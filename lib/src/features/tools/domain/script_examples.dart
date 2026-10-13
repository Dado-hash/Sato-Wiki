import 'dart:convert';

import 'hash160.dart';
import 'script_machine.dart';
import 'script_parser.dart';
import 'tools_bytes.dart';

/// Example scripts for the step-by-step script demo.
///
/// Keys and signatures are placeholders. Each example lists the simulated
/// signatures it needs, so the machine can check them without real keys.
/// Pure Dart, no Flutter imports. This is a teaching interpreter, not
/// consensus code.

/// One example: an unlocking script, a locking script, and the transaction
/// context its timelocks need.
final class ScriptExample {
  /// Creates an example. [id] is lowercase with hyphens.
  const ScriptExample({
    required this.id,
    required this.wikiEntryId,
    required this.unlocking,
    required this.locking,
    this.lockTime,
    this.inputSequence,
    this.txVersion,
    this.validSignatures = const <String>{},
  });

  /// Lowercase identifier with hyphens, such as `multisig-2-of-3`.
  final String id;

  /// Wiki entry that explains the example.
  final String wikiEntryId;

  /// Unlocking script in ASM. It runs before [locking].
  final String unlocking;

  /// Locking script in ASM.
  final String locking;

  /// Lock time of the spending transaction, if the example needs one.
  final int? lockTime;

  /// Input sequence of the spending transaction, if the example needs one.
  final int? inputSequence;

  /// Transaction version, if the example needs one.
  final int? txVersion;

  /// Simulated valid signatures, as `'<sig hex>:<pubkey hex>'`.
  final Set<String> validSignatures;

  /// A machine that runs [unlocking] followed by [locking].
  ScriptMachine createMachine() {
    return ScriptMachine(
      parseScriptAsm('$unlocking $locking'),
      lockTime: lockTime,
      inputSequence: inputSequence,
      txVersion: txVersion,
      validSignatures: validSignatures,
    );
  }
}

String _repeat(String text, int count) => List.filled(count, text).join();

final _alicePub = '02${_repeat('11', 32)}';
final _bobPub = '02${_repeat('22', 32)}';
final _carolPub = '03${_repeat('33', 32)}';
final _aliceSig = '30${_repeat('a1', 70)}';
final _bobSig = '30${_repeat('b2', 70)}';

/// The hashlock preimage is the text `satoshi`; its SHA-256 is the lock.
final _secretHash = hexEncode(sha256Bytes(utf8.encode('satoshi')));
final _alicePkh = hexEncode(hash160(hexDecode(_alicePub)));

const _timeoutHeight = 600000;
final _htlcLocking =
    'OP_IF OP_SHA256 <$_secretHash> OP_EQUALVERIFY <$_bobPub> '
    'OP_ELSE #$_timeoutHeight OP_CHECKLOCKTIMEVERIFY OP_DROP <$_alicePub> '
    'OP_ENDIF OP_CHECKSIG';

/// Every example, in the order the demo shows them.
final scriptExamples = <ScriptExample>[
  ScriptExample(
    id: 'arithmetic',
    wikiEntryId: 'wiki.bitcoin-script',
    unlocking: '',
    locking: '2 3 OP_ADD 5 OP_EQUAL',
  ),
  ScriptExample(
    id: 'p2pkh',
    wikiEntryId: 'wiki.bitcoin-script',
    unlocking: '<$_aliceSig> <$_alicePub>',
    locking: 'OP_DUP OP_HASH160 <$_alicePkh> OP_EQUALVERIFY OP_CHECKSIG',
    validSignatures: {'$_aliceSig:$_alicePub'},
  ),
  ScriptExample(
    id: 'multisig-2-of-3',
    wikiEntryId: 'wiki.multisig',
    unlocking: 'OP_0 <$_aliceSig> <$_bobSig>',
    locking: '2 <$_alicePub> <$_bobPub> <$_carolPub> 3 OP_CHECKMULTISIG',
    validSignatures: {'$_aliceSig:$_alicePub', '$_bobSig:$_bobPub'},
  ),
  ScriptExample(
    id: 'hashlock',
    wikiEntryId: 'wiki.hashlocks',
    unlocking: "'satoshi'",
    locking: 'OP_SHA256 <$_secretHash> OP_EQUAL',
  ),
  ScriptExample(
    id: 'cltv',
    wikiEntryId: 'wiki.timelocks',
    unlocking: '<$_aliceSig>',
    locking:
        '#$_timeoutHeight OP_CHECKLOCKTIMEVERIFY OP_DROP <$_alicePub> OP_CHECKSIG',
    lockTime: _timeoutHeight + 50000,
    inputSequence: 0xfffffffe,
    txVersion: 2,
    validSignatures: {'$_aliceSig:$_alicePub'},
  ),
  ScriptExample(
    id: 'csv',
    wikiEntryId: 'wiki.timelocks',
    unlocking: '<$_aliceSig>',
    locking: '10 OP_CHECKSEQUENCEVERIFY OP_DROP <$_alicePub> OP_CHECKSIG',
    inputSequence: 12,
    txVersion: 2,
    validSignatures: {'$_aliceSig:$_alicePub'},
  ),
  ScriptExample(
    id: 'htlc',
    wikiEntryId: 'wiki.htlcs',
    unlocking: "<$_bobSig> 'satoshi' OP_1",
    locking: _htlcLocking,
    lockTime: _timeoutHeight + 50000,
    inputSequence: 0xfffffffe,
    txVersion: 2,
    validSignatures: {'$_bobSig:$_bobPub'},
  ),
  ScriptExample(
    id: 'htlc-refund',
    wikiEntryId: 'wiki.htlcs',
    unlocking: '<$_aliceSig> OP_0',
    locking: _htlcLocking,
    lockTime: _timeoutHeight + 50000,
    inputSequence: 0xfffffffe,
    txVersion: 2,
    validSignatures: {'$_aliceSig:$_alicePub'},
  ),
];
