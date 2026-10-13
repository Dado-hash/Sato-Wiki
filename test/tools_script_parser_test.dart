import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sato_wiki/src/features/tools/domain/script_opcodes.dart';
import 'package:sato_wiki/src/features/tools/domain/script_parser.dart';
import 'package:sato_wiki/src/features/tools/domain/tools_bytes.dart';

ScriptOp op(String name) => ScriptOp(scriptOpcodeByName(name)!);

ScriptParseReason parseFailure(String asm) {
  try {
    parseScriptAsm(asm);
  } on ScriptParseException catch (error) {
    return error.reason;
  }
  fail('Expected a parse failure for "$asm"');
}

void main() {
  group('opcode lookup', () {
    test('finds names with and without OP_, in any case', () {
      expect(scriptOpcodeByName('OP_DUP')!.byte, 0x76);
      expect(scriptOpcodeByName('dup')!.byte, 0x76);
      expect(scriptOpcodeByName('op_dup')!.byte, 0x76);
      expect(scriptOpcodeByName('  DUP ')!.byte, 0x76);
    });

    test('accepts the aliases of Bitcoin Core', () {
      expect(scriptOpcodeByName('OP_FALSE')!.byte, 0x00);
      expect(scriptOpcodeByName('OP_TRUE')!.byte, 0x51);
      expect(scriptOpcodeByName('OP_NOP2')!.name, 'OP_CHECKLOCKTIMEVERIFY');
      expect(scriptOpcodeByName('NOP3')!.name, 'OP_CHECKSEQUENCEVERIFY');
    });

    test('returns null for an unknown name', () {
      expect(scriptOpcodeByName('OP_NOPE'), isNull);
      expect(scriptOpcodeByName(''), isNull);
    });

    test('finds opcodes by byte', () {
      expect(scriptOpcodeByByte(0xa9)!.name, 'OP_HASH160');
      expect(scriptOpcodeByByte(0x00)!.name, 'OP_0');
      expect(scriptOpcodeByByte(0xb1)!.name, 'OP_CHECKLOCKTIMEVERIFY');
    });

    test('returns null for direct push bytes and out-of-range values', () {
      expect(scriptOpcodeByByte(0x01), isNull);
      expect(scriptOpcodeByByte(0x4b), isNull);
      expect(scriptOpcodeByByte(256), isNull);
    });

    test('marks disabled, simulated and unsupported opcodes', () {
      expect(
        scriptOpcodeByName('OP_CAT')!.support,
        ScriptOpcodeSupport.disabled,
      );
      expect(
        scriptOpcodeByName('OP_MUL')!.support,
        ScriptOpcodeSupport.disabled,
      );
      expect(
        scriptOpcodeByName('OP_CHECKSIG')!.support,
        ScriptOpcodeSupport.simulated,
      );
      expect(
        scriptOpcodeByName('OP_CHECKSIGADD')!.support,
        ScriptOpcodeSupport.unsupported,
      );
      expect(
        scriptOpcodeByName('OP_SHA1')!.support,
        ScriptOpcodeSupport.supported,
      );
    });

    test('disabled set is exactly the fifteen Core rejects', () {
      final disabled = scriptOpcodeTable
          .where((op) => op.support == ScriptOpcodeSupport.disabled)
          .map((op) => op.name)
          .toSet();
      expect(disabled, {
        'OP_CAT',
        'OP_SUBSTR',
        'OP_LEFT',
        'OP_RIGHT',
        'OP_INVERT',
        'OP_AND',
        'OP_OR',
        'OP_XOR',
        'OP_2MUL',
        'OP_2DIV',
        'OP_MUL',
        'OP_DIV',
        'OP_MOD',
        'OP_LSHIFT',
        'OP_RSHIFT',
      });
    });
  });

  group('parseScriptAsm', () {
    test('reads opcode names', () {
      expect(parseScriptAsm('OP_DUP dup OP_HASH160'), [
        op('OP_DUP'),
        op('DUP'),
        op('OP_HASH160'),
      ]);
    });

    test('reads small bare numbers as constant opcodes', () {
      expect(parseScriptAsm('-1 0 1 16'), [
        op('OP_1NEGATE'),
        op('OP_0'),
        op('OP_1'),
        op('OP_16'),
      ]);
    });

    test('reads hex in angle brackets and bare hex', () {
      expect(parseScriptAsm('<a1b2> a1b2'), [
        ScriptPush(Uint8List.fromList([0xa1, 0xb2])),
        ScriptPush(Uint8List.fromList([0xa1, 0xb2])),
      ]);
    });

    test('reads an empty angle-bracket push', () {
      expect(parseScriptAsm('<>'), [ScriptPush(Uint8List(0))]);
    });

    test('reads a bare two-digit hex value as a push, not a number', () {
      expect(parseScriptAsm('17'), [
        ScriptPush(Uint8List.fromList([0x17])),
      ]);
    });

    test('reads a large decimal with a leading hash as a script number', () {
      expect(parseScriptAsm('#500 #-500'), [
        ScriptPush(Uint8List.fromList([0xf4, 0x01])),
        ScriptPush(Uint8List.fromList([0xf4, 0x81])),
      ]);
    });

    test('reads quoted text as UTF-8', () {
      expect(parseScriptAsm("'hello' ''"), [
        ScriptPush(Uint8List.fromList('hello'.codeUnits)),
        ScriptPush(Uint8List(0)),
      ]);
    });

    test('reads an empty script as no elements', () {
      expect(parseScriptAsm('   '), isEmpty);
    });

    test('rejects an unknown token with its index', () {
      expect(
        () => parseScriptAsm('OP_DUP FOO'),
        throwsA(
          isA<ScriptParseException>()
              .having((e) => e.reason, 'reason', ScriptParseReason.unknownToken)
              .having((e) => e.index, 'index', 1),
        ),
      );
    });

    test('rejects Core raw-byte notation, which is for parseScriptHex', () {
      expect(parseFailure('0x51'), ScriptParseReason.unknownToken);
    });

    test('rejects odd-length hex', () {
      expect(parseFailure('abc'), ScriptParseReason.invalidHex);
      expect(parseFailure('<abc>'), ScriptParseReason.invalidHex);
    });

    test('rejects a negative number outside -1 to 16', () {
      expect(parseFailure('-2'), ScriptParseReason.invalidNumber);
    });

    test('rejects a hash number that does not fit in an integer', () {
      expect(
        parseFailure('#99999999999999999999999999'),
        ScriptParseReason.invalidNumber,
      );
    });

    test('rejects unterminated text', () {
      expect(parseFailure("'abc"), ScriptParseReason.unterminatedText);
      expect(parseFailure("'"), ScriptParseReason.unterminatedText);
    });

    test('rejects PUSHDATA opcode names, which ASM writes as data', () {
      expect(parseFailure('OP_PUSHDATA1'), ScriptParseReason.unknownToken);
    });
  });

  group('parseScriptHex', () {
    test('reads a real P2PKH locking script', () {
      final elements = parseScriptHex(
        '76a91462e907b15cbf27d5425399ebf6f0fb50ebb88f1888ac',
      );

      expect(elements.length, 5);
      expect(elements[0], op('OP_DUP'));
      expect(elements[1], op('OP_HASH160'));
      expect(elements[2], isA<ScriptPush>());
      expect((elements[2] as ScriptPush).data.length, 20);
      expect(elements[3], op('OP_EQUALVERIFY'));
      expect(elements[4], op('OP_CHECKSIG'));
    });

    test('reads a direct push and an opcode', () {
      expect(parseScriptHex('02abcd76'), [
        ScriptPush(Uint8List.fromList([0xab, 0xcd])),
        op('OP_DUP'),
      ]);
    });

    test('reads OP_0 for byte 0x00', () {
      expect(parseScriptHex('00'), [op('OP_0')]);
    });

    test('reads an empty script as no elements', () {
      expect(parseScriptHex(''), isEmpty);
    });

    test('reads PUSHDATA1 at the 76-byte boundary', () {
      final data = Uint8List(76)..fillRange(0, 76, 0x11);
      final hex = '4c4c${hexEncode(data)}';

      final elements = parseScriptHex(hex);

      expect(elements, [ScriptPush(data)]);
    });

    test('reads a 75-byte direct push', () {
      final data = Uint8List(75)..fillRange(0, 75, 0x22);

      expect(parseScriptHex('4b${hexEncode(data)}'), [ScriptPush(data)]);
    });

    test('reads PUSHDATA2 and PUSHDATA4 lengths', () {
      final data = Uint8List(256)..fillRange(0, 256, 0x33);
      expect(parseScriptHex('4d0001${hexEncode(data)}'), [ScriptPush(data)]);

      expect(parseScriptHex('4e00010000${hexEncode(data)}'), [
        ScriptPush(data),
      ]);
    });

    test('rejects a push whose data runs past the end', () {
      expect(
        () => parseScriptHex('02aa'),
        throwsA(
          isA<ScriptParseException>().having(
            (e) => e.reason,
            'reason',
            ScriptParseReason.truncatedPush,
          ),
        ),
      );
    });

    test('rejects a PUSHDATA whose length field is cut short', () {
      for (final hex in ['4c', '4d01', '4e0100']) {
        expect(
          () => parseScriptHex(hex),
          throwsA(
            isA<ScriptParseException>().having(
              (e) => e.reason,
              'reason',
              ScriptParseReason.truncatedPush,
            ),
          ),
          reason: hex,
        );
      }
    });

    test('rejects text that is not hex', () {
      expect(
        () => parseScriptHex('zz'),
        throwsA(
          isA<ScriptParseException>().having(
            (e) => e.reason,
            'reason',
            ScriptParseReason.invalidHex,
          ),
        ),
      );
    });
  });

  group('serializeScript and scriptToAsm', () {
    test('P2PKH hex round trips through elements', () {
      const hex = '76a91462e907b15cbf27d5425399ebf6f0fb50ebb88f1888ac';

      expect(hexEncode(serializeScript(parseScriptHex(hex))), hex);
    });

    test('uses minimal pushes for small and special values', () {
      final elements = [
        ScriptPush(Uint8List(0)),
        ScriptPush(Uint8List.fromList([0x01])),
        ScriptPush(Uint8List.fromList([0x10])),
        ScriptPush(Uint8List.fromList([0x81])),
        ScriptPush(Uint8List.fromList([0x11])),
      ];

      expect(hexEncode(serializeScript(elements)), '0051604f0111');
    });

    test('uses PUSHDATA1 from 76 bytes and PUSHDATA2 from 256 bytes', () {
      final seventySix = ScriptPush(Uint8List(76));
      final twoHundredFiftySix = ScriptPush(Uint8List(256));

      expect(serializeScript([seventySix]).sublist(0, 2), [0x4c, 76]);
      expect(serializeScript([twoHundredFiftySix]).sublist(0, 3), [
        0x4d,
        0x00,
        0x01,
      ]);
    });

    test('ASM round trips through elements and hex', () {
      const asm =
          'OP_DUP OP_HASH160 <62e907b15cbf27d5425399ebf6f0fb50ebb88f18> '
          'OP_EQUALVERIFY OP_CHECKSIG';
      final elements = parseScriptAsm(asm);

      expect(scriptToAsm(elements), asm);
      final bytes = serializeScript(elements);
      expect(scriptToAsm(parseScriptHex(hexEncode(bytes))), asm);
    });

    test('each token form survives ASM to hex and back to ASM', () {
      const asm = '-1 0 16 OP_NOP <ab> <> <0102> OP_CHECKSIGVERIFY';
      final elements = parseScriptAsm(asm);

      final bytes = serializeScript(elements);
      final back = parseScriptHex(hexEncode(bytes));

      expect(serializeScript(back), bytes);
      expect(back.length, elements.length);
    });
  });
}
