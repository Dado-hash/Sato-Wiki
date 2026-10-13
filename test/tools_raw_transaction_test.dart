import 'package:flutter_test/flutter_test.dart';
import 'package:sato_wiki/src/features/tools/domain/raw_transaction.dart';
import 'package:sato_wiki/src/features/tools/domain/tools_bytes.dart';

/// Genesis coinbase transaction, fetched from mempool.space/api/tx/`genesis txid`/hex.
const String genesisTxHex =
    '01000000010000000000000000000000000000000000000000000000000000000000000000ffffffff4d04ffff001d0104455468652054696d65732030332f4a616e2f32303039204368616e63656c6c6f72206f6e206272696e6b206f66207365636f6e64206261696c6f757420666f722062616e6b73ffffffff0100f2052a01000000434104678afdb0fe5548271967f1a67130b7105cd6a828e03909a67962e0ea1f61deb649f6bc3f4cef38c4f35504e51ec112de5c384df7ba0b8d578a4c702b6bf11d5fac00000000';

/// BIP143 "Native P2WPKH" signed transaction, from bips/bip-0143.mediawiki.
const String bip143SignedHex =
    '01000000000102fff7f7881a8099afa6940d42d1e7f6362bec38171ea3edf433541db4e4ad969f00000000494830450221008b9d1dc26ba6a9cb62127b02742fa9d754cd3bebf337f7a55d114c8e5cdd30be022040529b194ba3f9281a99f2b1c0a19c0489bc22ede944ccf4ecbab4cc618ef3ed01eeffffffef51e1b804cc89d182d279655c3aa89e815b1b309fe287d9b2b55d57b90ec68a0100000000ffffffff02202cb206000000001976a9148280b37df378db99f66f85c95a783a76ac7a6d5988ac9093510d000000001976a9143bde42dbee7e4dbe6a21b2d50ce2f0167faa815988ac000247304402203609e17b84f6a7d30c80bfa610b5b4542f32a8a0d5447a12fb1366d7f01cc44a0220573a954c4518331561406f90300e8f3358f51928d43c212a8caed02de67eebee0121025476c2e83188368da1ff3e292e7acafcdb3566bb0ad253f62fc70f07aeee635711000000';

/// BIP143 "Native P2WPKH" unsigned transaction, from bips/bip-0143.mediawiki.
const String bip143UnsignedHex =
    '0100000002fff7f7881a8099afa6940d42d1e7f6362bec38171ea3edf433541db4e4ad969f0000000000eeffffffef51e1b804cc89d182d279655c3aa89e815b1b309fe287d9b2b55d57b90ec68a0100000000ffffffff02202cb206000000001976a9148280b37df378db99f66f85c95a783a76ac7a6d5988ac9093510d000000001976a9143bde42dbee7e4dbe6a21b2d50ce2f0167faa815988ac11000000';

const String genesisTxid =
    '4a5e1e4baab89f3a32518a88c31bc87f618f76673e2cc77ab2127b7afdeda33b';

/// Checks that [tx].fields cover bytes 0..totalSize once each, with no gap or overlap.
void expectFieldsCover(DecodedTransaction tx) {
  var position = 0;
  for (final field in tx.fields) {
    expect(field.offset, position, reason: 'gap or overlap at ${field.kind}');
    expect(field.length, greaterThan(0));
    position += field.length;
  }
  expect(position, tx.totalSize);
}

void expectDecodeError(String hex, RawTransactionErrorReason reason) {
  expect(
    () => decodeRawTransaction(hex),
    throwsA(
      isA<RawTransactionException>().having((e) => e.reason, 'reason', reason),
    ),
  );
}

void main() {
  group('genesis coinbase transaction', () {
    late DecodedTransaction tx;

    setUp(() {
      tx = decodeRawTransaction(genesisTxHex);
    });

    test('has the known txid, one input and one output', () {
      expect(tx.txid, genesisTxid);
      expect(tx.wtxid, genesisTxid);
      expect(tx.isSegwit, isFalse);
      expect(tx.inputs, hasLength(1));
      expect(tx.outputs, hasLength(1));
      expect(tx.version, 1);
      expect(tx.lockTime, 0);
    });

    test('is a coinbase paying 50 BTC to a p2pk output', () {
      expect(tx.isCoinbase, isTrue);
      expect(tx.inputs.single.previousTxid, '0' * 64);
      expect(tx.inputs.single.previousIndex, 0xffffffff);
      expect(tx.outputs.single.valueSatoshi, 5000000000);
      expect(tx.outputs.single.scriptType, ScriptType.p2pk);
      expect(tx.inputs.single.witness, isEmpty);
    });

    test('sizes: legacy, so base equals total and weight is 4 per byte', () {
      expect(tx.totalSize, 204);
      expect(tx.baseSize, 204);
      expect(tx.weight, 816);
      expect(tx.vsize, 204);
    });

    test('fields cover every byte exactly once', () {
      expectFieldsCover(tx);
    });

    test('every proper prefix is rejected as truncated', () {
      final totalBytes = genesisTxHex.length ~/ 2;
      for (var length = 0; length < totalBytes; length++) {
        final prefix = genesisTxHex.substring(0, length * 2);
        if (length == 0) {
          expectDecodeError(prefix, RawTransactionErrorReason.notHex);
        } else {
          expectDecodeError(prefix, RawTransactionErrorReason.truncated);
        }
      }
    });

    test('trailing bytes are rejected', () {
      expectDecodeError(
        '${genesisTxHex}00',
        RawTransactionErrorReason.trailingBytes,
      );
    });
  });

  group('BIP143 native P2WPKH signed transaction', () {
    late DecodedTransaction tx;

    setUp(() {
      tx = decodeRawTransaction(bip143SignedHex);
    });

    test('is segwit with two inputs and two outputs', () {
      expect(tx.isSegwit, isTrue);
      expect(tx.inputs, hasLength(2));
      expect(tx.outputs, hasLength(2));
      expect(tx.isCoinbase, isFalse);
    });

    test('witness data is present for the second input only', () {
      expect(tx.inputs[0].witness, isEmpty);
      expect(tx.inputs[1].witness, hasLength(2));
      expect(tx.inputs[1].witness[0], hasLength(71));
      expect(tx.inputs[1].witness[1], hasLength(33));
      expect(tx.inputs[1].witness[1][0], 0x02);
    });

    test('script sizes and output templates match the BIP', () {
      expect(tx.inputs[0].scriptSig, hasLength(73));
      expect(tx.inputs[1].scriptSig, isEmpty);
      expect(tx.outputs[0].valueSatoshi, 0x06b22c20);
      expect(tx.outputs[1].valueSatoshi, 0x0d519390);
      expect(tx.outputs[0].scriptType, ScriptType.p2pkh);
      expect(tx.outputs[1].scriptType, ScriptType.p2pkh);
    });

    test('txid differs from wtxid', () {
      expect(tx.txid, isNot(tx.wtxid));
      expect(tx.txid, hasLength(64));
      expect(tx.wtxid, hasLength(64));
    });

    test(
      'base size is the total minus marker, flag and witness (110 bytes)',
      () {
        // Marker and flag 2 bytes, witness of input 0 is 1 byte (count 0),
        // witness of input 1 is 1 count + 1 + 71 + 1 + 33 = 107 bytes.
        expect(tx.totalSize - tx.baseSize, 2 + 1 + 107);
      },
    );

    test('weight and vsize follow the formulas', () {
      expect(tx.weight, tx.baseSize * 3 + tx.totalSize);
      expect(tx.vsize, (tx.weight + 3) ~/ 4);
    });

    test('fields cover every byte exactly once', () {
      expectFieldsCover(tx);
      expect(
        tx.fields.where((f) => f.kind == TxFieldKind.marker),
        hasLength(1),
      );
      expect(tx.fields.where((f) => f.kind == TxFieldKind.flag), hasLength(1));
    });

    test('every proper prefix is rejected with a RawTransactionException', () {
      final totalBytes = bip143SignedHex.length ~/ 2;
      for (var length = 0; length < totalBytes; length++) {
        final prefix = bip143SignedHex.substring(0, length * 2);
        expect(
          () => decodeRawTransaction(prefix),
          throwsA(isA<RawTransactionException>()),
          reason: 'prefix of $length bytes',
        );
      }
    });
  });

  group('BIP143 unsigned transaction (legacy serialization)', () {
    test('txid is the double SHA-256 of its serialization, reversed', () {
      final tx = decodeRawTransaction(bip143UnsignedHex);
      expect(tx.isSegwit, isFalse);
      expect(tx.inputs, hasLength(2));
      expect(tx.outputs, hasLength(2));
      expect(tx.totalSize, hexDecode(bip143UnsignedHex).length);
      expect(tx.baseSize, tx.totalSize);
      expect(tx.txid, tx.wtxid);
      expect(
        tx.txid,
        hexEncode(reversedBytes(doubleSha256(hexDecode(bip143UnsignedHex)))),
      );
      expectFieldsCover(tx);
    });
  });

  group('error handling', () {
    test('odd length, non-hex and empty input are notHex', () {
      expectDecodeError('abc', RawTransactionErrorReason.notHex);
      expectDecodeError('zz00', RawTransactionErrorReason.notHex);
      expectDecodeError('', RawTransactionErrorReason.notHex);
      expectDecodeError('   ', RawTransactionErrorReason.notHex);
    });

    test('more than 400000 bytes is tooLarge', () {
      expectDecodeError('00' * 400001, RawTransactionErrorReason.tooLarge);
    });

    test('an unknown segwit flag is invalidStructure', () {
      expectDecodeError(
        '0100000000020000',
        RawTransactionErrorReason.invalidStructure,
      );
    });

    test('a varint larger than the data is truncated, never a RangeError', () {
      expectDecodeError(
        '01000000ffffffffffffffffff',
        RawTransactionErrorReason.truncated,
      );
      expectDecodeError('01000000fdffff', RawTransactionErrorReason.truncated);
    });
  });

  group('classifyScriptPubKey', () {
    test('standard templates', () {
      final hash20 = '11' * 20;
      final hash32 = '22' * 32;
      expect(
        classifyScriptPubKey(hexDecode('76a914${hash20}88ac')),
        ScriptType.p2pkh,
      );
      expect(
        classifyScriptPubKey(hexDecode('a914${hash20}87')),
        ScriptType.p2sh,
      );
      expect(classifyScriptPubKey(hexDecode('0014$hash20')), ScriptType.p2wpkh);
      expect(classifyScriptPubKey(hexDecode('0020$hash32')), ScriptType.p2wsh);
      expect(classifyScriptPubKey(hexDecode('5120$hash32')), ScriptType.p2tr);
    });

    test('other witness programs are witnessUnknown', () {
      expect(
        classifyScriptPubKey(hexDecode('5102abcd')),
        ScriptType.witnessUnknown,
      );
      expect(
        classifyScriptPubKey(hexDecode('0010${'33' * 16}')),
        ScriptType.witnessUnknown,
      );
    });

    test('p2pk with compressed and uncompressed keys', () {
      expect(
        classifyScriptPubKey(hexDecode('2102${'44' * 32}ac')),
        ScriptType.p2pk,
      );
      expect(
        classifyScriptPubKey(hexDecode('4104${'44' * 64}ac')),
        ScriptType.p2pk,
      );
      expect(
        classifyScriptPubKey(hexDecode('2105${'44' * 32}ac')),
        ScriptType.nonStandard,
      );
    });

    test('bare multisig', () {
      final key1 = '02${'55' * 32}';
      final key2 = '03${'66' * 32}';
      final key3 = '02${'77' * 32}';
      expect(
        classifyScriptPubKey(hexDecode('5121${key1}51ae')),
        ScriptType.bareMultisig,
      );
      expect(
        classifyScriptPubKey(hexDecode('5221${key1}21${key2}21${key3}53ae')),
        ScriptType.bareMultisig,
      );
    });

    test('OP_RETURN and empty or unknown scripts', () {
      expect(
        classifyScriptPubKey(hexDecode('6a04deadbeef')),
        ScriptType.opReturn,
      );
      expect(classifyScriptPubKey(<int>[]), ScriptType.nonStandard);
      expect(classifyScriptPubKey(hexDecode('6a')), ScriptType.opReturn);
      expect(classifyScriptPubKey(hexDecode('51')), ScriptType.nonStandard);
    });
  });
}
