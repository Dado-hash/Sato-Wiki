import 'dart:typed_data';

/// Bech32 (BIP173) and Bech32m (BIP350) encoding, plus SegWit address rules.
/// Pure Dart, no Flutter imports.

/// Checksum variant of a Bech32 string.
enum Bech32Variant { bech32, bech32m }

/// The rule a Bech32 or SegWit string broke.
enum Bech32Problem {
  /// The whole string is longer than 90 characters.
  tooLong,

  /// The data part is shorter than the 6-character checksum.
  tooShort,

  /// Upper and lower case letters are mixed.
  mixedCase,

  /// There is no `1` separator.
  missingSeparator,

  /// The human-readable part is empty.
  emptyHrp,

  /// The human-readable part has a character outside 33..126.
  invalidHrpCharacter,

  /// The data part has a character outside the bech32 alphabet.
  invalidCharacter,

  /// The checksum matches neither Bech32 nor Bech32m.
  badChecksum,

  /// The human-readable part is not one of `bc`, `tb` or `bcrt`.
  unknownHrp,

  /// A SegWit string has no witness version.
  emptyData,

  /// The witness version is above 16.
  unknownWitnessVersion,

  /// The witness program length is not allowed for its version.
  invalidProgramLength,

  /// Version 0 uses Bech32m, or versions 1 to 16 use Bech32.
  wrongVariant,

  /// The 5-bit to 8-bit conversion has non-zero or too long padding.
  invalidPadding,
}

/// A [FormatException] that also names the rule that failed.
final class Bech32FormatException extends FormatException {
  /// Creates an exception for [problem] with a short English [message].
  const Bech32FormatException(this.problem, String message, [String? source])
    : super(message, source);

  /// The rule that failed.
  final Bech32Problem problem;
}

/// A decoded Bech32 or Bech32m string, without its checksum.
final class Bech32Data {
  /// Creates decoded Bech32 data.
  const Bech32Data({
    required this.hrp,
    required this.data,
    required this.variant,
  });

  /// The lower case human-readable part.
  final String hrp;

  /// The 5-bit data words, without the checksum.
  final Uint8List data;

  /// The checksum variant that matched.
  final Bech32Variant variant;
}

/// A decoded SegWit address.
final class SegwitAddress {
  /// Creates a decoded SegWit address.
  const SegwitAddress({
    required this.hrp,
    required this.witnessVersion,
    required this.program,
    required this.variant,
  });

  /// The lower case human-readable part (`bc`, `tb` or `bcrt`).
  final String hrp;

  /// The witness version, 0 to 16.
  final int witnessVersion;

  /// The witness program, 2 to 40 bytes.
  final Uint8List program;

  /// The checksum variant: Bech32 for version 0, Bech32m otherwise.
  final Bech32Variant variant;
}

const _charset = 'qpzry9x8gf2tvdw0s3jn54khce6mua7l';
const _generator = <int>[
  0x3b6a57b2,
  0x26508e6d,
  0x1ea119fa,
  0x3d4233dd,
  0x2a1462b3,
];
const _bech32Constant = 1;
const _bech32mConstant = 0x2bc830a3;
const _maxLength = 90;
const _checksumLength = 6;
const _segwitHrps = {'bc', 'tb', 'bcrt'};

/// Decodes a Bech32 or Bech32m [input] string.
///
/// Checks the BIP173 rules: at most 90 characters, no mixed case, a
/// non-empty human-readable part, a `1` separator, a 6-character checksum
/// and only characters from the bech32 alphabet. The returned data has the
/// checksum removed.
///
/// Throws a [Bech32FormatException] when a rule fails.
Bech32Data bech32Decode(String input) {
  if (input.length > _maxLength) {
    throw const Bech32FormatException(
      Bech32Problem.tooLong,
      'Bech32 string is longer than 90 characters',
    );
  }

  final hasLower = input != input.toUpperCase();
  final hasUpper = input != input.toLowerCase();
  if (hasLower && hasUpper) {
    throw const Bech32FormatException(
      Bech32Problem.mixedCase,
      'Bech32 string mixes upper and lower case',
    );
  }

  final text = input.toLowerCase();
  final separator = text.lastIndexOf('1');
  if (separator < 0) {
    throw const Bech32FormatException(
      Bech32Problem.missingSeparator,
      'Bech32 separator is missing',
    );
  }
  if (separator == 0) {
    throw const Bech32FormatException(
      Bech32Problem.emptyHrp,
      'Bech32 human-readable part is empty',
    );
  }

  final hrp = text.substring(0, separator);
  for (final unit in hrp.codeUnits) {
    if (unit < 33 || unit > 126) {
      throw const Bech32FormatException(
        Bech32Problem.invalidHrpCharacter,
        'Bech32 human-readable part has an invalid character',
      );
    }
  }

  if (text.length - separator - 1 < _checksumLength) {
    throw const Bech32FormatException(
      Bech32Problem.tooShort,
      'Bech32 checksum is too short',
    );
  }

  final words = <int>[];
  for (var i = separator + 1; i < text.length; i++) {
    final value = _charset.indexOf(text[i]);
    if (value < 0) {
      throw const Bech32FormatException(
        Bech32Problem.invalidCharacter,
        'Bech32 data has an invalid character',
      );
    }
    words.add(value);
  }

  final checksum = _polymod([..._hrpExpand(hrp), ...words]);
  final Bech32Variant variant;
  if (checksum == _bech32Constant) {
    variant = Bech32Variant.bech32;
  } else if (checksum == _bech32mConstant) {
    variant = Bech32Variant.bech32m;
  } else {
    throw const Bech32FormatException(
      Bech32Problem.badChecksum,
      'Bech32 checksum does not match',
    );
  }

  return Bech32Data(
    hrp: hrp,
    data: Uint8List.fromList(words.sublist(0, words.length - _checksumLength)),
    variant: variant,
  );
}

/// Bech32 or Bech32m text for [hrp] and the 5-bit [words].
///
/// [words] must hold values from 0 to 31. The output is lower case.
/// Throws a [Bech32FormatException] for an invalid human-readable part, a
/// word out of range or a result longer than 90 characters.
String bech32Encode(String hrp, List<int> words, Bech32Variant variant) {
  final lowerHrp = _validHrp(hrp);
  for (final word in words) {
    if (word < 0 || word > 31) {
      throw const Bech32FormatException(
        Bech32Problem.invalidCharacter,
        'Bech32 word is out of the 5-bit range',
      );
    }
  }

  final total = lowerHrp.length + 1 + words.length + _checksumLength;
  if (total > _maxLength) {
    throw const Bech32FormatException(
      Bech32Problem.tooLong,
      'Bech32 string is longer than 90 characters',
    );
  }

  final constant = variant == Bech32Variant.bech32
      ? _bech32Constant
      : _bech32mConstant;
  final polymod = _polymod([
    ..._hrpExpand(lowerHrp),
    ...words,
    for (var i = 0; i < _checksumLength; i++) 0,
  ]);
  final modulus = polymod ^ constant;
  final checksum = [
    for (var i = 0; i < _checksumLength; i++)
      (modulus >>> (5 * (_checksumLength - 1 - i))) & 31,
  ];

  final buffer = StringBuffer('${lowerHrp}1');
  for (final word in [...words, ...checksum]) {
    buffer.write(_charset[word]);
  }

  return buffer.toString();
}

/// Regroups [data] from [fromBits]-bit to [toBits]-bit values.
///
/// With [pad] true, leftover bits are zero-padded into a final value. With
/// [pad] false, leftover bits must be fewer than [fromBits] and zero.
/// Throws a [Bech32FormatException] when the padding is not allowed.
Uint8List convertBits(
  List<int> data,
  int fromBits,
  int toBits, {
  required bool pad,
}) {
  var accumulator = 0;
  var bits = 0;
  final maxValue = (1 << toBits) - 1;
  final maxAccumulator = (1 << (fromBits + toBits - 1)) - 1;
  final result = <int>[];

  for (final value in data) {
    if (value < 0 || (value >>> fromBits) != 0) {
      throw const Bech32FormatException(
        Bech32Problem.invalidPadding,
        'Bit conversion input is out of range',
      );
    }

    accumulator = ((accumulator << fromBits) | value) & maxAccumulator;
    bits += fromBits;
    while (bits >= toBits) {
      bits -= toBits;
      result.add((accumulator >>> bits) & maxValue);
    }
  }

  if (pad) {
    if (bits > 0) {
      result.add((accumulator << (toBits - bits)) & maxValue);
    }
  } else if (bits >= fromBits ||
      ((accumulator << (toBits - bits)) & maxValue) != 0) {
    throw const Bech32FormatException(
      Bech32Problem.invalidPadding,
      'Bit conversion padding is invalid',
    );
  }

  return Uint8List.fromList(result);
}

/// Decodes a SegWit [address] (BIP173 and BIP350 rules).
///
/// Accepts the `bc`, `tb` and `bcrt` human-readable parts. Witness version
/// 0 needs a 20 or 32 byte program and Bech32. Versions 1 to 16 need Bech32m
/// and a program of 2 to 40 bytes. Throws a [Bech32FormatException] when a
/// rule fails.
SegwitAddress decodeSegwitAddress(String address) {
  final decoded = bech32Decode(address);
  if (!_segwitHrps.contains(decoded.hrp)) {
    throw const Bech32FormatException(
      Bech32Problem.unknownHrp,
      'SegWit human-readable part is not bc, tb or bcrt',
    );
  }

  if (decoded.data.isEmpty) {
    throw const Bech32FormatException(
      Bech32Problem.emptyData,
      'SegWit address has no witness version',
    );
  }

  final version = decoded.data[0];
  if (version > 16) {
    throw const Bech32FormatException(
      Bech32Problem.unknownWitnessVersion,
      'SegWit witness version is above 16',
    );
  }

  final program = convertBits(decoded.data.sublist(1), 5, 8, pad: false);
  _checkProgram(version, program.length);

  final expected = version == 0 ? Bech32Variant.bech32 : Bech32Variant.bech32m;
  if (decoded.variant != expected) {
    throw const Bech32FormatException(
      Bech32Problem.wrongVariant,
      'SegWit address uses the wrong Bech32 variant',
    );
  }

  return SegwitAddress(
    hrp: decoded.hrp,
    witnessVersion: version,
    program: program,
    variant: decoded.variant,
  );
}

/// SegWit address text for [hrp], [witnessVersion] and [program].
///
/// Applies the same rules as [decodeSegwitAddress]. Output is lower case.
/// Throws a [Bech32FormatException] when a rule fails.
String encodeSegwitAddress(String hrp, int witnessVersion, List<int> program) {
  final lowerHrp = hrp.toLowerCase();
  if (!_segwitHrps.contains(lowerHrp)) {
    throw const Bech32FormatException(
      Bech32Problem.unknownHrp,
      'SegWit human-readable part is not bc, tb or bcrt',
    );
  }
  if (witnessVersion < 0 || witnessVersion > 16) {
    throw const Bech32FormatException(
      Bech32Problem.unknownWitnessVersion,
      'SegWit witness version must be 0 to 16',
    );
  }
  _checkProgram(witnessVersion, program.length);

  final words = [witnessVersion, ...convertBits(program, 8, 5, pad: true)];
  final variant = witnessVersion == 0
      ? Bech32Variant.bech32
      : Bech32Variant.bech32m;

  return bech32Encode(lowerHrp, words, variant);
}

void _checkProgram(int version, int length) {
  if (length < 2 || length > 40) {
    throw const Bech32FormatException(
      Bech32Problem.invalidProgramLength,
      'SegWit program must be 2 to 40 bytes',
    );
  }
  if (version == 0 && length != 20 && length != 32) {
    throw const Bech32FormatException(
      Bech32Problem.invalidProgramLength,
      'SegWit version 0 program must be 20 or 32 bytes',
    );
  }
}

String _validHrp(String hrp) {
  if (hrp.isEmpty) {
    throw const Bech32FormatException(
      Bech32Problem.emptyHrp,
      'Bech32 human-readable part is empty',
    );
  }
  for (final unit in hrp.codeUnits) {
    if (unit < 33 || unit > 126) {
      throw const Bech32FormatException(
        Bech32Problem.invalidHrpCharacter,
        'Bech32 human-readable part has an invalid character',
      );
    }
  }

  return hrp.toLowerCase();
}

List<int> _hrpExpand(String hrp) {
  return [
    for (final unit in hrp.codeUnits) unit >> 5,
    0,
    for (final unit in hrp.codeUnits) unit & 31,
  ];
}

int _polymod(List<int> values) {
  var checksum = 1;
  for (final value in values) {
    final top = checksum >>> 25;
    checksum = ((checksum & 0x1ffffff) << 5) ^ value;
    for (var i = 0; i < 5; i++) {
      if (((top >>> i) & 1) == 1) {
        checksum ^= _generator[i];
      }
    }
  }

  return checksum;
}
