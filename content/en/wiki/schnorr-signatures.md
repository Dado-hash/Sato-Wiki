---
id: wiki.schnorr-signatures
slug: schnorr-signatures
language: en
category: cryptography
title: Schnorr Signatures
description: The linear signature scheme introduced in Taproot that enables signature aggregation, batch verification, and more efficient multi-signatures.
coverImage: media/wiki/schnorr-signatures/schnorr-signing.svg
difficulty: advanced
readTimeMinutes: 9
tags:
  - Cryptography
  - Schnorr
  - Signatures
  - Taproot
  - BIP 340
related:
  - wiki.ecdsa
  - wiki.digital-signatures
  - wiki.taproot
  - wiki.multisig
  - wiki.public-keys
sources:
  - title: "BIP 340 - Schnorr Signatures for secp256k1"
    url: https://github.com/bitcoin/bips/blob/master/bip-0340.mediawiki
    author: Pieter Wuille, Jonas Nick, Tim Ruffing
  - title: "BIP 341 - Taproot: SegWit version 1 spending rules"
    url: https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki
    author: Pieter Wuille, Jonas Nick, Anthony Towns
  - title: "BIP 342 - Taproot Script"
    url: https://github.com/bitcoin/bips/blob/master/bip-0342.mediawiki
    author: Pieter Wuille, Jonas Nick, Anthony Towns
updatedAt: 2026-05-27T00:00:00Z
---

## base

Schnorr signatures are a newer type of signature in Bitcoin, added in 2021 with the Taproot upgrade. They are simpler, smaller, and have a special property called linearity — you can add signatures together.

A Schnorr signature is always 64 bytes fixed, compared to ECDSA signatures which range from 70 to 72 bytes in DER encoding. The fixed size simplifies implementation and makes predictable the space consumed in each input.

The linearity property is what makes Schnorr signatures powerful. Because signatures can be added, a group of signers can produce a single signature that looks identical to a signature made by one person. This enables three main benefits:

- **Multi-signatures that look like single signatures.** A 3-of-5 multisignature wallet produces the same 64-byte signature as a single-key wallet. An observer cannot tell how many people signed.
- **Batch verification.** Verifying 1000 signatures together is roughly 2x faster than verifying each one individually.
- **Privacy.** Multisignature outputs on-chain are indistinguishable from single-signature outputs.

Think of it like a group signing pen. When a committee needs to sign a document, each member touches the same pen. The resulting signature is one cohesive mark that proves the entire group approved — not a collection of individual signatures that reveals how many people were involved.

![Schnorr signature scheme](media/wiki/schnorr-signatures/schnorr-signing.svg "Schnorr signing uses a nonce commitment R and a challenge hash e. The signature (R, s) is 64 bytes. Multiple signatures can be aggregated into one.")

## medium

Schnorr signing works with three components: a private key d, a public key Q = d*G, and a message m. The signer picks a random nonce k, computes a commitment R = k*G, then derives a challenge e = H(R || Q || m). The signature scalar is s = k + e*d. The full signature is the pair (R, s), exactly 64 bytes.

Verification is straightforward. The verifier computes the same challenge e = H(R || Q || m) and checks that s*G = R + e*Q. If the equation holds, the signature is valid. Unlike ECDSA, Schnorr does not support public key recovery — the public key must be provided separately.

The BIP 340 variant used in Bitcoin specifies x-only public keys: only the x-coordinate of the public key is transmitted, and the y-coordinate is implicitly even. This saves one byte per public key and avoids computing a square root during verification. If the actual y-coordinate is odd, the private key is negated to make it even.

**Key aggregation with MuSig.** MuSig is a multi-signature protocol that allows multiple parties to produce a single Schnorr signature. Each participant contributes a key share and a nonce share. The aggregate public key is a weighted sum of all participants' public keys. The aggregate nonce and signature are computed through an interactive signing process:

1. Each participant generates a nonce commitment and broadcasts it.
2. Everyone computes the aggregate nonce R from all commitments.
3. Each participant computes their partial signature s_i.
4. The partial signatures are summed to produce the aggregate s.

The final signature (R, s) is identical in structure to a single-party Schnorr signature. No one observing the blockchain can determine that multiple signers were involved.

**Batch verification.** Schnorr signatures support batch verification through the linearity property. Given n signatures (R_i, s_i) on messages m_i with public keys Q_i, a verifier can check a random linear combination instead of checking each equation individually. This reduces the number of expensive elliptic curve point multiplications from 2n to approximately n + 1, yielding a roughly 2x speedup. The random coefficients prevent a malicious signer from crafting signatures that pass batch verification but would fail individually.

## advanced

**BIP 340 design decisions.** BIP 340 specifies the Schnorr signature variant used in Bitcoin. It differs from textbook Schnorr in several ways:

- **X-only public keys.** Only the x-coordinate of the public key is used. This reduces public key size from 33 bytes to 32 bytes. During verification, the implementation assumes the y-coordinate is even. If a key has an odd y-coordinate, the key holder negates their private key before signing, which flips the y-coordinate to even. This trick avoids the need for a quadratic residue check during verification and eliminates a conditional branch.
- **Challenge includes public key.** The challenge hash is e = H(R || Q || m), not e = H(R || m). Including Q in the hash prevents key cancellation attacks in multi-signature settings. Without it, an attacker in a multi-signature scheme could choose a public key that cancels another participant's key, producing an aggregate key they control entirely.
- **Nonce generation.** The signer must never reuse or reveal the nonce k. If k is reused with different messages, the private key can be recovered by solving two equations. If k is known, the private key can be computed directly. BIP 340 recommends deterministic nonce generation using the private key and message as input to a pseudorandom function, which eliminates the risk of RNG failure.

**MuSig, MuSig2, and FROST.** Three multi-signature protocols build on Schnorr linearity:

- MuSig (2018) requires three communication rounds: one for key aggregation, one for nonce commitment, one for partial signatures. It is secure under the plain public key model and does not require proof of possession for key registration.
- MuSig2 (2020) reduces the protocol to two rounds by sending two nonce commitments per signer instead of one. This makes it practical for signing in environments with limited interactivity, such as Lightning Network channels.
- FROST (2020) is a threshold signature scheme. Instead of requiring all participants to sign, any t-of-n subset can produce a valid signature. FROST uses a distributed key generation protocol where each participant holds a share of the private key. Partial signatures from t participants are combined into a single Schnorr signature. This is the foundation for threshold wallets and distributed custody.

**Adaptor signatures.** Schnorr adaptor signatures extend the scheme with a hidden value called an adaptor. Given an adaptor t, a signer can produce a pre-signature that looks like a regular signature but is not yet valid. The pre-signature can be turned into a valid signature by revealing t. This enables:

- Atomic swaps: Two parties exchange adaptor signatures across different blockchains. When one signature is completed on-chain, the adaptor is revealed, allowing the other party to complete their signature.
- Discreet Log Contracts (DLCs): Oracle-signed outcomes are encoded as adaptor signatures. The winning party completes the signature using the oracle's attestation.
- Payment pools: Participants create adaptor signatures that enforce payout conditions without requiring on-chain transactions unless someone cheats.

**Cross-input signature aggregation.** Schnorr signatures can potentially be aggregated across different inputs of the same transaction. Instead of each input carrying its own 64-byte signature, all inputs could share a single aggregate signature. This would reduce transaction size significantly — a 10-input transaction would save over 500 bytes. Cross-input aggregation is not yet implemented in Bitcoin and requires consensus changes. It is an active area of research, with proposals for half-aggregation (aggregate signatures into a single 32-byte proof) being explored.

**Security model.** Schnorr signatures are provably secure under the discrete logarithm assumption in the random oracle model (ECDLP). This means that if an attacker can forge a Schnorr signature, they can also compute discrete logarithms — a problem considered computationally infeasible for the secp256k1 curve. The proof requires that the hash function behaves as a random oracle, which is a strong idealization, but the practical security margin is considered sufficient by the cryptographic community. By contrast, ECDSA lacks a proof of security under the same assumptions and relies on different algebraic properties.

Schnorr also provides strong unforgeability under chosen message attacks (SUF-CMA). Even if an attacker obtains signatures on arbitrary messages of their choice, they cannot produce a signature on a new message. The non-malleability of Schnorr signatures is inherent: given a valid signature (R, s), an attacker cannot produce a different valid signature for the same message, unlike ECDSA where signatures are malleable by negating s or using different DER encodings.
