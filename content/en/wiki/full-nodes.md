---
id: wiki.full-nodes
slug: full-nodes
language: en
category: protocol
title: Full Nodes
description: Bitcoin software that independently validates blocks and transactions instead of trusting another party's view of the chain.
coverImage: media/wiki/full-nodes/validation-pipeline.svg
difficulty: advanced
readTimeMinutes: 8
tags:
  - Full Nodes
  - Validation
  - Consensus
  - P2P Network
  - Privacy
related:
  - wiki.consensus-rules
  - wiki.blocks
  - wiki.utxo-model
  - wiki.mempool
  - wiki.peer-to-peer-network
sources:
  - title: Bitcoin Developer Guide - Operating Modes
    url: https://developer.bitcoin.org/devguide/operating_modes.html
    author: Bitcoin.org contributors
  - title: Bitcoin Developer Guide - P2P Network
    url: https://developer.bitcoin.org/devguide/p2p_network.html
    author: Bitcoin.org contributors
  - title: Bitcoin Core validation implementation
    url: https://github.com/bitcoin/bitcoin/blob/master/src/validation.cpp
    author: Bitcoin Core contributors
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
updatedAt: 2026-05-27T00:00:00Z
---

## base

A full node is Bitcoin software that checks the blockchain for itself. It downloads blocks, verifies transactions and proof of work, keeps track of the UTXO set, and rejects data that breaks the rules.

![Full node validation pipeline](media/wiki/full-nodes/validation-pipeline.svg "A full node receives peer data, validates headers and blocks, updates the UTXO set, and relays only acceptable data.")

Running a full node means you do not need to ask a wallet server which blocks or payments are valid. Your node can tell whether a transaction is confirmed, whether a block follows the rules, and whether your wallet is being shown the same chain your software accepts.

Full nodes are not the same as miners. Miners propose blocks by doing proof of work. Full nodes decide whether those blocks are valid according to their own rules. A miner can find a block, but it cannot force honest nodes to accept an invalid one.

## medium

During initial block download, a full node starts from the genesis block and validates the chain up to the current tip. It checks proof of work, block structure, transaction rules, scripts, supply rules, and the order in which outputs are spent and created.

A full node can be archival or pruned. An archival node keeps old block data and can serve historical blocks to other peers. A pruned node still validates the whole chain and keeps the current chainstate, but discards old block files after they are no longer needed locally.

Full nodes also participate in the peer-to-peer network. They discover peers, exchange headers, request blocks, relay valid transactions, and maintain a mempool of unconfirmed transactions that pass local policy. Networking helps data move; validation decides what the node accepts.

The security benefit is independence. Even if many peers lie, a full node can reject invalid blocks and transactions. It needs connectivity to learn about the network, but it does not outsource the question of validity.

## advanced

A full node separates consensus from policy. Consensus rules determine whether a block can be part of the best chain. Policy rules determine what the node relays or keeps in its mempool before mining. A transaction may be non-standard by policy but still valid if a miner includes it in a valid block.

Block validation is layered. The node checks headers and proof of work, validates contextual header rules, downloads block data, verifies transaction structure, checks inputs against the UTXO set, executes scripts, enforces subsidy and fee constraints, and commits the resulting chainstate if the block connects.

Full nodes also make Bitcoin's rule changes conservative. A rule change that makes previously invalid blocks valid requires users and economic actors to run software that accepts the new rules. Otherwise their nodes continue rejecting those blocks. This is why local validation is part of Bitcoin's governance model, not just an implementation detail.

Pruning, assume-valid defaults, and caching can reduce resource use, but they do not change the core responsibility: the node must be able to enforce the consensus rules for the chain it accepts. Performance shortcuts are only acceptable when they preserve the same final validation result.

The full node's quiet job is to be strict. It listens to an open network, but it treats every peer as untrusted until the data checks out locally.
