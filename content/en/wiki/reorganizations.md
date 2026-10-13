---
id: wiki.reorganizations
slug: reorganizations
language: en
category: protocol
title: Reorganizations and Stale Blocks
description: How nodes switch to the branch with more accumulated work when two blocks are found close together, what happens to the losing block, and why confirmations reduce risk.
difficulty: base
readTimeMinutes: 5
tags:
  - Reorganization
  - Stale Blocks
  - Forks
  - Confirmations
related:
  - wiki.blockchain
  - wiki.blocks
  - wiki.block-propagation
  - wiki.proof-of-work
  - wiki.coinbase-transaction
sources:
  - title: Bitcoin Developer Guide - Block Chain
    url: https://developer.bitcoin.org/devguide/block_chain.html
    author: Bitcoin.org contributors
  - title: Bitcoin Core consensus parameters
    url: https://github.com/bitcoin/bitcoin/blob/master/src/consensus/consensus.h
    author: Bitcoin Core contributors
  - title: Bitcoin Core validation implementation
    url: https://github.com/bitcoin/bitcoin/blob/master/src/validation.cpp
    author: Bitcoin Core contributors
  - title: "BIP 50: March 2013 Chain Fork Post-Mortem"
    url: https://github.com/bitcoin/bips/blob/master/bip-0050.mediawiki
    author: Gavin Andresen
    publishedAt: 2013-03-20
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

Sometimes two miners find valid blocks at nearly the same moment, and both extend the same previous block. The network now has a fork with two competing tips at the same height. Nodes do not keep both forever. Each node follows the branch it considers best, which is the one with the most accumulated proof of work. When the next block is found on top of one branch, that branch becomes stronger, and the other side is abandoned.

The losing block is called stale. It was valid, but it is no longer part of the best chain. Its transactions are not simply lost. When a node switches branches, it removes the stale block and tries to return its transactions to the mempool. A transaction that is still valid and does not conflict with the winning branch can be included in a later block. A transaction that the winning branch already spent differently is dropped. The coinbase transaction of the stale block is not returned, because it only pays a reward on the branch it belongs to.

Confirmations reduce the risk of a reorganization. A payment buried under more blocks would require a longer alternative branch to be replaced. Coinbase outputs also cannot be spent until 100 blocks after they are created. This rule keeps a miner from spending a reward that a short reorganization could remove.

## medium

When a node receives a block that extends a branch with more work than its current tip, it disconnects blocks back to the point where the branches split, and then connects the new branch. Simultaneous blocks are a normal part of operation, so switches happen regularly. The developer guide notes that nodes usually use the first block they see when two arrive together, and that they switch only when a competing branch becomes stronger.

The developer guide describes the rule as following the most difficult chain. This means the chain with the most accumulated work, not the one with the most blocks. Satoshi Nakamoto's whitepaper described the same idea as the longest chain, the one that carries the largest pool of CPU power. Work is the measure, so a branch with fewer blocks can still win if its blocks were harder to find.

Stale blocks and orphan blocks are different things. A stale block is valid and was once part of a fork, but a later block chose the other side. The developer guide notes that the word orphan is used for stale blocks, and also for true orphan blocks, which are blocks whose parent the node has never seen. A node holds a true orphan until its parent arrives, because it cannot connect the block to a chain it knows.

How fast a block reaches the rest of the network affects how often two blocks are found close enough together to create a fork. Block propagation covers how that relay works in practice.

Reorganizations are normal at the tip of the chain and become less likely as blocks accumulate. A confirmed transaction has no guarantee of finality, but each new block on top of it makes replacing it more expensive. A payment that is one block deep is more exposed than one that is many blocks deep, which is why merchants choose confirmation counts based on the value they are willing to risk.

## advanced

The whitepaper gives a probability model for an attacker who tries to overtake the honest chain. It assumes that honest blocks arrive at a faster rate than the attacker's blocks, and it treats the attacker's progress as a Poisson process. Under this model, the probability that the attacker ever catches up falls exponentially as the number of blocks between the attacker and the honest chain grows. The model gives the reasoning behind confirmation counts, but it does not fix a number for every payment, because the appropriate depth depends on the value at risk and the attacker's resources.

Reorganization handling in Bitcoin Core is a sequence of disconnect and connect steps. When blocks are disconnected, their transactions go into a pool that is replayed into the mempool in the original order, starting from the earliest transaction that was confirmed. Coinbase transactions are not re-added. If a transaction fails validation on the new branch, it is removed, along with any transactions that depended on it, because those would now be orphans in the mempool.

The 100-block rule for coinbase outputs is a consensus rule defined in Bitcoin Core's consensus parameters. Its purpose is to prevent a miner from spending a block reward before a short reorganization could remove the block that created it. The rule limits the damage from short reorganizations, but it does not prevent longer ones.

Deep reorganizations have happened, and they have usually been caused by differences between software versions rather than by a deliberate attack. BIP 50, the post-mortem of March 2013, describes a fork that started when a block with a larger number of transaction inputs was accepted by Bitcoin 0.8 nodes but rejected by older nodes. The 0.8 chain had about 60 percent of the mining hash power at that point, but the pools that mined on it downgraded their nodes to 0.7 so that they would reject the block. The majority then moved to the older chain, and the 0.8 nodes reorganized onto it. The cause was a database lock limit in the older software, which had become an unintended consensus rule. BIP 50 also records one large double spend during the reorganization, done by someone testing whether it was possible.

Reorganizations are therefore a property of the network as a whole. Nodes running the same rules can still end up on different branches for a while, and the chain with the most work becomes the reference only after the rest of the network has built on it.
