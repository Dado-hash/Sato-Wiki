---
id: history.first-halving
slug: first-halving
language: en
date: 2012-11-28
title: First Bitcoin Halving
category: protocol
summary: The first Bitcoin halving cuts the block subsidy from 50 to 25 BTC at block height 210,000, reducing the rate of new bitcoin issuance by 50%.
tags:
  - Bitcoin
  - Halving
  - Mining
  - Supply
related:
  - id: wiki.halving
    title: Halving
  - id: wiki.block-subsidy
    title: Block Subsidy
  - id: wiki.issuance-schedule
    title: Issuance Schedule
  - id: wiki.miner-incentives
    title: Miner Incentives
sources:
  - title: First Halving — Blockchain.com
    url: https://www.blockchain.com/explorer/blocks/210000
    author: Blockchain.com
  - title: Bitcoin Halving History — CoinDesk
    url: https://www.coindesk.com/bitcoin-halving-history
    author: CoinDesk
  - title: Bitcoin block 210,000 — Bitcoin Explorer
    url: https://bitcoinexplorer.org/block/210000
    author: Bitcoin Explorer
updatedAt: 2026-05-28T00:00:00Z
---

On November 28, 2012, Bitcoin reached block height 210,000, triggering the first programmed reduction in mining rewards. The block subsidy decreased from 50 to 25 bitcoin per block, cutting the rate at which new bitcoins entered circulation by half. This event, now known as a "halving," was hardcoded into Bitcoin's consensus rules by Satoshi Nakamoto and occurs every 210,000 blocks — approximately every four years.

![First halving block 210000](media/history/first-halving/first-halving-block.webp "Block 210,000 as displayed on a block explorer, marking the first halving at 25 BTC subsidy.")

## The Halving Mechanism

Bitcoin's issuance schedule is one of its most distinctive features. Unlike fiat currencies, where central banks can print money at will, Bitcoin's supply follows a predetermined, unchangeable curve. The block subsidy started at 50 BTC in January 2009 and halves every 210,000 blocks. The first halving at block 210,000 brought the subsidy to 25 BTC. This geometric decay means the total supply asymptotically approaches 21 million, with each halving making new bitcoin increasingly scarce.

The halving is enforced by consensus: every full node validates that the coinbase transaction in each block does not create more bitcoin than the current subsidy plus transaction fees. If a miner attempted to claim the old 50 BTC reward after block 210,000, all nodes would reject the block as invalid.

## Market Response

At the time of the first halving, bitcoin was trading at approximately $12–$13. The event had been anticipated by the community, but its immediate market impact was muted. However, the months following the halving saw one of the first major Bitcoin bull runs. By April 2013, the price had risen to over $260 — a more than 20x increase from the halving price.

Economists debate whether the post-halving price increases are causal or coincidental. The "stock-to-flow" model argues that reduced new supply, combined with steady or increasing demand, naturally pushes prices higher. Critics counter that the relationship is correlation, not causation, and that other factors — media attention, exchange development, macroeconomic conditions — drive the price.

## Mining Impact

The first halving had a significant impact on miners. Those operating with high electricity costs or inefficient hardware found their revenue suddenly halved. Some miners were forced to shut down, temporarily reducing the network hashrate. However, the decline was short-lived as more efficient mining hardware (FPGAs and early ASICs) was entering the market, and the rising bitcoin price compensated for the reduced block subsidy.

Bitcoin's difficulty adjustment mechanism ensured that blocks continued to be found every 10 minutes on average. When some miners left, the difficulty decreased, making it easier for remaining miners to find blocks. This automatic stabilization is a key feature of Bitcoin's design.

## Historical Significance

The first halving was a landmark event that validated Bitcoin's monetary policy. It demonstrated that the fixed supply schedule would be enforced by the network, regardless of miner sentiment or market conditions. The event also introduced the broader public to Bitcoin's unique monetary properties, sparking discussions about its potential as a store of value and its differences from traditional inflationary currencies.

Every halving since has drawn increasing attention, with the 2020 and 2024 halvings being major media events. The first halving, while less noticed by the mainstream at the time, was the crucial test that proved Bitcoin's monetary policy was not just theoretical — it was inevitable.

