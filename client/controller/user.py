# This Python file uses the following encoding: utf-8
import logging
from operator import itemgetter
from typing import List

from controller.types.detail import *
import random
from datetime import datetime, timedelta

from controller.utils import dict_iterator

QML_IMPORT_NAME = "io.backend"
QML_IMPORT_MAJOR_VERSION = 1
QML_IMPORT_MINOR_VERSION = 0



@QmlElement
class User(QObject):
    _details: list[Detail] = []
    _details_filter: DetailsFilter
    def __init__(
            self,
            token: str,
            parent = None
    ):
        super().__init__(parent)
        self._token = token
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

        self._first_name = "Андрей"
        self._last_name = "Гайдулян"
        self._middle_name = "Сергеевич"

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
            manufacture_date = (start + timedelta(days=random_days)).strftime("%d.%m.%y %H:%M:%S")
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
        return self._details

    @Slot(result = "QVariantMap")
    def load_sorting_options(self):
        return self._details_filter



    @Slot("QVariant", "QVariant", result = "QVariantList")
    def load_details_filter(self, f: QObject, sortParams: QObject):
        ru_translate = {
            "pending": "обрабатывается",
            "in_production": "в производстве",
            "sorting": "сортировка",
            "completed": "отсортирован",
            "canceled": "отменён"
        }
        def filter_detail(d: Detail) -> bool:
            if f.property("date") is not None:
                from_date = f.property("date").property("from")
                to_date = f.property("date").property("to")
                from_p = datetime.strptime(from_date, "%d.%m.%Y")
                to_p = datetime.strptime(f"{to_date} 23:59", "%d.%m.%Y %H:%M")

                detail_date = datetime.strptime(d["manufacture_date"], "%d.%m.%y %H:%M:%S")
                if detail_date < from_p or detail_date > to_p:
                    return False
            type_f = f.property("type")
            if type_f is not None and type_f != "Все":
                if d["type"]["id"] != self._details_filter["detail_type"][type_f]:
                    return False

            batch_f = f.property("batch")
            if batch_f is not None and batch_f != "Все":
                if d["batch_number"] != self._details_filter["batch"][batch_f]:
                    return False

            status_f = f.property("status")
            if status_f is not None and status_f != "Все":
                if d["status"] != self._details_filter["status"][status_f]:
                    return False

            order_f = f.property("order")
            if order_f is not None and order_f != "Все":
                if d["order"] is None or d["order"]["id"] != self._details_filter["order"][order_f]:
                    return False

            warehouse_f = f.property("warehouse")
            if warehouse_f is not None and warehouse_f != "Все":
                if d["warehouse"]["id"] != self._details_filter["warehouse"][warehouse_f]:
                    return False

            words: dict = {}
            for k, v in dict_iterator(d):
                words[str(v).lower()] = True

            if f.property("search") is not None and f.property("search") != "":
                search_arr = str.split(f.property("search"), " ")
                for word in search_arr:
                    word = word.lower()
                    found=False
                    for k in words:
                        if ru_translate.get(k) is not None:
                            k = ru_translate[k]
                        if str.__contains__(k, word):
                            found=True
                            break
                    if not found:
                        return False

            return True


        data = filter(filter_detail, self._details)

        attr_getter = None
        sort_name = sortParams.property("propertyName")
        match sort_name:
            case "type":
                attr_getter = lambda x: x["type"]["name"]
            case "serial":
                attr_getter = lambda x: x["serial_number"]
            case "batch":
                attr_getter = lambda x: x["batch_number"]
            case "status":
                attr_getter = lambda x: x["status"]
            case "order":
                attr_getter = lambda x: (x.get("order") or {}).get("name", "")
            case "warehouse":
                attr_getter = lambda x: (itemgetter("country", "region", "city", "street", "building"))(x["warehouse"]["address"])
            case "date":
                attr_getter = lambda x: datetime.strptime(x["manufacture_date"], "%d.%m.%y %H:%M:%S")
            case _:
                logging.error(f"Unknown sorting property. propertyName={sort_name}")

        data = sorted(data, key=attr_getter, reverse=sortParams.property("sortAsc"))
        arr = list(data)
        logging.info(f"For current filter found {len(arr)} entry")
        return arr

    @Slot(int, result="QVariant")
    def get_detail(self, id: int):
        for i in self._details:
            if i["id"] == id:
                return i

        return None

