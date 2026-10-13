import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sato_wiki/src/features/tools/domain/hash160.dart';
import 'package:sato_wiki/src/features/tools/domain/script_examples.dart';
import 'package:sato_wiki/src/features/tools/domain/script_machine.dart';
import 'package:sato_wiki/src/features/tools/domain/tools_bytes.dart';

const _wikiIds = {
  'wiki.bitcoin-script',
  'wiki.multisig',
  'wiki.timelocks',
  'wiki.hashlocks',
  'wiki.p2sh',
  'wiki.htlcs',
};

ScriptExample _example(String id) {
  return scriptExamples.singleWhere((example) => example.id == id);
}

void main() {
  test('every example has a unique lowercase hyphenated id', () {
    final ids = scriptExamples.map((example) => example.id).toList();

    expect(ids.toSet().length, ids.length);
    for (final id in ids) {
      expect(id, matches(RegExp(r'^[a-z0-9]+(-[a-z0-9]+)*$')), reason: id);
    }
  });

  test('every example points at a known wiki entry', () {
    for (final example in scriptExamples) {
      expect(_wikiIds, contains(example.wikiEntryId), reason: example.id);
    }
  });

  test('the required examples are present', () {
    final ids = scriptExamples.map((example) => example.id).toSet();

    expect(
      ids,
      containsAll([
        'arithmetic',
        'p2pkh',
        'multisig-2-of-3',
        'hashlock',
        'cltv',
        'csv',
        'htlc',
      ]),
    );
  });

  test('every example runs to success', () {
    for (final example in scriptExamples) {
      final machine = example.createMachine();
      machine.runAll();

      expect(machine.error, isNull, reason: example.id);
      expect(machine.succeeded, isTrue, reason: example.id);
    }
  });

  test('arithmetic example is 2 + 3 = 5', () {
    final machine = _example('arithmetic').createMachine();
    final results = machine.runAll();

    expect(machine.succeeded, isTrue);
    expect(results.last.stack.single, [1]);
  });

  test('p2pkh example locks to the HASH160 of its key', () {
    final example = _example('p2pkh');
    final keyToken = example.unlocking.split(' ').last;
    final pubKey = hexDecode(keyToken.substring(1, keyToken.length - 1));

    expect(example.locking, contains('<${hexEncode(hash160(pubKey))}>'));
    final machine = example.createMachine();
    machine.runAll();
    expect(machine.succeeded, isTrue);
  });

  test('hashlock example stores the SHA-256 of the text satoshi', () {
    final digest = hexEncode(sha256Bytes(utf8.encode('satoshi')));

    expect(_example('hashlock').locking, 'OP_SHA256 <$digest> OP_EQUAL');
  });

  test('CLTV example is satisfied by its lock time', () {
    final example = _example('cltv');
    final machine = example.createMachine();
    final results = machine.runAll();

    expect(machine.succeeded, isTrue);
    expect(
      results.any((result) => result.note == ScriptStepNote.timelockSatisfied),
      isTrue,
    );
  });

  test('CSV example is satisfied by its relative lock', () {
    final machine = _example('csv').createMachine();
    final results = machine.runAll();

    expect(machine.succeeded, isTrue);
    expect(
      results.any((result) => result.note == ScriptStepNote.timelockSatisfied),
      isTrue,
    );
  });

  test('HTLC runs to success through the hashlock branch', () {
    final machine = _example('htlc').createMachine();
    final results = machine.runAll();

    expect(machine.succeeded, isTrue);
    expect(results.any((result) => !result.executed), isTrue);
    expect(
      results.any(
        (result) =>
            result.note == ScriptStepNote.signatureSimulated &&
            result.error == null,
      ),
      isTrue,
    );
  });

  test('HTLC runs to success through the timelock branch', () {
    final machine = _example('htlc-refund').createMachine();
    machine.runAll();

    expect(machine.error, isNull);
    expect(machine.succeeded, isTrue);
  });

  test('HTLC with a wrong preimage fails', () {
    final claim = _example('htlc');
    final wrong = ScriptExample(
      id: 'htlc-wrong',
      wikiEntryId: claim.wikiEntryId,
      unlocking: claim.unlocking.replaceFirst("'satoshi'", "'wrong'"),
      locking: claim.locking,
      lockTime: claim.lockTime,
      inputSequence: claim.inputSequence,
      txVersion: claim.txVersion,
      validSignatures: claim.validSignatures,
    );
    final machine = wrong.createMachine();
    machine.runAll();

    expect(machine.error, ScriptError.equalVerifyFailed);
    expect(machine.succeeded, isFalse);
  });

  test('HTLC refund fails before the lock time', () {
    final refund = _example('htlc-refund');
    final early = ScriptExample(
      id: 'htlc-early',
      wikiEntryId: refund.wikiEntryId,
      unlocking: refund.unlocking,
      locking: refund.locking,
      lockTime: 600000 - 1,
      inputSequence: refund.inputSequence,
      txVersion: refund.txVersion,
      validSignatures: refund.validSignatures,
    );
    final machine = early.createMachine();
    machine.runAll();

    expect(machine.error, ScriptError.lockTimeNotReached);
  });

  test('a multisig example fails when one listed signature is missing', () {
    final example = _example('multisig-2-of-3');
    final bobMissing = ScriptExample(
      id: 'multisig-missing-bob',
      wikiEntryId: example.wikiEntryId,
      unlocking: example.unlocking,
      locking: example.locking,
      // Keep Alice's signature and drop Bob's, whose key is all 0x22 bytes.
      validSignatures: {
        for (final sig in example.validSignatures)
          if (!sig.contains('22' * 32)) sig,
      },
    );
    final machine = bobMissing.createMachine();
    machine.runAll();

    expect(machine.error, isNull);
    expect(machine.succeeded, isFalse);
  });

  test(
    'every example is marked with a simulated-signature note when it signs',
    () {
      for (final id in ['p2pkh', 'multisig-2-of-3', 'htlc']) {
        final machine = _example(id).createMachine();
        final results = machine.runAll();

        expect(
          results.any(
            (result) => result.note == ScriptStepNote.signatureSimulated,
          ),
          isTrue,
          reason: id,
        );
      }
    },
  );
}
