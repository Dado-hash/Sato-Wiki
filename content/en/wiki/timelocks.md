---
id: wiki.timelocks
slug: timelocks
language: en
category: cryptography
title: Timelocks
description: Bitcoin primitives that prevent spending of an output until a specified block height or time has been reached.
coverImage: media/wiki/timelocks/timelock-cltv-csv.svg
difficulty: advanced
readTimeMinutes: 8
tags:
  - Cryptography
  - Timelocks
  - Script
  - Lightning Network
  - CLTV
  - CSV
related:
  - wiki.hashlocks
  - wiki.bitcoin-script
  - wiki.lightning-network
  - wiki.payment-channels
  - wiki.commitment-transactions
sources:
  - title: "BIP 65 — OP_CHECKLOCKTIMEVERIFY"
    url: https://github.com/bitcoin/bips/blob/master/bip-0065.mediawiki
    author: Peter Todd
    publishedAt: 2014-10-10
  - title: "BIP 68 — Relative lock-time using consensus-enforced sequence numbers"
    url: https://github.com/bitcoin/bips/blob/master/bip-0068.mediawiki
    author: Mark Friedenbach, BtcDrak, Nicolas Dorier, kinoshitajona
    publishedAt: 2015-05-28
  - title: "BIP 112 — CHECKSEQUENCEVERIFY"
    url: https://github.com/bitcoin/bips/blob/master/bip-0112.mediawiki
    author: BtcDrak, Mark Friedenbach, Eric Lombrozo
    publishedAt: 2015-08-10
updatedAt: 2026-05-27T00:00:00Z
---

## base

Timelocks are conditions that prevent a Bitcoin transaction from being confirmed until a certain point in time. They are the mechanism that enables time-based contracts on Bitcoin, forming the foundation of payment channels, the Lightning Network, and many other smart contract patterns.

There are two types of timelocks in Bitcoin:

**Absolute timelocks.** Lock a transaction or output until a specific block height (e.g., block 800,000) or a specific UNIX timestamp (e.g., January 1, 2027). The transaction cannot be mined before that point, no matter how high the fee.

**Relative timelocks.** Lock a transaction or output for a specific duration measured from when the output was first included in a block. For example, if an output was mined in block 800,000 with a relative timelock of 100 blocks, it cannot be spent until block 800,100.

Both types are enforced at the consensus level — every full node checks timelock conditions before accepting a block. This is what makes timelocks trustworthy without intermediaries.

![CLTV and CSV comparison](media/wiki/timelocks/timelock-cltv-csv.svg "Absolute timelocks (CLTV) lock until a specific height or time. Relative timelocks (CSV) lock for a duration after the output is mined.")

## medium

Timelocks exist at two separate layers: transaction-level and script-level.

**Transaction-level: locktime and sequence.**

Every transaction has a locktime field (4 bytes) that sets an absolute time condition. If locktime is non-zero and less than 500 million, it is interpreted as a block height. If 500 million or greater, it is a UNIX timestamp. A transaction with locktime > 0 is not considered final until its locktime is reached.

The nSequence field in each input enables relative timelocks at the transaction level. BIP 68 redefined the sequence number semantics: if the most significant bit of nSequence is clear (bit 31 = 0), the remaining bits encode a relative locktime. The encoding uses the second-most significant bit to distinguish between blocks (bit 30 = 0) and time (bit 30 = 1, in 512-second granularity).

**Script-level: OP_CHECKLOCKTIMEVERIFY and OP_CHECKSEQUENCEVERIFY.**

CLTV (BIP 65) pushes a value to the stack. If that value is greater than the transaction's locktime, the script fails. This connects script-based conditions to the transaction-level locktime. A typical usage:
```
<locktime> OP_CHECKLOCKTIMEVERIFY OP_DROP OP_CHECKSIG
```

CSV (BIP 112) works similarly but checks against the input's sequence number (BIP 68) instead of the transaction locktime:
```
<relative_blocks> OP_CHECKSEQUENCEVERIFY OP_DROP OP_CHECKSIG
```

## advanced

**Transaction locktime details.** The locktime field uses multiple encoding rules:
- Value 0: immediately final
- Values 1-499,999,999: block height
- Values ≥ 500,000,000: UNIX timestamp
- The median-time-past (MTP) rule requires the locktime to be compared against the median of the last 11 blocks' timestamps, not the block timestamp itself. This prevents miners from manipulating timestamps to prematurely spend timelocked outputs.

**BIP 68 sequence encoding.** When bit 31 = 0, the lower 16 bits encode:
- If bit 30 = 0: relative blocks (16-bit value, max 65535 blocks ≈ 455 days)
- If bit 30 = 1: relative time in 512-second intervals (max 65535 × 512 seconds ≈ 388 days)

This granularity was chosen so that one unit of relative time corresponds to approximately the target block interval (10 minutes × 512/600 ≈ 0.85).

**Use in Lightning Network.** Timelocks are the backbone of Lightning Network security. Every commitment transaction uses both CLTV and CSV:
- The to_local output has a CSV timelock (typically 144 blocks ≈ 24 hours) that prevents the channel funder from immediately spending their balance after closing unilaterally
- HTLC outputs use CLTV to set the absolute timeout for the payment, after which the sender can reclaim the funds if the receiver fails to claim
- The combination ensures that honest parties can always recover their funds, even if the other party goes offline or attempts to publish stale state

**Vaults and time-locked transactions.** More advanced constructions use timelocks for vaults — outputs that impose a timelock before funds can move to their final destination. A typical vault uses:
1. A "hot" key that can trigger a move to a timelocked address
2. The timelocked address imposes a delay
3. During the delay, a "cold" key (stored offline) can cancel the transaction or redirect funds

**Security considerations.** Timelocks are enforced by consensus, but there are nuances:
- Miners control which transactions enter blocks up to timelock constraints
- A miner can theoretically withhold a timelocked transaction until the next block, but cannot include it early
- Reorgs can reset relative timelocks if the output is no longer in the chain
- The MTP rule for CLTV means timelock values can be ±2 hours from wall clock time, which is acceptable for most use cases
