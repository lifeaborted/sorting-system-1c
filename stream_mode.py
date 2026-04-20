import time
import logging
import shutil
from pathlib import Path
from pipeline import MarkingPipeline, PipelineResult
import json
import cv2
import requests
import numpy as np
from dotenv import load_dotenv
import os
import datetime
import sys

load_dotenv()
logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")

CONFIG_PATH = "config.json"
INPUT_FOLDER = "input"
OUTPUT_FOLDER = "output"
PROCESSED_FOLDER = "done"

PORT = os.getenv('PORT', 5000)
API_URL = f"http://localhost:{os.getenv('PORT')}/service/scan"
API_KEY = os.getenv("SCANNER_API_KEY")


def load_config(path):
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def parse_text_to_fields(raw_text: str) -> dict:
    current_dt = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')

    return {
        "serial_number": raw_text.strip() if raw_text else "UNDEFINED",
        "batch_number": "N/A",
        "manufacture_date": current_dt
    }


def send_to_server(fields: dict, image_np: np.ndarray, filename: str):
    """
    Отправка на Node.js через form-data
    """
    try:
        success, img_encoded = cv2.imencode('.jpg', image_np)
        if not success:
            logging.error("Ошибка кодирования изображения")
            return
        img_bytes = img_encoded.tobytes()

        files = {
            'image': (filename, img_bytes, 'image/jpeg')
        }

        headers = {
            'Authorization': f'Bearer {API_KEY}'
        }

        logging.info(f"-> Отправка данных: {fields}")

        response = requests.post(API_URL, files=files, data=fields, headers=headers, timeout=10)

        if response.status_code in [200, 201]:
            logging.info(f"<- Успешно отправлено. Ответ: {response.text}")
        else:
            logging.error(f"<- Ошибка сервера {response.status_code}: {response.text}")

    except requests.exceptions.RequestException as e:
        logging.error(f"Ошибка соединения: {e}")
    except Exception as e:
        logging.error(f"Ошибка при отправке: {e}")


def main():
    print("Инициализация моделей, пожалуйста, подождите...")
    Path(INPUT_FOLDER).mkdir(exist_ok=True)
    Path(OUTPUT_FOLDER).mkdir(exist_ok=True)
    Path(PROCESSED_FOLDER).mkdir(exist_ok=True)

    cfg = load_config(CONFIG_PATH)

    init_args = {
        "yolo_model_path": cfg["yolo"].get("model_path"),
        "yolo_conf": cfg["yolo"]["conf_threshold"],
        "yolo_iou": cfg["yolo"]["iou_threshold"],
        "ocr_lang": cfg["ocr"]["lang"],  # Должен быть 'en'
        "ocr_use_gpu": cfg["ocr"]["use_gpu"],
        "min_ocr_conf": cfg["ocr"]["min_confidence"],
        "crop_padding": cfg["ocr"]["crop_padding_px"],
        "save_crops": False,
        "crops_dir": cfg["output"]["crops_dir"],
    }

    pipeline = MarkingPipeline(**init_args)
    print("Модели загружены! Начинаю слежение за папкой 'input'...")

    while True:
        try:
            user_input = input("""Для завершения работы введите "exit":""")
            if user_input.lower() == 'exit':
                print("Выход из программы.")
                sys.exit()

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

                result = pipeline.process_image(img, source=img_path.name)

                full_text = " ".join([d.text for d in result.detections])
                payload = parse_text_to_fields(full_text)

                annotated_img = MarkingPipeline._draw_detections(img, result)

                # А) Технический JSON (полный ответ пайплайна)
                result_json_path = Path(OUTPUT_FOLDER) / f"{img_path.stem}_result.json"
                with open(result_json_path, "w", encoding="utf-8") as f:
                    f.write(result.to_json())

                # Б) JSON для отправки (поля формы)
                payload_json_path = Path(OUTPUT_FOLDER) / f"{img_path.stem}_payload.json"
                with open(payload_json_path, "w", encoding="utf-8") as f:
                    json.dump(payload, f, indent=2, ensure_ascii=False)

                annotated_img_path = Path(OUTPUT_FOLDER) / f"{img_path.stem}_annotated.jpg"
                cv2.imwrite(str(annotated_img_path), annotated_img)

                logging.info(f"Результаты сохранены в папку 'output' (json + jpg)")

                send_to_server(payload, annotated_img, img_path.name)

                shutil.move(str(img_path), Path(PROCESSED_FOLDER) / img_path.name)

        except KeyboardInterrupt:
            logging.info("Остановка работы.")
            break
        except Exception as e:
            logging.error(f"Критическая ошибка: {e}")
            time.sleep(1)


if __name__ == "__main__":
    main()