import 'dart:typed_data';

import 'tools_bytes.dart';
import 'units.dart';

/// Decoder for serialized Bitcoin transactions, legacy and BIP144 segwit. Pure Dart.

/// Largest transaction accepted by [decodeRawTransaction], in bytes.
const int maxRawTransactionBytes = 400000;

final BigInt _maxInt64 = (BigInt.one << 63) - BigInt.one;
const int _coinbaseIndex = 0xffffffff;

/// Why a raw transaction could not be decoded.
enum RawTransactionErrorReason {
  /// The text is empty, has an odd length or is not hexadecimal.
  notHex,

  /// The data ends before a field is complete, or a count exceeds the data.
  truncated,

  /// Bytes remain after the last field.
  trailingBytes,

  /// The data is larger than [maxRawTransactionBytes].
  tooLarge,

  /// A value is outside what a transaction can hold, or a segwit flag is unknown.
  invalidStructure,
}

/// Thrown by [decodeRawTransaction]. Never a RangeError.
final class RawTransactionException implements Exception {
  /// Creates an exception with a [reason] and a developer-facing [message].
  const RawTransactionException(this.reason, this.message);

  /// Category of the failure, for the UI to describe.
  final RawTransactionErrorReason reason;

  /// Short English description for logs and tests.
  final String message;

  @override
  String toString() => 'RawTransactionException(${reason.name}): $message';
}

/// Script template of an output's scriptPubKey.
enum ScriptType {
  /// Pay to public key.
  p2pk,

  /// Pay to public key hash.
  p2pkh,

  /// Pay to script hash.
  p2sh,

  /// Pay to witness public key hash (version 0, 20 bytes).
  p2wpkh,

  /// Pay to witness script hash (version 0, 32 bytes).
  p2wsh,

  /// Pay to taproot (version 1, 32 bytes).
  p2tr,

  /// Any other witness program.
  witnessUnknown,

  /// Bare m-of-n multisig with at most 3 keys.
  bareMultisig,

  /// Data carrier output starting with OP_RETURN.
  opReturn,

  /// Anything else.
  nonStandard,
}

/// Kind of a serialized field, used to colour the hex by part.
enum TxFieldKind {
  /// 4-byte version.
  version,

  /// Segwit marker `00`.
  marker,

  /// Segwit flag `01`.
  flag,

  /// CompactSize count of inputs.
  inputCount,

  /// 32-byte previous txid, as stored (not reversed).
  previousTxid,

  /// 4-byte index of the spent output.
  previousIndex,

  /// CompactSize length of the scriptSig.
  scriptSigLength,

  /// scriptSig bytes.
  scriptSig,

  /// 4-byte sequence.
  sequence,

  /// CompactSize count of outputs.
  outputCount,

  /// 8-byte output value in satoshi.
  value,

  /// CompactSize length of the scriptPubKey.
  scriptPubKeyLength,

  /// scriptPubKey bytes.
  scriptPubKey,

  /// CompactSize count of witness items for one input.
  witnessItemCount,

  /// CompactSize length of one witness item.
  witnessItemLength,

  /// Bytes of one witness item.
  witnessItem,

  /// 4-byte lock time.
  lockTime,
}

/// One contiguous piece of the serialization, in byte offsets.
final class TxField {
  /// Creates a field of [length] bytes at [offset].
  const TxField({
    required this.kind,
    required this.offset,
    required this.length,
    this.index,
    this.itemIndex,
  });

  /// What the bytes encode.
  final TxFieldKind kind;

  /// Offset of the first byte in the original serialization.
  final int offset;

  /// Number of bytes in the original serialization.
  final int length;

  /// Input or output number, when the field belongs to one.
  final int? index;

  /// Witness item number, for witness fields.
  final int? itemIndex;
}

/// One transaction input.
final class TxInput {
  /// Creates an input.
  const TxInput({
    required this.previousTxid,
    required this.previousIndex,
    required this.scriptSig,
    required this.sequence,
    required this.witness,
  });

  /// Spent txid in displayed order (reversed, as explorers show it).
  final String previousTxid;

  /// Index of the spent output.
  final int previousIndex;

  /// Unlocking script.
  final Uint8List scriptSig;

  /// Sequence number.
  final int sequence;

  /// Witness stack items, empty when the input has no witness.
  final List<Uint8List> witness;
}

/// One transaction output.
final class TxOutput {
  /// Creates an output.
  const TxOutput({
    required this.valueSatoshi,
    required this.scriptPubKey,
    required this.scriptType,
  });

  /// Value in satoshi.
  final int valueSatoshi;

  /// Locking script.
  final Uint8List scriptPubKey;

  /// Template recognised for [scriptPubKey].
  final ScriptType scriptType;
}

/// A decoded transaction, with ids, sizes and the field layout.
final class DecodedTransaction {
  /// Creates a decoded transaction.
  const DecodedTransaction({
    required this.version,
    required this.isSegwit,
    required this.inputs,
    required this.outputs,
    required this.lockTime,
    required this.txid,
    required this.wtxid,
    required this.totalSize,
    required this.baseSize,
    required this.weight,
    required this.vsize,
    required this.isCoinbase,
    required this.fields,
  });

  /// Signed 32-bit version.
  final int version;

  /// Whether the serialization uses the BIP144 marker and flag.
  final bool isSegwit;

  /// Inputs in order.
  final List<TxInput> inputs;

  /// Outputs in order.
  final List<TxOutput> outputs;

  /// Lock time.
  final int lockTime;

  /// Txid in displayed order: double SHA-256 of the serialization without witness data, reversed.
  final String txid;

  /// Wtxid in displayed order: double SHA-256 of the full serialization, reversed.
  final String wtxid;

  /// Length of the full serialization in bytes.
  final int totalSize;

  /// Length of the serialization without marker, flag and witness data.
  final int baseSize;

  /// Weight units: `baseSize * 3 + totalSize`.
  final int weight;

  /// Virtual size: weight divided by 4, rounded up.
  final int vsize;

  /// True for a single input spending the null outpoint (all-zero txid, index 0xffffffff).
  final bool isCoinbase;

  /// Every byte of the serialization, in order, covered exactly once.
  final List<TxField> fields;
}

/// Decodes a serialized transaction given as hexadecimal text.
///
/// Accepts legacy and BIP144 segwit serializations. Throws a
/// [RawTransactionException] for every malformed input.
DecodedTransaction decodeRawTransaction(String hex) {
  final trimmed = hex.trim();
  if (trimmed.length ~/ 2 > maxRawTransactionBytes) {
    throw const RawTransactionException(
      RawTransactionErrorReason.tooLarge,
      'Transaction is larger than 400000 bytes',
    );
  }
  if (!isHex(trimmed)) {
    throw const RawTransactionException(
      RawTransactionErrorReason.notHex,
      'Input is empty, has an odd length or is not hexadecimal',
    );
  }

  final bytes = hexDecode(trimmed);
  final reader = _Reader(bytes);

  final version = _signed32(reader.readUint(4, TxFieldKind.version));

  var isSegwit = false;
  if (reader.remaining > 0 && bytes[reader.pos] == 0x00) {
    reader.take(1, TxFieldKind.marker);
    final flag = reader.take(1, TxFieldKind.flag);
    if (flag[0] != 0x01) {
      throw const RawTransactionException(
        RawTransactionErrorReason.invalidStructure,
        'Unknown segwit flag',
      );
    }
    isSegwit = true;
  }

  final inputCountOffset = reader.pos;
  final inputCount = reader.readCompactSize(TxFieldKind.inputCount);
  final rawInputs = <_RawInput>[];
  for (var i = 0; i < inputCount; i++) {
    final previousTxid = reader.take(32, TxFieldKind.previousTxid, index: i);
    final previousIndex = reader.readUint(
      4,
      TxFieldKind.previousIndex,
      index: i,
    );
    final scriptLength = reader.readCompactSize(
      TxFieldKind.scriptSigLength,
      index: i,
    );
    final scriptSig = reader.take(
      scriptLength,
      TxFieldKind.scriptSig,
      index: i,
    );
    final sequence = reader.readUint(4, TxFieldKind.sequence, index: i);
    rawInputs.add(
      _RawInput(
        previousTxid: hexEncode(reversedBytes(previousTxid)),
        previousIndex: previousIndex,
        scriptSig: scriptSig,
        sequence: sequence,
      ),
    );
  }

  final outputCount = reader.readCompactSize(TxFieldKind.outputCount);
  final outputs = <TxOutput>[];
  for (var i = 0; i < outputCount; i++) {
    final value = reader.readInt64(TxFieldKind.value, index: i);
    final scriptLength = reader.readCompactSize(
      TxFieldKind.scriptPubKeyLength,
      index: i,
    );
    final scriptPubKey = reader.take(
      scriptLength,
      TxFieldKind.scriptPubKey,
      index: i,
    );
    outputs.add(
      TxOutput(
        valueSatoshi: value,
        scriptPubKey: scriptPubKey,
        scriptType: classifyScriptPubKey(scriptPubKey),
      ),
    );
  }

  final witnessStart = reader.pos;
  final witnesses = List<List<Uint8List>>.generate(inputCount, (_) => const []);
  if (isSegwit) {
    for (var i = 0; i < inputCount; i++) {
      final itemCount = reader.readCompactSize(
        TxFieldKind.witnessItemCount,
        index: i,
      );
      final items = <Uint8List>[];
      for (var j = 0; j < itemCount; j++) {
        final length = reader.readCompactSize(
          TxFieldKind.witnessItemLength,
          index: i,
          itemIndex: j,
        );
        items.add(
          reader.take(length, TxFieldKind.witnessItem, index: i, itemIndex: j),
        );
      }
      witnesses[i] = items;
    }
  }

  final lockOffset = reader.pos;
  final lockTime = reader.readUint(4, TxFieldKind.lockTime);
  if (reader.remaining > 0) {
    throw const RawTransactionException(
      RawTransactionErrorReason.trailingBytes,
      'Bytes remain after the last field',
    );
  }

  final stripped = BytesBuilder(copy: false)
    ..add(bytes.sublist(0, 4))
    ..add(bytes.sublist(inputCountOffset, witnessStart))
    ..add(bytes.sublist(lockOffset, lockOffset + 4));
  final baseSize = stripped.length;
  final totalSize = bytes.length;
  final weight = weightFromSizes(baseSize: baseSize, totalSize: totalSize);

  final inputs = <TxInput>[
    for (var i = 0; i < rawInputs.length; i++)
      TxInput(
        previousTxid: rawInputs[i].previousTxid,
        previousIndex: rawInputs[i].previousIndex,
        scriptSig: rawInputs[i].scriptSig,
        sequence: rawInputs[i].sequence,
        witness: List.unmodifiable(witnesses[i]),
      ),
  ];

  return DecodedTransaction(
    version: version,
    isSegwit: isSegwit,
    inputs: List.unmodifiable(inputs),
    outputs: List.unmodifiable(outputs),
    lockTime: lockTime,
    txid: hexEncode(reversedBytes(doubleSha256(stripped.toBytes()))),
    wtxid: hexEncode(reversedBytes(doubleSha256(bytes))),
    totalSize: totalSize,
    baseSize: baseSize,
    weight: weight,
    vsize: vbytesFromWeight(weight),
    isCoinbase:
        inputs.length == 1 &&
        inputs[0].previousTxid == '0' * 64 &&
        inputs[0].previousIndex == _coinbaseIndex,
    fields: List.unmodifiable(reader.fields),
  );
}

/// Template of a scriptPubKey, using the standard patterns.
ScriptType classifyScriptPubKey(List<int> script) {
  final n = script.length;
  if (n == 25 &&
      script[0] == 0x76 &&
      script[1] == 0xa9 &&
      script[2] == 0x14 &&
      script[23] == 0x88 &&
      script[24] == 0xac) {
    return ScriptType.p2pkh;
  }
  if (n == 23 && script[0] == 0xa9 && script[1] == 0x14 && script[22] == 0x87) {
    return ScriptType.p2sh;
  }
  if (n == 22 && script[0] == 0x00 && script[1] == 0x14) {
    return ScriptType.p2wpkh;
  }
  if (n == 34 && script[0] == 0x00 && script[1] == 0x20) {
    return ScriptType.p2wsh;
  }
  if (n == 34 && script[0] == 0x51 && script[1] == 0x20) {
    return ScriptType.p2tr;
  }
  if (_isWitnessProgram(script)) {
    return ScriptType.witnessUnknown;
  }
  if (_isP2pk(script)) {
    return ScriptType.p2pk;
  }
  if (_isBareMultisig(script)) {
    return ScriptType.bareMultisig;
  }
  if (n > 0 && script[0] == 0x6a) {
    return ScriptType.opReturn;
  }

  return ScriptType.nonStandard;
}

/// A version opcode (OP_0 or OP_1..OP_16) followed by one push of 2..40 bytes.
bool _isWitnessProgram(List<int> script) {
  final n = script.length;
  if (n < 4 || n > 42) {
    return false;
  }
  final version = script[0];
  if (version != 0x00 && (version < 0x51 || version > 0x60)) {
    return false;
  }
  final push = script[1];

  return push >= 2 && push <= 40 && n == push + 2;
}

bool _isP2pk(List<int> script) {
  final n = script.length;
  if (n == 35 && script[0] == 0x21 && script[34] == 0xac) {
    return _isValidPublicKey(script, 1, 33);
  }
  if (n == 67 && script[0] == 0x41 && script[66] == 0xac) {
    return _isValidPublicKey(script, 1, 65);
  }

  return false;
}

bool _isBareMultisig(List<int> script) {
  final n = script.length;
  if (n < 3 || script[n - 1] != 0xae) {
    return false;
  }
  final required = script[0];
  final keyCount = script[n - 2];
  if (required < 0x51 ||
      required > 0x53 ||
      keyCount < 0x51 ||
      keyCount > 0x53) {
    return false;
  }
  final m = required - 0x50;
  final total = keyCount - 0x50;
  if (m > total) {
    return false;
  }

  final end = n - 2;
  var position = 1;
  var keys = 0;
  while (position < end) {
    final push = script[position];
    final length = push == 0x21
        ? 33
        : push == 0x41
        ? 65
        : 0;
    if (length == 0 || position + 1 + length > end) {
      return false;
    }
    if (!_isValidPublicKey(script, position + 1, length)) {
      return false;
    }
    position += 1 + length;
    keys += 1;
  }

  return keys == total;
}

/// Size and prefix check for a public key, as Bitcoin Core's `CPubKey::ValidSize`.
bool _isValidPublicKey(List<int> script, int start, int length) {
  final prefix = script[start];
  if (length == 33) {
    return prefix == 0x02 || prefix == 0x03;
  }

  return length == 65 && (prefix == 0x04 || prefix == 0x06 || prefix == 0x07);
}

int _signed32(int value) {
  return value >= 0x80000000 ? value - 0x100000000 : value;
}

final class _RawInput {
  const _RawInput({
    required this.previousTxid,
    required this.previousIndex,
    required this.scriptSig,
    required this.sequence,
  });

  final String previousTxid;
  final int previousIndex;
  final Uint8List scriptSig;
  final int sequence;
}

/// Sequential reader that records a [TxField] for every piece it consumes.
final class _Reader {
  _Reader(this.bytes);

  final Uint8List bytes;
  final List<TxField> fields = [];
  int pos = 0;

  int get remaining => bytes.length - pos;

  /// Consumes [count] bytes and records them as one field. Empty fields are not recorded.
  Uint8List take(int count, TxFieldKind kind, {int? index, int? itemIndex}) {
    if (count < 0 || count > remaining) {
      throw _truncated();
    }
    final start = pos;
    pos += count;
    if (count > 0) {
      fields.add(
        TxField(
          kind: kind,
          offset: start,
          length: count,
          index: index,
          itemIndex: itemIndex,
        ),
      );
    }

    return Uint8List.fromList(bytes.sublist(start, pos));
  }

  /// Little-endian unsigned integer of [count] bytes (at most 4 here).
  int readUint(int count, TxFieldKind kind, {int? index}) {
    final data = take(count, kind, index: index);
    var value = 0;
    for (var i = count - 1; i >= 0; i--) {
      value = (value << 8) | data[i];
    }

    return value;
  }

  /// Little-endian signed 64-bit amount. Values above 2^63 - 1 are rejected.
  int readInt64(TxFieldKind kind, {int? index}) {
    final value = _readBig(8, kind, index: index);
    if (value > _maxInt64) {
      throw const RawTransactionException(
        RawTransactionErrorReason.invalidStructure,
        'Amount does not fit in 63 bits',
      );
    }

    return value.toInt();
  }

  /// Bitcoin CompactSize. A count or length larger than the remaining bytes is truncated.
  int readCompactSize(TxFieldKind kind, {int? index, int? itemIndex}) {
    if (remaining < 1) {
      throw _truncated();
    }
    final prefix = bytes[pos];
    final width = switch (prefix) {
      0xfd => 3,
      0xfe => 5,
      0xff => 9,
      _ => 1,
    };
    final BigInt value;
    if (width == 1) {
      value = BigInt.from(take(1, kind, index: index, itemIndex: itemIndex)[0]);
    } else {
      value = _readBig(
        width - 1,
        kind,
        index: index,
        itemIndex: itemIndex,
        skipPrefix: true,
      );
    }
    if (value > BigInt.from(remaining)) {
      throw _truncated();
    }

    return value.toInt();
  }

  BigInt _readBig(
    int count,
    TxFieldKind kind, {
    int? index,
    int? itemIndex,
    bool skipPrefix = false,
  }) {
    final prefixLength = skipPrefix ? 1 : 0;
    final data = take(
      count + prefixLength,
      kind,
      index: index,
      itemIndex: itemIndex,
    );
    var value = BigInt.zero;
    for (var i = data.length - 1; i >= prefixLength; i--) {
      value = (value << 8) | BigInt.from(data[i]);
    }

    return value;
  }

  RawTransactionException _truncated() {
    return const RawTransactionException(
      RawTransactionErrorReason.truncated,
      'Data ends before the field is complete',
    );
  }
}
