# This Python file uses the following encoding: utf-8
import logging
from operator import itemgetter
from typing import List

from controller.api.api import Api
from controller.api.orders import OrdersApi
from controller.types.detail import *
import random
from datetime import datetime, timedelta

from controller.utils import dict_iterator

QML_IMPORT_NAME = "io.backend"
QML_IMPORT_MAJOR_VERSION = 1
QML_IMPORT_MINOR_VERSION = 0



@QmlElement
class User(QObject):
    _api: Api
    _first_name: str
    _last_name: str
    _middle_name: str
    _details: list[Detail] = None
    _details_types: dict[int, DetailType] = None
    _warehouses: dict[int, Warehouse] = None
    _orders: dict[int, OrdersApi.Order] = None
    _details_filter: DetailsFilter
    def __init__(
            self,
            parent = None
    ):
        super().__init__(parent)
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


    @staticmethod
    async def new(api: Api) -> 'User':
        user = User()
        user._api = api
        data = await api.user.me()
        user._first_name = data["first_name"]
        user._last_name = data["last_name"]
        user._middle_name = data["middle_name"]

        await user._load_details_from_api()

        return user


    @Slot(str, result = str)
    def format_username(self, form: str):
        return form.format(first=self._first_name, second=self._last_name, middle=self._middle_name)

    async def _load_warehouses(self):
        self._warehouses = {}
        raw_warehouses = await self._api.warehouses.get_all()
        for r_warehouse in raw_warehouses["rows"]:
            r_addr = r_warehouse["address"]
            self._warehouses[r_warehouse["warehouse_id"]] = Warehouse(
                id=r_warehouse["warehouse_id"],
                name=r_warehouse["name"],
                created_at=r_warehouse["created_at"],
                address=Address(
                    id=r_addr["address_id"],
                    country=r_addr["country"],
                    postal_code=r_addr["postal_code"],
                    building=r_addr["building"],
                    street=r_addr["street"],
                    region=r_addr["region"],
                    city=r_addr["city"]
                )
            )

    async def _load_details_types(self):
        self._details_types = {}
        raw_part_types = await self._api.part_types.get_all()
        for r_type in raw_part_types["rows"]:
            self._details_types[r_type["part_type_id"]] = DetailType(
                id=r_type["part_type_id"],
                name=r_type["name"],
                code=r_type["type_code"],
                price=r_type["price"],
            )

    async def _load_orders(self):
        self._orders = {}
        for i in (await self._api.orders.get_all())["rows"]:
            self._orders[i["order_id"]] = i

    async def _load_details_from_api(self):
        if self._details_types is None:
            await self._load_details_types()
        if self._warehouses is None:
            await self._load_warehouses()

        self._details = []
        raw_details = await self._api.parts.get_all()
        for r_detail in raw_details["rows"]:
            status = r_detail["status"]
            match status:
                case "manufactured":
                    status = "pending"
                case "sorted":
                    status = "completed"
                case _:
                    logging.error(f"Unknown detail status type={status}")
                    status = ""
            detail = Detail(
                id=r_detail["part_id"],
                batch_number=r_detail["batch_number"],
                manufacture_date=datetime.strptime(r_detail["manufacture_date"], "%Y-%m-%dT%H:%M:%S.%fZ").strftime("%d.%m.%y %H:%M:%S"),
                type=self._details_types[r_detail["part_type_id"]],
                serial_number=r_detail["serial_number"],
                sorted_at=r_detail["sorted_at"],
                warehouse=self._warehouses[r_detail["warehouse_id"]] if r_detail["warehouse_id"] is not None else None,
                qc_inspector_id=r_detail["qc_inspector_id"],
                order=None, # TODO
                status=status,
            )

            self._details.append(detail)
            self._details_filter["detail_type"][detail["type"]["name"]] = detail["type"]["id"]

            batch_number = detail["batch_number"]
            self._details_filter["batch"][batch_number] = batch_number


            if detail["warehouse"] is not None:
                wh_name = detail["warehouse"]["address"]["city"]
                self._details_filter["warehouse"][wh_name] = detail["warehouse"]["id"]

            if detail["order"]:
                self._details_filter["order"][detail["order"]["name"]] = detail["order"]["id"]



    @Slot("QVariant", result="QVariantList")
    def load_orders(self, f: QObject):
        if self._orders is None:
            self._api.run_blocking(self._load_orders())

        def filter_order(o: OrdersApi.Order) -> bool:
            if f.property("status") is not None:
                if o["status"] != f.property("status"):
                    return False

            if f.property("priority") is not None:
                if o["priority"] != f.property("priority"):
                    return False

            if f.property("customer") is not None:
                if o["customer_id"] != f.property("customer"):
                    return False

            if f.property("date") is not None:
                from_date = f.property("date").property("from")
                to_date = f.property("date").property("to")
                from_p = datetime.strptime(from_date, "%d.%m.%Y")
                to_p = datetime.strptime(f"{to_date} 23:59", "%d.%m.%Y %H:%M")
                o_date = datetime.strptime(o["created_at"], "%Y-%m-%dT%H:%M:%S.%fZ")
                if o_date < from_p or o_date > to_p:
                    return False
            return True

        arr = list(filter(filter_order, self._orders.values()))
        logging.info(f"For current filter found {len(arr)} orders")
        return arr

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
                if d["warehouse"] is None:
                    return False
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
                attr_getter = lambda x: (itemgetter("country", "region", "city", "street", "building"))(x["warehouse"]["address"]) if x["warehouse"] is not None else ("", "", "", "", "")
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

