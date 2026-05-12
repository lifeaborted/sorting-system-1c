"""
Запуск сервера нейронки для приема изображения
"""
from logger_config import setup_logger
setup_logger()

from loguru import logger
import main

from pathlib import Path
from fastapi import FastAPI, UploadFile, File, HTTPException, BackgroundTasks
from fastapi.responses import JSONResponse

app = FastAPI(title="Neural Marking Service")

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

    logger.info(f"Запуск HTTP сервера на {host}:{port}")
    uvicorn.run(app, host=host, port=port, access_log=False)