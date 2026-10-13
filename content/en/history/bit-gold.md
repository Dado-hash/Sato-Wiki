---
id: history.bit-gold
slug: bit-gold
language: en
date: 2005-12-29
title: Nick Szabo Publishes Bit Gold
category: origin
summary: Nick Szabo publishes the "Bit gold" post on his blog Unenumerated, proposing unforgeable digital tokens built from chained proofs of work and a distributed title registry.
tags:
  - Bit Gold
  - Nick Szabo
  - Proof of Work
  - Digital Cash
sources:
  - title: Bit gold
    url: https://unenumerated.blogspot.com/2005/12/bit-gold.html
    author: Nick Szabo
  - title: Bit Gold
    url: https://nakamotoinstitute.org/library/bit-gold/
    author: Nick Szabo
    publishedAt: 2005-12-29
  - title: Bit Gold
    url: https://en.bitcoin.it/wiki/Bit_Gold
    author: Bitcoin Wiki contributors
related:
  - wiki.proof-of-work
  - wiki.digital-signatures
  - history.rpow
  - history.b-money
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

Nick Szabo published a post titled "Bit gold" on his blog Unenumerated in December 2005. The post is dated December 29, 2005: the earliest archived copy, captured by the Wayback Machine on March 29, 2006, shows that date above the post. The live page now shows December 27, 2008, the date Blogger gives the post after a later repost. The post opens by saying that its author "hit upon the idea of bit gold" long before, and it argues that money's value depends on trust in a third party.

The proposal was a protocol for creating unforgeable digital tokens online. Each new string of bits would be the output of a computational puzzle, a proof of work that is costly to produce and cheap to check. The challenge for each puzzle is the string created just before it, so every token depends on the one before. The proof is timestamped by several services and recorded in a distributed property title registry. Ownership is shown by the unbroken chain of digital signatures in that registry, and anyone can check a token's challenge, proof and timestamp.

Szabo listed the main limits himself: the security of the scheme depends on how well trust is spread across the timestamp services and the registry, and on the problem of machine architecture. The post does not describe a finished system with running software, and it leaves open how the registry would be kept honest in practice. The copy archived in March 2006 already mentions Hal Finney's RPOW.

The Bitcoin whitepaper does not cite bit gold. Its references are b-money, Hashcash and timestamping research, and the bit gold post is not among them. Still, bit gold and Bitcoin share a design pattern: a chain of proofs of work, timestamped records and ownership shown by signatures. Bitcoin's whitepaper presents its own version of that pattern, with a public chain of blocks in place of the title registry.
