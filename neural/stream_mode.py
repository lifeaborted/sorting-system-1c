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
import threading
import re


load_dotenv()
logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")

CONFIG_PATH = "config.json"
INPUT_FOLDER = "input"
OUTPUT_FOLDER = "output"
PROCESSED_FOLDER = "done"
global JWT_TOKEN

PORT = os.getenv('PORT', 5000)
AUTH_USER = os.getenv('AUTH_USER')
AUTH_PASSWORD = os.getenv('AUTH_PASSWORD')

BASE_URL = f"http://localhost:{PORT}/service/scan"
SCAN_URL = f"{BASE_URL}/api/service/scan"
AUTH_URL = f"{BASE_URL}/api/auth/login"


def load_config(path):
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def get_jwt_token():
    try:
        logging.info(f"Авторизация на {AUTH_URL}...")

        credentials = {
            "username": AUTH_USER,
            "password": AUTH_PASSWORD
        }

        response = requests.post(AUTH_URL, json=credentials, timeout=10)

        if response.status_code == 200:
            data = response.json()
            JWT_TOKEN = data.get('Token') or data.get('token')

            if JWT_TOKEN:
                logging.info("JWT токен успешно получен.")
                return True
            else:
                logging.error(f"Токен не найден в ответе сервера. Ответ: {data}")
        else:
            logging.error(f"Ошибка авторизации {response.status_code}: {response.text}")

    except Exception as e:
        logging.error(f"Ошибка при получении токена: {e}")

    JWT_TOKEN = None
    return False


def parse_text_to_fields(raw_text: str) -> dict:

    sn_pattern = r'SN-[A-Za-z0-9]+' # Регулярное выражение для Serial Number
    batch_pattern = r'B-\d+' # Регулярное выражение для Batch Number (B- + цифры)

    sn_match = re.search(sn_pattern, raw_text)
    serial_number = sn_match.group(0) if sn_match else "N/A"

    batch_match = re.search(batch_pattern, raw_text)
    batch_number = batch_match.group(0) if batch_match else "N/A"

    if serial_number == "N/A" and raw_text:
        serial_number = raw_text.strip()

    return {
        "serial_number": serial_number,
        "batch_number": batch_number
    }


def send_to_server(fields: dict, image_np: np.ndarray, filename: str):
    """
    Отправка данных from-data.
    Поля: serial_number, batch_number, image.
    """
    if not JWT_TOKEN:
        logging.warning("Токен отсутствует. Попытка авторизации...")
        if not get_jwt_token():
            logging.error("Не удалось получить токен. Отправка отменена.")
            return

    try:
        success, img_encoded = cv2.imencode('.jpg', image_np)
        if not success:
            return
        img_bytes = img_encoded.tobytes()

        files = {'image': (filename, img_bytes, 'image/jpeg')}
        data = {
            'serial_number': fields['serial_number'],
            'batch_number': fields['batch_number']
        }

        headers = {
            'Authorization': f'Bearer {JWT_TOKEN}'
        }

        logging.info(f"-> Отправка данных: {data}")

        response = requests.post(SCAN_URL, files=files, data=data, headers=headers, timeout=10)

        # Если 401 (Unauthorized) - значит токен просрочен
        if response.status_code == 401:
            logging.warning("Токен устарел. Попытка обновить и отправить повторно...")
            if get_jwt_token():
                headers['Authorization'] = f'Bearer {JWT_TOKEN}'
                response = requests.post(SCAN_URL, files=files, data=data, headers=headers, timeout=10)

        if response.status_code in [200, 201]:
            logging.info(f"<- Успешно отправлено. Ответ: {response.text}")
        else:
            logging.error(f"<- Ошибка сервера {response.status_code}: {response.text}")

    except Exception as e:
        logging.error(f"Ошибка при отправке: {e}")


def listen_for_exit():
    while True:
        user_input = input()
        if user_input.lower() == 'exit':
            print("\nЗавершение работы...")
            os._exit(0)


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
    print('Для завершения работы введите "exit" и нажмите Enter.')

    exit_thread = threading.Thread(target=listen_for_exit, daemon=True)
    exit_thread.start()
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