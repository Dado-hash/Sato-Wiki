---
id: wiki.public-keys
slug: public-keys
language: en
category: cryptography
title: Public Keys
description: The cryptographic coordinates derived from private keys that others use to verify signatures and send bitcoin.
coverImage: media/wiki/public-keys/public-key-derivation.svg
difficulty: advanced
readTimeMinutes: 8
tags:
  - Cryptography
  - Public Keys
  - Elliptic Curve
  - Addresses
related:
  - wiki.private-keys
  - wiki.digital-signatures
  - wiki.ecdsa
  - wiki.bitcoin-addresses
  - wiki.secp256k1
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: "Mastering Bitcoin - Chapter 4"
    url: https://github.com/bitcoinbook/bitcoinbook/blob/develop/ch04.asciidoc
    author: Andreas M. Antonopoulos
  - title: "secp256k1 standard"
    url: https://www.secg.org/sec2-v2.pdf
    author: SECG
updatedAt: 2026-05-27T00:00:00Z
---

## base

A public key is derived from a private key using elliptic curve multiplication. The private key is a secret 256-bit number, and the public key is the result of multiplying it by a fixed generator point on the secp256k1 curve. This operation is one-way: given a public key, there is no known mathematical method to recover the private key.

A public key is safe to share. Anyone who knows your public key can verify signatures you create and can send bitcoin to the associated address. The address itself is computed by hashing the public key, adding another layer of protection.

Think of a public key like a mailbox. The mailbox is visible to everyone — anyone can drop mail in it. But only the person with the private key — the key to the mailbox — can open it and retrieve what is inside. The address is a label that tells people which mailbox to use.

![Public key derivation from private key](media/wiki/public-keys/public-key-derivation.svg "The private key scalar k is multiplied by the generator point G to produce the public key point K = k * G on the secp256k1 curve.")

## medium

A Bitcoin public key is a point on the secp256k1 elliptic curve. It consists of two coordinates (x, y) that satisfy the curve equation y^2 = x^3 + 7 over the finite field defined by the prime modulus p.

Given a private key k (a scalar integer in the range [1, n-1], where n is the curve order), the public key K is computed as:

```
K = k * G
```

Here G is the generator point of the secp256k1 curve, a fixed base point whose coordinates are defined by the standard. The symbol * denotes elliptic curve scalar multiplication — the repeated addition of G to itself k times. This operation is computationally efficient in one direction but infeasible to reverse, a property known as the discrete logarithm problem.

Public keys appear in two serialisation formats:

- **Compressed (33 bytes)**: Stores the x-coordinate and a prefix byte indicating the parity (sign) of the y-coordinate. The prefix is 0x02 if y is even, 0x03 if y is odd. Since the curve equation determines y up to sign given x, the full point can be reconstructed from x and the parity bit alone.

- **Uncompressed (65 bytes)**: Stores both coordinates in full, prefixed by 0x04. This format is larger but was the default in early Bitcoin software. It is still valid but rarely used in new transactions because of the extra block space cost.

The compressed format has become the standard because it saves 32 bytes per public key in every transaction input. In a transaction with multiple inputs, the savings compound significantly. The transition to compressed keys was incentivised by the lower transaction fees that smaller data sizes produce.

Because public keys are derived deterministically from private keys, the same private key always produces the same public key. This determinism is what makes key pairs verifiable: anyone can check that a public key corresponds to a given private key by performing the same multiplication.

From the public key, a Bitcoin address is produced through a hash chain. First the public key is hashed with SHA-256, then the result is hashed with RIPEMD-160. The resulting 20-byte hash is encoded in Base58Check (legacy addresses) or Bech32 (SegWit addresses). This hashing adds collision resistance and reduces the address length, but it means the public key is not revealed until the funds are spent.

## advanced

**Elliptic curve scalar multiplication.** The operation K = k * G is not ordinary multiplication. It is defined as repeatedly applying the elliptic curve group law: point addition and point doubling.

Point addition takes two distinct points P and Q on the curve and produces a third point R = P + Q. Geometrically, R is the reflection across the x-axis of the third intersection point of the line through P and Q with the curve.

Point doubling takes a single point P and produces R = 2*P. It uses the tangent line at P instead of a secant line through two points.

Scalar multiplication combines addition and doubling using the double-and-add algorithm. To compute k*G, scan the bits of k from most significant to least: start at G, then for each bit, double the current result, and if the bit is 1, add G. This requires at most 256 doublings and 256 additions — about 512 curve operations for any 256-bit scalar.

**Generator point G.** The secp256k1 generator point has these coordinates:

```
G_x = 0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798
G_y = 0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8
```

Every public key on the curve is some multiple of G. The order n of G is the smallest positive integer such that n * G = O (the point at infinity). For secp256k1, n is approximately 1.1579 * 10^77.

**Prefix bytes and key formats.** The first byte of a serialised public key tells the parser what format is being used:

- 0x04 — uncompressed, followed by 32 bytes of x and 32 bytes of y (65 bytes total).
- 0x02 — compressed, y is even (33 bytes).
- 0x03 — compressed, y is odd (33 bytes).
- 0x06 — hybrid, y is even (65 bytes, rarely used).
- 0x07 — hybrid, y is odd (65 bytes, rarely used).

Hybrid formats (0x06, 0x07) include both coordinates like uncompressed but also encode the y parity like compressed. They provide a safety check: the parser can verify that the included y matches the parity indicated by the prefix. In practice, hybrid keys are almost never seen on the Bitcoin network.

**Public key recovery from signatures.** One unique property of ECDSA is that the public key can be recovered from a signature and the message that was signed. Given (r, s) and the message hash, there are usually two or four possible candidate public keys. The signature includes a recovery ID (v) that identifies the correct one.

This recovery feature means: if you have a signed message and the signature, you do not need to be told the public key separately — you can compute it. This property was used heavily in the early days for offline payment protocols and is still used by Ethereum for transaction origination (where the sender is recovered from the signature rather than explicitly included).

Bitcoin P2PKH (Pay-to-Public-Key-Hash) transactions do not rely on this for standard spending, but it is used internally by some wallet implementations and for signing messages outside of transactions.

**Schnorr signatures remove recovery.** Schnorr signatures (activated in Taproot, November 2021) do not support public key recovery from signatures. This is an intentional design choice. Schnorr uses a different signing structure where the public key is committed to inside the signature nonce, making recovery impossible without additional data.

The trade-off is practical: Schnorr signatures are smaller, support signature aggregation (multiple signers produce one signature), and provide better privacy through key path spending. Public key recovery was a niche feature of ECDSA that was sacrificed for these gains.

**Security and the discrete log problem.** The security of all Bitcoin public key cryptography rests on the assumption that solving the discrete logarithm problem on the secp256k1 curve is computationally infeasible. Given a public key point K, finding the private key k such that K = k * G requires an attacker to determine how many times G was added to itself.

The best known algorithm for this is Pollard's rho, which has a running time of O(sqrt(n)) curve operations. For n ~ 2^256, sqrt(n) ~ 2^128 operations. This is far beyond any practical capability. Even with optimised hardware, 2^128 curve operations would consume more energy than is available from all the stars in the observable universe.

Quantum computing changes this picture. Shor's algorithm can solve the discrete log problem in polynomial time, which would break ECDSA and Schnorr. However, a quantum computer large enough to attack Bitcoin keys — requiring millions of physical qubits — does not exist and is not expected within the next decade. The Bitcoin community is actively researching post-quantum signature schemes as a long-term mitigation.
