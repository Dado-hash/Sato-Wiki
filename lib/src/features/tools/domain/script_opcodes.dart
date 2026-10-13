// Bitcoin Script opcode table for the teaching tools.
//
// Names and byte values are taken from `enum opcodetype` in Bitcoin Core
// (`src/script/script.h`). The support level says how the teaching
// interpreter treats each opcode. It is not a statement about consensus.
// Pure Dart, no Flutter imports.

/// How the teaching interpreter treats an opcode.
enum ScriptOpcodeSupport {
  /// Executed with Bitcoin's semantics.
  supported,

  /// Executed, but signature checks use a lookup table instead of real
  /// signatures. The step carries a note saying so.
  simulated,

  /// Rejected by Bitcoin Core even inside a branch that is not executed.
  disabled,

  /// Not implemented here. Fails only when the opcode is executed.
  unsupported,
}

/// One Bitcoin Script opcode, with its byte value and support level.
///
/// Two opcodes are equal when their bytes are equal.
final class ScriptOpcode {
  /// Creates an opcode entry.
  const ScriptOpcode(this.name, this.byte, this.support);

  /// Canonical name, such as `OP_DUP`.
  final String name;

  /// Byte value in a serialized script.
  final int byte;

  /// How the teaching interpreter treats this opcode.
  final ScriptOpcodeSupport support;

  @override
  bool operator ==(Object other) => other is ScriptOpcode && other.byte == byte;

  @override
  int get hashCode => byte;

  @override
  String toString() => name;
}

/// Every opcode named in Bitcoin Core, sorted by byte value.
///
/// Byte values 0x01 to 0x4b are direct data pushes and are not listed here.
/// Unassigned bytes (0xbb to 0xfe) are not listed either.
const scriptOpcodeTable = <ScriptOpcode>[
  ScriptOpcode('OP_0', 0x00, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_PUSHDATA1', 0x4c, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_PUSHDATA2', 0x4d, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_PUSHDATA4', 0x4e, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_1NEGATE', 0x4f, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_RESERVED', 0x50, ScriptOpcodeSupport.unsupported),
  ScriptOpcode('OP_1', 0x51, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_2', 0x52, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_3', 0x53, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_4', 0x54, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_5', 0x55, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_6', 0x56, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_7', 0x57, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_8', 0x58, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_9', 0x59, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_10', 0x5a, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_11', 0x5b, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_12', 0x5c, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_13', 0x5d, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_14', 0x5e, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_15', 0x5f, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_16', 0x60, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_NOP', 0x61, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_VER', 0x62, ScriptOpcodeSupport.unsupported),
  ScriptOpcode('OP_IF', 0x63, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_NOTIF', 0x64, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_VERIF', 0x65, ScriptOpcodeSupport.unsupported),
  ScriptOpcode('OP_VERNOTIF', 0x66, ScriptOpcodeSupport.unsupported),
  ScriptOpcode('OP_ELSE', 0x67, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_ENDIF', 0x68, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_VERIFY', 0x69, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_RETURN', 0x6a, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_TOALTSTACK', 0x6b, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_FROMALTSTACK', 0x6c, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_2DROP', 0x6d, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_2DUP', 0x6e, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_3DUP', 0x6f, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_2OVER', 0x70, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_2ROT', 0x71, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_2SWAP', 0x72, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_IFDUP', 0x73, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_DEPTH', 0x74, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_DROP', 0x75, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_DUP', 0x76, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_NIP', 0x77, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_OVER', 0x78, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_PICK', 0x79, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_ROLL', 0x7a, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_ROT', 0x7b, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_SWAP', 0x7c, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_TUCK', 0x7d, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_CAT', 0x7e, ScriptOpcodeSupport.disabled),
  ScriptOpcode('OP_SUBSTR', 0x7f, ScriptOpcodeSupport.disabled),
  ScriptOpcode('OP_LEFT', 0x80, ScriptOpcodeSupport.disabled),
  ScriptOpcode('OP_RIGHT', 0x81, ScriptOpcodeSupport.disabled),
  ScriptOpcode('OP_SIZE', 0x82, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_INVERT', 0x83, ScriptOpcodeSupport.disabled),
  ScriptOpcode('OP_AND', 0x84, ScriptOpcodeSupport.disabled),
  ScriptOpcode('OP_OR', 0x85, ScriptOpcodeSupport.disabled),
  ScriptOpcode('OP_XOR', 0x86, ScriptOpcodeSupport.disabled),
  ScriptOpcode('OP_EQUAL', 0x87, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_EQUALVERIFY', 0x88, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_RESERVED1', 0x89, ScriptOpcodeSupport.unsupported),
  ScriptOpcode('OP_RESERVED2', 0x8a, ScriptOpcodeSupport.unsupported),
  ScriptOpcode('OP_1ADD', 0x8b, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_1SUB', 0x8c, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_2MUL', 0x8d, ScriptOpcodeSupport.disabled),
  ScriptOpcode('OP_2DIV', 0x8e, ScriptOpcodeSupport.disabled),
  ScriptOpcode('OP_NEGATE', 0x8f, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_ABS', 0x90, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_NOT', 0x91, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_0NOTEQUAL', 0x92, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_ADD', 0x93, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_SUB', 0x94, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_MUL', 0x95, ScriptOpcodeSupport.disabled),
  ScriptOpcode('OP_DIV', 0x96, ScriptOpcodeSupport.disabled),
  ScriptOpcode('OP_MOD', 0x97, ScriptOpcodeSupport.disabled),
  ScriptOpcode('OP_LSHIFT', 0x98, ScriptOpcodeSupport.disabled),
  ScriptOpcode('OP_RSHIFT', 0x99, ScriptOpcodeSupport.disabled),
  ScriptOpcode('OP_BOOLAND', 0x9a, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_BOOLOR', 0x9b, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_NUMEQUAL', 0x9c, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_NUMEQUALVERIFY', 0x9d, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_NUMNOTEQUAL', 0x9e, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_LESSTHAN', 0x9f, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_GREATERTHAN', 0xa0, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_LESSTHANOREQUAL', 0xa1, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_GREATERTHANOREQUAL', 0xa2, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_MIN', 0xa3, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_MAX', 0xa4, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_WITHIN', 0xa5, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_RIPEMD160', 0xa6, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_SHA1', 0xa7, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_SHA256', 0xa8, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_HASH160', 0xa9, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_HASH256', 0xaa, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_CODESEPARATOR', 0xab, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_CHECKSIG', 0xac, ScriptOpcodeSupport.simulated),
  ScriptOpcode('OP_CHECKSIGVERIFY', 0xad, ScriptOpcodeSupport.simulated),
  ScriptOpcode('OP_CHECKMULTISIG', 0xae, ScriptOpcodeSupport.simulated),
  ScriptOpcode('OP_CHECKMULTISIGVERIFY', 0xaf, ScriptOpcodeSupport.simulated),
  ScriptOpcode('OP_NOP1', 0xb0, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_CHECKLOCKTIMEVERIFY', 0xb1, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_CHECKSEQUENCEVERIFY', 0xb2, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_NOP4', 0xb3, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_NOP5', 0xb4, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_NOP6', 0xb5, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_NOP7', 0xb6, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_NOP8', 0xb7, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_NOP9', 0xb8, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_NOP10', 0xb9, ScriptOpcodeSupport.supported),
  ScriptOpcode('OP_CHECKSIGADD', 0xba, ScriptOpcodeSupport.unsupported),
  ScriptOpcode('OP_INVALIDOPCODE', 0xff, ScriptOpcodeSupport.unsupported),
];

/// Names that Bitcoin Core accepts as aliases of a canonical opcode name.
const _scriptOpcodeAliases = <String, String>{
  'OP_FALSE': 'OP_0',
  'OP_TRUE': 'OP_1',
  'OP_NOP2': 'OP_CHECKLOCKTIMEVERIFY',
  'OP_NOP3': 'OP_CHECKSEQUENCEVERIFY',
};

final _scriptOpcodesByName = {for (final op in scriptOpcodeTable) op.name: op};

final _scriptOpcodesByByte = {for (final op in scriptOpcodeTable) op.byte: op};

/// Opcode called [name], in any letter case, with or without `OP_`.
///
/// The aliases OP_FALSE, OP_TRUE, OP_NOP2 and OP_NOP3 are accepted. Returns
/// null for an unknown name.
ScriptOpcode? scriptOpcodeByName(String name) {
  var key = name.trim().toUpperCase();
  if (!key.startsWith('OP_')) {
    key = 'OP_$key';
  }
  key = _scriptOpcodeAliases[key] ?? key;

  return _scriptOpcodesByName[key];
}

/// Opcode with the byte value [byte].
///
/// Returns null for the direct push bytes 0x01 to 0x4b, which the parser
/// reads as data, and for values outside 0 to 255. Unassigned bytes
/// (0xbb to 0xfe) return an unsupported `OP_UNKNOWN` entry.
ScriptOpcode? scriptOpcodeByByte(int byte) {
  if (byte < 0 || byte > 0xff) {
    return null;
  }
  if (byte >= 0x01 && byte <= 0x4b) {
    return null;
  }

  return _scriptOpcodesByByte[byte] ??
      ScriptOpcode('OP_UNKNOWN', byte, ScriptOpcodeSupport.unsupported);
}
