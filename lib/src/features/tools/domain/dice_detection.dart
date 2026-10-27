// Die detections, throw ordering and stability tracking for the dice tool.
// Pure Dart, no Flutter imports.

/// Box of a detected die, normalised to 0..1 of the camera frame.
final class DieBox {
  /// Creates a box from its top-left corner and size.
  const DieBox({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  /// Left edge, 0..1 of the frame width.
  final double left;

  /// Top edge, 0..1 of the frame height.
  final double top;

  /// Width, 0..1 of the frame width.
  final double width;

  /// Height, 0..1 of the frame height.
  final double height;

  /// Horizontal centre.
  double get centerX => left + width / 2;

  /// Vertical centre.
  double get centerY => top + height / 2;
}

/// One die read by the detector.
final class DetectedDie {
  /// Creates a detection with its face value, box and confidence (0..1).
  const DetectedDie({
    required this.value,
    required this.box,
    required this.confidence,
  });

  /// Face value, 1..6.
  final int value;

  /// Where the die is in the frame.
  final DieBox box;

  /// Detector confidence, 0..1.
  final double confidence;
}

/// Orders dice by position, never by value: rows top to bottom (a die joins a
/// row when its centre is within half the mean box height of the row), left to
/// right inside a row.
List<DetectedDie> orderByPosition(List<DetectedDie> dice) {
  if (dice.isEmpty) {
    return [];
  }

  var heightSum = 0.0;
  for (final die in dice) {
    heightSum += die.box.height;
  }
  final halfRow = heightSum / dice.length / 2;

  final byHeight = List.of(dice)
    ..sort((a, b) => a.box.centerY.compareTo(b.box.centerY));

  final rows = <List<DetectedDie>>[];
  final rowCentres = <double>[];
  for (final die in byHeight) {
    final last = rows.isEmpty ? -1 : rows.length - 1;
    if (last >= 0 && (die.box.centerY - rowCentres[last]).abs() <= halfRow) {
      rows[last].add(die);
      rowCentres[last] = _meanCenterY(rows[last]);
    } else {
      rows.add([die]);
      rowCentres.add(die.box.centerY);
    }
  }

  return [
    for (final row in rows)
      ...(List.of(row)..sort((a, b) => a.box.centerX.compareTo(b.box.centerX))),
  ];
}

double _meanCenterY(List<DetectedDie> row) {
  var sum = 0.0;
  for (final die in row) {
    sum += die.box.centerY;
  }

  return sum / row.length;
}

/// A throw ready to record.
final class DiceThrowCandidate {
  /// Creates a throw from dice that are already ordered by position.
  const DiceThrowCandidate(this.dice);

  /// Confidence below this value asks the user to check the reading.
  static const reviewThreshold = 0.85;

  /// The dice, in position order.
  final List<DetectedDie> dice;

  /// Face values in position order.
  List<int> get values => [for (final die in dice) die.value];

  /// True when any die was read with confidence below [reviewThreshold].
  bool get needsReview => dice.any((die) => die.confidence < reviewThreshold);
}

/// Emits a throw when the same dice stay still for [requiredStableFrames] frames.
final class DiceStabilityTracker {
  /// Creates a tracker. Defaults match the dice sandbox.
  DiceStabilityTracker({
    this.requiredStableFrames = 4,
    this.minConfidence = 0.5,
    this.maxCenterShift = 0.04,
    this.maxDice = 5,
  });

  /// Consecutive identical frames needed before a throw is emitted.
  final int requiredStableFrames;

  /// Detections below this confidence are ignored.
  final double minConfidence;

  /// Largest centre movement, in frame units, that still counts as still.
  final double maxCenterShift;

  /// Frames with more dice than this reset the count.
  final int maxDice;

  List<DetectedDie>? _scene;
  int _stableFrames = 0;
  bool _emitted = false;

  /// Feed one frame; returns a candidate once per still scene. Dice under
  /// [minConfidence] are dropped; frames with 0 or more than [maxDice] dice reset the count.
  /// After emitting, nothing is emitted again until the scene changes (count,
  /// a value, or a centre moving more than [maxCenterShift]).
  DiceThrowCandidate? addFrame(List<DetectedDie> frame) {
    final dice = [
      for (final die in frame)
        if (die.confidence >= minConfidence) die,
    ];

    if (dice.isEmpty || dice.length > maxDice) {
      reset();

      return null;
    }

    final scene = _scene;
    if (scene == null || !_sameScene(scene, dice)) {
      _scene = dice;
      _stableFrames = 1;
      _emitted = false;
    } else {
      _stableFrames++;
    }

    if (!_emitted && _stableFrames >= requiredStableFrames) {
      _emitted = true;

      return DiceThrowCandidate(orderByPosition(dice));
    }

    return null;
  }

  /// 0..1 progress toward the next capture (for the UI bar).
  double get progress {
    if (_emitted) {
      return 1;
    }
    final fraction = _stableFrames / requiredStableFrames;

    return fraction.clamp(0.0, 1.0);
  }

  /// Forgets the current scene and starts counting again.
  void reset() {
    _scene = null;
    _stableFrames = 0;
    _emitted = false;
  }

  bool _sameScene(List<DetectedDie> reference, List<DetectedDie> current) {
    if (reference.length != current.length) {
      return false;
    }

    final used = List<bool>.filled(reference.length, false);
    for (final die in current) {
      var matched = false;
      for (var i = 0; i < reference.length; i++) {
        if (used[i]) {
          continue;
        }
        final other = reference[i];
        if (other.value == die.value &&
            (other.box.centerX - die.box.centerX).abs() <= maxCenterShift &&
            (other.box.centerY - die.box.centerY).abs() <= maxCenterShift) {
          used[i] = true;
          matched = true;
          break;
        }
      }
      if (!matched) {
        return false;
      }
    }

    return true;
  }
}
