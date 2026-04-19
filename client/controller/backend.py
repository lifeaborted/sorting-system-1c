# This Python file uses the following encoding: utf-8
import asyncio
import logging
import os
from typing import final, Optional, Any

from dotenv import load_dotenv
from PySide6 import QtCore, QtAsyncio
from PySide6.QtCore import Property
from PySide6.QtQml import QmlElement, QmlSingleton
from PySide6.QtCore import QObject, Slot, Property, Signal

from controller.api.api import Api
from controller.notification import Notificator
from controller.router import Router
from controller.user import User

QML_IMPORT_NAME = "io.backend"
QML_IMPORT_MAJOR_VERSION = 1
QML_IMPORT_MINOR_VERSION = 0

@QmlElement
@QmlSingleton
class Backend(QObject):
    _router: Router
    _notificator: Notificator
    _user: Optional[User]
    _user_changed = Signal()
    def __init__(self, parent=None):
        super().__init__(parent)
        self._api = Api(os.getenv("SERVER_URL"), int(os.getenv("PORT")))
        self._router = Router()
        self._notificator = Notificator()
        self._user = None

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
                self._user = User(data["token"])
                logging.info(f"Login as {self._user.format_username('{first} {second} {middle}')}")
                self._router.set_route_detailed("/details", None)
            except Exception as e:
                self._notificator.new_err_notification("Error", e.__str__())
                logging.error(e)


        else:
            logging.warning("Tried to login while being already, skipping...")

    @Slot()
    def logout(self):
        self._user = None
