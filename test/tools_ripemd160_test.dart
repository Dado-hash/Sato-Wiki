import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sato_wiki/src/features/tools/domain/hash160.dart';
import 'package:sato_wiki/src/features/tools/domain/ripemd160.dart';
import 'package:sato_wiki/src/features/tools/domain/tools_bytes.dart';

// RIPEMD-160 vectors from the authors' page
// https://homes.esat.kuleuven.be/~bosselae/ripemd160.html (fetched during
// development). hash160 vector from the Bitcoin genesis public key.

void main() {
  group('ripemd160 vectors', () {
    const vectors = <String, String>{
      '': '9c1185a5c5e9fc54612808977ee8f548b2258d31',
      'a': '0bdc9d2d256b3ee9daae347be6f4dc835a467ffe',
      'abc': '8eb208f7e05d987a9b044a8e98c6b087f15a0bfc',
      'message digest': '5d0689ef49d2fae572b881b123a85ffa21595f36',
      'abcdefghijklmnopqrstuvwxyz': 'f71c27109c692c1b56bbdceb5b9d2865b3708dbc',
      'abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq':
          '12a053384a9c0c88e405a06c27dcf49ada62eb2b',
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789':
          'b0e20b6e3116640286ed3a87a5713079b21f5189',
      '12345678901234567890123456789012345678901234567890123456789012345678901234567890':
          '9b752e45573d4b39f4dbd3323cab82bf63326bfb',
    };

    vectors.forEach((message, digest) {
      test('"$message"', () {
        final hash = ripemd160(utf8.encode(message));
        expect(hash.length, 20);
        expect(hexEncode(hash), digest);
      });
    });

    test('one million "a" characters', () {
      final message = utf8.encode('a' * 1000000);
      expect(
        hexEncode(ripemd160(message)),
        '52783243c1697bdbe16d37f97f68f08325dc1528',
      );
    });
  });

  group('hash160', () {
    test('public key hashes to the genesis hash160', () {
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
