# This Python file uses the following encoding: utf-8
import uuid
from enum import Enum

from PySide6 import QtCore
from PySide6.QtCore import QObject, Property, QEnum, Signal, Slot
from PySide6.QtQml import QmlElement, ListProperty
from PySide6.QtQuick import QQuickItem

QML_IMPORT_NAME = "io.backend"
QML_IMPORT_MAJOR_VERSION = 1
QML_IMPORT_MINOR_VERSION = 0

@QmlElement
class Notification(QQuickItem):
    def __init__(self, title: str, message: str, importance: int, parent = None):
        self._title = title
        self._message = message
        self._importance = importance
        self.uuid = uuid.uuid4().__str__()
        super().__init__(parent)

    @Property(str, constant = True, final = True)
    def title(self):
        return self._title

    @title.setter
    def title(self, t):
        self._title = t

    @Property(str, constant=True, final=True)
    def message(self):
        return self._message

    @message.setter
    def message(self, m):
        self._message = m

    @Property(int, constant=True, final=True)
    def importance(self):
        return self._importance

    @importance.setter
    def importance(self, i):
        self._importance = i

@QmlElement
class Notificator(QObject):
    _notificationChanged = Signal()
    _notifications: list[Notification]
    def __init__(self, parent = None):
        self._notifications = []
        super().__init__(parent)

    @Slot(str, str, int, result=None)
    def new_notification(self, title: str, message: str, importance: int):
        self._append_notification(Notification(title, message, importance))

    def _append_notification(self, n):
        self._notifications.append(n)
        self._notificationChanged.emit()

    def _notifications_len(self):
        return len(self._notifications)

    def _notifications_at(self, x):
        return self._notifications[x]

    # Not using id, because we need to allow track each notification separately
    @Slot(str, result= None)
    def remove_notification(self, notification_uuid: str):
        for i, v in enumerate(self._notifications):
            if v.uuid == notification_uuid:
                self._notifications.pop(i)
        self._notificationChanged.emit()

    # ugly  ass binding
    notifications = ListProperty(
        Notification,
        _append_notification,
        count = _notifications_len,
        at = _notifications_at,
        notify = _notificationChanged,
    )







