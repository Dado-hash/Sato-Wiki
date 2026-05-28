---
id: wiki.fixed-supply
slug: fixed-supply
language: en
category: economics
title: Fixed Supply
description: Bitcoin's supply is algorithmically capped at 21 million coins. No entity can create more, making it the first digitally scarce asset.
coverImage: media/wiki/fixed-supply/fixed-supply-hero.svg
difficulty: base
readTimeMinutes: 6
tags:
  - Economics
  - Supply
  - Scarcity
  - Monetary Policy
related:
  - wiki.twenty-one-million-cap
  - wiki.issuance-schedule
  - wiki.halving
  - wiki.scarcity
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: Mastering Bitcoin - Chapter 8
    url: https://github.com/bitcoinbook/bitcoinbook/blob/develop/ch08.asciidoc
    author: Andreas M. Antonopoulos
  - title: Bitcoin's Monetary Policy
    url: https://en.bitcoin.it/wiki/Controlled_supply
    author: Bitcoin Wiki contributors
updatedAt: 2026-05-28T00:00:00Z
---

## base

Bitcoin has a fixed supply. The protocol rules enforce that no more than 21 million bitcoin will ever exist. This is enforced by code running on every full node, not by a promise from a central bank or company.

Traditional money can be printed by central banks when they decide more is needed. This is called monetary inflation. Bitcoin's supply rules cannot be changed unless almost every participant agrees to run new software — and changing the 21 million cap is considered unthinkable by the community.

Because the supply is fixed and known in advance, Bitcoin is the first example of true digital scarcity. Before Bitcoin, digital files could be copied infinitely. Bitcoin solved this by making each unit provably rare through the combination of proof of work and consensus rules.

![Fixed supply comparison](media/wiki/fixed-supply/fixed-supply-hero.svg "Bitcoin's fixed supply of 21 million coins compared to traditional fiat money, which has no supply cap and can be inflated by central banks.")

A fixed supply means that if demand for Bitcoin grows, the price must adjust upward — there is no way to create more coins to meet demand. This is fundamentally different from fiat currencies, where central banks can create new money and dilute the value of existing holdings.

## medium

The fixed supply is enforced by the consensus rules that every full node validates. The key constant in the Bitcoin Core source code is `MAX_MONEY = 21,000,000 * COIN`, where `COIN` represents 100,000,000 satoshis (the smallest unit). No transaction output can be created that would cause the total money supply to exceed this limit.

Conceptually, the fixed supply emerges from two protocol rules working together:

1. **Block subsidy schedule**: Each block creates a fixed amount of new bitcoin (the subsidy), which halves every 210,000 blocks
2. **No creation outside coinbase**: No transaction except the coinbase can create new bitcoin. Every other transaction must consume inputs that sum to at least as much as its outputs

The geometric series of block subsidies converges to exactly 21 million:
```
Total = 50 + 25 + 12.5 + 6.25 + 3.125 + ... = 50 × 2 = 100 × 210,000 = 21,000,000
```

This mathematical convergence is elegant: even though halvings continue forever, the amount of bitcoin that can ever be created is bounded and precisely calculable. After approximately 64 halvings, the subsidy rounds to zero satoshis due to integer arithmetic, and no more bitcoin will ever be created.

Bitcoin's fixed supply contrasts sharply with traditional monetary systems:

- **Gold**: Supply grows at 1-2% per year as new mines are discovered and extraction technology improves
- **Fiat currency**: Central banks can create unlimited amounts, and most major currencies have experienced persistent inflation
- **Commodity money**: Historical monies like shells or livestock had variable supply depending on collection or breeding

The fixed supply makes Bitcoin disinflationary by design. The inflation rate (new coins as a percentage of circulating supply) is precisely known decades in advance and approaches zero over time. This predictability allows savers and investors to make long-term decisions with confidence about future supply.

## advanced

The fixed supply rule is deeply embedded in Bitcoin's validation logic at multiple levels. At the transaction level, the sum of outputs for any non-coinbase transaction must not exceed the sum of inputs. At the block level, the coinbase transaction's output value must not exceed the block subsidy plus transaction fees. At the chain level, the monetary supply is implicitly bounded by these rules — no single piece of code checks a running total against MAX_MONEY during normal operation.

The `MAX_MONEY` constant serves a defensive role. It prevents overflow attacks where a crafted transaction could create an output exceeding the supply cap. Bitcoin Core checks this constant in the `CheckTxInputs` function: if the total transaction output value exceeds MAX_MONEY, the transaction is rejected. This protects against scenarios where integer overflow or manipulated input values could create coins from nothing.

The geometric series convergence deserves deeper analysis. The initial subsidy of 50 BTC per block produces:
- 210,000 blocks per halving epoch
- Each epoch's total issuance = starting_subsidy × 210,000
- Issuance by era: Era 0 = 10,500,000 BTC (50%), Era 1 = 5,250,000 (25%), Era 2 = 2,625,000 (12.5%)

By the end of the fourth halving (2024), approximately 93% of all bitcoin had been mined. This means the vast majority of Bitcoin's monetary base was created in its first 15 years, with the remaining 7% distributed over the following century.

| Era | Years | Subsidy | BTC created | % of total |
|-----|-------|---------|-------------|------------|
| 1 | 2009-2012 | 50 BTC | 10,500,000 | 50.00% |
| 2 | 2012-2016 | 25 BTC | 5,250,000 | 25.00% |
| 3 | 2016-2020 | 12.5 BTC | 2,625,000 | 12.50% |
| 4 | 2020-2024 | 6.25 BTC | 1,312,500 | 6.25% |
| 5 | 2024-2028 | 3.125 BTC | 656,250 | 3.125% |

A subtle but important implication: the fixed supply combined with lost coins means the circulating supply is permanently lower than 21 million. Estimates of lost bitcoin — from forgotten private keys, destroyed hardware, and early mining rewards sent to unspendable addresses — range from 3 to 6 million coins. This makes effective scarcity even higher than the nominal cap suggests.

The economic properties of a fixed supply have been debated since the earliest days of Bitcoin. Critics argue that a fixed supply is deflationary and may discourage spending, potentially leading to economic stagnation. Proponents counter that deflation in a growing economy is natural and that the divisibility of bitcoin (8 decimal places, allowing 2.1 quadrillion units) provides sufficient granularity for any level of economic activity.
