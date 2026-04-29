"""
Тест моделей из папки runs/detect на 1 из изображений
"""

import os
import glob
from pathlib import Path
from ultralytics import YOLO

# --- НАСТРОЙКИ ---
source_image = "extensions/part_001.jpg"  # Картинка для теста из папки 'extensions'
runs_folder = "runs/detect"  # Папка, где лежат результаты обучений
output_folder = "extensions/model_comparison"  # Куда сохранять результаты


# -----------------

def main():
    # Создаем папку для результатов
    Path(output_folder).mkdir(parents=True, exist_ok=True)

    # Проверяем наличие картинки
    if not os.path.exists(source_image):
        print(f"Ошибка: Файл {source_image} не найден!")
        return

    # Ищем все папки train, train2, train3 и т.д.
    # Путь к весам обычно: runs/detect/train(N)/weights/best.pt
    search_path = os.path.join(runs_folder, "train*", "weights", "best.pt")
    model_paths = sorted(glob.glob(search_path))

    if not model_paths:
        print("Не найдено обученных моделей (best.pt) в папке runs/detect.")
        return

    print(f"Найдено {len(model_paths)} моделей. Начинаю тестирование...")

    for model_path in model_paths:
        # Получаем имя папки обучения (например, train9)
        # путь: runs/detect/train9/weights/best.pt -> берем 'train9'
        run_name = Path(model_path).parent.parent.name
        save_name = f"{run_name}.jpg"
        save_path = os.path.join(output_folder, save_name)

        print(f"--> Тестирую модель: {run_name}...")

        try:
            # Загружаем модель
            model = YOLO(model_path)

            # Запускаем предикт
            # save=False, потому что мы сохраним руками с нужным именем
            # conf=0.25 - порог уверенности (можно менять)
            results = model.predict(source=source_image, save=False, conf=0.25, verbose=False)

            # Берем первый результат (так как картинка одна)
            res = results[0]

            # Сохраняем картинку с отрисованными рамками
            res.save(save_path)

            # Выводим информацию в консоль
            if res.boxes:
                for box in res.boxes:
                    cls_id = int(box.cls[0])
                    cls_name = res.names[cls_id]
                    conf = float(box.conf[0])
                    print(f"    Найдено: {cls_name}, уверенность: {conf:.2f}")
            else:
                print("    Ничего не найдено.")

        except Exception as e:
            print(f"    Ошибка при обработке модели {run_name}: {e}")

    print(f"\nГотово! Все результаты сохранены в папке: {output_folder}")


if __name__ == "__main__":
    main()