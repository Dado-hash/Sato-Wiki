import 'dart:typed_data';

import 'tools_bytes.dart';

/// Base58 and Base58Check encoding for the offline tools. Pure Dart.

const _alphabet = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';

final _base = BigInt.from(58);

/// A Base58Check payload split into its version byte and the data after it.
final class Base58CheckData {
  /// Creates a decoded Base58Check value.
  const Base58CheckData({required this.version, required this.payload});

  /// The leading version byte (for example 0x00 for mainnet P2PKH).
  final int version;

  /// The bytes after the version byte, without the checksum.
  final Uint8List payload;
}

/// Base58 text for [bytes].
///
/// Each leading zero byte becomes a leading `1`, as Bitcoin does.
String base58Encode(List<int> bytes) {
  var leadingZeros = 0;
  while (leadingZeros < bytes.length && bytes[leadingZeros] == 0) {
    leadingZeros++;
  }

  var value = BigInt.zero;
  for (final byte in bytes) {
    value = (value << 8) | BigInt.from(byte);
  }

  final digits = <String>[];
  while (value > BigInt.zero) {
    final remainder = (value % _base).toInt();
    digits.add(_alphabet[remainder]);
    value = value ~/ _base;
  }

  final buffer = StringBuffer('1' * leadingZeros);
  for (final digit in digits.reversed) {
    buffer.write(digit);
  }

  return buffer.toString();
}

/// Bytes for the Base58 [text].
///
/// Throws a [FormatException] when [text] contains a character outside the
/// Base58 alphabet. Leading `1` characters become leading zero bytes.
Uint8List base58Decode(String text) {
  var value = BigInt.zero;
  var leadingOnes = 0;
  var seenDigit = false;

  for (var i = 0; i < text.length; i++) {
    final index = _alphabet.indexOf(text[i]);
    if (index < 0) {
      throw FormatException('Invalid Base58 character', text, i);
    }

    if (index == 0 && !seenDigit) {
      leadingOnes++;
    } else {
      seenDigit = true;
    }

    value = value * _base + BigInt.from(index);
  }

  final significant = <int>[];
  while (value > BigInt.zero) {
    significant.add((value & BigInt.from(0xff)).toInt());
    value = value >> 8;
  }

  final bytes = Uint8List(leadingOnes + significant.length);
  for (var i = 0; i < significant.length; i++) {
    bytes[bytes.length - 1 - i] = significant[i];
  }

  return bytes;
}

/// Base58Check text for [version] followed by [payload].
///
/// The checksum is the first four bytes of the double SHA-256 of the data.
String base58CheckEncode(int version, List<int> payload) {
  if (version < 0 || version > 255) {
    throw RangeError.range(version, 0, 255, 'version');
  }

  final data = <int>[version, ...payload];
  final checksum = doubleSha256(data).sublist(0, 4);

  return base58Encode([...data, ...checksum]);
}

/// Version byte and payload for the Base58Check [text].
///
/// Throws a [FormatException] when a character is outside the Base58
/// alphabet, when the data is shorter than version plus checksum, or when the
/// checksum does not match.
Base58CheckData base58CheckDecode(String text) {
  final bytes = base58Decode(text);
  if (bytes.length < 5) {
    throw FormatException('Base58Check data too short', text);
  }

  final body = bytes.sublist(0, bytes.length - 4);
  final checksum = bytes.sublist(bytes.length - 4);
  final expected = doubleSha256(body).sublist(0, 4);

  for (var i = 0; i < 4; i++) {
    if (checksum[i] != expected[i]) {
      throw FormatException('Bad Base58Check checksum', text);
    }
  }

  return Base58CheckData(
    version: body[0],
    payload: Uint8List.fromList(body.sublist(1)),
  );
}
