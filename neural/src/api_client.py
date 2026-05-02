"""
Инкапсуляция работы с сетью
"""

import os
import logging
from typing import Optional

import requests
import cv2
import numpy as np
from config_manager import load_or_create_config

cfg = load_or_create_config(os.path.join("config.json"))

conn_cfg = cfg.get("connection", {})
HOST = conn_cfg.get("host", "localhost")
PORT = conn_cfg.get("port", 5000)
BASE_URL = f"http://{HOST}:{PORT}"
SCAN_URL = f"{BASE_URL}/api/service/scan"
AUTH_URL = f"{BASE_URL}/api/user/login"
AUTH_USER = os.getenv('AUTH_USER', None)
AUTH_PASSWORD = os.getenv('AUTH_PASSWORD', None)


class APIClient:
    def __init__(self, token: Optional[str] = None):
        self.token = token
        self.try_login()

    def authenticate(self) -> bool:
        try:
            logging.info(f"Авторизация на {AUTH_URL}...")
            credentials = {"login": AUTH_USER, "password": AUTH_PASSWORD}
            response = requests.post(AUTH_URL, json=credentials, timeout=10)

            if response.status_code == 200:
                data = response.json()
                self.token = data.get('token')
                if self.token:
                    logging.info("JWT токен успешно получен.")
                    return True
                else:
                    logging.error(f"Токен не найден в ответе сервера.")
            else:
                logging.error(f"Ошибка авторизации {response.status_code}: {response.text}")
        except Exception as e:
            logging.error(f"Ошибка при получении токена: {e}")

        self.token = None
        return False


    def try_login(self):
        if self.token is None:
            logging.warning("Токен отсутствует. Попытка авторизации...")
            if not self.authenticate():
                raise Exception("Ошибка аунтефикации")

    def send_scan_result(self, fields: dict, image_np: np.ndarray, filename: str) -> bool:
        try:
            success, img_encoded = cv2.imencode('.jpg', image_np)
            if not success:
                return False
            img_bytes = img_encoded.tobytes()

            files = {'image': (filename, img_bytes, 'image/jpeg')}
            data = {
                'serial_number': fields['serial_number'],
                'batch_number': fields['batch_number']
            }
            headers = {'Authorization': f'Bearer {self.token}'}

            logging.info(f"-> Отправка данных: {data}")
            response = requests.post(SCAN_URL, files=files, data=data, headers=headers, timeout=10)

            # Если токен устарел
            if response.status_code == 403:
                logging.warning("Токен устарел. Повторная авторизация...")
                if self.authenticate():
                    headers['Authorization'] = f'Bearer {self.token}'
                    response = requests.post(SCAN_URL, files=files, data=data, headers=headers, timeout=10)

            if response.status_code == 200:
                logging.info(f"<- Успешно отправлено.")
                return True
            else:
                logging.error(f"<- Ошибка сервера {response.status_code}: {response.text}")
                return False

        except Exception as e:
            logging.error(f"Ошибка при отправке: {e}")
            return False