---
id: wiki.difficulty-adjustment
slug: difficulty-adjustment
language: en
category: economics
title: Difficulty Adjustment
description: The algorithm that recalibrates Bitcoin's proof-of-work target every 2016 blocks so blocks continue to arrive at 10-minute intervals regardless of total hash rate.
coverImage: media/wiki/difficulty-adjustment/difficulty-loop.svg
difficulty: base
readTimeMinutes: 7
tags:
  - Economics
  - Mining
  - Difficulty
  - Consensus
related:
  - wiki.proof-of-work
  - wiki.mining
  - wiki.halving
  - wiki.blocks
  - wiki.consensus-rules
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: Bitcoin Developer Reference - Block Chain
    url: https://developer.bitcoin.org/reference/block_chain.html
    author: Bitcoin.org contributors
  - title: Bitcoin Core difficulty adjustment implementation
    url: https://github.com/bitcoin/bitcoin/blob/master/src/pow.cpp
    author: Bitcoin Core contributors
updatedAt: 2026-05-28T00:00:00Z
---

## base

Bitcoin's difficulty adjustment is the mechanism that keeps the block production rate stable. Without it, adding more miners would make blocks find faster and faster, throwing off the network's predictable 10-minute rhythm.

The adjustment works as a feedback loop. Every 2,016 blocks — roughly two weeks — every full node checks how long it actually took to mine those blocks. If it took less than two weeks (blocks were found too quickly), the difficulty increases. If it took more than two weeks (blocks were found too slowly), the difficulty decreases. The adjustment is clamped to a maximum factor of 4 per period.

This means Bitcoin automatically adapts to changes in total mining power. When new miners join, blocks initially come faster, but the next adjustment raises the difficulty and brings the pace back to 10 minutes. When miners leave, the adjustment lowers the difficulty, keeping the network accessible even with less total hash rate.

![Difficulty adjustment feedback loop](media/wiki/difficulty-adjustment/difficulty-loop.svg "A negative feedback loop: hash rate changes alter block timing, which triggers a difficulty adjustment every 2016 blocks to restore the 10-minute target.")

The difficulty is expressed as a target: miners must find a block header hash that is below this target value. A lower target means fewer valid hashes, making mining harder. A higher target means more valid hashes, making mining easier.

## medium

The difficulty adjustment algorithm is mathematically straightforward. After each 2,016-block period, every full node independently calculates:

```
new_target = old_target × (actual_timespan / target_timespan)
```

Where `actual_timespan` is the time it took to mine the last 2,016 blocks, and `target_timespan` is 2,016 × 10 minutes = 20,160 minutes (exactly two weeks).

The adjustment is clamped so that `actual_timespan` cannot be less than 3.5 days (one quarter of the target) or more than 8 weeks (four times the target). This prevents extreme adjustments from a single anomalous period.

The difficulty is stored in the block header as the `nBits` field — a compact 4-byte encoding of the 256-bit target. Bitcoin Core's `pow.cpp` implements the retarget in `CalculateNextWorkRequired()`:

```cpp
unsigned int CalculateNextWorkRequired(const CBlockIndex* pindexLast,
                                       int64_t nFirstBlockTime,
                                       const Consensus::Params& params)
{
    if (params.fPowNoRetargeting)
        return pindexLast->nBits;

    int64_t nActualTimespan = pindexLast->GetBlockTime() - nFirstBlockTime;
    nActualTimespan = std::max(nActualTimespan, params.DifficultyAdjustmentInterval() / 4);
    nActualTimespan = std::min(nActualTimespan, params.DifficultyAdjustmentInterval() * 4);

    const arith_uint256 bnPowLimit = UintToArith256(params.powLimit);
    arith_uint256 bnNew;
    bnNew.SetCompact(pindexLast->nBits);
    bnNew *= nActualTimespan;
    bnNew /= params.DifficultyAdjustmentInterval();

    if (bnNew > bnPowLimit)
        bnNew = bnPowLimit;
    return bnNew.GetCompact();
}
```

The difficulty has grown enormously since Bitcoin's launch. The first blocks had a difficulty of 1, meaning the target was the maximum possible value (2²²⁴ - 1 for Bitcoin). By 2026, difficulty exceeds 100 trillion — a 100,000,000,000,000x increase. This reflects the growth of Bitcoin's mining industry from hobbyists on CPUs to industrial-scale ASIC operations.

![Difficulty history](media/wiki/difficulty-adjustment/difficulty-history-chart.svg "Bitcoin's mining difficulty has grown from 1 to over 100 trillion, reflecting the enormous growth of global hash rate from CPU to GPU to ASIC mining.")

Timestamps in blocks are not trusted blindly. Nodes enforce rules to prevent miners from manipulating the difficulty by lying about timestamps: the block timestamp must be greater than the median timestamp of the past 11 blocks (Median-Time-Past) and cannot be more than 2 hours ahead of the node's network-adjusted time.

## advanced

The difficulty adjustment has evolved over Bitcoin's history. Originally, Satoshi Nakamoto implemented a simple retarget based on the ratio of actual to expected timespan. The current algorithm has been refined to prevent several attack vectors.

**Timestamp manipulation attacks.** A dishonest miner could claim blocks were found faster than reality to lower the difficulty during the next period. Bitcoin defends against this with two rules:
1. **Median-Time-Past**: A block's timestamp must exceed the median of the last 11 block timestamps. This prevents a miner from single-handedly moving the clock far into the future.
2. **Future limit**: A block's timestamp cannot exceed the node's local time by more than 2 hours.

These rules prevent mining entities from creating blocks with timestamps that would significantly distort the difficulty calculation.

**Emergency Difficulty Adjustment (EDA).** Bitcoin Cash, a fork of Bitcoin, experienced severe oscillation due to its emergency difficulty adjustment mechanism. Bitcoin's more conservative design (only adjusting every 2,016 blocks with a 4x clamp) avoids this instability.

**Testnet special case.** Bitcoin's test network (testnet) uses a special rule: if a block hasn't been found in 20 minutes, the difficulty is halved for the next block. This ensures testnet remains usable even when little testing is happening. Mainnet has no such rule.

**The economics of difficulty.** The difficulty adjustment links Bitcoin's security to its price. When the price rises, mining becomes more profitable, attracting more miners, raising the difficulty, and making the network more secure. When the price falls, unprofitable miners exit, difficulty drops, and remaining miners operate with lower costs. This automatic equilibrium creates a self-stabilizing system that does not require external intervention.

The difficulty adjustment also affects confirmation time variability. While the target is 10-minute blocks, individual block times follow an exponential distribution (a Poisson process). This means that individual blocks can arrive within seconds or take hours. The difficulty adjustment corrects the average but cannot prevent short-term variance. From a user's perspective, this is why you might see a block arrive 30 seconds after the previous one, followed by a 45-minute wait. The system works correctly over the 2,016-block window, not block by block.

As of 2025-2026, the difficulty algorithm is the subject of ongoing research. Proposals like **Difficulty Adjustment Algorithm v2** and **ASERT** (Absolutely Scheduled Exponentially Rising Targets) have been discussed for potential future upgrades, though none have been adopted by Bitcoin Core as of 2026. These proposals aim to make the adjustment smoother and more responsive while preserving Bitcoin's conservative approach to consensus changes.
