# This Python file uses the following encoding: utf-8
import asyncio
import logging
import os
import traceback
from typing import final, Optional, Any, Callable

from dotenv import load_dotenv
from PySide6 import QtCore, QtAsyncio
from PySide6.QtCore import Property
from PySide6.QtQml import QmlElement, QmlSingleton
from PySide6.QtCore import QObject, Slot, Property, Signal

from controller.api.api import Api
from controller.config import load_config, save_config
from controller.nn_wrapper import NeuralNetworkWrapper
from controller.notification import Notificator
from controller.router import Router
from controller.user import User

QML_IMPORT_NAME = "io.backend"
QML_IMPORT_MAJOR_VERSION = 1
QML_IMPORT_MINOR_VERSION = 0

_shutdown_exec: Optional[Callable[[], None]] = None
def execute_shutdown():
    logging.info("[ON_EXIT]Called shutdown executor")
    if _shutdown_exec is not None:
        _shutdown_exec()
@QmlElement
@QmlSingleton
class Backend(QObject):
    _router: Router
    _notificator: Notificator
    _user: Optional[User]
    _user_changed = Signal()
    _neural_wrapper: Optional[NeuralNetworkWrapper]
    def __init__(self, parent=None):
        super().__init__(parent)
        global _shutdown_exec
        _shutdown_exec = self.on_shutdown
        self._api = Api(os.getenv("SERVER_URL"), int(os.getenv("PORT")))
        self._router = Router()
        self._notificator = Notificator()
        self._user = None
        self._conf = load_config()
        if self._conf.get("token"):
            logging.info("Found token in conf file")
            try:
                self.login_token(self._conf.get("token"))
            except Exception as e:
                logging.error(traceback.format_exc())
                logging.error(f"Auth failed err={e.__str__()}. Stacktrace above")

    @Property(Router, constant=True, final = True)
    def router(self):
        return self._router

    @Property(Notificator, constant=True, final = True)
    def notificator(self):
        return self._notificator

    @Property(User, notify = _user_changed)
    def user(self):
        return self._user

    @Slot(str, str)
    def login(self, login: str, password: str):
        if self._user is None:
            try:
                data = self._api.run_blocking(self._api.user.login({
                    "login": login,
                    "password": password
                }))
                token = data["token"]
                self.login_token(token)
            except Exception as e:
                self._notificator.new_err_notification("Error", e.__str__())
                logging.error(e)
        else:
            logging.warning("Tried to login while being already, skipping...")

    def login_token(self, token: str):
        self._api.client.use_auth(token)
        self._user = self._api.run_blocking(User.new(self._api, self._router, self._notificator))
        logging.info(f"Login as {self._user.format_username('{first} {second} {middle}')}")
        self._conf["token"] = token
        save_config(self._conf)

        self._neural_wrapper = NeuralNetworkWrapper(token)
        self._router.set_route_detailed("/details", None)

    @Slot()
    def logout(self):
        self._user.stop()
        self._user = None
        self._conf["token"] = None
        save_config(self._conf)

    def on_shutdown(self):
        if self.user is not None:
            self._user.stop()
        if self._neural_wrapper is not None:
            self._neural_wrapper.stop()