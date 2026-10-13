import 'package:flutter_test/flutter_test.dart';
import 'package:sato_wiki/src/features/tools/domain/address_analyzer.dart';
import 'package:sato_wiki/src/features/tools/domain/base58.dart';
import 'package:sato_wiki/src/features/tools/domain/bech32.dart';
import 'package:sato_wiki/src/features/tools/domain/tools_bytes.dart';

// Official vectors:
// - genesis block address 1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa (hash160 62e9...)
// - BIP173 mainnet P2WPKH, mainnet P2WSH and testnet P2WPKH/P2WSH examples
// - BIP350 valid and invalid address lists (taproot, v2 and error cases)
// - BIP32 test vector 1 extended public key
//
// Built in the test, not official: testnet and P2SH Base58Check strings (built
// from the genesis hash160), the regtest address, the WIF-shaped strings (built
// from dummy bytes, never a real key) and the unknown-version string.

const _genesisHash160 = '62e907b15cbf27d5425399ebf6f0fb50ebb88f18';
const _genesisAddress = '1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa';
const _mainnetP2wpkh = 'bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4';
const _mainnetP2wsh =
    'bc1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3qccfmv3';
const _testnetP2wpkh = 'tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx';
const _testnetP2wsh =
    'tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3q0sl5k7';
const _taproot =
    'bc1p0xlxvlhemja6c4dqv22uapctqupfhlxm9h8z3k2e72q4k9hcz7vqzk5jj0';
const _bip32Xpub =
    'xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8';

/// Genesis address with one character changed (still in the alphabet).
String _withChangedCharacter(String text, int index) {
  final replacement = text[index] == 'a' ? 'b' : 'a';

  return text.substring(0, index) + replacement + text.substring(index + 1);
}

void main() {
  final hash160 = hexDecode(_genesisHash160);

  group('kinds', () {
    test('mainnet P2PKH from the genesis address', () {
      final result = analyzeAddress(_genesisAddress);
      expect(result.kind, AddressKind.p2pkh);
      expect(result.network, BitcoinNetwork.mainnet);
      expect(result.encoding, AddressEncoding.base58check);
      expect(result.checksumValid, isTrue);
      expect(result.versionByte, 0x00);
      expect(hexEncode(result.payload!), _genesisHash160);
      expect(result.humanReadablePart, isNull);
      expect(result.error, isNull);
    });

    test('mainnet P2SH (built from the genesis hash160)', () {
      final address = base58CheckEncode(0x05, hash160);
      final result = analyzeAddress(address);
      expect(result.kind, AddressKind.p2sh);
      expect(result.network, BitcoinNetwork.mainnet);
      expect(result.versionByte, 0x05);
      expect(hexEncode(result.payload!), _genesisHash160);
    });

    test('testnet P2PKH (built from the genesis hash160)', () {
      final address = base58CheckEncode(0x6f, hash160);
      final result = analyzeAddress(address);
      expect(result.kind, AddressKind.p2pkh);
      expect(result.network, BitcoinNetwork.testnet);
      expect(result.versionByte, 0x6f);
    });

    test('testnet P2SH (built from the genesis hash160)', () {
      final address = base58CheckEncode(0xc4, hash160);
      final result = analyzeAddress(address);
      expect(result.kind, AddressKind.p2sh);
      expect(result.network, BitcoinNetwork.testnet);
      expect(result.versionByte, 0xc4);
    });

    test('mainnet P2WPKH (BIP173 example)', () {
      final result = analyzeAddress(_mainnetP2wpkh);
      expect(result.kind, AddressKind.p2wpkh);
      expect(result.network, BitcoinNetwork.mainnet);
      expect(result.encoding, AddressEncoding.bech32);
      expect(result.checksumValid, isTrue);
      expect(result.witnessVersion, 0);
      expect(result.humanReadablePart, 'bc');
      expect(
        hexEncode(result.payload!),
        '751e76e8199196d454941c45d1b3a323f1433bd6',
      );
    });

    test('mainnet P2WSH (BIP173 example)', () {
      final result = analyzeAddress(_mainnetP2wsh);
      expect(result.kind, AddressKind.p2wsh);
      expect(result.network, BitcoinNetwork.mainnet);
      expect(result.encoding, AddressEncoding.bech32);
      expect(result.payload!.length, 32);
    });

    test('testnet P2WPKH (BIP173 example)', () {
      final result = analyzeAddress(_testnetP2wpkh);
      expect(result.kind, AddressKind.p2wpkh);
      expect(result.network, BitcoinNetwork.testnet);
      expect(result.humanReadablePart, 'tb');
    });

    test('testnet P2WSH (BIP173 example)', () {
      final result = analyzeAddress(_testnetP2wsh);
      expect(result.kind, AddressKind.p2wsh);
      expect(result.network, BitcoinNetwork.testnet);
    });

    test('regtest P2WPKH (built with the bcrt prefix)', () {
      final address = encodeSegwitAddress('bcrt', 0, hash160);
      final result = analyzeAddress(address);
      expect(result.kind, AddressKind.p2wpkh);
      expect(result.network, BitcoinNetwork.regtest);
      expect(result.humanReadablePart, 'bcrt');
    });

    test('taproot from the BIP350 examples', () {
      final result = analyzeAddress(_taproot);
      expect(result.kind, AddressKind.p2tr);
      expect(result.network, BitcoinNetwork.mainnet);
      expect(result.encoding, AddressEncoding.bech32m);
      expect(result.witnessVersion, 1);
      expect(
        hexEncode(result.payload!),
        '79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798',
      );
    });

    test('unknown witness version 2 is witnessUnknown', () {
      final result = analyzeAddress('bc1zw508d6qejxtdg4y5r3zarvaryvaxxpcs');
      expect(result.kind, AddressKind.witnessUnknown);
      expect(result.witnessVersion, 2);
      expect(result.encoding, AddressEncoding.bech32m);
    });

    test('leading and trailing spaces are ignored', () {
      expect(analyzeAddress('  $_genesisAddress \n').kind, AddressKind.p2pkh);
    });

    test('WIF mainnet key shape keeps no payload', () {
      final wif = base58CheckEncode(0x80, List<int>.filled(32, 1));
      final result = analyzeAddress(wif);
      expect(result.kind, AddressKind.privateKeyWif);
      expect(result.network, BitcoinNetwork.mainnet);
      expect(result.versionByte, 0x80);
      expect(result.payload, isNull);
      expect(result.error, isNull);
    });

    test('WIF testnet key shape with compressed flag keeps no payload', () {
      final wif = base58CheckEncode(0xef, List<int>.filled(33, 1));
      final result = analyzeAddress(wif);
      expect(result.kind, AddressKind.privateKeyWif);
      expect(result.network, BitcoinNetwork.testnet);
      expect(result.payload, isNull);
    });

    test('BIP32 test vector 1 xpub is an extendedKey', () {
      final result = analyzeAddress(_bip32Xpub);
      expect(result.kind, AddressKind.extendedKey);
      expect(result.encoding, AddressEncoding.base58check);
      expect(result.checksumValid, isTrue);
      expect(result.payload, isNull);
    });
  });

  group('errors', () {
    test('empty and blank input is empty', () {
      for (final input in ['', '   ']) {
        final result = analyzeAddress(input);
        expect(result.kind, AddressKind.invalid);
        expect(result.error, AddressError.empty);
      }
    });

    test('base58 checksum mismatch is badChecksum', () {
      final result = analyzeAddress(_withChangedCharacter(_genesisAddress, 10));
      expect(result.kind, AddressKind.invalid);
      expect(result.encoding, AddressEncoding.base58check);
      expect(result.checksumValid, isFalse);
      expect(result.error, AddressError.badChecksum);
    });

    test('base58 payload of 19 bytes is badLength', () {
      final address = base58CheckEncode(0x00, List<int>.filled(19, 1));
      final result = analyzeAddress(address);
      expect(result.kind, AddressKind.invalid);
      expect(result.error, AddressError.badLength);
    });

    test('base58 string shorter than version plus checksum is badLength', () {
      final result = analyzeAddress('1111');
      expect(result.kind, AddressKind.invalid);
      expect(result.error, AddressError.badLength);
    });

    test('unknown base58 version is unknownVersion', () {
      final address = base58CheckEncode(0x30, hash160);
      final result = analyzeAddress(address);
      expect(result.kind, AddressKind.invalid);
      expect(result.error, AddressError.unknownVersion);
      expect(result.versionByte, 0x30);
      expect(result.checksumValid, isTrue);
    });

    test('a character outside the bech32 alphabet is badCharacter', () {
      final result = analyzeAddress('x1b4n0q5v');
      expect(result.kind, AddressKind.invalid);
      expect(result.error, AddressError.badCharacter);
    });

    test('a segwit string with a bad checksum character is badCharacter', () {
      final result = analyzeAddress(
        'bc1p38j9r5y49hruaue7wxjce0updqjuyyx0kh56v8s25huc6995vvpql3jow4',
      );
      expect(result.kind, AddressKind.invalid);
      expect(result.error, AddressError.badCharacter);
    });

    test('mixed-case bech32 is mixedCase', () {
      final result = analyzeAddress(
        'tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3q0sL5k7',
      );
      expect(result.kind, AddressKind.invalid);
      expect(result.error, AddressError.mixedCase);
    });

    test('version 0 address with a bech32m checksum is wrongBech32Variant', () {
      final result = analyzeAddress(
        'bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kemeawh',
      );
      expect(result.kind, AddressKind.invalid);
      expect(result.error, AddressError.wrongBech32Variant);
      expect(result.encoding, AddressEncoding.bech32m);
      expect(result.checksumValid, isTrue);
    });

    test('version 1 address with a bech32 checksum is wrongBech32Variant', () {
      final result = analyzeAddress(
        'bc1p0xlxvlhemja6c4dqv22uapctqupfhlxm9h8z3k2e72q4k9hcz7vqh2y7hd',
      );
      expect(result.kind, AddressKind.invalid);
      expect(result.error, AddressError.wrongBech32Variant);
      expect(result.encoding, AddressEncoding.bech32);
    });

    test('unknown human-readable part is unknownHrp', () {
      final result = analyzeAddress(
        'tc1p0xlxvlhemja6c4dqv22uapctqupfhlxm9h8z3k2e72q4k9hcz7vq5zuyut',
      );
      expect(result.kind, AddressKind.invalid);
      expect(result.error, AddressError.unknownHrp);
      expect(result.humanReadablePart, 'tc');
      expect(result.encoding, AddressEncoding.bech32m);
    });

    test('bech32 without separator is missingSeparator', () {
      final result = analyzeAddress('pzry9x0s0muk');
      expect(result.kind, AddressKind.invalid);
      expect(result.error, AddressError.missingSeparator);
    });

    test('bech32 with empty human-readable part is emptyHumanReadablePart', () {
      final result = analyzeAddress('1pzry9x0s0muk');
      expect(result.kind, AddressKind.invalid);
      expect(result.error, AddressError.emptyHumanReadablePart);
    });

    test('segwit with no data is emptyData', () {
      final result = analyzeAddress('bc1gmk9yu');
      expect(result.kind, AddressKind.invalid);
      expect(result.error, AddressError.emptyData);
    });

    test('segwit with a one-byte program is badLength', () {
      final result = analyzeAddress('bc1pw5dgrnzv');
      expect(result.kind, AddressKind.invalid);
      expect(result.error, AddressError.badLength);
    });

    test('version 0 with a 16-byte program is badLength', () {
      final result = analyzeAddress('BC1QR508D6QEJXTDG4Y5R3ZARVARYV98GJ9P');
      expect(result.kind, AddressKind.invalid);
      expect(result.error, AddressError.badLength);
    });

    test('witness version 17 is unknownVersion', () {
      final result = analyzeAddress(
        'BC130XLXVLHEMJA6C4DQV22UAPCTQUPFHLXM9H8Z3K2E72Q4K9HCZ7VQ7ZWS8R',
      );
      expect(result.kind, AddressKind.invalid);
      expect(result.error, AddressError.unknownVersion);
    });

    test('non-zero padding is invalidPadding', () {
      final result = analyzeAddress(
        'tb1p0xlxvlhemja6c4dqv22uapctqupfhlxm9h8z3k2e72q4k9hcz7vpggkg4j',
      );
      expect(result.kind, AddressKind.invalid);
      expect(result.error, AddressError.invalidPadding);
    });
  });

  test('never throws on odd input', () {
    for (final input in ['bc1', '1', '\u0000', 'bcrt1', '🙂', 'tb1q', '0']) {
      expect(() => analyzeAddress(input), returnsNormally, reason: input);
      expect(analyzeAddress(input).kind, AddressKind.invalid, reason: input);
    }
  });
}
