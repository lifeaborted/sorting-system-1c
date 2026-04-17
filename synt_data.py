import cv2
import os
import numpy as np

# --- НАСТРОЙКИ ---
source_image_path = "part_001.jpg"
output_dir = "synthetic_dataset"
class_name = "marking"
class_id = 0  # ID класса (обычно 0)
num_images_to_generate = 50
# -----------------

# Создаем папки
images_train_dir = os.path.join(output_dir, "images", "train")
labels_train_dir = os.path.join(output_dir, "labels", "train")
os.makedirs(images_train_dir, exist_ok=True)
os.makedirs(labels_train_dir, exist_ok=True)

# 1. Загрузка изображения
img = cv2.imread(source_image_path)
if img is None:
    print(f"Ошибка: Не найдено изображение {source_image_path}")
    exit()

h, w = img.shape[:2]

# 2. Интерактивная разметка (если нет файла .txt)
label_path = source_image_path.replace(".jpg", ".txt")
if not os.path.exists(label_path):
    print("Файл разметки не найден. Запуск ручной разметки...")
    print("1. Обведите текст мышкой.")
    print("2. Нажмите ENTER.")
    print("3. Нажмите 'q' для выхода и сохранения.")

    # Инициализация ROI selector
    roi = cv2.selectROI("Select Text Area", img, fromCenter=False, showCrosshair=True)
    cv2.destroyWindow("Select Text Area")

    x, y, rw, rh = roi
    if rw == 0 or rh == 0:
        print("Ошибка: Вы не выбрали область. Попробуйте снова.")
        exit()

    # Конвертация в формат YOLO (нормализованные координаты)
    x_center = (x + rw / 2) / w
    y_center = (y + rh / 2) / h
    w_norm = rw / w
    h_norm = rh / h

    label_content = f"{class_id} {x_center} {y_center} {w_norm} {h_norm}"

    with open(label_path, "w") as f:
        f.write(label_content)
    print(f"Файл разметки создан: {label_path}")
else:
    print(f"Найден существующий файл разметки: {label_path}")
    with open(label_path, "r") as f:
        label_content = f.read()

# 3. Генерация данных (Аугментация)
print(f"Генерация {num_images_to_generate} изображений...")

for i in range(num_images_to_generate):
    # Копируем изображение
    img_aug = img.copy()

    # --- Применяем эффекты (которые не двигают объект) ---

    # А. Случайная яркость
    factor = np.random.uniform(0.5, 1.5)  # от 50% до 150%
    img_aug = cv2.convertScaleAbs(img_aug, alpha=factor, beta=0)

    # Б. Случайный контраст (через умножение)
    # (уже сделано выше alpha, но можно добавить гамму)

    # В. Гауссов шум
    if np.random.rand() > 0.5:
        noise = np.random.normal(0, 10, img_aug.shape).astype(np.uint8)
        img_aug = cv2.add(img_aug, noise)

    # Г. Размытие (иногда)
    if np.random.rand() > 0.7:
        img_aug = cv2.GaussianBlur(img_aug, (3, 3), 0)

    # Сохраняем изображение
    new_img_name = f"synth_{i}.jpg"
    cv2.imwrite(os.path.join(images_train_dir, new_img_name), img_aug)

    # Сохраняем разметку (она такая же, так как объект не двигался)
    # Координаты YOLO остаются валидными для яркости/шума/размытия
    new_label_name = f"synth_{i}.txt"
    with open(os.path.join(labels_train_dir, new_label_name), "w") as f:
        f.write(label_content)

print("Готово! Датасет создан в папке:", os.path.abspath(output_dir))