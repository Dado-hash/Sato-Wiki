import 'package:flutter_test/flutter_test.dart';
import 'package:sato_wiki/src/features/tools/domain/compact_target.dart';

void main() {
  group('targetFromBits', () {
    test('difficulty 1 bits give the maximum target', () {
      expect(
        targetToHex(targetFromBits(0x1d00ffff)),
        '00000000ffff0000000000000000000000000000000000000000000000000000',
      );
      expect(maxTarget, targetFromBits(0x1d00ffff));
    });

    test('0x1b0404cb gives the documented target', () {
      expect(
        targetToHex(targetFromBits(0x1b0404cb)),
        '00000000000404cb000000000000000000000000000000000000000000000000',
      );
    });

    test('exponent of 3 or less shifts the mantissa right', () {
      expect(targetFromBits(0x03123456), BigInt.from(0x123456));
      expect(targetFromBits(0x02008000), BigInt.from(0x80));
    });

    test('sign bit with a non-zero mantissa is rejected', () {
      expect(() => targetFromBits(0x04923456), throwsFormatException);
    });

    test('bits outside 32 bits are rejected', () {
      expect(() => targetFromBits(-1), throwsFormatException);
      expect(() => targetFromBits(0x100000000), throwsFormatException);
    });
  });

  group('bitsFromTarget', () {
    test('round trips the documented bits', () {
      expect(bitsFromTarget(targetFromBits(0x1d00ffff)), 0x1d00ffff);
      expect(bitsFromTarget(targetFromBits(0x1b0404cb)), 0x1b0404cb);
    });

    test('normalises a mantissa with the top bit set', () {
      // 0x80 needs a leading zero byte in the mantissa, so it becomes 0x02008000
      expect(bitsFromTarget(BigInt.from(0x80)), 0x02008000);
      expect(bitsFromTarget(BigInt.zero), 0);
    });

    test('negative targets are rejected', () {
      expect(() => bitsFromTarget(BigInt.from(-1)), throwsArgumentError);
    });
  });

  group('difficulty', () {
    test('difficulty 1 bits give exactly 1.0', () {
      expect(difficultyFromBits(0x1d00ffff), 1.0);
      expect(difficultyFromTarget(maxTarget), 1.0);
    });

    test('0x1b0404cb gives the documented difficulty', () {
      expect(difficultyFromBits(0x1b0404cb), closeTo(16307.420938523983, 1e-6));
    });

    test('expected hashes is 2^256 divided by target plus one', () {
      expect(
        expectedHashes(maxTarget),
        (BigInt.one << 256) ~/ (maxTarget + BigInt.one),
      );
      expect(expectedHashes(BigInt.one << 252), BigInt.from(15));
    });

    test('zero target is rejected for difficulty', () {
      expect(() => difficultyFromTarget(BigInt.zero), throwsArgumentError);
    });
  });

  group('targetToHex', () {
    test('pads to 64 characters', () {
      expect(
        targetToHex(BigInt.one),
        '0000000000000000000000000000000000000000000000000000000000000001',
      );
    });
  });

  group('parseBits', () {
    test('accepts plain, prefixed and upper case text', () {
      expect(parseBits('1d00ffff'), 0x1d00ffff);
      expect(parseBits('0x1d00ffff'), 0x1d00ffff);
      expect(parseBits('0X1D00FFFF'), 0x1d00ffff);
      expect(parseBits(' 1D00FFFF '), 0x1d00ffff);
    });

    test('rejects other text', () {
      expect(() => parseBits(''), throwsFormatException);
      expect(() => parseBits('1d00fff'), throwsFormatException);
      expect(() => parseBits('1d00fffff'), throwsFormatException);
      expect(() => parseBits('0x1d00fffg'), throwsFormatException);
      expect(() => parseBits('1d00ffff00'), throwsFormatException);
    });
  });
}
