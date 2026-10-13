---
id: wiki.myth-too-slow
slug: myth-too-slow
language: en
category: myths
title: '"Bitcoin is too slow to be useful"'
description: "Partly true: the base layer confirms only a few transactions per second by design, and layers built on top handle smaller payments with their own trade-offs."
difficulty: base
readTimeMinutes: 5
tags:
  - Myths
  - Scaling
  - Lightning
  - Blocks
related:
  - wiki.blocks
  - wiki.fee-market
  - wiki.lightning-network
  - wiki.weight-units
  - wiki.payment-channels
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: "The Bitcoin Lightning Network: Scalable Off-Chain Instant Payments"
    url: https://lightning.network/lightning-network-paper.pdf
    author: Joseph Poon and Thaddeus Dryja
    publishedAt: 2016-01-14
  - title: Bitcoin Core - Chain Parameters (chainparams.cpp)
    url: https://github.com/bitcoin/bitcoin/blob/master/src/kernel/chainparams.cpp
    author: Bitcoin Core contributors
  - title: Bitcoin Core - Consensus Parameters (consensus.h)
    url: https://github.com/bitcoin/bitcoin/blob/master/src/consensus/consensus.h
    author: Bitcoin Core contributors
  - title: Bitcoin Developer Guide - Block Chain
    url: https://developer.bitcoin.org/devguide/block_chain.html
    author: Bitcoin.org contributors
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

Partly true. The base layer, which is the main Bitcoin chain, is slow for everyday payments. A new block arrives about every ten minutes and holds only a limited amount of data, so the chain handles only a few transactions per second. It is still the place where payments become final, and where large or important transfers settle, because that is what it is built for. Small everyday payments usually run on layers built on top of it, such as the Lightning Network, which are faster and cheaper but carry trade-offs of their own.

The limit is deliberate. Keeping blocks small makes it cheaper for ordinary people to run a full node, and nodes are what keep Bitcoin's rules honest. Bigger blocks would make it faster to move coins, but they would need more powerful computers to check, and fewer people could run a node. Speed and the ability for anyone to verify the chain pull against each other.

So the honest answer is that Bitcoin is slow for many purposes, and that slowness is a choice about what the base layer is for.

## medium

Two parameters set the base layer's pace and capacity. The target interval between blocks is ten minutes, a value Bitcoin Core sets as the proof-of-work target spacing for mainnet. Each block may hold at most 4,000,000 weight units under the current consensus code. Transactions differ in size, so the number of transactions per block varies, and a few per second is a rough average rather than a fixed rate. The Lightning Network paper, a January 2016 draft written before the current limit, described Bitcoin as supporting "less than 7 transactions per second with a 1 megabyte block limit". That figure is approximate and out of date, so read it as a rough scale rather than a measurement.

Confirmation and settlement are different things. A transaction is confirmed when it appears in a block. It becomes practically final only after more blocks are built on top, because each extra block makes a reversal more costly. The whitepaper analyses how the chance that an attacker catches up falls quickly as blocks are added. A payment can therefore be visible within minutes and still take longer before the seller can be confident the coins will stay put.

The limit also protects the network. The Lightning paper argues that full validation must stay cheap, so that consumer hardware on a home connection can check the chain. If blocks grew very large, only a few parties could validate them, and trust would drift toward those parties. Bitcoin keeps the base layer small so that the checks remain open to many people.

The Lightning Network moves repeated payments into channels between two parties, and only the opening and closing of a channel needs to appear on the chain. The paper describes payments that can be routed across channels and enforced on-chain through timelocks if a party does not cooperate. Channels have costs of their own. Both parties lock funds, and a payment across several channels needs enough liquidity on every hop of the route.

## advanced

The strongest version of the claim is that Bitcoin cannot serve as a payment system for ordinary life. At a few transactions per second, the base layer can carry only a small share of payments, and if the layers built on top fail or cost too much, the only remaining option is an expensive on-chain transaction. On this view, the design choice to keep blocks small is a permanent ceiling rather than a temporary one, and everything else is a workaround.

There is a serious point there. Blocks are limited, so when demand exceeds the space, users compete with fees (see the fee market entry). Lightning depends on channel liquidity, and a payment that crosses many channels is only as available as the route it takes. Channels also need on-chain transactions to open and close, so heavy use of the layer still produces activity on the base chain.

The reply has three parts. First, the base layer does not need to carry everything. Its job is to be a settlement layer where ownership is recorded and disputes are resolved, and its designers wanted it to stay cheap to verify. Second, raising the limit is possible but is a deliberate change: the developer guide gives raising the block size above 1 MB as an example of a change that requires a hard fork, which every node must adopt. Third, how much capacity is enough is a social question, and the protocol does not answer it on its own.

The objections are that the reply can read as an excuse. A consensus change is slow to coordinate, and the cost of waiting falls on users who need to pay now. Layers add their own complexity and failure modes. The Lightning paper assumed that the chain would stay cheap to verify while demand grew, and that is a bet about future hardware and network conditions rather than a proof. A critic can accept all of the design logic and still ask whether it serves the payments people actually make.

For the claim to become true, the base layer would need to stay at its current capacity while the layers built on it fail to serve everyday payments at acceptable cost and safety, pushing users toward custodians. For the claim to be clearly false, the layers would need to handle everyday payments at low cost while keeping the self-custody and safety properties that make the base layer worth using. Measured confirmation times and fees at peak demand would be the practical test.
