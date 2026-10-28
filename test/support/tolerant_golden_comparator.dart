import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// A [LocalFileComparator] that accepts goldens differing by at most
/// [tolerance] of the pixels (a fraction, 0.0005 is 0.05%).
///
/// Use it when a golden was rasterised on another machine or SDK build and
/// only anti-aliasing differs; the golden itself is not regenerated.
class TolerantGoldenComparator extends LocalFileComparator {
  TolerantGoldenComparator(super.testFile, {this.tolerance = 0.0})
    : assert(tolerance >= 0 && tolerance <= 1);

  /// Largest accepted fraction of differing pixels.
  final double tolerance;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );

    if (result.passed || result.diffPercent <= tolerance) {
      result.dispose();
      return true;
    }

    final error = await generateFailureOutput(result, golden, basedir);
    result.dispose();
    throw FlutterError(error);
  }
}
