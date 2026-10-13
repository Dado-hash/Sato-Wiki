import 'package:flutter_test/flutter_test.dart';
import 'package:sato_wiki/src/features/tools/domain/script_number.dart';
import 'package:sato_wiki/src/features/tools/domain/tools_bytes.dart';

// Expected encodings follow Bitcoin Core's CScriptNum (src/script/script.h).

void main() {
  group('encodeScriptNumber', () {
    final cases = <int, String>{
      0: '',
      1: '01',
      -1: '81',
      127: '7f',
      128: '8000',
      -128: '8080',
      255: 'ff00',
      256: '0001',
      32767: 'ff7f',
      32768: '008000',
      -32768: '008080',
      2147483647: 'ffffff7f',
      -2147483647: 'ffffffff',
      // 2^31 needs a fifth byte because the top bit of four bytes is set.
      2147483648: '0000008000',
      -2147483648: '0000008080',
    };

    for (final entry in cases.entries) {
      test('encodes ${entry.key} as ${entry.value}', () {
        expect(hexEncode(encodeScriptNumber(entry.key)), entry.value);
      });
    }
  });

  group('decodeScriptNumber', () {
    test('empty array is zero', () {
      expect(decodeScriptNumber(const <int>[]), 0);
    });

    test('decodes the boundary values', () {
      expect(decodeScriptNumber(hexDecode('01')), 1);
      expect(decodeScriptNumber(hexDecode('81')), -1);
      expect(decodeScriptNumber(hexDecode('7f')), 127);
      expect(decodeScriptNumber(hexDecode('8000')), 128);
      expect(decodeScriptNumber(hexDecode('8080')), -128);
      expect(decodeScriptNumber(hexDecode('ff00')), 255);
      expect(decodeScriptNumber(hexDecode('0001')), 256);
      expect(decodeScriptNumber(hexDecode('ff7f')), 32767);
      expect(decodeScriptNumber(hexDecode('008000')), 32768);
    });

    test('maximum and minimum 4-byte values', () {
      expect(decodeScriptNumber(hexDecode('ffffff7f')), 2147483647);
      expect(decodeScriptNumber(hexDecode('ffffffff')), -2147483647);
    });

    test('round trips every value in a sample', () {
      final values = <int>[
        0,
        1,
        -1,
        2,
        -2,
        16,
        17,
        127,
        -127,
        128,
        -129,
        255,
        -255,
        4096,
        -65535,
        65536,
        8388607,
        -8388608,
        2147483647,
        -2147483647,
        2147483648,
        -2147483648,
        4294967295,
      ];
      for (final value in values) {
        expect(
          decodeScriptNumber(encodeScriptNumber(value), maxLength: 5),
          value,
          reason: 'value $value',
        );
      }
    });

    test('rejects a non-minimal encoding with a trailing zero byte', () {
      expect(
        () => decodeScriptNumber(hexDecode('0100')),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => decodeScriptNumber(hexDecode('0000')),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects negative zero', () {
      expect(
        () => decodeScriptNumber(hexDecode('80')),
        throwsA(isA<FormatException>()),
      );
    });

    test('accepts a non-minimal encoding when minimal is not required', () {
      expect(decodeScriptNumber(hexDecode('0100'), requireMinimal: false), 1);
      expect(decodeScriptNumber(hexDecode('80'), requireMinimal: false), 0);
    });

    test('accepts a trailing zero byte that carries the sign bit', () {
      expect(decodeScriptNumber(hexDecode('8000')), 128);
    });

    test('rejects a 5-byte number when maxLength is 4', () {
      expect(
        () => decodeScriptNumber(hexDecode('0000008000')),
        throwsA(isA<FormatException>()),
      );
    });

    test('accepts a 5-byte number with maxLength 5', () {
      expect(
        decodeScriptNumber(hexDecode('0000008000'), maxLength: 5),
        2147483648,
      );
    });

    test('rejects a maxLength outside 1 to 7', () {
      expect(
        () => decodeScriptNumber(const <int>[1], maxLength: 8),
        throwsA(isA<RangeError>()),
      );
    });
  });

  group('castToBool', () {
    test('empty array is false', () {
      expect(castToBool(const <int>[]), isFalse);
    });

    test('all zero bytes are false', () {
      expect(castToBool(hexDecode('0000')), isFalse);
    });

    test('negative zero is false', () {
      expect(castToBool(hexDecode('80')), isFalse);
      expect(castToBool(hexDecode('0080')), isFalse);
    });

    test('any other non-zero byte is true', () {
      expect(castToBool(hexDecode('01')), isTrue);
      expect(castToBool(hexDecode('81')), isTrue);
      expect(castToBool(hexDecode('0000f0')), isTrue);
      expect(castToBool(hexDecode('8000')), isTrue);
    });
  });
}
