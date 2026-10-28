import 'dart:async';
import 'dart:isolate';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../domain/dice_detection.dart';
import 'dice_detector.dart';

/// Reads dice with an on-device YOLOX-Nano TFLite detector fed by the back
/// camera.
///
/// Model contract: float32 NHWC input `[1, S, S, 3]` in BGR, raw 0..255,
/// letterboxed (see [letterboxBgr]); float32 output `[1, N, 11]` holding
/// cx, cy, w, h (input pixels), objectness and 6 class probabilities.
///
/// Assumptions, to verify on a device:
/// - Android frames arrive in sensor orientation (landscape for a portrait
///   phone), so they are rotated by [CameraDescription.sensorOrientation].
/// - iOS frames arrive already upright, so no rotation is applied.
/// - Boxes are normalised to the upright frame, which is what [CameraPreview]
///   shows in portrait.
/// - The labels file order defines the class index: class `c` is the line `c`
///   (0-based) and must read `1`..`6`.
///
/// Frames are kept in memory only: nothing is saved, logged or sent anywhere.
class TfliteDiceDetector implements DiceDetector {
  TfliteDiceDetector();

  static const _modelAsset = 'assets/models/dice_detector.tflite';
  static const _labelsAsset = 'assets/models/dice_detector_labels.txt';

  /// Minimum gap between two processed frames (about 5 frames per second).
  static const _minFrameInterval = Duration(milliseconds: 200);

  /// Detections below this score (objectness x class probability) are dropped.
  static const minScore = 0.3;

  /// Overlapping detections above this IoU are merged, keeping the best one.
  static const nmsIouThreshold = 0.45;

  /// Most dice reported for one frame.
  static const maxDetections = 10;

  final _detections = StreamController<List<DetectedDie>>.broadcast();

  CameraController? _controller;
  Interpreter? _interpreter;
  IsolateInterpreter? _isolateInterpreter;
  List<String> _labels = const [];
  _ModelIo? _io;
  int _rotationDegrees = 0;
  bool _starting = false;
  bool _streaming = false;
  bool _busy = false;
  bool _disposed = false;
  DateTime? _lastFrame;

  @override
  Stream<List<DetectedDie>> get detections => _detections.stream;

  @override
  Future<bool> isAvailable() async {
    try {
      await rootBundle.load(_modelAsset);
      final cameras = await availableCameras();
      return cameras.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> start() async {
    if (_disposed || _starting || _streaming) return;
    _starting = true;
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final modelData = await rootBundle.load(_modelAsset);
      final labelsText = await rootBundle.loadString(_labelsAsset);
      final interpreter = Interpreter.fromBuffer(
        modelData.buffer.asUint8List(
          modelData.offsetInBytes,
          modelData.lengthInBytes,
        ),
      );
      _interpreter = interpreter;
      final io = _ModelIo.read(interpreter);
      _io = io;
      _labels = parseLabels(labelsText);
      if (_labels.length != io.classCount) {
        throw StateError(
          'Dice labels (${_labels.length}) do not match the model classes '
          '(${io.classCount})',
        );
      }
      _isolateInterpreter = await IsolateInterpreter.create(
        address: interpreter.address,
      );

      final controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: defaultTargetPlatform == TargetPlatform.android
            ? ImageFormatGroup.yuv420
            : ImageFormatGroup.bgra8888,
      );
      _controller = controller;
      await controller.initialize();
      if (_disposed) {
        await _release();
        return;
      }
      _rotationDegrees = defaultTargetPlatform == TargetPlatform.android
          ? camera.sensorOrientation
          : 0;
      await controller.startImageStream(_onFrame);
      _streaming = true;
    } catch (_) {
      await _release();
    } finally {
      _starting = false;
    }
  }

  @override
  Future<void> stop() async {
    final controller = _controller;
    if (_disposed || controller == null || !_streaming) return;
    _streaming = false;
    try {
      await controller.stopImageStream();
    } catch (_) {
      // The camera may already be gone; nothing else to clean up here.
    }
  }

  /// Releases the camera, the interpreter and the stream. Safe to call more
  /// than once; after dispose, [start] and [stop] do nothing.
  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await _release();
    await _detections.close();
  }

  @override
  Widget? buildPreview() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return null;
    return CameraPreview(controller);
  }

  /// Stops the stream and frees the camera and the interpreter.
  Future<void> _release() async {
    await stop();
    final controller = _controller;
    _controller = null;
    _streaming = false;
    await controller?.dispose();
    await _isolateInterpreter?.close();
    _isolateInterpreter = null;
    _interpreter?.close();
    _interpreter = null;
    _io = null;
    _labels = const [];
  }

  void _onFrame(CameraImage image) {
    if (_busy || !_streaming || _disposed) return;
    final now = DateTime.now();
    final last = _lastFrame;
    if (last != null && now.difference(last) < _minFrameInterval) return;
    final io = _io;
    final isolateInterpreter = _isolateInterpreter;
    if (io == null || isolateInterpreter == null) return;

    _lastFrame = now;
    _busy = true;
    // Copy the planes now: the plugin may reuse its buffers after this call.
    final packet = FramePacket.fromCameraImage(
      image,
      rotationDegrees: _rotationDegrees,
      modelSize: io.inputSize,
    );
    unawaited(_process(packet, io, isolateInterpreter));
  }

  Future<void> _process(
    FramePacket packet,
    _ModelIo io,
    IsolateInterpreter isolateInterpreter,
  ) async {
    try {
      final input = await Isolate.run(() => packet.toModelInput());
      final output = allocateOutput(io.outputShape);
      await isolateInterpreter.runForMultipleInputs(
        [input.buffer],
        {0: output},
      );
      if (_disposed || !_streaming || _detections.isClosed) return;

      final rows = [
        for (final row in (output as List).first as List)
          toDoubles(row as List),
      ];
      _detections.add(
        parseYoloxOutput(
          rows: rows,
          geometry: packet.geometry,
          labels: _labels,
        ),
      );
    } catch (_) {
      // A bad frame is skipped silently; the next one may work.
    } finally {
      _busy = false;
    }
  }
}

/// Shape and type of the model's input and output tensors.
class _ModelIo {
  const _ModelIo({required this.inputSize, required this.outputShape});

  factory _ModelIo.read(Interpreter interpreter) {
    final input = interpreter.getInputTensor(0);
    final shape = input.shape;
    if (shape.length != 4 ||
        shape[0] != 1 ||
        shape[1] != shape[2] ||
        shape[3] != 3) {
      throw StateError('Unexpected dice model input shape: $shape');
    }
    if (input.type != TensorType.float32) {
      throw StateError('Unsupported dice model input type: ${input.type}');
    }
    final outputs = interpreter.getOutputTensors();
    if (outputs.length != 1) {
      throw StateError('Expected 1 detection output, got ${outputs.length}');
    }
    final output = outputs.first;
    final outShape = output.shape;
    if (output.type != TensorType.float32 ||
        outShape.length != 3 ||
        outShape[0] != 1 ||
        outShape[2] <= yoloxBoxColumns) {
      throw StateError(
        'Unexpected dice model output: $outShape ${output.type}',
      );
    }
    return _ModelIo(inputSize: shape[1], outputShape: outShape);
  }

  /// Square input side in pixels.
  final int inputSize;

  /// `[1, N, 5 + classes]`.
  final List<int> outputShape;

  /// Number of class probabilities per row.
  int get classCount => outputShape[2] - yoloxBoxColumns;
}

/// Columns per output row: cx, cy, w, h, objectness, then the class probs.
@visibleForTesting
const yoloxBoxColumns = 5;

/// Camera frame copied into plain typed data so it can cross into an isolate.
class FramePacket {
  const FramePacket({
    required this.width,
    required this.height,
    required this.isYuv,
    required this.planes,
    required this.rowStrides,
    required this.pixelStrides,
    required this.rotationDegrees,
    required this.modelSize,
  });

  factory FramePacket.fromCameraImage(
    CameraImage image, {
    required int rotationDegrees,
    required int modelSize,
  }) {
    final isYuv = image.format.group == ImageFormatGroup.yuv420;
    return FramePacket(
      width: image.width,
      height: image.height,
      isYuv: isYuv,
      planes: [for (final p in image.planes) Uint8List.fromList(p.bytes)],
      rowStrides: [for (final p in image.planes) p.bytesPerRow],
      pixelStrides: [for (final p in image.planes) p.bytesPerPixel ?? 1],
      rotationDegrees: rotationDegrees,
      modelSize: modelSize,
    );
  }

  final int width;
  final int height;
  final bool isYuv;

  /// YUV420: Y, U, V planes. BGRA: one interleaved plane.
  final List<Uint8List> planes;
  final List<int> rowStrides;
  final List<int> pixelStrides;
  final int rotationDegrees;
  final int modelSize;

  /// Where the upright frame sits in the model input.
  LetterboxGeometry get geometry => LetterboxGeometry.forFrame(
    width: width,
    height: height,
    rotationDegrees: rotationDegrees,
    size: modelSize,
  );

  /// Converts the frame to a letterboxed BGR model input (raw 0..255).
  Float32List toModelInput() {
    final bgr = isYuv
        ? yuv420ToBgr(
            width: width,
            height: height,
            y: planes[0],
            u: planes[1],
            v: planes[2],
            yRowStride: rowStrides[0],
            uvRowStride: rowStrides[1],
            uvPixelStride: pixelStrides[1],
          )
        : bgraToBgr(
            width: width,
            height: height,
            bytes: planes[0],
            rowStride: rowStrides[0],
          );
    return letterboxBgr(
      bgr: bgr,
      width: width,
      height: height,
      rotationDegrees: rotationDegrees,
      size: modelSize,
    );
  }
}

/// Parses the labels file: one label per non-empty line.
@visibleForTesting
List<String> parseLabels(String text) => [
  for (final line in text.split('\n'))
    if (line.trim().isNotEmpty) line.trim(),
];

/// Allocates a nested list matching an output tensor shape.
@visibleForTesting
Object allocateOutput(List<int> shape) {
  if (shape.length == 1) return List<double>.filled(shape[0], 0);
  final rest = shape.sublist(1);
  return List.generate(shape[0], (_) => allocateOutput(rest));
}

/// Converts a nested list of numbers into doubles.
@visibleForTesting
List<double> toDoubles(List values) => [
  for (final v in values) (v as num).toDouble(),
];

/// Quarter turns clockwise for a rotation in degrees (any multiple of 90).
int _quarterTurns(int rotationDegrees) =>
    (((rotationDegrees % 360) + 360) % 360) ~/ 90;

/// Placement of an upright frame inside the square model input.
@visibleForTesting
class LetterboxGeometry {
  const LetterboxGeometry({
    required this.frameWidth,
    required this.frameHeight,
    required this.size,
  });

  /// Geometry of a [width] x [height] frame rotated clockwise by
  /// [rotationDegrees] (0, 90, 180 or 270) and fitted into [size].
  factory LetterboxGeometry.forFrame({
    required int width,
    required int height,
    required int rotationDegrees,
    required int size,
  }) {
    final swap = _quarterTurns(rotationDegrees).isOdd;
    return LetterboxGeometry(
      frameWidth: swap ? height : width,
      frameHeight: swap ? width : height,
      size: size,
    );
  }

  /// Upright frame width in pixels.
  final int frameWidth;

  /// Upright frame height in pixels.
  final int frameHeight;

  /// Model input side in pixels.
  final int size;

  /// Pixels of model input per pixel of upright frame.
  double get scale => math.min(size / frameWidth, size / frameHeight);
}

/// Value used for the letterbox padding.
const _letterboxFill = 114.0;

/// Source taps for one axis of a bilinear resize, computed as OpenCV
/// `cv2.resize(..., INTER_LINEAR)` does: `src = (dst + 0.5) * srcLength /
/// outLength - 0.5`, clamped to the frame, then the two neighbours `lo` and
/// `hi` with weight `frac` on `hi`.
({Int32List lo, Int32List hi, Float64List frac}) _bilinearTaps({
  required int outLength,
  required int srcLength,
}) {
  final lo = Int32List(outLength);
  final hi = Int32List(outLength);
  final frac = Float64List(outLength);
  final ratio = srcLength / outLength;
  for (var i = 0; i < outLength; i++) {
    final src = math.min(
      math.max((i + 0.5) * ratio - 0.5, 0.0),
      srcLength - 1.0,
    );
    final x0 = src.floor();
    lo[i] = x0;
    hi[i] = math.min(x0 + 1, srcLength - 1);
    frac[i] = src - x0;
  }
  return (lo: lo, hi: hi, frac: frac);
}

/// Rotates a camera frame upright, scales it to fit a square of [size] with
/// its top-left corner at (0, 0), and fills the rest with 114. The resize is
/// bilinear with OpenCV INTER_LINEAR semantics (the same as YOLOX training
/// and the Python evaluation). Output is BGR, row-major, raw 0..255 as float32.
@visibleForTesting
Float32List letterboxBgr({
  required Uint8List bgr,
  required int width,
  required int height,
  required int rotationDegrees,
  required int size,
}) {
  final geometry = LetterboxGeometry.forFrame(
    width: width,
    height: height,
    rotationDegrees: rotationDegrees,
    size: size,
  );
  final upWidth = geometry.frameWidth;
  final upHeight = geometry.frameHeight;
  // Truncated like YOLOX's int(w * r), not rounded.
  final fitWidth = math.min(
    size,
    math.max(1, (upWidth * geometry.scale).floor()),
  );
  final fitHeight = math.min(
    size,
    math.max(1, (upHeight * geometry.scale).floor()),
  );
  final quarterTurns = _quarterTurns(rotationDegrees);
  final columns = _bilinearTaps(outLength: fitWidth, srcLength: upWidth);
  final rows = _bilinearTaps(outLength: fitHeight, srcLength: upHeight);

  // Raw frame byte index of an upright frame pixel.
  int rawIndex(int ux, int uy) {
    final int sx;
    final int sy;
    switch (quarterTurns) {
      case 1:
        sx = uy;
        sy = height - 1 - ux;
      case 2:
        sx = width - 1 - ux;
        sy = height - 1 - uy;
      case 3:
        sx = width - 1 - uy;
        sy = ux;
      default:
        sx = ux;
        sy = uy;
    }
    return (sy * width + sx) * 3;
  }

  final out = Float32List(size * size * 3)
    ..fillRange(0, size * size * 3, _letterboxFill);
  for (var oy = 0; oy < fitHeight; oy++) {
    final y0 = rows.lo[oy];
    final y1 = rows.hi[oy];
    final fy = rows.frac[oy];
    for (var ox = 0; ox < fitWidth; ox++) {
      final x0 = columns.lo[ox];
      final x1 = columns.hi[ox];
      final fx = columns.frac[ox];
      final i00 = rawIndex(x0, y0);
      final i10 = rawIndex(x1, y0);
      final i01 = rawIndex(x0, y1);
      final i11 = rawIndex(x1, y1);
      final o = (oy * size + ox) * 3;
      for (var c = 0; c < 3; c++) {
        final top = bgr[i00 + c] + (bgr[i10 + c] - bgr[i00 + c]) * fx;
        final bottom = bgr[i01 + c] + (bgr[i11 + c] - bgr[i01 + c]) * fx;
        out[o + c] = top + (bottom - top) * fy;
      }
    }
  }
  return out;
}

/// YUV420 (Android, with strides) to packed BGR.
@visibleForTesting
Uint8List yuv420ToBgr({
  required int width,
  required int height,
  required Uint8List y,
  required Uint8List u,
  required Uint8List v,
  required int yRowStride,
  required int uvRowStride,
  required int uvPixelStride,
}) {
  final out = Uint8List(width * height * 3);
  var o = 0;
  for (var row = 0; row < height; row++) {
    for (var col = 0; col < width; col++) {
      final yValue = y[row * yRowStride + col];
      final uvIndex = (row >> 1) * uvRowStride + (col >> 1) * uvPixelStride;
      final uValue = u[uvIndex] - 128;
      final vValue = v[uvIndex] - 128;
      final r = yValue + ((359 * vValue) >> 8);
      final g = yValue - ((88 * uValue + 183 * vValue) >> 8);
      final b = yValue + ((454 * uValue) >> 8);
      out[o++] = _clampByte(b);
      out[o++] = _clampByte(g);
      out[o++] = _clampByte(r);
    }
  }
  return out;
}

/// BGRA8888 (iOS) to packed BGR, dropping alpha.
@visibleForTesting
Uint8List bgraToBgr({
  required int width,
  required int height,
  required Uint8List bytes,
  required int rowStride,
}) {
  final out = Uint8List(width * height * 3);
  var o = 0;
  for (var row = 0; row < height; row++) {
    for (var col = 0; col < width; col++) {
      final i = row * rowStride + col * 4;
      out[o++] = bytes[i];
      out[o++] = bytes[i + 1];
      out[o++] = bytes[i + 2];
    }
  }
  return out;
}

/// Box corners in model input pixels, used for overlap tests.
@visibleForTesting
final class CornerBox {
  /// Creates a box from its corners.
  const CornerBox({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  final double left;
  final double top;
  final double right;
  final double bottom;

  /// Area in square pixels; zero or less for an empty box.
  double get area => (right - left) * (bottom - top);
}

/// Intersection over union of two boxes, 0 when they do not overlap.
@visibleForTesting
double iou(CornerBox a, CornerBox b) {
  final interWidth = math.max(
    0.0,
    math.min(a.right, b.right) - math.max(a.left, b.left),
  );
  final interHeight = math.max(
    0.0,
    math.min(a.bottom, b.bottom) - math.max(a.top, b.top),
  );
  final intersection = interWidth * interHeight;
  final union = a.area + b.area - intersection;
  return union <= 0 ? 0 : intersection / union;
}

/// Greedy class-agnostic non-maximum suppression. Returns the indices of the
/// kept boxes, highest score first: a box is dropped when it overlaps a kept
/// box with an IoU above [iouThreshold]. At most [maxKeep] boxes are kept.
@visibleForTesting
List<int> nonMaxSuppression(
  List<CornerBox> boxes,
  List<double> scores, {
  double iouThreshold = TfliteDiceDetector.nmsIouThreshold,
  int maxKeep = TfliteDiceDetector.maxDetections,
}) {
  final order = [for (var i = 0; i < boxes.length; i++) i]
    ..sort((a, b) => scores[b].compareTo(scores[a]));
  final kept = <int>[];
  for (final i in order) {
    if (kept.length >= maxKeep) break;
    var overlaps = false;
    for (final k in kept) {
      if (iou(boxes[i], boxes[k]) > iouThreshold) {
        overlaps = true;
        break;
      }
    }
    if (!overlaps) kept.add(i);
  }
  return kept;
}

/// Parses one YOLOX output `[N, 11]` (cx, cy, w, h, objectness, 6 class
/// probabilities, all in model input pixels except the probabilities).
///
/// Score is objectness x best class probability; rows below
/// [TfliteDiceDetector.minScore] and classes that do not map to a die value
/// are dropped, then overlaps are suppressed in input space. Surviving boxes
/// are mapped back to 0..1 of the upright frame.
@visibleForTesting
List<DetectedDie> parseYoloxOutput({
  required List<List<double>> rows,
  required LetterboxGeometry geometry,
  required List<String> labels,
  double threshold = TfliteDiceDetector.minScore,
}) {
  final candidates = <_Candidate>[];
  for (final row in rows) {
    // Each row is cx, cy, w, h, objectness, then one probability per label.
    if (row.length != yoloxBoxColumns + labels.length) continue;
    var bestProb = 0.0;
    var bestClass = -1;
    for (var c = yoloxBoxColumns; c < row.length; c++) {
      if (row[c] > bestProb) {
        bestProb = row[c];
        bestClass = c - yoloxBoxColumns;
      }
    }
    final score = row[4] * bestProb;
    if (score < threshold) continue;
    final value = valueForClass(bestClass, labels);
    if (value == null) continue;
    final halfWidth = row[2] / 2;
    final halfHeight = row[3] / 2;
    candidates.add(
      _Candidate(
        value: value,
        score: score,
        box: CornerBox(
          left: row[0] - halfWidth,
          top: row[1] - halfHeight,
          right: row[0] + halfWidth,
          bottom: row[1] + halfHeight,
        ),
      ),
    );
  }

  final kept = nonMaxSuppression(
    [for (final c in candidates) c.box],
    [for (final c in candidates) c.score],
  );

  final scale = geometry.scale;
  final dice = <DetectedDie>[];
  for (final i in kept) {
    final c = candidates[i];
    final left = _clamp01(c.box.left / scale / geometry.frameWidth);
    final top = _clamp01(c.box.top / scale / geometry.frameHeight);
    final right = _clamp01(c.box.right / scale / geometry.frameWidth);
    final bottom = _clamp01(c.box.bottom / scale / geometry.frameHeight);
    final width = right - left;
    final height = bottom - top;
    if (width <= 0 || height <= 0) continue;
    dice.add(
      DetectedDie(
        value: c.value,
        box: DieBox(left: left, top: top, width: width, height: height),
        confidence: c.score,
      ),
    );
  }
  return dice;
}

/// A row that passed the score and label checks, before suppression.
final class _Candidate {
  const _Candidate({
    required this.value,
    required this.score,
    required this.box,
  });

  final int value;
  final double score;
  final CornerBox box;
}

/// Die value (1..6) for a class index, read from the label at that index.
@visibleForTesting
int? valueForClass(int classIndex, List<String> labels) {
  if (classIndex < 0 || classIndex >= labels.length) return null;
  final value = int.tryParse(labels[classIndex].trim());
  if (value == null || value < 1 || value > 6) return null;
  return value;
}

int _clampByte(int value) => value < 0 ? 0 : (value > 255 ? 255 : value);

double _clamp01(double value) => value < 0 ? 0.0 : (value > 1 ? 1.0 : value);
