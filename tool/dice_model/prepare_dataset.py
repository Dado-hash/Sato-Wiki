"""Convert a dice dataset into the COCO layout that YOLOX's COCODataset reads.

Output layout (under --out):

    <out>/train2017/*.jpg
    <out>/val2017/*.jpg
    <out>/test2017/*.jpg                       (only with --test-source)
    <out>/annotations/instances_train2017.json
    <out>/annotations/instances_val2017.json
    <out>/annotations/instances_test2017.json  (only with --test-source)
    <out>/summary.json

The category ids are 1..6 and the names are "1".."6". YOLOX maps categories to
class indices in sorted id order, so class index 0 is face "1", and so on. This
is the same order as assets/models/dice_detector_labels.txt.

Supported source formats (--format):

    coco  any *.json under the source folder with "images" and "annotations"
          (Roboflow "COCO" export, one json per split folder)
    yolo  images/ and labels/ folders with YOLO .txt labels; class names are
          read from data.yaml next to them
    voc   Annotations/*.xml with the images in JPEGImages/ or images/

Every box must end up labelled with a die face "1".."6". Use --class-map to
rename source labels (for example {"d6-3": "3"}).

The default split is a seeded shuffle of the sorted file list, so the same
inputs and seed always give the same split. --test-source converts a separate
folder (the maintainer's own photos) into test2017 without splitting it.
--extra-dir adds more labelled photos to the training pool. The script refuses
to run if an image file appears in both the training pool and the test set
(checked by SHA-256), because the test set must never be used for training.

Roboflow exports need --group-split. Roboflow writes every source photo several
times (augmented copies) and names them "<source>.rf.<hash>.<ext>". A random
file split would put copies of one photo in train and in test, and the test
score would be inflated. With --group-split the script pools the images of all
input folders, groups them by source photo, and splits the groups into
train/val/test with --ratios (default 0.75 0.10 0.15). Copies of one photo never
cross splits, and the script checks this before writing anything. The
categories of a Roboflow COCO export are "1".."6" (ids 1..6) plus a parent
category with id 0 ("1-2-3-4-5-6"); id 0 and its annotations are dropped.

Only the Python standard library is needed for the COCO path. Pillow is
imported only when a YOLO source has to be decoded to read image sizes.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import random
import shutil
import sys
import xml.etree.ElementTree as ET
from dataclasses import dataclass, field
from pathlib import Path
from typing import Dict, List, Optional, Sequence, Tuple

FACES = ["1", "2", "3", "4", "5", "6"]
IMAGE_SUFFIXES = {".jpg", ".jpeg", ".png", ".bmp"}
DEFAULT_VAL_FRACTION = 0.2
DEFAULT_RATIOS = (0.75, 0.10, 0.15)
# Roboflow's parent category (id 0, named "1-2-3-4-5-6"). Its annotations are dropped.
COCO_PARENT_CATEGORY_ID = 0


@dataclass
class Box:
    label: str
    x: float
    y: float
    w: float
    h: float


@dataclass
class Record:
    key: str  # path relative to its source folder, used for sorting
    file: Path
    width: int
    height: int
    boxes: List[Box] = field(default_factory=list)


def load_coco(root: Path) -> List[Record]:
    records: List[Record] = []
    for json_path in sorted(root.rglob("*.json")):
        data = json.loads(json_path.read_text(encoding="utf-8"))
        if not isinstance(data, dict) or "images" not in data or "annotations" not in data:
            continue
        names = {int(c["id"]): str(c["name"]) for c in data.get("categories", [])}
        by_image: Dict[int, List[Box]] = {}
        for ann in data["annotations"]:
            if int(ann["category_id"]) == COCO_PARENT_CATEGORY_ID:
                continue
            label = names.get(int(ann["category_id"]), str(ann["category_id"]))
            x, y, w, h = (float(v) for v in ann["bbox"])
            by_image.setdefault(int(ann["image_id"]), []).append(Box(label, x, y, w, h))
        for image in data["images"]:
            file = _find_image(json_path.parent, str(image["file_name"]))
            records.append(
                Record(
                    key=_relative(file, root),
                    file=file,
                    width=int(image["width"]),
                    height=int(image["height"]),
                    boxes=by_image.get(int(image["id"]), []),
                )
            )
    return records


def load_yolo(root: Path) -> List[Record]:
    names = _read_yolo_names(root)
    records: List[Record] = []
    for image_path in sorted(p for p in root.rglob("*") if p.suffix.lower() in IMAGE_SUFFIXES):
        if "images" not in image_path.parts:
            continue
        parts = list(image_path.parts)
        index = len(parts) - 1 - parts[::-1].index("images")
        parts[index] = "labels"
        label_path = Path(*parts).with_suffix(".txt")
        width, height = _image_size(image_path)
        boxes: List[Box] = []
        if label_path.exists():
            for line in label_path.read_text(encoding="utf-8").splitlines():
                fields = line.split()
                if len(fields) < 5:
                    continue
                class_index = int(float(fields[0]))
                if class_index >= len(names):
                    raise ValueError(f"{label_path}: class index {class_index} not in data.yaml")
                cx, cy, bw, bh = (float(v) for v in fields[1:5])
                boxes.append(
                    Box(
                        names[class_index],
                        (cx - bw / 2) * width,
                        (cy - bh / 2) * height,
                        bw * width,
                        bh * height,
                    )
                )
        records.append(
            Record(_relative(image_path, root), image_path, width, height, boxes)
        )
    return records


def load_voc(root: Path) -> List[Record]:
    records: List[Record] = []
    for xml_path in sorted(root.rglob("*.xml")):
        tree = ET.parse(xml_path).getroot()
        filename = tree.findtext("filename")
        if not filename:
            continue
        size = tree.find("size")
        width = int(float(size.findtext("width")))
        height = int(float(size.findtext("height")))
        file = _find_image(
            xml_path.parent,
            filename,
            extra_dirs=[xml_path.parent.parent / "JPEGImages", xml_path.parent.parent / "images"],
        )
        boxes: List[Box] = []
        for obj in tree.findall("object"):
            bnd = obj.find("bndbox")
            xmin, ymin = float(bnd.findtext("xmin")), float(bnd.findtext("ymin"))
            xmax, ymax = float(bnd.findtext("xmax")), float(bnd.findtext("ymax"))
            boxes.append(Box(obj.findtext("name"), xmin, ymin, xmax - xmin, ymax - ymin))
        records.append(Record(_relative(file, root), file, width, height, boxes))
    return records


LOADERS = {"coco": load_coco, "yolo": load_yolo, "voc": load_voc}


def load_source(fmt: str, root: Path, class_map: Dict[str, str]) -> List[Record]:
    """Loads one source folder and applies the class map to every box."""
    if not root.is_dir():
        raise SystemExit(f"Source folder not found: {root}")
    records = LOADERS[fmt](root)
    for record in records:
        for box in record.boxes:
            box.label = class_map.get(box.label, box.label)
    return records


def _read_yolo_names(root: Path) -> List[str]:
    """Reads the names list from data.yaml, without a YAML dependency."""
    yaml_path = root / "data.yaml"
    if not yaml_path.exists():
        raise SystemExit(f"{root}: yolo format needs data.yaml with a names list")
    names: List[str] = []
    in_names = False
    for line in yaml_path.read_text(encoding="utf-8").splitlines():
        stripped = line.strip()
        if stripped.startswith("names:"):
            rest = stripped[len("names:"):].strip()
            if rest.startswith("["):
                return [item.strip().strip("'\"") for item in rest.strip("[]").split(",") if item.strip()]
            in_names = True
            continue
        if in_names and stripped.startswith("- "):
            names.append(stripped[2:].strip().strip("'\""))
        elif in_names and stripped and not line.startswith(" "):
            break
    if not names:
        raise SystemExit(f"{yaml_path}: could not read the names list")
    return names


def _find_image(folder: Path, file_name: str, extra_dirs: Optional[List[Path]] = None) -> Path:
    candidates = [folder / file_name, folder / "images" / file_name]
    candidates += [d / file_name for d in (extra_dirs or [])]
    for candidate in candidates:
        if candidate.exists():
            return candidate
    raise SystemExit(f"Image not found for {file_name} near {folder}")


def _relative(path: Path, root: Path) -> str:
    try:
        return path.relative_to(root).as_posix()
    except ValueError:
        return path.name


def _image_size(path: Path) -> Tuple[int, int]:
    """Reads the pixel size of an image. Pillow is imported here, only when needed."""
    try:
        from PIL import Image
    except ImportError as exc:
        raise SystemExit("Reading YOLO image sizes needs Pillow: pip install pillow") from exc
    with Image.open(path) as img:
        return img.size


def source_group(file_name: str) -> str:
    """Returns the source photo of a Roboflow augmented copy.

    "IMG_1_jpg.rf.<hash>.jpg" and "IMG_1_jpg.rf.<other>.jpg" both give "IMG_1_jpg".
    A file without the ".rf." marker is its own group.
    """
    return file_name.split(".rf.", 1)[0] if ".rf." in file_name else file_name


def _sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1 << 20), b""):
            digest.update(chunk)
    return digest.hexdigest()


def clean_record(record: Record, stats: Dict[str, int]) -> Record:
    """Clips boxes to the image and drops empty or unknown-face boxes."""
    kept: List[Box] = []
    for box in record.boxes:
        if box.label not in FACES:
            raise SystemExit(
                f"{record.key}: label '{box.label}' is not a die face 1-6. "
                "Add it to --class-map or fix the source."
            )
        x0, y0 = max(0.0, box.x), max(0.0, box.y)
        x1 = min(float(record.width), box.x + box.w)
        y1 = min(float(record.height), box.y + box.h)
        if x1 - x0 < 2 or y1 - y0 < 2:
            stats["skipped_boxes"] += 1
            continue
        kept.append(Box(box.label, x0, y0, x1 - x0, y1 - y0))
    record.boxes = kept
    return record


def split_records(records: List[Record], val_fraction: float, seed: int) -> Tuple[List[Record], List[Record]]:
    ordered = sorted(records, key=lambda r: r.key)
    random.Random(seed).shuffle(ordered)
    n_val = round(len(ordered) * val_fraction)
    return ordered[n_val:], ordered[:n_val]


def split_by_source_group(
    records: List[Record], ratios: Sequence[float], seed: int
) -> Tuple[List[Record], List[Record], List[Record]]:
    """Splits whole source photos into (train, val, test) with a seeded shuffle.

    Every copy of one source photo lands in the same split, so augmented copies
    cannot leak from training into validation or test.
    """
    groups: Dict[str, List[Record]] = {}
    for record in records:
        groups.setdefault(source_group(record.file.name), []).append(record)
    keys = sorted(groups)
    random.Random(seed).shuffle(keys)

    n_train = round(len(keys) * ratios[0])
    n_val = round(len(keys) * ratios[1])
    key_splits = (keys[:n_train], keys[n_train : n_train + n_val], keys[n_train + n_val :])
    if any(not part for part in key_splits):
        raise SystemExit(f"{len(keys)} source groups are too few for ratios {list(ratios)}.")

    splits = tuple(
        [record for key in part for record in sorted(groups[key], key=lambda r: r.key)]
        for part in key_splits
    )
    check_group_isolation(splits)
    return splits


def check_group_isolation(splits: Sequence[List[Record]]) -> None:
    """Raises if a source group has images in more than one split."""
    owner: Dict[str, int] = {}
    for index, records in enumerate(splits):
        for record in records:
            key = source_group(record.file.name)
            if owner.setdefault(key, index) != index:
                raise RuntimeError(f"Source group {key} is in two splits (leak).")


def check_no_test_overlap(pool: List[Record], test: List[Record]) -> None:
    """Stops the run when a test photo is also in the training pool (same bytes)."""
    pool_hashes = {_sha256(r.file): r.key for r in pool}
    for record in test:
        other = pool_hashes.get(_sha256(record.file))
        if other is not None:
            raise SystemExit(
                f"Test image {record.key} is also in the training pool ({other}). "
                "Remove it from --source or --extra-dir: the test set must never be trained on."
            )


def write_split(records: List[Record], image_dir: Path, annotation_file: Path) -> Dict[str, int]:
    """Copies images to image_dir and writes a COCO annotation file. Returns per-face box counts."""
    image_dir.mkdir(parents=True, exist_ok=True)
    annotation_file.parent.mkdir(parents=True, exist_ok=True)
    images, annotations = [], []
    counts = {face: 0 for face in FACES}
    for image_id, record in enumerate(records, start=1):
        dest_name = f"{image_id:05d}_{record.file.name}"
        shutil.copy2(record.file, image_dir / dest_name)
        images.append(
            {"id": image_id, "file_name": dest_name, "width": record.width, "height": record.height}
        )
        for box in record.boxes:
            counts[box.label] += 1
            annotations.append(
                {
                    "id": len(annotations) + 1,
                    "image_id": image_id,
                    "category_id": int(box.label),
                    "bbox": [round(box.x, 2), round(box.y, 2), round(box.w, 2), round(box.h, 2)],
                    "area": round(box.w * box.h, 2),
                    "iscrowd": 0,
                }
            )
    categories = [{"id": int(face), "name": face, "supercategory": "die"} for face in FACES]
    coco = {"images": images, "annotations": annotations, "categories": categories}
    annotation_file.write_text(json.dumps(coco, indent=2), encoding="utf-8")
    return counts


def parse_args(argv: Optional[List[str]] = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--source", type=Path, required=True, help="Folder with the training/validation dataset.")
    parser.add_argument("--format", choices=sorted(LOADERS), required=True, help="Format of --source.")
    parser.add_argument("--out", type=Path, default=Path("build/dice_model/dataset"), help="Output folder.")
    parser.add_argument(
        "--val-fraction",
        type=float,
        help=f"Random-file split only: share of the pool used for validation (default {DEFAULT_VAL_FRACTION}).",
    )
    parser.add_argument(
        "--group-split",
        action="store_true",
        help="Split by source photo (Roboflow augmented copies stay together) into train/val/test. "
        "Pools all input folders; cannot be combined with --test-source.",
    )
    parser.add_argument(
        "--ratios",
        type=float,
        nargs=3,
        default=list(DEFAULT_RATIOS),
        metavar=("TRAIN", "VAL", "TEST"),
        help="With --group-split: share of source groups per split (must sum to 1).",
    )
    parser.add_argument("--seed", type=int, default=42, help="Seed for the split.")
    parser.add_argument("--class-map", type=Path, help="JSON object mapping source labels to faces 1-6.")
    parser.add_argument("--extra-dir", type=Path, help="Folder of extra labelled photos, added to the training pool.")
    parser.add_argument("--extra-format", choices=sorted(LOADERS), help="Format of --extra-dir (default: --format).")
    parser.add_argument("--test-source", type=Path, help="Folder converted to test2017 without splitting.")
    parser.add_argument("--test-format", choices=sorted(LOADERS), help="Format of --test-source (default: --format).")
    args = parser.parse_args(argv)
    if args.group_split:
        if args.test_source:
            parser.error("--group-split builds its own test split; drop --test-source")
        if args.val_fraction is not None:
            parser.error("--val-fraction does not apply with --group-split; use --ratios")
        if any(r <= 0.0 for r in args.ratios) or abs(sum(args.ratios) - 1.0) > 1e-6:
            parser.error("--ratios must be three positive numbers that sum to 1")
    elif args.val_fraction is None:
        args.val_fraction = DEFAULT_VAL_FRACTION
    elif not 0.0 < args.val_fraction < 1.0:
        parser.error("--val-fraction must be between 0 and 1")
    return args


def main(argv: Optional[List[str]] = None) -> int:
    args = parse_args(argv)
    class_map: Dict[str, str] = {}
    if args.class_map:
        class_map = json.loads(args.class_map.read_text(encoding="utf-8"))

    stats = {"skipped_boxes": 0}
    pool = load_source(args.format, args.source, class_map)
    if args.extra_dir:
        pool += load_source(args.extra_format or args.format, args.extra_dir, class_map)
    pool = [clean_record(r, stats) for r in pool]

    if args.group_split:
        train, val, test = split_by_source_group(pool, args.ratios, args.seed)
        summary = {"seed": args.seed, "split_mode": "source_groups", "ratios": args.ratios, "splits": {}}
        splits = [("train2017", train), ("val2017", val), ("test2017", test)]
    else:
        train, val = split_records(pool, args.val_fraction, args.seed)
        summary = {"seed": args.seed, "split_mode": "random_files", "val_fraction": args.val_fraction, "splits": {}}
        splits = [("train2017", train), ("val2017", val)]
        if args.test_source:
            test = [
                clean_record(r, stats)
                for r in load_source(args.test_format or args.format, args.test_source, class_map)
            ]
            check_no_test_overlap(pool, test)
            splits.append(("test2017", test))

    args.out.mkdir(parents=True, exist_ok=True)
    annotations_dir = args.out / "annotations"
    for name, records in splits:
        counts = write_split(
            records,
            args.out / name,
            annotations_dir / f"instances_{name}.json",
        )
        entry = {"images": len(records), "boxes_per_face": counts}
        if args.group_split:
            entry["source_groups"] = len({source_group(r.file.name) for r in records})
        summary["splits"][name] = entry

    summary["skipped_boxes"] = stats["skipped_boxes"]
    (args.out / "summary.json").write_text(json.dumps(summary, indent=2), encoding="utf-8")
    print(json.dumps(summary, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
