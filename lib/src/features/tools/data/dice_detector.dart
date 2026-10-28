import 'package:flutter/widgets.dart';

import '../domain/dice_detection.dart';

/// Reads dice from the camera on the device. Implementations never store frames.
abstract class DiceDetector {
  /// False when the device has no camera, permission is denied, or the model is not bundled.
  Future<bool> isAvailable();

  /// Detections per processed frame, already in normalised coordinates.
  Stream<List<DetectedDie>> get detections;

  Future<void> start();

  Future<void> stop();

  Future<void> dispose();

  /// Camera preview; null until [start] completes.
  Widget? buildPreview();
}
