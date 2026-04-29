"""

"""

import argparse
import json
import logging
import sys
from pathlib import Path
from pipeline import MarkingPipeline, PipelineResult


def load_config(path: str) -> dict:
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def setup_logging(level: str):
    logging.basicConfig(
        level=getattr(logging, level.upper(), logging.INFO),
        format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
        datefmt="%H:%M:%S",
    )


def build_pipeline(cfg: dict) -> MarkingPipeline:
    yolo_path = cfg["yolo"].get("model_path")
    # Если файл не существует — передаём None (загрузит yolov8n.pt автоматически)
    if yolo_path and not Path(yolo_path).exists():
        logging.warning(
            f"Модель не найдена: {yolo_path}. "
            "Будет загружена предобученная yolov8n.pt (замените на дообученную модель)."
        )
        yolo_path = None

    return MarkingPipeline(
        yolo_model_path=yolo_path,
        yolo_conf=cfg["yolo"]["conf_threshold"],
        yolo_iou=cfg["yolo"]["iou_threshold"],
        ocr_lang=cfg["ocr"]["lang"],
        ocr_use_gpu=cfg["ocr"]["use_gpu"],
        min_ocr_conf=cfg["ocr"]["min_confidence"],
        crop_padding=cfg["ocr"]["crop_padding_px"],
        save_crops=cfg["output"]["save_crops"],
        crops_dir=cfg["output"]["crops_dir"],
    )


def handle_result(result: PipelineResult, save: bool, out_dir: Path):
    print(result.to_json())
    if save:
        name = Path(result.source).stem or "result"
        path = out_dir / f"{name}_{result.timestamp.replace(':', '-')}.json"
        path.write_text(result.to_json(), encoding="utf-8")
        logging.info(f"Сохранён: {path}")


def main():
    parser = argparse.ArgumentParser(description="Пайплайн распознавания маркировки")
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--image",  metavar="PATH", help="Путь к одному изображению")
    group.add_argument("--folder", metavar="DIR",  help="Папка с изображениями (jpg/png)")
    group.add_argument("--camera", action="store_true", help="Захват с USB-камеры")
    parser.add_argument("--config", default="config.json", help="Путь к конфигу")
    args = parser.parse_args()

    cfg = load_config(args.config)
    setup_logging(cfg["output"].get("log_level", "INFO"))

    pipeline = build_pipeline(cfg)
    out_dir = Path(cfg["output"]["output_dir"])
    out_dir.mkdir(parents=True, exist_ok=True)
    save_json = cfg["output"]["save_json"]

    if args.image:
        result = pipeline.process_file(args.image)
        handle_result(result, save_json, out_dir)

    elif args.folder:
        folder = Path(args.folder)
        images = sorted(
            list(folder.glob("*.jpg")) +
            list(folder.glob("*.jpeg")) +
            list(folder.glob("*.png"))
        )
        if not images:
            logging.error(f"Изображения не найдены в {folder}")
            sys.exit(1)
        logging.info(f"Найдено {len(images)} изображений в {folder}")
        for img_path in images:
            result = pipeline.process_file(str(img_path))
            handle_result(result, save_json, out_dir)

    elif args.camera:
        pipeline.process_camera(
            camera_index=cfg["camera"]["index"],
            output_dir=cfg["output"]["output_dir"],
            save_json=save_json,
            show_preview=cfg["camera"]["show_preview"],
        )


if __name__ == "__main__":
    main()
