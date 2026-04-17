# Пайплайн распознавания маркировки

Реализует схему: **Камера/Файл → YOLOv8 → PaddleOCR → JSON**

## Установка

```bash
pip install -r requirements.txt
```

Для GPU (PaddlePaddle):
```bash
pip install paddlepaddle-gpu>=2.6.0
# и установите в config.json: "use_gpu": true
```

## Запуск

```bash
# Одно изображение
python run.py --image part_001.jpg

# Папка с изображениями
python run.py --folder ./test_images/

# Захват с камеры (S — обработать кадр, Q — выйти)
python run.py --camera
```

## Пример выходного JSON

```json
{
  "timestamp": "2026-04-14T10:33:21",
  "source": "part_001.jpg",
  "processing_time_ms": 87.4,
  "status": "ok",
  "error": null,
  "detections": [
    {
      "bbox": [142, 88, 310, 144],
      "confidence": 0.891,
      "text": "АТ-7834-Б",
      "ocr_confidence": 0.943
    }
  ]
}
```

## Подключение собственной модели YOLO

Если у вас ещё нет дообученной модели (детекция именно области гравировки),
пайплайн работает с предобученным `yolov8n.pt` — он детектирует общие объекты,
что полезно для проверки OCR-части.

Для дообучения:

1. Собрать датасет: сфотографировать изделия, разметить bbox вокруг гравировки
   (например, в LabelImg или CVAT).
2. Структура датасета:
   ```
   dataset/
     images/train/  images/val/
     labels/train/  labels/val/
   data.yaml
   ```
3. Запустить дообучение:
   ```bash
   yolo detect train model=yolov8n.pt data=data.yaml epochs=50 imgsz=640
   ```
4. Указать путь к `best.pt` в `config.json` → `yolo.model_path`.

## Интеграция с 1С

Результат `PipelineResult.to_json()` — готовый JSON для отправки через REST API.
Структура полностью совместима с описанием в FR-05 технического задания.

Пример отправки (добавить в `run.py` или отдельный модуль):

```python
import requests

result_json = pipeline.process_file("part.jpg").to_json()
resp = requests.post(
    "http://1c-server/marking/api/v1/recognition",
    data=result_json,
    headers={"Content-Type": "application/json", "Authorization": "Bearer <token>"},
)
```

## Файлы

| Файл | Назначение |
|---|---|
| `pipeline.py` | Класс `MarkingPipeline` — ядро пайплайна |
| `run.py` | CLI-точка входа |
| `config.json` | Конфигурация (пороги, пути, язык OCR) |
| `requirements.txt` | Зависимости |
