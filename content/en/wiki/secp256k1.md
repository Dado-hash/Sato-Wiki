---
id: wiki.secp256k1
slug: secp256k1
language: en
category: cryptography
title: secp256k1
description: The specific elliptic curve standardized by SECG that Bitcoin uses for all its cryptographic key operations.
coverImage: media/wiki/secp256k1/secp256k1-curve.svg
difficulty: advanced
readTimeMinutes: 8
tags:
  - Cryptography
  - secp256k1
  - Elliptic Curve
  - ECDSA
  - Schnorr
related:
  - wiki.private-keys
  - wiki.public-keys
  - wiki.ecdsa
  - wiki.schnorr-signatures
  - wiki.digital-signatures
sources:
  - title: "SEC 2 — Recommended Elliptic Curve Domain Parameters"
    url: https://www.secg.org/sec2-v2.pdf
    author: Standards for Efficient Cryptography Group
    publishedAt: 2010-01-27
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: "BIP 340 — Schnorr Signatures for secp256k1"
    url: https://github.com/bitcoin/bips/blob/master/bip-0340.mediawiki
    author: Pieter Wuille, Jonas Nick, Tim Ruffing
updatedAt: 2026-05-27T00:00:00Z
---

## base

secp256k1 is the elliptic curve Bitcoin uses for all its cryptographic operations. Every private key, public key, and digital signature in Bitcoin is defined by this curve. It is a Koblitz curve — a special type of elliptic curve designed for efficient computation — over the field of prime order p.

The curve equation is y² = x³ + 7. This is a simple equation, but its structure over a finite field creates a mathematical playground where certain problems are easy to compute forward but infeasible to reverse, which is exactly what Bitcoin needs for its security.

Satoshi Nakamoto chose secp256k1 for Bitcoin specifically because it expresses better performance than other standard curves and has no known backdoors. The curve's Koblitz design allows for particularly efficient point multiplication, which matters because every Bitcoin transaction requires at least one such operation.

![secp256k1 curve parameters and key derivation](media/wiki/secp256k1/secp256k1-curve.svg "The secp256k1 curve equation y² = x³ + 7, its prime order, and the public key derivation K = k × G.")

## medium

secp256k1 is defined over the field F_p where p = 2²⁵⁶ − 2³² − 2⁹ − 2⁸ − 2⁷ − 2⁶ − 2⁴ − 1. This prime was chosen because it is very close to a power of two, enabling efficient modular reduction using bit shifts and additions instead of general-purpose division. Any implementation benefits from this choice automatically.

The curve order n — the number of points on the curve — is approximately 2²⁵⁶. Every private key is a scalar in the range [1, n-1]. The generator point G is a fixed curve point used in the key derivation formula K = k × G, where k is the private key, G is the generator, and K is the public key. The generator G is specified in compressed form as `0279BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798`.

Bitcoin chose secp256k1 also for its verifiably random parameters. Unlike other curves where certain constants were chosen without public explanation, secp256k1's parameters are derived from the smallest possible values that satisfy the curve equation, leaving no room for hidden weaknesses. The curve has cofactor 1, meaning the number of points equals the order n exactly.

Key types using secp256k1:
- ECDSA signatures (Bitcoin since 2009)
- Schnorr signatures (BIP 340, Taproot 2021)
- Public key recovery from signatures
- HD wallet key derivation (BIP 32)

## advanced

The curve secp256k1 belongs to the Koblitz family (K-256), designed for performance using the Frobenius endomorphism. The Frobenius map τ(x, y) = (x², y²) over F_p allows replacing point doubling operations with much cheaper field squarings. Implementations using τ-adic expansions can achieve 2-3× speedup in scalar multiplication compared to generic curves like P-256, with more advanced techniques approaching 4×.

The field prime p = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F is a Crandall prime (also called a Solinas prime of the form 2²⁵⁶ − 2³² − 937). Modular reduction can be performed efficiently using the identity:

```
c = 2²⁵⁶ mod p = 2³² + 937
```

This property is critical for high-speed implementations, reducing a 512-bit product to 256 bits in just a few additions. Most production-grade implementations (libsecp256k1, OpenSSL) use this to achieve sub-microsecond scalar multiplication on modern hardware.

The curve order n = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 is a 256-bit prime. The relationship between p and n is not random: n ≈ p for Koblitz curves due to the Hasse bound |n − (p + 1)| ≤ 2√p.

Security: the best known attack on secp256k1's discrete log is Pollard's rho algorithm, with expected complexity approximately (√(πn/2))/2 ≈ 2¹²⁸ operations using parallelized variants. This matches the 128-bit security level claimed for the curve. All known attacks require 2¹²⁸ curve operations, each of which is a full scalar multiplication.

The choice of secp256k1 over NIST curves (P-256) was deliberate. Satoshi selected it because:
- Verifiably random parameters (no unexplained constants)
- No relationship to NSA-designed curves
- Koblitz curve structure for implementation efficiency
- Strong community analysis and adoption

Modern Bitcoin implementations (Bitcoin Core, libsecp256k1) use constant-time scalar multiplication to prevent side-channel attacks. The libsecp256k1 library, maintained by Pieter Wuille and the Bitcoin Core team, implements these techniques for both ECDSA and Schnorr signatures and is considered a reference for production-grade elliptic curve cryptography.
