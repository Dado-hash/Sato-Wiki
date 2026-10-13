import 'dart:convert';
import 'dart:isolate';

import 'tools_bytes.dart';

/// Teaching blockchain for the lab, modelled on Anders Brownworth's blockchain demo.
/// This is a simplified block, NOT real Bitcoin. Pure Dart, no Flutter imports.

/// Previous hash of the first block: 64 zeros.
const String labGenesisPreviousHash =
    '0000000000000000000000000000000000000000000000000000000000000000';

/// Immutable lab block. Its hash is SHA-256 of `'$number$nonce$data$previousHash'`.
final class LabBlock {
  /// Creates a block.
  const LabBlock({
    required this.number,
    required this.nonce,
    required this.data,
    required this.previousHash,
  });

  /// Position in the chain, starting at 0.
  final int number;

  /// Value changed by mining until the hash meets the difficulty.
  final int nonce;

  /// Block content, usually from [encodeLabTransfers].
  final String data;

  /// Hash of the previous block, or [labGenesisPreviousHash] for the first block.
  final String previousHash;

  /// SHA-256 of the block text, as lowercase hexadecimal.
  String get hash {
    final text = '$number$nonce$data$previousHash';

    return hexEncode(sha256Bytes(utf8.encode(text)));
  }

  /// Whether [hash] starts with [leadingZeros] zero characters.
  bool isMined(int leadingZeros) => labHashMeetsDifficulty(hash, leadingZeros);

  /// Copy with the given fields replaced.
  LabBlock copyWith({
    int? number,
    int? nonce,
    String? data,
    String? previousHash,
  }) {
    return LabBlock(
      number: number ?? this.number,
      nonce: nonce ?? this.nonce,
      data: data ?? this.data,
      previousHash: previousHash ?? this.previousHash,
    );
  }
}

/// Whether [hash] starts with [leadingZeros] zero characters.
bool labHashMeetsDifficulty(String hash, int leadingZeros) {
  if (leadingZeros < 0) {
    throw ArgumentError.value(
      leadingZeros,
      'leadingZeros',
      'must not be negative',
    );
  }

  return hash.length >= leadingZeros &&
      hash.substring(0, leadingZeros) == '0' * leadingZeros;
}

/// Verdict for one block of a lab chain.
final class LabBlockStatus {
  /// Creates a status.
  const LabBlockStatus({
    required this.mined,
    required this.linked,
    required this.valid,
  });

  /// Whether the block hash meets the difficulty.
  final bool mined;

  /// Whether the previous hash matches the block before, or the genesis value for the first block.
  final bool linked;

  /// Mined, linked, and every earlier block valid.
  final bool valid;
}

/// Checks every block of [chain] at the given [leadingZeros] difficulty.
///
/// Changing an old block breaks its link to the next block, so it and every
/// later block are reported as not valid.
List<LabBlockStatus> validateLabChain(List<LabBlock> chain, int leadingZeros) {
  final statuses = <LabBlockStatus>[];
  for (var i = 0; i < chain.length; i++) {
    final block = chain[i];
    final mined = block.isMined(leadingZeros);
    final linked = i == 0
        ? block.previousHash == labGenesisPreviousHash
        : block.previousHash == chain[i - 1].hash;
    final earlierValid = i == 0 || statuses[i - 1].valid;
    statuses.add(
      LabBlockStatus(
        mined: mined,
        linked: linked,
        valid: mined && linked && earlierValid,
      ),
    );
  }

  return List.unmodifiable(statuses);
}

/// Result of one call to [mineLabBlockChunk] or [mineHeaderChunk].
final class LabMiningChunkResult {
  /// Creates a chunk result.
  const LabMiningChunkResult({
    required this.nonce,
    required this.hash,
    required this.nextNonce,
    required this.attemptsDone,
  });

  /// Nonce that met the difficulty, or null when none was found in this chunk.
  final int? nonce;

  /// Hash of the found block, or null.
  final String? hash;

  /// Nonce to start the next chunk from.
  final int nextNonce;

  /// Number of nonces tried in this chunk.
  final int attemptsDone;
}

/// Tries up to [attempts] nonces from [startNonce] and stops at the first one that meets the difficulty.
///
/// Synchronous, so a caller can run it in chunks and report progress.
LabMiningChunkResult mineLabBlockChunk(
  LabBlock block, {
  required int leadingZeros,
  required int startNonce,
  required int attempts,
}) {
  if (attempts < 0) {
    throw ArgumentError.value(attempts, 'attempts', 'must not be negative');
  }

  for (var i = 0; i < attempts; i++) {
    final nonce = startNonce + i;
    final candidate = block.copyWith(nonce: nonce);
    final hash = candidate.hash;
    if (labHashMeetsDifficulty(hash, leadingZeros)) {
      return LabMiningChunkResult(
        nonce: nonce,
        hash: hash,
        nextNonce: nonce + 1,
        attemptsDone: i + 1,
      );
    }
  }

  return LabMiningChunkResult(
    nonce: null,
    hash: null,
    nextNonce: startNonce + attempts,
    attemptsDone: attempts,
  );
}

/// [block] with the first nonce from 0 that meets [leadingZeros], searched in a background isolate.
///
/// Throws a [StateError] when no nonce is found within [maxAttempts].
Future<LabBlock> mineLabBlock(
  LabBlock block, {
  required int leadingZeros,
  int maxAttempts = 50000000,
}) {
  return Isolate.run(() {
    final result = mineLabBlockChunk(
      block,
      leadingZeros: leadingZeros,
      startNonce: 0,
      attempts: maxAttempts,
    );
    final nonce = result.nonce;
    if (nonce == null) {
      throw StateError('No nonce found within $maxAttempts attempts');
    }

    return block.copyWith(nonce: nonce);
  });
}

/// A transfer in the lab ledger.
final class LabTransfer {
  /// Creates a transfer of [amount] units from [from] to [to].
  const LabTransfer({
    required this.from,
    required this.to,
    required this.amount,
  });

  /// Sender name.
  final String from;

  /// Recipient name.
  final String to;

  /// Amount in whole lab units.
  final int amount;
}

/// Deterministic block text for [transfers], one line per transfer.
///
/// [coinbase], when given, is written first. Each line is `from -> to: amount`.
/// Throws an [ArgumentError] when a name contains a line break or an amount is negative.
String encodeLabTransfers(
  List<LabTransfer> transfers, {
  LabTransfer? coinbase,
}) {
  final all = [if (coinbase != null) coinbase, ...transfers];
  final lines = <String>[];
  for (final transfer in all) {
    if (transfer.from.contains('\n') ||
        transfer.from.contains('\r') ||
        transfer.to.contains('\n') ||
        transfer.to.contains('\r')) {
      throw ArgumentError('Names must not contain line breaks');
    }
    if (transfer.amount < 0) {
      throw ArgumentError.value(
        transfer.amount,
        'amount',
        'must not be negative',
      );
    }
    lines.add('${transfer.from} -> ${transfer.to}: ${transfer.amount}');
  }

  return lines.join('\n');
}
