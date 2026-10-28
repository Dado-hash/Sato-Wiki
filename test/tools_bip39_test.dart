import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter_test/flutter_test.dart';
import 'package:sato_wiki/src/features/tools/domain/bip39.dart';
import 'package:sato_wiki/src/features/tools/domain/bip39_wordlist_en.dart';

// Wordlist checked against bitcoin/bips bip-0039/english.txt (SHA-256 below).
// Vectors marked "Trezor" are from trezor/python-mnemonic vectors.json; the
// others were computed independently with hashlib and cross-checked.

String _wordsOf(Bip39Mnemonic mnemonic) {
  return [
    for (var i = 0; i < mnemonic.wordCount; i++) mnemonic.wordAt(i),
  ].join(' ');
}

Uint8List _filled(int length, int byte) =>
    Uint8List.fromList(List.filled(length, byte));

void main() {
  group('BIP39 English wordlist', () {
    test('has 2048 unique, sorted words', () {
      expect(bip39EnglishWordlist, hasLength(2048));
      expect(bip39EnglishWordlist.toSet(), hasLength(2048));
      final sorted = List<String>.of(bip39EnglishWordlist)..sort();
      expect(bip39EnglishWordlist, sorted);
    });

    test('starts with abandon and ends with zoo', () {
      expect(bip39EnglishWordlist.first, 'abandon');
      expect(bip39EnglishWordlist.last, 'zoo');
    });

    test('matches the official file hash', () {
      final text = '${bip39EnglishWordlist.join('\n')}\n';
      final digest = crypto.sha256.convert(utf8.encode(text)).toString();
      expect(
        digest,
        '2f5eed53a4727b4bf8880d8f3f199efc90e58503646d9ff8eff3a2ed3b24dbda',
      );
    });
  });

  group('Bip39Mnemonic vectors', () {
    test('16 zero bytes give twelve abandon words ending in about', () {
      final mnemonic = Bip39Mnemonic.fromEntropy(_filled(16, 0));
      expect(
        _wordsOf(mnemonic),
        'abandon abandon abandon abandon abandon abandon abandon abandon '
        'abandon abandon abandon about',
      );
    });

    test('Trezor vectors for 16, 20, 24, 28 and 32 bytes', () {
      final cases = <(Uint8List, String)>[
        (
          _filled(16, 0x7f),
          'legal winner thank year wave sausage worth useful legal winner '
              'thank yellow',
        ),
        (
          _filled(16, 0x80),
          'letter advice cage absurd amount doctor acoustic avoid letter '
              'advice cage above',
        ),
        (
          _filled(16, 0xff),
          'zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo wrong',
        ),
        (_filled(20, 0x00), 'abandon ' * 14 + 'address'),
        (
          _filled(20, 0x7f),
          'legal winner thank year wave sausage worth useful legal winner '
              'thank year wave sausage wise',
        ),
        (_filled(24, 0xff), 'zoo ' * 17 + 'when'),
        (
          _filled(28, 0x7f),
          'legal winner thank year wave sausage worth useful legal winner '
              'thank year wave sausage worth useful legal winner thank year '
              'viable',
        ),
        (_filled(32, 0x00), 'abandon ' * 23 + 'art'),
        (_filled(32, 0xff), 'zoo ' * 23 + 'vote'),
        (
          _filled(32, 0x7f),
          'legal winner thank year wave sausage worth useful ' * 2 +
              'legal winner thank year wave sausage worth title',
        ),
      ];

      for (final (entropy, words) in cases) {
        final expected = words.trim();
        expect(
          _wordsOf(Bip39Mnemonic.fromEntropy(entropy)),
          expected,
          reason: 'entropy ${entropy.length} bytes, first ${entropy.first}',
        );
      }
    });

    test('SHA-256 of 123456 as 24-word entropy', () {
      final entropy = Uint8List.fromList(
        crypto.sha256.convert(utf8.encode('123456')).bytes,
      );
      expect(
        _wordsOf(Bip39Mnemonic.fromEntropy(entropy)),
        'mirror reject rookie talk pudding throw happy era myth already '
        'payment own sentence push head sting video explain letter bomb '
        'casual hotel rather garment',
      );
    });
  });

  group('Bip39Mnemonic structure', () {
    test('lengths for every supported entropy size', () {
      const expected = {
        16: (128, 4, 12),
        20: (160, 5, 15),
        24: (192, 6, 18),
        28: (224, 7, 21),
        32: (256, 8, 24),
      };
      for (final entry in expected.entries) {
        final mnemonic = Bip39Mnemonic.fromEntropy(_filled(entry.key, 1));
        final (ent, cs, words) = entry.value;
        expect(mnemonic.entropyBitLength, ent);
        expect(mnemonic.checksumBitLength, cs);
        expect(mnemonic.wordCount, words);
        expect(mnemonic.indices, hasLength(words));
        expect(mnemonic.bitString(), hasLength(ent + cs));
      }
    });

    test('bitString, bitGroups and checksum for 32 x 0x7f', () {
      final mnemonic = Bip39Mnemonic.fromEntropy(_filled(32, 0x7f));
      final bits = mnemonic.bitString();

      expect(bits, hasLength(264));
      expect(bits.substring(256), '00010111');
      expect(bits.substring(0, 8), '01111111');

      final groups = mnemonic.bitGroups();
      expect(groups, hasLength(24));
      expect(groups.every((group) => group.length == 11), isTrue);
      expect(groups.join(), bits);
      expect(groups.first, '01111111011');
      expect(mnemonic.indices.first, 1019);
      expect(mnemonic.wordAt(0), 'legal');
      expect(mnemonic.wordAt(23), 'title');
    });

    test('indices agree with the bit groups', () {
      final mnemonic = Bip39Mnemonic.fromEntropy(_filled(16, 0xa5));
      final groups = mnemonic.bitGroups();
      for (var i = 0; i < groups.length; i++) {
        expect(mnemonic.indices[i], int.parse(groups[i], radix: 2));
      }
    });

    test('copies the input entropy', () {
      final input = _filled(16, 0x42);
      final mnemonic = Bip39Mnemonic.fromEntropy(input);
      input.fillRange(0, input.length, 0);

      expect(mnemonic.entropy, _filled(16, 0x42));
    });

    test('bad entropy lengths throw ArgumentError', () {
      for (final length in [0, 1, 15, 17, 31, 33, 64]) {
        expect(
          () => Bip39Mnemonic.fromEntropy(_filled(length, 0)),
          throwsArgumentError,
          reason: 'length $length',
        );
      }
    });

    test('wordAt rejects out of range positions', () {
      final mnemonic = Bip39Mnemonic.fromEntropy(_filled(16, 0));
      expect(() => mnemonic.wordAt(12), throwsRangeError);
      expect(() => mnemonic.wordAt(-1), throwsRangeError);
    });
  });

  group('Bip39Mnemonic.wipe', () {
    test('zeroes entropy and indices and marks the mnemonic wiped', () {
      final mnemonic = Bip39Mnemonic.fromEntropy(_filled(32, 0x7f));
      final entropy = mnemonic.entropy;
      final indices = mnemonic.indices;
      expect(mnemonic.isWiped, isFalse);

      mnemonic.wipe();

      expect(mnemonic.isWiped, isTrue);
      expect(entropy.every((byte) => byte == 0), isTrue);
      expect(indices.every((index) => index == 0), isTrue);
    });

    test('wiped mnemonic refuses to render words or bits', () {
      final mnemonic = Bip39Mnemonic.fromEntropy(_filled(16, 0x7f));
      mnemonic.wipe();

      expect(() => mnemonic.wordAt(0), throwsStateError);
      expect(() => mnemonic.bitString(), throwsStateError);
      expect(() => mnemonic.bitGroups(), throwsStateError);
    });
  });
}
