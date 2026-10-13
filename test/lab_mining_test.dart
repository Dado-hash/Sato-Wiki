import 'package:flutter_test/flutter_test.dart';

import 'package:sato_wiki/src/features/tools/domain/lab_blockchain.dart';
import 'package:sato_wiki/src/features/tools/presentation/lab_mining.dart';

void main() {
  const block = LabBlock(
    number: 1,
    nonce: 0,
    data: 'Alice -> Bob: 5',
    previousHash: labGenesisPreviousHash,
  );

  test('finds the first nonce that meets the difficulty', () async {
    final found = await mineLabBlockInBatches(
      block,
      leadingZeros: 2,
      isCancelled: () => false,
      onProgress: (_) {},
    );

    expect(found, isNotNull);
    expect(found!.isMined(2), isTrue);
    for (var nonce = 0; nonce < found.nonce; nonce++) {
      expect(block.copyWith(nonce: nonce).isMined(2), isFalse);
    }
  });

  test('reports progress after each batch', () async {
    final reports = <LabMiningProgress>[];
    await mineLabBlockInBatches(
      block,
      leadingZeros: 4,
      isCancelled: () => reports.length >= 3,
      onProgress: reports.add,
    );

    expect(reports, hasLength(3));
    expect(reports.last.attempts, greaterThan(reports.first.attempts));
    expect(reports.last.attempts, labMiningBatchSize * 3);
  });

  test('a cancelled run returns null without a nonce', () async {
    final found = await mineLabBlockInBatches(
      block,
      leadingZeros: 4,
      isCancelled: () => true,
      onProgress: (_) {},
    );

    expect(found, isNull);
  });

  test('speed is zero before any time has passed', () {
    const progress = LabMiningProgress(attempts: 10, elapsed: Duration.zero);

    expect(progress.hashesPerSecond, 0);
  });
}
