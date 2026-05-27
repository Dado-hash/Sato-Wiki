---
id: wiki.ecdsa
slug: ecdsa
language: en
category: cryptography
title: ECDSA
description: The Elliptic Curve Digital Signature Algorithm Bitcoin used since its inception to authorize transactions through private key ownership.
coverImage: media/wiki/ecdsa/ecdsa-sign-verify.svg
difficulty: advanced
readTimeMinutes: 9
tags:
  - Cryptography
  - ECDSA
  - Signatures
  - Elliptic Curve
related:
  - wiki.digital-signatures
  - wiki.schnorr-signatures
  - wiki.private-keys
  - wiki.public-keys
  - wiki.secp256k1
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: "ANSI X9.62 - ECDSA Standard"
    url: https://www.secg.org/sec1-v2.pdf
    author: SECG
  - title: "BIP 340 - Schnorr Signatures for secp256k1"
    url: https://github.com/bitcoin/bips/blob/master/bip-0340.mediawiki
    author: Pieter Wuille, Jonas Nick, Tim Ruffing
updatedAt: 2026-05-27T00:00:00Z
---

## base

ECDSA is the original signature algorithm Bitcoin uses to authorize transactions. A signature proves knowledge of a private key without revealing it. Every Bitcoin transaction input contains an ECDSA signature that unlocks the funds by proving ownership of the private key corresponding to the public key locked in the output.

To sign a message `z` (the transaction hash) with private key `d`:

1. Pick a random nonce `k` between 1 and `n-1`, where `n` is the curve order.
2. Compute the elliptic curve point `R = k * G`, where `G` is the generator point. Let `r = R.x`.
3. Compute `s = k⁻¹(z + r * d) mod n`.
4. The signature is `(r, s)`.

To verify a signature `(r, s)` against a message `z` and public key `Q`:

1. Compute `u₁ = z * s⁻¹ mod n` and `u₂ = r * s⁻¹ mod n`.
2. Compute the point `R' = u₁ * G + u₂ * Q`.
3. Check that `R'.x == r`. If equal, the signature is valid.

![ECDSA Signing and Verification](media/wiki/ecdsa/ecdsa-sign-verify.svg "The ECDSA signing formula on the left produces (r, s) from the private key, message hash, and random nonce k. The verification formula on the right computes u1 and u2, reconstructs the point R', and checks that its x-coordinate equals r.")

The simple intuition: the signer proves knowledge of the private key `d` by creating a mathematical relationship that only someone with `d` could produce. The verification equation `R' = u₁ * G + u₂ * Q` expands to `(z * s⁻¹) * G + (r * s⁻¹) * Q`. Substituting `Q = d * G` and `s = k⁻¹(z + r * d)` shows that `R'` reconstructs the original `R`, confirming the signer knew `d`.

## medium

**The nonce is critical.** The random value `k` must satisfy two properties: it must be unique across all signatures from the same private key, and it must remain secret. If `k` is ever reused with the same private key, anyone who sees both signatures can compute the private key directly:

- Given two signatures `(r, s₁)` and `(r, s₂)` with the same `k` and same `r`, an attacker computes `k = (z₁ - z₂) / (s₁ - s₂)` and then `d = (s₁ * k - z₁) / r`.

This is not a theoretical risk. In 2010, the Sony PlayStation 3 used a fixed nonce `k` for ECDSA signatures, allowing attackers to derive the private key used to sign firmware updates. In 2013, the Android Bitcoin wallet bug produced weak nonces due to a flawed `SecureRandom` implementation, allowing attackers to drain wallets by scanning the blockchain for signatures sharing the same `r` value.

To eliminate the risk of bad randomness, RFC 6979 defines a deterministic way to generate `k` by hashing the private key and the message together. This ensures the same message always produces the same nonce — safe because the private key is secret — while different messages or keys produce unrelated nonces. Most modern Bitcoin wallets use RFC 6979.

**Signature format.** An ECDSA signature is typically encoded in DER (Distinguished Encoding Rules) format. A typical signature occupies 70-72 bytes:

```
30 [total-length] 02 [r-length] [r bytes] 02 [s-length] [s bytes]
```

The variable length arises because DER uses minimal big-endian encoding with no leading zero bytes, and prepends a `0x00` byte when the high bit is set (to prevent the integer from being interpreted as negative).

**Public key recovery.** ECDSA signatures have a useful property: given `(r, s)` and the message `z`, you can recover the public key `Q` without knowing it in advance. This is called public key recovery or key recovery. There are typically four possible recovered keys (two possible `R` points from the x-coordinate `r`, and for each, two possible values based on the recovery ID or "v" byte). Ethereum uses this property extensively: transactions include only the signature, and the sender address is derived from the recovered public key.

In Bitcoin, public key recovery is used in the signature hash algorithm. The recovery ID (v) is encoded alongside the signature to disambiguate which of the four candidates is correct. SegWit v0 addresses (P2WPKH) and legacy P2PKH addresses both rely on this mechanism.

**Nonce generation in detail.** RFC 6979 generates `k` in a way that is both deterministic and resistant to side-channel attacks:

1. Hash the private key and message to produce an initial seed.
2. Use HMAC-DRBG (a deterministic random bit generator based on HMAC-SHA256) to produce `k`.
3. If `k` is zero or greater than `n`, regenerate using the DRBG's reseed mechanism.

This approach guarantees uniqueness without relying on system entropy, making it suitable for embedded devices, hardware wallets, and any environment where randomness might be compromised.

## advanced

**DER encoding details.** The full DER encoding of an ECDSA signature follows ASN.1 structure:

- A SEQUENCE tag (`0x30`) followed by the total length of the remaining data.
- An INTEGER tag (`0x02`) for `r`, its length, and the `r` value itself, encoded as a signed big-endian integer with no leading zeros. If the high bit of `r` is set, a `0x00` padding byte is prepended.
- An INTEGER tag (`0x02`) for `s`, with the same signing conventions.

This encoding is what gives ECDSA its variable signature size. BIP 66 standardized strict DER encoding for Bitcoin, requiring exactly this format and rejecting any deviations. Before BIP 66, nodes accepted non-strict encodings, creating malleability vectors.

**Signature malleability.** ECDSA signatures are malleable in several ways:

- **`s` malleability (BIP 62).** If `(r, s)` is a valid signature, then `(r, n-s)` is also valid for the same message and key, because `s` and `n-s` are modular inverses of each other. BIP 146 (low-s requirement) made Bitcoin reject signatures where `s > n/2`, eliminating this vector.
- **DER padding malleability.** Before BIP 66, extra padding bytes in the DER integers could be added or removed without changing the mathematical validity of `(r, s)`. An attacker could tweak the encoding to produce a different transaction identifier (txid) for the same logical transaction.
- **Third-party malleability.** Before SegWit, anyone could take an unconfirmed transaction, modify the DER encoding of its signature, and broadcast the mutated version. Since the txid changed, the mutated transaction could be confirmed instead of the original, effectively invalidating the original. SegWit solved this by moving signatures into the witness structure, which is excluded from the txid calculation.

BIP 66 (strict DER) and BIP 62 (low-s requirement) reduced malleability significantly. SegWit eliminated it entirely for SegWit inputs.

**ECDSA vs Schnorr.** ECDSA has several structural disadvantages compared to Schnorr signatures (BIP 340):

- **Non-linearity.** ECDSA is not linear: the signing equation `s = k⁻¹(z + r * d)` involves modular inversion and mixes the message hash with both the private key and the nonce in a way that does not support algebraic combinations. Schnorr signatures are linear: `s = k + e * d`, which enables signature aggregation, batch verification, and adaptor signatures.
- **Batch verification.** Schnorr signatures can be batch-verified: verifying `n` signatures costs less than `n` times the cost of a single verification, using random linear combinations. ECDSA does not support batch verification at all — each signature must be checked individually.
- **Signature aggregation.** Multiple Schnorr signatures from different signers on different messages can be aggregated into a single signature, reducing block space usage. MuSig and MuSig2 (BIP 327) build multi-signature schemes on this property.
- **Size.** Schnorr signatures are fixed at 64 bytes. ECDSA signatures are 70-72 bytes in DER encoding.

**Security proof.** ECDSA is proven existentially unforgeable under chosen message attack (EUF-CMA) in the random oracle model, assuming the elliptic curve discrete logarithm problem is hard. The proof models the hash function as a random oracle and shows that an adversary who can forge signatures can be used to solve the discrete log problem.

The security reduction is tight: a successful forger implies a discrete log solver with roughly the same advantage. This means ECDSA on secp256k1 provides approximately 128 bits of security (half the key size, due to Pollard's rho algorithm for discrete log).

**Why BIP 340 Schnorr is replacing ECDSA.** Bitcoin's Taproot upgrade (2021) introduced Schnorr signatures as a native option through BIP 340. While ECDSA remains in wide use for legacy and SegWit v0 transactions, new protocol developments favor Schnorr:

- **Taproot outputs** use Schnorr by default, offering smaller transaction sizes and better privacy.
- **Cross-input signature aggregation** (proposed) would aggregate signatures across multiple inputs in a single transaction, significantly reducing multi-input transaction sizes.
- **Smart contract protocols** like Lightning Network and Discreet Log Contracts benefit from Schnorr's linearity for adaptor signatures and atomic swaps.

ECDSA will remain part of Bitcoin's consensus rules indefinitely — legacy outputs cannot be spent without it — but all new signature-based features are being built on Schnorr.
