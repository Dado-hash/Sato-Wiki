import 'package:flutter/foundation.dart';

import '../domain/bip39.dart';
import '../domain/dice_entropy.dart';

/// In-memory state of one dice session. Nothing is persisted; [wipe] zeroes
/// everything. Rolls, entropy and words stay in typed buffers so they can be
/// overwritten, and nothing here is logged.
class DiceSessionController extends ChangeNotifier {
  DiceSessionController({required this.length})
    : _rolls = Uint8List(length.rolls);

  final DiceSeedLength length;

  /// Dice read in each throw. The sandbox asks for throws of this size.
  static const dicePerThrow = 5;

  final Uint8List _rolls;
  final List<int> _throwSizes = [];
  int _rollCount = 0;
  Bip39Mnemonic? _mnemonic;
  bool _revealed = false;
  int _selectedWord = 0;
  bool _wiped = false;

  /// Rolls recorded so far.
  int get rollCount => _rollCount;

  /// Rolls the seed length needs.
  int get requiredRolls => length.rolls;

  /// Roll at [index], 0-based, among the recorded rolls.
  int rollAt(int index) {
    RangeError.checkValidIndex(index, _rolls, 'index', _rollCount);

    return _rolls[index];
  }

  /// Throws recorded so far.
  int get throwCount => _throwSizes.length;

  /// Throws needed to roll every die the seed length requires.
  int get throwsNeeded => (requiredRolls / dicePerThrow).ceil();

  /// Values of the most recent throw, or an empty list when there is none.
  List<int> get lastThrow {
    if (_throwSizes.isEmpty) {
      return const [];
    }
    final size = _throwSizes.last;

    return _rolls.sublist(_rollCount - size, _rollCount);
  }

  /// Entropy collected so far, capped at the size of the seed.
  double get entropyBits {
    final cap = (length.entropyBytes * 8).toDouble();
    final bits = diceEntropyBits(_rollCount);

    return bits > cap ? cap : bits;
  }

  /// Face counts and the fairness check over the recorded rolls.
  DiceRollStats get stats => DiceRollStats.of(_rolls.take(_rollCount));

  /// True once every required roll is recorded.
  bool get isComplete => _rollCount == requiredRolls;

  /// Appends one throw of 1 to [dicePerThrow] values, each 1..6. Values beyond
  /// the required rolls are ignored. Invalid values throw an [ArgumentError]
  /// and change nothing.
  void addThrow(List<int> values) {
    _checkValues(values);
    final room = requiredRolls - _rollCount;
    final accepted = values.length < room ? values.length : room;
    if (accepted == 0) {
      return;
    }

    for (var i = 0; i < accepted; i++) {
      _rolls[_rollCount + i] = values[i];
    }
    _rollCount += accepted;
    _throwSizes.add(accepted);
    _wiped = false;
    _invalidateMnemonic();
    notifyListeners();
  }

  /// Replaces the most recent throw with [values]. Does nothing when no throw
  /// has been recorded.
  void replaceLastThrow(List<int> values) {
    _checkValues(values);
    if (_throwSizes.isEmpty) {
      return;
    }
    _removeLastThrow();
    addThrow(values);
  }

  /// Removes the most recent throw and its rolls.
  void undoLastThrow() {
    if (_throwSizes.isEmpty) {
      return;
    }
    _removeLastThrow();
    notifyListeners();
  }

  /// The BIP39 mnemonic, built on first use once every roll is recorded.
  /// Null before that. Rebuilt after undo or replace.
  Bip39Mnemonic? get mnemonic {
    if (!isComplete) {
      return null;
    }
    final existing = _mnemonic;
    if (existing != null) {
      return existing;
    }

    final entropy = diceRollsToEntropy(_rolls, length);
    try {
      _mnemonic = Bip39Mnemonic.fromEntropy(entropy);
    } finally {
      entropy.fillRange(0, entropy.length, 0);
    }

    return _mnemonic;
  }

  /// Whether the words are shown while the reveal control is held.
  bool get revealed => _revealed;

  void setRevealed(bool value) {
    if (_revealed == value) {
      return;
    }
    _revealed = value;
    notifyListeners();
  }

  /// Word highlighted for the bits view, 0-based.
  int get selectedWord => _selectedWord;

  void selectWord(int index) {
    RangeError.checkValueInInterval(index, 0, length.words - 1, 'index');
    if (_selectedWord == index) {
      return;
    }
    _selectedWord = index;
    notifyListeners();
  }

  /// True after [wipe] until a throw is recorded again.
  bool get isWiped => _wiped;

  /// Zeroes rolls, entropy and words, and resets every counter.
  void wipe() {
    _erase();
    notifyListeners();
  }

  @override
  void dispose() {
    _erase();
    super.dispose();
  }

  void _erase() {
    _rolls.fillRange(0, _rolls.length, 0);
    _throwSizes.clear();
    _rollCount = 0;
    _invalidateMnemonic();
    _revealed = false;
    _selectedWord = 0;
    _wiped = true;
  }

  void _removeLastThrow() {
    final size = _throwSizes.removeLast();
    final start = _rollCount - size;
    _rolls.fillRange(start, _rollCount, 0);
    _rollCount = start;
    _invalidateMnemonic();
  }

  void _invalidateMnemonic() {
    _mnemonic?.wipe();
    _mnemonic = null;
  }

  static void _checkValues(List<int> values) {
    if (values.isEmpty || values.length > dicePerThrow) {
      throw ArgumentError.value(
        values.length,
        'values.length',
        'A throw holds 1 to $dicePerThrow dice',
      );
    }
    for (final value in values) {
      if (value < 1 || value > 6) {
        throw ArgumentError.value(value, 'values', 'A die shows 1..6');
      }
    }
  }
}
