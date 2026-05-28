---
id: wiki.block-subsidy
slug: block-subsidy
language: en
category: economics
title: Block Subsidy
description: The newly minted bitcoin awarded to the miner of each valid block, which together with transaction fees forms the coinbase output.
coverImage: media/wiki/block-subsidy/block-subsidy-hero.svg
difficulty: base
readTimeMinutes: 6
tags:
  - Economics
  - Mining
  - Subsidy
  - Supply
related:
  - wiki.miner-incentives
  - wiki.halving
  - wiki.issuance-schedule
  - wiki.transaction-fees
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: Bitcoin Developer Reference - Transactions
    url: https://developer.bitcoin.org/reference/transactions.html
    author: Bitcoin.org contributors
  - title: Mastering Bitcoin - Chapter 10
    url: https://github.com/bitcoinbook/bitcoinbook/blob/develop/ch10.asciidoc
    author: Andreas M. Antonopoulos
updatedAt: 2026-05-28T00:00:00Z
---

## base

The block subsidy is the amount of new bitcoin created in every block. It is the only way new bitcoin enter circulation. When a miner mines a valid block, they are allowed to create a special transaction called the coinbase that awards them the subsidy plus any transaction fees from the transactions they included.

The subsidy started at 50 BTC per block in 2009. Every 210,000 blocks (roughly four years), the subsidy is cut in half — this is called the halving. As of the 2024 halving, the subsidy is 3.125 BTC per block.

The subsidy follows a simple rule: start with 50 BTC and divide by two every 210,000 blocks. After 64 halvings, the subsidy becomes less than 1 satoshi and rounds to zero. This will happen around the year 2140.

![Block subsidy anatomy](media/wiki/block-subsidy/block-subsidy-hero.svg "The coinbase transaction contains the block subsidy plus transaction fees. This is the only way new bitcoin enter the system.")

The block subsidy is what makes mining profitable even when transaction fees are low. In Bitcoin's early years, the subsidy was the dominant incentive. As it declines over the decades, transaction fees are expected to become the primary miner revenue source.

The coinbase output has a special rule: it cannot be spent until it has 100 confirmations (about 16 hours). This prevents miners from spending subsidy coins that might be invalidated by a block reorganization.

## medium

The block subsidy is enforced by the consensus rules that every full node validates. The function `GetBlockSubsidy` in Bitcoin Core calculates the correct subsidy for any block height:

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

The subsidy halves every 210,000 blocks. The arithmetic is a simple right-shift: after one halving, 50 becomes 25; after two, 25 becomes 12.5; and so on. After 64 halvings, the result is zero.

The coinbase transaction is unique in that it has no inputs. All other transactions must consume previous UTXOs as inputs. The coinbase creates value from nothing, but only within the strict limits defined by the subsidy schedule. The total coinbase output value must not exceed the block subsidy plus the sum of fees from all transactions in the block.

Because the subsidy is paid in the coinbase, the actual monetary supply grows only when blocks are found. At 144 blocks per day (10-minute average), the daily issuance can be calculated as:
```
Daily issuance = subsidy × 144
```
At 3.125 BTC, this is 450 BTC per day, or approximately 164,000 BTC per year.

The subsidy has accounted for the vast majority of total bitcoin supply:
- 2009-2012: 10,500,000 BTC from subsidy (100% of new supply)
- 2012-2016: 5,250,000 BTC from subsidy (~98% with low fees)
- 2016-2020: 2,625,000 BTC from subsidy (~95%)
- 2020-2024: 1,312,500 BTC from subsidy (~90%)

## advanced

The block subsidy serves a dual economic purpose: it distributes new coins and secures the network simultaneously. This design elegantly solves the bootstrapping problem that plagues new monetary systems.

**The coinbase maturity rule.** Coinbase outputs must mature for 100 blocks before they can be spent (enforced by `IsCoinBase()` checks in `CheckTxInputs`). This prevents the following attack: a miner finds a block, spends the coinbase immediately, and then a reorganization orphans that block. Without the maturity rule, the spent coins would disappear from one chain state but remain in another, creating a double-spend opportunity.

**Subsidy and difficulty interaction.** The block subsidy indirectly affects mining difficulty through profitability. When subsidy is high, mining is more profitable, attracting more hash rate, which raises difficulty. As subsidy declines, the equilibrium hash rate for a given bitcoin price also declines, unless offset by fee revenue or price appreciation.

**Theoretical minimum viable subsidy.** Economists debate the minimum subsidy (or fee revenue) needed to sustain the network. A common model assumes miners spend most of their revenue on electricity. If total mining revenue falls below total electricity costs, miners shut down, hash rate drops, and the network becomes less secure. The adjustment is self-correcting: lower hash rate means lower difficulty, which reduces electricity costs for remaining miners, restoring equilibrium.

**Comparison to gold mining.** The Bitcoin block subsidy is analogous to gold mining: both require real-world resources (energy, equipment) to produce new units. However, Bitcoin's subsidy schedule is entirely predictable, while gold's supply depends on geological discovery and extraction technology. Bitcoin's subsidy rate halves on a fixed schedule regardless of price; gold mines open or close based on the gold price versus extraction cost.
