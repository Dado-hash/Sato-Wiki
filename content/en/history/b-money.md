---
id: history.b-money
slug: b-money
language: en
date: 1998-11-27
title: Wei Dai Describes b-money
category: origin
summary: Wei Dai describes b-money, a proposal for pseudonymous parties to pay each other and enforce contracts without a trusted authority, with new money created through computational work.
tags:
  - b-money
  - Digital Cash
  - Cypherpunk
  - Wei Dai
sources:
  - title: "PipeNet 1.1 and b-money"
    url: https://mailing-list-archive.cryptoanarchy.wiki/archive/1998/11/0e3ccb59b898d6b3dc41250477bb70f593e29f5519439e1ad189bd7fa9234d45
    author: Wei Dai
    publishedAt: 1998-11-27
  - title: b-money
    url: http://www.weidai.com/bmoney.txt
    author: Wei Dai
  - title: b-money
    url: https://nakamotoinstitute.org/library/b-money/
    author: Wei Dai
  - title: B-money
    url: https://en.bitcoin.it/wiki/B-money
    author: Bitcoin Wiki contributors
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
related:
  - wiki.digital-signatures
  - wiki.proof-of-work
  - history.bitcoin-whitepaper
  - history.hashcash
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

On November 27, 1998 (UTC), Wei Dai announced a proposal called b-money on the cypherpunks mailing list, in a message titled "PipeNet 1.1 and b-money". The text of the proposal itself carries no date. The proposal describes how a group of untraceable pseudonyms could pay each other and enforce contracts among themselves without an outside authority. It opens by framing a crypto-anarchist community that would need a medium of exchange and a way to enforce agreements.

Dai described two protocols. The first assumed an anonymous broadcast channel that would be hard to make practical, and it kept a separate database of balances at every participant. The second used a set of account keepers who hold the balances and, in each period, agree on how much new money to create. Creation was decided by auction: anyone could bid an amount of b-money together with the solution to a problem from a fixed class, and the highest bids per unit of money were credited. Each period had four phases: planning, bidding, computation and money creation.

The design left important questions open. It depended on account keepers who had to reach agreement on balances and on the size of each money creation, and the text states that creation would go ahead whether or not the keepers reached a consensus on their quotas. It did not settle how keepers would reach that agreement, and the text describes no working implementation.

The Bitcoin whitepaper cites b-money as reference [1], in its discussion of how transactions must be publicly announced so that participants can agree on one order of payments. It gives the reference as "W. Dai, 'b-money,' http://www.weidai.com/bmoney.txt, 1998." Bitcoin takes a different route: instead of account keepers, the whitepaper uses a public chain of proof-of-work blocks that every node can check. Both designs use the cost of computation as a basis for trust, but the whitepaper removes the need for a fixed set of trusted keepers.
