"""
Запуск сервера нейронки для приема изображения
"""
import os
import sys

os.environ['KMP_DUPLICATE_LIB_OK'] = 'True'

if getattr(sys, 'frozen', False):
    app_dir = os.path.dirname(sys.executable)
    # Добавляем папку _internal в путь
    internal_dir = os.path.join(app_dir, '_internal')

    # Путь для PyTorch
    torch_lib = os.path.join(internal_dir, 'torch', 'lib')
    if os.path.exists(torch_lib):
        os.add_dll_directory(torch_lib)
        os.environ['PATH'] = torch_lib + os.pathsep + os.environ.get('PATH', '')

    # Путь для Paddle
    paddle_lib = os.path.join(internal_dir, 'paddle', 'libs')
    if os.path.exists(paddle_lib):
        os.add_dll_directory(paddle_lib)
        os.environ['PATH'] = paddle_lib + os.pathsep + os.environ.get('PATH', '')

os.environ['KMP_DUPLICATE_LIB_OK'] = 'True'

from logger_config import setup_logger
from loguru import logger
from contextlib import asynccontextmanager

setup_logger()

import main
import api_client
import config_manager
import parser
import pipeline
import recognizers
import detectors
import models


from pathlib import Path
from fastapi import FastAPI, UploadFile, File, HTTPException, BackgroundTasks
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware

@asynccontextmanager
async def lifespan(app: FastAPI):
    yield
    logger.opt(ansi=True).info("<red>Остановка сервера...</red>")

app = FastAPI(title="Neural Marking Service", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.post("/neural/upload/")
async def upload_image(
    background_tasks: BackgroundTasks,
    file: UploadFile = File(...)
):
    """
    Принимает изображение и ставит в очередь.
    """
    logger.debug(f"Запрос получен: {file.filename}")

    contents = await file.read()

    background_tasks.add_task(main.process_image_logic, contents, file.filename)

    return JSONResponse(
        status_code=200,
        content={
            "status": "accepted",
            "message": "Image queued for processing",
            "filename": file.filename
        }
    )

if __name__ == "__main__":
    import uvicorn

    main.initialize()

    cfg_path = Path(__file__).resolve().parent.parent / "data" / "config.json"
    import json
    try:
        with open(cfg_path, "r") as f:
            cfg = json.load(f)
        server_cfg = cfg.get("server", {})
        host = server_cfg.get("host", "0.0.0.0")
        port = server_cfg.get("port", 5001)
    except:
        host, port = "0.0.0.0", 5001

    logger.log("DONE", f"Uvicorn server started on {host}:{port}")

    uvicorn.run(app, host=host, port=port, access_log=False, log_config=None)