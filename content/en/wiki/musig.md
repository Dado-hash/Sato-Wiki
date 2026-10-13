---
id: wiki.musig
slug: musig
language: en
category: cryptography
title: MuSig2
description: A Schnorr multi-signature protocol in which several signers produce one signature under one aggregate public key, so a shared spend looks like a single-signer spend.
coverImage: media/wiki/musig/musig-hero.svg
difficulty: advanced
readTimeMinutes: 4
tags:
  - MuSig2
  - Schnorr
  - Multisig
  - Taproot
  - Key Aggregation
related:
  - wiki.schnorr-signatures
  - wiki.multisig
  - wiki.taproot
  - wiki.digital-signatures
  - wiki.secp256k1
sources:
  - title: "BIP 327: MuSig2 for BIP340-compatible Multi-Signatures"
    url: https://github.com/bitcoin/bips/blob/master/bip-0327.mediawiki
    author: Jonas Nick, Tim Ruffing, Elliott Jin
  - title: "BIP 340: Schnorr Signatures for secp256k1"
    url: https://github.com/bitcoin/bips/blob/master/bip-0340.mediawiki
    author: Pieter Wuille, Jonas Nick, Tim Ruffing
  - title: "MuSig: Simple Schnorr Multi-Signatures with Applications to Bitcoin"
    url: https://eprint.iacr.org/2018/068
    author: Gregory Maxwell, Andrew Poelstra, Yannick Seurin, Pieter Wuille
  - title: "FROST: Flexible Round-Optimized Schnorr Threshold Signatures"
    url: https://eprint.iacr.org/2020/852
    author: Chelsea Komlo, Ian Goldberg
  - title: Bitcoin Optech - MuSig
    url: https://bitcoinops.org/en/topics/musig/
    author: Bitcoin Optech
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

Multi-signature is a way to lock funds so that several people must agree before they can be spent. Script multisig does this by placing every public key on chain and requiring a set number of signatures. MuSig2 reaches the same goal with a different structure. The signers combine their public keys into one aggregate key, and together they produce one ordinary Schnorr signature for it. The spend looks like a payment from a single key.

That difference matters for size and privacy. A cooperative spend of a MuSig2 output uses one signature, and an observer cannot tell how many people signed or how many keys existed. A script multisig spend reveals the structure of the arrangement, because the script lists the keys and the signatures sit next to them.

MuSig2 is an n-of-n scheme: every signer must take part. It does not let a subset of signers spend alone. Threshold schemes such as FROST cover that case, but they are a separate design, and this entry does not describe them further.

Signing also needs coordination. The signers exchange values in rounds before a signature can be made, so the protocol is less convenient than a script multisig in which each signer signs on its own.

## medium

Aggregation is the first step. A signer cannot simply add the public keys together. If the last signer could choose a key that cancels the others, that signer would control the sum alone. This is the rogue key attack, and MuSig2 is designed to prevent it. Each key is multiplied by a coefficient that comes from hashing the whole list of keys together with that key. No signer can pick a key that cancels the others, because every coefficient depends on the full set. The result is a single public key with the same format as a BIP 340 key.

The signing uses two rounds. In the first round, each signer creates two secret nonces, computes their public points and sends the public values to the others. Once every signer has all the public nonces, each signer computes the same aggregate nonce and produces a partial signature with its key share. The partial signatures are then combined into one Schnorr signature that verifies under the aggregate key. Nobody sees the individual keys or nonces in the final signature.

Nonce reuse is fatal. A Schnorr signature reveals a value that depends on the secret key, the nonce and the message. If the same nonce is used for two different messages under the same key, two equations contain the same unknown and it can be solved, which exposes the signer's key share. BIP 327 says that the signing step must never be executed twice with the same secret nonce, and it suggests erasing that value after use to prevent accidents. Any restart, backup or copied state in a signing session is a place where a nonce could be reused.

Some implementations reject duplicate public keys before aggregation. BIP 327 explains that duplicates are allowed by the algorithm but can reduce security, and that it is often impossible to tell which signer copied a key. Applications can therefore refuse to aggregate duplicates and ask the user to investigate.

## advanced

BIP 327 defines MuSig2 for BIP 340 signatures. Its key aggregation produces an x-only public key that can be placed in a Taproot output, and tweaks can be applied to the aggregate key, for example to commit to a script tree. The on-chain result is a single key-path spend. An observer cannot distinguish it from a single-signer Taproot spend, even though several people control the key. The original MuSig paper showed that the scheme is secure in the plain public-key model, which means signers do not need to prove knowledge of their private keys to a certificate authority before taking part.

Compared with OP_CHECKMULTISIG, the MuSig2 spend is smaller and more private. Script multisig places the N public keys in the script and includes M signatures in the witness, so the size and the structure both grow with the arrangement. The output carries one 32-byte x-only key, and the spend carries one 64-byte Schnorr signature. The privacy difference is equally clear: script multisig reveals the key set and the threshold, while MuSig2 hides the signers entirely.

Accountability is the trade-off. In script multisig, the redeem or witness script names every key and the signatures show which keys approved a spend. This record is useful for audits and for proving who signed. MuSig2 gives that record up, because the chain shows nothing about the individual signers. Optech notes the same balance: MuSig uses less block space and is more private than script multisig, but it requires more interaction among the participants.

MuSig2 is an n-of-n scheme, so it cannot express a 2-of-3 policy by itself. Its signing sessions are stateful, and that state must be handled with care. BIP 327 says that the signing protocol is designed for two communication rounds, and that its nonces are not derived deterministically from the message, so the implementation must securely hold and then discard the secret nonce.

FROST, by contrast, is a threshold signature scheme. It requires cooperation among a threshold number of signers, each holding a share of one private key, and the paper presents it as a way to reduce network overhead during signing. It is a separate design from MuSig2 and should be read as a separate topic.
