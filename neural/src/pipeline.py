"""
Связь детектора и распознавателя
"""

import time
import logging
from pathlib import Path
import cv2
import numpy as np

from models import Detection, PipelineResult
from detectors import YOLODetector
from recognizers import OCRRecognizer

logger = logging.getLogger(__name__)


class MarkingPipeline:
    def __init__(
            self,
            yolo_model_path: str = None,
            yolo_conf: float = 0.5,
            yolo_iou: float = 0.45,
            ocr_lang: str = "en",
            ocr_use_gpu: bool = False,
            min_ocr_conf: float = 0.6,
            crop_padding: int = 8,
            save_crops: bool = False,
            crops_dir: str = "crops",
    ):
        # Инициализация компонентов
        self.detector = YOLODetector(yolo_model_path, yolo_conf, yolo_iou)
        self.recognizer = OCRRecognizer(ocr_lang, ocr_use_gpu, min_ocr_conf)

        self.crop_padding = crop_padding
        self.save_crops = save_crops
        self.crops_dir = Path(crops_dir)

        if save_crops:
            self.crops_dir.mkdir(parents=True, exist_ok=True)

    def process_image(self, image: np.ndarray, source: str = "frame") -> PipelineResult:
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
        return result

    def _run(self, image: np.ndarray, source: str, timestamp: str) -> list[Detection]:
        h, w = image.shape[:2]

        # 1. Детекция YOLO
        raw_boxes = self.detector.predict(image)

        if not raw_boxes:
            logger.debug("YOLO: нет детекций")
            return []

        final_detections = []

        # 2. Обработка каждой области
        for i, box_data in enumerate(raw_boxes):
            x1, y1, x2, y2 = box_data['bbox']
            yolo_conf = box_data['confidence']

            # Добавляем отступы
            x1p = max(0, x1 - self.crop_padding)
            y1p = max(0, y1 - self.crop_padding)
            x2p = min(w, x2 + self.crop_padding)
            y2p = min(h, y2 + self.crop_padding)

            crop = image[y1p:y2p, x1p:x2p]

            if self.save_crops:
                safe_timestamp = timestamp.replace(":", "-")
                crop_name = f"{Path(source).stem}_{safe_timestamp}_{i}.jpg"
                cv2.imwrite(str(self.crops_dir / crop_name), crop)

            # 3. Распознавание OCR
            text, ocr_conf = self.recognizer.recognize(crop)

            # Фильтр по уверенности теперь спрятан внутри recognizer,
            # но можно оставить и тут для логики сохранения
            if text == "" and ocr_conf == 0.0:
                continue

            final_detections.append(
                Detection(
                    bbox=[x1, y1, x2, y2],
                    confidence=round(yolo_conf, 4),
                    text=text,
                    ocr_confidence=round(ocr_conf, 4),
                )
            )

        return final_detections