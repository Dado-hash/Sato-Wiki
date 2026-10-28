"""The model contract the app implements, shared by export.py and evaluate.py.

Input: one float32 tensor, NHWC [1, 416, 416, 3], channel order BGR, raw 0..255
values (no mean or std). The image is resized keeping its aspect ratio so it
fits 416x416, placed at the top-left corner, and the rest is filled with 114.

Output: one float32 tensor [1, 3549, 11], already decoded (YOLOX export with
--decode_in_inference). Each row is cx, cy, w, h in input pixels (416 space),
objectness (sigmoid applied), then six class probabilities (sigmoid applied).
Score = objectness * max class probability. NMS is done by the app.
"""

from __future__ import annotations

import os

from dataclasses import dataclass
from typing import List, Tuple

import cv2
import numpy as np
from PIL import Image

# 416 is the shipped contract; DICE_INPUT_SIZE (same variable as dice_exp.py) selects
# another square size, for example 640. The app reads the size from the model.
INPUT_SIZE = int(os.environ.get("DICE_INPUT_SIZE", "416"))
PAD_VALUE = 114
NUM_CLASSES = 6
# Anchors at strides 8, 16 and 32: 3549 for 416 (52*52 + 26*26 + 13*13), 8400 for 640.
NUM_ANCHORS = sum((INPUT_SIZE // stride) ** 2 for stride in (8, 16, 32))
OUTPUT_DIM = 5 + NUM_CLASSES
LABELS = ["1", "2", "3", "4", "5", "6"]  # class index 0..5
SCORE_THRESHOLD = 0.3
NMS_IOU = 0.45


class ContractError(RuntimeError):
    """Raised when a model does not match the app contract."""


@dataclass
class Detection:
    """One kept detection, box in original image pixels (x0, y0, x1, y1)."""

    box: np.ndarray
    score: float
    class_index: int


def letterbox(image: Image.Image) -> Tuple[np.ndarray, float]:
    """Returns the float32 HWC BGR input (416x416, raw 0..255) and the scale ratio.

    Mirrors YOLOX's preproc exactly: r = min(416/h, 416/w), cv2.resize to
    int(w*r) x int(h*r) with INTER_LINEAR on a BGR array, top-left placement,
    pad value 114. The app uses the same OpenCV INTER_LINEAR-equivalent filter.
    """
    width, height = image.size
    ratio = min(INPUT_SIZE / height, INPUT_SIZE / width)
    new_w, new_h = int(width * ratio), int(height * ratio)
    rgb = np.asarray(image.convert("RGB"), dtype=np.uint8)
    bgr_src = np.ascontiguousarray(rgb[:, :, ::-1])
    resized = cv2.resize(bgr_src, (new_w, new_h), interpolation=cv2.INTER_LINEAR)
    canvas = np.full((INPUT_SIZE, INPUT_SIZE, 3), PAD_VALUE, dtype=np.uint8)
    canvas[:new_h, :new_w] = resized
    return canvas.astype(np.float32), ratio


def load_interpreter(model_path: str):
    """Loads a TFLite interpreter from ai-edge-litert, or from TensorFlow as a fallback."""
    try:
        from ai_edge_litert.interpreter import Interpreter
    except ImportError:
        try:
            from tensorflow.lite import Interpreter  # type: ignore[no-redef]
        except ImportError as error:
            raise SystemExit(
                "No TFLite interpreter found. Install ai-edge-litert (see requirements.txt)."
            ) from error
    interpreter = Interpreter(model_path=model_path)
    interpreter.allocate_tensors()
    return interpreter


def check_interpreter_io(interpreter) -> None:
    """Fails loudly unless the model has the contract's input and output shapes and dtypes."""
    inputs = interpreter.get_input_details()
    outputs = interpreter.get_output_details()
    if len(inputs) != 1 or len(outputs) != 1:
        raise ContractError(
            f"expected 1 input and 1 output, got {len(inputs)} inputs and {len(outputs)} outputs"
        )
    in_shape = [int(v) for v in inputs[0]["shape"]]
    out_shape = [int(v) for v in outputs[0]["shape"]]
    expected_in = [1, INPUT_SIZE, INPUT_SIZE, 3]
    expected_out = [1, NUM_ANCHORS, OUTPUT_DIM]
    if in_shape != expected_in:
        raise ContractError(f"input shape {in_shape}, contract needs {expected_in} (NHWC)")
    if out_shape != expected_out:
        raise ContractError(f"output shape {out_shape}, contract needs {expected_out}")
    for name, detail in (("input", inputs[0]), ("output", outputs[0])):
        if np.dtype(detail["dtype"]) != np.float32:
            raise ContractError(f"{name} dtype is {np.dtype(detail['dtype'])}, contract needs float32")


def iou_xyxy(box: np.ndarray, boxes: np.ndarray) -> np.ndarray:
    """IoU of one box against an array of boxes, all in x0, y0, x1, y1."""
    x0 = np.maximum(box[0], boxes[:, 0])
    y0 = np.maximum(box[1], boxes[:, 1])
    x1 = np.minimum(box[2], boxes[:, 2])
    y1 = np.minimum(box[3], boxes[:, 3])
    inter = np.clip(x1 - x0, 0, None) * np.clip(y1 - y0, 0, None)
    area = (box[2] - box[0]) * (box[3] - box[1])
    areas = (boxes[:, 2] - boxes[:, 0]) * (boxes[:, 3] - boxes[:, 1])
    return inter / np.maximum(area + areas - inter, 1e-9)


def postprocess(
    raw: np.ndarray,
    ratio: float,
    score_threshold: float = SCORE_THRESHOLD,
    nms_iou: float = NMS_IOU,
) -> List[Detection]:
    """Decodes [3549, 11] rows as the app does: threshold, class-agnostic NMS, map to the original image."""
    cx, cy, w, h = raw[:, 0], raw[:, 1], raw[:, 2], raw[:, 3]
    objectness = raw[:, 4]
    class_probs = raw[:, 5:]
    class_index = class_probs.argmax(axis=1)
    score = objectness * class_probs[np.arange(raw.shape[0]), class_index]
    keep = np.flatnonzero(score >= score_threshold)
    if keep.size == 0:
        return []
    boxes = np.stack(
        [cx - w / 2, cy - h / 2, cx + w / 2, cy + h / 2], axis=1
    )[keep] / ratio
    scores = score[keep]
    classes = class_index[keep]

    order = np.argsort(-scores)
    kept: List[Detection] = []
    while order.size:
        best = order[0]
        kept.append(Detection(boxes[best], float(scores[best]), int(classes[best])))
        if order.size == 1:
            break
        rest = order[1:]
        order = rest[iou_xyxy(boxes[best], boxes[rest]) <= nms_iou]
    return kept
