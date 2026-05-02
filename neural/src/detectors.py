"""
Класс, отвечающий только за поиск объектов (YOLO)
"""

import logging
from typing import Optional
import numpy as np
from ultralytics import YOLO

logger = logging.getLogger(__name__)


class YOLODetector:
    def __init__(
            self,
            config: dict
    ):
        self.conf = config.get("conf_threshold", 0.25)
        self.iou = config.get("iou_threshold", 0.45)
        path = config.get("model_path", "yolov8n.pt")

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