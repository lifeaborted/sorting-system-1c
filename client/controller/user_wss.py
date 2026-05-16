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
    _loop: AbstractEventLoop = None
    def __init__(self, api: Api, handlers: UserHandlersWss):
        self._ev = asyncio.Event()
        self._api = api
        self._handlers = handlers

    def start(self):
        if self._is_stopped:
            logging.error(f"[UserWss] Trying to start a stopped websocket... ignoring")
            return
        # TODO check why therad doesnt capture errors
        try:
            self._thread = threading.Thread(target=self._api.run_blocking, args=(self._api.user.detail_wss(self._socket_loop),))

            self._thread.start()
        except Exception as e:
            logging.error(f"[UserWss] Failed to start thread. Err={e}")

    def stop(self, join_thread: bool = True):
        self._log("Trying to stop websocket")
        self._is_stopped = True
        if self._loop:
            self._loop.call_soon_threadsafe(self._ev.set)
        if self._thread and join_thread:
            self._thread.join()

    async def _socket_loop(self, ws: WebSocketResponse, clean: bool = True, retry: int = 3):
        if clean:
            self._loop = asyncio.get_event_loop()
            self._log("Thread started")
        else:
            self._log(f"Reconnected")
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
            elif msg.type == aiohttp.WSMsgType.CLOSED:
                self._log(f"Client disconnected.")
                while retry > 0:
                    self._log(f"Available attempts to reconnect {retry}")
                    await asyncio.sleep(4)
                    try:
                        retry -= 1
                        await self._api.user.detail_wss(lambda d: self._socket_loop(d, False, retry))
                        break
                    except Exception as e:
                        self._log(f"Failed to reconnect.")
                else:
                    self._log(f"No more available attempts")
                break
        self._log("Thread stopped")


    def _log(self, text: str):
        logging.info(f"[UserWss]{text}")

