---
id: history.runes-launch
slug: runes-launch
language: en
date: 2024-04-01
title: Runes Protocol Launch
category: protocol
summary: Casey Rodarmor launches the Runes protocol, enabling fungible token creation on Bitcoin using the UTXO model.
sources:
  - title: Runes Documentation
    url: https://docs.ordinals.com/runes.html
  - title: Runes Specification
    url: https://github.com/ordinals/ord/blob/master/src/runes.rs
related:
  - wiki.utxo-model
  - wiki.taproot
updatedAt: 2026-05-28T00:00:00Z
---

In April 2024, Casey Rodarmor launched the Runes protocol, a new standard for creating fungible tokens on the Bitcoin blockchain. Runes launched concurrently with the fourth halving at block 840,000, in a coordinated event that generated significant attention and activity.

![Example of a Runes protocol transaction showing OP_RETURN token operation encoding.](media/history/runes-launch/runes-transaction-example.webp "Runes transaction example")

Runes addressed limitations of earlier Bitcoin token protocols. Unlike BRC-20, which relied on Ordinals inscriptions and created significant blockchain bloat through its off-chain state model, Runes used Bitcoin's native UTXO model directly. Each Rune token balance was committed to a Bitcoin transaction output, enabling clean integration with Bitcoin's existing infrastructure.

The protocol's design prioritized simplicity and efficiency. Runes transactions used OP_RETURN outputs to encode token operations — etching new tokens, minting, and transferring — with minimal on-chain footprint. This approach reduced the data burden on the blockchain compared to inscription-based token protocols.

Runes launched with immense initial hype. Several prominent projects conducted mints and airdrops on the first day, generating millions of dollars in transaction fees. While early enthusiasm moderated over time, Runes established a foundation for fungible token activity on Bitcoin, complementing the non-fungible use cases enabled by Ordinals.
