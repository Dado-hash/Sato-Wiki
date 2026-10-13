import '../domain/address_analyzer.dart';

/// What the explorer search box was asked to look up. Pure Dart.
sealed class ExplorerQuery {
  const ExplorerQuery();
}

/// A block height of 1 to 8 digits.
final class ExplorerHeightQuery extends ExplorerQuery {
  /// Creates a height query.
  const ExplorerHeightQuery(this.height);

  /// The requested block height.
  final int height;
}

/// 64 hexadecimal characters: a block hash or a txid. The UI tries both.
final class ExplorerHashQuery extends ExplorerQuery {
  /// Creates a hash query. [hash] is stored in lower case.
  const ExplorerHashQuery(this.hash);

  /// The hash, in lower case hex.
  final String hash;

  /// Whether the hash starts with at least 8 zero characters, as block hashes
  /// do because of proof of work.
  bool get looksLikeBlockHash => hash.startsWith('00000000');
}

/// A Bitcoin address of a kind the analyzer accepts.
final class ExplorerAddressQuery extends ExplorerQuery {
  /// Creates an address query.
  const ExplorerAddressQuery(this.address);

  /// The address, trimmed.
  final String address;
}

final _heightPattern = RegExp(r'^[0-9]{1,8}$');
final _hashPattern = RegExp(r'^[0-9a-fA-F]{64}$');
const _addressKinds = <AddressKind>{
  AddressKind.p2pkh,
  AddressKind.p2sh,
  AddressKind.p2wpkh,
  AddressKind.p2wsh,
  AddressKind.p2tr,
  AddressKind.witnessUnknown,
};

/// Classifies explorer search text, or returns null when it cannot be searched.
///
/// Surrounding spaces are ignored. WIF private keys and extended keys return
/// null, so they are never sent to a server. Never throws.
ExplorerQuery? parseExplorerQuery(String input) {
  final text = input.trim();
  if (text.isEmpty) {
    return null;
  }
  if (_heightPattern.hasMatch(text)) {
    return ExplorerHeightQuery(int.parse(text));
  }
  if (_hashPattern.hasMatch(text)) {
    return ExplorerHashQuery(text.toLowerCase());
  }
  if (_addressKinds.contains(analyzeAddress(text).kind)) {
    return ExplorerAddressQuery(text);
  }

  return null;
}
