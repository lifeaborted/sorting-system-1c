import json
from typing import Optional, Union, Literal, TypedDict

from PySide6 import QtCore
from PySide6.QtCore import QObject, Slot, Property, Signal
from PySide6.QtQml import QmlElement
from dataclasses import dataclass


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
    name: str
    address: Address
    created_at: str

class OrderShort(TypedDict):
    id: int
    name: str

class DetailType(TypedDict):
    id: int
    name: str
    code: str
    price: int
    order_item_type_id: Optional[int]

class Detail(TypedDict):
    id: int
    serial_number: str
    batch_number: str
    manufacture_date: str
    order: Optional[OrderShort]
    warehouse: Optional[Warehouse]
    sorted_at: Optional[str]
    qc_inspector_id: Optional[int]
    type: DetailType
    status: Literal["pending", "in_production", "sorting", "completed", "canceled"]


class DetailsFilter(TypedDict):
    search: str
    detail_type: dict[str, int]
    batch: dict[str, str]
    status: dict[str, str]
    order: dict[str, int]
    warehouse: dict[str, int]