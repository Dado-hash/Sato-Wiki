import 'package:flutter_test/flutter_test.dart';
import 'package:sato_wiki/src/features/tools/domain/bip39.dart';
import 'package:sato_wiki/src/features/tools/domain/dice_entropy.dart';

List<int> _rolls(String text) => [for (final c in text.codeUnits) c - 0x30];

String _words(Bip39Mnemonic mnemonic) {
  return [
    for (var i = 0; i < mnemonic.wordCount; i++) mnemonic.wordAt(i),
  ].join(' ');
}

String _seedFor(String rolls, DiceSeedLength length) {
  return _words(
    Bip39Mnemonic.fromEntropy(diceRollsToEntropy(_rolls(rolls), length)),
  );
}

void main() {
  group('DiceSeedLength', () {
    test('matches SeedSigner roll counts and entropy sizes', () {
      expect(DiceSeedLength.words12.rolls, 50);
      expect(DiceSeedLength.words12.entropyBytes, 16);
      expect(DiceSeedLength.words12.words, 12);
      expect(DiceSeedLength.words24.rolls, 99);
      expect(DiceSeedLength.words24.entropyBytes, 32);
      expect(DiceSeedLength.words24.words, 24);
    });
  });

  group('diceRollsToEntropy vectors', () {
    test('99 rolls: 5, then 44 twos, then 54 fives', () {
      expect(
        _seedFor('5${'2' * 44}${'5' * 54}', DiceSeedLength.words24),
        'resource timber firm banner horror pupil frozen main pear direct '
        'pioneer broken grid core insane begin sister pony end debate task '
        'silk empty curious',
      );
    });

    test('99 rolls: 45 twos, then 54 fives', () {
      expect(
        _seedFor('${'2' * 45}${'5' * 54}', DiceSeedLength.words24),
        'garden uphold level clog sword globe armor issue two cute scorpion '
        'improve verb artwork blind tail raw butter combine move produce foil '
        'feature wave',
      );
    });

    test('99 rolls: 45 twos, 53 fives, then a six', () {
      expect(
        _seedFor('${'2' * 45}${'5' * 53}6', DiceSeedLength.words24),
        'lizard broken love tired depend eyebrow excess lonely advance father '
        'various cram ignore panic feed plunge miss regret boring unique '
        'galaxy fan detail fly',
      );
    });

    test('50 rolls: 123456 eight times, then 12', () {
      expect(
        _seedFor('${'123456' * 8}12', DiceSeedLength.words12),
        'unveil nice picture region tragic fault cream strike tourist control '
        'recipe tourist',
      );
    });

    test('50 rolls of 1', () {
      expect(
        _seedFor('1' * 50, DiceSeedLength.words12),
        'diet glad hat rural panther lawsuit act drop gallery urge where fit',
      );
    });

    test('50 rolls of 6', () {
      expect(
        _seedFor('6' * 50, DiceSeedLength.words12),
        'senior morning song proud recycle toy search apple trigger lend '
        'vibrant arrest',
      );
    });

    test('12-word seeds use 16 bytes and 24-word seeds use 32 bytes', () {
      expect(
        diceRollsToEntropy(_rolls('1' * 50), DiceSeedLength.words12),
        hasLength(16),
      );
      expect(
        diceRollsToEntropy(_rolls('1' * 99), DiceSeedLength.words24),
        hasLength(32),
      );
    });
  });

  group('diceRollsToEntropy validation', () {
    test('wrong roll count throws ArgumentError', () {
      expect(
        () => diceRollsToEntropy(_rolls('1' * 49), DiceSeedLength.words12),
        throwsArgumentError,
      );
      expect(
        () => diceRollsToEntropy(_rolls('1' * 51), DiceSeedLength.words12),
        throwsArgumentError,
      );
      expect(
        () => diceRollsToEntropy(_rolls('1' * 98), DiceSeedLength.words24),
        throwsArgumentError,
      );
      expect(
        () => diceRollsToEntropy(_rolls('123456'), DiceSeedLength.words24),
        throwsArgumentError,
      );
    });

    test('values outside 1..6 throw ArgumentError', () {
      for (final bad in [0, 7, -1, 9]) {
        final rolls = List<int>.filled(50, 3)..[10] = bad;
        expect(
          () => diceRollsToEntropy(rolls, DiceSeedLength.words12),
          throwsArgumentError,
          reason: 'value $bad',
        );
      }
    });
  });

  group('diceEntropyBits', () {
    test('one roll is log2(6) bits', () {
      expect(diceBitsPerRoll, closeTo(2.584962500721156, 1e-12));
      expect(diceEntropyBits(1), closeTo(2.58, 0.01));
    });

    test('99 rolls give about 255.9 bits', () {
      expect(diceEntropyBits(99), closeTo(255.9, 0.1));
    });

    test('50 rolls give about 129.2 bits', () {
      expect(diceEntropyBits(50), closeTo(129.2, 0.1));
    });
  });

  group('DiceRollStats', () {
    test('counts each face', () {
      final stats = DiceRollStats.of([1, 1, 2, 3, 3, 3, 6]);
      expect(stats.counts, [2, 1, 3, 0, 0, 1]);
      expect(stats.total, 7);
    });

    test('empty input has zero counts and no bias', () {
      final stats = DiceRollStats.of(const []);
      expect(stats.counts, [0, 0, 0, 0, 0, 0]);
      expect(stats.total, 0);
      expect(stats.chiSquare, 0);
      expect(stats.looksBiased, isFalse);
    });

    test('counts are read-only', () {
      final stats = DiceRollStats.of([1, 2]);
      expect(() => stats.counts[0] = 5, throwsUnsupportedError);
    });

    test('perfectly even rolls have chi-square 0', () {
      final stats = DiceRollStats.of([1, 2, 3, 4, 5, 6]);
      expect(stats.chiSquare, 0);
      expect(stats.looksBiased, isFalse);
    });

    test('chi-square for ten 1s', () {
      final stats = DiceRollStats.of(List.filled(10, 1));
      expect(stats.chiSquare, closeTo(50, 1e-9));
    });

    test('total below 30 never looks biased', () {
      final stats = DiceRollStats.of(List.filled(20, 6));
      expect(stats.chiSquare, greaterThan(20.515));
      expect(stats.looksBiased, isFalse);
    });

    test('99 sixes look biased', () {
      final stats = DiceRollStats.of(List.filled(99, 6));
      expect(stats.total, 99);
      expect(stats.chiSquare, closeTo(495, 1e-9));
      expect(stats.looksBiased, isTrue);
    });

    test('a balanced 30 rolls does not look biased', () {
      final stats = DiceRollStats.of([
        for (var face = 1; face <= 6; face++) ...List.filled(5, face),
      ]);
      expect(stats.total, 30);
      expect(stats.looksBiased, isFalse);
    });

    test('values outside 1..6 throw ArgumentError', () {
      expect(() => DiceRollStats.of([1, 7]), throwsArgumentError);
      expect(() => DiceRollStats.of([0]), throwsArgumentError);
    });
  });
}
