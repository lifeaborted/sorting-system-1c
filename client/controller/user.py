# This Python file uses the following encoding: utf-8
import json
import logging
import random
from datetime import datetime, timedelta
from typing import List

from PySide6 import QtCore
from PySide6.QtCore import QObject, Slot
from PySide6.QtQml import QmlElement

from controller.detail import *
import random
from datetime import datetime, timedelta
QML_IMPORT_NAME = "io.backend"
QML_IMPORT_MAJOR_VERSION = 1
QML_IMPORT_MINOR_VERSION = 0

class DetailsFilter(TypedDict):
    search: str
    detail_type: dict[str, int]
    batch: dict[str, str]
    status: dict[str, str]
    order: dict[str, int]
    warehouse: dict[str, int]

@QmlElement
class User(QObject):
    _details: list[Detail] = []
    _details_filter: DetailsFilter
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
        self._details_filter = {
            "search": "",
            "detail_type": {},
            "batch": {},
            "status": {
                "Обрабатывается": "pending",
                "В производстве": "in_production",
                "Сортировка": "sorting",
                "Отсортирован": "completed",
                "Отменён": "canceled"
            },
            "order": {},
            "warehouse": {}
        }
        self.create_details()

    @Slot(str, result = str)
    def format_username(self, form: str):
        return form.format(first=self._first_name, second=self._last_name, middle=self._middle_name)


    def create_details(self):
        # mock template for data
        self._details.clear()
        i = 0
        detailTypes: List[DetailType] = [
            DetailType(id=(i := i + 1) - 1, name="Шкив", code="SHK"),
            DetailType(id=(i := i + 1) - 1, name="Подшипник", code="PODIK"),
            DetailType(id=(i := i + 1) - 1, name="Вал", code="VAL"),
            DetailType(id=(i := i + 1) - 1, name="Гвоздь", code="GDE"),
        ]
        i = 0
        warehouses: List[Optional[Warehouse]] = [
            Warehouse(id=(i := i + 1) - 1, address=Address(
                id=0,
                country="Россия",
                region="Челябинская обл.",
                city="г. Челябинск",
                street="пр. Ленина",
                building="д. 228",
                postal_code="56789"
            )),
            Warehouse(id=(i := i + 1) - 1, address=Address(
                id=1,
                country="Россия",
                region="Московская обл.",
                city="г. Москва",
                street="пр. Москвы",
                building="д. 1",
                postal_code="1111"
            )),
            Warehouse(id=(i := i + 1) - 1, address=Address(
                id=2,
                country="Казахстан",
                region="Казахская обл.",
                city="г. Алмата",
                street="пр. Алматинский",
                building="д. 0000",
                postal_code="56788"
            )),
        ]
        i = 0
        statuses = ["pending", "in_production", "sorting", "completed", "canceled"]

        for i in range(100):
            # --- serial number ---
            serial_number = f"Ш-{random.randint(100, 999)}-{random.randint(1000000, 9999999)}"

            # --- batch number ---
            batch_number = f"П-{random.randint(10000, 99999)}"

            # --- random date ---
            start = datetime(2023, 1, 1)
            end = datetime(2026, 12, 31)
            delta = end - start
            random_days = random.randint(0, delta.days)
            manufacture_date = (start + timedelta(days=random_days)).strftime("%d.%m.%y")

            detail: Detail = {
                "id": i,
                "serial_number": serial_number,
                "batch_number": batch_number,
                "manufacture_date": manufacture_date,
                "order": None if random.random() < 0.3 else {
                    "id": random.randint(1, 20),
                    "name": f"№{random.randint(100, 999)}-ЧКПЗ-{random.randint(10, 99)}"
                },
                "warehouse": random.choice(warehouses),
                "type": random.choice(detailTypes),
                "status": random.choice(statuses)
            }
            self._details.append(detail)
            self._details_filter["detail_type"][detail["type"]["name"]] = detail["type"]["id"]

            self._details_filter["batch"][batch_number] = batch_number

            wh_name = detail["warehouse"]["address"]["city"]
            self._details_filter["warehouse"][wh_name] = detail["warehouse"]["id"]

            if detail["order"]:
                self._details_filter["order"][detail["order"]["name"]] = detail["order"]["id"]

    @Slot(result = "QVariantList")
    def load_details(self):
        dict_list = []
        for detail in self._details:
            dict_list.append(json.loads(json.dumps(detail)))
        return dict_list

    @Slot(result = "QVariantMap")
    def load_sorting_options(self):
        return self._details_filter

    @Slot("QVariant", result = "QVariantList")
    def load_details_filter(self, f: QObject):
        data = self._details
        if f.property("search") is not None:
            # data = filter(lambda d: d[""])
            pass

        if f.property("date") is not None:
            # data = filter(lambda d: d[""])
            pass

        type_f = f.property("type")
        if type_f is not None and type_f != "Все":
            data = filter(
                lambda d: d["type"]["id"] == self._details_filter["detail_type"][type_f],
                data
            )

        batch_f = f.property("batch")
        if batch_f is not None and batch_f != "Все":
            data = filter(
                lambda d: d["batch_number"] == self._details_filter["batch"][batch_f],
                data
            )

        status_f = f.property("status")
        if status_f is not None and status_f != "Все":
            data = filter(
                lambda d: d["status"] == self._details_filter["status"][status_f],
                data
            )

        order_f = f.property("order")
        if order_f is not None and order_f != "Все":
            data = filter(
                lambda d: d["order"] is not None and
                          d["order"]["id"] == self._details_filter["order"][order_f],
                data
            )

        warehouse_f = f.property("warehouse")
        if warehouse_f is not None and warehouse_f != "Все":
            data = filter(
                lambda d: d["warehouse"]["id"] == self._details_filter["warehouse"][warehouse_f],
                data
            )

        arr = list(data)
        logging.info(f"For current filter found {len(arr)} entry")
        return arr
