import json
import logging
import asyncio
from typing import Awaitable, Any, TypeVar, Generic, Callable, Optional

import aiohttp
from aiohttp import ClientResponse, ClientWebSocketResponse

T = TypeVar('T')

class HttpWrapper:
    def __init__(self, server_url: str, log: bool = True):
        self._token_auth: Optional[str] = None
        self.host = server_url
        self.log = log

    async def get(self, path: str) -> dict:
        self._log_route(path, "get")
        async with aiohttp.ClientSession(headers=self._headers()) as session:
            async with session.get(f"{self.host}{path}") as response:
                if response.status != 200:
                    await self._raise_response(response)
                return await response.json()

    async def post(self, path: str, data: dict) -> dict:
        self._log_route(path, "post")
        async with aiohttp.ClientSession(headers=self._headers()) as session:
            async with session.post(
                    f"{self.host}{path}",
                    json=data,
            ) as response:
                if response.status != 200:
                    await self._raise_response(response)
                return await response.json()

    async def put(self, path: str, data: dict) -> dict:
        self._log_route(path, "put")
        async with aiohttp.ClientSession(headers=self._headers()) as session:
            async with session.put(
                    f"{self.host}{path}",
                    json=data,
            ) as response:
                if response.status != 200:
                    await self._raise_response(response)
                return await response.json()

    async def wss(self, path: str, f: Callable[[ClientWebSocketResponse], Awaitable[None]]):
        self._log_route(path, "wss")

        async with aiohttp.ClientSession(headers=self._headers()) as session:
            async with session.ws_connect(f"{self.host}{path}") as ws:
                await f(ws)

    def _log_route(self, path: str, method: str):
        if self.log:
            logging.info(f"[HttpWrapper][{method.upper()}] Calling url {self.host}{path}")

    async def _raise_response(self, resp: ClientResponse):
        raise Exception(
            f"Error calling {resp.url}. status={resp.status}. text={await resp.text()}"
        )


    def _headers(self) -> dict:
        return {
            "Authorization": f"Bearer {self._token_auth}"
        }
    def use_auth(self, token: str):
        self._token_auth = token

    @staticmethod
    def run_blocking(f:Awaitable[T]) -> T:
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
        return loop.run_until_complete(f)