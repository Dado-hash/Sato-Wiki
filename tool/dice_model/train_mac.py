"""Train the dice detector (dice_exp.py) on a Mac: Apple Silicon GPU (MPS) or CPU.

YOLOX trains on CUDA only. This launcher runs the same Trainer as

    python -m yolox.tools.train -f dice_exp.py -d 1 -b <batch> -c <pretrained>

but replaces the CUDA-only parts at runtime. The YOLOX checkout is not edited.
Each replacement is marked MAC-PATCH and names the YOLOX file and lines it
replaces (line numbers refer to commit 6ddff4824372906469a7fae2dc3206c7aa4bbaee).
Single process, fp32 (no AMP), no distributed setup, no CUDA streams.

Device: --device mps|cpu, else env DICE_DEVICE, else MPS when available.
Unsupported MPS ops fall back to CPU (PYTORCH_ENABLE_MPS_FALLBACK=1, set below
before torch is imported).

Output: <output-dir>/dice_exp/best_ckpt.pth, where export.py looks for it.

Example (repository root):
    python tool/dice_model/train_mac.py --data-dir build/dice_model/dataset \\
      --pretrained build/dice_model/yolox_nano.pth --epochs 150 --batch-size 16 --seed 42
"""

import os

# Must be set before torch is imported. Ops without an MPS kernel run on the CPU.
os.environ.setdefault("PYTORCH_ENABLE_MPS_FALLBACK", "1")

import argparse  # noqa: E402
import random  # noqa: E402
import sys  # noqa: E402
import time  # noqa: E402
import warnings  # noqa: E402
from collections import defaultdict  # noqa: E402
from pathlib import Path  # noqa: E402
from typing import List, Optional  # noqa: E402

import torch  # noqa: E402
from loguru import logger  # noqa: E402
from tqdm import tqdm  # noqa: E402

import yolox.core.trainer as yolox_trainer  # noqa: E402
from yolox.core import Trainer  # noqa: E402
from yolox.evaluators import COCOEvaluator  # noqa: E402
from yolox.exp import check_exp_value  # noqa: E402
from yolox.tools.train import make_parser as yolox_train_parser  # noqa: E402
from yolox.utils import ModelEMA, get_model_info, is_main_process, postprocess, synchronize  # noqa: E402

from dice_exp import Exp as DiceExp  # noqa: E402  (same directory)

HERE = Path(__file__).resolve().parent
DEVICES = ("mps", "cpu")


# ----------------------------------------------------------------------------
# MPS dtype strings (legacy tensor.type() casts in YOLOX).
# ----------------------------------------------------------------------------
# MAC-PATCH: YOLOX casts with legacy type strings taken from tensor.type(). On MPS
# that string is 'torch.mps.FloatTensor', and Tensor.type() rejects it
# ("invalid type: 'torch.mps.FloatTensor'"), so the first training iteration fails.
# Covered YOLOX call sites (commit 6ddff4824372906469a7fae2dc3206c7aa4bbaee):
#   yolox/models/yolo_head.py:166, 211, 223, 245, 246, 597
#   yolox/utils/boxes.py:100
#   yolox/models/losses.py:30
#   yolox/evaluators/coco_evaluator.py:171 (decoder dtype=outputs.type())
# The wrapper maps 'torch.mps.<Name>Tensor' to self.to(device="mps", dtype=...),
# i.e. the legacy type-string semantics: the string encodes both the device and
# the dtype. YOLOX relies on this to move CPU-built grids to the GPU
# (yolo_head.py get_output_and_grid and decode_outputs). Keeping the device
# left those grids on CPU ("Expected all tensors to be on the same device").
# Every other call (no argument, real dtypes, CPU/CUDA strings) goes to the
# original method unchanged.
# Installed only when the selected device is mps (see main()).
_MPS_LEGACY_DTYPES = {
    "FloatTensor": torch.float32,
    "HalfTensor": torch.float16,
    "DoubleTensor": torch.float64,
    "LongTensor": torch.int64,
    "IntTensor": torch.int32,
    "BoolTensor": torch.bool,
    "ByteTensor": torch.uint8,
    "CharTensor": torch.int8,
    "ShortTensor": torch.int16,
    "BFloat16Tensor": torch.bfloat16,
}
_original_tensor_type = torch.Tensor.type


def _tensor_type_accepting_mps_names(self, dtype=None, non_blocking=False):
    if isinstance(dtype, str) and dtype.startswith("torch.mps."):
        target = _MPS_LEGACY_DTYPES.get(dtype[len("torch.mps."):])
        if target is not None:
            return self.to(device="mps", dtype=target, non_blocking=non_blocking)
    if dtype is None:
        return _original_tensor_type(self, non_blocking=non_blocking)
    return _original_tensor_type(self, dtype, non_blocking=non_blocking)


def install_mps_type_patch() -> None:
    """Idempotent. Only called when the device is mps."""
    if torch.Tensor.type is not _tensor_type_accepting_mps_names:
        torch.Tensor.type = _tensor_type_accepting_mps_names


# ----------------------------------------------------------------------------
# Plain data path (replaces DataPrefetcher, data_prefetcher.py:8-51, and the
# CUDA stream use in Trainer.before_train, trainer.py:158).
# ----------------------------------------------------------------------------
class PlainPrefetcher:
    """Iterates the train loader and moves each batch to the device.

    YOLOX's DataPrefetcher preloads the next batch on a torch.cuda.Stream and
    copies it with .cuda(non_blocking=True). Here there is no preload and no
    stream: next() returns the batch already on the device.
    """

    def __init__(self, loader, device: str):
        self.loader = iter(loader)
        self.device = device

    def next(self):
        inputs, targets, _, _ = next(self.loader)
        return inputs.to(self.device), targets.to(self.device)


# ----------------------------------------------------------------------------
# Evaluator (replaces COCOEvaluator.evaluate, coco_evaluator.py:116-205).
# ----------------------------------------------------------------------------
class DiceCOCOEvaluator(COCOEvaluator):
    """COCOEvaluator with the CUDA-only lines of evaluate() changed.

    MAC-PATCH coco_evaluator.py:135: `tensor_type = torch.cuda.FloatTensor`
        -> images are moved with imgs.to(device, float32).
    MAC-PATCH coco_evaluator.py:189: `torch.cuda.FloatTensor([...])`
        -> a CPU float32 tensor (evaluate_prediction only reads .item()).
    MAC-PATCH coco_evaluator.py:154: `.cuda()` in the TensorRT branch is dropped
        (trt_file is not used).
    MAC-PATCH coco_evaluator.py:174,181: time_synchronized() only syncs CUDA;
        on MPS this syncs torch.mps before reading the clock.
    distributed, half and TensorRT are not supported here (single process, fp32).
    """

    def __init__(self, *args, device: str, **kwargs):
        super().__init__(*args, **kwargs)
        self.device = device

    def _sync_and_time(self) -> float:
        if self.device == "mps":
            torch.mps.synchronize()
        return time.time()

    def evaluate(self, model, distributed=False, half=False, trt_file=None,
                 decoder=None, test_size=None, return_outputs=False):
        if distributed or half or trt_file is not None:
            raise NotImplementedError("train_mac.py runs single process, fp32, without TensorRT")
        model = model.eval()
        data_list = []
        output_data = defaultdict()
        progress_bar = tqdm if is_main_process() else iter

        inference_time = 0
        nms_time = 0
        n_samples = max(len(self.dataloader) - 1, 1)

        for cur_iter, (imgs, _, info_imgs, ids) in enumerate(progress_bar(self.dataloader)):
            with torch.no_grad():
                imgs = imgs.to(self.device, dtype=torch.float32)

                # skip the last iters since batchsize might be not enough for batch inference
                is_time_record = cur_iter < len(self.dataloader) - 1
                if is_time_record:
                    start = self._sync_and_time()

                outputs = model(imgs)
                if decoder is not None:
                    outputs = decoder(outputs, dtype=outputs.type())

                if is_time_record:
                    infer_end = self._sync_and_time()
                    inference_time += infer_end - start

                outputs = postprocess(outputs, self.num_classes, self.confthre, self.nmsthre)
                if is_time_record:
                    nms_end = self._sync_and_time()
                    nms_time += nms_end - infer_end

            data_list_elem, image_wise_data = self.convert_to_coco_format(
                outputs, info_imgs, ids, return_outputs=True)
            data_list.extend(data_list_elem)
            output_data.update(image_wise_data)

        statistics = torch.tensor([inference_time, nms_time, n_samples], dtype=torch.float32)
        eval_results = self.evaluate_prediction(data_list, statistics)
        synchronize()

        if return_outputs:
            return eval_results, output_data
        return eval_results


# ----------------------------------------------------------------------------
# Experiment: dice_exp.Exp with three CUDA-only methods replaced.
# ----------------------------------------------------------------------------
class MacDiceExp(DiceExp):
    def __init__(self, device: str):
        super().__init__()
        self.mac_device = device

    def random_resize(self, data_loader, epoch, rank, is_distributed):
        """MAC-PATCH yolox_base.py:224-241 (random_resize).

        YOLOX puts the new size in torch.LongTensor(2).cuda() on rank 0 and
        broadcasts it. There is one process, so the size is drawn directly.
        Same draw and same output as YOLOX.
        """
        size_factor = self.input_size[1] * 1.0 / self.input_size[0]
        size = random.randint(*self.random_size)
        return (int(32 * size), 32 * int(size * size_factor))

    def get_evaluator(self, batch_size, is_distributed, testdev=False, legacy=False):
        """MAC-PATCH yolox_base.py:get_evaluator: builds DiceCOCOEvaluator (see above)."""
        return DiceCOCOEvaluator(
            dataloader=self.get_eval_loader(batch_size, is_distributed, testdev=testdev, legacy=legacy),
            img_size=self.test_size,
            confthre=self.test_conf,
            nmsthre=self.nmsthre,
            num_classes=self.num_classes,
            testdev=testdev,
            device=self.mac_device,
        )


# ----------------------------------------------------------------------------
# Trainer (replaces parts of Trainer.__init__ and Trainer.before_train).
# ----------------------------------------------------------------------------
class DiceTrainer(Trainer):
    def __init__(self, exp, args, device: str):
        # Trainer.__init__ also builds torch.cuda.amp.GradScaler(enabled=fp16). With
        # fp16 off it is a no-op, so train_one_iter (inherited, unchanged) runs on MPS/CPU.
        super().__init__(exp, args)
        # MAC-PATCH trainer.py:51: self.device = "cuda:{local_rank}"
        self.device = device

    def before_train(self):
        """Copy of Trainer.before_train (trainer.py:131-197) with the CUDA lines changed.

        MAC-PATCH trainer.py:136: torch.cuda.set_device(local_rank) removed (no CUDA device).
        MAC-PATCH trainer.py:158: DataPrefetcher (CUDA streams) -> PlainPrefetcher.
        Removed, not used here: occupy_mem (-o, nvidia-smi and CUDA allocation),
        DDP (single process), wandb and mlflow loggers (tensorboard only).
        """
        logger.info("args: {}".format(self.args))
        logger.info("exp value:\n{}".format(self.exp))

        # model related init
        model = self.exp.get_model()
        logger.info("Model Summary: {}".format(get_model_info(model, self.exp.test_size)))
        model.to(self.device)

        # solver related init
        self.optimizer = self.exp.get_optimizer(self.args.batch_size)

        # value of epoch will be set in `resume_train`
        model = self.resume_train(model)

        # data related init
        self.no_aug = self.start_epoch >= self.max_epoch - self.exp.no_aug_epochs
        self.train_loader = self.exp.get_data_loader(
            batch_size=self.args.batch_size,
            is_distributed=False,
            no_aug=self.no_aug,
            cache_img=self.args.cache,
        )
        logger.info("init prefetcher (plain, no CUDA streams)")
        self.prefetcher = PlainPrefetcher(self.train_loader, self.device)
        # max_iter means iters per epoch
        self.max_iter = len(self.train_loader)

        self.lr_scheduler = self.exp.get_lr_scheduler(
            self.exp.basic_lr_per_img * self.args.batch_size, self.max_iter
        )

        if self.use_model_ema:
            self.ema_model = ModelEMA(model, 0.9998)
            self.ema_model.updates = self.max_iter * self.start_epoch

        self.model = model

        self.evaluator = self.exp.get_evaluator(batch_size=self.args.batch_size, is_distributed=False)

        if self.args.logger != "tensorboard":
            raise SystemExit("train_mac.py supports only the tensorboard logger")
        from torch.utils.tensorboard import SummaryWriter

        self.tblogger = SummaryWriter(os.path.join(self.file_name, "tensorboard"))

        logger.info("Training start...")
        logger.info("\n{}".format(model))


# ----------------------------------------------------------------------------
# Command line and entry point.
# ----------------------------------------------------------------------------
def parse_args(argv: Optional[List[str]] = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--data-dir", type=Path, default=Path("build/dice_model/dataset"),
                        help="COCO-layout dataset from prepare_dataset.py.")
    parser.add_argument("--output-dir", type=Path, default=Path("build/dice_model/yolox_outputs"),
                        help="Where YOLOX writes checkpoints (dice_exp/best_ckpt.pth).")
    parser.add_argument("--pretrained", type=Path,
                        help="COCO checkpoint yolox_nano.pth to start from (recommended).")
    parser.add_argument("--epochs", type=int, default=150, help="Training epochs.")
    parser.add_argument("--batch-size", type=int, default=16, help="Batch size (YOLOX -b).")
    parser.add_argument("--seed", type=int, default=42, help="Random seed.")
    parser.add_argument("--device", choices=DEVICES, default=None,
                        help="mps or cpu. Default: env DICE_DEVICE, else mps if available.")
    parser.add_argument("--workers", type=int, default=None,
                        help="Data loader worker processes (default: YOLOX's 4).")
    return parser.parse_args(argv)


def select_device(requested: Optional[str]) -> str:
    name = (requested or os.environ.get("DICE_DEVICE") or "").strip().lower()
    if not name:
        name = "mps" if torch.backends.mps.is_available() else "cpu"
    if name not in DEVICES:
        raise SystemExit(f"Unknown device {name!r}: use one of {', '.join(DEVICES)} (DICE_DEVICE or --device)")
    if name == "mps" and not torch.backends.mps.is_available():
        raise SystemExit("MPS is not available on this machine: use --device cpu")
    return name


def check_inputs(args: argparse.Namespace) -> None:
    annotations = args.data_dir / "annotations" / "instances_train2017.json"
    if not annotations.exists() or not (args.data_dir / "train2017").is_dir():
        raise SystemExit(f"{args.data_dir}: run prepare_dataset.py first (missing train2017/ or annotations)")
    if args.pretrained and not args.pretrained.exists():
        raise SystemExit(f"Pretrained checkpoint not found: {args.pretrained}")


def device_mem_usage_mb(device: str) -> float:
    """MAC-PATCH yolox/utils/metric.py:48 gpu_mem_usage (torch.cuda.max_memory_allocated).

    Used only by the 'gpu mem' field of the training log. Trainer.after_iter
    reads it through the name yolox.core.trainer.gpu_mem_usage, which is replaced in main().
    """
    if device == "mps":
        return torch.mps.current_allocated_memory() / (1024 * 1024)
    return 0.0


def main(argv: Optional[List[str]] = None) -> int:
    args = parse_args(argv)
    device = select_device(args.device)
    check_inputs(args)
    if device == "mps":
        # MAC-PATCH: legacy 'torch.mps.*Tensor' type strings, see install_mps_type_patch().
        install_mps_type_patch()
    # torch.cuda.amp.GradScaler/autocast are constructed with enabled=False on this
    # path. Their deprecation warnings are noise here.
    warnings.filterwarnings("ignore", message=r"torch\.cuda\.amp\..*deprecated", category=FutureWarning)

    exp = MacDiceExp(device)
    exp.data_dir = str(args.data_dir.resolve())
    exp.output_dir = str(args.output_dir.resolve())
    exp.max_epoch = args.epochs
    exp.seed = args.seed
    if args.workers is not None:
        exp.data_num_workers = args.workers
    check_exp_value(exp)

    argv_yolox = ["-f", str(HERE / "dice_exp.py"), "-b", str(args.batch_size), "-d", "1"]
    if args.pretrained:
        argv_yolox += ["-c", str(args.pretrained.resolve())]
    yolox_args = yolox_train_parser().parse_args(argv_yolox)
    yolox_args.experiment_name = exp.exp_name

    # MAC-PATCH tools/train.py:main: seeding is kept (random, torch). The CUDNN
    # deterministic flag, configure_nccl, configure_omp and launch() are not used.
    random.seed(exp.seed)
    torch.manual_seed(exp.seed)

    # MAC-PATCH trainer.py:268 (gpu_mem_usage, see device_mem_usage_mb).
    yolox_trainer.gpu_mem_usage = lambda: device_mem_usage_mb(device)

    logger.info("Training on {} (single process, fp32)".format(device))
    trainer = DiceTrainer(exp, yolox_args, device)
    try:
        trainer.train()
    except BaseException:
        # YOLOX redirects sys.stderr to loguru, so the traceback otherwise
        # disappears and train_log.txt only shows "Exception in training:".
        logger.exception("Training failed")
        raise
    return 0


if __name__ == "__main__":
    sys.exit(main())
