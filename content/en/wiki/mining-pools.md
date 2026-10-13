---
id: wiki.mining-pools
slug: mining-pools
language: en
category: protocol
title: Mining Pools
description: Groups of miners who combine their hashrate, track work with shares and split the reward, and the trade-offs that come with pooling.
coverImage: media/wiki/mining-pools/mining-pools-hero.svg
difficulty: base
readTimeMinutes: 4
tags:
  - Mining Pools
  - Mining
  - Payouts
  - Centralization
  - Stratum
related:
  - wiki.mining
  - wiki.mining-software
  - wiki.miner-incentives
  - wiki.mining-hardware
  - wiki.proof-of-work
sources:
  - title: Bitcoin Optech - Pooled mining
    url: https://bitcoinops.org/en/topics/pooled-mining/
    author: Bitcoin Optech
  - title: Bitcoin Wiki - Pooled mining
    url: https://en.bitcoin.it/wiki/Pooled_mining
    author: Bitcoin Wiki contributors
  - title: "BIP 22: getblocktemplate - Fundamentals"
    url: https://github.com/bitcoin/bips/blob/master/bip-0022.mediawiki
    author: Luke Dashjr
  - title: Stratum V2 specification
    url: https://github.com/stratum-mining/sv2-spec
    author: Stratum V2 contributors
  - title: Stratum V2 project
    url: https://stratumprotocol.org/
    author: Stratum V2 contributors
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

Mining is a lottery. Each hash attempt has a small chance of falling below the target, and a miner's chance of finding the next block is roughly its share of the total hashrate. A small miner can wait a long time between blocks, and its income swings widely from day to day. The Optech pooled mining topic illustrates the point with a pool holding 1 percent of the hashrate, which can still go days without finding a block.

Mining pools exist to smooth that variance. Many miners combine their hashrate, share the work and split the reward according to a published rule. A pool works through shares. Members hash at a lower difficulty than the network, so a share is a header hash that proves work but is not a valid block. The pool counts the shares each member submits. When a hash also meets the network target, the pool has found a block, broadcasts it, and pays out the reward.

Most members do not build the block themselves. In the common protocol, the pool sends a block header template and coinbase data, so members usually have no direct say over which transactions the block contains.

## medium

Pools differ mainly in how they pay out. Optech describes three common schemes without numbers. Pay per share (PPS) pays for every share at a rate tied to the block subsidy, so a miner's income does not depend on luck, and the pool carries the variance. Pay per last N shares (PPLNS) pays out the actual reward from a found block, divided among the last N shares before it. This removes the pool's own variance but can leave miners unpaid for long stretches. Full pay per share (FPPS) works like PPS but adds transaction fees, which pools estimate with a proxy such as the average fees over a recent period.

The payout rule also affects how miners behave. The Bitcoin Wiki notes that some score-based schemes weight older shares less than recent ones, which reduces the gain from switching pools in the middle of a round. Miners can change pools, and the scheme decides how much is lost or gained by doing so.

Centralization is the main concern with pools. The Stratum V2 project states that a few mining pools now dominate Bitcoin's block space, with some acting as proxies for others, and that a pool can selectively include or exclude transactions. The reason lies in the protocol. With Stratum v1, which most pools have used, members receive a template from the pool, and the pool may reject changes to its transactions. Whoever builds the template therefore decides what gets mined. Concentrated hashrate turns that decision into a concentrated one.

Newer designs move template choice back toward miners. Stratum V2 can let members choose their own transactions. BraidPool is a proposed fully decentralized pool in which every member chooses its own transactions. The details of miner-built templates are covered in the mining software entry.

## advanced

A share must meet two rules to count. It must either be a valid block or be what would have been one at the primary target, and its coinbase transaction must follow the template the pool provides. The pool can therefore fix the coinbase layout even when the miner chooses the rest. Optech also notes that few Stratum v1 users check the previous block header against their own full node. In the past, that lack of independent validation has led miners to lose money by building on blocks that broke the consensus rules.

Payout schemes move risk around. Under PPS, the pool bears variance and must keep capital to pay members before it finds blocks. Under PPLNS, the pool bears no variance, but miners can be left unpaid during long droughts. Optech says PPLNS eliminates the pool's problems with variance and block withholding attacks. Optech also notes that even a slight block withholding attack could push a pool's profitability below a sustainable level, which is one reason the payout scheme matters to the pool operator.

Centralization has several layers. Hashrate can concentrate in a few pools, and within each pool the operator controls the template unless members use a protocol that gives them a say. Stratum V2 separates these roles with a Job Declaration Protocol. A Job Declarator Client on the miner side declares the jobs it wants to mine, and a Job Declarator Server on the pool side allocates tokens and acknowledges declarations. The specification defines two modes. In coinbase-only mode, the pool sees the coinbase and fee revenue but not the transactions. In full-template mode, the miner declares the transaction set. Its connections also use a Noise handshake, so the link is encrypted and authenticated.

The honest summary is that pooling is efficient, and that the payout scheme and the template builder are where its governance problems sit. A pool that gives members a choice of template, a clear payout rule and independent validation of the chain reduces some of the risk. A pool that offers none of these asks its members to trust it with more than the hashing itself.
