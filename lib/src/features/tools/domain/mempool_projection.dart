// Projects the mempool onto the next blocks from its fee histogram. Pure Dart,
// no Flutter imports.

import 'dart:math';

import '../data/esplora_models.dart';

/// Vbytes in a full block, the consensus limit used for projections.
const int projectedBlockVsize = 1000000;

/// A block the mempool would fill next, built from the fee histogram.
final class ProjectedBlock {
  /// Creates a projected block.
  const ProjectedBlock({
    required this.minFeeRate,
    required this.maxFeeRate,
    required this.medianFeeRate,
    required this.vsize,
    required this.estimatedFees,
  });

  /// Lowest bucket fee rate inside this block, in sat/vB.
  final double minFeeRate;

  /// Highest bucket fee rate inside this block, in sat/vB.
  final double maxFeeRate;

  /// Fee rate at the middle vbyte of the block, in sat/vB.
  final double medianFeeRate;

  /// Vbytes in this block. At most the block size used for the projection.
  final int vsize;

  /// Fees of this block in satoshi. A lower bound, because each bucket counts
  /// at its lowest fee rate.
  final int estimatedFees;
}

/// A slice of one histogram bucket that landed in a block.
final class _Slice {
  const _Slice(this.feeRate, this.vsize);

  final double feeRate;
  final int vsize;
}

/// Splits [histogram] (highest fee rate first) into blocks of [blockVsize]
/// vbytes, highest fee rate first.
///
/// A bucket larger than the space left in a block is split across blocks.
/// Returns at most [maxBlocks] blocks. The last one may be partial. An empty
/// histogram gives an empty list.
List<ProjectedBlock> projectMempoolBlocks(
  List<EsploraFeeBucket> histogram, {
  int maxBlocks = 8,
  int blockVsize = projectedBlockVsize,
}) {
  if (blockVsize <= 0) {
    throw ArgumentError.value(blockVsize, 'blockVsize', 'must be positive');
  }

  final blocks = <ProjectedBlock>[];
  var current = <_Slice>[];
  var used = 0;

  void closeCurrent() {
    if (current.isEmpty) {
      return;
    }
    blocks.add(_build(current, used));
    current = <_Slice>[];
    used = 0;
  }

  for (final bucket in histogram) {
    var remaining = bucket.vsize;
    while (remaining > 0 && blocks.length < maxBlocks) {
      final take = remaining < blockVsize - used
          ? remaining
          : blockVsize - used;
      current.add(_Slice(bucket.feeRate, take));
      used += take;
      remaining -= take;
      if (used == blockVsize) {
        closeCurrent();
      }
    }
    if (blocks.length >= maxBlocks) {
      return blocks;
    }
  }
  closeCurrent();

  return blocks;
}

/// Blocks needed to clear [mempoolVsize] vbytes, rounded up. 0 for 0.
int blocksToClear(int mempoolVsize, {int blockVsize = projectedBlockVsize}) {
  if (blockVsize <= 0) {
    throw ArgumentError.value(blockVsize, 'blockVsize', 'must be positive');
  }
  if (mempoolVsize <= 0) {
    return 0;
  }

  return (mempoolVsize + blockVsize - 1) ~/ blockVsize;
}

/// Turns the slices of one block into its summary. [slices] is not empty and
/// [vsize] is the sum of their sizes.
ProjectedBlock _build(List<_Slice> slices, int vsize) {
  var minRate = slices.first.feeRate;
  var maxRate = slices.first.feeRate;
  var fees = 0.0;
  for (final slice in slices) {
    if (slice.feeRate < minRate) {
      minRate = slice.feeRate;
    }
    if (slice.feeRate > maxRate) {
      maxRate = slice.feeRate;
    }
    fees += slice.feeRate * slice.vsize;
  }

  // The rate of the slice that holds the middle vbyte.
  final middle = vsize / 2;
  var seen = 0;
  var medianRate = slices.last.feeRate;
  for (final slice in slices) {
    seen += slice.vsize;
    if (seen >= middle) {
      medianRate = slice.feeRate;
      break;
    }
  }

  return ProjectedBlock(
    minFeeRate: minRate,
    maxFeeRate: maxRate,
    medianFeeRate: medianRate,
    vsize: vsize,
    estimatedFees: fees.round(),
  );
}

/// Fee estimates for targets 1, 3, 6 and 144 blocks, derived from the mempool
/// when the server has no `/fee-estimates`.
///
/// Target 1 is the median rate of the next block, target 3 the median of the
/// third block and target 6 the median of the sixth block. Each falls back to
/// the last projected block when there are fewer blocks (target 6 uses that
/// block's lowest rate). Target 144 is the lowest rate in [histogram]. The
/// targets are forced to be non-increasing. An empty projection gives no
/// estimates.
EsploraFeeEstimates feeEstimatesFromProjection(
  List<ProjectedBlock> projected,
  List<EsploraFeeBucket> histogram,
) {
  if (projected.isEmpty) {
    return const EsploraFeeEstimates(<int, double>{});
  }

  final last = projected.last;
  final next = projected.first.medianFeeRate;
  final third = (projected.length > 2 ? projected[2] : last).medianFeeRate;
  final sixth = projected.length >= 6
      ? projected[5].medianFeeRate
      : last.minFeeRate;
  final lowest = histogram.isEmpty
      ? last.minFeeRate
      : histogram.map((bucket) => bucket.feeRate).reduce(min);

  final target3 = min(third, next);
  final target6 = min(sixth, target3);
  final target144 = min(lowest, target6);

  return EsploraFeeEstimates(
    Map.unmodifiable(<int, double>{
      1: next,
      3: target3,
      6: target6,
      144: target144,
    }),
  );
}
