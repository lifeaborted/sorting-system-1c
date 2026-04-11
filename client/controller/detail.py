# This Python file uses the following encoding: utf-8
import json
from typing import Optional, Union, Literal, TypedDict

from PySide6 import QtCore
from PySide6.QtCore import QObject, Slot, Property, Signal
from PySide6.QtQml import QmlElement
from dataclasses import dataclass

QML_IMPORT_NAME = "io.backend"
QML_IMPORT_MAJOR_VERSION = 1
QML_IMPORT_MINOR_VERSION = 0

class Address(TypedDict):
    id: int
    country: str
    region: str
    city: str
    street: str
    building: str
    postal_code: str

class Warehouse(TypedDict):
    id: int
    address: Address

class OrderShort(TypedDict):
    id: int
    name: str

class DetailType(TypedDict):
    id: int
    name: str
    code: str

class Detail(TypedDict):
    id: int
    serial_number: str
    batch_number: str
    manufacture_date: str
    order: Optional[OrderShort]
    warehouse: Warehouse
    type: DetailType
    status: Literal["pending", "in_production", "sorting", "completed", "canceled"]

