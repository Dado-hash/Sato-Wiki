import 'dart:typed_data';

/// RIPEMD-160 helpers for the offline tools. Pure Dart, no Flutter imports.

const _mask32 = 0xffffffff;

/// Message word order for the left and right lines, per round.
const _leftWord = <int>[
  0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, //
  7, 4, 13, 1, 10, 6, 15, 3, 12, 0, 9, 5, 2, 14, 11, 8, //
  3, 10, 14, 4, 9, 15, 8, 1, 2, 7, 0, 6, 13, 11, 5, 12, //
  1, 9, 11, 10, 0, 8, 12, 4, 13, 3, 7, 15, 14, 5, 6, 2, //
  4, 0, 5, 9, 7, 12, 2, 10, 14, 1, 3, 8, 11, 6, 15, 13, //
];

const _rightWord = <int>[
  5, 14, 7, 0, 9, 2, 11, 4, 13, 6, 15, 8, 1, 10, 3, 12, //
  6, 11, 3, 7, 0, 13, 5, 10, 14, 15, 8, 12, 4, 9, 1, 2, //
  15, 5, 1, 3, 7, 14, 6, 9, 11, 8, 12, 2, 10, 0, 4, 13, //
  8, 6, 4, 1, 3, 11, 15, 0, 5, 12, 2, 13, 9, 7, 10, 14, //
  12, 15, 10, 4, 1, 5, 8, 7, 6, 2, 13, 14, 0, 3, 9, 11, //
];

/// Left rotation amounts.
const _leftShift = <int>[
  11, 14, 15, 12, 5, 8, 7, 9, 11, 13, 14, 15, 6, 7, 9, 8, //
  7, 6, 8, 13, 11, 9, 7, 15, 7, 12, 15, 9, 11, 7, 13, 12, //
  11, 13, 6, 7, 14, 9, 13, 15, 14, 8, 13, 6, 5, 12, 7, 5, //
  11, 12, 14, 15, 14, 15, 9, 8, 9, 14, 5, 6, 8, 6, 5, 12, //
  9, 15, 5, 11, 6, 8, 13, 12, 5, 12, 13, 14, 11, 8, 5, 6, //
];

/// Right rotation amounts.
const _rightShift = <int>[
  8, 9, 9, 11, 13, 15, 15, 5, 7, 7, 8, 11, 14, 14, 12, 6, //
  9, 13, 15, 7, 12, 8, 9, 11, 7, 7, 12, 7, 6, 15, 13, 11, //
  9, 7, 15, 11, 8, 6, 6, 14, 12, 13, 5, 14, 13, 13, 7, 5, //
  15, 5, 8, 11, 14, 14, 6, 14, 6, 9, 12, 9, 12, 5, 15, 8, //
  8, 5, 12, 9, 12, 5, 14, 6, 8, 13, 6, 5, 15, 13, 11, 11, //
];

const _leftConstant = <int>[
  0x00000000,
  0x5a827999,
  0x6ed9eba1,
  0x8f1bbcdc,
  0xa953fd4e,
];
const _rightConstant = <int>[
  0x50a28be6,
  0x5c4dd124,
  0x6d703ef3,
  0x7a6d76e9,
  0x00000000,
];

/// RIPEMD-160 digest of [bytes], always 20 bytes long.
///
/// Used by Bitcoin for addresses through [hash160]. Works on any input length.
Uint8List ripemd160(List<int> bytes) {
  final message = _padMessage(bytes);
  final state = <int>[
    0x67452301,
    0xefcdab89,
    0x98badcfe,
    0x10325476,
    0xc3d2e1f0,
  ];
  final words = List<int>.filled(16, 0);

  for (var offset = 0; offset < message.length; offset += 64) {
    for (var i = 0; i < 16; i++) {
      words[i] = _readUint32LittleEndian(message, offset + i * 4);
    }
    _compress(state, words);
  }

  final digest = Uint8List(20);
  for (var i = 0; i < 5; i++) {
    for (var b = 0; b < 4; b++) {
      digest[i * 4 + b] = (state[i] >>> (8 * b)) & 0xff;
    }
  }

  return digest;
}

/// [bytes] followed by the 0x80 marker, zero padding and the 64-bit bit length.
Uint8List _padMessage(List<int> bytes) {
  final zeroCount = (55 - bytes.length) % 64;
  final padded = Uint8List(bytes.length + 1 + zeroCount + 8);
  padded.setAll(0, bytes);
  padded[bytes.length] = 0x80;

  final bitLength = bytes.length * 8;
  final lengthOffset = padded.length - 8;
  for (var i = 0; i < 8; i++) {
    padded[lengthOffset + i] = (bitLength >>> (8 * i)) & 0xff;
  }

  return padded;
}

int _readUint32LittleEndian(Uint8List bytes, int offset) {
  return bytes[offset] |
      (bytes[offset + 1] << 8) |
      (bytes[offset + 2] << 16) |
      (bytes[offset + 3] << 24);
}

/// Mixing function for [round] (0..4) over three 32-bit words.
int _mix(int round, int x, int y, int z) {
  final result = switch (round) {
    0 => x ^ y ^ z,
    1 => (x & y) | (~x & z),
    2 => (x | ~y) ^ z,
    3 => (x & z) | (y & ~z),
    _ => x ^ (y | ~z),
  };

  return result & _mask32;
}

int _rotateLeft(int value, int bits) {
  return ((value << bits) | (value >>> (32 - bits))) & _mask32;
}

/// One 512-bit block: runs the left and right lines and merges them into [state].
void _compress(List<int> state, List<int> words) {
  var al = state[0], bl = state[1], cl = state[2], dl = state[3], el = state[4];
  var ar = state[0], br = state[1], cr = state[2], dr = state[3], er = state[4];

  for (var step = 0; step < 80; step++) {
    final round = step >> 4;

    final leftSum =
        (al +
            _mix(round, bl, cl, dl) +
            words[_leftWord[step]] +
            _leftConstant[round]) &
        _mask32;
    final tLeft = (_rotateLeft(leftSum, _leftShift[step]) + el) & _mask32;
    al = el;
    el = dl;
    dl = _rotateLeft(cl, 10);
    cl = bl;
    bl = tLeft;

    final rightSum =
        (ar +
            _mix(4 - round, br, cr, dr) +
            words[_rightWord[step]] +
            _rightConstant[round]) &
        _mask32;
    final tRight = (_rotateLeft(rightSum, _rightShift[step]) + er) & _mask32;
    ar = er;
    er = dr;
    dr = _rotateLeft(cr, 10);
    cr = br;
    br = tRight;
  }

  final t = (state[1] + cl + dr) & _mask32;
  state[1] = (state[2] + dl + er) & _mask32;
  state[2] = (state[3] + el + ar) & _mask32;
  state[3] = (state[4] + al + br) & _mask32;
  state[4] = (state[0] + bl + cr) & _mask32;
  state[0] = t;
}
