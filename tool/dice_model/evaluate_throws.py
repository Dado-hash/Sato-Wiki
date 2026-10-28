"""Evaluate the detector on whole throws: photos labelled only with the faces showing.

Labelling boxes is slow; for a throw what matters is whether the app reads the
right values. The truth file maps each photo to the faces up, in any order:

    {"IMG_0001.jpg": [4, 5, 2, 6, 2], ...}

For each photo the predicted values are compared with the truth as multisets:
a die counts as read correctly when its value is matched, and a throw is correct
only when every die is found and read right (what a seed needs).

Frame modes, to see how much the app's framing costs:
    full    the whole photo letterboxed into the model input (what the app does)
    center  a centred square crop of the photo's short side, then the input
--frame-short-side first scales the photo so its short side has that many
pixels, to mimic the camera stream (480 for the app's ResolutionPreset.medium).

    python evaluate_throws.py --model dice_detector.tflite --photos <dir> --truth truth.json
"""

from __future__ import annotations

import argparse
import json
import sys
from collections import Counter
from pathlib import Path

import numpy as np
from PIL import Image, ImageOps

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import dice_contract  # noqa: E402
from dice_contract import load_interpreter, postprocess  # noqa: E402


def frame(image: Image.Image, mode: str, short_side: int) -> Image.Image:
    if short_side:
        scale = short_side / min(image.size)
        image = image.resize((round(image.width * scale), round(image.height * scale)), Image.BILINEAR)
    if mode == "center":
        side = min(image.size)
        left, top = (image.width - side) // 2, (image.height - side) // 2
        image = image.crop((left, top, left + side, top + side))
    return image


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--model", type=Path, required=True)
    parser.add_argument("--photos", type=Path, required=True)
    parser.add_argument("--truth", type=Path, required=True)
    parser.add_argument("--modes", default="full,center")
    parser.add_argument("--frame-short-side", type=int, default=480)
    parser.add_argument("--verbose", action="store_true", help="Print every photo")
    args = parser.parse_args()

    truth = {k: v for k, v in json.loads(args.truth.read_text(encoding="utf-8")).items() if not k.startswith("_")}
    interpreter = load_interpreter(str(args.model))
    size = int(interpreter.get_input_details()[0]["shape"][1])
    dice_contract.INPUT_SIZE = size  # letterbox() reads the module constant
    inp = interpreter.get_input_details()[0]["index"]
    out = interpreter.get_output_details()[0]["index"]
    print(f"model {args.model.name}: input {size}, camera short side {args.frame_short_side or 'native'}")

    for mode in args.modes.split(","):
        found = correct = expected = extra = throws_ok = 0
        for name, values in sorted(truth.items()):
            image = ImageOps.exif_transpose(Image.open(args.photos / name)).convert("RGB")
            tensor, ratio = dice_contract.letterbox(frame(image, mode, args.frame_short_side))
            interpreter.set_tensor(inp, tensor[None])
            interpreter.invoke()
            detections = postprocess(interpreter.get_tensor(out)[0], ratio)
            predicted = Counter(d.class_index + 1 for d in detections)
            wanted = Counter(values)
            hit = sum((predicted & wanted).values())
            expected += len(values)
            found += min(len(detections), len(values))
            correct += hit
            extra += max(0, len(detections) - len(values))
            throws_ok += int(predicted == wanted)
            if args.verbose:
                print(f"  {mode:6} {name}: truth {sorted(values)} read {sorted(predicted.elements())}")
        print(f"{mode:6}: dice read right {correct}/{expected} ({correct / expected:.1%}), "
              f"dice found {found}/{expected}, extra detections {extra}, "
              f"throws fully right {throws_ok}/{len(truth)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
