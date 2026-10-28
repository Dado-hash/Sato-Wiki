import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;

import 'bip39_wordlist_en.dart';

/// BIP39 mnemonic encoding for the dice tool. Pure Dart, no Flutter imports.

/// A BIP39 mnemonic built from entropy, with the intermediate values the
/// result screen shows. Call [wipe] when the session ends.
final class Bip39Mnemonic {
  Bip39Mnemonic._(
    this._entropy,
    this._checksum,
    this._indices,
    this._checksumBits,
  );

  /// Builds the mnemonic for [entropy] of 16, 20, 24, 28 or 32 bytes.
  ///
  /// The input is copied. Any other length throws an [ArgumentError].
  factory Bip39Mnemonic.fromEntropy(Uint8List entropy) {
    if (!_validEntropyBytes.contains(entropy.length)) {
      throw ArgumentError.value(
        entropy.length,
        'entropy.length',
        'BIP39 entropy must be 16, 20, 24, 28 or 32 bytes',
      );
    }

    final copy = Uint8List.fromList(entropy);
    final entropyBits = copy.length * 8;
    final checksumBits = entropyBits ~/ 32;
    final digest = crypto.sha256.convert(copy).bytes;
    final checksum = Uint8List.fromList([digest[0]]);
    final totalBits = entropyBits + checksumBits;
    final indices = Uint16List(totalBits ~/ 11);
    final bits = _BitReader(copy, checksum, entropyBits);
    for (var word = 0; word < indices.length; word++) {
      var value = 0;
      for (var bit = word * 11; bit < word * 11 + 11; bit++) {
        value = (value << 1) | bits.at(bit);
      }
      indices[word] = value;
    }

    return Bip39Mnemonic._(copy, checksum, indices, checksumBits);
  }

  static const _validEntropyBytes = {16, 20, 24, 28, 32};

  final Uint8List _entropy;
  final Uint8List _checksum;
  final Uint16List _indices;
  final int _checksumBits;
  bool _wiped = false;

  /// The entropy bytes. This is the internal buffer, not a copy.
  Uint8List get entropy => _entropy;

  /// Entropy length in bits (ENT).
  int get entropyBitLength => _entropy.length * 8;

  /// Checksum length in bits (CS = ENT / 32).
  int get checksumBitLength => _checksumBits;

  /// Number of words: (ENT + CS) / 11.
  int get wordCount => _indices.length;

  /// Word indices (0..2047), one per word.
  Uint16List get indices => _indices;

  /// Whether [wipe] has run.
  bool get isWiped => _wiped;

  /// Entropy followed by checksum as a string of '0' and '1' characters.
  ///
  /// Throws a [StateError] after [wipe]. The string is built on demand.
  String bitString() {
    _checkNotWiped();
    final total = entropyBitLength + checksumBitLength;
    final buffer = StringBuffer();
    for (var bit = 0; bit < total; bit++) {
      buffer.write(_bitAt(bit));
    }

    return buffer.toString();
  }

  /// The [bitString] split into groups of 11 bits, one per word.
  ///
  /// Throws a [StateError] after [wipe].
  List<String> bitGroups() {
    final bits = bitString();

    return [
      for (var start = 0; start < bits.length; start += 11)
        bits.substring(start, start + 11),
    ];
  }

  /// Word at position [index] (0-based), from [bip39EnglishWordlist].
  ///
  /// Throws a [StateError] after [wipe] and a [RangeError] when [index] is
  /// outside the mnemonic.
  String wordAt(int index) {
    _checkNotWiped();
    RangeError.checkValidIndex(index, _indices, 'index');

    return bip39EnglishWordlist[_indices[index]];
  }

  /// Overwrites the entropy, checksum and word indices with zeros.
  void wipe() {
    _entropy.fillRange(0, _entropy.length, 0);
    _checksum.fillRange(0, _checksum.length, 0);
    _indices.fillRange(0, _indices.length, 0);
    _wiped = true;
  }

  void _checkNotWiped() {
    if (_wiped) {
      throw StateError('Bip39Mnemonic was wiped');
    }
  }

  /// Bit [position] of entropy followed by checksum, most significant first.
  int _bitAt(int position) {
    return _BitReader(_entropy, _checksum, entropyBitLength).at(position);
  }
}

/// Reads bits of entropy followed by checksum, most significant bit first.
final class _BitReader {
  const _BitReader(this._entropy, this._checksum, this._entropyBits);

  final Uint8List _entropy;
  final Uint8List _checksum;
  final int _entropyBits;

  int at(int position) {
    if (position < _entropyBits) {
      return (_entropy[position >> 3] >> (7 - (position & 7))) & 1;
    }

    return (_checksum[0] >> (7 - (position - _entropyBits))) & 1;
  }
}
