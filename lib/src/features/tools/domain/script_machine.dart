import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;

import 'hash160.dart';
import 'ripemd160.dart';
import 'script_number.dart';
import 'script_opcodes.dart';
import 'script_parser.dart';
import 'tools_bytes.dart';

/// Step-by-step Bitcoin Script interpreter for the teaching tools.
///
/// This is a TEACHING INTERPRETER, NOT CONSENSUS CODE. It follows Bitcoin
/// Core's rules for the opcodes it supports, but it runs a single script with
/// no transaction, no signature checks and no policy rules. Never use it to
/// decide whether a real transaction is valid.
///
/// Signature opcodes are SIMULATED: a signature is valid for a public key when
/// `'<sig hex>:<pubkey hex>'` (lowercase hex) is in the valid set. Every
/// executed signature step carries [ScriptStepNote.signatureSimulated].
///
/// Differences from Bitcoin Core:
/// - Minimal script numbers are always required (Core does so only with the
///   MINIMALDATA flag), and pushes are never checked for minimal encoding.
/// - OP_CHECKLOCKTIMEVERIFY and OP_CHECKSEQUENCEVERIFY are always enforced,
///   as BIP 65 and BIP 112 describe them. Core applies them only with the
///   matching script flag.
/// - This machine runs one script. Bitcoin runs the unlocking and locking
///   scripts separately, each with its own opcode count and alt stack, so
///   [ScriptExample.createMachine] can differ on very long scripts.
/// - There is no P2SH, SegWit or Taproot evaluation.
///
/// Pure Dart, no Flutter imports.

/// A note attached to a step, explaining something the user should know.
enum ScriptStepNote {
  /// A signature check ran against the simulated set, not a real signature.
  signatureSimulated,

  /// A timelock check passed.
  timelockSatisfied,

  /// A timelock check failed.
  timelockNotSatisfied,

  /// The relative timelock is disabled by its flag, so the opcode does
  /// nothing (BIP 112).
  timelockDisabled,

  /// A timelock opcode needs the transaction context, which was not given.
  needsContext,
}

/// The reason a script failed. The machine is finished after an error.
enum ScriptError {
  /// An opcode needs more stack items than there are.
  stackUnderflow,

  /// FROMALTSTACK ran with an empty alt stack.
  altStackUnderflow,

  /// OP_VERIFY, OP_CHECKSIGVERIFY or OP_CHECKMULTISIGVERIFY failed.
  verifyFailed,

  /// OP_EQUALVERIFY found two different items.
  equalVerifyFailed,

  /// OP_NUMEQUALVERIFY found two different numbers.
  numEqualVerifyFailed,

  /// OP_RETURN ran.
  opReturn,

  /// A disabled opcode appeared, even in a branch that was not executed.
  disabledOpcode,

  /// An opcode that is not implemented here ran.
  unsupportedOpcode,

  /// ELSE or ENDIF with no open IF, or an IF still open when the script ends.
  unbalancedConditional,

  /// A number operand is longer than 4 bytes (5 bytes for timelocks).
  numberOverflow,

  /// A number operand is not minimally encoded.
  nonMinimalNumber,

  /// A data push is longer than 520 bytes.
  pushTooLarge,

  /// The stack and alt stack together hold more than 1000 items.
  stackTooLarge,

  /// More than 201 non-push opcodes ran.
  opCountExceeded,

  /// PICK or ROLL asked for a depth that the stack does not have.
  badPickIndex,

  /// OP_CHECKMULTISIG asked for fewer than 0 or more than 20 keys.
  keyCountOutOfRange,

  /// OP_CHECKMULTISIG asked for more signatures than keys, or a negative
  /// count.
  sigCountOutOfRange,

  /// A timelock operand is negative.
  negativeLockTime,

  /// The transaction's lock time or sequence is below the required value.
  lockTimeNotReached,

  /// The timelock operand and the transaction use different types (block
  /// height and time).
  lockTimeTypeMismatch,

  /// OP_CHECKLOCKTIMEVERIFY cannot pass because the input sequence is final.
  inputSequenceFinal,

  /// OP_CHECKSEQUENCEVERIFY cannot pass because the input sequence disables
  /// relative timelocks.
  inputSequenceDisabled,

  /// OP_CHECKSEQUENCEVERIFY needs transaction version 2 or higher.
  txVersionTooLow,

  /// A timelock opcode ran without the transaction context it needs.
  missingContext,

  /// The serialized script is longer than 10,000 bytes. Checked before the
  /// first element runs.
  scriptTooLarge,
}

/// The result of one [ScriptMachine.step].
final class ScriptStepResult {
  /// Creates a step result. The stacks are copies, bottom item first.
  const ScriptStepResult({
    required this.index,
    required this.element,
    required this.stack,
    required this.altStack,
    required this.executed,
    this.note,
    this.error,
  });

  /// Position of [element] in the script.
  final int index;

  /// The element that ran.
  final ScriptElement element;

  /// Main stack after the step, bottom item first.
  final List<Uint8List> stack;

  /// Alt stack after the step, bottom item first.
  final List<Uint8List> altStack;

  /// False when the element was skipped inside a branch that was not taken.
  /// IF, NOTIF, ELSE and ENDIF count as executed when no enclosing branch
  /// blocks them.
  final bool executed;

  /// A note about this step, if any.
  final ScriptStepNote? note;

  /// The failure that ended the script at this step, if any.
  final ScriptError? error;
}

/// Runs a script one element at a time and records the stacks after each.
final class ScriptMachine {
  /// Creates a machine for [elements], ready to step from the first element.
  ///
  /// [lockTime], [inputSequence] and [txVersion] describe the spending
  /// transaction for the timelock opcodes. When one of them is null, a
  /// timelock opcode that needs it fails with [ScriptError.missingContext].
  ///
  /// [initialStack] is the main stack the script starts from, bottom item
  /// first. Bitcoin runs the unlocking script and then the locking script on
  /// the stack the first one leaves, so the second machine starts with it.
  ///
  /// [validSignatures] holds `'<sig hex>:<pubkey hex>'` entries in lowercase
  /// hex. Throws an [ArgumentError] if [elements] contains an OP_PUSHDATA
  /// opcode, because pushes are represented as [ScriptPush].
  ScriptMachine(
    List<ScriptElement> elements, {
    this.lockTime,
    this.inputSequence,
    this.txVersion,
    Set<String> validSignatures = const <String>{},
    List<Uint8List> initialStack = const <Uint8List>[],
  }) : _elements = List.unmodifiable(elements),
       validSignatures = Set.unmodifiable(validSignatures),
       _initialStack = List<Uint8List>.unmodifiable(initialStack),
       _stack = List<Uint8List>.of(initialStack),
       _oversize = serializeScript(elements).length > _maxScriptSize {
    for (final element in elements) {
      if (element is ScriptOp &&
          element.opcode.byte >= 0x4c &&
          element.opcode.byte <= 0x4e) {
        throw ArgumentError.value(element, 'elements', 'Use ScriptPush');
      }
    }
  }

  /// Lock time of the spending transaction, for OP_CHECKLOCKTIMEVERIFY.
  final int? lockTime;

  /// Sequence of the input being checked, for both timelock opcodes.
  final int? inputSequence;

  /// Version of the spending transaction, for OP_CHECKSEQUENCEVERIFY.
  final int? txVersion;

  /// Simulated valid signatures, as `'<sig hex>:<pubkey hex>'`.
  final Set<String> validSignatures;

  final List<ScriptElement> _elements;
  final bool _oversize;
  final List<Uint8List> _initialStack;
  List<Uint8List> _stack;
  List<Uint8List> _altStack = <Uint8List>[];
  List<bool> _branches = <bool>[];
  int _next = 0;
  int _opCount = 0;
  ScriptError? _error;
  ScriptStepNote? _note;

  static const _maxElementSize = 520;
  static const _maxStackSize = 1000;
  static const _maxOpCount = 201;
  static const _maxScriptSize = 10000;
  static const _lockTimeThreshold = 500000000;
  static const _sequenceFinal = 0xffffffff;
  static const _sequenceDisableFlag = 1 << 31;
  static const _sequenceTypeFlag = 1 << 22;
  static const _sequenceMask = 0x0000ffff;

  /// Whether the script has finished: it failed, or every element has run.
  bool get isFinished => _error != null || _next >= _elements.length;

  /// Whether the script passed.
  ///
  /// Null while the script is running. False after an error or when the top
  /// item is false or the stack is empty. True when the top item is true.
  bool? get succeeded {
    if (!isFinished) {
      return null;
    }
    if (_error != null) {
      return false;
    }

    return _stack.isNotEmpty && castToBool(_stack.last);
  }

  /// The error that ended the script, or null.
  ScriptError? get error => _error;

  /// Runs the next element and returns what happened.
  ///
  /// Throws a [StateError] when the script has already finished.
  ScriptStepResult step() {
    if (isFinished) {
      throw StateError('The script has already finished.');
    }
    final index = _next;
    final element = _elements[index];
    _next++;
    _note = null;
    final executed = _enclosingTaken(element);
    ScriptError? failure;
    try {
      if (_oversize) {
        throw const _ScriptFailure(ScriptError.scriptTooLarge);
      }
      _apply(element);
      if (_stack.length + _altStack.length > _maxStackSize) {
        throw const _ScriptFailure(ScriptError.stackTooLarge);
      }
      if (_next == _elements.length && _branches.isNotEmpty) {
        throw const _ScriptFailure(ScriptError.unbalancedConditional);
      }
    } on _ScriptFailure catch (failureSignal) {
      failure = failureSignal.error;
    }
    _error = failure;

    return ScriptStepResult(
      index: index,
      element: element,
      stack: List.unmodifiable(_stack),
      altStack: List.unmodifiable(_altStack),
      executed: executed,
      note: _note,
      error: failure,
    );
  }

  /// Runs every remaining element and returns each step's result.
  List<ScriptStepResult> runAll() {
    final results = <ScriptStepResult>[];
    while (!isFinished) {
      results.add(step());
    }

    return results;
  }

  /// Returns the machine to its first element with empty stacks.
  void reset() {
    _stack = List<Uint8List>.of(_initialStack);
    _altStack = <Uint8List>[];
    _branches = <bool>[];
    _next = 0;
    _opCount = 0;
    _error = null;
    _note = null;
  }

  bool get _executing => _branches.every((taken) => taken);

  static bool _isControl(ScriptOpcode opcode) {
    return opcode.name == 'OP_IF' ||
        opcode.name == 'OP_NOTIF' ||
        opcode.name == 'OP_ELSE' ||
        opcode.name == 'OP_ENDIF';
  }

  /// Whether every branch enclosing [element] is taken. For ELSE and ENDIF
  /// the innermost branch is not counted, because the ELSE or ENDIF belongs to
  /// it.
  bool _enclosingTaken(ScriptElement element) {
    var count = _branches.length;
    if (element is ScriptOp &&
        (element.opcode.name == 'OP_ELSE' ||
            element.opcode.name == 'OP_ENDIF') &&
        count > 0) {
      count--;
    }

    return _branches.take(count).every((taken) => taken);
  }

  void _apply(ScriptElement element) {
    if (element is ScriptPush) {
      if (element.data.length > _maxElementSize) {
        throw const _ScriptFailure(ScriptError.pushTooLarge);
      }
      if (_executing) {
        _stack.add(element.data);
      }

      return;
    }

    final opcode = (element as ScriptOp).opcode;
    if (opcode.byte > 0x60 && ++_opCount > _maxOpCount) {
      throw const _ScriptFailure(ScriptError.opCountExceeded);
    }
    if (opcode.support == ScriptOpcodeSupport.disabled) {
      throw const _ScriptFailure(ScriptError.disabledOpcode);
    }
    if (!_executing && !_isControl(opcode)) {
      return;
    }

    _run(opcode);
  }

  void _run(ScriptOpcode opcode) {
    final byte = opcode.byte;
    if (byte == 0x00) {
      _push(const <int>[]);

      return;
    }
    if (byte == 0x4f) {
      _push(const <int>[0x81]);

      return;
    }
    if (byte >= 0x51 && byte <= 0x60) {
      _push(<int>[byte - 0x50]);

      return;
    }

    switch (opcode.name) {
      case 'OP_NOP':
      case 'OP_NOP1':
      case 'OP_NOP4':
      case 'OP_NOP5':
      case 'OP_NOP6':
      case 'OP_NOP7':
      case 'OP_NOP8':
      case 'OP_NOP9':
      case 'OP_NOP10':
      case 'OP_CODESEPARATOR':
        break;
      case 'OP_IF':
      case 'OP_NOTIF':
        _openBranch(negate: opcode.name == 'OP_NOTIF');
      case 'OP_ELSE':
        if (_branches.isEmpty) {
          throw const _ScriptFailure(ScriptError.unbalancedConditional);
        }
        _branches[_branches.length - 1] = !_branches.last;
      case 'OP_ENDIF':
        if (_branches.isEmpty) {
          throw const _ScriptFailure(ScriptError.unbalancedConditional);
        }
        _branches.removeLast();
      case 'OP_VERIFY':
        if (!castToBool(_pop())) {
          throw const _ScriptFailure(ScriptError.verifyFailed);
        }
      case 'OP_RETURN':
        throw const _ScriptFailure(ScriptError.opReturn);
      case 'OP_TOALTSTACK':
        _altStack.add(_pop());
      case 'OP_FROMALTSTACK':
        if (_altStack.isEmpty) {
          throw const _ScriptFailure(ScriptError.altStackUnderflow);
        }
        _stack.add(_altStack.removeLast());
      case 'OP_IFDUP':
        _need(1);
        if (castToBool(_top(0))) {
          _stack.add(_top(0));
        }
      case 'OP_DEPTH':
        _pushNumber(_stack.length);
      case 'OP_DROP':
        _pop();
      case 'OP_DUP':
        _need(1);
        _stack.add(_top(0));
      case 'OP_NIP':
        _need(2);
        _stack.removeAt(_stack.length - 2);
      case 'OP_OVER':
        _need(2);
        _stack.add(_top(1));
      case 'OP_PICK':
        final depth = _popNumber();
        _checkDepth(depth);
        _stack.add(_stack[_stack.length - 1 - depth]);
      case 'OP_ROLL':
        final depth = _popNumber();
        _checkDepth(depth);
        _stack.add(_stack.removeAt(_stack.length - 1 - depth));
      case 'OP_ROT':
        _need(3);
        _stack.add(_stack.removeAt(_stack.length - 3));
      case 'OP_SWAP':
        _need(2);
        final top = _stack.removeLast();
        _stack.insert(_stack.length - 1, top);
      case 'OP_TUCK':
        _need(2);
        _stack.insert(_stack.length - 2, _top(0));
      case 'OP_2DROP':
        _need(2);
        _stack.removeRange(_stack.length - 2, _stack.length);
      case 'OP_2DUP':
        _need(2);
        _stack.addAll([_top(1), _top(0)]);
      case 'OP_3DUP':
        _need(3);
        _stack.addAll([_top(2), _top(1), _top(0)]);
      case 'OP_2OVER':
        _need(4);
        _stack.addAll([_top(3), _top(2)]);
      case 'OP_2ROT':
        _need(6);
        final first = _stack.removeAt(_stack.length - 6);
        final second = _stack.removeAt(_stack.length - 5);
        _stack.addAll([first, second]);
      case 'OP_2SWAP':
        _need(4);
        final first = _stack.removeAt(_stack.length - 4);
        final second = _stack.removeAt(_stack.length - 3);
        _stack.addAll([first, second]);
      case 'OP_SIZE':
        _need(1);
        _pushNumber(_top(0).length);
      case 'OP_EQUAL':
        _pushBool(_popPair());
      case 'OP_EQUALVERIFY':
        if (!_popPair()) {
          throw const _ScriptFailure(ScriptError.equalVerifyFailed);
        }
      case 'OP_1ADD':
        _pushNumber(_popNumber() + 1);
      case 'OP_1SUB':
        _pushNumber(_popNumber() - 1);
      case 'OP_NEGATE':
        _pushNumber(-_popNumber());
      case 'OP_ABS':
        _pushNumber(_popNumber().abs());
      case 'OP_NOT':
        _pushBool(_popNumber() == 0);
      case 'OP_0NOTEQUAL':
        _pushBool(_popNumber() != 0);
      case 'OP_ADD':
        final pair = _popNumberPair();
        _pushNumber(pair.$1 + pair.$2);
      case 'OP_SUB':
        final pair = _popNumberPair();
        _pushNumber(pair.$1 - pair.$2);
      case 'OP_BOOLAND':
        final pair = _popNumberPair();
        _pushBool(pair.$1 != 0 && pair.$2 != 0);
      case 'OP_BOOLOR':
        final pair = _popNumberPair();
        _pushBool(pair.$1 != 0 || pair.$2 != 0);
      case 'OP_NUMEQUAL':
        final pair = _popNumberPair();
        _pushBool(pair.$1 == pair.$2);
      case 'OP_NUMEQUALVERIFY':
        final pair = _popNumberPair();
        if (pair.$1 != pair.$2) {
          throw const _ScriptFailure(ScriptError.numEqualVerifyFailed);
        }
      case 'OP_NUMNOTEQUAL':
        final pair = _popNumberPair();
        _pushBool(pair.$1 != pair.$2);
      case 'OP_LESSTHAN':
        final pair = _popNumberPair();
        _pushBool(pair.$1 < pair.$2);
      case 'OP_GREATERTHAN':
        final pair = _popNumberPair();
        _pushBool(pair.$1 > pair.$2);
      case 'OP_LESSTHANOREQUAL':
        final pair = _popNumberPair();
        _pushBool(pair.$1 <= pair.$2);
      case 'OP_GREATERTHANOREQUAL':
        final pair = _popNumberPair();
        _pushBool(pair.$1 >= pair.$2);
      case 'OP_MIN':
        final pair = _popNumberPair();
        _pushNumber(pair.$1 < pair.$2 ? pair.$1 : pair.$2);
      case 'OP_MAX':
        final pair = _popNumberPair();
        _pushNumber(pair.$1 > pair.$2 ? pair.$1 : pair.$2);
      case 'OP_WITHIN':
        _need(3);
        final maximum = _decode(_top(0));
        final minimum = _decode(_top(1));
        final value = _decode(_top(2));
        _stack.removeRange(_stack.length - 3, _stack.length);
        _pushBool(minimum <= value && value < maximum);
      case 'OP_RIPEMD160':
        _push(ripemd160(_pop()));
      case 'OP_SHA1':
        _push(Uint8List.fromList(crypto.sha1.convert(_pop()).bytes));
      case 'OP_SHA256':
        _push(sha256Bytes(_pop()));
      case 'OP_HASH160':
        _push(hash160(_pop()));
      case 'OP_HASH256':
        _push(doubleSha256(_pop()));
      case 'OP_CHECKLOCKTIMEVERIFY':
        _checkLockTime();
      case 'OP_CHECKSEQUENCEVERIFY':
        _checkSequence();
      case 'OP_CHECKSIG':
        _need(2);
        final publicKey = _pop();
        final signature = _pop();
        _note = ScriptStepNote.signatureSimulated;
        _pushBool(_isSimulatedValid(signature, publicKey));
      case 'OP_CHECKSIGVERIFY':
        _need(2);
        final publicKey = _pop();
        final signature = _pop();
        _note = ScriptStepNote.signatureSimulated;
        if (!_isSimulatedValid(signature, publicKey)) {
          throw const _ScriptFailure(ScriptError.verifyFailed);
        }
      case 'OP_CHECKMULTISIG':
        _checkMultisig(verify: false);
      case 'OP_CHECKMULTISIGVERIFY':
        _checkMultisig(verify: true);
      default:
        throw const _ScriptFailure(ScriptError.unsupportedOpcode);
    }
  }

  void _openBranch({required bool negate}) {
    var taken = false;
    if (_executing) {
      if (_stack.isEmpty) {
        throw const _ScriptFailure(ScriptError.stackUnderflow);
      }
      taken = castToBool(_stack.removeLast());
      if (negate) {
        taken = !taken;
      }
    }
    _branches.add(taken);
  }

  void _checkLockTime() {
    _need(1);
    final operand = _decode(_top(0), maxLength: 5);
    if (operand < 0) {
      throw const _ScriptFailure(ScriptError.negativeLockTime);
    }
    final transactionLockTime = lockTime;
    final sequence = inputSequence;
    if (transactionLockTime == null || sequence == null) {
      _note = ScriptStepNote.needsContext;
      throw const _ScriptFailure(ScriptError.missingContext);
    }

    final operandIsTime = operand >= _lockTimeThreshold;
    final transactionIsTime = transactionLockTime >= _lockTimeThreshold;
    if (operandIsTime != transactionIsTime) {
      _note = ScriptStepNote.timelockNotSatisfied;
      throw const _ScriptFailure(ScriptError.lockTimeTypeMismatch);
    }
    if (operand > transactionLockTime) {
      _note = ScriptStepNote.timelockNotSatisfied;
      throw const _ScriptFailure(ScriptError.lockTimeNotReached);
    }
    if (sequence == _sequenceFinal) {
      _note = ScriptStepNote.timelockNotSatisfied;
      throw const _ScriptFailure(ScriptError.inputSequenceFinal);
    }
    _note = ScriptStepNote.timelockSatisfied;
  }

  void _checkSequence() {
    _need(1);
    final operand = _decode(_top(0), maxLength: 5);
    if (operand < 0) {
      throw const _ScriptFailure(ScriptError.negativeLockTime);
    }
    if (operand & _sequenceDisableFlag != 0) {
      _note = ScriptStepNote.timelockDisabled;

      return;
    }
    final version = txVersion;
    final sequence = inputSequence;
    if (version == null || sequence == null) {
      _note = ScriptStepNote.needsContext;
      throw const _ScriptFailure(ScriptError.missingContext);
    }

    if (version < 2) {
      _note = ScriptStepNote.timelockNotSatisfied;
      throw const _ScriptFailure(ScriptError.txVersionTooLow);
    }
    if (sequence & _sequenceDisableFlag != 0) {
      _note = ScriptStepNote.timelockNotSatisfied;
      throw const _ScriptFailure(ScriptError.inputSequenceDisabled);
    }

    const mask = _sequenceTypeFlag | _sequenceMask;
    final maskedSequence = sequence & mask;
    final maskedOperand = operand & mask;
    final sequenceIsTime = maskedSequence >= _sequenceTypeFlag;
    final operandIsTime = maskedOperand >= _sequenceTypeFlag;
    if (sequenceIsTime != operandIsTime) {
      _note = ScriptStepNote.timelockNotSatisfied;
      throw const _ScriptFailure(ScriptError.lockTimeTypeMismatch);
    }
    if (maskedOperand > maskedSequence) {
      _note = ScriptStepNote.timelockNotSatisfied;
      throw const _ScriptFailure(ScriptError.lockTimeNotReached);
    }
    _note = ScriptStepNote.timelockSatisfied;
  }

  void _checkMultisig({required bool verify}) {
    _need(1);
    final keyCount = _popNumber();
    if (keyCount < 0 || keyCount > 20) {
      throw const _ScriptFailure(ScriptError.keyCountOutOfRange);
    }
    _need(keyCount);
    // keys[0] is the top key, which Core compares first.
    final keys = List<Uint8List>.generate(keyCount, (_) => _pop());

    _need(1);
    final signatureCount = _popNumber();
    if (signatureCount < 0 || signatureCount > keyCount) {
      throw const _ScriptFailure(ScriptError.sigCountOutOfRange);
    }
    _need(signatureCount);
    final signatures = List<Uint8List>.generate(signatureCount, (_) => _pop());

    // The dummy item that Bitcoin pops because of an off-by-one bug.
    _pop();

    _note = ScriptStepNote.signatureSimulated;
    var signatureIndex = 0;
    var keyIndex = 0;
    var success = true;
    while (success && signatureIndex < signatures.length) {
      if (_isSimulatedValid(signatures[signatureIndex], keys[keyIndex])) {
        signatureIndex++;
      }
      keyIndex++;
      if (signatures.length - signatureIndex > keyCount - keyIndex) {
        success = false;
      }
    }
    success = success && signatureIndex == signatures.length;

    if (verify) {
      if (!success) {
        throw const _ScriptFailure(ScriptError.verifyFailed);
      }
    } else {
      _pushBool(success);
    }
  }

  bool _isSimulatedValid(Uint8List signature, Uint8List publicKey) {
    if (signature.isEmpty) {
      return false;
    }

    return validSignatures.contains(
      '${hexEncode(signature)}:${hexEncode(publicKey)}',
    );
  }

  void _need(int count) {
    if (_stack.length < count) {
      throw const _ScriptFailure(ScriptError.stackUnderflow);
    }
  }

  Uint8List _top(int depth) => _stack[_stack.length - 1 - depth];

  Uint8List _pop() {
    _need(1);

    return _stack.removeLast();
  }

  void _push(List<int> bytes) {
    _stack.add(Uint8List.fromList(bytes));
  }

  void _pushBool(bool value) {
    _push(value ? const <int>[1] : const <int>[]);
  }

  void _pushNumber(int value) {
    _push(encodeScriptNumber(value));
  }

  /// Pops the two items on top and reports whether they are equal.
  bool _popPair() {
    _need(2);
    final top = _pop();
    final below = _pop();
    if (top.length != below.length) {
      return false;
    }
    for (var i = 0; i < top.length; i++) {
      if (top[i] != below[i]) {
        return false;
      }
    }

    return true;
  }

  int _decode(List<int> bytes, {int maxLength = 4}) {
    if (bytes.length > maxLength) {
      throw const _ScriptFailure(ScriptError.numberOverflow);
    }
    try {
      return decodeScriptNumber(bytes, maxLength: maxLength);
    } on FormatException {
      throw const _ScriptFailure(ScriptError.nonMinimalNumber);
    }
  }

  int _popNumber() => _decode(_pop());

  /// Pops two numbers and returns them as (below, top).
  (int, int) _popNumberPair() {
    _need(2);
    final top = _decode(_top(0));
    final below = _decode(_top(1));
    _stack.removeRange(_stack.length - 2, _stack.length);

    return (below, top);
  }

  void _checkDepth(int depth) {
    if (depth < 0 || depth >= _stack.length) {
      throw const _ScriptFailure(ScriptError.badPickIndex);
    }
  }
}

/// Internal signal carrying the error of a failed step.
final class _ScriptFailure implements Exception {
  const _ScriptFailure(this.error);

  final ScriptError error;
}
