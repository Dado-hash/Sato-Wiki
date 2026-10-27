"""Export the trained YOLOX-Nano checkpoint to assets/models/dice_detector.tflite.

Steps:

 1. The same steps as YOLOX tools/export_onnx.py, run in process with
    torch.onnx.export (decode in inference, no onnxsim).
    The ONNX output is [1, 3549, 11], already decoded (see dice_contract.py).
    onnxsim is skipped because onnx2tf runs its own simplification, and
    YOLOX's pinned onnx-simplifier conflicts with onnx2tf's onnxsim.
 2. onnx2tf (MIT, PINTO0309) converts the ONNX file to TFLite. It writes
    float32 and float16 files. Only the float32 file is kept: the float16 one
    has float16 activations, which the TFLite CPU kernels reject.
 3. The TFLite file is checked against the contract: input [1, 416, 416, 3]
    float32, output [1, 3549, 11] float32. Any mismatch stops the export.
 4. Numeric check: the float32 TFLite is compared
    with ONNX Runtime on the same random input. A large difference stops the export.
 5. Copies dice_detector.tflite and dice_detector_labels.txt to --out-dir and
    prints the SHA-256 of the .tflite file.

Requires the venv from requirements.txt, with YOLOX installed from its checkout.
"""

from __future__ import annotations

import argparse
import hashlib
import os
import shutil
import subprocess
import sys
from pathlib import Path
from typing import List, Optional

import numpy as np

from dice_contract import (
    INPUT_SIZE,
    LABELS,
    NUM_ANCHORS,
    OUTPUT_DIM,
    ContractError,
    check_interpreter_io,
    load_interpreter,
)

HERE = Path(__file__).resolve().parent
OPSET = 11


def parse_args(argv: Optional[List[str]] = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--yolox-dir", type=Path, required=True, help="Git checkout of YOLOX.")
    parser.add_argument("--exp", type=Path, default=HERE / "dice_exp.py", help="Experiment file.")
    parser.add_argument("--ckpt", type=Path,
                        default=Path("build/dice_model/yolox_outputs/dice_exp/best_ckpt.pth"),
                        help="Trained checkpoint from train.py.")
    parser.add_argument("--work-dir", type=Path, default=Path("build/dice_model/export/work"),
                        help="Intermediate ONNX and TFLite files.")
    parser.add_argument("--out-dir", type=Path, default=Path("build/dice_model/export"),
                        help="Where dice_detector.tflite and the labels file are written.")
    parser.add_argument("--tolerance-float32", type=float, default=1e-3,
                        help="Max relative difference, float32 TFLite vs ONNX Runtime (starting value, tune on first export).")
    parser.add_argument("--skip-onnx", action="store_true",
                        help="Reuse work-dir/dice_detector.onnx instead of exporting again.")
    return parser.parse_args(argv)


def sha256_of(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1 << 20), b""):
            digest.update(chunk)
    return digest.hexdigest()


def export_onnx(args: argparse.Namespace, onnx_path: Path) -> None:
    # Same steps as YOLOX tools/export_onnx.py, run in process: that script calls
    # torch.onnx._export, which torch 2.5 removed, so it uses the public torch.onnx.export.
    if not (args.yolox_dir / "yolox").is_dir():
        raise SystemExit(f"{args.yolox_dir}: yolox/ not found; is this a YOLOX checkout?")
    if not args.ckpt.exists():
        raise SystemExit(f"Checkpoint not found: {args.ckpt} (run train.py first)")
    sys.path.insert(0, str(args.yolox_dir.resolve()))

    import torch
    from torch import nn
    from yolox.exp import get_exp
    from yolox.models.network_blocks import SiLU
    from yolox.utils import replace_module

    exp = get_exp(str(args.exp.resolve()), None)
    model = exp.get_model()
    ckpt = torch.load(str(args.ckpt), map_location="cpu", weights_only=False)
    model.load_state_dict(ckpt.get("model", ckpt))
    model.eval()
    model = replace_module(model, nn.SiLU, SiLU)
    model.head.decode_in_inference = True

    dummy = torch.randn(1, 3, exp.test_size[0], exp.test_size[1])
    print(f"ONNX export: {args.ckpt} -> {onnx_path} (opset {OPSET}, decode in inference)", flush=True)
    torch.onnx.export(
        model,
        dummy,
        str(onnx_path),
        input_names=["images"],
        output_names=["output"],
        opset_version=OPSET,
        dynamo=False,
    )


def check_onnx(onnx_path: Path) -> None:
    import onnx

    model = onnx.load(str(onnx_path))
    if len(model.graph.input) != 1 or len(model.graph.output) != 1:
        raise ContractError("ONNX model must have exactly one input and one output")

    def dims(value_info) -> List[int]:
        return [d.dim_value for d in value_info.type.tensor_type.shape.dim]

    in_dims = dims(model.graph.input[0])
    out_dims = dims(model.graph.output[0])
    if in_dims != [1, 3, INPUT_SIZE, INPUT_SIZE]:
        raise ContractError(f"ONNX input {in_dims}, expected [1, 3, {INPUT_SIZE}, {INPUT_SIZE}] (NCHW)")
    if out_dims != [1, NUM_ANCHORS, OUTPUT_DIM]:
        raise ContractError(
            f"ONNX output {out_dims}, expected [1, {NUM_ANCHORS}, {OUTPUT_DIM}]. "
            "Is --decode_in_inference set and is num_classes 6?"
        )


def convert_tflite(onnx_path: Path, tf_dir: Path) -> Path:
    """Runs onnx2tf and returns the float32 .tflite file it writes.

    onnx2tf also writes a *_float16.tflite, but its flatbuffer_direct backend makes
    the activations float16 too, and the TFLite CPU kernels (CONV_2D) reject that
    file at allocate_tensors. So the float32 file is the one shipped.
    """
    if tf_dir.exists():
        shutil.rmtree(tf_dir)
    env = dict(os.environ)
    env["PATH"] = str(Path(sys.executable).parent) + os.pathsep + env.get("PATH", "")
    cmd = ["onnx2tf", "-i", str(onnx_path), "-o", str(tf_dir)]
    print("TFLite conversion:", " ".join(cmd), flush=True)
    subprocess.run(cmd, check=True, env=env)
    float32 = sorted(tf_dir.glob("*_float32.tflite"))
    if len(float32) != 1:
        raise SystemExit(
            f"onnx2tf did not write one float32 .tflite in {tf_dir} "
            f"(found {[p.name for p in float32]})."
        )
    return float32[0]


def run_tflite(model_path: Path, batch: np.ndarray) -> np.ndarray:
    interpreter = load_interpreter(str(model_path))
    check_interpreter_io(interpreter)
    detail = interpreter.get_input_details()[0]
    interpreter.set_tensor(detail["index"], batch)
    interpreter.invoke()
    out = interpreter.get_output_details()[0]
    return interpreter.get_tensor(out["index"])[0]


def run_onnx(onnx_path: Path, nhwc: np.ndarray) -> np.ndarray:
    import onnxruntime as ort

    session = ort.InferenceSession(str(onnx_path), providers=["CPUExecutionProvider"])
    name = session.get_inputs()[0].name
    nchw = np.ascontiguousarray(nhwc.transpose(0, 3, 1, 2))
    return session.run(None, {name: nchw})[0][0]


def relative_diff(a: np.ndarray, b: np.ndarray) -> float:
    return float(np.max(np.abs(a - b)) / max(1.0, float(np.max(np.abs(a)))))


def main(argv: Optional[List[str]] = None) -> int:
    args = parse_args(argv)
    args.work_dir.mkdir(parents=True, exist_ok=True)
    args.out_dir.mkdir(parents=True, exist_ok=True)
    onnx_path = args.work_dir / "dice_detector.onnx"

    if not args.skip_onnx:
        export_onnx(args, onnx_path)
    if not onnx_path.exists():
        raise SystemExit(f"{onnx_path} missing; run without --skip-onnx first")
    check_onnx(onnx_path)

    float32_path = convert_tflite(onnx_path, args.work_dir / "tflite")

    # Same random input for every backend: values 0..255, NHWC, as the app feeds it.
    rng = np.random.default_rng(0)
    batch = rng.uniform(0, 255, size=(1, INPUT_SIZE, INPUT_SIZE, 3)).astype(np.float32)
    reference = run_onnx(onnx_path, batch)
    out32 = run_tflite(float32_path, batch)
    diff32 = relative_diff(reference, out32)
    print(f"Relative difference vs ONNX Runtime: float32 {diff32:.5f}")
    if diff32 > args.tolerance_float32:
        raise SystemExit(f"float32 TFLite differs from ONNX by {diff32:.5f} (limit {args.tolerance_float32})")

    model_out = args.out_dir / "dice_detector.tflite"
    labels_out = args.out_dir / "dice_detector_labels.txt"
    shutil.copyfile(float32_path, model_out)
    labels_out.write_text("\n".join(LABELS) + "\n", encoding="utf-8")
    print(f"Wrote {model_out} ({model_out.stat().st_size} bytes)")
    print(f"Wrote {labels_out}")
    print(f"SHA-256 {sha256_of(model_out)}  {model_out}")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except ContractError as error:
        print(f"Contract check failed: {error}", file=sys.stderr)
        sys.exit(2)
