import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sato_wiki/src/features/tools/data/esplora_models.dart';

// Fixtures follow the field names of the Esplora API.md. The genesis block and
// its coinbase transaction carry their real values; the segwit transaction and
// the status values are hand-built.
const _genesisId =
    '000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f';
const _genesisCoinbaseTxid =
    '4a5e1e4baab89f3a32518a88c31bc87f618f76673e2cc77ab2127b7afdeda33b';
const _genesisAddress = '1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa';
const _segwitTxid =
    '19b07dc823648870150e9425aa994195f4250511784eece89eefe8d75a13e00d';
const _segwitPrevTxid =
    '142b72c2847faee404e6b4d2c2bda64339fd5cf52c5bf87735c036e95d4a4868';
const _blockHash850000 =
    'f8ffe0e0425c3ac96d1f2642b4d2d1ab96967b0f3fab2b43935784896982c5f0';

final _blockJson = <String, Object?>{
  'id': _genesisId,
  'height': 0,
  'version': 1,
  'timestamp': 1231006505,
  'tx_count': 1,
  'size': 285,
  'weight': 1140,
  'merkle_root':
      '4a5e1e4baab89f3a32518a88c31bc87f618f76673e2cc77ab2127b7afdeda33b',
  'nonce': 2083236893,
  'bits': 486604799,
  'difficulty': 1,
  'mediantime': 1231006505,
};

final _coinbaseJson = <String, Object?>{
  'txid': _genesisCoinbaseTxid,
  'version': 1,
  'locktime': 0,
  'size': 204,
  'weight': 816,
  'vin': [
    {
      'txid':
          '0000000000000000000000000000000000000000000000000000000000000000',
      'vout': 4294967295,
      'is_coinbase': true,
      'scriptsig':
          '04ffff001d0104455468652054696d65732030332f4a616e2f323030392043'
          '68616e63656c6c6f72206f6e206272696e6b206f66207365636f6e64206261696c'
          '6f757420666f722062616e6b73',
      'scriptsig_asm': 'OP_PUSHBYTES_4 ffff001d OP_PUSHBYTES_1 04',
      'sequence': 4294967295,
      'witness': <String>[],
      'prevout': null,
    },
  ],
  'vout': [
    {
      'scriptpubkey':
          '4104678afdb0fe5548271967f1a67130b7105cd6a828e03909a67962e0ea1f61'
          'deb649f6bc3f4cef38c4f35504e51ec112de5c384df7ba0b8d578a4c702b6bf11'
          'd5fac',
      'scriptpubkey_asm': 'OP_PUSHBYTES_65 OP_CHECKSIG',
      'scriptpubkey_type': 'p2pk',
      'value': 5000000000,
    },
  ],
  'status': {
    'confirmed': true,
    'block_height': 0,
    'block_hash': _genesisId,
    'block_time': 1231006505,
  },
};

final _segwitJson = <String, Object?>{
  'txid': _segwitTxid,
  'version': 2,
  'locktime': 0,
  'size': 222,
  'weight': 561,
  'fee': 1500,
  'vin': [
    {
      'txid': _segwitPrevTxid,
      'vout': 1,
      'is_coinbase': false,
      'scriptsig': '',
      'scriptsig_asm': '',
      'witness': [
        '3045022100aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
            '0220bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb01',
        '02cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc',
      ],
      'sequence': 4294967293,
      'is_pegin': false,
      'prevout': {
        'scriptpubkey': '0014751e76e8199196d454941c45d1b3a323f1433bd6',
        'scriptpubkey_asm':
            'OP_0 OP_PUSHBYTES_20 751e76e8199196d454941c45d1b3a323f1433bd6',
        'scriptpubkey_type': 'v0_p2wpkh',
        'scriptpubkey_address': 'bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4',
        'value': 100000,
      },
    },
  ],
  'vout': [
    {
      'scriptpubkey':
          '00201863143c14c5166804bd19203356da136c985678cd4d27a1b8c6329604903262',
      'scriptpubkey_asm': 'OP_0 OP_PUSHBYTES_32 1863143c',
      'scriptpubkey_type': 'v0_p2wsh',
      'scriptpubkey_address':
          'bc1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3qccfmv3',
      'value': 98500,
    },
  ],
  'status': {
    'confirmed': true,
    'block_height': 850000,
    'block_hash': _blockHash850000,
    'block_time': 1760000000,
    'mediantime': 1759999000,
  },
};

Map<String, Object?> _copy(Map<String, Object?> source) {
  return jsonDecode(jsonEncode(source)) as Map<String, Object?>;
}

void main() {
  group('EsploraBlock', () {
    test('parses the block fields and ignores extra ones', () {
      final block = EsploraBlock.fromJson(_copy(_blockJson));

      expect(block.id, _genesisId);
      expect(block.height, 0);
      expect(block.version, 1);
      expect(block.timestamp, 1231006505);
      expect(block.txCount, 1);
      expect(block.size, 285);
      expect(block.weight, 1140);
      expect(block.merkleRoot, _genesisCoinbaseTxid);
      expect(block.previousBlockHash, isNull);
      expect(block.nonce, 2083236893);
      expect(block.bits, 486604799);
      expect(block.difficulty, 1);
    });

    test('reads previousblockhash when present', () {
      final json = _copy(_blockJson)..['previousblockhash'] = _blockHash850000;

      expect(EsploraBlock.fromJson(json).previousBlockHash, _blockHash850000);
    });

    test('accepts a fractional difficulty', () {
      final json = _copy(_blockJson)..['difficulty'] = 1.5e13;

      expect(EsploraBlock.fromJson(json).difficulty, 1.5e13);
    });

    test('a missing field is a FormatException', () {
      final json = _copy(_blockJson)..remove('tx_count');

      expect(
        () => EsploraBlock.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('a string where an integer belongs is a FormatException', () {
      final json = _copy(_blockJson)..['height'] = '0';

      expect(
        () => EsploraBlock.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('a non-integer height is a FormatException', () {
      final json = _copy(_blockJson)..['height'] = 1.0;

      expect(
        () => EsploraBlock.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('EsploraTransaction', () {
    test('parses a coinbase with no prevout and no fee', () {
      final tx = EsploraTransaction.fromJson(_copy(_coinbaseJson));

      expect(tx.txid, _genesisCoinbaseTxid);
      expect(tx.version, 1);
      expect(tx.lockTime, 0);
      expect(tx.fee, isNull);
      expect(tx.inputs, hasLength(1));

      final input = tx.inputs.single;
      expect(input.isCoinbase, isTrue);
      expect(input.previousIndex, 4294967295);
      expect(input.previousTxid, '0' * 64);
      expect(input.prevout, isNull);
      expect(input.witness, isEmpty);
      expect(input.scriptSigHex, startsWith('04ffff001d'));

      final output = tx.outputs.single;
      expect(output.valueSatoshi, 5000000000);
      expect(output.scriptPubKeyType, 'p2pk');
      expect(output.address, isNull);

      expect(tx.status.confirmed, isTrue);
      expect(tx.status.blockHeight, 0);
      expect(tx.status.blockHash, _genesisId);
      expect(tx.status.blockTime, 1231006505);
    });

    test('parses a segwit transaction with witness and prevout', () {
      final tx = EsploraTransaction.fromJson(_copy(_segwitJson));

      expect(tx.fee, 1500);
      expect(tx.inputs, hasLength(1));

      final input = tx.inputs.single;
      expect(input.isCoinbase, isFalse);
      expect(input.previousTxid, _segwitPrevTxid);
      expect(input.previousIndex, 1);
      expect(input.scriptSigHex, isEmpty);
      expect(input.sequence, 4294967293);
      expect(input.witness, hasLength(2));
      expect(input.witness.first, startsWith('3045022100'));

      final prevout = input.prevout!;
      expect(prevout.valueSatoshi, 100000);
      expect(prevout.scriptPubKeyType, 'v0_p2wpkh');
      expect(prevout.address, 'bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4');

      final output = tx.outputs.single;
      expect(output.valueSatoshi, 98500);
      expect(output.scriptPubKeyType, 'v0_p2wsh');
      expect(output.scriptPubKeyHex, startsWith('0020'));

      expect(tx.status.blockHeight, 850000);
    });

    test('an unconfirmed status has null block fields', () {
      final json = _copy(_segwitJson)
        ..['status'] = <String, Object?>{
          'confirmed': false,
          'block_height': null,
          'block_hash': null,
          'block_time': null,
        };
      final tx = EsploraTransaction.fromJson(json);

      expect(tx.status.confirmed, isFalse);
      expect(tx.status.blockHeight, isNull);
      expect(tx.status.blockHash, isNull);
      expect(tx.status.blockTime, isNull);
    });

    test('a witness item that is not a string is a FormatException', () {
      final json = _copy(_segwitJson);
      final vin = (json['vin'] as List<Object?>).single as Map<String, Object?>;
      vin['witness'] = <Object?>[1, 2];

      expect(
        () => EsploraTransaction.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('vin that is not a list is a FormatException', () {
      final json = _copy(_segwitJson)..['vin'] = 'nope';

      expect(
        () => EsploraTransaction.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('an output that is not an object is a FormatException', () {
      final json = _copy(_segwitJson)..['vout'] = <Object?>[42];

      expect(
        () => EsploraTransaction.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('a missing status is a FormatException', () {
      final json = _copy(_segwitJson)..remove('status');

      expect(
        () => EsploraTransaction.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('the inputs and outputs lists cannot be changed', () {
      final tx = EsploraTransaction.fromJson(_copy(_segwitJson));

      expect(() => tx.outputs.add(tx.outputs.first), throwsUnsupportedError);
    });
  });

  group('EsploraAddressStats', () {
    test('parses chain and mempool totals', () {
      final stats = EsploraAddressStats.fromJson({
        'address': _genesisAddress,
        'chain_stats': {
          'funded_txo_count': 1,
          'funded_txo_sum': 5000000000,
          'spent_txo_count': 0,
          'spent_txo_sum': 0,
          'tx_count': 1,
        },
        'mempool_stats': {
          'funded_txo_count': 0,
          'funded_txo_sum': 0,
          'spent_txo_count': 0,
          'spent_txo_sum': 0,
          'tx_count': 0,
        },
      });

      expect(stats.address, _genesisAddress);
      expect(stats.chain.fundedTxoCount, 1);
      expect(stats.chain.fundedTxoSum, 5000000000);
      expect(stats.chain.spentTxoCount, 0);
      expect(stats.chain.spentTxoSum, 0);
      expect(stats.chain.txCount, 1);
      expect(stats.mempool.txCount, 0);
    });

    test('a missing scope is a FormatException', () {
      expect(
        () => EsploraAddressStats.fromJson({
          'address': _genesisAddress,
          'chain_stats': {
            'funded_txo_count': 1,
            'funded_txo_sum': 1,
            'spent_txo_count': 0,
            'spent_txo_sum': 0,
            'tx_count': 1,
          },
        }),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
