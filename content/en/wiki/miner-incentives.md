---
id: wiki.miner-incentives
slug: miner-incentives
language: en
category: economics
title: Miner Incentives
description: The economic rewards — block subsidy and transaction fees — that motivate miners to secure the network through honest participation.
coverImage: media/wiki/miner-incentives/miner-incentives-hero.svg
difficulty: base
readTimeMinutes: 7
tags:
  - Economics
  - Mining
  - Incentives
  - Security
related:
  - wiki.block-subsidy
  - wiki.fee-market
  - wiki.halving
  - wiki.game-theory
  - wiki.proof-of-work
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: Mastering Bitcoin - Chapter 8
    url: https://github.com/bitcoinbook/bitcoinbook/blob/develop/ch08.asciidoc
    author: Andreas M. Antonopoulos
  - title: Bitcoin and the Economist's Fallacy
    url: https://medium.com/@nic__carter/bitcoin-and-the-economists-fallacy-4f087d3d7ad2
    author: Nic Carter
updatedAt: 2026-05-28T00:00:00Z
---

## base

Miners are the participants who create new blocks on the Bitcoin network. They are motivated by economic rewards — specifically, the chance to earn bitcoin by finding a valid block. This is the incentive that makes the whole system work.

When a miner successfully adds a block to the blockchain, they receive two types of compensation:

1. **Block subsidy**: A fixed amount of newly created bitcoin. As of 2024, this is 3.125 BTC per block.
2. **Transaction fees**: The fees attached to the transactions included in the block.

The total reward — subsidy plus fees — is collected through the coinbase transaction, which is the first transaction in every block.

![Miner revenue sources](media/wiki/miner-incentives/miner-incentives-hero.svg "Miners earn revenue from two sources: the block subsidy (newly created bitcoin) and transaction fees paid by users.")

Mining is competitive. The more computing power a miner has, the higher their chance of finding the next block. This competition means miners must operate efficiently — spending as little as possible on electricity and hardware — to remain profitable.

The key insight is that miners are financially motivated to follow the rules. A miner who tries to include invalid transactions or break the consensus rules will have their block rejected by full nodes, wasting their electricity and effort. Honest mining is the most profitable strategy.

## medium

The incentive structure of Bitcoin is carefully designed to align the self-interest of miners with the security of the network. There are two distinct revenue streams, each with different properties.

**Block subsidy** is the primary incentive in Bitcoin's early decades. It is predictable, known decades in advance, and diminishes over time through the halving mechanism. In 2009, the subsidy was 50 BTC per block, creating strong incentives for early miners to participate. By 2024, the subsidy had fallen to 3.125 BTC.

**Transaction fees** are the secondary incentive that becomes increasingly important as the subsidy declines. Fees are set by users competing for block space. When the mempool is congested, users bid higher fees, increasing miner revenue. When the mempool is empty, fees fall to near zero.

The total daily miner revenue can be calculated as:
```
Daily revenue = (subsidy + avg_fees_per_block) × 144 blocks per day
```

At 3.125 BTC subsidy and an average fee of 0.5 BTC per block (congested conditions), daily revenue is approximately 522 BTC. At a price of $60,000, this is roughly $31 million per day in total miner compensation.

Miner incentives create a positive feedback loop for security:

1. Higher bitcoin price → mining becomes more profitable
2. More profitable mining → more miners join
3. More miners → higher hash rate
4. Higher hash rate → more secure network
5. More secure network → more user trust → higher bitcoin price

This loop is not guaranteed, but it has operated for most of Bitcoin's history. It creates a self-reinforcing relationship between price, security, and adoption.

Critically, miners have sunk costs in hardware and facilities. Once an ASIC miner is purchased and installed, the operator must mine to recover their investment. This creates a long-term commitment to the network that aligns miner interests with Bitcoin's success.

## advanced

The game theory of miner incentives is more nuanced than simple profit maximization. Several strategic considerations affect miner behavior:

**Revenue maximization vs. sabotage.** A miner with significant hash rate could in theory attempt to disrupt the network (e.g., by mining empty blocks or executing a 51% attack to double-spend). However, such attacks are self-limiting: a successful attack would destroy user confidence, crash the price, and devalue the attacker's own mining equipment and bitcoin holdings. Rational miners therefore have a financial interest in preserving network integrity.

**Orphaning and propagation races.** Miners must decide which transactions to include and how quickly to propagate blocks. Including too many low-fee transactions makes a block larger and slower to propagate, increasing orphan risk. Miners balance fee revenue against the expected cost of orphan races, typically optimizing for fee rate rather than total fee.

**The mining reward function** in Bitcoin is a memoryless Poisson process: each hash attempt has an equal independent probability of success. This means expected revenue is proportional to the share of total hash rate. A miner controlling 1% of global hash rate expects to find approximately 1% of blocks.

The expected value of mining can be expressed as:
```
E[revenue] = (hash_rate / total_hash_rate) × (subsidy + avg_fees) × blocks_per_day × BTC_price
```

**The tragedy of the commons in mining.** Individual miners have an incentive to increase their hash rate to capture a larger share of rewards. But when all miners do this, the difficulty adjusts upward, and each miner's share remains roughly the same — while everyone's electricity costs rise. This is a classic arms race dynamic.

**Forward-looking incentives.** The halving schedule means rational miners must plan for declining subsidy revenue. This creates pressure for:
- Investment in more efficient ASIC technology
- Relocation to regions with cheaper electricity
- Vertical integration with power generation
- Fee revenue optimization through transaction selection

**The security budget question.** A major debate in Bitcoin economics concerns whether fee revenue alone can sustain mining security after subsidies become negligible. Some argue that Layer 2 solutions (Lightning Network) and the value of settlement finality will generate sufficient fee demand. Others worry that declining security budgets could make attacks economically viable.
