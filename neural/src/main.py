import sys
import time
import logging
import shutil
import json
import threading
import os
from pathlib import Path
from typing import Optional
import cv2

from config_manager import load_or_create_config
from pipeline import MarkingPipeline
from utils import draw_detections
from parser import parse_text_to_fields
from api_client import APIClient

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s", force=True)

ROOT_FOLDER = Path(__file__).resolve().parent.parent

INPUT_FOLDER = ROOT_FOLDER/"src"/"data"/"input"
OUTPUT_FOLDER = ROOT_FOLDER/"src"/"data"/"output"
PROCESSED_FOLDER = ROOT_FOLDER/"src"/"data"/"done"
CONFIG_PATH = ROOT_FOLDER/"data"/"config.json"


def listen_for_exit():
    while True:
        user_input = input()
        if user_input.lower() == 'exit':
            print("\nЗавершение работы...")
            os._exit(0)


def main():
    cfg = load_or_create_config(CONFIG_PATH)

    print("Инициализация моделей, пожалуйста, подождите...")

    INPUT_FOLDER.mkdir(parents=True, exist_ok=True)
    OUTPUT_FOLDER.mkdir(parents=True, exist_ok=True)
    PROCESSED_FOLDER.mkdir(parents=True, exist_ok=True)

    neural_cfg = cfg.get("neural", {})
    output_cfg = cfg.get("output", {})
    pipeline = MarkingPipeline(neural_cfg, output_cfg)

    print("Модели загружены! Начинаю слежение за папкой 'input'...")
    print('Для завершения работы введите "exit" и нажмите Enter.')

    conn_cfg = cfg.get("connection", {})
    host = conn_cfg.get("host", "localhost")
    port = conn_cfg.get("port", 5000)

    try:
        api_client = APIClient(host=host, port=port)
    except Exception as e:
        logging.critical(f"Не удалось инициализировать API клиент: {e}")
        return

    # Поток для выхода
    exit_thread = threading.Thread(target=listen_for_exit, daemon=True)
    exit_thread.start()

    # Основной цикл
    while True:
        try:
            files = list(INPUT_FOLDER.glob("*.[jJ][pP][gG]")) + \
                    list(INPUT_FOLDER.glob("*.[pP][nN][gG]"))

            if not files:
                time.sleep(0.5)
                continue

            for img_path in files:
                logging.info(f"Обработка файла: {img_path.name}")

                img = cv2.imread(str(img_path))
                if img is None:
                    shutil.move(str(img_path), Path(PROCESSED_FOLDER) / img_path.name)
                    continue

                # 1. Запуск пайплайна (YOLO + OCR)
                result = pipeline.process_image(img, source=img_path.name)

                # 2. Парсинг текста
                full_text = " ".join([d.text for d in result.detections])
                payload = parse_text_to_fields(full_text)

                # 3. Визуализация
                annotated_img = draw_detections(img, result)

                # 4. Сохранение результатов локально
                result_json_path = Path(OUTPUT_FOLDER) / f"{img_path.stem}_result.json"
                with open(result_json_path, "w", encoding="utf-8") as f:
                    f.write(result.to_json())

                payload_json_path = Path(OUTPUT_FOLDER) / f"{img_path.stem}_payload.json"
                with open(payload_json_path, "w", encoding="utf-8") as f:
                    json.dump(payload, f, indent=2, ensure_ascii=False)

                annotated_img_path = Path(OUTPUT_FOLDER) / f"{img_path.stem}_annotated.jpg"
                cv2.imwrite(str(annotated_img_path), annotated_img)

                logging.info(f"Результаты сохранены в папку 'output'")

                # 5. Отправка на сервер
                api_client.send_scan_result(payload, annotated_img, img_path.name)

                # 6. Архивация исходника
                shutil.move(str(img_path), Path(PROCESSED_FOLDER) / img_path.name)

        except KeyboardInterrupt:
            logging.info("Остановка работы.")
            break
        except Exception as e:
            logging.error(f"Критическая ошибка: {e}")
            time.sleep(1)


if __name__ == "__main__":
    main()