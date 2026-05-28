---
id: history.lightning-whitepaper
slug: lightning-whitepaper
language: en
date: 2017-08-01
title: Lightning Network Whitepaper
category: protocol
summary: Joseph Poon and Thaddeus Dryja publish the Lightning Network whitepaper, proposing a second-layer scaling solution for Bitcoin.
coverImage: media/wiki/history-lightning-whitepaper/history-lightning-whitepaper-hero.svg
sources:
  - title: Lightning Network Whitepaper
    url: https://lightning.network/lightning-network-paper.pdf
  - title: BOLT Specifications
    url: https://github.com/lightning/bolts
related:
  - wiki.lightning-network
updatedAt: 2026-05-28T00:00:00Z
---

In August 2017, Joseph Poon and Thaddeus Dryja published "The Bitcoin Lightning Network: Scalable Off-Chain Instant Payments," introducing a second-layer protocol designed to address Bitcoin's scalability challenges. While early drafts circulated in late 2015 and early 2016, the canonical whitepaper is dated to this period.
![Diagram of a Lightning Network payment channel network routing a payment across multiple participants.](media/history/lightning-whitepaper/lightning-network-diagram.webp "Lightning Network routing diagram")


The whitepaper proposed a network of bidirectional payment channels that could route payments across multiple participants without settling each transaction on the Bitcoin blockchain. By moving most transactions off-chain and only settling the final balance, the Lightning Network could theoretically process millions of payments per second with near-instant finality and minimal fees.

Key innovations included Hashed Timelock Contracts (HTLCs) for atomic routing, commitment transactions for channel state management, and onion routing for payment privacy. The protocol required SegWit to be active on Bitcoin, creating a symbiotic relationship between the two technologies.

The Lightning Network whitepaper became one of the most influential documents in Bitcoin's history, spawning multiple interoperable implementations (LND, c-lightning, Eclair) and a growing ecosystem of applications built on top of the payment layer.
