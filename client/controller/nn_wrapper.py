import asyncio
import json
import logging
import os.path
import threading
from asyncio import AbstractEventLoop
from threading import Thread
from typing import TypedDict, Callable

import aiohttp
from aiohttp.web_ws import WebSocketResponse

from controller.api.api import Api
from controller.api.orders import OrdersApi
from controller.api.parts import PartsApi
from subprocess import Popen, PIPE, STDOUT


class NeuralNetworkWrapper:
    _is_stopped: bool = False
    _p: Popen
    _thread: Thread
    def __init__(self, token: str):
        self.start(token)

    def start(self, token: str):
        if self._is_stopped:
            self._log_err(f"Trying to start a stopped NeuralNetwork... ignoring")
            return
        self._thread = threading.Thread(target=self._loop, args=(token,))
        self._thread.start()

    def stop(self):
        self._log("Trying to stop neural network")
        self._is_stopped = True
        if self._p is not None:
            self._p.stdin.write("exit\n")
            self._p.stdin.flush()

    def _loop(self, token: str):
        self._log("Trying to start popen")

        possible_venvs = [
            '../neural/.venv/bin/python3',
            '../neural/venv/bin/python3',
            '../neural/.venv/Scripts/python.exe',
            '../neural/venv/Scripts/python.exe'
        ]
        found = False
        for i in possible_venvs:
            if os.path.exists(i):
                self._p = Popen([i, '../neural/src/main.py', f'TOKEN={token}'], cwd="../neural/", stdout=PIPE, stdin=PIPE, stderr=PIPE, text=True)
                found = True
                break
        if not found:
            self._log_err(f"Failed to run python venv: Couldn't locate path")
            return
        
        status = self._p.wait()
        if status != 0:
            self._log_err(f"Exited with status {status}")
            self._log_err(f"{self._p.stderr.readlines()}")
        self._log("Popen is stopped")


    def _log(self, text: str):
        logging.info(f"[NeuralNetwork]{text}")

    def _log_err(self, text: str):
        logging.error(f"[NeuralNetwork]{text}")


