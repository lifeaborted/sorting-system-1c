import cv2
import json
import time
import logging
from pathlib import Path
from dataclasses import dataclass, field, asdict
from typing import Optional
import numpy as np
from ultralytics import YOLO
from paddleocr import PaddleOCR
import paddle

logger = logging.getLogger(__name__)

@dataclass
class Detection:
    bbox: list[int]          # [x1, y1, x2, y2] в пикселях
    confidence: float        # уверенность детектора (0..1)
    text: str                # распознанный текст
    ocr_confidence: float    # уверенность OCR (0..1)


@dataclass
class PipelineResult:
    timestamp: str
    source: str
    processing_time_ms: float
    detections: list[Detection] = field(default_factory=list)
    status: str = "ok"
    error: Optional[str] = None

    def to_json(self, indent: int = 2) -> str:
        d = asdict(self)
        return json.dumps(d, ensure_ascii=False, indent=indent)

"""
Пайплайн: изображение → YOLO → PaddleOCR → PipelineResult.

Параметры:
    yolo_model_path: путь к .pt-файлу весов YOLO. Если None — загружается
                     предобученный yolov8n (детекция объектов вместо
                     маркировки; замените на дообученную модель).
    yolo_conf:       порог уверенности детектора (рекомендуется 0.5–0.7).
    yolo_iou:        порог IoU для NMS.
    ocr_lang:        язык OCR. 'en' — только латиница/цифры; 'ch' — +CJK.
    ocr_use_gpu:     использовать GPU для OCR (требует CUDA + paddlepaddle-gpu).
    crop_padding:    отступ в пикселях вокруг bbox перед передачей в OCR.
    min_ocr_conf:    минимальная уверенность OCR для включения в результат.
    save_crops:      сохранять ли вырезки с детекциями (для отладки/дообучения).
    crops_dir:       папка для сохранения вырезок.
"""

class MarkingPipeline:
    def __init__(
        self,
        yolo_model_path: Optional[str] = None,
        yolo_conf: float = 0.5,
        yolo_iou: float = 0.45,
        ocr_lang: str = "en",
        ocr_use_gpu: bool = False,
        crop_padding: int = 8,
        min_ocr_conf: float = 0.6,
        save_crops: bool = False,
        crops_dir: str = "crops",
    ):
        self.yolo_conf = yolo_conf
        self.yolo_iou = yolo_iou
        self.crop_padding = crop_padding
        self.min_ocr_conf = min_ocr_conf
        self.save_crops = save_crops
        self.crops_dir = Path(crops_dir)

        if save_crops:
            self.crops_dir.mkdir(parents=True, exist_ok=True)

        # --- YOLO ---
        model_path = yolo_model_path or "yolov8n.pt"
        logger.info(f"Загрузка YOLO: {model_path}")
        self.yolo = YOLO(model_path)

        # --- PaddleOCR ---
        # use_angle_cls=True — распознавание повёрнутого текста
        # det=True  — включить детектор текстовых строк внутри crop
        # rec=True  — включить распознаватель символов

        if ocr_use_gpu:
            if not paddle.is_compiled_with_cuda():
                logger.warning("PaddlePaddle не собран с CUDA, будет использован CPU")
                paddle.set_device('cpu')
            else:
                paddle.set_device('gpu')
                logger.info("Используется GPU")
        else:
            # Использовать CPU
            paddle.set_device('cpu')
            logger.info("Используется CPU")

        logger.info(f"Инициализация PaddleOCR (lang={ocr_lang}, gpu={ocr_use_gpu})")
        self.ocr = PaddleOCR(
            use_angle_cls=False, #True для не горизонтального текста
            lang=ocr_lang
        )

        logger.info("Пайплайн инициализирован.")

    def process_image(self, image: np.ndarray, source: str = "frame") -> PipelineResult:
        """
        Обработка кадра.
        """
        t0 = time.perf_counter()
        timestamp = time.strftime("%Y-%m-%dT%H:%M:%S")

        try:
            detections = self._run(image, source, timestamp)
            status = "ok" if detections else "no_detections"
            result = PipelineResult(
                timestamp=timestamp,
                source=source,
                processing_time_ms=round((time.perf_counter() - t0) * 1000, 1),
                detections=detections,
                status=status,
            )
        except Exception as exc:
            logger.exception("Ошибка в пайплайне")
            result = PipelineResult(
                timestamp=timestamp,
                source=source,
                processing_time_ms=round((time.perf_counter() - t0) * 1000, 1),
                status="error",
                error=str(exc),
            )

        logger.debug(f"[{source}] {result.status} — {result.processing_time_ms} мс")
        return result

    def process_file(self, path: str) -> PipelineResult:
        """Чтение и обработка файла."""
        img = cv2.imread(path)
        if img is None:
            raise FileNotFoundError(f"Не удалось прочитать изображение: {path}")
        return self.process_image(img, source=path)


    def _run(
        self, image: np.ndarray, source: str, timestamp: str
    ) -> list[Detection]:
        """Запустить YOLO → обрезка → OCR для каждой детекции."""
        h, w = image.shape[:2]
        detections: list[Detection] = []

        # 1. YOLO: детекция областей с маркировкой
        yolo_results = self.yolo.predict(
            source=image,
            conf=self.yolo_conf,
            iou=self.yolo_iou,
            verbose=True,
        )
        boxes = yolo_results[0].boxes  # Boxes object

        if boxes is None or len(boxes) == 0:
            print("!!! YOLO: детекции не найдены !!!")  # Временная диагностика
            return []

        for i, box in enumerate(boxes):
            x1, y1, x2, y2 = map(int, box.xyxy[0].tolist())
            yolo_conf = float(box.conf[0])

            # Добавляем отступ, не выходя за границы кадра
            x1p = max(0, x1 - self.crop_padding)
            y1p = max(0, y1 - self.crop_padding)
            x2p = min(w, x2 + self.crop_padding)
            y2p = min(h, y2 + self.crop_padding)

            crop = image[y1p:y2p, x1p:x2p]

            if self.save_crops:
                # Заменяем двоеточия на дефисы, чтобы Windows не ругался
                safe_timestamp = timestamp.replace(":", "-")
                crop_name = f"{Path(source).stem}_{safe_timestamp}_{i}.jpg"
                cv2.imwrite(str(self.crops_dir / crop_name), crop)

            # 2. PaddleOCR: распознать текст в вырезке
            text, ocr_conf = self._ocr_crop(crop)
            if ocr_conf < self.min_ocr_conf:
                logger.debug(
                    f"OCR: уверенность {ocr_conf:.2f} < {self.min_ocr_conf}, "
                    f"пропускаем bbox #{i}"
                )
                continue

            detections.append(
                Detection(
                    bbox=[x1, y1, x2, y2],
                    confidence=round(yolo_conf, 4),
                    text=text,
                    ocr_confidence=round(ocr_conf, 4),
                )
            )

        return detections

    def _ocr_crop(self, crop: np.ndarray) -> tuple[str, float]:
        """
        Адаптивное распознавание:
        1. Пробуем улучшенное изображение.
        2. Если уверенность низкая - пробуем исходное.
        3. Возвращаем лучший результат.
        """

        def run_ocr(img):
            try:
                # PaddleOCR 3.x лучше работает с RGB
                img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
                result = self.ocr.ocr(img_rgb)
            except TypeError:
                result = self.ocr.ocr(img, cls=True)
            except Exception:
                return "", 0.0

            if not result:
                return "", 0.0

            result_obj = result[0]
            if isinstance(result_obj, dict):
                texts = result_obj.get('rec_texts', [])
                scores = result_obj.get('rec_scores', [])
            else:
                texts = getattr(result_obj, 'rec_texts', [])
                scores = getattr(result_obj, 'rec_scores', [])

            if texts:
                full_text = " ".join(str(t) for t in texts)
                avg_conf = sum(scores) / len(scores) if scores else 0.0
                return full_text, avg_conf
            return "", 0.0


        # === ПРОХОД 1: С улучшением ===
        try:
            # 1. Рамка
            border_size = 10
            processed = cv2.copyMakeBorder(crop, border_size, border_size, border_size, border_size,
                                           cv2.BORDER_CONSTANT, value=[255, 255, 255])

            # 2. Увеличение
            h, w = processed.shape[:2]
            processed = cv2.resize(processed, (w * 2, h * 2), interpolation=cv2.INTER_LINEAR)

            # 3. Мягкое улучшение контраста
            lab = cv2.cvtColor(processed, cv2.COLOR_BGR2LAB)
            l, a, b = cv2.split(lab)
            clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))
            l = clahe.apply(l)
            processed = cv2.cvtColor(cv2.merge((l, a, b)), cv2.COLOR_LAB2BGR)

            text_proc, conf_proc = run_ocr(processed)
        except Exception:
            text_proc, conf_proc = "", 0.0

        if conf_proc > 0.8:
            return text_proc, conf_proc

        # === ПРОХОД 2: Исходное изображение ===
        text_raw, conf_raw = run_ocr(crop)

        # === ВЫБОР ЛУЧШЕГО РЕЗУЛЬТАТА ===
        if conf_proc >= conf_raw:
            return text_proc, conf_proc
        else:
            return text_raw, conf_raw


    @staticmethod
    def _draw_detections(image: np.ndarray, result: PipelineResult) -> np.ndarray:
        """Нарисовать bbox и текст на изображении"""
        img = image.copy()
        for det in result.detections:
            x1, y1, x2, y2 = det.bbox
            label = f"{det.text} ({det.ocr_confidence:.2f})"
            cv2.rectangle(img, (x1, y1), (x2, y2), (0, 200, 50), 2)
            cv2.putText(
                img, label,
                (x1, max(y1 - 8, 12)),
                cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 200, 50), 2,
            )
        return img