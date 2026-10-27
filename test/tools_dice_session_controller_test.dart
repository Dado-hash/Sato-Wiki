import 'package:flutter_test/flutter_test.dart';
import 'package:sato_wiki/src/features/tools/domain/bip39.dart';
import 'package:sato_wiki/src/features/tools/domain/dice_entropy.dart';
import 'package:sato_wiki/src/features/tools/presentation/dice_session_controller.dart';

/// Splits [rolls] into throws of at most five dice, as the sandbox records them.
void _feed(DiceSessionController controller, List<int> rolls) {
  for (var start = 0; start < rolls.length; start += 5) {
    final end = start + 5 < rolls.length ? start + 5 : rolls.length;
    controller.addThrow(rolls.sublist(start, end));
  }
}

List<int> _digits(String text) => [
  for (final c in text.split('')) int.parse(c),
];

List<String> _wordsOf(Bip39Mnemonic mnemonic) => [
  for (var i = 0; i < mnemonic.wordCount; i++) mnemonic.wordAt(i),
];

/// SeedSigner 99-roll vector: 45 twos then 54 fives.
final _seedSignerRolls = _digits('2' * 45 + '5' * 54);
const _seedSignerWords =
    'garden uphold level clog sword globe armor issue two cute scorpion '
    'improve verb artwork blind tail raw butter combine move produce foil '
    'feature wave';

void main() {
  group('DiceSessionController', () {
    late DiceSessionController controller;

    setUp(() {
      controller = DiceSessionController(length: DiceSeedLength.words24);
    });

    tearDown(() {
      controller.dispose();
    });

    test('starts empty with the length requirements', () {
      expect(controller.rollCount, 0);
      expect(controller.requiredRolls, 99);
      expect(controller.throwCount, 0);
      expect(controller.throwsNeeded, 20);
      expect(controller.lastThrow, isEmpty);
      expect(controller.isComplete, isFalse);
      expect(controller.mnemonic, isNull);
      expect(controller.isWiped, isFalse);
      expect(controller.entropyBits, 0);
    });

    test('throws to completion build the SeedSigner 24-word seed', () {
      _feed(controller, _seedSignerRolls);

      expect(controller.rollCount, 99);
      expect(controller.throwCount, 20);
      expect(controller.isComplete, isTrue);
      expect(controller.lastThrow, [5, 5, 5, 5]);
      expect(controller.rollAt(0), 2);
      expect(controller.rollAt(98), 5);

      final mnemonic = controller.mnemonic!;
      expect(mnemonic.wordCount, 24);
      expect(_wordsOf(mnemonic).join(' '), _seedSignerWords);
    });

    test('12-word seed from 50 rolls matches the contract vector', () {
      final short = DiceSessionController(length: DiceSeedLength.words12);
      addTearDown(short.dispose);

      expect(short.throwsNeeded, 10);
      _feed(short, _digits('1' * 50));

      expect(short.isComplete, isTrue);
      expect(
        _wordsOf(short.mnemonic!).join(' '),
        'diet glad hat rural panther lawsuit act drop gallery urge where fit',
      );
    });

    test('extra values beyond the required rolls are ignored', () {
      _feed(controller, _seedSignerRolls);
      controller.addThrow([1, 2, 3]);

      expect(controller.rollCount, 99);
      expect(controller.throwCount, 20);
      expect(_wordsOf(controller.mnemonic!).join(' '), _seedSignerWords);
    });

    test('a throw that overflows is truncated to the remaining rolls', () {
      _feed(controller, _seedSignerRolls.sublist(0, 97));
      controller.addThrow([5, 5, 5, 5, 5]);

      expect(controller.rollCount, 99);
      expect(controller.throwCount, 21);
      expect(controller.lastThrow, [5, 5]);
      expect(controller.isComplete, isTrue);
    });

    test('mnemonic is null before completion and cached afterwards', () {
      _feed(controller, _seedSignerRolls.sublist(0, 98));
      expect(controller.mnemonic, isNull);

      controller.addThrow([5]);
      final first = controller.mnemonic;
      expect(first, isNotNull);
      expect(identical(controller.mnemonic, first), isTrue);
    });

    test('undo removes the mnemonic and re-adding restores the same words', () {
      _feed(controller, _seedSignerRolls);
      final before = controller.mnemonic!;
      final words = _wordsOf(before).join(' ');

      controller.undoLastThrow();
      expect(controller.rollCount, 95);
      expect(controller.throwCount, 19);
      expect(controller.mnemonic, isNull);
      expect(before.isWiped, isTrue);

      controller.addThrow([5, 5, 5, 5]);
      expect(_wordsOf(controller.mnemonic!).join(' '), words);
    });

    test('undo on an empty session does nothing', () {
      controller.undoLastThrow();

      expect(controller.rollCount, 0);
      expect(controller.throwCount, 0);
    });

    test('replace rebuilds the mnemonic from the new last throw', () {
      _feed(controller, _seedSignerRolls);

      // The last throw is four dice, rolls 96 to 99. Changing the final one
      // to a six gives the contract vector "2"*45 + "5"*53 + "6".
      controller.replaceLastThrow([5, 5, 5, 6]);

      expect(controller.rollCount, 99);
      expect(controller.throwCount, 20);
      expect(controller.rollAt(98), 6);
      expect(
        _wordsOf(controller.mnemonic!).join(' '),
        'lizard broken love tired depend eyebrow excess lonely advance father '
        'various cram ignore panic feed plunge miss regret boring unique '
        'galaxy fan detail fly',
      );
    });

    test('replace with no throws recorded does nothing', () {
      controller.replaceLastThrow([1, 2]);

      expect(controller.rollCount, 0);
      expect(controller.throwCount, 0);
    });

    test('invalid values throw and leave the session unchanged', () {
      controller.addThrow([1, 2]);

      expect(() => controller.addThrow([]), throwsArgumentError);
      expect(
        () => controller.addThrow([1, 2, 3, 4, 5, 6]),
        throwsArgumentError,
      );
      expect(() => controller.addThrow([0]), throwsArgumentError);
      expect(() => controller.addThrow([7]), throwsArgumentError);
      expect(() => controller.addThrow([3, -1]), throwsArgumentError);
      expect(() => controller.replaceLastThrow([9]), throwsArgumentError);

      expect(controller.rollCount, 2);
      expect(controller.throwCount, 1);
      expect(controller.rollAt(0), 1);
      expect(controller.rollAt(1), 2);
    });

    test('notifies listeners on each change', () {
      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.addThrow([1, 2]);
      controller.undoLastThrow();
      controller.setRevealed(true);
      controller.selectWord(3);

      expect(notifications, 4);
    });

    test(
      'entropy is the roll count times log2(6), capped at the seed size',
      () {
        final short = DiceSessionController(length: DiceSeedLength.words12);
        addTearDown(short.dispose);

        _feed(short, _digits('6' * 50));
        expect(short.entropyBits, 128.0);

        _feed(controller, _seedSignerRolls.sublist(0, 10));
        expect(controller.entropyBits, closeTo(diceEntropyBits(10), 1e-9));
      },
    );

    test('stats count the recorded rolls only', () {
      controller.addThrow([1, 1, 2]);

      expect(controller.stats.total, 3);
      expect(controller.stats.counts[0], 2);
      expect(controller.stats.counts[1], 1);
    });

    test('wipe zeroes rolls and the mnemonic and resets the session', () {
      _feed(controller, _seedSignerRolls);
      final mnemonic = controller.mnemonic!;
      controller.setRevealed(true);
      controller.selectWord(7);

      controller.wipe();

      expect(controller.rollCount, 0);
      expect(controller.throwCount, 0);
      expect(controller.lastThrow, isEmpty);
      expect(controller.mnemonic, isNull);
      expect(controller.revealed, isFalse);
      expect(controller.selectedWord, 0);
      expect(controller.isWiped, isTrue);
      expect(mnemonic.isWiped, isTrue);
      expect(() => controller.rollAt(0), throwsRangeError);
    });

    test('wipe notifies listeners', () {
      var notified = false;
      controller.addListener(() => notified = true);

      controller.wipe();

      expect(notified, isTrue);
    });

    test('recording a throw after wipe clears the wiped flag', () {
      controller.wipe();
      controller.addThrow([4]);

      expect(controller.isWiped, isFalse);
      expect(controller.rollCount, 1);
    });

    test('dispose wipes the mnemonic', () {
      final session = DiceSessionController(length: DiceSeedLength.words24);
      _feed(session, _seedSignerRolls);
      final mnemonic = session.mnemonic!;

      session.dispose();

      expect(mnemonic.isWiped, isTrue);
      expect(session.rollCount, 0);
      expect(session.isWiped, isTrue);
    });

    test('word selection stays within the seed length', () {
      controller.selectWord(23);
      expect(controller.selectedWord, 23);

      expect(() => controller.selectWord(24), throwsRangeError);
      expect(() => controller.selectWord(-1), throwsRangeError);
    });
  });
}
