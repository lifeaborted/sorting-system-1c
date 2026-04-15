# This Python file uses the following encoding: utf-8
import logging
from typing import final, Optional

from PySide6 import QtCore
from PySide6.QtCore import Property
from PySide6.QtQml import QmlElement, QmlSingleton
from PySide6.QtCore import QObject, Slot, Property, Signal

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

    @Slot(str, str, str)
    def login(self, *args):
        if self._user is None:
            self._user = User(args[0], args[1], args[2])
            logging.info(f"Login as {self._user.format_username('{first} {second} {middle}')}")
        else:
            logging.warning("Tried to login while being already, skipping...")

    @Slot()
    def logout(self):
        self._user = None
