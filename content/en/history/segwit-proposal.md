---
id: history.segwit-proposal
slug: segwit-proposal
language: en
date: 2015-12-01
title: SegWit Proposal
category: protocol
summary: Pieter Wuille proposes Segregated Witness (BIP 141, 143, 144) to solve transaction malleability and scalability.
coverImage: media/wiki/history-segwit-proposal/history-segwit-proposal-hero.svg
sources:
  - title: BIP 141
    url: https://github.com/bitcoin/bips/blob/master/bip-0141.mediawiki
  - title: BIP 143
    url: https://github.com/bitcoin/bips/blob/master/bip-0143.mediawiki
  - title: BIP 144
    url: https://github.com/bitcoin/bips/blob/master/bip-0144.mediawiki
related:
  - wiki.segregated-witness
updatedAt: 2026-05-28T00:00:00Z
---

In December 2015, Pieter Wuille introduced Segregated Witness (SegWit) through three Bitcoin Improvement Proposals: BIP 141, BIP 143, and BIP 144. SegWit proposed a soft fork that would separate (segregate) the witness data (signatures and scripts) from the transaction data, effectively restructuring how blocks store information.

![Diagram illustrating the structure of a SegWit transaction showing the separation of witness data from the transaction body.](media/history/segwit-proposal/segwit-structure-diagram.webp "SegWit transaction structure diagram")

The primary goals of SegWit were twofold. First, it fixed transaction malleability, a long-standing bug that allowed third parties to alter transaction identifiers before confirmation. This was a critical requirement for second-layer protocols like the Lightning Network. Second, by moving witness data outside the main block structure, SegWit effectively increased the block size limit from 1 MB to approximately 4 MB, providing a scalability improvement.

SegWit also introduced a new weight-based block size measurement system, replacing the strict 1 MB limit. Each byte in the witness section counted as 1 weight unit, while each byte in the base block counted as 4 weight units, with a total block weight limit of 4 million units.

The proposal sparked intense debate within the Bitcoin community, with some advocating for larger hard-fork block size increases instead. This debate would eventually lead to the Bitcoin Cash fork in 2017.
