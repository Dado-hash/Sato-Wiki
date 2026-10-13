import 'dart:convert';
import 'dart:typed_data';

import 'script_number.dart';
import 'script_opcodes.dart';
import 'tools_bytes.dart';

/// Reading, writing and printing Bitcoin Script for the teaching tools.
///
/// Pure Dart, no Flutter imports. This is part of a teaching interpreter, not
/// consensus code.

/// One element of a script: either a data push or an opcode.
sealed class ScriptElement {
  const ScriptElement();
}

/// A data push. [data] is pushed to the stack when the element runs.
final class ScriptPush extends ScriptElement {
  /// Creates a data push of [data].
  const ScriptPush(this.data);

  /// Bytes pushed to the stack.
  final Uint8List data;

  @override
  bool operator ==(Object other) {
    if (other is! ScriptPush || other.data.length != data.length) {
      return false;
    }
    for (var i = 0; i < data.length; i++) {
      if (other.data[i] != data[i]) {
        return false;
      }
    }

    return true;
  }

  @override
  int get hashCode => Object.hashAll(data);

  @override
  String toString() => '<${hexEncode(data)}>';
}

/// A non-push opcode, including the constant opcodes OP_0 and OP_1 to OP_16.
final class ScriptOp extends ScriptElement {
  /// Creates an opcode element.
  const ScriptOp(this.opcode);

  /// The opcode.
  final ScriptOpcode opcode;

  @override
  bool operator ==(Object other) => other is ScriptOp && other.opcode == opcode;

  @override
  int get hashCode => opcode.hashCode;

  @override
  String toString() => opcode.name;
}

/// Why a script could not be read.
enum ScriptParseReason {
  /// An ASM token is not an opcode name, a number, hex data or quoted text.
  unknownToken,

  /// Hex text has an odd length or a character that is not a hex digit.
  invalidHex,

  /// A number is out of range or cannot be encoded.
  invalidNumber,

  /// Quoted text has no closing quote.
  unterminatedText,

  /// A push asks for more bytes than the script has.
  truncatedPush,
}

/// A script that could not be read.
///
/// [index] is the token index for ASM and the byte offset for hex.
final class ScriptParseException implements Exception {
  /// Creates an exception for [reason] at [index].
  const ScriptParseException(this.reason, this.index);

  /// Why parsing failed.
  final ScriptParseReason reason;

  /// Token index for ASM, byte offset for hex.
  final int index;

  @override
  String toString() => 'ScriptParseException(${reason.name}, index $index)';
}

final _integerPattern = RegExp(r'^-?\d+$');
final _bigIntegerPattern = RegExp(r'^#-?\d+$');
final _angleHexPattern = RegExp(r'^<([0-9a-fA-F]*)>$');
final _bareHexPattern = RegExp(r'^[0-9a-fA-F]+$');

/// Script elements for the ASM text [asm].
///
/// Tokens are separated by whitespace. Each token is one of:
/// - an opcode name, with or without `OP_`, in any case (`DUP`, `OP_ADD`);
/// - a bare integer from -1 to 16, which becomes OP_1NEGATE, OP_0 or OP_1 to
///   OP_16;
/// - a larger integer with a leading `#`, such as `#500`, pushed as a minimal
///   script number;
/// - hex data in angle brackets, such as `<a1b2>` (`<>` is an empty push);
/// - bare even-length hex of at least two digits, such as `a1b2`;
/// - text in single quotes, such as `'hello'`, pushed as UTF-8.
///
/// A bare integer outside -1 to 16 is read as hex, so `17` is the push of the
/// byte 0x17. Use `#17` for the number.
///
/// Throws a [ScriptParseException] with the index of the bad token.
List<ScriptElement> parseScriptAsm(String asm) {
  final tokens = asm.trim().isEmpty
      ? const <String>[]
      : asm.trim().split(RegExp(r'\s+'));
  final elements = <ScriptElement>[];
  for (var i = 0; i < tokens.length; i++) {
    elements.add(_parseAsmToken(tokens[i], i));
  }

  return elements;
}

ScriptElement _parseAsmToken(String token, int index) {
  final opcode = scriptOpcodeByName(token);
  if (opcode != null) {
    if (_isPushOpcodeByte(opcode.byte)) {
      // Pushes are written as data in ASM, not as PUSHDATA opcodes.
      throw ScriptParseException(ScriptParseReason.unknownToken, index);
    }

    return ScriptOp(opcode);
  }

  if (_integerPattern.hasMatch(token)) {
    final value = _parseInteger(token, index);
    if (value >= -1 && value <= 16) {
      return ScriptOp(_smallNumberOpcode(value));
    }
    if (token.startsWith('-')) {
      throw ScriptParseException(ScriptParseReason.invalidNumber, index);
    }
    // Larger bare integers are hex, as the documentation says.
  }

  if (_bigIntegerPattern.hasMatch(token)) {
    final value = _parseInteger(token.substring(1), index);

    return ScriptPush(encodeScriptNumber(value));
  }

  final angle = _angleHexPattern.firstMatch(token);
  if (angle != null) {
    final text = angle.group(1)!;
    if (text.length.isOdd) {
      throw ScriptParseException(ScriptParseReason.invalidHex, index);
    }

    return ScriptPush(text.isEmpty ? Uint8List(0) : hexDecode(text));
  }

  if (token.startsWith("'")) {
    if (token.length < 2 || !token.endsWith("'")) {
      throw ScriptParseException(ScriptParseReason.unterminatedText, index);
    }

    return ScriptPush(
      Uint8List.fromList(utf8.encode(token.substring(1, token.length - 1))),
    );
  }

  if (_bareHexPattern.hasMatch(token)) {
    if (token.length.isOdd || token.length < 2) {
      throw ScriptParseException(ScriptParseReason.invalidHex, index);
    }

    return ScriptPush(hexDecode(token));
  }

  throw ScriptParseException(ScriptParseReason.unknownToken, index);
}

int _parseInteger(String text, int index) {
  final value = int.tryParse(text);
  if (value == null) {
    throw ScriptParseException(ScriptParseReason.invalidNumber, index);
  }

  return value;
}

ScriptOpcode _smallNumberOpcode(int value) {
  if (value == -1) {
    return scriptOpcodeByName('OP_1NEGATE')!;
  }

  return scriptOpcodeByName('OP_$value')!;
}

bool _isPushOpcodeByte(int byte) => byte >= 0x4c && byte <= 0x4e;

/// Script elements for the serialized script [hex].
///
/// Reads direct pushes (0x01 to 0x4b), OP_PUSHDATA1, OP_PUSHDATA2 and
/// OP_PUSHDATA4, and every other byte as an opcode. Byte 0x00 is read as OP_0.
///
/// Throws a [ScriptParseException] for invalid hex and for a push whose data
/// or length field runs past the end of the script.
List<ScriptElement> parseScriptHex(String hex) {
  if (hex.trim().isEmpty) {
    return <ScriptElement>[];
  }
  final Uint8List bytes;
  try {
    bytes = hexDecode(hex);
  } on FormatException {
    throw const ScriptParseException(ScriptParseReason.invalidHex, 0);
  }

  final elements = <ScriptElement>[];
  var offset = 0;
  while (offset < bytes.length) {
    final byte = bytes[offset];
    final opcodeOffset = offset;
    offset++;

    int lengthSize;
    if (byte >= 0x01 && byte <= 0x4b) {
      lengthSize = 0;
    } else if (byte == 0x4c) {
      lengthSize = 1;
    } else if (byte == 0x4d) {
      lengthSize = 2;
    } else if (byte == 0x4e) {
      lengthSize = 4;
    } else {
      elements.add(ScriptOp(scriptOpcodeByByte(byte)!));
      continue;
    }

    var length = byte;
    if (lengthSize > 0) {
      if (offset + lengthSize > bytes.length) {
        throw ScriptParseException(
          ScriptParseReason.truncatedPush,
          opcodeOffset,
        );
      }
      length = 0;
      for (var i = 0; i < lengthSize; i++) {
        length |= bytes[offset + i] << (8 * i);
      }
      offset += lengthSize;
    }

    if (offset + length > bytes.length) {
      throw ScriptParseException(ScriptParseReason.truncatedPush, opcodeOffset);
    }
    elements.add(
      ScriptPush(Uint8List.fromList(bytes.sublist(offset, offset + length))),
    );
    offset += length;
  }

  return elements;
}

/// Serialized script bytes for [elements], using minimal push opcodes.
///
/// Empty data becomes OP_0. A single byte from 1 to 16 becomes OP_1 to OP_16,
/// and 0x81 becomes OP_1NEGATE. Longer data uses a direct push or
/// OP_PUSHDATA1, OP_PUSHDATA2 or OP_PUSHDATA4, whichever is the smallest.
Uint8List serializeScript(List<ScriptElement> elements) {
  final out = <int>[];
  for (final element in elements) {
    switch (element) {
      case ScriptOp(:final opcode):
        out.add(opcode.byte);
      case ScriptPush(:final data):
        _writePush(out, data);
    }
  }

  return Uint8List.fromList(out);
}

void _writePush(List<int> out, Uint8List data) {
  final length = data.length;
  if (length == 0) {
    out.add(0x00);

    return;
  }
  if (length == 1 && data[0] >= 1 && data[0] <= 16) {
    out.add(0x50 + data[0]);

    return;
  }
  if (length == 1 && data[0] == 0x81) {
    out.add(0x4f);

    return;
  }
  if (length <= 0x4b) {
    out.add(length);
  } else if (length <= 0xff) {
    out
      ..add(0x4c)
      ..add(length);
  } else if (length <= 0xffff) {
    out
      ..add(0x4d)
      ..add(length & 0xff)
      ..add(length >> 8);
  } else {
    out
      ..add(0x4e)
      ..add(length & 0xff)
      ..add((length >> 8) & 0xff)
      ..add((length >> 16) & 0xff)
      ..add((length >> 24) & 0xff);
  }
  out.addAll(data);
}

/// ASM text for [elements], in the notation [parseScriptAsm] reads.
///
/// Opcodes print with their canonical names. Data prints in angle brackets as
/// hex, so the output always parses back to the same bytes.
String scriptToAsm(List<ScriptElement> elements) {
  return elements
      .map((element) {
        return switch (element) {
          ScriptOp(:final opcode) => opcode.name,
          ScriptPush(:final data) => '<${hexEncode(data)}>',
        };
      })
      .join(' ');
}
