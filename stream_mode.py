import time
import logging
import shutil
from pathlib import Path
from pipeline import MarkingPipeline, PipelineResult
import json
import cv2
import sys

# --- НАСТРОЙКИ ---
CONFIG_PATH = "config.json"
INPUT_FOLDER = "input"  # Папка, куда кидать фото
OUTPUT_FOLDER = "output"  # Папка с результатами
PROCESSED_FOLDER = "done"  # Папка с обработанными фото
# -----------------

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")


def load_config(path):
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def main():
    print("Инициализация моделей (это займет несколько секунд)...")
    # Создаем папки
    Path(INPUT_FOLDER).mkdir(exist_ok=True)
    Path(OUTPUT_FOLDER).mkdir(exist_ok=True)
    Path(PROCESSED_FOLDER).mkdir(exist_ok=True)

    # 1. Загрузка конфига и пайплайна (происходит ОДИН РАЗ)
    cfg = load_config(CONFIG_PATH)

    # Настройка параметров инициализации из конфига
    init_args = {
        "yolo_model_path": cfg["yolo"].get("model_path"),
        "yolo_conf": cfg["yolo"]["conf_threshold"],
        "yolo_iou": cfg["yolo"]["iou_threshold"],
        "ocr_lang": cfg["ocr"]["lang"],
        "ocr_use_gpu": cfg["ocr"]["use_gpu"],
        "min_ocr_conf": cfg["ocr"]["min_confidence"],
        "crop_padding": cfg["ocr"]["crop_padding_px"],
        "save_crops": cfg["output"]["save_crops"],
        "crops_dir": cfg["output"]["crops_dir"],
    }


    pipeline = MarkingPipeline(**init_args)
    print("Модели загружены! Начинаю слежение за папкой 'input'...")

    # 2. Бесконечный цикл проверки
    while True:
        try:
            user_input = input("Введите 'exit' для выхода: ")
            if user_input.lower() == 'exit':
                print("Выход из программы.")
                sys.exit()
            # Ищем файлы в папке input
            files = list(Path(INPUT_FOLDER).glob("*.[jJ][pP][gG]")) + \
                    list(Path(INPUT_FOLDER).glob("*.[pP][nN][gG]"))

            if not files:
                time.sleep(0.5)  # Если пусто, спим полсекунды
                continue

            for img_path in files:
                logging.info(f"Обнаружен файл: {img_path.name}")

                # 3. Обработка (работает быстро, т.к. модели в памяти)
                result = pipeline.process_file(str(img_path))

                # 4. Сохранение результата
                out_json = Path(OUTPUT_FOLDER) / f"{img_path.stem}.json"
                out_json.write_text(result.to_json(), encoding="utf-8")
                logging.info(f"Результат сохранен: {out_json.name}")
                print("-" * 30)
                print(result.to_json())
                print("-" * 30)

                # 5. Перемещение исходника, чтобы не обрабатывать повторно
                shutil.move(str(img_path), Path(PROCESSED_FOLDER) / img_path.name)

        except Exception as e:
            logging.error(f"Ошибка: {e}")
            time.sleep(1)


if __name__ == "__main__":
    main()