from typing import Awaitable

from controller.api.http import HttpWrapper, T
from controller.api.user import UserApi


class Api:
    def __init__(self, host: str, port: int):
        self.client = HttpWrapper(f"{host}:{port}")
        self.user = UserApi(self.client)

    def run_blocking(self, f: Awaitable[T]) -> T:
        return self.client.run_blocking(f)
