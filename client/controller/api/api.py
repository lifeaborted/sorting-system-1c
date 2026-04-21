from typing import Awaitable

from controller.api.http import HttpWrapper, T
from controller.api.orders import OrdersApi
from controller.api.part_types import PartTypesApi
from controller.api.parts import PartsApi
from controller.api.user import UserApi
from controller.api.warehouses import WarehousesApi


class Api:
    def __init__(self, host: str, port: int):
        self.client = HttpWrapper(f"{host}:{port}")
        self.user = UserApi(self.client)
        self.parts = PartsApi(self.client)
        self.warehouses = WarehousesApi(self.client)
        self.part_types = PartTypesApi(self.client)
        self.orders = OrdersApi(self.client)

    def run_blocking(self, f: Awaitable[T]) -> T:
        return self.client.run_blocking(f)