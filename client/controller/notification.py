# This Python file uses the following encoding: utf-8
import uuid
from enum import Enum
from typing import TypedDict

from PySide6 import QtCore
from PySide6.QtCore import QObject, Property, QEnum, Signal, Slot
from PySide6.QtQml import QmlElement, ListProperty
from PySide6.QtQuick import QQuickItem

QML_IMPORT_NAME = "io.backend"
QML_IMPORT_MAJOR_VERSION = 1
QML_IMPORT_MINOR_VERSION = 0

class Notification(TypedDict):
    title: str
    message: str
    importance: str
    uuid: str

@QmlElement
class Notificator(QObject):
    notificationChanged = Signal()
    _notifications: list[Notification]
    _visible: list[Notification]

    def __init__(self, parent=None):
        self._notifications = []
        self._visible = []
        super().__init__(parent)

    @Slot(str, str, result=None)
    def new_err_notification(self, title: str, message: str):
        self._append_notification(self._create_notification(title, message, "error"))

    @Slot(str, str, result=None)
    def new_success_notification(self, title: str, message: str):
        self._append_notification(self._create_notification(title, message, "success"))

    @Slot(str, str, result=None)
    def new_normal_notification(self, title: str, message: str):
        self._append_notification(self._create_notification(title, message, "normal"))

    @Property("QVariantList", notify=notificationChanged)
    def notifications(self):
        return self._notifications

    @Property("QVariantList", notify=notificationChanged)
    def visible_notifications(self):
        return self._visible

    def _update_visible(self):
        last_four = self._notifications[-4:] if len(self._notifications) > 4 else self._notifications
        self._visible = list(reversed(last_four))
        self.notificationChanged.emit()

    def _create_notification(self, title: str, message: str, importance: str) -> Notification:
        return Notification(title=title, message=message, importance=importance, uuid=uuid.uuid4().__str__())

    def _append_notification(self, n):
        self._notifications.append(n)
        self._update_visible()

    # Not using id, because we need to allow track each notification separately
    @Slot(str, result=None)
    def remove_notification(self, notification_uuid: str):
        for i, v in enumerate(self._notifications):
            if v["uuid"] == notification_uuid:
                self._notifications.pop(i)
                break
        self._update_visible()








