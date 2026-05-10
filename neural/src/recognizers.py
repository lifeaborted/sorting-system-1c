"""
Класс, отвечающий за чтение текста и всю предобработку
"""

import cv2
import logging
import time
import paddle
from paddleocr import PaddleOCR
import numpy as np

logger = logging.getLogger(__name__)


class OCRRecognizer:
    def __init__(
            self,
            config: dict
    ):
        self.min_conf = config.get("min_confidence", 0.6)
        use_gpu = config.get("use_gpu", False)
        lang = config.get("lang", "en")
        use_angle_cls = config.get("use_angle_cls", "False")
        text_recognition_batch_size = config.get("batch", 6)
        text_detection_model_name = config.get("detection_model", "PP-OCRv5_mobile_det")  # Легкая мобильная модель поиска
        text_recognition_model_name = config.get("recognition_model", "PP-OCRv5_mobile_rec")  # Легкая мобильная модель поиска

        if use_gpu:
            if not paddle.is_compiled_with_cuda():
                logger.warning("PaddlePaddle не собран с CUDA, используется CPU")
                paddle.set_device('cpu')
            else:
                paddle.set_device('gpu')
        else:
            paddle.set_device('cpu')

        logger.info(f"Инициализация PaddleOCR (lang={lang}, gpu={use_gpu})")
        self.ocr = PaddleOCR(use_angle_cls=use_angle_cls,
                             device='gpu:0' if use_gpu else 'cpu',
                             lang=lang,
                             engine="paddle_static",
                             text_recognition_batch_size=text_recognition_batch_size,
                             text_detection_model_name=text_detection_model_name,
                             text_recognition_model_name=text_recognition_model_name
                             )

    def recognize(self, crop: np.ndarray) -> tuple[str, float]:
        """
        Адаптивное распознавание с предобработкой и замером времени.
        Возвращает (текст, уверенность).
        """

        def run_ocr(img):
            try:
                img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
                result = self.ocr.ocr(img_rgb, det=False, rec=True)
            except TypeError:
                result = self.ocr.ocr(img)
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

        t_total_start = time.perf_counter()

        # --- Проход 1: С улучшением (для сложных фото) ---
        t_prep_start = time.perf_counter()
        try:
            processed = self._preprocess_image(crop)
        except Exception as e:
            logger.error(f"Ошибка предобработки: {e}")
            processed = crop # Fallback
        t_prep_end = time.perf_counter()
        dt_prep = (t_prep_end - t_prep_start) * 1000

        t_ocr1_start = time.perf_counter()
        try:
            text_proc, conf_proc = run_ocr(processed)
        except Exception:
            text_proc, conf_proc = "", 0.0
        t_ocr1_end = time.perf_counter()
        dt_ocr1 = (t_ocr1_end - t_ocr1_start) * 1000

        if conf_proc > 0.8:
            t_total_end = time.perf_counter()
            dt_total = (t_total_end - t_total_start) * 1000
            logger.info(f"TIMING | Total: {dt_total:.1f}ms | Prep: {dt_prep:.1f}ms | OCR Pass1: {dt_ocr1:.1f}ms | Result: Processed")
            return text_proc, conf_proc

        # --- Проход 2: Исходное изображение (для четких фото) ---
        t_ocr2_start = time.perf_counter()
        text_raw, conf_raw = run_ocr(crop)
        t_ocr2_end = time.perf_counter()
        dt_ocr2 = (t_ocr2_end - t_ocr2_start) * 1000

        t_total_end = time.perf_counter()
        dt_total = (t_total_end - t_total_start) * 1000

        if conf_proc >= conf_raw:
            logger.info(f"TIMING | Total: {dt_total:.1f}ms | Prep: {dt_prep:.1f}ms | OCR Pass1: {dt_ocr1:.1f}ms | OCR Pass2: {dt_ocr2:.1f}ms | Result: Processed")
            return text_proc, conf_proc
        else:
            logger.info(f"TIMING | Total: {dt_total:.1f}ms | Prep: {dt_prep:.1f}ms | OCR Pass1: {dt_ocr1:.1f}ms | OCR Pass2: {dt_ocr2:.1f}ms | Result: Raw")
            return text_raw, conf_raw

    def _preprocess_image(self, crop: np.ndarray) -> np.ndarray:
        """
        Оптимизированная предобработка.
        """
        h, w = crop.shape[:2]

        max_side = 640
        if max(h, w) > max_side:
            scale = max_side / max(h, w)
            processed = cv2.resize(crop, (int(w * scale), int(h * scale)), interpolation=cv2.INTER_AREA)
        elif max(h, w) < 200:
            processed = cv2.resize(crop, (w * 2, h * 2), interpolation=cv2.INTER_CUBIC)
        else:
            processed = crop

        # 2. Рамка
        border_size = 10
        processed = cv2.copyMakeBorder(processed, border_size, border_size, border_size, border_size,
                                       cv2.BORDER_CONSTANT, value=[255, 255, 255])

        # 3. Улучшение контраста (CLAHE)
        lab = cv2.cvtColor(processed, cv2.COLOR_BGR2LAB)
        l, a, b = cv2.split(lab)
        clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))
        l = clahe.apply(l)
        processed = cv2.cvtColor(cv2.merge((l, a, b)), cv2.COLOR_LAB2BGR)

        return processed