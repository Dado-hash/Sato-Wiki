"""Evaluate dice_detector.tflite on a COCO test split with the app's pre- and post-processing.

The input is letterboxed and the output decoded exactly as the app does it
(dice_contract.py): BGR, raw 0..255, 416x416 top-left with pad 114; score =
objectness * max class probability, kept at or above --score-threshold, then
class-agnostic NMS at --nms-iou, boxes mapped back to the original image.

Matching: each kept detection, in score order, is matched to the unmatched
ground-truth box with the highest IoU, if that IoU is at least --match-iou. A
detection that matches is a localised die. Value accuracy is the share of
localised dice whose predicted face equals the labelled face. Recall, precision
and misses are reported separately.

Exit codes: 0 when value accuracy is at least --min-value-accuracy, 1 when it
is below that or nothing matched, 2 when the model does not match the contract.

Example:
    python tool/dice_model/evaluate.py \\
      --model build/dice_model/export/dice_detector.tflite \\
      --labels build/dice_model/export/dice_detector_labels.txt \\
      --data-dir build/dice_model/dataset --split test2017
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Dict, List, Optional, Tuple

import numpy as np
from PIL import Image

from dice_contract import (
    ContractError,
    Detection,
    NMS_IOU,
    SCORE_THRESHOLD,
    check_interpreter_io,
    iou_xyxy,
    letterbox,
    load_interpreter,
    postprocess,
)


def parse_args(argv: Optional[List[str]] = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--model", type=Path, required=True, help="dice_detector.tflite")
    parser.add_argument("--labels", type=Path, required=True, help="dice_detector_labels.txt")
    parser.add_argument("--data-dir", type=Path, default=Path("build/dice_model/dataset"),
                        help="COCO-layout folder with <split>/ and annotations/instances_<split>.json")
    parser.add_argument("--split", default="test2017", help="Split folder name (default: test2017)")
    parser.add_argument("--score-threshold", type=float, default=SCORE_THRESHOLD)
    parser.add_argument("--nms-iou", type=float, default=NMS_IOU)
    parser.add_argument("--match-iou", type=float, default=0.5)
    parser.add_argument("--min-value-accuracy", type=float, default=0.99)
    parser.add_argument("--json-out", type=Path, help="Write the metrics as JSON to this path.")
    return parser.parse_args(argv)


def load_labels(path: Path) -> List[str]:
    labels = [line.strip() for line in path.read_text(encoding="utf-8").splitlines() if line.strip()]
    if labels != ["1", "2", "3", "4", "5", "6"]:
        raise ContractError(f"{path}: labels must be 1..6 in order, got {labels}")
    return labels


def load_ground_truth(annotations: Path, images_dir: Path) -> Dict[str, List[Tuple[str, np.ndarray]]]:
    """Returns {file_name: [(face label, [x0, y0, x1, y1]), ...]} from a COCO file."""
    data = json.loads(annotations.read_text(encoding="utf-8"))
    names = {int(c["id"]): str(c["name"]) for c in data["categories"]}
    by_id = {int(img["id"]): str(img["file_name"]) for img in data["images"]}
    truth: Dict[str, List[Tuple[str, np.ndarray]]] = {name: [] for name in by_id.values()}
    for ann in data["annotations"]:
        x, y, w, h = (float(v) for v in ann["bbox"])
        file_name = by_id[int(ann["image_id"])]
        truth[file_name].append((names[int(ann["category_id"])], np.array([x, y, x + w, y + h])))
    missing = [f for f in truth if not (images_dir / f).exists()]
    if missing:
        raise SystemExit(f"{len(missing)} images listed in {annotations} are missing from {images_dir}, e.g. {missing[0]}")
    return truth


def match_image(
    detections: List[Detection],
    truth: List[Tuple[str, np.ndarray]],
    labels: List[str],
    match_iou: float,
) -> Tuple[List[Tuple[str, str]], int]:
    """Returns (gt_label, predicted_label) for each localised die, and the number of false positives."""
    used = np.zeros(len(truth), dtype=bool)
    pairs: List[Tuple[str, str]] = []
    false_positives = 0
    gt_boxes = np.stack([box for _, box in truth]) if truth else np.zeros((0, 4))
    for det in detections:  # already sorted by score, highest first
        if gt_boxes.shape[0] == 0:
            false_positives += 1
            continue
        ious = iou_xyxy(det.box, gt_boxes)
        ious[used] = -1.0
        best = int(np.argmax(ious))
        if ious[best] >= match_iou:
            used[best] = True
            pairs.append((truth[best][0], labels[det.class_index]))
        else:
            false_positives += 1
    return pairs, false_positives


def evaluate(args: argparse.Namespace) -> Tuple[dict, bool]:
    labels = load_labels(args.labels)
    interpreter = load_interpreter(str(args.model))
    check_interpreter_io(interpreter)
    input_index = interpreter.get_input_details()[0]["index"]
    output_index = interpreter.get_output_details()[0]["index"]

    split_dir = args.data_dir / args.split
    annotations = args.data_dir / "annotations" / f"instances_{args.split}.json"
    if not annotations.exists():
        raise SystemExit(f"{annotations} not found; run prepare_dataset.py with --test-source first")
    truth_by_file = load_ground_truth(annotations, split_dir)

    gt_count = {label: 0 for label in labels}
    pred_count = {label: 0 for label in labels}
    tp = {label: 0 for label in labels}
    confusion = {g: {p: 0 for p in labels} for g in labels}
    matched = correct = false_positives = missed = 0

    for file_name in sorted(truth_by_file):
        truth = truth_by_file[file_name]
        for gt_label, _ in truth:
            gt_count[gt_label] += 1
        image = Image.open(split_dir / file_name)
        batch_input, ratio = letterbox(image)
        interpreter.set_tensor(input_index, batch_input[None])
        interpreter.invoke()
        raw = interpreter.get_tensor(output_index)[0]
        detections = postprocess(raw, ratio, args.score_threshold, args.nms_iou)
        for det in detections:
            pred_count[labels[det.class_index]] += 1
        pairs, fp = match_image(detections, truth, labels, args.match_iou)
        false_positives += fp
        missed += len(truth) - len(pairs)
        for gt_label, pred_label in pairs:
            matched += 1
            confusion[gt_label][pred_label] += 1
            if gt_label == pred_label:
                correct += 1
                tp[gt_label] += 1

    value_accuracy = correct / matched if matched else 0.0
    per_class = {
        label: {
            "precision": tp[label] / pred_count[label] if pred_count[label] else 0.0,
            "recall": tp[label] / gt_count[label] if gt_count[label] else 0.0,
            "ground_truth": gt_count[label],
            "predicted": pred_count[label],
        }
        for label in labels
    }
    passed = matched > 0 and value_accuracy >= args.min_value_accuracy
    report = {
        "images": len(truth_by_file),
        "ground_truth_boxes": sum(gt_count.values()),
        "localised_boxes": matched,
        "missed_boxes": missed,
        "false_positives": false_positives,
        "value_accuracy": value_accuracy,
        "min_value_accuracy": args.min_value_accuracy,
        "per_class": per_class,
        "confusion_matrix": confusion,
        "score_threshold": args.score_threshold,
        "nms_iou": args.nms_iou,
        "match_iou": args.match_iou,
        "passed": passed,
    }
    return report, passed


def print_report(report: dict, labels: List[str]) -> None:
    print(f"Images: {report['images']}")
    print(f"Ground-truth dice: {report['ground_truth_boxes']}")
    print(f"Localised (IoU >= {report['match_iou']}): {report['localised_boxes']}")
    print(f"Missed: {report['missed_boxes']}   False positives: {report['false_positives']}")
    print(f"Value accuracy (localised dice): {report['value_accuracy']:.4f} "
          f"(gate >= {report['min_value_accuracy']})")
    print()
    print(f"{'face':>4} {'precision':>10} {'recall':>8} {'GT':>5} {'pred':>5}")
    for label in labels:
        row = report["per_class"][label]
        print(f"{label:>4} {row['precision']:>10.3f} {row['recall']:>8.3f} {row['ground_truth']:>5} {row['predicted']:>5}")
    print()
    print("Confusion matrix (rows: labelled face, columns: predicted face, localised dice only)")
    print("      " + " ".join(f"{p:>5}" for p in labels))
    for g in labels:
        print(f"{g:>5} " + " ".join(f"{report['confusion_matrix'][g][p]:>5}" for p in labels))
    print()
    print("PASS" if report["passed"] else "FAIL")


def main(argv: Optional[List[str]] = None) -> int:
    args = parse_args(argv)
    try:
        report, passed = evaluate(args)
    except ContractError as error:
        print(f"Contract check failed: {error}", file=sys.stderr)
        return 2
    print_report(report, load_labels(args.labels))
    if args.json_out:
        args.json_out.parent.mkdir(parents=True, exist_ok=True)
        args.json_out.write_text(json.dumps(report, indent=2), encoding="utf-8")
    return 0 if passed else 1


if __name__ == "__main__":
    sys.exit(main())
