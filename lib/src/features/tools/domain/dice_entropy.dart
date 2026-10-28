import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;

/// Dice to entropy, as SeedSigner and Coldcard do it. Pure Dart, no Flutter imports.

/// Seed lengths the dice tool supports, as SeedSigner does.
enum DiceSeedLength {
  /// 12 words: 50 rolls, 16 bytes of entropy.
  words12(rolls: 50, entropyBytes: 16, words: 12),

  /// 24 words: 99 rolls, 32 bytes of entropy.
  words24(rolls: 99, entropyBytes: 32, words: 24);

  const DiceSeedLength({
    required this.rolls,
    required this.entropyBytes,
    required this.words,
  });

  /// Number of die rolls the seed needs.
  final int rolls;

  /// Entropy length in bytes.
  final int entropyBytes;

  /// Number of BIP39 words.
  final int words;
}

/// log2(6): entropy of one fair die roll in bits.
const double diceBitsPerRoll = 2.584962500721156;

/// Entropy from dice: SHA-256 of the rolls as ASCII digits '1'..'6', truncated
/// to [DiceSeedLength.entropyBytes] (SeedSigner and Coldcard method).
///
/// [rolls] must hold exactly `length.rolls` values, each 1..6; otherwise an
/// [ArgumentError] is thrown.
Uint8List diceRollsToEntropy(List<int> rolls, DiceSeedLength length) {
  if (rolls.length != length.rolls) {
    throw ArgumentError.value(
      rolls.length,
      'rolls.length',
      'Expected ${length.rolls} rolls',
    );
  }

  final digits = Uint8List(rolls.length);
  try {
    for (var i = 0; i < rolls.length; i++) {
      final roll = rolls[i];
      if (roll < 1 || roll > 6) {
        throw ArgumentError.value(roll, 'rolls[$i]', 'A roll must be 1..6');
      }
      digits[i] = 0x30 + roll;
    }

    final digest = crypto.sha256.convert(digits).bytes;
    try {
      return Uint8List.fromList(digest.sublist(0, length.entropyBytes));
    } finally {
      // The digest is the seed entropy: do not leave it in memory.
      if (digest is Uint8List) {
        digest.fillRange(0, digest.length, 0);
      }
    }
  } finally {
    digits.fillRange(0, digits.length, 0);
  }
}

/// Bits of entropy collected by [rollCount] rolls.
double diceEntropyBits(int rollCount) => rollCount * diceBitsPerRoll;

/// Face counts and a chi-square check against a fair die.
final class DiceRollStats {
  DiceRollStats._(this._counts, this._total, this._chiSquare);

  /// Counts the faces in [rolls]. Each value must be 1..6.
  factory DiceRollStats.of(Iterable<int> rolls) {
    final counts = List<int>.filled(6, 0);
    var total = 0;
    for (final roll in rolls) {
      if (roll < 1 || roll > 6) {
        throw ArgumentError.value(roll, 'roll', 'A roll must be 1..6');
      }
      counts[roll - 1]++;
      total++;
    }

    var chi = 0.0;
    if (total > 0) {
      final expected = total / 6;
      for (final count in counts) {
        final diff = count - expected;
        chi += diff * diff / expected;
      }
    }

    return DiceRollStats._(List.unmodifiable(counts), total, chi);
  }

  /// Chi-square critical value for p < 0.001 with 5 degrees of freedom.
  static const _biasThreshold = 20.515;

  /// Minimum number of rolls before the bias check is meaningful.
  static const _minimumTotal = 30;

  final List<int> _counts;
  final int _total;
  final double _chiSquare;

  /// Face counts, length 6; `counts[0]` is the number of 1s.
  List<int> get counts => _counts;

  /// Number of rolls counted.
  int get total => _total;

  /// Pearson chi-square statistic against a uniform die (0 when empty).
  double get chiSquare => _chiSquare;

  /// True only when total >= 30 and [chiSquare] > 20.515 (p < 0.001, 5 dof).
  bool get looksBiased =>
      _total >= _minimumTotal && _chiSquare > _biasThreshold;
}
