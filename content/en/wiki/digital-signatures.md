---
id: wiki.digital-signatures
slug: digital-signatures
language: en
category: cryptography
title: Digital Signatures
description: The cryptographic mechanism that proves ownership of a private key without revealing it, securing every Bitcoin transaction.
coverImage: media/wiki/digital-signatures/digital-signature-flow.svg
difficulty: advanced
readTimeMinutes: 8
tags:
  - Cryptography
  - Signatures
  - Authentication
  - Transactions
related:
  - wiki.private-keys
  - wiki.public-keys
  - wiki.ecdsa
  - wiki.schnorr-signatures
  - wiki.bitcoin-script
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: "Mastering Bitcoin - Chapter 4"
    url: https://github.com/bitcoinbook/bitcoinbook/blob/develop/ch04.asciidoc
    author: Andreas M. Antonopoulos
  - title: "BIP 340 - Schnorr Signatures for secp256k1"
    url: https://github.com/bitcoin/bips/blob/master/bip-0340.mediawiki
    author: Pieter Wuille, Jonas Nick, Tim Ruffing
updatedAt: 2026-05-27T00:00:00Z
---

## base

A digital signature proves you know a private key without revealing it. In Bitcoin, you sign a transaction to authorize spending. Anyone with your public key can verify the signature was made by the corresponding private key. Signatures are unique to the message: you cannot reuse a signature from one transaction on another.

The signing algorithm takes a private key and a message (the transaction) and produces a signature. The verification algorithm takes the message, the signature, and the public key, and outputs either valid or invalid. A valid signature can only have been created by someone who knows the private key, but verification requires only the public key — which is shared openly.

![Digital signature flow: signing with private key on the left, verification with public key on the right](media/wiki/digital-signatures/digital-signature-flow.svg "Two-column diagram of the signing and verification process in Bitcoin: a private key and transaction produce a signature through ECDSA or Schnorr; the signature, transaction, and public key pass through verification to output valid or invalid. The private key never leaves the signing side.")

Think of it like a personal wax seal. You press your unique ring (private key) into hot wax on a document. Everyone knows what your seal looks like (public key), so they can verify the seal is genuine. But nobody can forge it because they don't have your ring.

## medium

Digital signatures in Bitcoin provide three fundamental properties:

- **Message authenticity**: The intended recipient can confirm the message was created by the known sender.
- **Non-repudiation**: The sender cannot later deny having created the signature, since only the private key could produce it.
- **Unforgeability**: Without the private key, creating a valid signature for any new message is computationally infeasible.

Bitcoin uses the Elliptic Curve Digital Signature Algorithm (ECDSA) over the secp256k1 curve, and since the Taproot upgrade, Schnorr signatures (BIP 340) as well. Both schemes rely on the hardness of the elliptic curve discrete logarithm problem.

**SIGHASH flags.** A Bitcoin signature does not commit to the entire transaction. Instead, the signer chooses which parts of the transaction the signature covers through a SIGHASH flag, encoded as the last byte of the signature:

- **SIGHASH_ALL (0x01)**: The signature commits to all inputs and all outputs. This is the default and most common flag. Changing any part of the transaction invalidates all signatures.
- **SIGHASH_NONE (0x02)**: The signature commits to all inputs but no outputs. The signer does not care where the funds go. Anyone can fill in the outputs later.
- **SIGHASH_SINGLE (0x03)**: The signature commits to all inputs and exactly one output at the same index as the input being signed. Other outputs can be modified.
- **SIGHASH_ANYONECANPAY (0x80)**: Can be combined with any of the above via bitwise OR. The signature commits to exactly one input (the one being signed) instead of all inputs. This allows others to add or remove inputs from the transaction.

**Signature location.** Signatures are placed in the `scriptSig` field of each input (legacy transactions) or in the witness data (SegWit transactions). They sign the transaction data that excludes their own location — otherwise the signature would change the data it is trying to sign. This circular dependency is resolved by replacing the `scriptSig` with an empty placeholder before signing. In SegWit, the witness data is moved outside the transaction hash, so the signature commits to a serialization that excludes the witness itself (the "commitment" includes `scriptCode`, amount, and sequence).

**SIGHASH type breakdown:**

| Flag | Value | Inputs signed | Outputs signed |
|------|-------|--------------|----------------|
| ALL | 0x01 | All | All |
| NONE | 0x02 | All | None |
| SINGLE | 0x03 | All | One (matching index) |
| ALL \| ANYONECANPAY | 0x81 | One | All |
| NONE \| ANYONECANPAY | 0x82 | One | None |
| SINGLE \| ANYONECANPAY | 0x83 | One | One (matching index) |

## advanced

**Security model.** The standard security notion for digital signatures is Existential Unforgeability under Chosen Message Attack (EUF-CMA). An attacker who can request signatures on arbitrary messages of their choice must still be unable to produce a valid signature on any new message. Both ECDSA and Schnorr satisfy EUF-CMA under the random oracle model and the assumption that the elliptic curve discrete logarithm problem is hard on secp256k1.

**Signature encoding.**

- **ECDSA signatures** use DER (Distinguished Encoding Rules) encoding. A typical signature yields 70-72 bytes, structured as a sequence of two integers `r` and `s`, each 32 bytes, wrapped in ASN.1 headers with type tags and length prefixes. The variable length comes from the fact that DER requires minimal big-endian encoding with no leading zero bytes and a sign byte when the high bit is set.
- **Schnorr signatures** (BIP 340) are a fixed 64 bytes: 32 bytes for the `r` value (the x-coordinate of a public nonce) and 32 bytes for the `s` value (a scalar proof). The fixed size eliminates the malleability vector that plagues ECDSA.

**Transaction malleability.** ECDSA signatures are malleable: a third party can alter the DER encoding of a valid signature without changing its validity. For example, the `s` value can be replaced with its curve order complement `n - s` (low-s vs high-s), or padding bytes can be adjusted within DER rules. Both encodings produce the same mathematical signature but different bytes, resulting in a different transaction identifier (txid). Before SegWit, this allowed an attacker to invalidate unconfirmed transactions by broadcasting a mutated version with a different txid. BIP 66 (strict DER encoding) and BIP 62 (low-s requirement) reduced malleability, and SegWit eliminated it for SegWit inputs by moving the signature into the witness, which is excluded from the txid calculation.

**Signature hash commitment details.** The signature hash algorithm (`SigHash`) in legacy transactions serializes the transaction in a specific format that includes:

- The transaction version (4 bytes)
- The hash of the previous outputs being spent (for all inputs, or one depending on SIGHASH)
- The hash of the sequence numbers
- For the input being signed: the full outpoint (txid + vout), the `scriptCode` (the script of the output being spent), and the amount
- The hash of the output script and values
- The locktime (4 bytes)
- The SIGHASH type (4 bytes, little-endian)

SegWit introduced a new signature hash algorithm (BIP 143) that fixes several design flaws. The key change is that the amount of each output being spent is committed to directly, preventing a class of attacks where a third party modifies the amount after a hardware wallet signs. BIP 143 also simplifies the hash computation by hashing the outputs and inputs only once.

**Future developments.** Schnorr signatures enable several advanced features:

- **Batch verification**: Multiple Schnorr signatures can be verified together faster than verifying each individually. For ECDSA, batch verification is not possible. This reduces block validation time as Schnorr adoption grows.
- **Adaptor signatures**: A cryptographic technique where a signature reveals a secret when published. This powers atomic swaps, Lightning Network protocols, and Discreet Log Contracts (DLCs) without requiring script-based conditional paths.
- **MuSig and MuSig2**: Multi-signature schemes built on Schnorr that aggregate multiple public keys into a single key and multiple signatures into a single signature. A 3-of-3 MuSig looks identical on-chain to a single-signer transaction, improving privacy and reducing fees.
