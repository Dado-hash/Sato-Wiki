---
id: history.lightning-mainnet
slug: lightning-mainnet
language: en
date: 2018-03-01
title: Lightning Network Goes Live on Mainnet
category: protocol
summary: The Lightning Network launches on Bitcoin mainnet with LND 0.4, enabling instant, low-cost payments through a second-layer protocol.
sources:
  - title: LND Release v0.4
    url: https://github.com/lightningnetwork/lnd/releases/tag/v0.4-beta
  - title: Lightning Network Overview
    url: https://lightning.network/
related:
  - wiki.lightning-network
updatedAt: 2026-05-28T00:00:00Z
---

In March 2018, the Lightning Network (LN) became operational on Bitcoin mainnet with the release of LND 0.4-beta, the first production-grade implementation of the protocol. Developed by Lightning Labs, LND provided a complete node implementation with channel management, routing, and payment processing capabilities.

![Chart showing Lightning Network node and channel count growth from 2018 onward.](media/history/lightning-mainnet/ln-network-growth.webp "Lightning Network growth chart")

The Lightning Network addressed Bitcoin's scalability limitations by enabling off-chain payment channels. Users could open bidirectional channels by committing funds to a multi-signature address on the Bitcoin blockchain, then conduct unlimited transactions off-chain with instant settlement. Only the final channel state would be broadcast to the main chain.

Early adoption was gradual but steady. By late 2018, the network comprised approximately 2,500 nodes and 6,000 channels with a total capacity of around 100 BTC. Developers built wallets like Zap, mobile apps, and point-of-sale systems, demonstrating real-world use cases for micropayments.

The mainnet launch marked a transition from theory to practice for Bitcoin's most anticipated scaling solution, proving that Layer 2 could work securely on the existing base layer.
