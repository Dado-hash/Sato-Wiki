# Dice detector: model card

> **Beta: below the release gate.** This model finds 98.5% of the dice but reads
> the right face on 77.4% of them (gate: 0.99). It ships for testers only. Every
> throw read by the camera must be checked against the dice. Treat the camera
> mode as a beta until a model passes the gate.

## Purpose

Detects dice in a live camera frame and returns each die's face value (1 to 6)
for the Dice tool's "Dadi → Seed" flow. Runs on device, offline. Labels are the
strings `1` to `6` in `dice_detector_labels.txt`.

## Artifact

| Field | Value |
| --- | --- |
| Architecture | YOLOX-Nano (depth 0.33, width 0.25, depthwise, 6 classes) |
| File | `assets/models/dice_detector.tflite` |
| Labels | `assets/models/dice_detector_labels.txt` (`1`, `2`, `3`, `4`, `5`, `6`; class index 0 to 5) |
| Weights | float32 (float16 and int8 not produced: see `tool/dice_model/README.md`) |
| Size | 3,704,016 bytes (3.5 MiB) |
| SHA-256 | `8de7a1d4579e0b12599ae174f6b53231a44a881aa779e473789c16f35b276249` |

Verify with `shasum -a 256 assets/models/dice_detector.tflite`.

## Model I/O contract

The app implements this contract. `tool/dice_model/dice_contract.py` holds the
reference code, and `export.py` fails if the exported file differs.

| | Input | Output |
| --- | --- | --- |
| Tensor | float32, NHWC `[1, 416, 416, 3]` | float32, `[1, 3549, 11]` |
| Channel order | BGR | per row: `cx, cy, w, h`, objectness, 6 class probabilities |
| Values | raw 0 to 255, no mean or std | `cx, cy, w, h` in input pixels (416 space); objectness and class probabilities with sigmoid applied |
| Preprocessing | letterbox: resize keeping the aspect ratio so the image fits 416 x 416, top-left placement, pad value 114; the resize uses OpenCV `INTER_LINEAR` semantics in the app, the evaluation and the training preprocessing | none (already decoded by YOLOX `--decode_in_inference`) |
| Postprocessing (app) | none | score = objectness x max class probability; keep score >= 0.3; class-agnostic NMS at IoU 0.45 |

The 3549 rows are the anchors at strides 8, 16 and 32 for a 416 input:
52 x 52 + 26 x 26 + 13 x 13.

## Provenance

- **Architecture and tooling:** YOLOX (Megvii, Apache-2.0), YOLOX-Nano
  experiment, COCO-pretrained start (`yolox_nano.pth`, release tag `0.1.1rc0`).
  ONNX export by `export.py`, which repeats YOLOX `tools/export_onnx.py
  --decode_in_inference` in process.
  TFLite conversion with onnx2tf 2.6.9 (MIT).
- **Training data:** D6DiceSideRecognition v2 by dicemaschine (Roboflow Universe,
  https://universe.roboflow.com/dicemaschine/d6dicesiderecognition), exported
  2026-10-27. 600 images: 175 source photos with 3 augmented copies each (train),
  and 75 un-augmented photos (valid 50, test 25). Preprocessing: EXIF orientation
  stripped, stretched to 640 x 640. Augmentation: flips, 90-degree rotations and
  brightness +-20%. Faces 1 to 6, 4153 boxes.
- **Split:** grouped by source photo, so no augmented copy crosses splits. Seed 42,
  75% train, 10% validation, 15% test (188, 25 and 37 source groups). The test
  split is the held-out part of this dataset. No own photos are used yet, so the
  test score is not yet a check on the maintainer's own camera. Details in
  `tool/dice_model/README.md`.
- **Dataset license:** CC BY 4.0 (https://creativecommons.org/licenses/by/4.0/), as
  stated in the export's README. Confirm on the dataset page before release.
- **Dataset attribution:** D6DiceSideRecognition v2 by dicemaschine, Roboflow
  Universe (https://universe.roboflow.com/dicemaschine/d6dicesiderecognition),
  CC BY 4.0. Changes: resized, split by source photo and converted to COCO layout.
- **Own test photos:** none yet. When they exist they are used only for evaluation,
  never for training, and are labelled with a tool such as Label Studio or CVAT (TBD).
- **Code:** `tool/dice_model/` in this repository, MIT.

## License

- Model weights and labels: inherit the dataset license (CC BY 4.0) and are derived
  from YOLOX-Nano (Apache-2.0).
- Scripts: MIT, same as the repository.
- Attribution to show in the app's licence screen: YOLOX (Apache-2.0), and the
  dataset attribution line above (CC BY 4.0).

## Training command

Full steps are in `tool/dice_model/README.md`. The command that produced the
model:

```bash
python tool/dice_model/train_mac.py --device cpu \
  --data-dir build/dice_model/dataset --pretrained build/dice_model/yolox_nano.pth \
  --epochs 70 --batch-size 16 --seed 42
```

70 epochs (the last 15 without mosaic), evaluation on `val2017` every 10 epochs
and at every epoch of the last 15. The checkpoint shipped is `best_ckpt.pth`,
from epoch 59. Training took 2 h 29 min on the CPU of an Apple Silicon Mac
(about 2 minutes per epoch).

Export and evaluation commands: `tool/dice_model/export.py` and
`tool/dice_model/evaluate.py` with their defaults.

Environment: macOS on Apple Silicon, CPU, fp32. Python 3.12, PyTorch 2.5.1,
YOLOX commit 6ddff4824372906469a7fae2dc3206c7aa4bbaee, onnx2tf 2.6.9,
ai-edge-litert 2.1.2 (pins in `tool/dice_model/requirements.txt`).

Tolerance used by `export.py` for the check against ONNX Runtime: 1e-3 relative
(default). Measured difference: 0.00000.

## Metrics

Measured with `tool/dice_model/evaluate.py` on the held-out test set
(`test2017`: 95 images, 37 source photos of the dataset, until own photos are added). Release gate: value accuracy at least 0.99 (value accuracy
is measured on localised dice, IoU at least 0.5, score threshold 0.3, NMS IoU 0.45).

| Metric | Value |
| --- | --- |
| Metric | Value |
| --- | --- |
| Test images | 95 |
| Test boxes (ground truth) | 731 |
| Localised boxes (IoU >= 0.5) | 720 (98.5%) |
| Missed boxes | 11 |
| False positives | 10 |
| Die value accuracy (localised boxes) | **0.7736 (FAIL, gate: >= 0.99)** |
| Model size | 3.5 MiB |
| Speed on a test phone | not measured |

| Face | Precision | Recall | Ground truth | Predicted |
| --- | --- | --- | --- | --- |
| 1 | 0.919 | 0.898 | 127 | 124 |
| 2 | 0.740 | 0.675 | 114 | 104 |
| 3 | 0.705 | 0.812 | 112 | 129 |
| 4 | 0.802 | 0.703 | 138 | 121 |
| 5 | 0.618 | 0.711 | 114 | 131 |
| 6 | 0.802 | 0.770 | 126 | 121 |

Confusion matrix (rows: labelled face, columns: predicted face, localised dice only):

| | 1 | 2 | 3 | 4 | 5 | 6 |
| --- | --- | --- | --- | --- | --- | --- |
| **1** | 114 | 9 | 3 | 0 | 0 | 0 |
| **2** | 5 | 77 | 20 | 4 | 1 | 0 |
| **3** | 3 | 5 | 91 | 4 | 1 | 5 |
| **4** | 0 | 7 | 2 | 97 | 27 | 5 |
| **5** | 1 | 0 | 5 | 14 | 81 | 13 |
| **6** | 0 | 1 | 6 | 2 | 20 | 97 |

Most errors are between faces one pip apart (4 read as 5, 6 as 5, 2 as 3):
the model finds the dice but miscounts the pips. At 416 px input a small die
covers about 30 px, so a pip is 3 to 4 px.

Validation metrics from YOLOX's COCO evaluation on `val2017` (63 images), best
checkpoint (epoch 59): AP50 0.884, AP50:95 0.557. Last epoch (70): AP50 0.866,
AP50:95 0.548.

## Known limitations

- Trained on a public dataset that may not match the table, lighting and dice
  the user uses. The held-out split is from the same dataset, so it does not
  replace a test on the maintainer's own photos.
- Not tested with dice of other colours or sizes unless they are in the training
  data.
- Each detection is a single die. Overlapping dice are a known weak case.
- The app must still handle a low-confidence result by asking for manual entry.

## Change log

- 2026-10-27: first trained model, beta. YOLOX-Nano at 416 px, 70 epochs on CPU.
  Value accuracy 0.7736 on the held-out test split, below the 0.99 gate.
- Earlier: model switched from MediaPipe Model Maker to YOLOX-Nano, with the I/O
  contract above.
