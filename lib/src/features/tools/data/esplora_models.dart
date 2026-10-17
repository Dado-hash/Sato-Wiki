// Models for the Esplora REST API used by mempool.space and Blockstream.
//
// Field names follow https://github.com/Blockstream/esplora/blob/master/API.md.
// Parsing ignores extra fields. A missing field or a wrong type throws a
// FormatException; the client turns it into a bad response. Pure Dart.

/// A block summary from `GET /block/:hash`.
final class EsploraBlock {
  /// Creates a block summary.
  const EsploraBlock({
    required this.id,
    required this.height,
    required this.version,
    required this.timestamp,
    required this.txCount,
    required this.size,
    required this.weight,
    required this.merkleRoot,
    required this.previousBlockHash,
    required this.nonce,
    required this.bits,
    required this.difficulty,
  });

  /// Reads a block from its JSON object.
  factory EsploraBlock.fromJson(Map<String, Object?> json) {
    return EsploraBlock(
      id: _string(json, 'id'),
      height: _int(json, 'height'),
      version: _int(json, 'version'),
      timestamp: _int(json, 'timestamp'),
      txCount: _int(json, 'tx_count'),
      size: _int(json, 'size'),
      weight: _int(json, 'weight'),
      merkleRoot: _string(json, 'merkle_root'),
      previousBlockHash: _stringOrNull(json, 'previousblockhash'),
      nonce: _int(json, 'nonce'),
      bits: _int(json, 'bits'),
      difficulty: _num(json, 'difficulty'),
    );
  }

  /// Block hash, as hex.
  final String id;

  /// Height in the best chain.
  final int height;

  /// Block version.
  final int version;

  /// Block header time, in seconds since the Unix epoch.
  final int timestamp;

  /// Number of transactions, coinbase included.
  final int txCount;

  /// Serialized size in bytes.
  final int size;

  /// Weight in weight units.
  final int weight;

  /// Merkle root of the transactions, as hex.
  final String merkleRoot;

  /// Hash of the parent block. Null when the server omits it (genesis).
  final String? previousBlockHash;

  /// Header nonce.
  final int nonce;

  /// Compact target (`nBits`).
  final int bits;

  /// Difficulty relative to the minimum.
  final num difficulty;
}

/// A transaction from `GET /tx/:txid` or an address history call.
final class EsploraTransaction {
  /// Creates a transaction.
  const EsploraTransaction({
    required this.txid,
    required this.version,
    required this.lockTime,
    required this.size,
    required this.weight,
    required this.fee,
    required this.inputs,
    required this.outputs,
    required this.status,
  });

  /// Reads a transaction from its JSON object.
  factory EsploraTransaction.fromJson(Map<String, Object?> json) {
    return EsploraTransaction(
      txid: _string(json, 'txid'),
      version: _int(json, 'version'),
      lockTime: _int(json, 'locktime'),
      size: _int(json, 'size'),
      weight: _int(json, 'weight'),
      fee: _intOrNull(json, 'fee'),
      inputs: List.unmodifiable(
        _objectList(json, 'vin').map(EsploraInput.fromJson),
      ),
      outputs: List.unmodifiable(
        _objectList(json, 'vout').map(EsploraOutput.fromJson),
      ),
      status: EsploraTxStatus.fromJson(_object(json, 'status')),
    );
  }

  /// Transaction id, as hex.
  final String txid;

  /// Transaction version.
  final int version;

  /// Lock time (`locktime` in the API).
  final int lockTime;

  /// Serialized size in bytes.
  final int size;

  /// Weight in weight units.
  final int weight;

  /// Fee in satoshi. Null when the server omits it.
  final int? fee;

  /// Inputs, in order (`vin` in the API).
  final List<EsploraInput> inputs;

  /// Outputs, in order (`vout` in the API).
  final List<EsploraOutput> outputs;

  /// Confirmation status.
  final EsploraTxStatus status;
}

/// One input of a transaction (`vin` element).
final class EsploraInput {
  /// Creates an input.
  const EsploraInput({
    required this.previousTxid,
    required this.previousIndex,
    required this.isCoinbase,
    required this.sequence,
    required this.scriptSigHex,
    required this.witness,
    required this.prevout,
  });

  /// Reads an input from its JSON object.
  factory EsploraInput.fromJson(Map<String, Object?> json) {
    final prevoutJson = json['prevout'];
    final witnessJson = json['witness'] ?? const <Object?>[];
    if (witnessJson is! List<Object?> ||
        witnessJson.any((item) => item is! String)) {
      throw const FormatException('Esplora field "witness" must be strings.');
    }

    return EsploraInput(
      previousTxid: _string(json, 'txid'),
      previousIndex: _int(json, 'vout'),
      isCoinbase: _bool(json, 'is_coinbase'),
      sequence: _int(json, 'sequence'),
      scriptSigHex: _string(json, 'scriptsig'),
      witness: List.unmodifiable(witnessJson.cast<String>()),
      prevout: prevoutJson == null
          ? null
          : EsploraOutput.fromJson(_asObject(prevoutJson, 'prevout')),
    );
  }

  /// Id of the spent transaction, as hex. All zeros for a coinbase.
  final String previousTxid;

  /// Index of the spent output (`vout` in the API).
  final int previousIndex;

  /// Whether this input is the coinbase input.
  final bool isCoinbase;

  /// Sequence number.
  final int sequence;

  /// Unlocking script, as hex (`scriptsig` in the API).
  final String scriptSigHex;

  /// Witness stack items, each as hex. Empty for legacy inputs.
  final List<String> witness;

  /// The output being spent. Null for a coinbase input.
  final EsploraOutput? prevout;
}

/// One output of a transaction (`vout` element, or `prevout`).
final class EsploraOutput {
  /// Creates an output.
  const EsploraOutput({
    required this.valueSatoshi,
    required this.scriptPubKeyHex,
    required this.scriptPubKeyType,
    required this.address,
  });

  /// Reads an output from its JSON object.
  factory EsploraOutput.fromJson(Map<String, Object?> json) {
    return EsploraOutput(
      valueSatoshi: _int(json, 'value'),
      scriptPubKeyHex: _string(json, 'scriptpubkey'),
      scriptPubKeyType: _string(json, 'scriptpubkey_type'),
      address: _stringOrNull(json, 'scriptpubkey_address'),
    );
  }

  /// Amount in satoshi.
  final int valueSatoshi;

  /// Locking script, as hex (`scriptpubkey` in the API).
  final String scriptPubKeyHex;

  /// Script template name, such as `p2wpkh` or `op_return`.
  final String scriptPubKeyType;

  /// Address encoded from the script. Null when the script has none.
  final String? address;
}

/// Confirmation status of a transaction (`status` in the API).
final class EsploraTxStatus {
  /// Creates a status.
  const EsploraTxStatus({
    required this.confirmed,
    required this.blockHeight,
    required this.blockHash,
    required this.blockTime,
  });

  /// Reads a status from its JSON object.
  factory EsploraTxStatus.fromJson(Map<String, Object?> json) {
    return EsploraTxStatus(
      confirmed: _bool(json, 'confirmed'),
      blockHeight: _intOrNull(json, 'block_height'),
      blockHash: _stringOrNull(json, 'block_hash'),
      blockTime: _intOrNull(json, 'block_time'),
    );
  }

  /// Whether the transaction is in a block.
  final bool confirmed;

  /// Height of the containing block, when confirmed.
  final int? blockHeight;

  /// Hash of the containing block, when confirmed.
  final String? blockHash;

  /// Time of the containing block, when confirmed.
  final int? blockTime;
}

/// Address summary from `GET /address/:address`.
final class EsploraAddressStats {
  /// Creates address statistics.
  const EsploraAddressStats({
    required this.address,
    required this.chain,
    required this.mempool,
  });

  /// Reads address statistics from their JSON object.
  factory EsploraAddressStats.fromJson(Map<String, Object?> json) {
    return EsploraAddressStats(
      address: _string(json, 'address'),
      chain: EsploraAddressUsage.fromJson(_object(json, 'chain_stats')),
      mempool: EsploraAddressUsage.fromJson(_object(json, 'mempool_stats')),
    );
  }

  /// The address that was asked for.
  final String address;

  /// Totals over confirmed transactions (`chain_stats`).
  final EsploraAddressUsage chain;

  /// Totals over unconfirmed transactions (`mempool_stats`).
  final EsploraAddressUsage mempool;
}

/// Totals for one scope (confirmed or mempool) of an address.
final class EsploraAddressUsage {
  /// Creates address totals.
  const EsploraAddressUsage({
    required this.fundedTxoCount,
    required this.fundedTxoSum,
    required this.spentTxoCount,
    required this.spentTxoSum,
    required this.txCount,
  });

  /// Reads address totals from their JSON object.
  factory EsploraAddressUsage.fromJson(Map<String, Object?> json) {
    return EsploraAddressUsage(
      fundedTxoCount: _int(json, 'funded_txo_count'),
      fundedTxoSum: _int(json, 'funded_txo_sum'),
      spentTxoCount: _int(json, 'spent_txo_count'),
      spentTxoSum: _int(json, 'spent_txo_sum'),
      txCount: _int(json, 'tx_count'),
    );
  }

  /// Number of outputs paying to the address.
  final int fundedTxoCount;

  /// Total satoshi paid to the address.
  final int fundedTxoSum;

  /// Number of outputs of the address that were spent.
  final int spentTxoCount;

  /// Total satoshi of the spent outputs.
  final int spentTxoSum;

  /// Number of transactions that involve the address.
  final int txCount;
}

Map<String, Object?> _asObject(Object? value, String name) {
  if (value is Map<String, Object?>) {
    return value;
  }

  throw FormatException('Esplora field "$name" must be an object.');
}

Map<String, Object?> _object(Map<String, Object?> json, String key) {
  return _asObject(json[key], key);
}

List<Map<String, Object?>> _objectList(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! List<Object?>) {
    throw FormatException('Esplora field "$key" must be a list.');
  }

  final result = <Map<String, Object?>>[];
  for (final item in value) {
    result.add(_asObject(item, key));
  }

  return result;
}

String _string(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is String) {
    return value;
  }

  throw FormatException('Esplora field "$key" must be a string.');
}

String? _stringOrNull(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value == null || value is String) {
    return value as String?;
  }

  throw FormatException('Esplora field "$key" must be a string or null.');
}

int _int(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is int) {
    return value;
  }

  throw FormatException('Esplora field "$key" must be an integer.');
}

int? _intOrNull(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value == null || value is int) {
    return value as int?;
  }

  throw FormatException('Esplora field "$key" must be an integer or null.');
}

num _num(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is num) {
    return value;
  }

  throw FormatException('Esplora field "$key" must be a number.');
}

bool _bool(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is bool) {
    return value;
  }

  throw FormatException('Esplora field "$key" must be a boolean.');
}

/// One entry of the mempool fee histogram: [vsize] vbytes pay at least
/// [feeRate] sat/vB and less than the fee rate of the entry before it.
/// Entries come highest fee rate first.
final class EsploraFeeBucket {
  /// Creates a histogram entry.
  const EsploraFeeBucket({required this.feeRate, required this.vsize});

  /// Fee rate in sat/vB.
  final double feeRate;

  /// Total size of the transactions in this bucket, in vbytes.
  final int vsize;
}

/// Mempool summary from `GET /mempool`.
final class EsploraMempoolInfo {
  /// Creates a mempool summary.
  const EsploraMempoolInfo({
    required this.count,
    required this.vsize,
    required this.totalFee,
    required this.feeHistogram,
  });

  /// Reads a mempool summary from its JSON object.
  factory EsploraMempoolInfo.fromJson(Map<String, Object?> json) {
    final histogram = <EsploraFeeBucket>[];
    for (final entry in _list(json, 'fee_histogram')) {
      if (entry is! List<Object?> || entry.length != 2) {
        throw const FormatException(
          'Esplora field "fee_histogram" must hold [feerate, vsize] pairs.',
        );
      }
      histogram.add(
        EsploraFeeBucket(
          feeRate: _numValue(entry[0], 'fee_histogram'),
          vsize: _wholeValue(entry[1], 'fee_histogram'),
        ),
      );
    }

    return EsploraMempoolInfo(
      count: _int(json, 'count'),
      vsize: _int(json, 'vsize'),
      totalFee: _int(json, 'total_fee'),
      feeHistogram: List.unmodifiable(histogram),
    );
  }

  /// Number of transactions in the mempool.
  final int count;

  /// Total size of the mempool, in vbytes.
  final int vsize;

  /// Sum of the fees of the mempool transactions, in satoshi.
  final int totalFee;

  /// Fee histogram, highest fee rate first (`fee_histogram` in the API).
  final List<EsploraFeeBucket> feeHistogram;
}

/// Fee estimates from `GET /fee-estimates`: confirmation target in blocks
/// mapped to a fee rate in sat/vB.
final class EsploraFeeEstimates {
  /// Creates fee estimates. [byTarget] should not be changed afterwards.
  const EsploraFeeEstimates(this.byTarget);

  /// Reads fee estimates from their JSON object. Keys are strings such as
  /// `"1"` or `"144"`.
  factory EsploraFeeEstimates.fromJson(Map<String, Object?> json) {
    final byTarget = <int, double>{};
    for (final entry in json.entries) {
      final target = int.tryParse(entry.key);
      if (target == null || target < 1) {
        throw FormatException(
          'Fee estimate key "${entry.key}" must be a block target.',
        );
      }
      byTarget[target] = _numValue(entry.value, 'fee-estimates');
    }

    return EsploraFeeEstimates(Map.unmodifiable(byTarget));
  }

  /// Fee rate in sat/vB for each confirmation target, in blocks.
  final Map<int, double> byTarget;

  /// Fee rate for [target] blocks. When the server gave no such target, the
  /// rate of the nearest larger target. Null when there is none.
  double? forTarget(int target) {
    final exact = byTarget[target];
    if (exact != null) {
      return exact;
    }

    int? nearest;
    for (final key in byTarget.keys) {
      if (key > target && (nearest == null || key < nearest)) {
        nearest = key;
      }
    }

    return nearest == null ? null : byTarget[nearest];
  }
}

/// A transaction from `GET /mempool/recent`.
final class EsploraRecentTransaction {
  /// Creates a recent transaction.
  const EsploraRecentTransaction({
    required this.txid,
    required this.fee,
    required this.vsize,
    required this.value,
  });

  /// Reads a recent transaction from its JSON object.
  factory EsploraRecentTransaction.fromJson(Map<String, Object?> json) {
    return EsploraRecentTransaction(
      txid: _string(json, 'txid'),
      fee: _int(json, 'fee'),
      vsize: _int(json, 'vsize'),
      value: _int(json, 'value'),
    );
  }

  /// Transaction id, as hex.
  final String txid;

  /// Fee in satoshi.
  final int fee;

  /// Virtual size in vbytes.
  final int vsize;

  /// Sum of the outputs, in satoshi.
  final int value;

  /// Fee rate in sat/vB, or 0 when [vsize] is 0.
  double get feeRate => vsize == 0 ? 0 : fee / vsize;
}

/// Returns the list at [key], or throws a [FormatException] when it is not one.
List<Object?> _list(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is List<Object?>) {
    return value;
  }

  throw FormatException('Esplora field "$key" must be a list.');
}

/// Returns [value] as a non-negative, finite number, or throws a
/// [FormatException] naming [key].
double _numValue(Object? value, String key) {
  if (value is num && value.isFinite && value >= 0) {
    return value.toDouble();
  }

  throw FormatException('Esplora field "$key" must hold non-negative numbers.');
}

/// Returns [value] as a whole, non-negative number, or throws a
/// [FormatException] naming [key]. Accepts `1` and `1.0` alike.
int _wholeValue(Object? value, String key) {
  if (value is num && value.isFinite && value >= 0 && value % 1 == 0) {
    return value.toInt();
  }

  throw FormatException('Esplora field "$key" must hold whole numbers.');
}
