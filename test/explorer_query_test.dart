import 'package:flutter_test/flutter_test.dart';
import 'package:sato_wiki/src/features/tools/data/explorer_query.dart';
import 'package:sato_wiki/src/features/tools/domain/base58.dart';
import 'package:sato_wiki/src/features/tools/domain/tools_bytes.dart';

// Address vectors are the ones in test/tools_address_analyzer_test.dart.
const _genesisHash160 = '62e907b15cbf27d5425399ebf6f0fb50ebb88f18';
const _genesisAddress = '1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa';
const _mainnetP2wpkh = 'bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4';
const _mainnetP2wsh =
    'bc1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3qccfmv3';
const _taproot =
    'bc1p0xlxvlhemja6c4dqv22uapctqupfhlxm9h8z3k2e72q4k9hcz7vqzk5jj0';
const _unknownWitnessV2 = 'bc1zw508d6qejxtdg4y5r3zarvaryvaxxpcs';
const _bip32Xpub =
    'xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8';
final _hash = 'ab' * 32;

void main() {
  group('heights', () {
    test('one to eight digits are heights', () {
      expect((parseExplorerQuery('0') as ExplorerHeightQuery).height, 0);
      expect(
        (parseExplorerQuery('850000') as ExplorerHeightQuery).height,
        850000,
      );
      expect(
        (parseExplorerQuery('12345678') as ExplorerHeightQuery).height,
        12345678,
      );
    });

    test('nine digits are not a height', () {
      expect(parseExplorerQuery('123456789'), isNull);
    });
  });

  group('hashes', () {
    test('64 hex characters are a hash, stored in lower case', () {
      final query = parseExplorerQuery(_hash.toUpperCase());

      expect(query, isA<ExplorerHashQuery>());
      expect((query! as ExplorerHashQuery).hash, _hash);
    });

    test('a block hash with 8 leading zeros looks like a block hash', () {
      final query =
          parseExplorerQuery(
                '000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f',
              )
              as ExplorerHashQuery;

      expect(query.looksLikeBlockHash, isTrue);
    });

    test('a txid without leading zeros does not look like a block hash', () {
      final query = parseExplorerQuery(_hash) as ExplorerHashQuery;

      expect(query.looksLikeBlockHash, isFalse);
    });

    test('63 hex characters are not a hash', () {
      expect(parseExplorerQuery('ab' * 31 + 'a'), isNull);
    });
  });

  group('addresses', () {
    test('mainnet P2PKH', () {
      expect(parseExplorerQuery(_genesisAddress), isA<ExplorerAddressQuery>());
    });

    test('mainnet and testnet P2SH and testnet P2PKH', () {
      final hash160 = hexDecode(_genesisHash160);
      for (final address in [
        base58CheckEncode(0x05, hash160),
        base58CheckEncode(0xc4, hash160),
        base58CheckEncode(0x6f, hash160),
      ]) {
        expect(parseExplorerQuery(address), isA<ExplorerAddressQuery>());
      }
    });

    test('P2WPKH, P2WSH and P2TR', () {
      for (final address in [_mainnetP2wpkh, _mainnetP2wsh, _taproot]) {
        expect(parseExplorerQuery(address), isA<ExplorerAddressQuery>());
      }
    });

    test('unknown witness version is witnessUnknown and accepted', () {
      final query = parseExplorerQuery(_unknownWitnessV2);

      expect(query, isA<ExplorerAddressQuery>());
      expect((query! as ExplorerAddressQuery).address, _unknownWitnessV2);
    });

    test('surrounding spaces and newlines are trimmed', () {
      final query = parseExplorerQuery('  $_genesisAddress \n');

      expect((query! as ExplorerAddressQuery).address, _genesisAddress);
      expect(
        (parseExplorerQuery('  850000\t') as ExplorerHeightQuery).height,
        850000,
      );
    });
  });

  group('never searched', () {
    test('a WIF private key is null', () {
      final wif = base58CheckEncode(0x80, List<int>.filled(32, 1));

      expect(parseExplorerQuery(wif), isNull);
    });

    test('an extended public key is null', () {
      expect(parseExplorerQuery(_bip32Xpub), isNull);
    });

    test('garbage is null', () {
      for (final input in ['hello world', 'not-an-address', '!!!', 'bc1']) {
        expect(parseExplorerQuery(input), isNull, reason: input);
      }
    });

    test('empty and blank input are null', () {
      for (final input in ['', '   ']) {
        expect(parseExplorerQuery(input), isNull, reason: input);
      }
    });
  });
}
