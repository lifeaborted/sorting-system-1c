import json
import os
import logging

logger = logging.getLogger(__name__)

# Структура конфигурации по умолчанию
DEFAULT_CONFIG = {
    "connection": {
        "host": "localhost",
        "port": 5000
    },
    "neural": {
        "yolo": {
            "model_path": "..runs/detect/train2/weights/best.pt",
            "conf_threshold": 0.25,
            "iou_threshold": 0.45
        },
        "ocr": {
            "lang": "en",
            "use_gpu": False,
            "min_confidence": 0.60,
            "crop_padding_px": 8,
            "use_angle_cls": False
        }
    },
    "output": {
        "save_json": True,
        "output_dir": "results",
        "save_crops": True,
        "crops_dir": "data/crops",
        "log_level": "INFO"
    }
}

def load_or_create_config(path: str) -> dict:
    if not os.path.exists(path):
        logger.warning(f"Файл конфигурации '{path}' не найден. Создание стандартного конфига...")
        try:
            with open(path, "w", encoding="utf-8") as f:
                json.dump(DEFAULT_CONFIG, f, indent=4, ensure_ascii=False)
            logger.info(f"Файл '{path}' успешно создан.")
            return DEFAULT_CONFIG
        except Exception as e:
            logger.error(f"Критическая ошибка при создании конфига: {e}")
            return DEFAULT_CONFIG

    try:
        with open(path, encoding="utf-8") as f:
            config = json.load(f)
            logger.info(f"Конфигурация успешно загружена из '{path}'.")
            return config
    except json.JSONDecodeError:
        logger.error(f"Ошибка синтаксиса JSON в файле '{path}'. Используется конфиг по умолчанию.")
        return DEFAULT_CONFIG
    except Exception as e:
        logger.error(f"Ошибка чтения конфига: {e}. Используется конфиг по умолчанию.")
        return DEFAULT_CONFIG