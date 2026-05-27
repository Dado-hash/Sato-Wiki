---
id: wiki.forks-and-soft-forks
slug: forks-and-soft-forks
language: en
category: protocol
title: Forks and Soft Forks
description: How the Bitcoin network splits under different rule sets, and why soft forks are the preferred upgrade mechanism.
coverImage: media/wiki/forks-and-soft-forks/forks-hero.svg
difficulty: advanced
readTimeMinutes: 8
tags:
  - Forks
  - Soft Forks
  - Hard Forks
  - Consensus
  - Upgrades
related:
  - wiki.consensus-rules
  - wiki.blocks
  - wiki.full-nodes
  - wiki.proof-of-work
  - wiki.blockchain
sources:
  - title: "Bitcoin Developer Guide - Soft Fork Activation"
    url: https://developer.bitcoin.org/devguide/soft_forks.html
    author: Bitcoin Core contributors
  - title: BIP-9 — Version bits with timeout and delay
    url: https://github.com/bitcoin/bips/blob/master/bip-0009.mediawiki
    author: Pieter Wuille
  - title: BIP-8 — Version bits with lock-in by height
    url: https://github.com/bitcoin/bips/blob/master/bip-0008.mediawiki
    author: Shaolin Fry
  - title: BIP-148 — Mandatory activation of SegWit
    url: https://github.com/bitcoin/bips/blob/master/bip-0148.mediawiki
    author: Shaolin Fry
  - title: BIP-341 — Taproot
    url: https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki
    author: Pieter Wuille, Jonas Nick, Anthony Towns
  - title: Soft fork activation terminology
    url: https://bitcoinops.org/en/topics/soft-fork-activation/
    author: Bitcoin Optech
updatedAt: 2026-05-27T00:00:00Z
---

## base

A fork happens when the Bitcoin network splits into two groups that follow different rules. Forks can be temporary or permanent.

Temporary forks occur naturally when two miners find valid blocks at almost the same time. Nodes see two competing chains and follow whichever accumulates more proof of work. One branch is abandoned once a new block extends one side further. This is not a rule change — it is a normal part of how Bitcoin reaches consensus.

Permanent forks happen when the network's rules change. A soft fork tightens the rules, so old nodes still see every new block as valid. A hard fork relaxes the rules, so old nodes see some new blocks as invalid.

![Fork types overview](media/wiki/forks-and-soft-forks/forks-hero.svg "A blockchain splits at a common block into a backward-compatible soft fork and a non-backward-compatible hard fork.")

In a soft fork, old nodes remain on the same chain as upgraded nodes because the new rules accept a subset of what old rules accepted. In a hard fork, old and new nodes diverge permanently unless the old nodes upgrade.

## medium

Soft forks change the consensus rules in a backward-compatible way. A previously valid block or transaction becomes invalid under the new rules, but everything the new rules accept is also valid under the old rules. This means old nodes still see all new blocks as valid and follow the same chain.

### Activation mechanisms

Soft fork activation has evolved through several BIP standards:

**BIP-9** introduced version bits signaling. Miners set a bit in the block header version field to signal readiness. Once 1914 out of 2016 blocks (95% of a difficulty period) signal, the soft fork locks in and activates after a grace period. BIP-9 is now retired.

**BIP-8** improved on BIP-9 by adding a mandatory lock-in height. If signaling has not reached the threshold, the soft fork still activates at a predefined block height. This adds a guaranteed activation deadline.

**Speedy Trial** was used for Taproot activation. It reduced the signaling window to 2016 blocks (about two weeks) with a 90% threshold. If the threshold was met, the soft fork locked in and activated months later.

### Miner-activated vs user-activated soft forks

Most soft forks are miner-activated soft forks (MASF): miners signal readiness, and when enough signal, the rules change. This relies on miners to voluntarily enforce the new rules.

A user-activated soft fork (UASF) activates at a predetermined time regardless of miner signaling. The best-known example is BIP-148, which mandated SegWit signaling from August 1, 2017. Nodes running BIP-148 would reject blocks from miners who did not signal SegWit readiness. This created a reorg risk for non-signaling miners and catalyzed the SegWit activation.

### Notable soft forks

**BIP-30** (duplicate coinbase): prevents two coinbase transactions with the same txid from existing in different blocks.

**BIP-34** (height in coinbase): requires the block height in the coinbase input, making each coinbase unique and providing an ordering anchor.

**BIP-66** (strict DER signatures): enforces canonical DER encoding for ECDSA signatures, removing malleability vectors.

**BIP-65** (CLTV): adds OP_CHECKLOCKTIMEVERIFY for absolute timelocks.

**BIP-68/112/113** (CSV): adds relative locktime via sequence numbers and OP_CHECKSEQUENCEVERIFY, enabling payment channels and the Lightning Network.

**BIP-141** (SegWit): segregated witness, fixing transaction malleability and increasing block capacity through the weight system.

**BIP-341/342** (Taproot): Schnorr signatures, MAST script commitments, and a new Script version, making all outputs look identical by default.

### Hashrate requirements

A soft fork needs more than 50% of hashrate to enforce its rules, because miners with less than half the hashrate could still extend a chain with blocks that violate the new rules. In practice, the community targets much higher thresholds: 95% under BIP-9 and 90% under Speedy Trial. Lower thresholds increase the risk of a persistent reorg during activation.

## advanced

### Technical comparison

The key technical distinction between soft forks and hard forks is what happens to the validity of blocks:

A soft fork makes a previously **valid** block **invalid**. It restricts the set of acceptable blocks. Any block that satisfies the new, tighter rules also satisfies the old rules, so unupgraded nodes see the same chain.

A hard fork makes a previously **invalid** block **valid**. It expands the set of acceptable blocks. An unupgraded node rejects blocks that take advantage of the new rules, causing a permanent chain split unless every node upgrades.

![Soft fork vs hard fork comparison](media/wiki/forks-and-soft-forks/soft-hard-fork.svg "Left: a soft fork tightens rules but old nodes still accept new blocks. Right: a hard fork relaxes rules and old nodes reject new blocks.")

### Why Bitcoin Core prefers soft forks

Bitcoin Core has a strong institutional preference for soft forks because they preserve backward compatibility. Old nodes do not need to upgrade to remain on the correct chain. This minimizes disruption, reduces coordination costs, and prevents forced chain splits.

Hard forks create two competing networks with the same history up to the fork point. The community must decide which chain has the valid bitcoin, which is a social and economic decision, not a technical one. This is why hard forks are reserved for extreme circumstances or when a clean break is the explicit goal.

### Economic incentives and node sovereignty

Miner signaling is used in soft fork activation because miners must enforce the new rules for the fork to be secure. If a majority of hashrate does not enforce the new rules, a minority chain could outrun it. However, miners do not decide what the rules are — full nodes do. A node operator who disagrees with a soft fork can choose to not upgrade, and their node will still follow the longest valid chain under the old rules.

This is the principle of economic majority: the rules of Bitcoin are ultimately enforced by the nodes that economic actors (exchanges, merchants, users) run. If a soft fork is opposed by a significant economic majority, it will not be adopted regardless of miner signaling.

### Historical hard forks

**SegWit2x (2017):** A proposed hard fork to increase the block size limit to 2 MB. It was planned as part of the New York Agreement but was called off in November 2017 due to insufficient community consensus. The SegWit2x chain never launched.

**Bitcoin Cash (2017):** A hard fork that increased the block size limit to 8 MB and removed SegWit. It split from Bitcoin at block 478,558 and created a separate asset. Bitcoin Cash later hard-forked again into Bitcoin ABC and Bitcoin SV.

**Bitcoin SV (2018):** A hard fork from Bitcoin Cash that further increased block size limits to 128 MB and restored the original Satoshi opcodes. It represents an extreme interpretation of the "big block" philosophy.

### Activation mechanism details

BIP-9 used the block header version field as a bitfield. Miners set bit N to signal support for BIP N. During each difficulty period (2016 blocks), if 1914 out of 2016 blocks (95%) had the bit set, the soft fork locked in. After a grace period of another 2016 blocks, it activated. If the threshold was not met before a timeout, the bit was marked as FAILED and could not be reused.

BIP-8 added a mechanism called "lock-in by height." If the signaling threshold is met before the timeout height, the soft fork activates as in BIP-9. If the threshold is not met, the soft fork still activates at the timeout height — miners can no longer block activation. The LOT (Lock-in On Timeout) parameter controls this behavior.

Speedy Trial, used for Taproot, compressed the timeline significantly. The signaling period was only 2016 blocks (about two weeks) with a 90% threshold (1816 out of 2016). The threshold was met within a single period, triggering lock-in and activation months later at block 709,632.

### Reorg risk during activation

During soft fork activation, there is a brief window where a reorg could occur if a minority hashrate chain continues under old rules while the majority moves to new rules. BIP-148 (UASF for SegWit) explicitly created this risk as leverage: miners who did not signal SegWit readiness by August 1, 2017 risked having their blocks rejected by UASF nodes, which could trigger a reorg of their chain. This economic pressure pushed the mining community to activate SegWit through the existing BIP-9 mechanism.

The principle is that soft fork activation is not just a technical process but an economic one. Nodes enforce rules. Miners extend chains under those rules. If users and economic actors enforce new rules through upgraded nodes, miners must follow or risk building on a chain that economic actors reject.
