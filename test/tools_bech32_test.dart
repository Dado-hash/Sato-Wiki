import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sato_wiki/src/features/tools/domain/bech32.dart';
import 'package:sato_wiki/src/features/tools/domain/tools_bytes.dart';

// Vectors copied from BIP173 (checksum lists) and BIP350 (bech32m lists and
// address lists), fetched from github.com/bitcoin/bips master.

const _bip173Valid = [
  'A12UEL5L',
  'a12uel5l',
  'an83characterlonghumanreadablepartthatcontainsthenumber1andtheexcludedcharactersbio1tt5tgs',
  'abcdef1qpzry9x8gf2tvdw0s3jn54khce6mua7lmqqqxw',
  '11qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqc8247j',
  'split1checkupstagehandshakeupstreamerranterredcaperred2y9e3w',
  '?1ezyfcl',
];

const _bip173Invalid = [
  ' 1nwldj5',
  '\u007f1axkwrx',
  '\u00801eym55h',
  'an84characterslonghumanreadablepartthatcontainsthenumber1andtheexcludedcharactersbio1569pvx',
  'pzry9x0s0muk',
  '1pzry9x0s0muk',
  'x1b4n0q5v',
  'li1dgmt3',
  'de1lg7wt\u00ff',
  'A1G7SGD8',
  '10a06t8',
  '1qzzfhee',
];

const _bip350Valid = [
  'A1LQFN3A',
  'a1lqfn3a',
  'an83characterlonghumanreadablepartthatcontainsthetheexcludedcharactersbioandnumber11sg7hg6',
  'abcdef1l7aum6echk45nj3s0wdvt2fg8x9yrzpqzd3ryx',
  '11llllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllludsr8',
  'split1checkupstagehandshakeupstreamerranterredcaperredlc445v',
  '?1v759aa',
];

const _bip350Invalid = [
  ' 1xj0phk',
  '\u007f1g6xzxy',
  '\u00801vctc34',
  'an84characterslonghumanreadablepartthatcontainsthetheexcludedcharactersbioandnumber11d6pts4',
  'qyrz8wqd2c9m',
  '1qyrz8wqd2c9m',
  'y1b0jsk6g',
  'lt1igcx5c0',
  'in1muywd',
  'mm1crxm3i',
  'au1s5cgom',
  'M1VUXWEZ',
  '16plkw9',
  '1p2gdwpf',
];

const _bip350AddressValid = [
  (
    'BC1QW508D6QEJXTDG4Y5R3ZARVARY0C5XW7KV8F3T4',
    '0014751e76e8199196d454941c45d1b3a323f1433bd6',
  ),
  (
    'tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3q0sl5k7',
    '00201863143c14c5166804bd19203356da136c985678cd4d27a1b8c6329604903262',
  ),
  (
    'bc1pw508d6qejxtdg4y5r3zarvary0c5xw7kw508d6qejxtdg4y5r3zarvary0c5xw7kt5nd6y',
    '5128751e76e8199196d454941c45d1b3a323f1433bd6751e76e8199196d454941c45d1b3a323f1433bd6',
  ),
  ('BC1SW50QGDZ25J', '6002751e'),
  (
    'bc1zw508d6qejxtdg4y5r3zarvaryvaxxpcs',
    '5210751e76e8199196d454941c45d1b3a323',
  ),
  (
    'tb1qqqqqp399et2xygdj5xreqhjjvcmzhxw4aywxecjdzew6hylgvsesrxh6hy',
    '0020000000c4a5cad46221b2a187905e5266362b99d5e91c6ce24d165dab93e86433',
  ),
  (
    'tb1pqqqqp399et2xygdj5xreqhjjvcmzhxw4aywxecjdzew6hylgvsesf3hn0c',
    '5120000000c4a5cad46221b2a187905e5266362b99d5e91c6ce24d165dab93e86433',
  ),
  (
    'bc1p0xlxvlhemja6c4dqv22uapctqupfhlxm9h8z3k2e72q4k9hcz7vqzk5jj0',
    '512079be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798',
  ),
];

const _bip350AddressInvalid = [
  'tc1p0xlxvlhemja6c4dqv22uapctqupfhlxm9h8z3k2e72q4k9hcz7vq5zuyut',
  'bc1p0xlxvlhemja6c4dqv22uapctqupfhlxm9h8z3k2e72q4k9hcz7vqh2y7hd',
  'tb1z0xlxvlhemja6c4dqv22uapctqupfhlxm9h8z3k2e72q4k9hcz7vqglt7rf',
  'BC1S0XLXVLHEMJA6C4DQV22UAPCTQUPFHLXM9H8Z3K2E72Q4K9HCZ7VQ54WELL',
  'bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kemeawh',
  'tb1q0xlxvlhemja6c4dqv22uapctqupfhlxm9h8z3k2e72q4k9hcz7vq24jc47',
  'bc1p38j9r5y49hruaue7wxjce0updqjuyyx0kh56v8s25huc6995vvpql3jow4',
  'BC130XLXVLHEMJA6C4DQV22UAPCTQUPFHLXM9H8Z3K2E72Q4K9HCZ7VQ7ZWS8R',
  'bc1pw5dgrnzv',
  'bc1p0xlxvlhemja6c4dqv22uapctqupfhlxm9h8z3k2e72q4k9hcz7v8n0nx0muaewav253zgeav',
  'BC1QR508D6QEJXTDG4Y5R3ZARVARYV98GJ9P',
  'tb1p0xlxvlhemja6c4dqv22uapctqupfhlxm9h8z3k2e72q4k9hcz7vq47Zagq',
  'bc1p0xlxvlhemja6c4dqv22uapctqupfhlxm9h8z3k2e72q4k9hcz7v07qwwzcrf',
  'tb1p0xlxvlhemja6c4dqv22uapctqupfhlxm9h8z3k2e72q4k9hcz7vpggkg4j',
  'bc1gmk9yu',
];

void main() {
  group('bech32 checksum vectors (BIP173)', () {
    test('valid strings decode as bech32', () {
      for (final text in _bip173Valid) {
        expect(bech32Decode(text).variant, Bech32Variant.bech32, reason: text);
      }
    });

    test('invalid strings are rejected', () {
      for (final text in _bip173Invalid) {
        expect(
          () => bech32Decode(text),
          throwsA(isA<FormatException>()),
          reason: text,
        );
      }
    });

    test('valid strings re-encode to the same lower case text', () {
      for (final text in _bip173Valid) {
        final decoded = bech32Decode(text);
        final words = decoded.data.toList();
        expect(
          bech32Encode(decoded.hrp, words, Bech32Variant.bech32),
          text.toLowerCase(),
          reason: text,
        );
      }
    });
  });

  group('bech32m checksum vectors (BIP350)', () {
    test('valid strings decode as bech32m', () {
      for (final text in _bip350Valid) {
        expect(bech32Decode(text).variant, Bech32Variant.bech32m, reason: text);
      }
    });

    test('invalid strings are rejected', () {
      for (final text in _bip350Invalid) {
        expect(
          () => bech32Decode(text),
          throwsA(isA<FormatException>()),
          reason: text,
        );
      }
    });

    test('valid strings re-encode to the same lower case text', () {
      for (final text in _bip350Valid) {
        final decoded = bech32Decode(text);
        expect(
          bech32Encode(decoded.hrp, decoded.data, Bech32Variant.bech32m),
          text.toLowerCase(),
          reason: text,
        );
      }
    });
  });

  group('segwit address vectors (BIP350)', () {
    test('valid addresses decode to the scriptPubKey in the vector', () {
      for (final (address, scriptHex) in _bip350AddressValid) {
        final decoded = decodeSegwitAddress(address);
        final opcode = decoded.witnessVersion == 0
            ? 0x00
            : 0x50 + decoded.witnessVersion;
        final script = [opcode, decoded.program.length, ...decoded.program];
        expect(hexEncode(script), scriptHex, reason: address);
      }
    });

    test('valid addresses encode back to the lower case address', () {
      for (final (address, _) in _bip350AddressValid) {
        final decoded = decodeSegwitAddress(address);
        expect(
          encodeSegwitAddress(
            decoded.hrp,
            decoded.witnessVersion,
            decoded.program,
          ),
          address.toLowerCase(),
          reason: address,
        );
      }
    });

    test('invalid addresses are rejected', () {
      for (final address in _bip350AddressInvalid) {
        expect(
          () => decodeSegwitAddress(address),
          throwsA(isA<FormatException>()),
          reason: address,
        );
      }
    });
  });

  group('specific failure reasons', () {
    Bech32Problem problemOf(String text) {
      try {
        decodeSegwitAddress(text);
      } on Bech32FormatException catch (error) {
        return error.problem;
      }
      fail('expected $text to be rejected');
    }

    test('mixed case is reported as mixedCase', () {
      expect(
        problemOf(
          'tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3q0sL5k7',
        ),
        Bech32Problem.mixedCase,
      );
    });

    test('bech32 checksum on a version 1 address is wrongVariant', () {
      expect(
        problemOf(
          'bc1p0xlxvlhemja6c4dqv22uapctqupfhlxm9h8z3k2e72q4k9hcz7vqh2y7hd',
        ),
        Bech32Problem.wrongVariant,
      );
    });

    test('bech32m checksum on a version 0 address is wrongVariant', () {
      expect(
        problemOf('bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kemeawh'),
        Bech32Problem.wrongVariant,
      );
    });

    test('unknown human-readable part is unknownHrp', () {
      expect(
        problemOf(
          'tc1p0xlxvlhemja6c4dqv22uapctqupfhlxm9h8z3k2e72q4k9hcz7vq5zuyut',
        ),
        Bech32Problem.unknownHrp,
      );
    });

    test('one-byte program is invalidProgramLength', () {
      expect(problemOf('bc1pw5dgrnzv'), Bech32Problem.invalidProgramLength);
    });

    test('version 0 with 16 bytes is invalidProgramLength', () {
      expect(
        problemOf('BC1QR508D6QEJXTDG4Y5R3ZARVARYV98GJ9P'),
        Bech32Problem.invalidProgramLength,
      );
    });

    test('version 17 is unknownWitnessVersion', () {
      expect(
        problemOf(
          'BC130XLXVLHEMJA6C4DQV22UAPCTQUPFHLXM9H8Z3K2E72Q4K9HCZ7VQ7ZWS8R',
        ),
        Bech32Problem.unknownWitnessVersion,
      );
    });

    test('empty witness data is emptyData', () {
      expect(problemOf('bc1gmk9yu'), Bech32Problem.emptyData);
    });

    test('non-zero padding is invalidPadding', () {
      expect(
        problemOf(
          'tb1p0xlxvlhemja6c4dqv22uapctqupfhlxm9h8z3k2e72q4k9hcz7vpggkg4j',
        ),
        Bech32Problem.invalidPadding,
      );
    });

    test('missing separator is missingSeparator', () {
      expect(
        () => bech32Decode('pzry9x0s0muk'),
        throwsA(
          isA<Bech32FormatException>().having(
            (error) => error.problem,
            'problem',
            Bech32Problem.missingSeparator,
          ),
        ),
      );
    });

    test('uppercase HRP checksum is badChecksum', () {
      expect(
        () => bech32Decode('A1G7SGD8'),
        throwsA(
          isA<Bech32FormatException>().having(
            (error) => error.problem,
            'problem',
            Bech32Problem.badChecksum,
          ),
        ),
      );
    });
  });

  group('encoding', () {
    test('version 0 program encodes to the known mainnet P2WPKH address', () {
      final program = hexDecode('751e76e8199196d454941c45d1b3a323f1433bd6');
      expect(
        encodeSegwitAddress('bc', 0, program),
        'bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4',
      );
    });

    test('encoding rejects invalid versions and program lengths', () {
      final twenty = List<int>.filled(20, 1);
      expect(
        () => encodeSegwitAddress('bc', 17, twenty),
        throwsFormatException,
      );
      expect(() => encodeSegwitAddress('bc', 0, [1]), throwsFormatException);
      expect(
        () => encodeSegwitAddress('bc', 0, List<int>.filled(16, 1)),
        throwsFormatException,
      );
      expect(() => encodeSegwitAddress('xx', 0, twenty), throwsFormatException);
    });

    test('bech32Encode rejects words out of the 5-bit range', () {
      expect(
        () => bech32Encode('a', [32], Bech32Variant.bech32),
        throwsFormatException,
      );
    });

    test('convertBits 8 to 5 and back restores the bytes', () {
      final bytes = Uint8List.fromList(
        List<int>.generate(33, (i) => i * 7 & 0xff),
      );
      final words = convertBits(bytes, 8, 5, pad: true);
      expect(words.every((word) => word < 32), isTrue);
      expect(convertBits(words, 5, 8, pad: false), bytes);
    });

    test('convertBits without padding rejects leftover bits', () {
      expect(
        () => convertBits([1, 2], 5, 8, pad: false),
        throwsA(isA<Bech32FormatException>()),
      );
    });
  });
}
