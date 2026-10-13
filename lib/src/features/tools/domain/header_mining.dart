import 'dart:typed_data';

import 'tools_bytes.dart';

/// Real 80-byte Bitcoin block header and proof-of-work search. Pure Dart, no Flutter imports.

const int _maxUint32 = 0xffffffff;
const int _maxInt32 = 0x7fffffff;
const int _minInt32 = -0x80000000;

/// Result of [mineHeaderChunk], with the same contract as the lab chunk result.
final class HeaderMiningChunkResult {
  /// Creates a chunk result.
  const HeaderMiningChunkResult({
    required this.nonce,
    required this.hash,
    required this.nextNonce,
    required this.attemptsDone,
  });

  /// Nonce that met the target, or null when none was found in this chunk.
  final int? nonce;

  /// Displayed hash of the found header, or null.
  final String? hash;

  /// Nonce to start the next chunk from.
  final int nextNonce;

  /// Number of nonces tried in this chunk.
  final int attemptsDone;
}

/// Bitcoin block header. Hashes are in displayed order (reversed, as explorers show them).
final class BlockHeader {
  /// Creates a header.
  const BlockHeader({
    required this.version,
    required this.previousBlockHash,
    required this.merkleRoot,
    required this.time,
    required this.bits,
    required this.nonce,
  });

  /// Signed 32-bit version.
  final int version;

  /// Previous block hash as 64 hex characters, in displayed order.
  final String previousBlockHash;

  /// Merkle root as 64 hex characters, in displayed order.
  final String merkleRoot;

  /// Unix time, unsigned 32-bit.
  final int time;

  /// Compact target, unsigned 32-bit.
  final int bits;

  /// Nonce, unsigned 32-bit.
  final int nonce;

  /// The 80 serialized bytes, little-endian integers and byte-reversed hashes.
  ///
  /// Throws an [ArgumentError] when a field is out of range or a hash is not 64 hex characters.
  Uint8List serialize() {
    if (version < _minInt32 || version > _maxInt32) {
      throw ArgumentError.value(
        version,
        'version',
        'must fit in a signed 32-bit integer',
      );
    }
    _checkUint32('time', time);
    _checkUint32('bits', bits);
    _checkUint32('nonce', nonce);

    final out = Uint8List(80);
    final view = ByteData.sublistView(out);
    view.setInt32(0, version, Endian.little);
    out.setRange(
      4,
      36,
      _displayHashBytes(previousBlockHash, 'previousBlockHash'),
    );
    out.setRange(36, 68, _displayHashBytes(merkleRoot, 'merkleRoot'));
    view.setUint32(68, time, Endian.little);
    view.setUint32(72, bits, Endian.little);
    view.setUint32(76, nonce, Endian.little);

    return out;
  }

  /// Double SHA-256 of [serialize], reversed, as 64 lowercase hex characters.
  String get hash => hexEncode(reversedBytes(doubleSha256(serialize())));

  /// Copy with the given fields replaced.
  BlockHeader copyWith({
    int? version,
    String? previousBlockHash,
    String? merkleRoot,
    int? time,
    int? bits,
    int? nonce,
  }) {
    return BlockHeader(
      version: version ?? this.version,
      previousBlockHash: previousBlockHash ?? this.previousBlockHash,
      merkleRoot: merkleRoot ?? this.merkleRoot,
      time: time ?? this.time,
      bits: bits ?? this.bits,
      nonce: nonce ?? this.nonce,
    );
  }

  /// Header from 80 bytes of hexadecimal text.
  ///
  /// Throws a [FormatException] when the text is not hexadecimal or is not 80 bytes.
  static BlockHeader parse(String hex80bytes) {
    final bytes = hexDecode(hex80bytes);
    if (bytes.length != 80) {
      throw FormatException('A block header is 80 bytes', hex80bytes);
    }
    final view = ByteData.sublistView(bytes);

    return BlockHeader(
      version: view.getInt32(0, Endian.little),
      previousBlockHash: hexEncode(reversedBytes(bytes.sublist(4, 36))),
      merkleRoot: hexEncode(reversedBytes(bytes.sublist(36, 68))),
      time: view.getUint32(68, Endian.little),
      bits: view.getUint32(72, Endian.little),
      nonce: view.getUint32(76, Endian.little),
    );
  }
}

/// Mainnet genesis block header, with the real values.
const BlockHeader genesisHeader = BlockHeader(
  version: 1,
  previousBlockHash:
      '0000000000000000000000000000000000000000000000000000000000000000',
  merkleRoot:
      '4a5e1e4baab89f3a32518a88c31bc87f618f76673e2cc77ab2127b7afdeda33b',
  time: 1231006505,
  bits: 0x1d00ffff,
  nonce: 2083236893,
);

/// Whether the header hash, read as a 256-bit number, is at or below [target].
bool headerMeetsTarget(BlockHeader header, BigInt target) {
  return BigInt.parse(header.hash, radix: 16) <= target;
}

/// Tries up to [attempts] nonces from [startNonce], stopping at the first that meets [target].
///
/// The nonce is limited to 32 bits. When the search reaches 0xffffffff the
/// returned [HeaderMiningChunkResult.nextNonce] is 0x100000000, meaning exhausted.
HeaderMiningChunkResult mineHeaderChunk(
  BlockHeader header, {
  required BigInt target,
  required int startNonce,
  required int attempts,
}) {
  if (startNonce < 0 || startNonce > _maxUint32) {
    throw ArgumentError.value(startNonce, 'startNonce', 'must fit in 32 bits');
  }
  if (attempts < 0) {
    throw ArgumentError.value(attempts, 'attempts', 'must not be negative');
  }

  final end = startNonce + attempts > _maxUint32 + 1
      ? _maxUint32 + 1
      : startNonce + attempts;
  for (var nonce = startNonce; nonce < end; nonce++) {
    final candidate = header.copyWith(nonce: nonce);
    if (headerMeetsTarget(candidate, target)) {
      return HeaderMiningChunkResult(
        nonce: nonce,
        hash: candidate.hash,
        nextNonce: nonce + 1,
        attemptsDone: nonce - startNonce + 1,
      );
    }
  }

  return HeaderMiningChunkResult(
    nonce: null,
    hash: null,
    nextNonce: end,
    attemptsDone: end - startNonce,
  );
}

Uint8List _displayHashBytes(String hash, String name) {
  if (hash.length != 64 || !isHex(hash)) {
    throw ArgumentError.value(hash, name, 'must be 64 hexadecimal characters');
  }

  return reversedBytes(hexDecode(hash));
}

void _checkUint32(String name, int value) {
  if (value < 0 || value > _maxUint32) {
    throw ArgumentError.value(
      value,
      name,
      'must fit in an unsigned 32-bit integer',
    );
  }
}
