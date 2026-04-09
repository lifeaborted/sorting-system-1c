# This Python file uses the following encoding: utf-8
import sys
from pathlib import Path

from PySide6.QtCore import QObject, Slot, Property, Signal
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine, QmlElement, QmlSingleton
from PySide6.QtQuick import QQuickItem

QML_IMPORT_NAME = "io.backend"
QML_IMPORT_MAJOR_VERSION = 1
QML_IMPORT_MINOR_VERSION = 0

@QmlElement
class Router(QObject):
    _route_changed = Signal()
    def __init__(self, parent = None):
        super().__init__(parent)
        self._route = ""


    @Property(str, notify = _route_changed, final = True, )
    def route(self):
        return self._route

    @route.setter
    def route(self, r):
        self._route = r
        self._route_changed.emit()

@QmlElement
class Page(QQuickItem):
    _path: str
    _page: QObject
    def __init__(self, parent = None):
        super().__init__(parent)

    @Property(str, final=True, constant=True)
    def path(self):
        return self._path

    @path.setter
    def path(self, p):
        self._path = p

    @Property(QObject, final=True, constant=True)
    def page(self):
        return self._page

    @page.setter
    def page(self, p):
        self._page = p