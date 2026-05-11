"""
Вспомогательные функции визуализации
"""

import numpy as np

from models import PipelineResult
from ultralytics.utils.plotting import Annotator, colors
from parser import parse_text_to_fields


def draw_detections(image: np.ndarray, result: PipelineResult) -> np.ndarray:
    """Нарисовать bbox и текст с помощью ultralytics Annotator."""
    img = image.copy()

    annotator = Annotator(img, line_width=3)

    for det in result.detections:
        box = det.bbox

        fields = parse_text_to_fields(det.text)
        sn = fields.get("serial_number", "")
        bn = fields.get("batch_number", "")

        if bn != "N/A":
            parsed_text = f"{sn} {bn}"
        else:
            parsed_text = sn

        label = f"{parsed_text} ({det.ocr_confidence:.2f})"

        annotator.box_label(box, label, color=(255, 0, 0))

    # Возвращаем итоговое изображение
    return annotator.result()