"""Train the dice detector (YOLOX-Nano, dice_exp.py) with YOLOX's own training script.

This is a thin wrapper: it checks the inputs, sets the environment that
dice_exp.py reads, and runs

    python -m yolox.tools.train -f dice_exp.py -d <devices> -b <batch> [--fp16] [-c <pretrained>]

from the Python environment where YOLOX is installed (pip install -e <checkout>
--no-deps, see README.md). The seed is passed through DICE_SEED and read by YOLOX
as exp.seed.

Training on Linux or Windows needs a CUDA GPU (YOLOX's own script is CUDA-only).
On macOS there is no CUDA: this script hands the same settings to train_mac.py,
which runs the same Trainer on Apple Silicon (MPS) or CPU. Use --dry-run to print
the command without running it.

Example:
    python tool/dice_model/train.py --yolox-dir ~/src/YOLOX \\
      --data-dir build/dice_model/dataset --pretrained build/dice_model/yolox_nano.pth
"""

from __future__ import annotations

import argparse
import os
import subprocess
import sys
from pathlib import Path
from typing import List, Optional

HERE = Path(__file__).resolve().parent


def parse_args(argv: Optional[List[str]] = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--yolox-dir", type=Path, required=True, help="Git checkout of YOLOX (see README.md).")
    parser.add_argument("--data-dir", type=Path, default=Path("build/dice_model/dataset"),
                        help="COCO-layout dataset from prepare_dataset.py.")
    parser.add_argument("--output-dir", type=Path, default=Path("build/dice_model/yolox_outputs"),
                        help="Where YOLOX writes checkpoints (best_ckpt.pth).")
    parser.add_argument("--exp", type=Path, default=HERE / "dice_exp.py", help="Experiment file.")
    parser.add_argument("--pretrained", type=Path,
                        help="COCO checkpoint yolox_nano.pth to start from (recommended).")
    parser.add_argument("--epochs", type=int, default=150, help="Training epochs (DICE_MAX_EPOCH).")
    parser.add_argument("--batch-size", type=int, default=32, help="Total batch size (YOLOX -b).")
    parser.add_argument("--devices", type=int, default=1, help="GPUs (YOLOX -d).")
    parser.add_argument("--seed", type=int, default=42, help="Random seed (DICE_SEED).")
    parser.add_argument("--fp16", action="store_true", help="Mixed precision training.")
    parser.add_argument("--input-size", type=int, default=416, help="Square input size (DICE_INPUT_SIZE).")
    parser.add_argument("--mosaic-scale", default="0.5,1.5", help="Mosaic scale range low,high (DICE_MOSAIC_SCALE).")
    parser.add_argument("--dry-run", action="store_true", help="Print the command and exit.")
    return parser.parse_args(argv)


def check_inputs(args: argparse.Namespace) -> None:
    if not (args.yolox_dir / "tools" / "train.py").exists():
        raise SystemExit(f"{args.yolox_dir}: not a YOLOX checkout (tools/train.py missing)")
    if not args.exp.exists():
        raise SystemExit(f"Experiment file not found: {args.exp}")
    annotations = args.data_dir / "annotations" / "instances_train2017.json"
    if not annotations.exists() or not (args.data_dir / "train2017").is_dir():
        raise SystemExit(f"{args.data_dir}: run prepare_dataset.py first (missing train2017/ or annotations)")
    if args.pretrained and not args.pretrained.exists():
        raise SystemExit(f"Pretrained checkpoint not found: {args.pretrained}")


def build_command(args: argparse.Namespace) -> List[str]:
    cmd = [
        sys.executable, "-m", "yolox.tools.train",
        "-f", str(args.exp.resolve()),
        "-d", str(args.devices),
        "-b", str(args.batch_size),
    ]
    if args.fp16:
        cmd.append("--fp16")
    if args.pretrained:
        cmd += ["-c", str(args.pretrained.resolve())]
    return cmd


def mac_command(args: argparse.Namespace) -> List[str]:
    """Arguments for train_mac.py, which runs on MPS or CPU (no CUDA on macOS)."""
    if args.fp16 or args.devices != 1:
        raise SystemExit("--fp16 and --devices other than 1 need CUDA; train_mac.py is fp32, single device")
    cmd = [
        sys.executable, str(HERE / "train_mac.py"),
        "--data-dir", str(args.data_dir.resolve()),
        "--output-dir", str(args.output_dir.resolve()),
        "--epochs", str(args.epochs),
        "--batch-size", str(args.batch_size),
        "--seed", str(args.seed),
    ]
    if args.pretrained:
        cmd += ["--pretrained", str(args.pretrained.resolve())]
    return cmd


def main(argv: Optional[List[str]] = None) -> int:
    args = parse_args(argv)
    check_inputs(args)
    if sys.platform == "darwin":
        cmd = mac_command(args)
        print("macOS has no CUDA. Running train_mac.py instead:", " ".join(cmd), flush=True)
        if args.dry_run:
            return 0
        return subprocess.run(cmd, check=False).returncode
    env = dict(os.environ)
    env.update(
        DICE_DATA_DIR=str(args.data_dir.resolve()),
        DICE_OUTPUT_DIR=str(args.output_dir.resolve()),
        DICE_MAX_EPOCH=str(args.epochs),
        DICE_SEED=str(args.seed),
        DICE_INPUT_SIZE=str(args.input_size),
        DICE_MOSAIC_SCALE=args.mosaic_scale,
    )
    cmd = build_command(args)
    print("Running:", " ".join(cmd), flush=True)
    if args.dry_run:
        return 0
    result = subprocess.run(cmd, env=env, check=False)
    return result.returncode


if __name__ == "__main__":
    sys.exit(main())
