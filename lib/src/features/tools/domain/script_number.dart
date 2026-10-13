import 'dart:typed_data';

/// Script number encoding used by Bitcoin Script.
///
/// Numbers are little-endian, with the sign in the top bit of the last byte.
/// Zero is the empty array. Pure Dart, no Flutter imports.
///
/// This is part of a teaching interpreter, not consensus code.

/// Script number bytes for [value].
///
/// Throws an [ArgumentError] for the smallest 64-bit integer, whose magnitude
/// cannot be represented.
Uint8List encodeScriptNumber(int value) {
  if (value == -0x7fffffffffffffff - 1) {
    throw ArgumentError.value(value, 'value', 'Magnitude out of range');
  }
  if (value == 0) {
    return Uint8List(0);
  }

  final negative = value < 0;
  var magnitude = value.abs();
  final bytes = <int>[];
  while (magnitude > 0) {
    bytes.add(magnitude & 0xff);
    magnitude >>= 8;
  }

  if (bytes.last & 0x80 != 0) {
    // The top bit is the sign bit, so an extra byte carries the sign.
    bytes.add(negative ? 0x80 : 0x00);
  } else if (negative) {
    bytes[bytes.length - 1] |= 0x80;
  }

  return Uint8List.fromList(bytes);
}

/// The integer held by [bytes] as a script number.
///
/// Throws a [FormatException] when [bytes] is longer than [maxLength]. With
/// [requireMinimal] (the default), it also throws for a non-minimal encoding,
/// such as a trailing zero byte that is not needed for the sign, or negative
/// zero. [maxLength] must be between 1 and 7.
int decodeScriptNumber(
  List<int> bytes, {
  int maxLength = 4,
  bool requireMinimal = true,
}) {
  if (maxLength < 1 || maxLength > 7) {
    throw RangeError.range(maxLength, 1, 7, 'maxLength');
  }
  if (bytes.length > maxLength) {
    throw FormatException('Script number longer than $maxLength bytes', bytes);
  }
  if (bytes.isEmpty) {
    return 0;
  }

  final last = bytes.last;
  if (requireMinimal &&
      (last & 0x7f) == 0 &&
      (bytes.length == 1 || (bytes[bytes.length - 2] & 0x80) == 0)) {
    throw FormatException('Non-minimal script number', bytes);
  }

  var result = 0;
  for (var i = 0; i < bytes.length; i++) {
    result |= bytes[i] << (8 * i);
  }
  if (last & 0x80 != 0) {
    result &= ~(0x80 << (8 * (bytes.length - 1)));

    return -result;
  }

  return result;
}

/// Whether [bytes] counts as true on the stack.
///
/// Any non-zero byte makes the value true, except negative zero (0x80 in the
/// last byte alone), which is false. The empty array is false.
bool castToBool(List<int> bytes) {
  for (var i = 0; i < bytes.length; i++) {
    if (bytes[i] != 0) {
      if (i == bytes.length - 1 && bytes[i] == 0x80) {
        return false;
      }

      return true;
    }
  }

  return false;
}
