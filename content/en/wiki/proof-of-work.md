---
id: wiki.proof-of-work
slug: proof-of-work
language: en
category: protocol
title: Proof of Work
description: The mechanism Bitcoin uses to make block history expensive to rewrite and cheap to verify.
difficulty: advanced
readTimeMinutes: 9
tags:
  - Mining
  - Consensus
  - Cryptography
  - Difficulty
related:
  - wiki.mining
  - wiki.sha-256
  - wiki.difficulty-adjustment
  - wiki.blocks
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: Bitcoin Developer Reference - Block Chain
    url: https://developer.bitcoin.org/reference/block_chain.html
    author: Bitcoin.org contributors
  - title: Bitcoin Core proof-of-work implementation
    url: https://github.com/bitcoin/bitcoin/blob/master/src/pow.cpp
    author: Bitcoin Core contributors
updatedAt: 2026-05-26T00:00:00Z
---

## base

Proof of Work is Bitcoin's way of making history costly to rewrite. Miners build candidate blocks and search for a hash that is below the current network target. The search takes many attempts, but any node can check the winning hash quickly.

![Mining loop diagram](media/wiki/proof-of-work/pow-mining-loop.svg "A miner changes the block candidate until its hash is below the target.")

A block is useful only if it follows all consensus rules: its transactions must be valid, it must connect to a previous block, and its proof must satisfy the target. Proof of Work does not replace validation; it gives valid blocks an objective cost.

When nodes see competing histories, they follow the valid chain with the most accumulated work. To change an old transaction, an attacker would need to redo the work for that block and then produce more work than the honest network. Each new block makes that catch-up race harder.

## medium

Bitcoin miners hash the block header, not the whole block from scratch every time. The header contains the previous block hash, the Merkle root of the transactions, a timestamp, the compact target field called `nBits`, and a nonce. Miners vary the nonce, timestamp, transaction set, or coinbase data until the double-SHA-256 hash is low enough.

The target is a threshold. A lower target means fewer acceptable hashes, so the expected number of attempts rises. Because hash output behaves like random data, mining is a probability race: no miner can predict the winning nonce, but miners with more hash rate get more attempts per second.

![Accumulated work diagram](media/wiki/proof-of-work/accumulated-work.svg "Nodes choose the valid branch with the most accumulated proof of work, not simply the first block they heard about.")

Every 2,016 blocks, mainnet retargets difficulty so blocks continue to arrive near a 10 minute average. If the previous period was too fast, the target moves down and mining gets harder. If it was too slow, the target moves up and mining gets easier.

Proof of Work gives Bitcoin two important properties. First, it makes Sybil attacks expensive: votes are weighted by demonstrated work, not by network identities. Second, it makes settlement probabilistic: confirmations are not magic finality, but each confirmation adds work an attacker must outpace.

## advanced

Full nodes validate Proof of Work by deriving the target from `nBits` and checking that the block header hash is less than or equal to that target. They also check that the target is within the allowed proof-of-work limit and that the block satisfies the rest of the consensus rules.

The fork-choice rule is based on accumulated chainwork. A longer-looking branch with easier blocks can lose to a shorter branch with more total work. This is why "longest chain" is better understood as the valid chain with the greatest accumulated Proof of Work.

Difficulty retargeting is deliberately slow and bounded. On Bitcoin mainnet, retargets happen only at difficulty adjustment intervals, using the observed timespan for the previous 2,016 block period and clamping the adjustment. This prevents sudden target jumps while still adapting to long-term hash rate changes.

Proof of Work also defines the cost model for reorgs. A miner can always try to build a private branch, but replacing confirmed history requires that branch to overtake the public chain's accumulated work before the rest of the network extends it further. The economic question is not just "can hashes be produced?" but "can they be produced faster than everyone else while giving up honest mining revenue?"

This is why Proof of Work is not just a mining lottery. It is the bridge between digital consensus and an external resource cost. Nodes remain cheap to run and strict about rules; miners spend energy to propose an ordered history that nodes can reject or accept independently.
