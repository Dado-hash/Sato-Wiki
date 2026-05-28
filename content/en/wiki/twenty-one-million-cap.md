---
id: wiki.twenty-one-million-cap
slug: twenty-one-million-cap
language: en
category: economics
title: 21 Million Cap
description: The specific number chosen for Bitcoin's maximum supply, emerging from the block subsidy schedule and halving interval.
coverImage: media/wiki/twenty-one-million-cap/twenty-one-million-hero.svg
difficulty: base
readTimeMinutes: 6
tags:
  - Economics
  - Supply
  - 21 Million
  - Monetary Policy
related:
  - wiki.fixed-supply
  - wiki.issuance-schedule
  - wiki.halving
  - wiki.scarcity
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: Bitcoin's Controlled Supply
    url: https://en.bitcoin.it/wiki/Controlled_supply
    author: Bitcoin Wiki contributors
  - title: Why 21 Million?
    url: https://www.lopp.net/bitcoin-information/21-million.html
    author: Jameson Lopp
updatedAt: 2026-05-28T00:00:00Z
---

## base

The number 21 million is not random. It is the mathematical result of Bitcoin's block subsidy schedule. The initial subsidy of 50 BTC per block halves every 210,000 blocks. If you sum all subsidies from now until the last satoshi is mined, the total converges to exactly 21 million Bitcoin.

The first block (the genesis block, mined in January 2009) created 50 BTC. After 210,000 blocks, the subsidy dropped to 25 BTC. After another 210,000 blocks, to 12.5 BTC. This process continues every four years until the subsidy becomes so small it rounds to zero — around the year 2140.

At that point, no new bitcoin will ever be created. Miners will earn only transaction fees. The supply will be fixed forever.

![The 21 million cap](media/wiki/twenty-one-million-cap/twenty-one-million-hero.svg "Visual breakdown of the 21 million cap: coins mined, remaining supply, last block subsidy in ~2140, and divisibility into 2.1 quadrillion satoshis.")

21 million may seem like an arbitrary number, but it was a deliberate design choice by Satoshi Nakamoto. It balances several factors: making Bitcoin scarce enough to hold value, divisible enough for global use (each bitcoin splits into 100 million satoshis), and with a distribution schedule that rewards early adopters while continuing to incentivize miners for over a century.

## medium

The mathematics behind 21 million is a geometric series. Each halving epoch produces half the bitcoin of the previous one:

```
Total = 210,000 × 50 × (1 + 1/2 + 1/4 + 1/8 + 1/16 + ...)
      = 210,000 × 50 × 2
      = 10,500,000 × 2
      = 21,000,000
```

The sum of an infinite geometric series with ratio 1/2 is exactly 2 times the first term. This is why the total converges to a finite number despite halvings continuing forever.

Satoshi Nakamoto chose 50 BTC as the initial subsidy and 210,000 blocks as the halving interval. At 10 minutes per block, 210,000 blocks takes approximately 3.99 years — close to four years. The choice of 50 BTC has been the subject of speculation: some suggest it was chosen because 21 million divided by 210,000 equals 100, and with the first era having a 50% share, the initial subsidy of 50 fits cleanly.

Why specifically 21 million and not 10 million or 100 million? Satoshi explained in an early email that the choice was "a educated guess" based on making the unit small enough for typical transactions while keeping the total supply limited. The exact reasoning considered:

- **Divisibility**: With 8 decimal places, 21 million bitcoin provides 2.1 quadrillion (2.1 × 10¹⁵) individual units
- **Mining incentives**: The schedule needed to reward early miners generously while still providing incentives for the century-long transition to fee-only mining
- **Monetary base comparison**: At various price assumptions, 21 million units with high divisibility could approximate global monetary aggregates

The cap is enforced by every full node. Any block that would create coins beyond the subsidy limit is rejected as invalid. This is not a social convention — it is a consensus rule checked by software running on thousands of nodes worldwide.

## advanced

The 21 million cap is implicitly enforced rather than explicitly checked as a running total in most validation code. Bitcoin Core validates the coinbase transaction value against the expected subsidy for the current block height. The function `GetBlockSubsidy` in `src/validation.cpp` calculates the correct subsidy based on the number of halvings that have occurred. If the coinbase output exceeds the subsidy plus fees, the block is rejected.

This implicit enforcement means that even if `MAX_MONEY` were removed from the codebase, the supply would still be bounded by the subsidy schedule. The `MAX_MONEY` constant provides defense-in-depth against overflow and logic errors.

The exact last block with a non-zero subsidy can be calculated precisely. The subsidy halves every 210,000 blocks. Starting from 50 BTC = 5,000,000,000 satoshis, after 64 halvings the subsidy becomes less than 1 satoshi and rounds to zero:
```
Block height of final subsidy = 64 × 210,000 = 13,440,000
```
At 10 minutes per block, this occurs approximately 128 years after genesis, around the year 2137-2140 depending on actual block timing.

There is a common misconception that the cap could be changed by a simple code update. Changing the 21 million cap would require a hard fork — every full node and economic participant would need to upgrade. Given that the fixed supply is one of Bitcoin's most fundamental value propositions, such a change is considered extremely unlikely by the community. The social consensus around the 21 million cap is arguably stronger than any individual code path enforcing it.

The divisibility aspect is often overlooked. At 8 decimal places, 21 million BTC yields 2,100,000,000,000,000 (2.1 quadrillion) satoshis. This is sufficient for a global monetary system: at a global population of 10 billion, each person could hold up to 210,000 satoshis (0.0021 BTC) even if every single satoshi were evenly distributed. Layer 2 solutions like the Lightning Network further increase granularity by enabling sub-satoshi payments through routing and multi-path payments.
