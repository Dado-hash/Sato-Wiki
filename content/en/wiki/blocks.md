---
id: wiki.blocks
slug: blocks
language: en
category: protocol
title: Blocks
description: The batches of transactions miners propose and full nodes validate as updates to Bitcoin's shared history.
coverImage: media/wiki/blocks/block-anatomy.svg
difficulty: advanced
readTimeMinutes: 8
tags:
  - Blocks
  - Mining
  - Consensus
  - Merkle Trees
related:
  - wiki.blockchain
  - wiki.proof-of-work
  - wiki.transactions
  - wiki.merkle-trees
  - wiki.mining
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: Bitcoin Developer Reference - Block Chain
    url: https://developer.bitcoin.org/reference/block_chain.html
    author: Bitcoin.org contributors
  - title: Bitcoin Developer Guide - Block Chain
    url: https://developer.bitcoin.org/devguide/block_chain.html
    author: Bitcoin.org contributors
  - title: BIP 141 - Segregated Witness
    url: https://github.com/bitcoin/bips/blob/master/bip-0141.mediawiki
    author: Eric Lombrozo, Johnson Lau, Pieter Wuille
updatedAt: 2026-05-27T00:00:00Z
---

## base

A block is a package of transactions proposed by a miner. It links to the previous block, proves that work was done, and asks nodes to accept a new update to Bitcoin's transaction history.

![Block anatomy diagram](media/wiki/blocks/block-anatomy.svg "A block contains an 80-byte header, a coinbase transaction, and a list of transactions committed by the Merkle root.")

Every block has two main parts: a header and a transaction list. The header contains the previous block hash, a Merkle root that commits to the transactions, a timestamp, the difficulty target in compact form, and a nonce used during mining.

The first transaction is the coinbase transaction. It creates the block subsidy and collects the fees from the other transactions in the block. Nodes only accept the block if the coinbase pays no more than the rules allow and every included transaction is valid.

## medium

The block header is small, but it carries the commitments nodes need. The previous block hash links the block to its parent. The Merkle root commits to the ordered transaction list. The `nBits` field expresses the proof-of-work target, and the nonce is one of the values miners vary while searching for a valid header hash.

Blocks also have size constraints. Since SegWit, the main consensus limit is block weight, which counts base transaction data more heavily than witness data and caps a block at 4,000,000 weight units. This lets nodes reason about validation and relay costs while preserving compatibility with older serialization rules.

A valid proof of work is not enough. Full nodes check the block's structure, proof, timestamp rules, transaction validity, coinbase amount, Merkle commitment, and contextual rules that depend on chain history. If any rule fails, the block is invalid even if its hash is below the target.

Blocks provide settlement by ordering transactions. If two transactions conflict, a valid block can include at most one of them. Later blocks build on that choice, increasing the work required to replace it with a different history.

## advanced

Connecting a block is a consensus state transition. A node validates the header, checks that the parent is known and acceptable, verifies all transaction inputs against the current UTXO set, executes scripts, spends consumed outputs, creates new outputs, and records the resulting chainstate.

Some rules are block-wide rather than transaction-local. The coinbase must be first. The Merkle root must match the block's transactions. The coinbase value must not exceed subsidy plus fees. SegWit blocks must commit to witness data through the coinbase witness commitment when witness transactions are present.

Blocks also carry contextual constraints. Timestamps are compared against median-time-past and cannot drift too far into the future according to network-adjusted time policy. Difficulty changes only at retarget intervals on mainnet. Coinbase outputs require maturity before they can be spent, reducing the damage from short reorganizations.

A block can be stored, relayed, mined on, or rejected depending on its validation state. Headers can arrive before full blocks, and a node may know about more header work than it has fully validated block data for. The best chain is not merely the branch with headers; it is the best fully valid branch the node can connect under its rules.

Blocks are therefore both data containers and rule checkpoints. They batch transactions, commit to ordering, carry proof of work, and transform the UTXO set one valid step at a time.
