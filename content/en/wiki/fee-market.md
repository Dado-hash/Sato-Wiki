---
id: wiki.fee-market
slug: fee-market
language: en
category: economics
title: Fee Market
description: The competitive market for block space where users bid against each other for transaction confirmation, and miners select the most profitable transactions.
coverImage: media/wiki/fee-market/fee-market-hero.svg
difficulty: base
readTimeMinutes: 7
tags:
  - Economics
  - Fees
  - Mempool
  - Mining
related:
  - wiki.transaction-fees
  - wiki.miner-incentives
  - wiki.block-subsidy
  - wiki.mempool
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: "Mastering Bitcoin - Mempool and Fee Estimation"
    url: https://github.com/bitcoinbook/bitcoinbook/blob/develop/ch05.asciidoc
    author: Andreas M. Antonopoulos
  - title: Bitcoin Fee Market Analysis
    url: https://bitcoinfees.earn.com/
    author: Earn.com
updatedAt: 2026-05-28T00:00:00Z
---

## base

Bitcoin's fee market is the economic system that determines how much users pay to have their transactions confirmed. Because each block has a limited size (roughly 4 million weight units), not all transactions can be included immediately. Users compete for this scarce block space by offering fees.

When you send a Bitcoin transaction, you can attach a fee. Higher fees mean miners are more likely to include your transaction in the next block. Lower fees mean your transaction may wait longer in the mempool.

Think of it like a taxi queue at an airport. There are only so many taxis (block space). People who need a ride urgently are willing to pay more. Those who can wait take a cheaper option or wait for the next taxi. The price adjusts based on how many people need a ride and how many taxis are available.

The fee is calculated as the difference between the total value of your transaction inputs and the total value of your outputs:
```
fee = sum(inputs) - sum(outputs)
```

Fees are typically measured in satoshis per virtual byte (sat/vB). A standard transaction might cost 10-50 sat/vB during normal conditions, but can spike to hundreds during congestion.

![Fee market supply and demand](media/wiki/fee-market/fee-market-hero.svg "Block space is fixed. When demand for transactions exceeds supply, users bid up fees until the market clears.")

The fee market ensures that the most economically valuable transactions get confirmed first. It is not controlled by any central authority — it emerges naturally from the interaction of thousands of users and miners.

## medium

The fee market is driven by the fundamental constraint of block space. Each block has a maximum weight of 4,000,000 weight units (WU). After accounting for the block header and coinbase transaction, approximately 3,990,000 WU are available for user transactions. A typical transaction might consume 140-200 WU for a simple payment (SegWit) or more for complex scripts.

Miners select transactions from their mempool to build a block template. The standard selection algorithm is to sort transactions by fee rate (sat/vWU or sat/vB) and include the highest-paying ones first, up to the block weight limit. This is known as "greedy" transaction selection.

**Fee estimation.** Wallets use fee estimation algorithms to recommend appropriate fees. These algorithms analyze recent blocks to determine what fee rate was sufficient for confirmation within a target number of blocks. Bitcoin Core provides estimates through the `estimatesmartfee` RPC, which returns a fee rate for a given confirmation target (e.g., 2 blocks, 6 blocks, 25 blocks).

**Historical fee patterns.** The Bitcoin fee market has gone through several distinct phases:

- **2009-2012**: Most transactions included zero or minimal fees. Miners processed them regardless, since the block subsidy was the primary reward.
- **2013-2016**: As usage grew and blocks began to fill, fees became necessary. The first significant fee spikes occurred.
- **2017**: The peak of the first major fee crisis. Average fees reached over $50 per transaction during the December 2017 mania, as SegWit adoption was still low.
- **2021-2024**: Ordinals and BRC-20 inscriptions created new demand for block space, driving fee revenue to all-time highs even with lower Bitcoin prices relative to 2021 peaks.
- **Ongoing**: Fee revenue as a percentage of total miner reward has trended upward, from near zero to occasionally exceeding the block subsidy during periods of high demand.

**Replace-by-Fee (RBF).** RBF allows a sender to replace an unconfirmed transaction with a new one that pays a higher fee. BIP 125 defines opt-in RBF: the original transaction must signal replaceability by setting sequence number below 0xFFFFFFFE. When a replacement is detected, nodes validate that the new transaction pays a strictly higher fee rate and does not conflict with other mempool transactions.

**Child-Pays-For-Parent (CPFP).** If a transaction is stuck with a low fee, the recipient can create a new transaction that spends one of its outputs and offers a high fee. Miners evaluate the combined package: if the parent + child together offer a competitive fee rate, both are included. This gives the recipient a way to accelerate confirmation even if the sender did not pay enough.

## advanced

The fee market is a mechanism design problem: how to allocate a scarce resource (block space) among competing users without a central planner. Bitcoin's solution — first-price auction with a fixed supply — has significant implications.

**Block space as a congestion good.** Block space is a club good: it is non-rivalrous up to the block size limit, but becomes rivalrous when demand exceeds that limit. Unlike a typical market, the supply of block space does not respond to price signals — the block weight limit is fixed by consensus. This inelastic supply creates extreme price volatility when demand fluctuates.

**The fee distribution under different demand regimes:**

| Regime | Mempool state | Typical fee rate | Confirmation time |
|--------|--------------|-----------------|-------------------|
| Empty | 0-1 blocks of tx | 1-5 sat/vB | Next block |
| Normal | 1-5 blocks | 5-30 sat/vB | 1-6 blocks |
| Congested | 10-50+ blocks | 50-300+ sat/vB | Hours to days |
| Extreme | 100+ blocks | 300-1000+ sat/vB | Days |

**Economic efficiency of the fee market.** The first-price auction creates several inefficiencies:

1. **Fee overpayment**: Users must guess the appropriate fee, often overpaying due to uncertainty about others' bids.
2. **Bidding wars**: During congestion, users may repeatedly replace transactions with higher fees (RBF), creating an escalating auction.
3. **Strategic mempool pollution**: An attacker can fill blocks with low-fee transactions at minimal cost to congest the network.

Proposed improvements include:

- **Package relay (BIP 331)**: Allows a set of related transactions to be evaluated as a package rather than individually, improving CPFP effectiveness.
- **v3 transaction relay**: A new transaction version with stricter topology and replacement rules, designed to make fee bumping more reliable.
- **Ephemeral dust**: Short-lived UTXOs that can be spent before being included in a block, reducing the cost of certain protocol interactions.

**The transaction fee sustainability thesis.** Some economists argue that the fee market may fail to sustain mining security after subsidies decline, because fee-paying is a public good problem: users have an incentive to free-ride on others' fees. However, empirical data shows that fee revenue has grown significantly over time, and the Ordinals/inscriptions wave demonstrated that organic demand for block space can generate substantial fees even without traditional payment usage.
