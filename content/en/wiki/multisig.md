---
id: wiki.multisig
slug: multisig
language: en
category: cryptography
title: Multisignature
description: A Bitcoin script feature that requires multiple signatures from independent key holders to authorize a transaction.
coverImage: media/wiki/multisig/multisig-m-of-n.svg
difficulty: advanced
readTimeMinutes: 8
tags:
  - Cryptography
  - Multisig
  - Security
  - Script
related:
  - wiki.digital-signatures
  - wiki.ecdsa
  - wiki.schnorr-signatures
  - wiki.bitcoin-addresses
  - wiki.bitcoin-script
  - wiki.hashlocks
sources:
  - title: "BIP 11 — M-of-N Standard Transactions"
    url: https://github.com/bitcoin/bips/blob/master/bip-0011.mediawiki
    author: Gavin Andresen
    publishedAt: 2011-10-18
  - title: "BIP 16 — Pay to Script Hash"
    url: https://github.com/bitcoin/bips/blob/master/bip-0016.mediawiki
    author: Gavin Andresen
    publishedAt: 2012-01-03
  - title: "Mastering Bitcoin - Chapter 4"
    url: https://github.com/bitcoinbook/bitcoinbook/blob/develop/ch04.asciidoc
    author: Andreas M. Antonopoulos
updatedAt: 2026-05-27T00:00:00Z
---

## base

Multisignature (multisig) is a Bitcoin feature that requires multiple independent signatures to authorize a payment. Instead of a single key controlling funds, an M-of-N multisig setup requires M out of N possible signers to agree. A 2-of-3 multisig, for example, needs any 2 out of 3 key holders to sign before the funds can move.

This is useful for many scenarios: a company might use 2-of-3 with the CEO, CFO, and treasurer each holding one key — any two can authorize payments, but no individual can act alone. Families use 2-of-3 between parents and a lawyer for inheritance planning. Technical users use multisig to distribute risk across multiple devices or locations.

Multisig is enforced by Bitcoin Script using the OP_CHECKMULTISIG opcode. The locking script contains all N public keys and the required threshold M. Each spender provides M signatures. The script verifies that the signatures correspond to some subset of the listed public keys.

![Multisignature M-of-N setup](media/wiki/multisig/multisig-m-of-n.svg "A 2-of-3 multisig requires any two of three participants to sign. The locking script lists all three public keys and the threshold.")

## medium

The core multisig script pattern is:
```
OP_M <pubKey1> <pubKey2> ... <pubKeyN> OP_N OP_CHECKMULTISIG
```

This is called "bare multisig" and is rarely used directly today due to P2SH and P2WSH wrapping. Instead, the script is hashed and the hash is used as the address:

**P2SH multisig.** The locking script is `OP_HASH160 <scriptHash> OP_EQUAL`. The redeem script (the full multisig script) is revealed in the spending transaction. This hides the multisig parameters from the sender and reduces transaction fees for the creator.

**P2WSH multisig.** SegWit version of P2SH multisig. The witness script replaces the redeem script. Benefits include lower fees (witness discount), transaction malleability fix, and larger script capacity (10,000 bytes vs 520 bytes for the redeem script).

**Taproot multisig.** Schnorr signatures enable key aggregation. Instead of listing N public keys on-chain, Taproot combines them into a single public key using MuSig2. The result is indistinguishable from a single-signature transaction, providing both privacy and cost savings.

The number of signatures verified per input counts toward the block's sigop limit: one OP_CHECKMULTISIG counts as N sigops (one per public key). This is significant because blocks are limited to 80,000 sigops before SegWit and 800,000 after SegWit (weighted).

## advanced

**OP_CHECKMULTISIG bug.** The opcode pops an extra element (the first stack item) and discards it due to a bug in the original implementation. Unlocking scripts must therefore push an OP_0 (or any dummy value) before the actual signatures:
```
OP_0 <sig1> <sig2> ... <sigM>
```

This bug is now consensus-enforced and cannot be fixed without a hard fork. All legacy multisig outputs require the dummy element.

**Key aggregation with MuSig.** BIP 327 (MuSig2) is a multi-signature scheme that allows N parties to produce a single Schnorr signature that verifies against a single aggregated public key. The protocol requires three communication rounds:
- Round 1: Each party sends a nonce commitment
- Round 2: Each party sends their nonce
- Round 3: Each party sends their partial signature

The aggregated signature is a single 64-byte Schnorr signature, indistinguishable from a regular single-signer signature. This provides:
- **Cost savings**: one signature instead of N in the witness
- **Privacy**: the spending conditions look like a regular key-path spend
- **Efficiency**: single verification operation

**Threshold signatures (FROST).** While MuSig requires all signers to participate (it is N-of-N), FROST (Flexible Round-Optimized Schnorr Threshold Signatures) enables t-of-n threshold Schnorr signing with two rounds. FROST is not yet deployed in Bitcoin mainnet but is under active research and development.

**Security model.** Multisig security depends on the independence of the key holders. Common threats:
- Shared signing device: if two keys are on the same device, a compromise of that device breaks the multisig protection
- Social engineering: an attacker who convinces M-1 key holders to sign a malicious transaction can succeed
- Collusion: if M key holders collude, the remaining N-M holders cannot prevent spending

**Practical implementations.** Modern multisig wallets use BIP 48 to define derivation paths for multisig accounts, and BIP 174 (PSBT — Partially Signed Bitcoin Transactions) to coordinate signing between co-signers in a standardized format. PSBT allows each signer to independently review and sign the transaction before broadcasting.
