import time
import logging
import shutil
import json
import threading
import os
from pathlib import Path
import cv2

# Импорт наших модулей
from pipeline import MarkingPipeline
from utils import draw_detections
from parser import parse_text_to_fields
from api_client import APIClient

# Настройка логирования
logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s", force=True)

# Константы
INPUT_FOLDER = os.path.join("data", "input")
OUTPUT_FOLDER = os.path.join("data", "output")
PROCESSED_FOLDER = os.path.join("data", "done")
CONFIG_PATH = os.path.join("config.json")


def load_config(path):
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def listen_for_exit():
    while True:
        user_input = input()
        if user_input.lower() == 'exit':
            print("\nЗавершение работы...")
            os._exit(0)


def main():
    print("Инициализация моделей, пожалуйста, подождите...")

    # Создание папок
    Path(INPUT_FOLDER).mkdir(exist_ok=True)
    Path(OUTPUT_FOLDER).mkdir(exist_ok=True)
    Path(PROCESSED_FOLDER).mkdir(exist_ok=True)

    # Загрузка конфига
    cfg = load_config(CONFIG_PATH)

    # Инициализация компонентов
    pipeline = MarkingPipeline(
        yolo_model_path=cfg["yolo"].get("model_path"),
        yolo_conf=cfg["yolo"]["conf_threshold"],
        yolo_iou=cfg["yolo"]["iou_threshold"],
        ocr_lang=cfg["ocr"]["lang"],
        ocr_use_gpu=cfg["ocr"]["use_gpu"],
        min_ocr_conf=cfg["ocr"]["min_confidence"],
        crop_padding=cfg["ocr"]["crop_padding_px"],
        save_crops=cfg["output"]["save_crops"],
        crops_dir=cfg["output"]["crops_dir"],
    )

    api_client = APIClient()

    print("Модели загружены! Начинаю слежение за папкой 'input'...")
    print('Для завершения работы введите "exit" и нажмите Enter.')

    # Поток для выхода
    exit_thread = threading.Thread(target=listen_for_exit, daemon=True)
    exit_thread.start()

    # Основной цикл
    while True:
        try:
            files = list(Path(INPUT_FOLDER).glob("*.[jJ][pP][gG]")) + \
                    list(Path(INPUT_FOLDER).glob("*.[pP][nN][gG]"))

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