"""
Здесь хранятся "контейнеры" данных
"""

import json
from dataclasses import dataclass, field, asdict
from typing import Optional

@dataclass
class Detection:
    bbox: list[int]
    confidence: float
    text: str
    ocr_confidence: float

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