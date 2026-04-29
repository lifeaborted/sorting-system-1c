import asyncio
import json
import logging
import threading
from asyncio import AbstractEventLoop
from threading import Thread
from typing import TypedDict, Callable

import aiohttp
from aiohttp.web_ws import WebSocketResponse

from controller.api.api import Api
from controller.api.orders import OrdersApi
from controller.api.parts import PartsApi


class DetailScanned(TypedDict):
    part: PartsApi.Detail
    order: OrdersApi.Order
    image: PartsApi.Image
    isSorted: bool

class UserHandlersWss(TypedDict):
    on_detail_scanned: Callable[[DetailScanned], None]
    on_error: Callable[[str], None]


class UserWss:
    _api: Api
    _thread: Thread
    _is_stopped: bool = False
    _loop: AbstractEventLoop
    def __init__(self, api: Api, handlers: UserHandlersWss):
        self._ev = asyncio.Event()
        self._api = api
        self._handlers = handlers

    def start(self):
        if self._is_stopped:
            logging.error(f"[UserWss] Trying to start a stopped websocket... ignoring")
            return
        self._thread = threading.Thread(target=self._api.run_blocking, args=(self._api.user.detail_wss(self._socket_loop),))
        self._thread.start()

    def stop(self):
        self._log("Trying to stop websocket")
        self._is_stopped = True
        self._loop.call_soon_threadsafe(self._ev.set)
        self._thread.join()

    async def _socket_loop(self, ws: WebSocketResponse):
        self._loop = asyncio.get_event_loop()
        self._log("Thread started")
        while True:
            done, pending = await asyncio.wait([
                asyncio.create_task(ws.receive()),
                asyncio.create_task(self._ev.wait())
            ], return_when=asyncio.FIRST_COMPLETED)
            for task in pending:
                task.cancel()

            if self._is_stopped:
                break

            msg = done.pop().result()

            if msg.type == aiohttp.WSMsgType.TEXT:
                data = json.loads(msg.data)
                status = data["status"]
                self._log(f"New message, status={status}")
                if status == 200:
                    self._handlers["on_detail_scanned"](data)
                elif status == 404:
                    self._handlers["on_error"](data["message"])
            elif msg.type == aiohttp.WSMsgType.ERROR:
                self._log(f"Received error: {msg} ")
                break

        self._log("Thread stopped")


    def _log(self, text: str):
        logging.info(f"[UserWss]{text}")

