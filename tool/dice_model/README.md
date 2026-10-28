# Dice detector: training pipeline

This folder reproduces `assets/models/dice_detector.tflite`, the model the Dice
tool uses to read die faces from the camera. The detector is **YOLOX-Nano**
(Megvii, Apache-2.0), trained on a public dice dataset (D6DiceSideRecognition v2,
CC BY 4.0) plus synthetic scenes rendered in Blender (`synth/`), and checked on a
held-out split of the public dataset and on the maintainer's own photos.

Status: **beta model, below the release gate.** The second model (2026-10-28,
640 px, 80 epochs on an RTX 4060) reads the right face on 95.9% of the dice of
the held-out test split (gate: 0.99) and on 77.6% of the maintainer's own dice.
Metrics, SHA-256 and the confusion matrix are in `assets/models/dice_detector.md`.

## Why YOLOX-Nano

- **License:** Apache-2.0 for the code (`LICENSE` in the YOLOX repository,
  "Copyright (c) 2021-2022 Megvii Inc."). The weights and the dataset license are
  separate and are recorded in the model card.
- **Size and speed:** YOLOX-Nano is the smallest YOLOX variant (`depth 0.33`,
  `width 0.25`, depthwise convolutions) and is built for 416 px input. The
  shipped model uses 640 px, which reads small dice better (see below). The
  file is 3.6 MiB; on-device speed is not measured yet and goes in the model card.
- **Export without a post-process graph:** `export.py` repeats the steps of YOLOX `tools/export_onnx.py --decode_in_inference` in process (that script calls `torch.onnx._export`, which torch 2.5 removed) and
  writes the decoded boxes and probabilities, so the app does one NMS in Dart.
- **Why not MediaPipe Model Maker:** the earlier plan used Model Maker. It is no
  longer actively maintained, it has no EfficientDet-Lite0 option in the installed
  release, and its export has no NMS step, so the app contract could not be met.

## Model contract (what the app implements)

| | |
| --- | --- |
| File | `assets/models/dice_detector.tflite` (float32, about 3.5 MB; onnx2tf's float16 file uses float16 activations, which the TFLite CPU kernels reject; int8 is not implemented) |
| Labels | `assets/models/dice_detector_labels.txt`: `1` to `6`, one per line, class index 0 to 5 |
| Input | one float32 tensor, NHWC `[1, S, S, 3]`; S is 640 for the shipped model (`DICE_INPUT_SIZE`, default 416) |
| Channel order | **BGR** |
| Values | raw 0 to 255, no mean or std |
| Letterbox | resize keeping the aspect ratio so the image fits S x S (`r = min(S/h, S/w)`, size `int(w*r) x int(h*r)`), placed at the top-left, pad value **114**; the resize is bilinear with OpenCV `INTER_LINEAR` semantics in the app, the evaluation and the training preprocessing |
| Output | one float32 tensor `[1, N, 11]`, already decoded (`--decode_in_inference`); N is the anchor count at strides 8, 16 and 32: 8400 at 640, 3549 at 416 |
| Output row | `cx, cy, w, h` in input pixels (S space), then objectness (sigmoid applied), then 6 class probabilities (sigmoid applied) |
| Score | objectness x max class probability |
| NMS | done in the app (`evaluate.py` uses score 0.3 and class-agnostic IoU 0.45) |

`dice_contract.py` holds these constants and the reference letterbox,
decoding and NMS. `export.py` and `evaluate.py` use it, so the export is checked
against the same numbers the app uses. The input size comes from the
environment variable `DICE_INPUT_SIZE` (default 416): set it to the size of the
model for `export.py` and `evaluate.py`. `train.py --input-size` sets it for
training. The app reads the size from the model file, so changing it needs no
Dart change.

The export checks the final `.tflite` with the TFLite interpreter. The shapes,
dtypes and the numeric result must match ONNX Runtime, or the export stops. If
onnx2tf changes tensor layout or names, the export fails and nothing is copied.

## Contents

| File | Purpose |
| --- | --- |
| `prepare_dataset.py` | Converts a COCO, YOLO or Pascal VOC source to the COCO layout YOLOX reads (`train2017/`, `val2017/`, `test2017/`, `annotations/`). `--group-split` splits Roboflow exports by source photo (train/val/test), so augmented copies never cross splits. Refuses to run if a test photo is also in the training pool. |
| `dice_exp.py` | YOLOX experiment: 6 classes, YOLOX-Nano scale, 416 px by default, augmentation for dice. Reads paths and settings from environment variables set by `train.py`. |
| `train.py` | Thin wrapper around `python -m yolox.tools.train -f dice_exp.py`. `--input-size` and `--mosaic-scale` change the input size and the mosaic scale range. |
| `export.py` | YOLOX ONNX export with `--decode_in_inference`, onnx2tf to float32 TFLite, contract and numeric checks, copies the model and labels to `build/dice_model/export/`. Prints the SHA-256. |
| `evaluate.py` | Runs the `.tflite` on the test split with the app's exact pre- and post-processing. Per-class precision and recall, value accuracy, confusion matrix. Exit 1 if value accuracy is below 0.99. |
| `evaluate_throws.py` | Runs the `.tflite` on own photos labelled only with the faces up (no boxes) and counts dice read right and throws fully right. |
| `dice_contract.py` | Shared contract: constants, letterbox, decoding, NMS, interpreter shape check. |
| `synth/fetch_polyhaven.py` | Downloads CC0 floor textures and HDRIs from Poly Haven for the synthetic scenes. |
| `synth/render_dice.py` | Blender script: renders dice scenes with exact labels in COCO layout. |
| `synth/merge_coco.py` | Merges synthetic scenes with the real dataset into the layout `train.py` reads. The test split stays real only. |
| `requirements.txt` | Pinned Python dependencies (Python 3.12). |

Outputs go to `build/dice_model/` at the repository root, which is git-ignored
by the Flutter template (`/build`).

## Dataset provenance and license

The detector is trained on one public dataset. Its facts are below. The license
line was read from the dataset's own export README (`README.dataset.txt`, "License:
CC BY 4.0"); confirm it on the dataset page before the model ships.

| Field | Value |
| --- | --- |
| Dataset name | D6DiceSideRecognition, version v2 (Roboflow Universe, created 2024-12-07) |
| Author | dicemaschine (Roboflow user) |
| Dataset URL | https://universe.roboflow.com/dicemaschine/d6dicesiderecognition |
| License | CC BY 4.0 (https://creativecommons.org/licenses/by/4.0/) |
| Attribution line | D6DiceSideRecognition v2 by dicemaschine, Roboflow Universe (https://universe.roboflow.com/dicemaschine/d6dicesiderecognition), CC BY 4.0. Changes: resized, split by source photo and converted to COCO layout. |
| Export | Roboflow COCO export, 2026-10-27 |
| Preprocessing (Roboflow) | Auto-orientation with EXIF stripping; resize to 640 x 640 (stretch) |
| Augmentation (Roboflow, train only) | Each source photo has 3 augmented copies: 50% horizontal flip, 50% vertical flip, equal chance of no rotation, 90 degrees clockwise, 90 degrees counter-clockwise or 180 degrees, brightness -20% to +20% |
| Images | 600 in the export: 525 train (175 source photos x 3 copies), 50 valid and 25 test (one un-augmented image per source photo, 75 photos) |
| Boxes | 4153 in total: face 1: 693, 2: 732, 3: 706, 4: 680, 5: 712, 6: 630 |
| Classes | Faces "1" to "6" (ids 1 to 6). The parent category "1-2-3-4-5-6" (id 0) has no annotations and is dropped |
| Format used | COCO JSON, converted by `prepare_dataset.py --group-split` |
| Verified by | TBD (maintainer) |

Use only datasets with CC0, public-domain or CC BY 4.0 terms. Do not use NC, ND,
AGPL or unstated licenses: the model ships inside an MIT app. CC BY 4.0 requires
attribution in the model card and in the app's licence screen.

### Leak-free split

Roboflow writes each augmented copy as `<source>.rf.<hash>.jpg`, so the source
photo is the part before `.rf.`. `prepare_dataset.py --group-split` pools the
600 images of all three exported folders, groups them by source photo, and
splits the 250 groups with a seeded shuffle (seed 42) into 75% train, 10%
validation and 15% test. All copies of one photo are in one split. The script
checks this and stops if a group is in two splits.

| Split | Source groups | Images | Boxes (faces 1 to 6) |
| --- | --- | --- | --- |
| train2017 | 188 | 442 | 515, 562, 524, 473, 557, 469 (total 3100) |
| val2017 | 25 | 63 | 51, 56, 70, 69, 41, 35 (total 322) |
| test2017 | 37 | 95 | 127, 114, 112, 138, 114, 126 (total 731) |

Images per split differ from the group ratio because the 75 un-augmented
photos count as one image each and the augmented photos count as three.

### Test set policy

- The test split is the held-out 15% of source photos of this dataset (37
  groups, 95 images, 731 boxes). It is evaluated only, and its photos are never
  used for training.
- **Own photos.** 17 photos of the maintainer's throws (85 dice) are labelled
  with the faces up only and measured with `evaluate_throws.py` (see "Own
  photos"). They are not in the repository and never used for training.
- Own photos labelled with boxes (Label Studio or CVAT, COCO export) can be
  passed with `--test-source`; do not put them in `--source` or `--extra-dir`.
  `prepare_dataset.py` stops if a test image has the same bytes as a training
  image.
- The test set is used only to evaluate. If a model is changed because of its
  test results, a new, fresh test set is needed before the next release.

## Synthetic scenes

The public dataset has small coloured dice on a white tray. The first model,
trained only on it, saw dice in wood knots and fabric folds and misread dice
under other light. Synthetic scenes fix the domain: any floor, any light, any
dice, with exact labels and no hand labelling.

`synth/render_dice.py` runs inside Blender (tested with 4.2 LTS, Cycles on an
NVIDIA GPU). Each scene has a floor with a random Poly Haven texture or a plain
colour, a random HDRI and sometimes a lamp, 0 to 6 dice of a random style seen
from 7 to 35 cm like a phone, and sometimes distractors (coins, buttons, blank
cubes), so the model learns that a dark dot on its own is not a die. About 8% of
the scenes have no dice. The face up is set in the scene and the box is the
projection of the die mesh, so the labels are exact. The dice styles include one
that matches the maintainer's dice (white, red 1 and 4 with a larger 1, blue or
black pips on the other faces).

```bash
python tool/dice_model/synth/fetch_polyhaven.py --out build/dice_model/polyhaven
blender -b -P tool/dice_model/synth/render_dice.py -- \
  --assets build/dice_model/polyhaven --out build/dice_model/synth_v1 --count 3000 --seed 1
python tool/dice_model/synth/merge_coco.py --synth build/dice_model/synth_v1 \
  --real build/dice_model/dataset --out build/dice_model/dataset_v1
```

Rendering is limited more by the CPU (building each scene) than by the GPU, so
two or three Blender processes with different `--seed`
values and output folders use the machine better. `--synth` can be repeated in
`merge_coco.py`.

The shipped model used 4498 scenes and this training command:

```bash
python tool/dice_model/train.py --yolox-dir ~/src/YOLOX \
  --data-dir build/dice_model/dataset_v1 --pretrained build/dice_model/yolox_nano.pth \
  --epochs 80 --batch-size 16 --input-size 640 --mosaic-scale 0.7,1.6 --fp16
```

`--mosaic-scale 0.7,1.6` keeps the dice of the synthetic scenes from being
shrunk too far by mosaic. A 416 px model trained the same way read faces worse
on both test sets (0.867 against 0.959 on the public test split), because a die
in a phone frame covers only 10 to 17 px at 416.

## Own photos

The release test is a set of the maintainer's own photos, never used for
training. Labelling boxes is slow, so `evaluate_throws.py` needs only the faces
up of each photo, in any order:

```json
{"IMG_0001.jpg": [4, 5, 2, 6, 2]}
```

```bash
python tool/dice_model/evaluate_throws.py --model assets/models/dice_detector.tflite \
  --photos <photo folder> --truth truth.json --frame-short-side 480
```

`--frame-short-side 480` scales each photo to the app's camera stream
(`ResolutionPreset.medium`). `--modes full,center` compares the whole frame with
a centred square crop. A throw counts as right only when every die is found and
read right, which is what a seed needs.

## Reproduce

Run from the repository root. Python **3.12** is required (onnx2tf 2.6.9 needs
3.12 or newer). YOLOX trains on CUDA, so `train.py` expects an NVIDIA GPU.

**On a Mac** there is no CUDA. `train.py` hands the same settings to
`train_mac.py`, which runs YOLOX's own Trainer with the CUDA-only parts replaced
at runtime (each replacement is marked `MAC-PATCH`; the YOLOX checkout is not
edited). Use `--device cpu`: it is the tested path, about 2 minutes per epoch
for this dataset on Apple Silicon. `--device mps` (Apple GPU) is experimental:
with PyTorch 2.5.1 the backward pass fails on a view/stride error in the MPS
backend.

```bash
python tool/dice_model/train_mac.py --device cpu \
  --data-dir build/dice_model/dataset --pretrained build/dice_model/yolox_nano.pth \
  --epochs 70 --batch-size 16 --seed 42
```

```bash
# 0. Environment
python3.12 -m venv .venv-dice && source .venv-dice/bin/activate
pip install -r tool/dice_model/requirements.txt

# YOLOX from a pinned checkout. --no-deps: YOLOX's own requirements list an
# onnx-simplifier pin that conflicts with onnx2tf's onnxsim; the deps are above.
git clone https://github.com/Megvii-BaseDetection/YOLOX.git ~/src/YOLOX
git -C ~/src/YOLOX checkout 6ddff4824372906469a7fae2dc3206c7aa4bbaee   # main as of 2025-06-08; update to a newer tag after checking
pip install -v -e ~/src/YOLOX --no-deps

# 1. Dataset to COCO layout. Roboflow export: group by source photo, 75/10/15 split
python tool/dice_model/prepare_dataset.py \
  --source build/dice_model/source/dicemaschine_d6_v2 --format coco \
  --group-split --ratios 0.75 0.10 0.15 --seed 42 \
  --out build/dice_model/dataset
# Random-file split instead (not leak-free for Roboflow exports):
#   --val-fraction 0.2 without --group-split; own test photos: --test-source <folder> --test-format coco

# 2. Train (start from the COCO-pretrained YOLOX-Nano checkpoint)
curl -L -o build/dice_model/yolox_nano.pth \
  https://github.com/Megvii-BaseDetection/YOLOX/releases/download/0.1.1rc0/yolox_nano.pth
python tool/dice_model/train.py --yolox-dir ~/src/YOLOX \
  --data-dir build/dice_model/dataset --pretrained build/dice_model/yolox_nano.pth \
  --epochs 150 --batch-size 32 --devices 1 --seed 42 --fp16

# 3. Export: YOLOX ONNX (decoded), onnx2tf float32 TFLite, contract and numeric checks
#    (prefix DICE_INPUT_SIZE=640 here and in step 4 for a 640 px model)
python tool/dice_model/export.py --yolox-dir ~/src/YOLOX \
  --ckpt build/dice_model/yolox_outputs/dice_exp/best_ckpt.pth \
  --out-dir build/dice_model/export

# 4. Evaluate on the held-out test split (15% of source photos until own photos exist)
python tool/dice_model/evaluate.py \
  --model build/dice_model/export/dice_detector.tflite \
  --labels build/dice_model/export/dice_detector_labels.txt \
  --data-dir build/dice_model/dataset --split test2017 \
  --json-out build/dice_model/export/eval.json

# 5. Copy to the app (after the evaluation passes), then record the SHA-256
cp build/dice_model/export/dice_detector.tflite assets/models/
cp build/dice_model/export/dice_detector_labels.txt assets/models/
shasum -a 256 assets/models/dice_detector.tflite
```

The pretrained checkpoint URL is the release used in YOLOX's own weight links
(tag `0.1.1rc0`). It is not verified here. Check it exists before the run.

`train.py --dry-run` prints the exact YOLOX command without running it.

### Settings worth knowing

- `dice_exp.py` sets: 6 classes, depth 0.33, width 0.25, depthwise, 416 px input
  by default (multi-scale training from 320 to 640 px at 416, and from 0.75 to
  1.25 times the input size otherwise),
  mosaic on (scale 0.5 to 1.5), mixup off, horizontal flips 0.5, rotation
  +-15 degrees, shear 2, HSV jitter on, 150 epochs, seed 42. YOLOX's defaults
  are used for everything else (for example warmup and LR schedule).
- `prepare_dataset.py --test-source` converts a separate folder without
  splitting it. `summary.json` in the output folder records the split sizes and
  boxes per face.
- `export.py --skip-onnx` reuses an existing `work/dice_detector.onnx`.
- `export.py --tolerance-float32` is a starting value
  for the relative difference against ONNX Runtime. Tune it on the first real
  export and write the chosen value in the model card.

## Google Colab

Colab's default Python may not be 3.12. Use `uv` to get a 3.12 environment.
This route is not tested yet.

```python
# Cell 1: Python 3.12 environment and requirements
!pip install -q uv
!uv venv -p 3.12 /content/venv
!VIRTUAL_ENV=/content/venv uv pip install -r tool/dice_model/requirements.txt
```

```python
# Cell 2: YOLOX checkout, installed without its dependency pins
!git clone https://github.com/Megvii-BaseDetection/YOLOX.git /content/YOLOX
!git -C /content/YOLOX checkout 6ddff4824372906469a7fae2dc3206c7aa4bbaee
!VIRTUAL_ENV=/content/venv uv pip install -e /content/YOLOX --no-deps
```

Upload the repository folder `tool/dice_model/` and the dataset zip. Run the
commands from the reproduce section with `/content/venv/bin/python` in place of
`python`, and make sure the runtime has a GPU.

## Expected outputs

In `build/dice_model/export/`:

- `dice_detector.tflite`: float32 weights, input and output.
- `dice_detector_labels.txt`: six lines, `1` to `6`.
- `eval.json`: metrics from `evaluate.py`, if `--json-out` was given.

## Attribution and licensing

- The scripts in this folder are part of SatoWiki and follow the repository's MIT
  license.
- YOLOX (Apache-2.0), onnx2tf (MIT) and the other libraries keep their own
  licenses. The export is a derived model of YOLOX-Nano, so the model card names
  YOLOX.
- The model inherits the dataset's license. The dataset's required attribution
  goes in `assets/models/dice_detector.md`.
