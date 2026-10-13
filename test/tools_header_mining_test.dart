import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sato_wiki/src/features/tools/domain/compact_target.dart';
import 'package:sato_wiki/src/features/tools/domain/header_mining.dart';
import 'package:sato_wiki/src/features/tools/domain/tools_bytes.dart';

/// Genesis block header, 80 bytes, from the Bitcoin genesis block.
const String genesisHeaderHex =
    '0100000000000000000000000000000000000000000000000000000000000000'
    '000000003ba3edfd7a7b12b27ac72c3e67768f617fc81bc3888a51323a9fb8aa'
    '4b1e5e4a29ab5f49ffff001d1dac2b7c';

const String genesisHash =
    '000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f';

void main() {
  group('genesis header', () {
    test('the constant holds the real genesis values', () {
      expect(genesisHeader.version, 1);
      expect(
        genesisHeader.previousBlockHash,
        '0000000000000000000000000000000000000000000000000000000000000000',
      );
      expect(
        genesisHeader.merkleRoot,
        '4a5e1e4baab89f3a32518a88c31bc87f618f76673e2cc77ab2127b7afdeda33b',
      );
      expect(genesisHeader.time, 1231006505);
      expect(genesisHeader.bits, 0x1d00ffff);
      expect(genesisHeader.nonce, 2083236893);
    });

    test('hash is the documented genesis hash', () {
      expect(genesisHeader.hash, genesisHash);
    });

    test('hash meets its own target', () {
      final target = targetFromBits(genesisHeader.bits);
      expect(headerMeetsTarget(genesisHeader, target), isTrue);
    });

    test('a wrong nonce does not meet the target', () {
      final target = targetFromBits(genesisHeader.bits);
      expect(
        headerMeetsTarget(genesisHeader.copyWith(nonce: 0), target),
        isFalse,
      );
    });

    test('serialize gives the 80-byte header', () {
      expect(hexEncode(genesisHeader.serialize()), genesisHeaderHex);
      expect(genesisHeader.serialize(), hasLength(80));
    });

    test('parse reads the same fields back', () {
      final parsed = BlockHeader.parse(genesisHeaderHex);
      expect(parsed.version, 1);
      expect(parsed.previousBlockHash, genesisHeader.previousBlockHash);
      expect(parsed.merkleRoot, genesisHeader.merkleRoot);
      expect(parsed.time, genesisHeader.time);
      expect(parsed.bits, genesisHeader.bits);
      expect(parsed.nonce, genesisHeader.nonce);
      expect(parsed.hash, genesisHash);
    });

    test('parse rejects text that is not 80 bytes or not hex', () {
      expect(() => BlockHeader.parse('00' * 79), throwsFormatException);
      expect(() => BlockHeader.parse('00' * 81), throwsFormatException);
      expect(() => BlockHeader.parse('zz'), throwsFormatException);
    });

    test('serialize rejects out-of-range fields', () {
      expect(
        () => genesisHeader.copyWith(nonce: -1).serialize(),
        throwsArgumentError,
      );
      expect(
        () => genesisHeader.copyWith(time: 0x100000000).serialize(),
        throwsArgumentError,
      );
      expect(
        () => genesisHeader.copyWith(previousBlockHash: 'abcd').serialize(),
        throwsArgumentError,
      );
    });
  });

  group('mineHeaderChunk', () {
    test(
      'finds a nonce with an easy target within a few thousand attempts',
      () {
        final target = BigInt.one << 252;
        final result = mineHeaderChunk(
          genesisHeader.copyWith(nonce: 0),
          target: target,
          startNonce: 0,
          attempts: 5000,
        );
        final nonce = result.nonce;
        expect(nonce, isNotNull);
        expect(result.attemptsDone, nonce! + 1);
        expect(
          headerMeetsTarget(genesisHeader.copyWith(nonce: nonce), target),
          isTrue,
        );
        expect(result.hash, genesisHeader.copyWith(nonce: nonce).hash);
      },
    );

    test('finds the real genesis nonce at difficulty 1', () {
      final result = mineHeaderChunk(
        genesisHeader,
        target: maxTarget,
        startNonce: 2083236880,
        attempts: 100,
      );
      expect(result.nonce, 2083236893);
      expect(result.hash, genesisHash);
    });

    test('returns null and the next nonce when the chunk has no hit', () {
      final result = mineHeaderChunk(
        genesisHeader.copyWith(nonce: 0),
        target: BigInt.zero,
        startNonce: 10,
        attempts: 3,
      );
      expect(result.nonce, isNull);
      expect(result.hash, isNull);
      expect(result.nextNonce, 13);
      expect(result.attemptsDone, 3);
    });

    test('stops at the 32-bit nonce limit', () {
      final result = mineHeaderChunk(
        genesisHeader,
        target: BigInt.zero,
        startNonce: 0xfffffffe,
        attempts: 10,
      );
      expect(result.nonce, isNull);
      expect(result.attemptsDone, 2);
      expect(result.nextNonce, 0x100000000);
    });
  });

  group('byte helpers used by the header', () {
    test('the displayed hash is the reversed double SHA-256 of the bytes', () {
      final bytes = genesisHeader.serialize();
      expect(genesisHeader.hash, hexEncode(reversedBytes(doubleSha256(bytes))));
      expect(
        Uint8List.fromList(bytes.sublist(0, 4)),
        Uint8List.fromList([1, 0, 0, 0]),
      );
    });
  });
}
