"""
Инкапсуляция работы с сетью и авторизацией.
Надежное шифрование токена через Fernet (cryptography).
"""

import os
import sys
import json
import base64
import time
import getpass
import requests
import cv2
import numpy as np

from logger_config import setup_logger
setup_logger()

from loguru import logger
from typing import Optional
from pathlib import Path
from cryptography.fernet import Fernet
from dotenv import load_dotenv


env_path = Path(__file__).resolve().parent.parent / ".env"
load_dotenv(env_path)

SECRET_KEY = os.getenv('KEY')

if not SECRET_KEY:
    SECRET_KEY = Fernet.generate_key().decode('utf-8')
    try:
        with open(env_path, "a", encoding="utf-8") as f:
            f.write(f"\nKEY={SECRET_KEY}\n")
    except Exception as e:
        logger.error(f"Не удалось сохранить ключ в .env: {e}")

try:
    cipher_suite = Fernet(SECRET_KEY.encode('utf-8'))
except Exception as e:
    logger.critical(f"Неверный ключ шифрования! Ошибка: {e}")
    cipher_suite = None

AUTH_FILE = Path(__file__).resolve().parent.parent / "data" / "auth.dat"

class APIClient:
    def __init__(self, host: str, port: int):
        self.host = host
        self.port = port
        self.token = None
        self._saved_credentials = None

        self.base_url = f"http://{host}:{port}"
        self.scan_url = f"{self.base_url}/api/service/scan"
        self.auth_url = f"{self.base_url}/api/user/login"
        self.renew_url = f"{self.base_url}/api/user/auth"
        self.last_renewal_time = time.time()

        self._ensure_authenticated()

    # --- Методы шифрования Fernet ---

    @staticmethod
    def encrypt_data(data: str) -> bytes:
        if not cipher_suite: return b''
        return cipher_suite.encrypt(data.encode('utf-8'))

    @staticmethod
    def decrypt_data(encrypted_data: bytes) -> str:
        if not cipher_suite: return ""
        try:
            return cipher_suite.decrypt(encrypted_data).decode('utf-8')
        except Exception:
            return "" # Файл поврежден или ключ неверен

    # --- Работа с файлом ---

    @staticmethod
    def _decode_jwt_payload(token: str) -> Optional[dict]:
        try:
            payload_segment = token.split('.')[1]
            rem = len(payload_segment) % 4
            if rem > 0:
                payload_segment += '=' * (4 - rem)
            decoded_bytes = base64.urlsafe_b64decode(payload_segment)
            return json.loads(decoded_bytes)
        except Exception:
            return None

    @staticmethod
    def is_token_valid(token: str) -> bool:
        payload = APIClient._decode_jwt_payload(token)
        if not payload: return False
        exp = payload.get("exp")
        if not exp: return True
        return time.time() < (exp - 60)


    def _ensure_authenticated(self):
        # 1. Проверка аргументов
        token_from_arg = self._check_arguments()
        if token_from_arg and self.is_token_valid(token_from_arg):
            self.token = token_from_arg
            return

        # 2. Проверка файла
        token_from_file = self.load_token_from_file()
        if token_from_file:
            self.token = token_from_file
            return

        # 3. Ввод пароля
        self._interactive_login_flow()


    @staticmethod
    def load_token_from_file() -> Optional[str]:
        if not os.path.exists(AUTH_FILE):
            return None
        try:
            with open(AUTH_FILE, "rb") as f:
                encrypted_data = f.read()

            decrypted_token = APIClient.decrypt_data(encrypted_data)

            if decrypted_token and APIClient.is_token_valid(decrypted_token):
                logger.info("Найден валидный зашифрованный токен.")
                return decrypted_token
        except Exception as e:
            logger.error(f"Ошибка чтения auth.dat: {e}")
        return None

    def save_token_to_file(self):
        try:
            encrypted_data = APIClient.encrypt_data(self.token)
            with open(AUTH_FILE, "wb") as f: # Пишем как байты!
                f.write(encrypted_data)
        except Exception as e:
            logger.error(f"Не удалось сохранить токен: {e}")

    # --- Логика процесса авторизации ---


    @staticmethod
    def _check_arguments() -> Optional[str]:
        for i in sys.argv[1:]:
            if i.startswith("TOKEN="):
                return i.removeprefix("TOKEN=")
        return None

    def _interactive_login_flow(self):
        print("\n" + "="*40)
        print("Требуется авторизация")
        print("="*40)
        while True:
            login = input("Введите логин: ")
            password = getpass.getpass("Введите пароль: ")
            if self.authenticate(login, password):
                self._saved_credentials = (login, password)
                self.save_token_to_file()
                print("Авторизация успешна!\n")
                break
            print("Ошибка авторизации. Повторите попытку.")

    def authenticate(self, login: str, password: str) -> bool:
        try:
            credentials = {"login": login, "password": password}
            response = requests.post(self.auth_url, json=credentials, timeout=10)
            if response.status_code == 200:
                self.token = response.json().get('token')
                if self.token:
                    self.last_renewal_time = time.time()
                    return True
        except Exception as e:
            logger.error(f"Ошибка соединения: {e}")
        self.token = None
        return False

    def renew_token(self) -> bool:
        if not self.token: return False
        try:
            headers = {'Authorization': f'Bearer {self.token}'}
            response = requests.get(self.renew_url, headers=headers, timeout=10)
            if response.status_code == 200:
                self.token = response.json().get('token')
                if self.token:
                    self.save_token_to_file()
                    self.last_renewal_time = time.time()
                    logger.debug("Токен успешно продлен в фоновом режиме.")
                    return True
        except Exception as e:
            logger.error(f"Ошибка продления токена: {e}")
        return False

    def send_scan_result(self, fields: dict, image_np: np.ndarray, filename: str) -> bool:
        if not self.token: return False

        # Автопродление токена, если с прошлой выдачи прошел 1 час (3600 секунд)
        if time.time() - self.last_renewal_time >= 3600:
            self.renew_token()

        try:
            _, img_encoded = cv2.imencode('.jpg', image_np)
            files = {'image': (filename, img_encoded.tobytes(), 'image/jpeg')}
            data = {'serial_number': fields['serial_number'], 'batch_number': fields['batch_number']}
            headers = {'Authorization': f'Bearer {self.token}'}

            response = requests.post(self.scan_url, files=files, data=data, headers=headers, timeout=10)

            if response.status_code in [401, 403]:
                logger.warning("Токен отклонен. Попытка продления...")
                if self.renew_token():
                    headers['Authorization'] = f'Bearer {self.token}'
                    response = requests.post(self.scan_url, files=files, data=data, headers=headers, timeout=10)
                elif self._saved_credentials:
                    l, p = self._saved_credentials
                    if self.authenticate(l, p):
                        self.save_token_to_file()
                        headers['Authorization'] = f'Bearer {self.token}'
                        response = requests.post(self.scan_url, files=files, data=data, headers=headers, timeout=10)

            if response.status_code == 200:
                logger.debug("<- Успешно отправлено.")
                return True
            logger.error(f"<- Ошибка {response.status_code}")
            return False
        except Exception as e:
            logger.error(f"Ошибка отправки: {e}")
            return False