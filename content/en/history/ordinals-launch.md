---
id: history.ordinals-launch
slug: ordinals-launch
language: en
date: 2023-01-21
title: Ordinals Protocol Launch
category: community
summary: Casey Rodarmor launches the Ordinals protocol, enabling permanent data inscriptions on the Bitcoin blockchain.
sources:
  - title: Ordinals Documentation
    url: https://docs.ordinals.com/
  - title: Ordinal Theory Handbook
    url: https://www.ordinaltheory.com/
related:
  - wiki.segregated-witness
  - wiki.taproot
updatedAt: 2026-05-28T00:00:00Z
---

On January 21, 2023, Casey Rodarmor launched the Ordinals protocol, introducing a novel system for assigning unique identifiers to individual satoshis and inscribing arbitrary data onto them. Ordinals leveraged Bitcoin's Taproot upgrade and SegWit to embed data — images, text, audio, or applications — directly into the Bitcoin blockchain.
![An example Ordinals inscription showing embedded artwork permanently stored on the Bitcoin blockchain.](media/history/ordinals-launch/ordinals-inscription-example.webp "Ordinals inscription example")


The protocol worked through two key innovations. First, Ordinal Theory assigned each satoshi a unique number based on the order it was mined, creating a system where individual satoshis could be tracked and transferred. Second, inscriptions used Taproot's witness data to store content, with the entire inscribed data committed to a Bitcoin transaction output that could be spent and transferred.

Ordinals sparked intense debate within the Bitcoin community. Supporters saw them as a realization of Bitcoin's potential as a data storage and settlement layer, drawing parallels to colored coins and earlier experiments. Critics argued that inscriptions were spam that consumed block space and drove up fees for regular transactions.

Despite the controversy, Ordinals drove significant innovation. The demand for block space led to higher fee revenue for miners. Inscriptions reached millions within the first year, with popular collections like Bitcoin Frogs and Taproot Wizards demonstrating the breadth of creative applications. The protocol established a vibrant ecosystem of wallets, marketplaces, and indexers.
