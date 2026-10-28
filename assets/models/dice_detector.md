# Dice detector: model card

> **Beta: below the release gate.** On the held-out test split of the public
> dataset this model finds 99.7% of the dice and reads the right face on 95.9% of
> them (gate: 0.99). On the maintainer's own dice it reads 78% of the faces right,
> mostly misreading a 2 as a 3. It ships for testers only. Every throw read by the
> camera must be checked against the dice. Treat the camera mode as a beta until a
> model passes the gate.

## Purpose

Detects dice in a live camera frame and returns each die's face value (1 to 6)
for the Dice tool's "Dadi → Seed" flow. Runs on device, offline. Labels are the
strings `1` to `6` in `dice_detector_labels.txt`.

## Artifact

| Field | Value |
| --- | --- |
| Architecture | YOLOX-Nano (depth 0.33, width 0.25, depthwise, 6 classes), 640 px input |
| File | `assets/models/dice_detector.tflite` |
| Labels | `assets/models/dice_detector_labels.txt` (`1`, `2`, `3`, `4`, `5`, `6`; class index 0 to 5) |
| Weights | float32 (float16 and int8 not produced: see `tool/dice_model/README.md`) |
| Size | 3,762,228 bytes (3.6 MiB) |
| SHA-256 | `c6d9f8328a2dcf420277c47b4e87fc606f459a3162f1f5e983a4c4ac5b5db0cb` |

Verify with `shasum -a 256 assets/models/dice_detector.tflite`.

## Model I/O contract

The app implements this contract. `tool/dice_model/dice_contract.py` holds the
reference code, and `export.py` fails if the exported file differs. The app reads
the input size from the model, so a model of another size needs no code change.

| | Input | Output |
| --- | --- | --- |
| Tensor | float32, NHWC `[1, 640, 640, 3]` | float32, `[1, 8400, 11]` |
| Channel order | BGR | per row: `cx, cy, w, h`, objectness, 6 class probabilities |
| Values | raw 0 to 255, no mean or std | `cx, cy, w, h` in input pixels (640 space); objectness and class probabilities with sigmoid applied |
| Preprocessing | letterbox: resize keeping the aspect ratio so the image fits 640 x 640, top-left placement, pad value 114; the resize uses OpenCV `INTER_LINEAR` semantics in the app, the evaluation and the training preprocessing | none (already decoded by YOLOX `--decode_in_inference`) |
| Postprocessing (app) | none | score = objectness x max class probability; keep score >= 0.3; class-agnostic NMS at IoU 0.45 |

The 8400 rows are the anchors at strides 8, 16 and 32 for a 640 input:
80 x 80 + 40 x 40 + 20 x 20.

## Provenance

- **Architecture and tooling:** YOLOX (Megvii, Apache-2.0), YOLOX-Nano
  experiment, COCO-pretrained start (`yolox_nano.pth`, release tag `0.1.1rc0`).
  ONNX export by `export.py`, which repeats YOLOX `tools/export_onnx.py
  --decode_in_inference` in process.
  TFLite conversion with onnx2tf 2.6.9 (MIT).
- **Training data, real:** D6DiceSideRecognition v2 by dicemaschine (Roboflow
  Universe, https://universe.roboflow.com/dicemaschine/d6dicesiderecognition),
  exported 2026-10-27. 600 images: 175 source photos with 3 augmented copies each,
  and 75 un-augmented photos. Preprocessing: EXIF orientation stripped, stretched
  to 640 x 640. Augmentation: flips, 90-degree rotations and brightness +-20%.
  Faces 1 to 6, 4153 boxes.
- **Training data, synthetic:** 4498 scenes rendered with
  `tool/dice_model/synth/render_dice.py` in Blender 4.2.23 LTS (Cycles, GPU), in
  four runs of 1549, 549, 900 and 1500 scenes. The last run added the dice style
  of the maintainer's own dice (white body, red 1 and 4 with a larger 1, blue or
  black pips on the other faces). Floors and lighting come from 137 textures and
  85 HDRIs from Poly Haven (CC0, https://polyhaven.com/license), fetched with
  `synth/fetch_polyhaven.py`. Each scene has 0 to 6 dice of a random style and
  sometimes distractors (coins, buttons, blank cubes). Labels are exact: the face
  up is set in the scene and the box is the projection of the die mesh.
- **Split:** the real dataset is grouped by source photo, so no augmented copy
  crosses splits (seed 42, 75% train, 10% validation, 15% test: 188, 25 and 37
  source groups). 5% of the synthetic scenes go to validation, the rest to
  training. The test split has real photos only. `synth/merge_coco.py` builds the
  final layout:

  | Split | Images | Dice |
  | --- | --- | --- |
  | train2017 | 4716 (4274 synthetic, 442 real) | 16,415 |
  | val2017 | 287 (224 synthetic, 63 real) | 1029 |
  | test2017 | 95 (real) | 731 |

- **Dataset license:** CC BY 4.0 (https://creativecommons.org/licenses/by/4.0/), as
  stated in the export's README. Confirm on the dataset page before release.
- **Dataset attribution:** D6DiceSideRecognition v2 by dicemaschine, Roboflow
  Universe (https://universe.roboflow.com/dicemaschine/d6dicesiderecognition),
  CC BY 4.0. Changes: resized, split by source photo and converted to COCO layout.
- **Own photos:** 17 photos of throws of 5 dice, taken by the maintainer with a
  phone on a few home surfaces, with two sets of dice (85 dice). Labelled with the faces up
  only, no boxes, and used only for evaluation (`evaluate_throws.py`), never for
  training. They are not in the repository.
- **Code:** `tool/dice_model/` in this repository, MIT.

## License

- Model weights and labels: inherit the dataset license (CC BY 4.0) and are derived
  from YOLOX-Nano (Apache-2.0). The Poly Haven assets used in the synthetic scenes
  are CC0 and need no attribution.
- Scripts: MIT, same as the repository.
- Attribution to show in the app's licence screen: YOLOX (Apache-2.0), and the
  dataset attribution line above (CC BY 4.0).

## Training command

Full steps are in `tool/dice_model/README.md`. The command that produced the
model:

```bash
python tool/dice_model/train.py --yolox-dir YOLOX \
  --data-dir dataset_v1 --pretrained yolox_nano.pth \
  --epochs 80 --batch-size 16 --input-size 640 --mosaic-scale 0.7,1.6 --fp16
```

80 epochs (the last 15 without mosaic), multi-scale training from 480 to 800 px,
evaluation on `val2017` every 10 epochs and at every epoch of the last 15. The
checkpoint shipped is `best_ckpt.pth`, from epoch 80. Training took 1 h 39 min on
an NVIDIA RTX 4060 (8 GB).

A 416 px model was trained the same way on the same data for comparison (value
accuracy 0.867 on the test split, 60 of 85 own dice). The 640 model is better on
both sets, so it ships.

Export: `DICE_INPUT_SIZE=640 python tool/dice_model/export.py`. Evaluation:
`evaluate.py` on `test2017` and `evaluate_throws.py` on the own photos, with
`DICE_INPUT_SIZE=640` for `evaluate.py`.

Environment: training on Windows 11, Python 3.12.16, PyTorch 2.5.1 with CUDA
12.4, YOLOX commit 6ddff4824372906469a7fae2dc3206c7aa4bbaee. Export and
evaluation on macOS on Apple Silicon, onnx2tf 2.6.9, ai-edge-litert 2.1.2 (pins
in `tool/dice_model/requirements.txt`).

Tolerance used by `export.py` for the check against ONNX Runtime: 1e-3 relative
(default). Measured difference: 0.00000.

## Metrics

### Held-out test split of the public dataset

Measured with `tool/dice_model/evaluate.py` on `test2017` (95 images, 37 source
photos of the dataset). Release gate: value accuracy at least 0.99 (value
accuracy is measured on localised dice, IoU at least 0.5, score threshold 0.3,
NMS IoU 0.45).

| Metric | Value |
| --- | --- |
| Test images | 95 |
| Test boxes (ground truth) | 731 |
| Localised boxes (IoU >= 0.5) | 729 (99.7%) |
| Missed boxes | 2 |
| False positives | 3 |
| Die value accuracy (localised boxes) | **0.9588 (FAIL, gate: >= 0.99)** |
| Model size | 3.6 MiB |
| Speed on a test phone | not measured |

| Face | Precision | Recall | Ground truth | Predicted |
| --- | --- | --- | --- | --- |
| 1 | 0.977 | 0.992 | 127 | 129 |
| 2 | 0.973 | 0.965 | 114 | 113 |
| 3 | 0.939 | 0.955 | 112 | 114 |
| 4 | 1.000 | 0.913 | 138 | 126 |
| 5 | 0.909 | 0.965 | 114 | 121 |
| 6 | 0.930 | 0.952 | 126 | 129 |

Confusion matrix (rows: labelled face, columns: predicted face, localised dice only):

| | 1 | 2 | 3 | 4 | 5 | 6 |
| --- | --- | --- | --- | --- | --- | --- |
| **1** | 126 | 0 | 1 | 0 | 0 | 0 |
| **2** | 0 | 110 | 4 | 0 | 0 | 0 |
| **3** | 1 | 0 | 107 | 0 | 2 | 2 |
| **4** | 2 | 2 | 0 | 126 | 5 | 3 |
| **5** | 0 | 1 | 2 | 0 | 110 | 1 |
| **6** | 0 | 0 | 0 | 0 | 4 | 120 |

### Own photos

Measured with `tool/dice_model/evaluate_throws.py`: each photo is scaled so its
short side is 480 px (the app's camera stream) and given whole to the model, as
the app does. A throw counts as right only when every die is found and read
right.

| Metric | Value |
| --- | --- |
| Photos (throws) | 17 |
| Dice | 85 |
| Dice found | 85 |
| Dice read right | 66 (77.6%) |
| Extra detections | 1 |
| Throws fully right | 5 of 17 |

Most errors are a 2 read as a 3, and some 6 read as 5. On the public test split
the 2 is read right 96.5% of the time, so the gap is in the look of these
particular dice, which the synthetic scenes do not match yet. The next step is
fine-tuning on labelled photos of the maintainer's dice.

For comparison, the previous model (trained on the public dataset only, 416 px)
read 62 of 85 own dice right with a centred square crop, with 10 extra
detections and 1 throw fully right.

Validation metrics from YOLOX's COCO evaluation on `val2017` (287 images, mostly
synthetic), best checkpoint (epoch 80): AP50 0.994, AP50:95 0.842.

## Known limitations

- The value accuracy on the maintainer's own dice (78%) is far below the gate.
  The model finds the dice reliably but misreads some faces, the 2 above all.
- The held-out split is from the public dataset, so it does not replace a test on
  the maintainer's own photos.
- Not tested with dice of other colours or sizes unless they are in the training
  data.
- Each detection is a single die. Overlapping dice are a known weak case.
- 640 px input costs about 2.4 times the compute of 416 px. Speed on a phone is
  not measured yet.
- The app must still handle a low-confidence result by asking for manual entry.

## Change log

- 2026-10-28: second model, beta. YOLOX-Nano at 640 px, 80 epochs on a GPU, on
  the public dataset plus 4498 synthetic scenes. Value accuracy 0.9588 on the
  held-out test split, 0.776 on the maintainer's own dice. Fixes the false
  detections on wood and fabric of the first model.
- 2026-10-27: first trained model, beta. YOLOX-Nano at 416 px, 70 epochs on CPU.
  Value accuracy 0.7736 on the held-out test split, below the 0.99 gate.
- Earlier: model switched from MediaPipe Model Maker to YOLOX-Nano, with the I/O
  contract above.
