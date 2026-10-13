import 'dart:typed_data';

import 'ripemd160.dart';
import 'tools_bytes.dart';

/// HASH160 as used by Bitcoin addresses: RIPEMD-160 of SHA-256 of [bytes].
///
/// Returns 20 bytes. For P2PKH, pass the serialized public key.
Uint8List hash160(List<int> bytes) {
  return ripemd160(sha256Bytes(bytes));
}
