import 'package:flutter_test/flutter_test.dart';
import 'package:sato_wiki/src/features/tools/domain/lab_blockchain.dart';

/// Mines [block] at [leadingZeros] with chunks, as a UI would, and returns the mined block.
LabBlock mineByChunks(LabBlock block, int leadingZeros) {
  var start = 0;
  while (true) {
    final result = mineLabBlockChunk(
      block,
      leadingZeros: leadingZeros,
      startNonce: start,
      attempts: 1000,
    );
    final nonce = result.nonce;
    if (nonce != null) {
      return block.copyWith(nonce: nonce);
    }
    start = result.nextNonce;
  }
}

void main() {
  group('LabBlock hash', () {
    test('is SHA-256 of the concatenated text, as lowercase hex', () {
      const block = LabBlock(
        number: 0,
        nonce: 0,
        data: '',
        previousHash: labGenesisPreviousHash,
      );
      // Text is "0" + "0" + "" + 64 zeros. The value comes from
      // `printf '00%064d' 0 | shasum -a 256`, not from the code under test.
      expect(
        block.hash,
        'd5f28bdae4731c38abc064bc702233257035309462dbeaa891f9e8f33df6d78e',
      );
    });

    test('copyWith changes only the given fields', () {
      const block = LabBlock(number: 1, nonce: 2, data: 'a', previousHash: 'b');
      final changed = block.copyWith(nonce: 9);
      expect(changed.number, 1);
      expect(changed.nonce, 9);
      expect(changed.data, 'a');
      expect(changed.previousHash, 'b');
      expect(changed.hash, isNot(block.hash));
    });
  });

  group('difficulty', () {
    test('labHashMeetsDifficulty counts leading zero characters', () {
      expect(labHashMeetsDifficulty('00ab', 2), isTrue);
      expect(labHashMeetsDifficulty('0fab', 2), isFalse);
      expect(labHashMeetsDifficulty('0', 2), isFalse);
      expect(labHashMeetsDifficulty('abc', 0), isTrue);
    });

    test('a block mined at 2 leading zeros has a hash starting with 00', () {
      final mined = mineByChunks(
        const LabBlock(
          number: 0,
          nonce: 0,
          data: 'hello',
          previousHash: labGenesisPreviousHash,
        ),
        2,
      );
      expect(mined.hash.startsWith('00'), isTrue);
      expect(mined.isMined(2), isTrue);
    });
  });

  group('mineLabBlockChunk', () {
    const block = LabBlock(
      number: 0,
      nonce: 0,
      data: 'chunk test',
      previousHash: labGenesisPreviousHash,
    );

    test('reports the found nonce and hash', () {
      final result = mineLabBlockChunk(
        block,
        leadingZeros: 2,
        startNonce: 0,
        attempts: 100000,
      );
      final nonce = result.nonce;
      expect(nonce, isNotNull);
      expect(result.hash, block.copyWith(nonce: nonce).hash);
      expect(result.hash!.startsWith('00'), isTrue);
      expect(result.nextNonce, nonce! + 1);
      expect(result.attemptsDone, nonce + 1);
    });

    test('returns null and the next nonce when the chunk has no hit', () {
      // Precondition: nonce 0 does not meet 2 leading zeros for this block.
      expect(block.copyWith(nonce: 0).isMined(2), isFalse);
      final result = mineLabBlockChunk(
        block,
        leadingZeros: 2,
        startNonce: 0,
        attempts: 1,
      );
      expect(result.nonce, isNull);
      expect(result.hash, isNull);
      expect(result.nextNonce, 1);
      expect(result.attemptsDone, 1);
    });

    test('zero attempts does nothing', () {
      final result = mineLabBlockChunk(
        block,
        leadingZeros: 2,
        startNonce: 5,
        attempts: 0,
      );
      expect(result.nonce, isNull);
      expect(result.nextNonce, 5);
      expect(result.attemptsDone, 0);
    });
  });

  group('validateLabChain', () {
    test('a three-block chain mined in order is fully valid', () {
      final chain = <LabBlock>[];
      var previous = labGenesisPreviousHash;
      for (var i = 0; i < 3; i++) {
        final block = mineByChunks(
          LabBlock(
            number: i,
            nonce: 0,
            data: 'block $i',
            previousHash: previous,
          ),
          2,
        );
        chain.add(block);
        previous = block.hash;
      }

      final statuses = validateLabChain(chain, 2);
      expect(statuses, hasLength(3));
      for (final status in statuses) {
        expect(status.mined, isTrue);
        expect(status.linked, isTrue);
        expect(status.valid, isTrue);
      }
    });

    test('editing the data of block 1 makes blocks 1, 2 and 3 not valid', () {
      final chain = <LabBlock>[];
      var previous = labGenesisPreviousHash;
      for (var i = 0; i < 4; i++) {
        final block = mineByChunks(
          LabBlock(
            number: i,
            nonce: 0,
            data: 'block $i',
            previousHash: previous,
          ),
          2,
        );
        chain.add(block);
        previous = block.hash;
      }

      final edited = chain[1].copyWith(data: 'block 1 edited');
      // Precondition: the edited block does not meet the difficulty, so it is
      // reported as not valid because of its own hash, not by luck of linking.
      expect(edited.isMined(2), isFalse);
      final tampered = [chain[0], edited, chain[2], chain[3]];

      final statuses = validateLabChain(tampered, 2);
      expect(statuses[0].valid, isTrue);
      expect(statuses[1].valid, isFalse);
      expect(statuses[2].valid, isFalse);
      expect(statuses[2].linked, isFalse);
      expect(statuses[3].valid, isFalse);
    });

    test('the first block must link to the genesis value', () {
      final block = mineByChunks(
        const LabBlock(
          number: 0,
          nonce: 0,
          data: 'orphan',
          previousHash:
              '1111111111111111111111111111111111111111111111111111111111111111',
        ),
        2,
      );
      final status = validateLabChain([block], 2).single;
      expect(status.mined, isTrue);
      expect(status.linked, isFalse);
      expect(status.valid, isFalse);
    });
  });

  group('mineLabBlock', () {
    test('mines through an isolate at 3 leading zeros', () async {
      const block = LabBlock(
        number: 0,
        nonce: 0,
        data: 'isolate',
        previousHash: labGenesisPreviousHash,
      );
      final mined = await mineLabBlock(block, leadingZeros: 3);
      expect(mined.hash.startsWith('000'), isTrue);
      expect(mined.isMined(3), isTrue);
      expect(mined.data, block.data);
      expect(mined.previousHash, block.previousHash);
    });

    test(
      'throws StateError when no nonce is found within maxAttempts',
      () async {
        const block = LabBlock(
          number: 0,
          nonce: 0,
          data: 'too hard',
          previousHash: labGenesisPreviousHash,
        );
        await expectLater(
          mineLabBlock(block, leadingZeros: 8, maxAttempts: 10),
          throwsStateError,
        );
      },
    );
  });

  group('encodeLabTransfers', () {
    test('writes one line per transfer, coinbase first', () {
      final text = encodeLabTransfers(const [
        LabTransfer(from: 'alice', to: 'bob', amount: 5),
        LabTransfer(from: 'bob', to: 'carol', amount: 2),
      ], coinbase: const LabTransfer(from: 'mint', to: 'alice', amount: 50));
      expect(text, 'mint -> alice: 50\nalice -> bob: 5\nbob -> carol: 2');
    });

    test('is deterministic and handles no coinbase', () {
      const transfers = [LabTransfer(from: 'a', to: 'b', amount: 1)];
      expect(encodeLabTransfers(transfers), 'a -> b: 1');
      expect(encodeLabTransfers(transfers), encodeLabTransfers(transfers));
      expect(encodeLabTransfers(const []), '');
    });

    test('rejects line breaks and negative amounts', () {
      expect(
        () => encodeLabTransfers(const [
          LabTransfer(from: 'a\nb', to: 'c', amount: 1),
        ]),
        throwsArgumentError,
      );
      expect(
        () => encodeLabTransfers(const [
          LabTransfer(from: 'a', to: 'c', amount: -1),
        ]),
        throwsArgumentError,
      );
    });
  });
}
