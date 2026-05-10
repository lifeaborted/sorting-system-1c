"""
Главная точка входа
"""
import logging
import json
import io
from pathlib import Path
from datetime import datetime
import cv2
import numpy as np

from fastapi import FastAPI, UploadFile, File, HTTPException, BackgroundTasks
from fastapi.responses import JSONResponse

from config_manager import load_or_create_config
from pipeline import MarkingPipeline
from utils import draw_detections
from parser import parse_text_to_fields
from api_client import APIClient

ROOT_FOLDER = Path(__file__).resolve().parent.parent
CONFIG_PATH = ROOT_FOLDER / "data" / "config.json"
OUTPUT_FOLDER = ROOT_FOLDER / "src" / "data" / "output"
CROPS_DIR = ROOT_FOLDER / "src" / "data" / "crops"

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s", force=True)
logger = logging.getLogger(__name__)

app = FastAPI(title="Neural Marking Service")

pipeline = None
api_client = None


@app.on_event("startup")
async def startup_event():
    """Инициализация тяжелых моделей перед запуском сервера."""
    global pipeline, api_client

    logger.info("Инициализация моделей...")

    OUTPUT_FOLDER.mkdir(parents=True, exist_ok=True)
    CROPS_DIR.mkdir(parents=True, exist_ok=True)

    cfg = load_or_create_config(CONFIG_PATH)

    neural_cfg = cfg.get("neural", {})
    output_cfg = cfg.get("output", {})
    output_cfg["crops_dir"] = str(CROPS_DIR)

    pipeline = MarkingPipeline(neural_cfg, output_cfg)

    conn_cfg = cfg.get("connection", {})
    host = conn_cfg.get("host", "localhost")
    port = conn_cfg.get("port", 5000)

    try:
        api_client = APIClient(host=host, port=port)
    except Exception as e:
        logger.warning(f"Сервер запущен без авторизации на JS-бэкенде: {e}")
        api_client = None

    logger.info("Сервер готов к приему изображений.")


def process_in_background(contents: bytes, filename: str):
    logger.info(f"Фоновая обработка началась: {filename}")

    # 1. Декодирование
    nparr = np.frombuffer(contents, np.uint8)
    img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
    if img is None:
        logger.error(f"Не удалось декодировать {filename}")
        return

    # 2. Пайплайн (YOLO + OCR)
    source_name = filename
    result = pipeline.process_image(img, source=source_name)

    # 3. Парсинг
    full_text = " ".join([d.text for d in result.detections])
    payload = parse_text_to_fields(full_text)

    # 4. Визуализация
    annotated_img = draw_detections(img, result)

    # 5. Сохранение файлов
    timestamp = datetime.now().strftime("%Y-%m-%dT%H-%M-%S")
    base_filename = Path(source_name).stem

    result_json_path = OUTPUT_FOLDER / f"{base_filename}_result.json"
    with open(result_json_path, "w", encoding="utf-8") as f:
        f.write(result.to_json())

    payload_json_path = OUTPUT_FOLDER / f"{base_filename}_payload.json"
    with open(payload_json_path, "w", encoding="utf-8") as f:
        json.dump(payload, f, indent=2, ensure_ascii=False)

    annotated_img_path = OUTPUT_FOLDER / f"{base_filename}_annotated.jpg"
    cv2.imwrite(str(annotated_img_path), annotated_img)

    logger.info(f"Файлы сохранены: {base_filename}")

    # 6. Отправка на JS сервер
    if api_client:
        api_client.send_scan_result(payload, annotated_img, source_name)
    else:
        logger.warning("Нет связи с JS сервером.")


@app.post("/upload/")
async def upload_image(
        background_tasks: BackgroundTasks,
        file: UploadFile = File(...)
):

    if pipeline is None:
        raise HTTPException(status_code=503, detail="Models not initialized")

    logger.info(f"Получен запрос на обработку: {file.filename}")

    contents = await file.read()

    background_tasks.add_task(process_in_background, contents, file.filename)

    return JSONResponse(
        status_code=202,
        content={
            "status": "accepted",
            "message": "Image queued for processing",
            "filename": file.filename
        }
    )


if __name__ == "__main__":
    import uvicorn

    cfg = load_or_create_config(CONFIG_PATH)
    server_cfg = cfg.get("server", {})
    host = server_cfg.get("host", "localhost")
    port = server_cfg.get("port", 5001)

    logger.info(f"Запуск HTTP сервера на {host}:{port}")
    uvicorn.run(app, host=host, port=port)