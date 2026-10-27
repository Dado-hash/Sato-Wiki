import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sato_wiki/src/features/tools/data/tflite_dice_detector.dart';

/// One YOLOX output row: cx, cy, w, h, objectness, then the class probs.
List<double> _row({
  required double cx,
  required double cy,
  required double w,
  required double h,
  required double objectness,
  required List<double> classes,
}) => [cx, cy, w, h, objectness, ...classes];

/// Class probabilities with [face] (0-based) at [prob] and the rest at 0.
List<double> _onlyClass(int face, double prob) => [
  for (var i = 0; i < 6; i++) i == face ? prob : 0.0,
];

CornerBox _box(double left, double top, double right, double bottom) =>
    CornerBox(left: left, top: top, right: right, bottom: bottom);

const _grey = 114;

/// Compares float32 output with expected values to 1e-4.
void _expectPixels(Float32List actual, List<double> expected) {
  expect(actual, hasLength(expected.length));
  for (var i = 0; i < expected.length; i++) {
    expect(actual[i], closeTo(expected[i], 1e-4), reason: 'element $i');
  }
}

void main() {
  group('LetterboxGeometry', () {
    test('scales the upright frame to fit the square', () {
      final geometry = LetterboxGeometry.forFrame(
        width: 4,
        height: 2,
        rotationDegrees: 0,
        size: 8,
      );
      expect(geometry.frameWidth, 4);
      expect(geometry.frameHeight, 2);
      expect(geometry.scale, 2);
    });

    test('swaps the frame size for a quarter turn', () {
      final geometry = LetterboxGeometry.forFrame(
        width: 4,
        height: 2,
        rotationDegrees: 90,
        size: 8,
      );
      expect(geometry.frameWidth, 2);
      expect(geometry.frameHeight, 4);
      expect(geometry.scale, 2);
    });
  });

  group('letterboxBgr', () {
    // 2x1 frame: pixel A (B=1, G=2, R=3) then pixel B (B=4, G=5, R=6).
    final bgr = Uint8List.fromList([1, 2, 3, 4, 5, 6]);

    // Scale 2 in both axes, so every frame row and column is a bilinear mix
    // of its neighbours. With src = (dst + 0.5) / 2 - 0.5 and clamping:
    // dst 0 -> A, dst 1 -> 0.75 A + 0.25 B, dst 2 -> 0.25 A + 0.75 B, dst 3 -> B.
    final mixA25 = <double>[1.75, 2.75, 3.75];
    final mixA75 = <double>[3.25, 4.25, 5.25];
    final pixA = <double>[1, 2, 3];
    final pixB = <double>[4, 5, 6];
    final grey = List<double>.filled(6, _grey.toDouble());

    test('places the frame top-left, pads with 114, keeps BGR order', () {
      final out = letterboxBgr(
        bgr: bgr,
        width: 2,
        height: 1,
        rotationDegrees: 0,
        size: 4,
      );

      // The frame covers 4x2 pixels at the top, the rest is padding.
      final rowA = <double>[...pixA, ...mixA25, ...mixA75, ...pixB];
      final pad = List<double>.filled(12, _grey.toDouble());
      _expectPixels(out, [...rowA, ...rowA, ...pad, ...pad]);
    });

    test('rotates a quarter turn clockwise before fitting', () {
      final out = letterboxBgr(
        bgr: bgr,
        width: 2,
        height: 1,
        rotationDegrees: 90,
        size: 4,
      );

      // Upright frame is 1x2 with pixel A on top, B below. Each row is two
      // resized pixels followed by two padding pixels.
      final a = <double>[...pixA, ...pixA, ...grey];
      final mid25 = <double>[...mixA25, ...mixA25, ...grey];
      final mid75 = <double>[...mixA75, ...mixA75, ...grey];
      final b = <double>[...pixB, ...pixB, ...grey];
      _expectPixels(out, [...a, ...mid25, ...mid75, ...b]);
    });

    test('rotates a three-quarter turn with B on top', () {
      final out = letterboxBgr(
        bgr: bgr,
        width: 2,
        height: 1,
        rotationDegrees: 270,
        size: 4,
      );

      // Upright frame is 1x2 with B on top. The mixes are B-first: 0.75 B +
      // 0.25 A, then 0.25 B + 0.75 A.
      final b = <double>[...pixB, ...pixB, ...grey];
      final mid25 = <double>[3.25, 4.25, 5.25, 3.25, 4.25, 5.25, ...grey];
      final mid75 = <double>[1.75, 2.75, 3.75, 1.75, 2.75, 3.75, ...grey];
      final a = <double>[...pixA, ...pixA, ...grey];
      _expectPixels(out, [...b, ...mid25, ...mid75, ...a]);
    });

    test('resizes a 4x2 gradient with OpenCV INTER_LINEAR weights', () {
      // Frame pixel (x, y) has B = 10x + 100y, G = R = 0. Scale 0.75 gives a
      // 3x1 image (floor(4 * 0.75), floor(2 * 0.75)) in a 3x3 square.
      // Per axis, src = (dst + 0.5) * src_len / dst_len - 0.5, clamped:
      //   x: src_len / dst_len = 4 / 3, so src = 1/6, 3/2, 17/6
      //   y: src_len / dst_len = 2 / 1, so src = 1/2
      // At y = 1/2 the value is the mean of rows 0 and 1, so B(x) = 50 + 10x
      // for integer x. Then x = 1/6 gives 50 + 10/6 = 155/3, x = 3/2 gives 65,
      // and x = 17/6 gives 50 + 170/6 = 235/3 (the taps blend the x-neighbours
      // with weights 5/6 and 1/6, so the linear form carries through).
      final gradient = Uint8List.fromList([
        0, 0, 0, 10, 0, 0, 20, 0, 0, 30, 0, 0, //
        100, 0, 0, 110, 0, 0, 120, 0, 0, 130, 0, 0,
      ]);
      final out = letterboxBgr(
        bgr: gradient,
        width: 4,
        height: 2,
        rotationDegrees: 0,
        size: 3,
      );

      final row0 = <double>[155 / 3, 0, 0, 65, 0, 0, 235 / 3, 0, 0];
      final pad = List<double>.filled(9, _grey.toDouble());
      _expectPixels(out, [...row0, ...pad, ...pad]);
    });

    test('output is square of size x size x 3 floats', () {
      final out = letterboxBgr(
        bgr: Uint8List(3 * 5 * 7),
        width: 5,
        height: 7,
        rotationDegrees: 0,
        size: 416,
      );
      expect(out, hasLength(416 * 416 * 3));
      expect(out, isA<Float32List>());
    });
  });

  group('parseYoloxOutput', () {
    test('un-letterboxes boxes to 0..1 of the upright frame', () {
      // 200x100 frame in a 416 square: scale 2.08, image in the top 208 rows.
      final geometry = LetterboxGeometry.forFrame(
        width: 200,
        height: 100,
        rotationDegrees: 0,
        size: 416,
      );
      final dice = parseYoloxOutput(
        rows: [
          _row(
            cx: 104,
            cy: 52,
            w: 20.8,
            h: 10.4,
            objectness: 1,
            classes: _onlyClass(0, 0.95),
          ),
        ],
        geometry: geometry,
        labels: parseLabels('1\n2\n3\n4\n5\n6'),
      );

      expect(dice, hasLength(1));
      final die = dice.single;
      expect(die.value, 1);
      expect(die.confidence, closeTo(0.95, 1e-9));
      expect(die.box.left, closeTo(0.225, 1e-9));
      expect(die.box.top, closeTo(0.225, 1e-9));
      expect(die.box.width, closeTo(0.05, 1e-9));
      expect(die.box.height, closeTo(0.05, 1e-9));
    });

    test('score is objectness times the best class probability', () {
      final geometry = LetterboxGeometry.forFrame(
        width: 416,
        height: 416,
        rotationDegrees: 0,
        size: 416,
      );
      final labels = parseLabels('1\n2\n3\n4\n5\n6');
      final dice = parseYoloxOutput(
        rows: [
          _row(
            cx: 100,
            cy: 100,
            w: 40,
            h: 40,
            objectness: 0.5,
            classes: _onlyClass(5, 0.8),
          ),
        ],
        geometry: geometry,
        labels: labels,
      );

      expect(dice.single.value, 6);
      expect(dice.single.confidence, closeTo(0.4, 1e-9));
    });

    test('drops scores below 0.3 and keeps 0.3 itself', () {
      final geometry = LetterboxGeometry.forFrame(
        width: 416,
        height: 416,
        rotationDegrees: 0,
        size: 416,
      );
      final dice = parseYoloxOutput(
        rows: [
          _row(
            cx: 50,
            cy: 50,
            w: 20,
            h: 20,
            objectness: 1,
            classes: _onlyClass(0, 0.29),
          ),
          _row(
            cx: 200,
            cy: 200,
            w: 20,
            h: 20,
            objectness: 1,
            classes: _onlyClass(1, 0.3),
          ),
        ],
        geometry: geometry,
        labels: parseLabels('1\n2\n3\n4\n5\n6'),
      );

      expect(dice.map((d) => d.value), [2]);
      expect(dice.single.confidence, 0.3);
    });

    test('drops rows whose class does not map to a die face', () {
      final geometry = LetterboxGeometry.forFrame(
        width: 416,
        height: 416,
        rotationDegrees: 0,
        size: 416,
      );
      final dice = parseYoloxOutput(
        rows: [
          _row(
            cx: 50,
            cy: 50,
            w: 20,
            h: 20,
            objectness: 1,
            classes: _onlyClass(0, 0.9),
          ),
        ],
        geometry: geometry,
        labels: ['die', '2', '3', '4', '5', '6'],
      );

      expect(dice, isEmpty);
    });

    test('suppresses overlapping rows but keeps separate dice', () {
      final geometry = LetterboxGeometry.forFrame(
        width: 416,
        height: 416,
        rotationDegrees: 0,
        size: 416,
      );
      final dice = parseYoloxOutput(
        rows: [
          // Two boxes on the same die: IoU about 0.68, the weaker is dropped.
          _row(
            cx: 6,
            cy: 6,
            w: 10,
            h: 10,
            objectness: 1,
            classes: _onlyClass(0, 0.8),
          ),
          _row(
            cx: 5,
            cy: 5,
            w: 10,
            h: 10,
            objectness: 1,
            classes: _onlyClass(0, 0.9),
          ),
          // A second die further away is kept.
          _row(
            cx: 25,
            cy: 25,
            w: 10,
            h: 10,
            objectness: 1,
            classes: _onlyClass(3, 0.7),
          ),
        ],
        geometry: geometry,
        labels: parseLabels('1\n2\n3\n4\n5\n6'),
      );

      expect(dice.map((d) => d.value), [1, 4]);
      expect(dice.map((d) => d.confidence), [0.9, 0.7]);
    });

    test('clamps boxes to the frame and drops empty ones', () {
      final geometry = LetterboxGeometry.forFrame(
        width: 416,
        height: 416,
        rotationDegrees: 0,
        size: 416,
      );
      final dice = parseYoloxOutput(
        rows: [
          // Left edge at -5 (into the frame's left border) and top at 0.
          _row(
            cx: 5,
            cy: 100,
            w: 20,
            h: 20,
            objectness: 1,
            classes: _onlyClass(0, 0.9),
          ),
          // Only 2 of 20 pixels fall inside the 416 square.
          _row(
            cx: 415,
            cy: 300,
            w: 20,
            h: 20,
            objectness: 1,
            classes: _onlyClass(2, 0.9),
          ),
        ],
        geometry: geometry,
        labels: parseLabels('1\n2\n3\n4\n5\n6'),
      );

      expect(dice, hasLength(2));
      expect(dice[0].box.left, 0);
      expect(dice[0].box.width, closeTo(15 / 416, 1e-9));
      expect(dice[1].box.left + dice[1].box.width, 1);
    });

    test('ignores rows that are not 11 values long', () {
      final geometry = LetterboxGeometry.forFrame(
        width: 416,
        height: 416,
        rotationDegrees: 0,
        size: 416,
      );
      final dice = parseYoloxOutput(
        rows: [
          [50, 50, 20, 20, 1, 0.9, 0, 0, 0, 0],
        ],
        geometry: geometry,
        labels: parseLabels('1\n2\n3\n4\n5\n6'),
      );
      expect(dice, isEmpty);
    });
  });

  group('nonMaxSuppression', () {
    test('keeps the best of two overlapping boxes', () {
      final kept = nonMaxSuppression(
        [_box(0, 0, 10, 10), _box(1, 1, 11, 11)],
        [0.8, 0.9],
      );
      expect(kept, [1]);
    });

    test('keeps boxes that do not overlap, highest score first', () {
      final kept = nonMaxSuppression(
        [_box(0, 0, 10, 10), _box(20, 20, 30, 30), _box(40, 0, 50, 10)],
        [0.5, 0.7, 0.9],
      );
      expect(kept, [2, 1, 0]);
    });

    test('keeps at most maxKeep boxes', () {
      final boxes = [
        for (var i = 0; i < 12; i++) _box(i * 20.0, 0, i * 20.0 + 10, 10),
      ];
      final scores = [for (var i = 0; i < 12; i++) 1 - i / 100];
      expect(nonMaxSuppression(boxes, scores), hasLength(10));
      expect(nonMaxSuppression(boxes, scores, maxKeep: 3), [0, 1, 2]);
    });
  });

  group('iou', () {
    test('is 1 for identical boxes and 0 for disjoint ones', () {
      expect(iou(_box(0, 0, 10, 10), _box(0, 0, 10, 10)), 1);
      expect(iou(_box(0, 0, 10, 10), _box(20, 20, 30, 30)), 0);
    });

    test('measures partial overlap', () {
      // Intersection 9 x 9 = 81, union 100 + 100 - 81 = 119.
      expect(
        iou(_box(0, 0, 10, 10), _box(1, 1, 11, 11)),
        closeTo(81 / 119, 1e-9),
      );
    });
  });

  group('valueForClass', () {
    test('reads the label at the class index', () {
      final labels = parseLabels('1\n2\n3\n4\n5\n6');
      expect(valueForClass(0, labels), 1);
      expect(valueForClass(5, labels), 6);
      expect(valueForClass(6, labels), isNull);
      expect(valueForClass(-1, labels), isNull);
    });

    test('rejects labels that are not die faces', () {
      expect(valueForClass(0, ['die', '7']), isNull);
      expect(valueForClass(1, ['die', '7']), isNull);
    });
  });

  group('parseLabels', () {
    test('keeps non-empty trimmed lines in order', () {
      expect(parseLabels(' 1\r\n2\n\n3 \n'), ['1', '2', '3']);
    });
  });

  group('yuv420ToBgr', () {
    test('neutral chroma gives grey equal to luma', () {
      final bgr = yuv420ToBgr(
        width: 2,
        height: 2,
        y: Uint8List.fromList([0, 128, 255, 60]),
        u: Uint8List.fromList([128]),
        v: Uint8List.fromList([128]),
        yRowStride: 2,
        uvRowStride: 1,
        uvPixelStride: 1,
      );

      expect(bgr, [
        0, 0, 0, //
        128, 128, 128,
        255, 255, 255,
        60, 60, 60,
      ]);
    });

    test('honours row and pixel strides of the planes', () {
      // Y rows are padded to 4 bytes; chroma is interleaved (pixel stride 2).
      final bgr = yuv420ToBgr(
        width: 2,
        height: 2,
        y: Uint8List.fromList([10, 20, 99, 99, 30, 40, 99, 99]),
        u: Uint8List.fromList([128, 0, 128, 0]),
        v: Uint8List.fromList([128, 0, 128, 0]),
        yRowStride: 4,
        uvRowStride: 4,
        uvPixelStride: 2,
      );

      expect(bgr, [
        10, 10, 10, //
        20, 20, 20,
        30, 30, 30,
        40, 40, 40,
      ]);
    });

    test('red-heavy chroma pushes red up and green down, in BGR order', () {
      final bgr = yuv420ToBgr(
        width: 1,
        height: 1,
        y: Uint8List.fromList([128]),
        u: Uint8List.fromList([128]),
        v: Uint8List.fromList([255]),
        yRowStride: 1,
        uvRowStride: 1,
        uvPixelStride: 1,
      );

      expect(bgr[0], 128);
      expect(bgr[1], lessThan(128));
      expect(bgr[2], greaterThan(200));
    });
  });

  group('bgraToBgr', () {
    test('drops alpha and keeps the order, honouring row stride', () {
      // Two pixels per row, one padding word at the end of each row.
      final bytes = Uint8List.fromList([
        1, 2, 3, 255, 4, 5, 6, 255, 0, 0, 0, 0, // row 0: B G R A
        7, 8, 9, 255, 10, 11, 12, 255, 0, 0, 0, 0, // row 1
      ]);

      final bgr = bgraToBgr(width: 2, height: 2, bytes: bytes, rowStride: 12);

      expect(bgr, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]);
    });
  });
}
