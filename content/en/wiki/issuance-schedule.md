---
id: wiki.issuance-schedule
slug: issuance-schedule
language: en
category: economics
title: Issuance Schedule
description: The predictable rate at which new bitcoin are created through block subsidies, following a known disinflationary curve from 2009 to 2140.
coverImage: media/wiki/issuance-schedule/issuance-curve.svg
difficulty: base
readTimeMinutes: 7
tags:
  - Economics
  - Supply
  - Issuance
  - Monetary Policy
related:
  - wiki.fixed-supply
  - wiki.twenty-one-million-cap
  - wiki.halving
  - wiki.block-subsidy
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: Bitcoin's Controlled Supply
    url: https://en.bitcoin.it/wiki/Controlled_supply
    author: Bitcoin Wiki contributors
  - title: Bitcoin Block Subsidy Schedule
    url: https://bitcoin.stackexchange.com/questions/2456/bitcoin-block-subsidy-schedule
    author: Bitcoin Stack Exchange
updatedAt: 2026-05-28T00:00:00Z
---

## base

Bitcoin's issuance schedule is the predictable, algorithmically-enforced rate at which new bitcoin are created. The rules are simple: every block creates a fixed number of new bitcoin (the block subsidy), and that number is cut in half every 210,000 blocks — approximately every four years.

This schedule was set when Bitcoin launched in 2009 and cannot be changed without broad consensus. It means everyone in the world knows exactly how many new bitcoin will be created at any point in the future, decades in advance.

The initial subsidy was 50 BTC per block. After the first halving in 2012 it became 25 BTC. In 2016 it became 12.5 BTC. In 2020 it became 6.25 BTC. The most recent halving in 2024 set it at 3.125 BTC. This trend continues until the subsidy becomes so small it effectively reaches zero.

![Bitcoin issuance curve](media/wiki/issuance-schedule/issuance-curve.svg "The block subsidy steps down every four years, while the cumulative supply approaches 21 million asymptotically.")

The chart shows two important curves. The step function (orange bars) shows the subsidy per block at each era — halving each time. The green S-curve shows the cumulative supply approaching 21 million, with most bitcoin already mined in the early years.

Because the schedule is fixed and known, Bitcoin is disinflationary: the inflation rate (new coins as a percentage of existing supply) decreases predictably over time and approaches zero.

## medium

The issuance schedule follows a precise mathematical progression. Each halving epoch lasts exactly 210,000 blocks. At Bitcoin's normal 10-minute block interval, this corresponds to roughly 3.99 years per epoch. The block subsidy for any given epoch is:

```
subsidy(height) = 50 × 2^(-floor(height / 210000)) BTC
```

This produces a step function where the subsidy remains constant within each epoch and drops discontinuously at each halving boundary.

The inflation rate can be calculated at any point. In the first epoch (2009-2012), the annualized inflation rate was approximately:
```
10,500,000 BTC created / increasing from 0 to 10.5M ≈ effectively infinite at start, ~100% at end
```
By the fourth epoch (2020-2024), inflation dropped to approximately 1.8% per year. After the 2024 halving, the inflation rate fell below 1% — lower than gold's long-term supply growth rate of approximately 1.5-2% per year.

| Epoch | Years | Subsidy | Annual issuance | Inflation (approx.) |
|-------|-------|---------|-----------------|---------------------|
| 1 | 2009-2012 | 50 BTC | 2,625,000 BTC | ~∞ → 100% |
| 2 | 2012-2016 | 25 BTC | 1,312,500 BTC | ~50% → 12.5% |
| 3 | 2016-2020 | 12.5 BTC | 656,250 BTC | ~8% → 5% |
| 4 | 2020-2024 | 6.25 BTC | 328,125 BTC | ~3.6% → 1.8% |
| 5 | 2024-2028 | 3.125 BTC | 164,062 BTC | ~0.9% → 0.8% |

By the 10th halving (~2052), the annual inflation rate will be below 0.1% — negligible for practical purposes. By the time the subsidy reaches 1 satoshi per block (approximately 64th halving), new issuance is zero.

The deterministic nature of this schedule is unprecedented in monetary history. No government, central bank, or organization can accelerate, slow, or change the rate of new bitcoin creation. This predictability allows economic actors to make decisions with full knowledge of future supply conditions.

## advanced

The issuance schedule creates distinct economic regimes over Bitcoin's lifetime. There are three phases:

**Phase 1 — Distribution (2009-2024):** 93% of all bitcoin were mined in the first 15 years. High issuance rewarded early miners and widely distributed coins. This phase saw the emergence of mining as an industry, with hash rate growing from CPU-based mining to specialized ASICs.

**Phase 2 — Maturation (2024-2140):** The remaining 7% of bitcoin are issued at a declining rate over roughly 116 years. During this phase, the block subsidy transitions from being the primary miner revenue source to a secondary one, as transaction fees become increasingly important. Miners must become more efficient as subsidy revenue per block declines.

**Phase 3 — Fee-only (2140+):** No new bitcoin are created. Miners earn exclusively from transaction fees. The security model shifts from subsidy-based to fee-based, a transition that must be economically sustainable to preserve the network's proof-of-work security.

The transition between phases raises important game-theoretic questions. In Phase 1, the high subsidy created strong incentives for mining participation, rapidly building the network's security. In Phase 2, falling subsidy revenue must be offset by either rising bitcoin prices, falling mining costs, or increasing fee revenue. If none of these occur, the security budget might decline.

However, several factors suggest the transition is manageable:

1. **Technological efficiency**: ASIC efficiency has improved by orders of magnitude, and further improvements are expected
2. **Fee market maturation**: As Bitcoin adoption grows, competition for block space creates organic fee demand
3. **Second-layer growth**: Lightning Network and other layer 2 solutions can generate regular fee traffic as users open and close channels
4. **Price appreciation**: If Bitcoin's value grows with adoption, even a small subsidy in BTC terms can be significant in fiat terms — and eventually fee revenue can sustain the network

The schedule also has distributional implications. Early adopters received large rewards at low difficulty and low bitcoin prices. Latecomers must acquire coins through market purchase or mining at much higher difficulty. This creates an inherent advantage for early participation, but one that diminishes as the market matures and becomes more liquid.
