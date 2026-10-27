import 'package:flutter_test/flutter_test.dart';
import 'package:sato_wiki/src/features/tools/domain/dice_detection.dart';

DetectedDie _die(
  int value,
  double centerX,
  double centerY, {
  double confidence = 0.95,
  double size = 0.2,
}) {
  return DetectedDie(
    value: value,
    box: DieBox(
      left: centerX - size / 2,
      top: centerY - size / 2,
      width: size,
      height: size,
    ),
    confidence: confidence,
  );
}

void main() {
  group('DieBox', () {
    test('centre is the middle of the box', () {
      const box = DieBox(left: 0.1, top: 0.2, width: 0.4, height: 0.2);
      expect(box.centerX, closeTo(0.3, 1e-12));
      expect(box.centerY, closeTo(0.3, 1e-12));
    });
  });

  group('orderByPosition', () {
    test('empty input gives an empty list', () {
      expect(orderByPosition(const []), isEmpty);
    });

    test('two rows with jitter are read top to bottom, left to right', () {
      // Values are deliberately not in ascending order, so a sort by value
      // would fail this test.
      final dice = [
        _die(5, 0.22, 0.61),
        _die(6, 0.72, 0.19),
        _die(2, 0.81, 0.63),
        _die(1, 0.11, 0.21),
        _die(3, 0.41, 0.18),
      ];

      final ordered = orderByPosition(dice);

      expect([for (final die in ordered) die.value], [1, 3, 6, 5, 2]);
    });

    test('small vertical jitter inside a row does not split it', () {
      final dice = [
        _die(4, 0.70, 0.30),
        _die(2, 0.30, 0.36),
        _die(1, 0.50, 0.27),
        _die(3, 0.10, 0.33),
      ];

      expect(
        [for (final die in orderByPosition(dice)) die.value],
        [3, 2, 1, 4],
      );
    });

    test('a die far below the row starts a new row', () {
      final dice = [
        _die(6, 0.80, 0.20),
        _die(1, 0.20, 0.80),
        _die(2, 0.20, 0.20),
      ];

      expect([for (final die in orderByPosition(dice)) die.value], [2, 6, 1]);
    });

    test('never sorts by value', () {
      final dice = [_die(1, 0.9, 0.5), _die(2, 0.1, 0.5), _die(3, 0.5, 0.5)];

      expect([for (final die in orderByPosition(dice)) die.value], [2, 3, 1]);
    });
  });

  group('DiceThrowCandidate', () {
    test('values follow the given order', () {
      final candidate = DiceThrowCandidate([
        _die(4, 0.1, 0.5),
        _die(1, 0.5, 0.5),
      ]);
      expect(candidate.values, [4, 1]);
    });

    test('needsReview is false when every die is at least 0.85', () {
      final candidate = DiceThrowCandidate([
        _die(2, 0.1, 0.5, confidence: 0.85),
        _die(6, 0.5, 0.5, confidence: 0.99),
      ]);
      expect(candidate.needsReview, isFalse);
    });

    test('needsReview is true when any die is below 0.85', () {
      final candidate = DiceThrowCandidate([
        _die(2, 0.1, 0.5, confidence: 0.99),
        _die(6, 0.5, 0.5, confidence: 0.7),
      ]);
      expect(candidate.needsReview, isTrue);
    });
  });

  group('DiceStabilityTracker', () {
    List<DetectedDie> frame(List<DetectedDie> dice) => dice;

    final still = [_die(3, 0.2, 0.3), _die(5, 0.5, 0.3), _die(1, 0.8, 0.7)];

    test('emits after requiredStableFrames identical frames', () {
      final tracker = DiceStabilityTracker();
      expect(tracker.addFrame(frame(still)), isNull);
      expect(tracker.addFrame(frame(still)), isNull);
      expect(tracker.addFrame(frame(still)), isNull);

      final candidate = tracker.addFrame(frame(still));

      expect(candidate, isNotNull);
      expect(candidate!.values, [3, 5, 1]);
    });

    test('emits once per still scene', () {
      final tracker = DiceStabilityTracker();
      DiceThrowCandidate? first;
      for (var i = 0; i < 4; i++) {
        first = tracker.addFrame(frame(still));
      }
      expect(first, isNotNull);

      for (var i = 0; i < 10; i++) {
        expect(tracker.addFrame(frame(still)), isNull);
      }
    });

    test('re-arms after the value of a die changes', () {
      final tracker = DiceStabilityTracker();
      for (var i = 0; i < 4; i++) {
        tracker.addFrame(frame(still));
      }

      final moved = [_die(4, 0.2, 0.3), _die(5, 0.5, 0.3), _die(1, 0.8, 0.7)];
      for (var i = 0; i < 3; i++) {
        expect(tracker.addFrame(frame(moved)), isNull);
      }
      expect(tracker.addFrame(frame(moved))!.values, [4, 5, 1]);
    });

    test('re-arms after a centre moves more than maxCenterShift', () {
      final tracker = DiceStabilityTracker();
      for (var i = 0; i < 4; i++) {
        tracker.addFrame(frame(still));
      }

      final nudged = [
        _die(3, 0.2 + 0.01, 0.3),
        _die(5, 0.5, 0.3),
        _die(1, 0.8, 0.7),
      ];
      expect(tracker.addFrame(frame(nudged)), isNull);
      expect(tracker.progress, 1, reason: 'a small shift keeps the scene');

      final shifted = [
        _die(3, 0.2 + 0.1, 0.3),
        _die(5, 0.5, 0.3),
        _die(1, 0.8, 0.7),
      ];
      for (var i = 0; i < 3; i++) {
        expect(tracker.addFrame(frame(shifted)), isNull);
      }
      expect(tracker.addFrame(frame(shifted)), isNotNull);
    });

    test('drops dice below minConfidence and ignores them for the scene', () {
      final tracker = DiceStabilityTracker();
      final noisy = [
        _die(3, 0.2, 0.3),
        _die(5, 0.5, 0.3),
        _die(6, 0.9, 0.9, confidence: 0.3),
      ];

      for (var i = 0; i < 3; i++) {
        expect(tracker.addFrame(frame(noisy)), isNull);
      }
      final candidate = tracker.addFrame(frame(noisy));

      expect(candidate, isNotNull);
      expect(candidate!.values, [3, 5]);
    });

    test('frames with no dice reset the count', () {
      final tracker = DiceStabilityTracker();
      tracker.addFrame(frame(still));
      tracker.addFrame(frame(still));
      tracker.addFrame(frame(still));

      expect(tracker.addFrame(frame(const [])), isNull);
      expect(tracker.progress, 0);

      for (var i = 0; i < 3; i++) {
        expect(tracker.addFrame(frame(still)), isNull);
      }
      expect(tracker.addFrame(frame(still)), isNotNull);
    });

    test('more than maxDice dice reset the count', () {
      final tracker = DiceStabilityTracker(maxDice: 5);
      final six = [for (var i = 0; i < 6; i++) _die(1, 0.1 + i * 0.15, 0.5)];

      tracker.addFrame(frame(still));
      tracker.addFrame(frame(still));
      expect(tracker.addFrame(frame(six)), isNull);
      expect(tracker.progress, 0);

      for (var i = 0; i < 3; i++) {
        expect(tracker.addFrame(frame(still)), isNull);
      }
      expect(tracker.addFrame(frame(still)), isNotNull);
    });

    test('progress rises with each stable frame and is 1 after emitting', () {
      final tracker = DiceStabilityTracker();
      expect(tracker.progress, 0);

      tracker.addFrame(frame(still));
      expect(tracker.progress, closeTo(0.25, 1e-12));

      tracker.addFrame(frame(still));
      expect(tracker.progress, closeTo(0.5, 1e-12));

      tracker.addFrame(frame(still));
      tracker.addFrame(frame(still));
      expect(tracker.progress, 1);
    });

    test('reset clears the count and the emitted flag', () {
      final tracker = DiceStabilityTracker();
      for (var i = 0; i < 4; i++) {
        tracker.addFrame(frame(still));
      }
      tracker.reset();

      expect(tracker.progress, 0);
      for (var i = 0; i < 3; i++) {
        expect(tracker.addFrame(frame(still)), isNull);
      }
      expect(tracker.addFrame(frame(still)), isNotNull);
    });

    test('a low-confidence reading that needs review still emits', () {
      final tracker = DiceStabilityTracker();
      final unsure = [_die(2, 0.3, 0.4, confidence: 0.7), _die(4, 0.6, 0.4)];
      DiceThrowCandidate? candidate;
      for (var i = 0; i < 4; i++) {
        candidate = tracker.addFrame(frame(unsure));
      }

      expect(candidate, isNotNull);
      expect(candidate!.needsReview, isTrue);
    });
  });
}
