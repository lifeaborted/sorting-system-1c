"""
Вспомогательные функции визуализации
"""

import cv2
import numpy as np
from models import PipelineResult

def draw_detections(image: np.ndarray, result: PipelineResult) -> np.ndarray:
    """Нарисовать bbox и текст на изображении."""
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