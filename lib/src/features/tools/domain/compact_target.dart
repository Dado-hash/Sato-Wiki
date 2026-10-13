// Bitcoin compact ("nBits") targets and difficulty. Pure Dart, no Flutter imports.

const int _signBit = 0x00800000;
const int _mantissaMask = 0x007fffff;
const int _maxUint32 = 0xffffffff;
final BigInt _two256 = BigInt.one << 256;
final RegExp _bitsPattern = RegExp(r'^(?:0[xX])?[0-9a-fA-F]{8}$');

/// Target encoded by the compact [bits] value, as Bitcoin Core's `SetCompact`.
///
/// Throws a [FormatException] when [bits] is outside 0..0xffffffff or when the
/// sign bit is set together with a non-zero mantissa.
BigInt targetFromBits(int bits) {
  if (bits < 0 || bits > _maxUint32) {
    throw FormatException('Compact bits must fit in 32 bits', bits);
  }

  final exponent = bits >> 24;
  final mantissa = bits & _mantissaMask;
  if ((bits & _signBit) != 0 && mantissa != 0) {
    throw FormatException('Negative compact targets are not allowed', bits);
  }
  if (mantissa == 0) {
    return BigInt.zero;
  }

  final value = BigInt.from(mantissa);
  if (exponent <= 3) {
    return value >> (8 * (3 - exponent));
  }

  return value << (8 * (exponent - 3));
}

/// Compact ("nBits") encoding of [target], normalised as Bitcoin Core's `GetCompact`.
///
/// When the top bit of the mantissa would be set, the mantissa is shifted right
/// by 8 bits and the exponent is increased.
int bitsFromTarget(BigInt target) {
  if (target.isNegative) {
    throw ArgumentError.value(target, 'target', 'must not be negative');
  }
  if (target == BigInt.zero) {
    return 0;
  }

  var size = (target.bitLength + 7) ~/ 8;
  var compact = size <= 3
      ? target.toInt() << (8 * (3 - size))
      : (target >> (8 * (size - 3))).toInt();
  if ((compact & _signBit) != 0) {
    compact >>= 8;
    size += 1;
  }

  return compact | (size << 24);
}

/// Target of the difficulty 1 bits `0x1d00ffff`, the Bitcoin maximum target.
final BigInt maxTarget = targetFromBits(0x1d00ffff);

/// Difficulty of [target] relative to [maxTarget].
double difficultyFromTarget(BigInt target) {
  if (target <= BigInt.zero) {
    throw ArgumentError.value(target, 'target', 'must be positive');
  }

  return maxTarget.toDouble() / target.toDouble();
}

/// Difficulty of the compact [bits] value relative to [maxTarget].
double difficultyFromBits(int bits) {
  return difficultyFromTarget(targetFromBits(bits));
}

/// Expected number of hashes needed to find a hash at or below [target].
BigInt expectedHashes(BigInt target) {
  if (target.isNegative) {
    throw ArgumentError.value(target, 'target', 'must not be negative');
  }

  return _two256 ~/ (target + BigInt.one);
}

/// [target] as 64 lowercase hexadecimal characters, zero padded.
String targetToHex(BigInt target) {
  if (target.isNegative || target.bitLength > 256) {
    throw ArgumentError.value(target, 'target', 'must fit in 256 bits');
  }

  return target.toRadixString(16).padLeft(64, '0');
}

/// Compact bits from text such as `1d00ffff` or `0x1d00ffff`, in any case.
///
/// Throws a [FormatException] when the text is not exactly eight hex digits,
/// with an optional `0x` prefix.
int parseBits(String text) {
  final trimmed = text.trim();
  if (!_bitsPattern.hasMatch(trimmed)) {
    throw FormatException(
      'Expected 8 hex digits, optionally 0x-prefixed',
      text,
    );
  }

  final digits = trimmed.length == 10 ? trimmed.substring(2) : trimmed;

  return int.parse(digits, radix: 16);
}
