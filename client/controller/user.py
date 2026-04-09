# This Python file uses the following encoding: utf-8
from PySide6 import QtCore
from PySide6.QtCore import QObject, Slot
from PySide6.QtQml import QmlElement

QML_IMPORT_NAME = "io.backend"
QML_IMPORT_MAJOR_VERSION = 1
QML_IMPORT_MINOR_VERSION = 0
@QmlElement
class User(QObject):
    def __init__(
            self,
            first_name: str,
            last_name: str,
            middle_name: str,
            parent = None
    ):
        super().__init__(parent)
        self._first_name = first_name
        self._last_name = last_name
        self._middle_name = middle_name

    @Slot(str, result = str)
    def format_username(self, form: str):
        return form.format(first=self._first_name, second=self._last_name, middle=self._middle_name)
