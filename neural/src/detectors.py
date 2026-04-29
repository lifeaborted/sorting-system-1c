"""
Класс, отвечающий только за поиск объектов (YOLO)
"""

import logging
from typing import Optional
import numpy as np
from ultralytics import YOLO

logger = logging.getLogger(__name__)


class YOLODetector:
    def __init__(self, model_path: Optional[str] = None, conf: float = 0.5, iou: float = 0.45):
        self.conf = conf
        self.iou = iou
        path = model_path or "yolov8n.pt"
        logger.info(f"Загрузка YOLO модели: {path}")
        self.model = YOLO(path)

    def predict(self, image: np.ndarray) -> list:
        """
        Возвращает список словарей с координатами рамок.
        [{'bbox': [x1,y1,x2,y2], 'conf': float}, ...]
        """
        results = self.model.predict(source=image, conf=self.conf, iou=self.iou, verbose=False)
        boxes = results[0].boxes

        detections = []
        if boxes is None or len(boxes) == 0:
            return []

        for box in boxes:
            x1, y1, x2, y2 = map(int, box.xyxy[0].tolist())
            conf = float(box.conf[0])
            detections.append({
                'bbox': [x1, y1, x2, y2],
                'confidence': conf
            })
        return detections