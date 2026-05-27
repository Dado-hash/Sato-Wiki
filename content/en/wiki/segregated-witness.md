---
id: wiki.segregated-witness
slug: segregated-witness
language: en
category: protocol
title: Segregated Witness
description: A protocol upgrade that separates transaction signatures from the data used to compute the transaction ID, solving malleability and increasing block capacity.
coverImage: media/wiki/segregated-witness/segwit-hero.svg
difficulty: advanced
readTimeMinutes: 10
tags:
  - SegWit
  - Protocol Upgrade
  - Scalability
  - Malleability
  - Transactions
related:
  - wiki.transactions
  - wiki.blocks
  - wiki.bitcoin-script
sources:
  - title: "BIP 141 — Segregated Witness (Consensus layer)"
    url: https://github.com/bitcoin/bips/blob/master/bip-0141.mediawiki
    author: Eric Lombrozo, Johnson Lau, Pieter Wuille
    publishedAt: 2015-12-21
  - title: "BIP 143 — Transaction Signature Verification for Segregated Witness"
    url: https://github.com/bitcoin/bips/blob/master/bip-0143.mediawiki
    author: Johnson Lau, Pieter Wuille
    publishedAt: 2016-01-13
  - title: "BIP 147 — Dealing with dummy stack element malleability"
    url: https://github.com/bitcoin/bips/blob/master/bip-0147.mediawiki
    author: Johnson Lau
    publishedAt: 2016-03-07
  - title: "BIP 148 — Mandatory activation of Segregated Witness"
    url: https://github.com/bitcoin/bips/blob/master/bip-0148.mediawiki
    author: Shaolin Fry
    publishedAt: 2017-03-03
  - title: "Bitcoin Developer Guide — Segregated Witness"
    url: https://developer.bitcoin.org/devguide/segwit_wallet_dev.html
    author: Bitcoin.org contributors
updatedAt: 2026-05-27T00:00:00Z
---

## base

Segregated Witness (SegWit) is a protocol upgrade activated on the Bitcoin network in August 2017. It changes how transaction data is structured by separating the signature — the "witness" data — from the rest of the transaction. Before SegWit, signatures were part of the data that determined a transaction's identifier (txid). Anyone could slightly modify a signature before the transaction was confirmed, changing its txid without invalidating it — a problem called transaction malleability. SegWit solves this by putting witness data in a separate structure that does not affect the txid. It also increases the block's effective capacity because witness data counts less toward the block size limit.

![Segregated Witness separation](media/wiki/segregated-witness/segwit-hero.svg "Signatures are lifted out of the transaction data, leaving the txid non-malleable.")

## medium

Transaction malleability was not just a theoretical concern. When the Lightning Network team designed payment channels, they needed each transaction's txid to be predictable before confirmation so the next transaction could reference it. If an attacker could change the txid, the channel could be disrupted. SegWit solved this by removing the malleable signatures from the txid computation.

The upgrade introduced a new transaction format. The old format includes signatures inside each input's `scriptSig` field. The new format places a marker byte (`0x00`) and a flag byte (`0x01`) after the version field, keeps the `scriptSig` empty, and appends the witness data as a separate section after the outputs. Nodes that understand SegWit validate the witness data. Old nodes see the marker and flag as a valid but trivially spendable transaction and ignore the witness data — this design makes SegWit a soft fork, meaning old nodes still follow the same chain.

![Legacy vs SegWit transaction structure](media/wiki/segregated-witness/segwit-structure.svg "The SegWit format adds a marker, flag, and witness section while keeping the core transaction data compatible.")

SegWit also introduced the concept of block weight, measured in weight units (WU). The old 1 MB limit was replaced by a 4,000,000 WU limit. Non-witness data counts as 4 WU per byte, while witness data counts as 1 WU per byte. This increases the effective block capacity to roughly 1.6–2 MB for typical transactions and gives wallets an economic incentive to adopt SegWit outputs, since their transactions are smaller and pay lower fees.

Two address formats were introduced: native SegWit addresses starting with `bc1` (P2WPKH and P2WSH), and nested SegWit addresses (P2SH-P2WPKH and P2SH-P2WSH) that wrap the SegWit output inside a legacy pay-to-script-hash output for backwards compatibility with wallets that had not yet upgraded.

Activation required 95% of blocks in a 2,016-block retarget period to signal readiness, using BIP-9 version bits. When signaling fell short, the community activated a user-activated soft fork (UASF, BIP-148) as a contingency, which ensured the upgrade activated on schedule.

## advanced

BIP-141 defines the core SegWit specification. The witness structure is a serialized list of witness data, where each transaction input has a corresponding stack of witness items. The witness program, carried in the `scriptPubKey` of SegWit outputs, consists of a version byte (currently `0x00`) followed by the program data. This script versioning system allows future upgrades such as Taproot, which used witness version `0x01`.

The weight formula for transactions is:

- `weight = base_size × 3 + total_size`
- `base_size` is the serialized transaction size **without** witness data
- `total_size` is the serialized transaction size **including** witness data
- A block must satisfy `total_weight ≤ 4,000,000 WU`

Because witness data is discounted by 75 % relative to base data (1 witness byte = 1 WU vs 1 base byte = 4 WU), SegWit transactions are cheaper per byte to include in a block. This creates an economic incentive for wallets to adopt SegWit outputs.

The coinbase transaction commits to all witness data through a special `OP_RETURN` output. The commitment is the root of a Merkle tree of **wtxids** rather than txids. The wtxid commits to all transaction data including witness, while the txid commits only to non-witness data. This allows full nodes to verify that the witness data has not been tampered with while preserving the old txid for backwards compatibility.

SegWit also solved the quadratic hashing problem. In the legacy system, verifying all signature operations in a block required O(n²) hashing because each signature check could hash a potentially large amount of transaction data multiple times. SegWit transaction validation limits the data that needs to be hashed to the specific input being signed, making signature verification linear.

Four address formats exist:

- **P2WPKH** (native SegWit, `bc1q...`): Pay-to-Witness-Public-Key-Hash, for single-key spends.
- **P2WSH** (native SegWit, `bc1q...`): Pay-to-Witness-Script-Hash, for complex scripts.
- **P2SH-P2WPKH** (nested SegWit, `3...`): P2WPKH inside a legacy P2SH wrapper.
- **P2SH-P2WSH** (nested SegWit, `3...`): P2WSH inside a legacy P2SH wrapper.

Activation used BIP-9 version bits with bit 1. Miners signaled readiness by setting bit 1 in the block version field. Once 95 % of blocks in a 2,016-block signalling window signalled, a grace period began and SegWit activated after roughly two weeks. When signalling stalled, BIP-148 (UASF) was deployed: nodes enforced that blocks after August 1, 2017 must signal for SegWit, forcing miners to activate or risk a chain split.
