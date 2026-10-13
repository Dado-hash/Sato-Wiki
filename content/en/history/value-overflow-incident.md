---
id: history.value-overflow-incident
slug: value-overflow-incident
language: en
date: 2010-08-15
title: Value Overflow Incident in Block 74638
category: security
summary: A transaction in block 74638 creates about 184 billion BTC through an integer overflow, and a patch released the same day, version 0.3.10, rejects such transactions.
tags:
  - Security
  - Integer Overflow
  - Consensus
  - Soft Fork
sources:
  - title: "Strange block 74638"
    url: https://bitcointalk.org/index.php?topic=822.0
    author: jgarzik
    publishedAt: 2010-08-15
  - title: "Version 0.3.10 - block 74638 overflow PATCH!"
    url: https://satoshi.nakamotoinstitute.org/posts/bitcointalk/376/
    author: Satoshi Nakamoto
    publishedAt: 2010-08-15
  - title: "Re: overflow bug SERIOUS"
    url: https://satoshi.nakamotoinstitute.org/posts/bitcointalk/387/
    author: Satoshi Nakamoto
    publishedAt: 2010-08-16
  - title: CVE-2010-5139
    url: https://en.bitcoin.it/wiki/CVE-2010-5139
    author: Bitcoin Wiki contributors
related:
  - wiki.consensus-rules
  - wiki.forks-and-soft-forks
  - wiki.proof-of-work
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

On August 15, 2010, a developer noticed that block 74638 contained a transaction that created about 184 billion BTC. The transaction had two outputs of roughly 92.2 billion BTC each, and their sum overflowed the fixed-width integer the software used. The issue was raised the same day in the bitcointalk.org thread "Strange block 74638". The flaw is tracked as CVE-2010-5139.

The client checked each output for a negative value on its own, but it did not check whether the outputs added together overflowed. Two outputs that each looked valid summed to a negative number, which the software accepted. The bug was in the validation code, not in the chain's overall design.

Satoshi Nakamoto posted "Version 0.3.10 - block 74638 overflow PATCH!" on August 15, 2010, at 23:48 UTC. The patch changed the consensus rules so that nodes reject transactions with overflowing outputs. The Bitcoin Wiki describes the change as a soft fork. Nodes that had not upgraded kept building on the bad chain for a while, so the network briefly split into two competing histories.

On August 16, Satoshi wrote that the network had overtaken the bad chain "somewhere around 74689". The Bitcoin Wiki gives block 74691 as the height at which all nodes accepted the good chain, so the exact height is approximate in the sources. Once the good chain was longer, the transaction and the coins it created no longer existed on the main chain. The incident shows how consensus rules decide which transactions count and why upgrades had to be fast.

For Bitcoin's design, the incident shows the rule in the whitepaper that the longest chain of proof of work is the authoritative one. That rule let the corrected chain replace the bad one without any central action, although only after nodes had upgraded. The patch is also an early example of a soft fork, a change that tightens the rules so that older nodes still accept the new blocks.
