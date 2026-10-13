---
id: wiki.spv-and-pruning
slug: spv-and-pruning
language: en
category: protocol
title: SPV and Pruned Nodes
description: Two ways to use Bitcoin without storing the whole chain, a light client that checks headers and a pruned full node that validates everything but keeps only recent block files.
difficulty: base
readTimeMinutes: 4
tags:
  - SPV
  - Pruning
  - Light Clients
  - Merkle Proofs
related:
  - wiki.full-nodes
  - wiki.merkle-trees
  - wiki.proof-of-work
  - wiki.software-wallets
  - wiki.peer-to-peer-network
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: Bitcoin Developer Guide - Operating Modes
    url: https://developer.bitcoin.org/devguide/operating_modes.html
    author: Bitcoin.org contributors
  - title: "BIP 37: Connection Bloom filtering"
    url: https://github.com/bitcoin/bips/blob/master/bip-0037.mediawiki
    author: Mike Hearn, Matt Corallo
  - title: "BIP 157: Client Side Block Filtering"
    url: https://github.com/bitcoin/bips/blob/master/bip-0157.mediawiki
    author: Olaoluwa Osuntokun, Alex Akselrod, Jim Posen
  - title: "BIP 159: NODE_NETWORK_LIMITED service bit"
    url: https://github.com/bitcoin/bips/blob/master/bip-0159.mediawiki
    author: Jonas Schnelli
  - title: Bitcoin.org - Running a full node (pruning)
    url: https://bitcoin.org/en/full-node
    author: Bitcoin.org contributors
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

A full node downloads every block and checks every rule itself. Two lighter ways to use Bitcoin are often confused: an SPV client keeps only block headers, and a pruned full node checks everything but deletes old block data. They solve different problems and trust different things.

An SPV client, described in section 8 of the Bitcoin whitepaper, keeps the headers of the chain with the most proof of work. Each header is 80 bytes and commits to the block's transactions through a Merkle root. To check a payment, the client asks a peer for the Merkle branch that links the transaction to a header it already holds. If the branch checks out, the transaction is in that block, and the blocks built on top of it show how much work protects it.

A pruned full node validates the chain the same way an archival node does. It downloads every block, checks each one, and then deletes old block files to free disk space. It keeps enough recent data to follow the chain, but it cannot show you the blocks it has deleted.

In short:

- An SPV client stores headers, checks inclusion with Merkle branches, and trusts that the most-work chain is valid.
- A pruned node stores recent blocks, checks every rule, trusts nobody about validity, and has less history to offer other peers.

## medium

An SPV client is only as honest as the peers it asks. A Merkle branch proves that a transaction is in a block, but it cannot prove that nothing is missing. A peer can leave out a transaction that matters to the client, and the client will not notice. The Developer Guide therefore suggests sending requests to several peers, so one dishonest peer cannot hide everything.

Privacy is the second weakness. If an SPV client asks for the transactions that match its own addresses, each peer learns which addresses belong together. BIP 37 reduced this with Bloom filters. The client sends a filter, and the peer returns transactions that probably match. The false-positive rate is chosen by the client: a higher rate reveals less but costs bandwidth. BIP 157 and BIP 158 use a different design. The full node publishes a compact filter for each block, the client downloads those filters, tests them locally, and requests only the full blocks that may contain its transactions. BIP 157 describes BIP 37 as having known flaws that weaken privacy and invite denial-of-service attacks on full nodes.

A pruned node avoids the trust question because it validates everything itself. Its cost is that it cannot serve everything. In Bitcoin Core, pruning is enabled with the prune option, which sets a target size in MiB for raw block and undo data. A pruned node still relays new blocks and transactions, but it cannot serve arbitrary historical blocks. BIP 159 defines the NODE_NETWORK_LIMITED service flag, which tells other peers that a node keeps only recent blocks. Such a node promises at least the last 288 blocks, about two days. A peer that needs older blocks has to find a node that signals full history. Pruning also rules out features that depend on old data, such as the transaction index and wallet rescans.

## advanced

The whitepaper frames SPV as a trade-off. A client that holds only headers can check that a transaction is buried under proof of work, but not that the transaction obeys the rules. The Developer Guide makes the same point: the Merkle branch demonstrates the amount of work needed to rewrite the chain, not the validity of what is embedded. An SPV client therefore cannot check a conflicting unconfirmed payment, and it cannot tell an invalid transaction from a valid one that sits in a block. The most-work assumption carries the whole security argument.

Header checks give the client more than it might seem. Each header must hash below a target that follows the difficulty schedule, so a fake header chain costs real work to build. A Merkle branch contains one hash for each level of the tree, so its length grows with the logarithm of the number of transactions, not with the block size. The cost is a dependency: the client's view is only as current as the peers that serve it headers.

A pruned node has the opposite profile. It enforces every consensus rule, including the signatures and scripts of old blocks, because it checked them when they arrived. It also keeps undo data for recent blocks, which lets it roll them back during a reorganization. A node with a small prune target can be forced to stop when a reorganization needs blocks it has already deleted, so the target should cover a realistic reorganization depth. The Bitcoin Core documentation says the wallet is as secure with high prune values as with low ones, and that higher values only keep the node running through deeper reorganizations.

Taken together, the two models separate what is checked from what is kept. SPV checks inclusion cheaply and accepts the chain's work as proof of validity. Pruning checks everything and keeps less. Neither one gives the same guarantee as a full archival node, which validates the chain and can also serve its full history to others. In practice, a client that wants more assurance should compare what several peers report, rather than rely on a single answer.
