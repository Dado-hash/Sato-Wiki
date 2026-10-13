import 'dart:typed_data';

import 'base58.dart';
import 'bech32.dart';

/// Classifies a pasted Bitcoin address or key string. Pure Dart.
///
/// No user-facing text lives here: the UI translates the enums.

/// What a pasted string is.
enum AddressKind {
  p2pkh,
  p2sh,
  p2wpkh,
  p2wsh,
  p2tr,
  witnessUnknown,
  privateKeyWif,
  extendedKey,
  invalid,
}

/// Bitcoin network an address or key belongs to.
///
/// Testnet covers signet, which shares the testnet prefixes.
enum BitcoinNetwork { mainnet, testnet, regtest }

/// Checksum encoding of an address.
enum AddressEncoding { base58check, bech32, bech32m }

/// The failure found while analyzing a string.
enum AddressError {
  /// The input is blank.
  empty,

  /// A character is outside the alphabet of the detected encoding.
  badCharacter,

  /// The checksum does not match.
  badChecksum,

  /// The length is wrong for the detected type.
  badLength,

  /// The version byte or witness version is not one this app knows.
  unknownVersion,

  /// Upper and lower case letters are mixed in a Bech32 string.
  mixedCase,

  /// The Bech32 variant does not match the witness version.
  wrongBech32Variant,

  /// A Bech32 string has no `1` separator.
  missingSeparator,

  /// A Bech32 string has an empty human-readable part.
  emptyHumanReadablePart,

  /// The human-readable part is not a Bitcoin network.
  unknownHrp,

  /// A SegWit string has no witness data.
  emptyData,

  /// The bit regrouping of a SegWit program has bad padding.
  invalidPadding,
}

/// Result of [analyzeAddress].
final class AddressAnalysis {
  /// Creates an analysis result.
  const AddressAnalysis({
    required this.kind,
    this.network,
    this.encoding,
    this.checksumValid = false,
    this.versionByte,
    this.witnessVersion,
    this.payload,
    this.humanReadablePart,
    this.error,
  });

  /// What the string is.
  final AddressKind kind;

  /// The network, when it can be told from the string.
  final BitcoinNetwork? network;

  /// The checksum encoding, when one was detected.
  final AddressEncoding? encoding;

  /// Whether the checksum was verified.
  final bool checksumValid;

  /// The Base58Check version byte, for addresses and WIF keys.
  final int? versionByte;

  /// The SegWit witness version, 0 to 16.
  final int? witnessVersion;

  /// The hash or witness program. Always null for private keys and
  /// extended keys.
  final Uint8List? payload;

  /// The Bech32 human-readable part, lower case.
  final String? humanReadablePart;

  /// The failure, when [kind] is [AddressKind.invalid].
  final AddressError? error;
}

const _p2pkhMainnet = 0x00;
const _p2shMainnet = 0x05;
const _p2pkhTestnet = 0x6f;
const _p2shTestnet = 0xc4;
const _wifMainnet = 0x80;
const _wifTestnet = 0xef;
const _extendedKeyVersion = 0x04;
const _extendedKeyBodyLength = 78;
const _hashLength = 20;

final _base58Pattern = RegExp(r'^[1-9A-HJ-NP-Za-km-z]+$');

/// Classifies [input] as an address, a WIF private key, an extended key or
/// something invalid.
///
/// Never throws. Private keys are recognized by their version byte only; the
/// key bytes are never returned.
AddressAnalysis analyzeAddress(String input) {
  final text = input.trim();
  if (text.isEmpty) {
    return const AddressAnalysis(
      kind: AddressKind.invalid,
      error: AddressError.empty,
    );
  }

  final lower = text.toLowerCase();
  if (lower.startsWith('bc1') ||
      lower.startsWith('tb1') ||
      lower.startsWith('bcrt1')) {
    return _analyzeSegwit(text);
  }
  if (_base58Pattern.hasMatch(text)) {
    return _analyzeBase58(text);
  }

  return _analyzeOtherBech32(text);
}

AddressAnalysis _analyzeBase58(String text) {
  if (base58Decode(text).length < 5) {
    return const AddressAnalysis(
      kind: AddressKind.invalid,
      encoding: AddressEncoding.base58check,
      error: AddressError.badLength,
    );
  }

  final Base58CheckData data;
  try {
    data = base58CheckDecode(text);
  } on FormatException {
    return const AddressAnalysis(
      kind: AddressKind.invalid,
      encoding: AddressEncoding.base58check,
      error: AddressError.badChecksum,
    );
  }

  const base58Encoding = AddressEncoding.base58check;
  final payloadLength = data.payload.length;

  if (payloadLength + 1 == _extendedKeyBodyLength &&
      data.version == _extendedKeyVersion) {
    return const AddressAnalysis(
      kind: AddressKind.extendedKey,
      encoding: base58Encoding,
      checksumValid: true,
    );
  }

  switch (data.version) {
    case _wifMainnet:
    case _wifTestnet:
      final isWif = payloadLength == 32 || payloadLength == 33;

      return AddressAnalysis(
        kind: isWif ? AddressKind.privateKeyWif : AddressKind.invalid,
        network: data.version == _wifMainnet
            ? BitcoinNetwork.mainnet
            : BitcoinNetwork.testnet,
        encoding: base58Encoding,
        checksumValid: true,
        versionByte: data.version,
        error: isWif ? null : AddressError.badLength,
      );
    case _p2pkhMainnet:
    case _p2shMainnet:
    case _p2pkhTestnet:
    case _p2shTestnet:
      final isP2sh =
          data.version == _p2shMainnet || data.version == _p2shTestnet;
      final isMainnet =
          data.version == _p2pkhMainnet || data.version == _p2shMainnet;
      final hasRightLength = payloadLength == _hashLength;

      return AddressAnalysis(
        kind: hasRightLength
            ? (isP2sh ? AddressKind.p2sh : AddressKind.p2pkh)
            : AddressKind.invalid,
        network: isMainnet ? BitcoinNetwork.mainnet : BitcoinNetwork.testnet,
        encoding: base58Encoding,
        checksumValid: true,
        versionByte: data.version,
        payload: hasRightLength ? data.payload : null,
        error: hasRightLength ? null : AddressError.badLength,
      );
    default:
      return AddressAnalysis(
        kind: AddressKind.invalid,
        encoding: base58Encoding,
        checksumValid: true,
        versionByte: data.version,
        error: AddressError.unknownVersion,
      );
  }
}

AddressAnalysis _analyzeSegwit(String text) {
  final Bech32Data decoded;
  try {
    decoded = bech32Decode(text);
  } on Bech32FormatException catch (error) {
    return AddressAnalysis(
      kind: AddressKind.invalid,
      error: _mapProblem(error.problem),
    );
  }

  final encoding = decoded.variant == Bech32Variant.bech32
      ? AddressEncoding.bech32
      : AddressEncoding.bech32m;
  final network = _networkForHrp(decoded.hrp);

  final SegwitAddress segwit;
  try {
    segwit = decodeSegwitAddress(text);
  } on Bech32FormatException catch (error) {
    return AddressAnalysis(
      kind: AddressKind.invalid,
      network: network,
      encoding: encoding,
      checksumValid: true,
      humanReadablePart: decoded.hrp,
      error: _mapProblem(error.problem),
    );
  }

  final version = segwit.witnessVersion;
  final length = segwit.program.length;
  final AddressKind kind;
  if (version == 0 && length == _hashLength) {
    kind = AddressKind.p2wpkh;
  } else if (version == 0) {
    kind = AddressKind.p2wsh;
  } else if (version == 1 && length == 32) {
    kind = AddressKind.p2tr;
  } else {
    kind = AddressKind.witnessUnknown;
  }

  return AddressAnalysis(
    kind: kind,
    network: network,
    encoding: encoding,
    checksumValid: true,
    witnessVersion: version,
    payload: segwit.program,
    humanReadablePart: segwit.hrp,
  );
}

/// A Bech32 string that is not a SegWit address (for example a Lightning
/// invoice or an unknown human-readable part).
AddressAnalysis _analyzeOtherBech32(String text) {
  final Bech32Data decoded;
  try {
    decoded = bech32Decode(text);
  } on Bech32FormatException catch (error) {
    return AddressAnalysis(
      kind: AddressKind.invalid,
      error: _mapProblem(error.problem),
    );
  }

  return AddressAnalysis(
    kind: AddressKind.invalid,
    encoding: decoded.variant == Bech32Variant.bech32
        ? AddressEncoding.bech32
        : AddressEncoding.bech32m,
    checksumValid: true,
    humanReadablePart: decoded.hrp,
    error: AddressError.unknownHrp,
  );
}

BitcoinNetwork? _networkForHrp(String hrp) {
  return switch (hrp) {
    'bc' => BitcoinNetwork.mainnet,
    'tb' => BitcoinNetwork.testnet,
    'bcrt' => BitcoinNetwork.regtest,
    _ => null,
  };
}

AddressError _mapProblem(Bech32Problem problem) {
  return switch (problem) {
    Bech32Problem.tooLong ||
    Bech32Problem.tooShort ||
    Bech32Problem.invalidProgramLength => AddressError.badLength,
    Bech32Problem.mixedCase => AddressError.mixedCase,
    Bech32Problem.missingSeparator => AddressError.missingSeparator,
    Bech32Problem.emptyHrp => AddressError.emptyHumanReadablePart,
    Bech32Problem.invalidHrpCharacter ||
    Bech32Problem.invalidCharacter => AddressError.badCharacter,
    Bech32Problem.badChecksum => AddressError.badChecksum,
    Bech32Problem.unknownHrp => AddressError.unknownHrp,
    Bech32Problem.emptyData => AddressError.emptyData,
    Bech32Problem.unknownWitnessVersion => AddressError.unknownVersion,
    Bech32Problem.wrongVariant => AddressError.wrongBech32Variant,
    Bech32Problem.invalidPadding => AddressError.invalidPadding,
  };
}
