import logging
from logger_config import setup_logger

setup_logger()
logger = logging.getLogger(__name__)

import json
import cv2
import numpy as np

from pathlib import Path
from config_manager import load_or_create_config
from pipeline import MarkingPipeline
from utils import draw_detections
from parser import parse_text_to_fields
from api_client import APIClient
from datetime import datetime


ROOT_FOLDER = Path(__file__).resolve().parent.parent
CONFIG_PATH = ROOT_FOLDER / "data" / "config.json"
OUTPUT_FOLDER = ROOT_FOLDER / "data" / "output"
CROPS_DIR = ROOT_FOLDER / "data" / "crops"

pipeline = None
api_client = None


def initialize():
    """
    Инициализация всех компонентов (вызывается один раз при старте).
    """
    global pipeline, api_client

    logger.info("Инициализация моделей и коннектов...")

    OUTPUT_FOLDER.mkdir(parents=True, exist_ok=True)
    CROPS_DIR.mkdir(parents=True, exist_ok=True)

    cfg = load_or_create_config(CONFIG_PATH)

    neural_cfg = cfg.get("neural", {})
    output_cfg = cfg.get("output", {})
    output_cfg["crops_dir"] = str(CROPS_DIR)  # Передаем путь для crops

    pipeline = MarkingPipeline(neural_cfg, output_cfg)

    conn_cfg = cfg.get("connection", {})
    host = conn_cfg.get("host", "localhost")
    port = conn_cfg.get("port", 5001)

    try:
        api_client = APIClient(host=host, port=port)
    except Exception as e:
        logger.warning(f"Не удалось подключиться к API: {e}")
        api_client = None

    logger.info("Прогрев нейросетей...")
    try:
        dummy_img = np.zeros((640, 640, 3), dtype=np.uint8)
        pipeline.process_image(dummy_img, source="warmup")
        logger.info("Прогрев успешно завершен.")
    except Exception as e:
        logger.warning(f"Ошибка при прогреве: {e}")

    logger.info("Инициализация завершена.")


def process_image_logic(contents: bytes, filename: str) -> dict:
    """
    Основная логика обработки изображения.
    Принимает байты файла и имя файла.
    Возвращает словарь с результатами.
    """
    if pipeline is None:
        raise RuntimeError("Models not initialized. Call initialize() first.")

    # 1. Декодирование
    nparr = np.frombuffer(contents, np.uint8)
    img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
    if img is None:
        logger.error(f"Не удалось прочитать изображение: {filename}")
        return {"status": "error", "detail": "Invalid image"}

    # 2. Запуск пайплайна
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

    logger.info(f"Обработка завершена: {filename} (за {result.processing_time_ms} мс)")

    # 6. Отправка на JS сервер
    if api_client:
        api_client.send_scan_result(payload, annotated_img, source_name)

    return {
        "status": "success",
        "payload": payload,
        "processing_time_ms": result.processing_time_ms
    }


if __name__ == "__main__":
    initialize()
    print("Модуль логики загружен. Для работы используйте server.py")