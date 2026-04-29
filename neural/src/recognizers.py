"""
Класс, отвечающий за чтение текста и всю предобработку
"""

import cv2
import logging
import paddle
from paddleocr import PaddleOCR
import numpy as np

logger = logging.getLogger(__name__)


class OCRRecognizer:
    def __init__(self, lang: str = "en", use_gpu: bool = False, min_conf: float = 0.6):
        self.min_conf = min_conf

        if use_gpu:
            if not paddle.is_compiled_with_cuda():
                logger.warning("PaddlePaddle не собран с CUDA, используется CPU")
                paddle.set_device('cpu')
            else:
                paddle.set_device('gpu')
        else:
            paddle.set_device('cpu')

        logger.info(f"Инициализация PaddleOCR (lang={lang}, gpu={use_gpu})")
        self.ocr = PaddleOCR(use_angle_cls=False, lang=lang)

    def recognize(self, crop: np.ndarray) -> tuple[str, float]:
        """
        Адаптивное распознавание с предобработкой.
        Возвращает (текст, уверенность).
        """

        def run_ocr(img):
            try:
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

        # === Проход 1: С улучшением (для сложных фото) ===
        try:
            processed = self._preprocess_image(crop)
            text_proc, conf_proc = run_ocr(processed)
        except Exception:
            text_proc, conf_proc = "", 0.0

        if conf_proc > 0.8:
            return text_proc, conf_proc

        # === Проход 2: Исходное изображение (для четких фото) ===
        text_raw, conf_raw = run_ocr(crop)

        if conf_proc >= conf_raw:
            return text_proc, conf_proc
        else:
            return text_raw, conf_raw

    def _preprocess_image(self, crop: np.ndarray) -> np.ndarray:
        """Внутренняя логика улучшения картинки для OCR."""
        # 1. Рамка
        border_size = 10
        processed = cv2.copyMakeBorder(crop, border_size, border_size, border_size, border_size,
                                       cv2.BORDER_CONSTANT, value=[255, 255, 255])
        # 2. Увеличение
        h, w = processed.shape[:2]
        processed = cv2.resize(processed, (w * 2, h * 2), interpolation=cv2.INTER_LINEAR)

        # 3. Улучшение контраста (CLAHE)
        lab = cv2.cvtColor(processed, cv2.COLOR_BGR2LAB)
        l, a, b = cv2.split(lab)
        clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))
        l = clahe.apply(l)
        processed = cv2.cvtColor(cv2.merge((l, a, b)), cv2.COLOR_LAB2BGR)

        return processed