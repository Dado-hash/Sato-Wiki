---
id: wiki.halving
slug: halving
language: en
category: economics
title: Halving
description: The programmed reduction of Bitcoin's block subsidy by 50% every 210,000 blocks, controlling the rate of new supply creation.
coverImage: media/wiki/halving/halving-timeline.svg
difficulty: base
readTimeMinutes: 7
tags:
  - Economics
  - Halving
  - Supply
  - Monetary Policy
  - Mining
related:
  - wiki.fixed-supply
  - wiki.twenty-one-million-cap
  - wiki.issuance-schedule
  - wiki.block-subsidy
  - wiki.miner-incentives
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: Bitcoin Halving Events
    url: https://en.bitcoin.it/wiki/Halving
    author: Bitcoin Wiki contributors
  - title: Bitcoin Block Subsidy Schedule
    url: https://bitcoin.stackexchange.com/questions/2456/bitcoin-block-subsidy-schedule
    author: Bitcoin Stack Exchange
updatedAt: 2026-05-28T00:00:00Z
---

## base

A halving is an event programmed into Bitcoin's code where the reward miners receive for finding a new block is permanently cut in half. This happens every 210,000 blocks, or roughly every four years.

When Bitcoin launched in 2009, miners received 50 BTC for each block they found. In November 2012, the first halving reduced this to 25 BTC. The second halving in July 2016 brought it to 12.5 BTC. The third in May 2020 reduced it to 6.25 BTC. The fourth in April 2024 set it at 3.125 BTC.

The halving continues until the block subsidy becomes so small that it rounds to zero. This will happen after 64 halvings, around the year 2140. At that point, no new bitcoin will ever be created.

![Halving timeline](media/wiki/halving/halving-timeline.svg "The complete timeline of Bitcoin halvings from 2009 to 2140, showing how the block subsidy decreases over each 4-year epoch.")

The halving is the mechanism that makes Bitcoin's supply predictable and scarce. By reducing the reward over time, it mimics the diminishing returns of gold mining — without requiring anyone to decide when to reduce it.

## medium

The halving occurs at a specific block height, not a specific date. The first halving occurred at block 210,000, the second at 420,000, the third at 630,000, and the fourth at 840,000. The approximate date depends on how quickly blocks are mined. Because Bitcoin targets 10-minute blocks, 210,000 blocks takes about 3.99 years on average, but actual dates can vary by weeks due to hash rate fluctuations between difficulty adjustments.

Each halving reduces the rate of new bitcoin entering circulation by 50%. This has a direct effect on the inflation rate:
- Before the first halving: ~100,000 BTC per month entering circulation
- After the fourth halving (2024): ~13,125 BTC per month entering circulation
- After the eighth halving (~2040): ~820 BTC per month

The halving has historically been associated with significant market events. While the market's response to each halving has varied, the reduction in new supply creates a structural change in the balance between sell pressure from miners and buy demand from the market:

**Historical halvings:**
- **2012 (25 BTC)**: Bitcoin was trading around $12. In the year following, it rose to over $1,000
- **2016 (12.5 BTC)**: Price was around $650. The subsequent 18 months saw a rally to nearly $20,000
- **2020 (6.25 BTC)**: Price was around $8,600. The next year saw a peak above $68,000
- **2024 (3.125 BTC)**: Price was around $63,000

These patterns are often cited as evidence of the halving's impact on price, but correlation does not imply causation. Multiple factors — including monetary policy cycles, regulatory developments, and technological advancements — have also contributed to Bitcoin's price movements.

From a miner's perspective, the halving creates immediate revenue pressure. Miners who operated on thin margins before a halving may become unprofitable and shut down. This is by design: the halving forces mining efficiency improvements and ensures that only the most efficient miners survive, strengthening the network's long-term security.

## advanced

The halving mechanism is implemented in Bitcoin Core's `GetBlockSubsidy` function:

```cpp
CAmount GetBlockSubsidy(int nHeight, const Consensus::Params& consensusParams)
{
    int halvings = nHeight / consensusParams.nSubsidyHalvingInterval;
    if (halvings >= 64)
        return 0;
    CAmount nSubsidy = 50 * COIN;
    nSubsidy >>= halvings;
    return nSubsidy;
}
```

The right-shift operator (`>>= halvings`) implements the division by 2 for each halving. After 64 halvings, shifting a 64-bit integer 64 times produces zero, which terminates the subsidy forever. The `consensusParams.nSubsidyHalvingInterval` is set to 210,000 on mainnet.

Mining economics change drastically around each halving. Consider a miner with 1 EH/s of hash rate (~1% of total network hash rate):

| Metric | Before 2024 halving | After 2024 halving |
|--------|-------------------|-------------------|
| Daily BTC earned | ~0.6 BTC | ~0.3 BTC |
| Daily revenue (at $60k) | ~$36,000 | ~$18,000 |
| Breakeven electricity cost | ~$0.08/kWh | ~$0.04/kWh |

This is why each halving triggers a "miner shakeout." Less efficient miners must either upgrade hardware, secure cheaper power, or exit. The network hash rate often drops temporarily after a halving before recovering as efficient miners expand.

The halving also has profound implications for Bitcoin's security budget. In 2024, the annual subsidy was approximately 164,000 BTC, worth roughly $10 billion at $60,000 per BTC. By the 2032 halving, this will drop to ~41,000 BTC per year. For security to remain at current levels, either the bitcoin price must rise approximately 4x to maintain the same fiat-denominated security budget, or the network must rely increasingly on transaction fees to supplement miner revenue.

The game theory of the halving is often misunderstood. Because the subsidy is cut in half, one might expect miners to collude to raise fees. However, miners are price-takers in a competitive market. The mempool and fee market are driven by user demand for block space, not by miner coordination. If a miner demands higher fees, another miner will simply include the transaction at a lower rate.

The halving's impact on price is heavily debated. The "stock-to-flow" model popularized by PlanB posits a strong correlation between Bitcoin's scarcity (measured by the stock-to-flow ratio) and its market value. Each halving doubles Bitcoin's stock-to-flow ratio, and the model predicts a corresponding price increase. Critics argue that past performance is not predictive and that the model relies on a small sample size (only 4 halving events). As of 2026, rigorous academic consensus has not been reached on the halving's price impact.
