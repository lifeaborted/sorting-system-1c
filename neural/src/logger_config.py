import os
import sys
import warnings
import logging

from loguru import logger

_logger_initialized = False

logger.remove()
logger.add(sys.stderr, level="INFO")


class InterceptHandler(logging.Handler):
    def emit(self, record):
        try:
            level = logger.level(record.levelname).name
        except ValueError:
            level = record.levelno

        frame, depth = logging.currentframe(), 2
        while frame.f_code.co_filename == logging.__file__:
            frame = frame.f_back
            depth += 1

        logger.opt(depth=depth, exception=record.exc_info).log(level, record.getMessage())


def setup_logger():
    global _logger_initialized

    # Если уже инициализировали - выходим
    if _logger_initialized:
        return
    
    # 1. Отключаем C++ логи PaddlePaddle
    os.environ['GLOG_minloglevel'] = '2'

    # 2. Отключаем предупреждения Python
    warnings.filterwarnings("ignore")

    # 3. Перехватываем стандартные логи Python (FastAPI/Uvicorn) и глушим их спам
    logging.getLogger("uvicorn.access").setLevel(logging.WARNING)
    logging.getLogger("uvicorn.error").setLevel(logging.WARNING)

    logging.getLogger("uvicorn").handlers = [InterceptHandler()]
    logging.getLogger("fastapi").handlers = [InterceptHandler()]

    # Новый уровень логирования
    logger.level("DONE", no=25, color="<green>")

    _logger_initialized = True