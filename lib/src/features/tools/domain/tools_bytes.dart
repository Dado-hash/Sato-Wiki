import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;

/// Byte helpers shared by the offline tools. Pure Dart, no Flutter imports.

const _hexDigits = '0123456789abcdef';

/// Lowercase hexadecimal text for [bytes].
String hexEncode(List<int> bytes) {
  final buffer = StringBuffer();
  for (final byte in bytes) {
    buffer
      ..write(_hexDigits[(byte >> 4) & 0x0f])
      ..write(_hexDigits[byte & 0x0f]);
  }

  return buffer.toString();
}

/// Whether [text] is a non-empty hexadecimal string with an even length.
///
/// Spaces around the text are ignored. Upper and lower case are accepted.
bool isHex(String text) {
  final trimmed = text.trim();

  return trimmed.isNotEmpty &&
      trimmed.length.isEven &&
      _hexPattern.hasMatch(trimmed);
}

/// Bytes for the hexadecimal [text].
///
/// Throws a [FormatException] when [text] is empty, has an odd length or
/// contains a character that is not a hexadecimal digit.
Uint8List hexDecode(String text) {
  final trimmed = text.trim();
  if (!isHex(trimmed)) {
    throw FormatException('Not a hexadecimal string', text);
  }

  final bytes = Uint8List(trimmed.length ~/ 2);
  for (var i = 0; i < bytes.length; i++) {
    bytes[i] = int.parse(trimmed.substring(i * 2, i * 2 + 2), radix: 16);
  }

  return bytes;
}

/// SHA-256 of [bytes].
Uint8List sha256Bytes(List<int> bytes) {
  return Uint8List.fromList(crypto.sha256.convert(bytes).bytes);
}

/// SHA-256 applied twice, as Bitcoin does for block hashes and txids.
Uint8List doubleSha256(List<int> bytes) {
  return sha256Bytes(sha256Bytes(bytes));
}

/// [bytes] in reverse order.
///
/// Bitcoin shows block hashes and txids with the bytes reversed.
Uint8List reversedBytes(List<int> bytes) {
  return Uint8List.fromList(bytes.reversed.toList());
}

final _hexPattern = RegExp(r'^[0-9a-fA-F]+$');
