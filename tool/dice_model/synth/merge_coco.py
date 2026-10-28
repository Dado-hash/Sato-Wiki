"""Merge synthetic scenes from render_dice.py with a real dataset from prepare_dataset.py.

Output, in the layout train.py expects:
    <out>/train2017, <out>/val2017, <out>/test2017
    <out>/annotations/instances_{train,val,test}2017.json

- train: every synthetic image except a held-out slice, plus the real train split
- val:   the synthetic held-out slice, plus the real val split
- test:  the real test split only (synthetic images never measure the release)

Images are hard-linked when source and output are on the same drive, else copied.
File names get a prefix (synth_ / real_) so they never collide. Standard library only.

    python merge_coco.py --synth D:/satowiki-dice/synth_v1 --real D:/satowiki-dice/real \\
        --out D:/satowiki-dice/dataset_v1
"""

from __future__ import annotations

import argparse
import json
import os
import random
import shutil
import sys
from pathlib import Path

SPLITS = ("train2017", "val2017", "test2017")


def place(source: Path, target: Path) -> None:
    if target.exists():
        return
    try:
        os.link(source, target)
    except OSError:
        shutil.copy2(source, target)


class Builder:
    def __init__(self, categories: list):
        self.coco = {"images": [], "annotations": [], "categories": categories}
        self.next_image = 1
        self.next_ann = 1

    def add(self, image: dict, annotations: list, source: Path, out_dir: Path, prefix: str) -> None:
        file_name = prefix + image["file_name"]
        place(source / image["file_name"], out_dir / file_name)
        self.coco["images"].append({**image, "id": self.next_image, "file_name": file_name})
        for ann in annotations:
            self.coco["annotations"].append({**ann, "id": self.next_ann, "image_id": self.next_image})
            self.next_ann += 1
        self.next_image += 1


def by_image(coco: dict) -> dict:
    grouped: dict = {image["id"]: [] for image in coco["images"]}
    for ann in coco["annotations"]:
        grouped[ann["image_id"]].append(ann)
    return grouped


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--synth", type=Path, action="append", default=[],
                        help="render_dice.py output (images/ and annotations.json); repeatable")
    parser.add_argument("--real", type=Path, help="prepare_dataset.py output (COCO layout)")
    parser.add_argument("--out", type=Path, required=True)
    parser.add_argument("--synth-val-fraction", type=float, default=0.05)
    parser.add_argument("--seed", type=int, default=42)
    args = parser.parse_args()

    categories = [{"id": v, "name": str(v), "supercategory": "die"} for v in range(1, 7)]
    builders = {split: Builder(categories) for split in SPLITS}
    for split in SPLITS:
        (args.out / split).mkdir(parents=True, exist_ok=True)
    (args.out / "annotations").mkdir(parents=True, exist_ok=True)
    rng = random.Random(args.seed)

    for synth in args.synth:
        coco = json.loads((synth / "annotations.json").read_text(encoding="utf-8"))
        if [c["id"] for c in coco["categories"]] != [1, 2, 3, 4, 5, 6]:
            raise SystemExit(f"{synth}: unexpected categories {coco['categories']}")
        grouped = by_image(coco)
        images = sorted(coco["images"], key=lambda i: i["file_name"])
        rng.shuffle(images)
        n_val = round(len(images) * args.synth_val_fraction)
        for n, image in enumerate(images):
            split = "val2017" if n < n_val else "train2017"
            builders[split].add(image, grouped[image["id"]], synth / "images", args.out / split, "synth_")

    if args.real:
        for split in SPLITS:
            ann_file = args.real / "annotations" / f"instances_{split}.json"
            if not ann_file.exists():
                continue
            coco = json.loads(ann_file.read_text(encoding="utf-8"))
            names = {c["id"]: c["name"] for c in coco["categories"]}
            if any(names.get(v) != str(v) for v in range(1, 7)):
                raise SystemExit(f"{ann_file}: category ids must map 1..6 to faces '1'..'6'")
            grouped = by_image(coco)
            for image in coco["images"]:
                builders[split].add(image, grouped[image["id"]], args.real / split, args.out / split, "real_")

    for split, builder in builders.items():
        path = args.out / "annotations" / f"instances_{split}.json"
        path.write_text(json.dumps(builder.coco), encoding="utf-8")
        faces = [0] * 6
        for ann in builder.coco["annotations"]:
            faces[ann["category_id"] - 1] += 1
        print(f"{split}: {len(builder.coco['images'])} images, {len(builder.coco['annotations'])} dice, "
              f"faces 1-6: {faces}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
