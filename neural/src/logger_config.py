import os
import warnings
import logging
from loguru import logger


# Создадим перехватчик, который будет ловить логи от Uvicorn
# и направлять их в Loguru (чтобы всё было в едином красивом стиле)
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
    # 1. Отключаем C++ логи PaddlePaddle
    os.environ['GLOG_minloglevel'] = '2'

    # 2. Отключаем предупреждения Python
    warnings.filterwarnings("ignore")

    # 3. Отключаем спам от PaddleX
    try:
        import paddlex
        paddlex.utils.logging.setup_logging('WARNING')
    except ImportError:
        pass

    # 4. Перехватываем стандартные логи Python (FastAPI/Uvicorn) и глушим их спам
    logging.getLogger("uvicorn.access").setLevel(logging.WARNING)
    logging.getLogger("uvicorn.error").setLevel(logging.WARNING)

    # Заменяем стандартный вывод Uvicorn/FastAPI на наш красивый Loguru
    logging.getLogger("uvicorn").handlers = [InterceptHandler()]
    logging.getLogger("fastapi").handlers = [InterceptHandler()]