---
id: wiki.myth-energy-waste
slug: myth-energy-waste
language: en
category: myths
title: '"Bitcoin wastes energy"'
description: Mining uses a large amount of electricity by design to make rewriting history costly, but whether that counts as waste is a value judgement.
difficulty: base
readTimeMinutes: 5
tags:
  - Myths
  - Mining
  - Energy
  - Proof of Work
related:
  - wiki.proof-of-work
  - wiki.mining
  - wiki.difficulty-adjustment
  - wiki.miner-incentives
  - wiki.halving
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: Cambridge Bitcoin Electricity Consumption Index
    url: https://ccaf.io/cbeci/index
    author: Cambridge Centre for Alternative Finance
  - title: "The Energy Consumption of Blockchain Technology: Beyond Myth"
    url: https://link.springer.com/article/10.1007/s12599-020-00656-x
    author: Johannes Sedlmeir, Hans Ulrich Buhl, Gilbert Fridgen, Robert Keller
  - title: Block Chain - Bitcoin Developer Guide
    url: https://developer.bitcoin.org/devguide/block_chain.html
    author: Bitcoin.org contributors
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

Partly true. Bitcoin mining uses a large amount of electricity by design, because proof of work makes miners spend energy to produce blocks. Whether that counts as waste is a value judgement, and this entry does not settle it.

Think of a lock whose strength comes from how much effort it takes to pick. The effort is the point, and it has to be paid again on every attempt. In Bitcoin the equivalent effort is electricity and hardware. Someone who wants to rewrite confirmed history has to match and then outpace the work of the honest network, so the energy spent is what makes a rewrite expensive.

The energy use is not set by how many payments the network processes. It depends on how much mining competition there is, which in turn depends on the block reward and the cost of electricity. A busy day and a quiet day can use similar energy while carrying very different numbers of payments.

Whether that electricity comes from clean sources depends on where mining happens, and it changes over time. Estimates of the mix differ, so any single answer should be read with its assumptions in view.

## medium

The figure most often quoted is an estimate, not a meter reading. The Cambridge Bitcoin Electricity Consumption Index (CBECI) models network power demand from the total hashrate and from the efficiency of the mining hardware likely to be in use. It publishes a daily best-guess estimate, with its model starting on 18 July 2010. Because the inputs are modelled, the output carries uncertainty. The index changes daily, so no figure is quoted here.

An earlier academic estimate gives a sense of scale. Sedlmeir and colleagues, in a 2020 paper in Business & Information Systems Engineering, estimated Bitcoin's annual electricity use at 60 to 125 TWh. They placed that range alongside the consumption of countries such as Austria and Norway. The same authors argue that blanket statements about blockchain energy use should be reviewed with care.

Two parts of any such estimate are modelled rather than measured. One is the network's total hashrate, which can be observed from block production but must be converted into power with assumptions about hardware efficiency. The other is the share of that power from each energy source, which is not measured directly at the network level. Estimates of the mix therefore depend on the method used.

Energy per transaction is high because the network processes few payments per second. Sedlmeir and colleagues note that the theoretical throughput of Bitcoin is limited by block parameters. Their upper bound on mining energy depends on the electricity price and the block reward rather than on the number of transactions.

The argument therefore has two parts that are often mixed together. The first is whether the security is worth the energy, which is a question about values. The second is whether the energy is wasted, which depends on whether another design could give the same security at lower cost. The entry does not settle either part.

## advanced

The strongest version of the claim is that mining spends real resources for a single purpose, securing the ledger, and that much of that spending is a race between miners that adds nothing for users. If the same security could be had with less energy, the cost is avoidable, and presenting it as a necessary feature is an excuse.

The reply above answers in two ways, and both invite serious objection. First, the security argument assumes that a costly race is the only practical way to make rewriting history expensive. Sedlmeir and colleagues make the more general point that blockchain systems differ widely in energy use, so one figure for "blockchain" tells little. A critic can accept that and still argue that Bitcoin's own design, with its fixed reward and open competition, is what drives its consumption. The defence then rests on whether that security is worth the price, which is a value judgement.

Second, the claim that energy use does not scale with transactions is true of the protocol, but a critic can turn it around. If the energy per payment is very high, then the cost of each payment is high too, and the network's security budget is spent whether or not the system has many users. The defender can answer that the security is a shared resource for all holders of the ledger, and that this is the purpose of the spending.

Third, the claims about the energy mix are the least settled. Shares of renewable power depend on modelled assumptions, and different methods give different answers. A critic can argue that a clean-energy claim cannot offset a large consumption figure until it is measured independently. The reply is that the mix moves with the location of mining and that good measurements are hard to make.

The claim would become true, in the sense of waste, if a ledger with comparable security and wide acceptance were shown to need much less energy, and if the security that Bitcoin provides were shown not to be needed by the people who rely on it. The claim would become false if evidence showed that the energy is needed to hold the security that users value, and that it is not spent on competition for its own sake. Both outcomes depend on measurement and on how people weigh security against cost, not on the protocol alone.
