import 'package:flutter_test/flutter_test.dart';
import 'package:sato_wiki/src/features/tools/data/esplora_models.dart';
import 'package:sato_wiki/src/features/tools/domain/difficulty_epoch.dart';
import 'package:sato_wiki/src/features/tools/domain/mempool_projection.dart';

// Pure math for the live explorer dashboard. No server, no widgets.

EsploraFeeBucket _bucket(double feeRate, int vsize) {
  return EsploraFeeBucket(feeRate: feeRate, vsize: vsize);
}

void main() {
  group('projectMempoolBlocks', () {
    test('an empty histogram gives no blocks', () {
      expect(projectMempoolBlocks(const <EsploraFeeBucket>[]), isEmpty);
    });

    test('a bucket smaller than a block gives one partial block', () {
      final blocks = projectMempoolBlocks([_bucket(12, 250000)]);

      expect(blocks, hasLength(1));
      final block = blocks.single;
      expect(block.vsize, 250000);
      expect(block.minFeeRate, 12);
      expect(block.maxFeeRate, 12);
      expect(block.medianFeeRate, 12);
      expect(block.estimatedFees, 3000000);
    });

    test('a bucket that exactly fills a block gives no extra block', () {
      final blocks = projectMempoolBlocks([_bucket(10, 1000000)]);

      expect(blocks, hasLength(1));
      expect(blocks.single.vsize, 1000000);
    });

    test('a bucket larger than the space left is split across blocks', () {
      final blocks = projectMempoolBlocks([
        _bucket(10, 600000),
        _bucket(5, 700000),
      ], blockVsize: 1000000);

      expect(blocks, hasLength(2));

      final first = blocks[0];
      expect(first.vsize, 1000000);
      expect(first.maxFeeRate, 10);
      expect(first.minFeeRate, 5);
      // The middle vbyte (500000) is still in the 10 sat/vB bucket.
      expect(first.medianFeeRate, 10);
      expect(first.estimatedFees, 8000000);

      final second = blocks[1];
      expect(second.vsize, 300000);
      expect(second.minFeeRate, 5);
      expect(second.maxFeeRate, 5);
      expect(second.medianFeeRate, 5);
      expect(second.estimatedFees, 1500000);
    });

    test('the median follows the middle vbyte of the block', () {
      final blocks = projectMempoolBlocks([
        _bucket(10, 300000),
        _bucket(5, 700000),
      ], blockVsize: 1000000);

      expect(blocks.single.medianFeeRate, 5);
      expect(blocks.single.minFeeRate, 5);
      expect(blocks.single.maxFeeRate, 10);
    });

    test('a partial last block holds the rest of the histogram', () {
      final blocks = projectMempoolBlocks([
        _bucket(10, 1500000),
      ], blockVsize: 1000000);

      expect(blocks.map((block) => block.vsize), [1000000, 500000]);
    });

    test('no block is larger than the block size', () {
      final blocks = projectMempoolBlocks([
        _bucket(50, 999999),
        _bucket(20, 2),
        _bucket(3, 1700000),
      ], blockVsize: 1000000);

      for (final block in blocks) {
        expect(block.vsize, lessThanOrEqualTo(1000000));
        expect(block.vsize, greaterThan(0));
      }
      expect(
        blocks.map((block) => block.vsize).reduce((a, b) => a + b),
        2700001,
      );
    });

    test('maxBlocks caps the number of blocks, the last one full', () {
      final blocks = projectMempoolBlocks(
        [_bucket(10, 3000000)],
        maxBlocks: 2,
        blockVsize: 1000000,
      );

      expect(blocks, hasLength(2));
      expect(blocks.map((block) => block.vsize), [1000000, 1000000]);
    });

    test('the default cap is 8 blocks', () {
      final blocks = projectMempoolBlocks([_bucket(10, 20000000)]);

      expect(blocks, hasLength(8));
    });

    test('the default block size is one million vbytes', () {
      expect(projectedBlockVsize, 1000000);

      final blocks = projectMempoolBlocks([_bucket(10, 1500000)]);

      expect(blocks.first.vsize, 1000000);
    });

    test('estimated fees are rounded to whole satoshi', () {
      final blocks = projectMempoolBlocks([_bucket(2.5, 3)]);

      expect(blocks.single.estimatedFees, 8);
    });

    test('a block size that is not positive is an ArgumentError', () {
      expect(
        () => projectMempoolBlocks([_bucket(1, 1)], blockVsize: 0),
        throwsArgumentError,
      );
    });
  });

  group('blocksToClear', () {
    test('zero vbytes need no blocks', () {
      expect(blocksToClear(0), 0);
    });

    test('rounds up to whole blocks', () {
      expect(blocksToClear(1), 1);
      expect(blocksToClear(1000000), 1);
      expect(blocksToClear(1000001), 2);
      expect(blocksToClear(11550000), 12);
    });

    test('uses the block size given', () {
      expect(blocksToClear(250, blockVsize: 100), 3);
    });

    test('a block size that is not positive is an ArgumentError', () {
      expect(() => blocksToClear(10, blockVsize: 0), throwsArgumentError);
    });
  });

  group('epochStartHeight', () {
    test('the first block of the chain starts epoch 0', () {
      expect(epochStartHeight(0), 0);
      expect(epochStartHeight(2015), 0);
    });

    test('an epoch starts at each multiple of 2016', () {
      expect(epochStartHeight(2016), 2016);
      expect(epochStartHeight(971412), 969696);
    });

    test('a negative height is an ArgumentError', () {
      expect(() => epochStartHeight(-1), throwsArgumentError);
    });
  });

  group('DifficultyEpoch', () {
    test('at 0 mined: no average, no estimate, a full epoch left', () {
      final epoch = DifficultyEpoch.estimate(
        tipHeight: 2016,
        tipTime: 1000,
        startTime: 500,
      );

      expect(epoch.startHeight, 2016);
      expect(epoch.blocksMined, 0);
      expect(epoch.blocksRemaining, 2016);
      expect(epoch.progress, 0);
      expect(epoch.averageBlockSeconds, isNull);
      expect(epoch.estimatedChange, isNull);
      expect(epoch.estimatedSecondsLeft, isNull);
    });

    test('a zero or negative time span gives no average', () {
      final same = DifficultyEpoch.estimate(
        tipHeight: 971412,
        tipTime: 1792250000,
        startTime: 1792250000,
      );
      final reversed = DifficultyEpoch.estimate(
        tipHeight: 971412,
        tipTime: 1792250000,
        startTime: 1792250100,
      );

      expect(same.averageBlockSeconds, isNull);
      expect(same.estimatedChange, isNull);
      expect(reversed.averageBlockSeconds, isNull);
      expect(reversed.estimatedSecondsLeft, isNull);
    });

    test('canned data gives about 9:46 per block and a +2.31 % estimate', () {
      final epoch = DifficultyEpoch.estimate(
        tipHeight: 971412,
        tipTime: 1792250000,
        startTime: 1792250000 - 1006350,
      );

      expect(epoch.startHeight, 969696);
      expect(epoch.blocksMined, 1716);
      expect(epoch.blocksRemaining, 300);
      expect(epoch.progress, closeTo(1716 / 2016, 1e-9));
      expect(epoch.averageBlockSeconds, closeTo(586.45, 0.01));
      expect(epoch.estimatedChange, closeTo(0.0231, 0.0001));
      expect(epoch.estimatedSecondsLeft, closeTo(300 * 586.45, 5));
    });

    test('blocks at exactly 600 s give no change', () {
      final epoch = DifficultyEpoch.estimate(
        tipHeight: 971412,
        tipTime: 1792250000,
        startTime: 1792250000 - 1716 * 600,
      );

      expect(epoch.averageBlockSeconds, closeTo(600, 1e-9));
      expect(epoch.estimatedChange, closeTo(0, 1e-9));
    });

    test('a very fast epoch clamps the change to +300 %', () {
      final epoch = DifficultyEpoch.estimate(
        tipHeight: 971412,
        tipTime: 1792250000,
        startTime: 1792250000 - 1716 * 100,
      );

      expect(epoch.averageBlockSeconds, closeTo(100, 1e-9));
      expect(epoch.estimatedChange, 3.0);
    });

    test('a very slow epoch clamps the change to -75 %', () {
      final epoch = DifficultyEpoch.estimate(
        tipHeight: 971412,
        tipTime: 1792250000,
        startTime: 1792250000 - 1716 * 3000,
      );

      expect(epoch.averageBlockSeconds, closeTo(3000, 1e-9));
      expect(epoch.estimatedChange, -0.75);
    });
  });

  group('feeEstimatesFromProjection', () {
    ProjectedBlock block(double min, double median, double max) {
      return ProjectedBlock(
        minFeeRate: min,
        maxFeeRate: max,
        medianFeeRate: median,
        vsize: projectedBlockVsize,
        estimatedFees: 0,
      );
    }

    test('an empty projection gives no estimates', () {
      final fees = feeEstimatesFromProjection(const <ProjectedBlock>[], [
        _bucket(5, 1000),
      ]);

      expect(fees.byTarget, isEmpty);
    });

    test('targets take the medians of the first, third and sixth block', () {
      final projected = [
        block(10, 12, 20),
        block(8, 9, 10),
        block(5, 6, 7),
        block(4, 4.5, 5),
        block(3, 3.5, 4),
        block(2, 2.5, 3),
        block(1, 1.5, 2),
      ];
      final fees = feeEstimatesFromProjection(projected, [
        _bucket(20, 100),
        _bucket(1.2, 100),
      ]);

      expect(fees.byTarget, {1: 12, 3: 6, 6: 2.5, 144: 1.2});
    });

    test('short projections fall back to the last block', () {
      final projected = [block(10, 12, 20), block(8, 9, 10)];
      final fees = feeEstimatesFromProjection(projected, [_bucket(3, 100)]);

      // Target 3 uses the last block's median; target 6 its minimum.
      expect(fees.forTarget(1), 12);
      expect(fees.forTarget(3), 9);
      expect(fees.forTarget(6), 8);
      expect(fees.forTarget(144), 3);
    });

    test(
      'target 144 falls back to the last block minimum without a histogram',
      () {
        final projected = [block(10, 12, 20), block(4, 5, 6)];
        final fees = feeEstimatesFromProjection(
          projected,
          const <EsploraFeeBucket>[],
        );

        expect(fees.forTarget(144), 4);
      },
    );

    test('later targets are forced not to exceed earlier ones', () {
      final projected = [
        block(1, 2, 3),
        block(1, 9, 9),
        block(1, 9, 9),
        block(1, 9, 9),
        block(1, 9, 9),
        block(1, 9, 9),
      ];
      final fees = feeEstimatesFromProjection(projected, [_bucket(50, 100)]);

      expect(fees.forTarget(1), 2);
      expect(fees.forTarget(3), 2);
      expect(fees.forTarget(6), 2);
      expect(fees.forTarget(144), 2);
    });
  });
}
