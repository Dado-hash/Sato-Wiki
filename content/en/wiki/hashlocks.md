---
id: wiki.hashlocks
slug: hashlocks
language: en
category: cryptography
title: Hashlocks
description: A cryptographic condition that requires revealing the preimage of a hash to spend an output, enabling atomic and conditional payments.
coverImage: media/wiki/hashlocks/hashlock-mechanism.svg
difficulty: advanced
readTimeMinutes: 8
tags:
  - Cryptography
  - Hashlocks
  - Script
  - HTLCs
  - Lightning Network
  - Atomic Swaps
related:
  - wiki.hash-functions
  - wiki.timelocks
  - wiki.bitcoin-script
  - wiki.lightning-network
  - wiki.htlcs
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: "BIP 199 — Hashed Time-Locked Contract improvements"
    url: https://github.com/bitcoin/bips/blob/master/bip-0199.mediawiki
    author: Sean Bowe, Daira Hopwood
  - title: "The Bitcoin Lightning Network — Poon-Dryja"
    url: https://lightning.network/lightning-network-paper.pdf
    author: Joseph Poon, Thaddeus Dryja
    publishedAt: 2016-01-14
updatedAt: 2026-05-27T00:00:00Z
---

## base

A hashlock is a spending condition that requires a secret value (called a "preimage") to unlock funds. The condition works by committing to the hash of the secret in the locking script. To spend the output, the spender must reveal the original secret that produces that hash.

The mechanism is simple: Alice locks bitcoin with the hash of a secret R. Only someone who knows R can spend it. Since hashing is one-way, publishing the hash reveals nothing about R. But once R is revealed to claim the funds, anyone can see it. This property — that revealing R is a public proof of secret knowledge — is what makes hashlocks so useful.

When combined with timelocks, a hashlock creates a Hashed TimeLock Contract (HTLC). This is the fundamental building block of the Lightning Network, atomic swaps, and many Bitcoin smart contract patterns. The hashlock ensures the payment goes to the right person if they know the secret; the timelock ensures the sender can reclaim the funds if the secret is never revealed.

![Hashlock mechanism](media/wiki/hashlocks/hashlock-mechanism.svg "A secret preimage is hashed with SHA-256. The hash locks the output. Spending requires revealing the preimage. Combined with a timelock, this forms an HTLC.")

## medium

A hashlock in Bitcoin Script looks like this:
```
OP_SHA256 <hash> OP_EQUALVERIFY OP_CHECKSIG
```

The spender must provide a value that, when hashed with SHA-256, equals the lock hash. After the hash equality is verified, OP_EQUALVERIFY passes and the script proceeds to signature verification. This is the "success path" of an HTLC.

The complete HTLC has two paths:

**Path 1 — Redeem with preimage (success):**
```
OP_SHA256 <hash> OP_EQUALVERIFY OP_CHECKSIG
```
The spender provides: `<sig> <preimage>`

**Path 2 — Refund after timeout (timeout):**
```
<locktime> OP_CHECKLOCKTIMEVERIFY OP_DROP OP_CHECKSIG
```
The sender provides: `<sig>` (after locktime)

The script is typically wrapped in P2SH or P2WSH to hide the complex locking conditions from the sender. The combined script is a conditional payment: the recipient can claim immediately by revealing R, or the sender can reclaim after locktime.

**Atomic swap mechanics.** Hashlocks enable cross-chain atomic swaps. Alice (on Bitcoin) and Bob (on Litecoin) want to trade without trusting each other:

1. Bob generates R, sends H = SHA256(R) to Alice
2. Alice creates a Bitcoin HTLC locked with H: if Bob reveals R within 48 hours, Bob gets Alice's bitcoin; otherwise Alice gets it back
3. Bob creates a Litecoin HTLC locked with the same H: if Alice reveals R within 24 hours, Alice gets Bob's litecoin; otherwise Bob gets it back
4. Alice claims the Litecoin HTLC, revealing R
5. Bob uses the now-public R to claim the Bitcoin HTLC

The timelock asymmetry (48h vs 24h) ensures Alice cannot claim both, and Bob cannot bail out, making the swap atomic.

## advanced

**HTLC in Lightning Network.** Payment channels use HTLCs for multi-hop routing. When Alice pays Dave through Bob and Carol:

1. Each hop creates an HTLC with the same H but decreasing timelocks
2. Alice→Bob: HTLC with hash H, timelock 144 blocks
3. Bob→Carol: HTLC with hash H, timelock 138 blocks
4. Carol→Dave: HTLC with hash H, timelock 132 blocks

If Dave knows R, he claims from Carol, revealing R. Carol then claims from Bob, Bob from Alice. R propagates backward along the path. If any hop fails, the timelocks expire and each hop reclaims their funds independently.

The decreasing timelocks (132 < 138 < 144) are critical: each intermediate node has time to claim their HTLC before their own timelock expires after forwarding the preimage.

**Security properties.** Hashlocks provide atomicity without a trusted third party:

- **Atomicity**: either both parties complete the swap, or neither does. Partial completion is impossible because claiming the receiving side's HTLC automatically reveals R, which enables claiming the sending side's HTLC.
- **Non-custodial**: funds are always controlled by a script, never by a counterparty
- **Trustless**: no intermediary can steal funds, and no party can cheat by refusing to reveal R (the timelock protects the honest party)

**Preimage reuse and privacy.** Using the same R for multiple HTLCs creates a privacy leak: anyone who sees one claim can link all transactions using that R. Modern Lightning Network implementations use different preimages for each payment. Every HTLC should use a unique, cryptographically random preimage.

**Point timelocks (PTLCs).** An advanced alternative to HTLCs uses adaptor signatures instead of hashlocks. Instead of locking with a hash, a PTLC locks with an elliptic curve point. The preimage is not a raw value R but a scalar that, multiplied by G, produces the point. This enables:
- Same privacy properties as hashlocks
- Potential for scriptless scripts (the locking condition looks like a normal key spend)
- Reduced on-chain footprint
- Schnorr-based aggregation

PTLCs are not yet deployed on Bitcoin mainnet but are a known extension for future protocol upgrades, particularly in the context of Taproot and Schnorr signatures.

**OP_SHA256 vs OP_HASH256.** Hashlocks can use either opcode. OP_SHA256 hashes with single SHA-256, producing 32 bytes. OP_HASH256 produces double SHA-256. Single SHA-256 is preferred for HTLCs because it is standard in Lightning Network protocol specifications and compatible with BOLT specifications.
