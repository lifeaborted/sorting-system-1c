from logger_config import setup_logger
setup_logger()
from loguru import logger
from pathlib import Path
from config_manager import load_or_create_config
from pipeline import MarkingPipeline
from utils import draw_detections
from parser import parse_text_to_fields
from api_client import APIClient

import json
import cv2
import numpy as np

ROOT_FOLDER = Path(__file__).resolve().parent.parent
CONFIG_PATH = ROOT_FOLDER / "data" / "config.json"

pipeline = None
api_client = None


def initialize():
    """
    Инициализация всех компонентов (вызывается один раз при старте).
    """
    global pipeline, api_client

    logger.info("Инициализация моделей и коннектов...")

    cfg = load_or_create_config(CONFIG_PATH)

    neural_cfg = cfg.get("neural", {})
    output_cfg = cfg.get("output", {})

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

    #logger.info(f"Результат распознавания: {json.dumps(payload, ensure_ascii=False)}")
    logger.info(f"Обработка завершена: за {result.processing_time_ms} мс. Результат распознавания: {json.dumps(payload, ensure_ascii=False)}")

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