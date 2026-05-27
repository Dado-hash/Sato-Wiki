---
id: wiki.blockchain
slug: blockchain
language: en
category: protocol
title: Blockchain
description: Bitcoin's linked history of valid blocks selected by accumulated proof of work.
coverImage: media/wiki/blockchain/linked-chain.svg
difficulty: advanced
readTimeMinutes: 8
tags:
  - Blockchain
  - Consensus
  - Chainwork
  - History
related:
  - wiki.blocks
  - wiki.proof-of-work
  - wiki.full-nodes
  - wiki.consensus-rules
  - wiki.block-propagation
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: Bitcoin Developer Guide - Block Chain
    url: https://developer.bitcoin.org/devguide/block_chain.html
    author: Bitcoin.org contributors
  - title: Bitcoin Developer Reference - Block Chain
    url: https://developer.bitcoin.org/reference/block_chain.html
    author: Bitcoin.org contributors
  - title: Bitcoin Core validation implementation
    url: https://github.com/bitcoin/bitcoin/blob/master/src/validation.cpp
    author: Bitcoin Core contributors
updatedAt: 2026-05-27T00:00:00Z
---

## base

The Bitcoin blockchain is a chain of valid blocks. Each block points to the hash of the block before it, so changing an old block would change its hash and break every later link.

![Linked blockchain diagram](media/wiki/blockchain/linked-chain.svg "Blocks link backward by hash, while nodes follow the valid branch with the most accumulated proof of work.")

The blockchain is not just a public database. It is a history selected by rules and proof of work. Nodes reject invalid blocks, and miners compete to extend the valid chain with the most accumulated work.

Confirmations measure how deep a transaction is in that history. A transaction in the latest block has one confirmation. Each new block on top adds another confirmation and makes replacing that transaction more expensive.

## medium

Every block header commits to its parent through the previous block hash. This creates an ordered structure from the genesis block to the current tip. A node can verify the links, the proof of work, and the rules for each block as it builds its local view of the chain.

Temporary splits can happen when different miners find blocks at similar times. Nodes may see competing valid branches. They do not choose by miner identity or by the first branch they heard forever; they track the valid branch with the most accumulated proof of work.

The blockchain also commits to state changes. Blocks contain transactions, transactions consume and create UTXOs, and the node's chainstate changes as blocks are connected or disconnected during a reorganization. The visible chain of blocks and the current UTXO set are two views of the same validated history.

This is why "on-chain" means more than "published somewhere." A transaction is on Bitcoin's chain only when it is included in a valid block that belongs to the node's best valid chain.

## advanced

Bitcoin's blockchain is a hash-linked log plus a validation rule for choosing among competing logs. The hash links make tampering evident. Proof of work makes alternate histories costly. Full-node validation ensures that work only counts when it is attached to blocks that satisfy the consensus rules.

Nodes usually learn headers before full block data. Headers let them compare potential chainwork cheaply, but a header chain is not enough to accept payments. The node must validate the corresponding blocks and transactions before treating that branch as fully usable chain history.

Reorganizations are part of the design. If a node's current tip loses to another valid branch with more accumulated work, the node disconnects blocks back to the fork point and connects the stronger branch. Transactions from disconnected blocks may return to the mempool if they are still valid and not conflicted.

The chain does not provide instant finality. It provides probabilistic settlement: replacing a transaction requires producing a valid alternate branch that overtakes the public branch's accumulated work. The deeper the transaction, the more work must be replaced.

The practical result is a shared ordering system without a central timestamping authority. Every node can independently reconstruct the same best valid history from block data, proof of work, and consensus rules.
