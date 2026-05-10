import logging
from pathlib import Path
from contextlib import asynccontextmanager
from fastapi import FastAPI, UploadFile, File, HTTPException, BackgroundTasks
from fastapi.responses import JSONResponse

import main

logger = logging.getLogger(__name__)

@asynccontextmanager
async def lifespan(app: FastAPI):
    main.initialize()
    yield

app = FastAPI(title="Neural Marking Service", lifespan=lifespan)

@app.post("/neural/upload/")
async def upload_image(
    background_tasks: BackgroundTasks,
    file: UploadFile = File(...)
):
    """
    Принимает изображение и ставит в очередь.
    """
    logger.info(f"Запрос получен: {file.filename}")

    contents = await file.read()

    background_tasks.add_task(main.process_image_logic, contents, file.filename)

    return JSONResponse(
        status_code=202,
        content={
            "status": "accepted",
            "message": "Image queued for processing",
            "filename": file.filename
        }
    )

if __name__ == "__main__":
    import uvicorn

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

    logger.info(f"Запуск HTTP сервера на {host}:{port}")
    uvicorn.run(app, host=host, port=port)