// Bitcoin amounts, fee and weight helpers. Pure Dart, no Flutter imports.

/// Satoshi in one bitcoin.
const int satoshiPerBitcoin = 100000000;

final BigInt _satoshiPerBitcoinBig = BigInt.from(satoshiPerBitcoin);
final RegExp _amountPattern = RegExp(r'^([+-]?)(\d*)(?:[.,](\d+))?$');

/// Decimal BTC text for [satoshi], always with exactly 8 decimals.
///
/// Uses integer math only, so there is no rounding. For example 1 gives
/// `0.00000001` and 2100000000000000 gives `21000000.00000000`.
String satoshiToBitcoinText(int satoshi) {
  final value = BigInt.from(satoshi).abs();
  final whole = value ~/ _satoshiPerBitcoinBig;
  final fraction = value.remainder(_satoshiPerBitcoinBig);
  final sign = satoshi < 0 ? '-' : '';

  return '$sign$whole.${fraction.toString().padLeft(8, '0')}';
}

/// Satoshi for the decimal BTC [text], using integer math only.
///
/// Accepts `.` or `,` as decimal separator and an optional leading sign.
/// Throws a [FormatException] for empty text, garbage, or more than 8 decimals.
int bitcoinTextToSatoshi(String text) {
  final match = _amountPattern.firstMatch(text.trim());
  if (match == null) {
    throw FormatException('Not a decimal bitcoin amount', text);
  }

  final sign = match.group(1) ?? '';
  final wholeDigits = match.group(2) ?? '';
  final fractionDigits = match.group(3);
  if (wholeDigits.isEmpty && fractionDigits == null) {
    throw FormatException('Not a decimal bitcoin amount', text);
  }
  if ((fractionDigits?.length ?? 0) > 8) {
    throw FormatException('Bitcoin amounts have at most 8 decimals', text);
  }

  final whole = BigInt.parse(wholeDigits.isEmpty ? '0' : wholeDigits);
  final fraction = BigInt.parse((fractionDigits ?? '').padRight(8, '0'));
  var value = whole * _satoshiPerBitcoinBig + fraction;
  if (sign == '-') {
    value = -value;
  }
  if (value.abs().bitLength > 63) {
    throw FormatException('Bitcoin amount is out of range', text);
  }

  return value.toInt();
}

/// Virtual bytes for a transaction of [weight] weight units, rounded up.
int vbytesFromWeight(int weight) {
  if (weight < 0) {
    throw ArgumentError.value(weight, 'weight', 'must not be negative');
  }

  return (weight + 3) ~/ 4;
}

/// Weight units from the stripped size and the full size: `base * 3 + total`.
int weightFromSizes({required int baseSize, required int totalSize}) {
  if (baseSize < 0 || totalSize < baseSize) {
    throw ArgumentError('Total size must be at least the base size');
  }

  return baseSize * 3 + totalSize;
}

/// Fee rate in satoshi per virtual byte.
///
/// Throws an [ArgumentError] when [vbytes] is zero or negative.
double feeRate({required int feeSatoshi, required int vbytes}) {
  if (vbytes <= 0) {
    throw ArgumentError.value(vbytes, 'vbytes', 'must be positive');
  }

  return feeSatoshi / vbytes;
}

/// Fee in satoshi for [satPerVbyte] over [vbytes], rounded up.
///
/// Values within a tiny tolerance of a whole number are not rounded up, so a
/// rate such as 1.1 sat/vB over 10 vB gives 11 and not 12.
int feeForRate({required double satPerVbyte, required int vbytes}) {
  if (vbytes < 0) {
    throw ArgumentError.value(vbytes, 'vbytes', 'must not be negative');
  }
  if (!satPerVbyte.isFinite || satPerVbyte < 0) {
    throw ArgumentError.value(
      satPerVbyte,
      'satPerVbyte',
      'must be a finite non-negative rate',
    );
  }

  final exact = satPerVbyte * vbytes;
  final nearest = exact.roundToDouble();
  if ((exact - nearest).abs() < 1e-9 * (1 + exact)) {
    return nearest.toInt();
  }

  return exact.ceil();
}
