"""YOLOX-Nano experiment for the dice detector: six faces, classes "1" to "6".

Follows exps/example/custom/nano.py in the YOLOX repository (Apache-2.0). Used by
train.py (python -m yolox.tools.train -f dice_exp.py) and by YOLOX's
tools/export_onnx.py, so the export uses the same model definition.

train.py passes the settings below through environment variables, so this file
works from any working directory:

    DICE_DATA_DIR    COCO-layout dataset folder (prepare_dataset.py --out)
    DICE_OUTPUT_DIR  where YOLOX writes checkpoints and logs
    DICE_MAX_EPOCH   number of training epochs
    DICE_SEED        random seed (YOLOX reads it from exp.seed)

Input size is 416x416 for training, testing and export, matching the app contract
(see dice_contract.py).
"""

import os

import torch.nn as nn

from yolox.exp import Exp as MyExp
from yolox.models import YOLOX, YOLOPAFPN, YOLOXHead


def _env_int(name: str, default: int) -> int:
    value = os.environ.get(name)
    return int(value) if value else default


class Exp(MyExp):
    def __init__(self):
        super().__init__()
        # Model: YOLOX-Nano scale, depthwise convolutions, six die faces.
        self.num_classes = 6
        self.depth = 0.33
        self.width = 0.25
        self.act = "silu"
        self.depthwise = True
        self.input_size = (416, 416)
        self.test_size = (416, 416)
        # Multi-scale training in steps of 32 px (320 to 640). Export is fixed at 416.
        self.random_size = (10, 20)

        # Augmentation for dice: mosaic and flips on, mixup off, rotation +-15 degrees.
        self.mosaic_prob = 1.0
        self.mosaic_scale = (0.5, 1.5)
        self.enable_mixup = False
        self.mixup_prob = 0.0
        self.flip_prob = 0.5
        self.hsv_prob = 1.0
        self.degrees = 15.0
        self.translate = 0.1
        self.shear = 2.0
        self.no_aug_epochs = 15

        # Schedule and evaluation.
        self.max_epoch = _env_int("DICE_MAX_EPOCH", 150)
        self.eval_interval = 10

        # Data: prepare_dataset.py writes train2017/, val2017/ and annotations/.
        self.data_dir = os.environ.get("DICE_DATA_DIR", "build/dice_model/dataset")
        self.train_ann = "instances_train2017.json"
        self.val_ann = "instances_val2017.json"

        # Output and reproducibility.
        self.output_dir = os.environ.get("DICE_OUTPUT_DIR", "build/dice_model/yolox_outputs")
        self.seed = _env_int("DICE_SEED", 42)
        # YOLOX's base Exp takes exp_name from yolox_base.py, so checkpoints would go to
        # <output_dir>/yolox_base/. export.py reads <output_dir>/dice_exp/best_ckpt.pth.
        self.exp_name = "dice_exp"

    def get_model(self, sublinear=False):
        def init_yolo(module):
            for m in module.modules():
                if isinstance(m, nn.BatchNorm2d):
                    m.eps = 1e-3
                    m.momentum = 0.03

        if getattr(self, "model", None) is None:
            in_channels = [256, 512, 1024]
            backbone = YOLOPAFPN(
                self.depth, self.width, in_channels=in_channels, act=self.act, depthwise=self.depthwise
            )
            head = YOLOXHead(
                self.num_classes, self.width, in_channels=in_channels, act=self.act, depthwise=self.depthwise
            )
            self.model = YOLOX(backbone, head)
        self.model.apply(init_yolo)
        self.model.head.initialize_biases(1e-2)
        return self.model
