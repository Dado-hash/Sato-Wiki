import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sato_wiki/src/features/tools/domain/base58.dart';
import 'package:sato_wiki/src/features/tools/domain/hash160.dart';
import 'package:sato_wiki/src/features/tools/domain/tools_bytes.dart';

// Base58 pairs copied from Bitcoin Core src/test/data/base58_encode_decode.json
// (github.com/bitcoin/bitcoin master, fetched during development).

const _corePairs = [
  ('', ''),
  ('61', '2g'),
  ('626262', 'a3gV'),
  ('636363', 'aPEr'),
  ('73696d706c792061206c6f6e6720737472696e67', '2cFupjhnEsSn59qHXstmK2ffpLv2'),
  (
    '00eb15231dfceb60925886b67d065299925915aeb172c06647',
    '1NS17iag9jJgTHD1VXjvLCEnZuQ3rJDE9L',
  ),
  ('516b6fcd0f', 'ABnLTmg'),
  ('bf4f89001e670274dd', '3SEo3LWLoPntC'),
  ('572e4794', '3EFU7m'),
  ('ecac89cad93923c02321', 'EJDM8drfXA6uyA'),
  ('10c8511e', 'Rt5zm'),
  ('00000000000000000000', '1111111111'),
  (
    '00000000000000000000000000000000000000000000000000000000000000000000000000000000',
    '1111111111111111111111111111111111111111',
  ),
  (
    '00000000000000000000000000000000000000000000000000000000000000000000000000000001',
    '1111111111111111111111111111111111111112',
  ),
  (
    '0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ec39d04c37e71e5d591881f6',
    '111111111111111111111111111111111111111111111111111111111111111111111111111111111111115TYzLYH1udmLdzCLM',
  ),
  (
    '000111d38e5fc9071ffcd20b4a763cc9ae4f252bb4e48fd66a835e252ada93ff480d6dd43dc62a641155a5',
    '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz',
  ),
  (
    '000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9fa0a1a2a3a4a5a6a7a8a9aaabacadaeafb0b1b2b3b4b5b6b7b8b9babbbcbdbebfc0c1c2c3c4c5c6c7c8c9cacbcccdcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedfe0e1e2e3e4e5e6e7e8e9eaebecedeeeff0f1f2f3f4f5f6f7f8f9fafbfcfdfeff',
    '1cWB5HCBdLjAuqGGReWE3R3CguuwSjw6RHn39s2yuDRTS5NsBgNiFpWgAnEx6VQi8csexkgYw3mdYrMHr8x9i7aEwP8kZ7vccXWqKDvGv3u1GxFKPuAkn8JCPPGDMf3vMMnbzm6Nh9zh1gcNsMvH3ZNLmP5fSG6DGbbi2tuwMWPthr4boWwCxf7ewSgNQeacyozhKDDQQ1qL5fQFUW52QKUZDZ5fw3KXNQJMcNTcaB723LchjeKun7MuGW5qyCBZYzA1KjofN1gYBV3NqyhQJ3Ns746GNuf9N2pQPmHz4xpnSrrfCvy6TVVz5d4PdrjeshsWQwpZsZGzvbdAdN8MKV5QsBDY',
  ),
  ('271F359E', 'zzzzy'),
  ('271F359F', 'zzzzz'),
  ('271F35A0', '211111'),
  ('271F35A1', '211112'),
];

Uint8List _bytes(String hex) => hex.isEmpty ? Uint8List(0) : hexDecode(hex);

void main() {
  group('Bitcoin Core base58 vectors', () {
    test('encode matches the reference strings', () {
      for (final (hex, text) in _corePairs) {
        expect(base58Encode(_bytes(hex)), text, reason: hex);
      }
    });

    test('decode matches the reference bytes', () {
      for (final (hex, text) in _corePairs) {
        expect(hexEncode(base58Decode(text)), hex.toLowerCase(), reason: text);
      }
    });
  });

  group('Base58Check', () {
    const genesisAddress = '1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa';
    const genesisHash160 = '62e907b15cbf27d5425399ebf6f0fb50ebb88f18';

    test('genesis block address decodes to version 0 and its hash160', () {
      final data = base58CheckDecode(genesisAddress);
      expect(data.version, 0);
      expect(hexEncode(data.payload), genesisHash160);
    });

    test('genesis hash160 encodes back to the genesis address', () {
      expect(base58CheckEncode(0, hexDecode(genesisHash160)), genesisAddress);
    });

    test('round trip keeps version and payload', () {
      final payload = hexDecode(genesisHash160);
      for (final version in [0x05, 0x6f, 0xc4, 0x80, 0xef]) {
        final text = base58CheckEncode(version, payload);
        final data = base58CheckDecode(text);
        expect(data.version, version);
        expect(hexEncode(data.payload), genesisHash160);
      }
    });

    test('leading zero bytes become leading 1 characters', () {
      expect(base58Encode([0, 0, 0]), '111');
      expect(base58Encode([0, 0, 1]), '112');
      expect(base58Decode('112'), [0, 0, 1]);
      expect(base58CheckEncode(0, List<int>.filled(20, 0)), startsWith('1111'));
      final data = base58CheckDecode(
        base58CheckEncode(0, List<int>.filled(20, 0)),
      );
      expect(data.version, 0);
      expect(data.payload, List<int>.filled(20, 0));
    });

    test('a changed character gives a checksum error', () {
      final flipped =
          genesisAddress.substring(0, 10) +
          (genesisAddress[10] == 'a' ? 'b' : 'a') +
          genesisAddress.substring(11);
      expect(
        () => base58CheckDecode(flipped),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('checksum'),
          ),
        ),
      );
    });

    test('data shorter than version plus checksum is rejected', () {
      expect(() => base58CheckDecode('1111'), throwsFormatException);
    });

    test('characters outside the alphabet are rejected', () {
      for (final bad in ['0', 'O', 'I', 'l']) {
        final text = '1A1zP1eP5QGefi2DMPTfTL5SLmv7Div${bad}a';
        expect(() => base58Decode(text), throwsFormatException, reason: text);
        expect(
          () => base58CheckDecode(text),
          throwsFormatException,
          reason: text,
        );
      }
    });
  });

  group('hash160', () {
    test('public key hashes to the known hash160', () {
      final publicKey = hexDecode(
        '04678afdb0fe5548271967f1a67130b7105cd6a828e03909a67962e0ea1f61deb649f6bc3f4cef38c4f35504e51ec112de5c384df7ba0b8d578a4c702b6bf11d5f',
      );
      expect(
        hexEncode(hash160(publicKey)),
        '62e907b15cbf27d5425399ebf6f0fb50ebb88f18',
      );
    });
  });
}
