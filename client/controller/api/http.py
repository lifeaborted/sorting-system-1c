import json
import logging
import asyncio
from typing import Awaitable, Any, TypeVar, Generic, Callable

import aiohttp
from aiohttp import ClientResponse

T = TypeVar('T')

class HttpWrapper:
    def __init__(self, server_url: str, log: bool = True):
        self.host = server_url
        self.log = log

    async def get(self, path: str) -> ClientResponse:
        self._log_route(path, "get")
        async with aiohttp.ClientSession() as session:
            async with session.get(f"{self.host}{path}") as response:
                if (await response.json()).get("status", 200) != 200: # fix when саня
                    await self._raise_response(response)
                return await response.json()

    async def post(self, path: str, data: dict):
        self._log_route(path, "post")

        async with aiohttp.ClientSession() as session:
            async with session.post(
                    f"{self.host}{path}",
                    json=data
            ) as response:
                if (await response.json()).get("status", 200) != 200: # fix when саня
                    await self._raise_response(response)
                return await response.json()

    def _log_route(self, path: str, method: str):
        if self.log:
            logging.info(f"[HttpWrapper][{method.upper()}] Calling url {self.host}{path}")
    async def _raise_response(self, resp: ClientResponse):
        raise Exception(
            f"Error calling {resp.url}. status={resp.status}. text={await resp.text()}"
        )


    @staticmethod
    def run_blocking(f:Awaitable[T]) -> T:
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
        return loop.run_until_complete(f)