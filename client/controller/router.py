# This Python file uses the following encoding: utf-8
import sys
from pathlib import Path
from typing import Optional, TypedDict, NotRequired

from PySide6.QtCore import QObject, Slot, Property, Signal
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine, QmlElement, QmlSingleton, QJSValue
from PySide6.QtQuick import QQuickItem

QML_IMPORT_NAME = "io.backend"
QML_IMPORT_MAJOR_VERSION = 1
QML_IMPORT_MINOR_VERSION = 0

class RouteParams(TypedDict):
    data: NotRequired["QVariantMap"]
    route: str
    popup: NotRequired[bool]

@QmlElement
class Router(QObject):
    _route_changed = Signal()
    popupRequested = Signal(dict)
    def __init__(self, parent = None):
        super().__init__(parent)
        self._route = RouteParams(route="")


    @Property(str, notify = _route_changed, final = True )
    def route(self):
        return self._route["route"]

    @route.setter
    def route(self, r):
        self._change_route(RouteParams(
            route=r
        ))

    @Property("QVariantMap", notify = _route_changed, final = True )
    def data(self):
        return self._route.get("data", {})

    @Slot(str, "QVariantMap")
    def set_route_detailed(self, route: str, data: "QVariantMap"):
        self._change_route(RouteParams(
            route=route,
            data=data
        ))

    @Slot(str, "QVariantMap")
    def open_popup_detailed(self, route: str, data: "QVariantMap"):
        self._change_route(RouteParams(
            route=route,
            data=data,
            popup=True
        ))

    @Slot(str, "QVariantMap")
    def _change_route(self, route: RouteParams):
        if route.get("popup", False):
            self.popupRequested.emit(route)
        else:
            self._route = route
            self._route_changed.emit()


@QmlElement
class Page(QQuickItem):
    _path: str
    _page: QObject
    _use_router_data: bool = False
    _use_window: bool = False
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

    @Property(bool, final=True, constant=True)
    def useRouterData(self):
        return self._use_router_data

    @useRouterData.setter
    def useRouterData(self, p):
        self._use_router_data = p

    @Property(bool, final=True, constant=True)
    def useWindow(self):
        return self._use_window

    @useRouterData.setter
    def useWindow(self, p):
        self._use_window = p