// Progress of the current Bitcoin difficulty epoch and a naive estimate of the
// next adjustment. Pure Dart, no Flutter imports.

/// Blocks in one difficulty epoch.
const int difficultyEpochBlocks = 2016;

/// Target time between blocks, in seconds.
const int targetBlockSeconds = 600;

/// Smallest estimated change, -75 %. The protocol limits one adjustment to a
/// factor of four either way.
const double _minChange = -0.75;

/// Largest estimated change, +300 %.
const double _maxChange = 3.0;

/// First height of the epoch that contains [height].
int epochStartHeight(int height) {
  if (height < 0) {
    throw ArgumentError.value(height, 'height', 'must not be negative');
  }

  return height ~/ difficultyEpochBlocks * difficultyEpochBlocks;
}

/// Progress of the current difficulty epoch and a naive estimate of the next
/// adjustment.
final class DifficultyEpoch {
  const DifficultyEpoch._({
    required this.startHeight,
    required this.blocksMined,
    required this.blocksRemaining,
    required this.progress,
    required this.averageBlockSeconds,
    required this.estimatedChange,
    required this.estimatedSecondsLeft,
  });

  /// Estimates the epoch that contains [tipHeight].
  ///
  /// [tipTime] is the time of the best block and [startTime] the time of the
  /// block at `epochStartHeight(tipHeight)`. Times are Unix seconds. The
  /// average uses the blocks mined so far, so it is a naive estimate.
  factory DifficultyEpoch.estimate({
    required int tipHeight,
    required int tipTime,
    required int startTime,
  }) {
    final startHeight = epochStartHeight(tipHeight);
    final blocksMined = tipHeight - startHeight;
    final blocksRemaining = difficultyEpochBlocks - blocksMined;
    final span = tipTime - startTime;

    double? average;
    if (blocksMined > 0 && span > 0) {
      average = span / blocksMined;
    }

    double? change;
    int? secondsLeft;
    if (average != null) {
      final raw = targetBlockSeconds / average - 1;
      change = raw < _minChange
          ? _minChange
          : (raw > _maxChange ? _maxChange : raw);
      secondsLeft = (blocksRemaining * average).round();
    }

    return DifficultyEpoch._(
      startHeight: startHeight,
      blocksMined: blocksMined,
      blocksRemaining: blocksRemaining,
      progress: blocksMined / difficultyEpochBlocks,
      averageBlockSeconds: average,
      estimatedChange: change,
      estimatedSecondsLeft: secondsLeft,
    );
  }

  /// First height of the epoch.
  final int startHeight;

  /// Blocks mined in this epoch so far (`tipHeight - startHeight`).
  final int blocksMined;

  /// Blocks left until the next adjustment.
  final int blocksRemaining;

  /// Share of the epoch that is done, from 0 to 1.
  final double progress;

  /// Average seconds per block so far. Null when no block was mined in the
  /// epoch or the time span is not positive.
  final double? averageBlockSeconds;

  /// Estimated change of difficulty at the next adjustment, as a fraction:
  /// 0.0231 means +2.31 %. Clamped to -0.75 .. 3.0. Null when
  /// [averageBlockSeconds] is null.
  final double? estimatedChange;

  /// Estimated seconds until the next adjustment, at the current average.
  /// Null when [averageBlockSeconds] is null.
  final int? estimatedSecondsLeft;
}
