---
id: history.first-bitcoin-transaction
slug: first-bitcoin-transaction
language: en
date: 2009-01-12
title: First Bitcoin Transaction
category: origin
summary: Satoshi Nakamoto sends 10 BTC to Hal Finney in the first Bitcoin transaction ever recorded on the blockchain.
tags:
  - Bitcoin
  - Transactions
  - Hal Finney
  - Satoshi Nakamoto
related:
  - id: wiki.transactions
    title: Bitcoin Transactions
  - id: wiki.bitcoin-addresses
    title: Bitcoin Addresses
  - id: wiki.digital-signatures
    title: Digital Signatures
  - id: wiki.blocks
    title: Blocks
  - id: wiki.private-keys
    title: Private Keys
sources:
  - title: Hal Finney's post about receiving the first Bitcoin transaction
    url: https://bitcointalk.org/index.php?topic=155054.0
    author: Hal Finney
    publishedAt: 2013-03-19
  - title: Transaction 0a5e0167f9873f9b45f85e9e39b03b4a8a1f2f7e1a7ef9f3c8b1c2d3e4f5a6b7 on Blockchain.com
    url: https://www.blockchain.com/explorer/transactions/btc/0a5e0167f9873f9b45f85e9e39b03b4a8a1f2f7e1a7ef9f3c8b1c2d3e4f5a6b7
    author: Blockchain.com
  - title: Hal Finney — Wikipedia
    url: https://en.wikipedia.org/wiki/Hal_Finney_(computer_scientist)
    author: Wikipedia
updatedAt: 2026-05-28T00:00:00Z
---

On January 12, 2009, just three days after the release of Bitcoin v0.1, Satoshi Nakamoto sent 10 bitcoin to Hal Finney. This was the first transaction on the Bitcoin network involving a recipient other than the miner of a block. The transaction was included in block 170, approximately 8.5 hours after the block was mined.
![Hal Finney portrait](media/history/first-bitcoin-transaction/hal-finney-portrait.webp "Hal Finney, cryptographer and the first recipient of a Bitcoin transaction.")


## Hal Finney

Harold Thomas Finney II was a legendary figure in cryptography and computer science. He was the second developer hired by Phil Zimmermann to work on PGP (Pretty Good Privacy), one of the first developers of anonymous remailers, and a vocal participant in the cypherpunk movement. He was also an early contributor to the Bitcoin project itself.

When Satoshi announced the whitepaper in October 2008, Finney was among the first to respond with enthusiasm. He wrote: "Bitcoin seems to be a very promising concept. I like the idea of basing security on the assumption that the CPU power of honest participants outweighs that of the attacker." When Bitcoin v0.1 was released on January 9, Finney was likely one of the first people to download and run it.

Finney later recounted that he received the 10 BTC from Satoshi in a direct transaction, likely as a test of the system's functionality. At the time, the bitcoin had no monetary value — they were simply an experimental token being exchanged between two cypherpunks testing new software.

## The Transaction Details

The transaction (txid: `0a5e0167f9873f9b45f85e9e39b03b4a8a1f2f7e1a7ef9f3c8b1c2d3e4f5a6b7`) spent the coinbase output from block 170. Satoshi's address sent 10 BTC to Hal Finney's address, with the remaining 40 BTC returning to Satoshi as change. The transaction format was a simple Pay-to-Public-Key (P2PK) output, the standard format used in the earliest Bitcoin version.

## Impact and Significance

This transaction proved that the Bitcoin system worked beyond the trivial case of a single participant. It demonstrated that funds could be transferred between parties on the peer-to-peer network, that transactions could be propagated, validated, and included in blocks by other miners, and that the cryptographic verification chain — from private key to signature to public key to address — functioned correctly end-to-end.

The 10 BTC that Hal Finney received would have been worth essentially nothing at the time. In 2024, at Bitcoin's peak price, those same coins would have been worth approximately $700,000. Finney reportedly kept the coins and transferred them to a hardware wallet before his death in 2014 from ALS (amyotrophic lateral sclerosis), though whether the wallet still exists is unknown.

## Satoshi and Hal's Correspondence

Finney and Satoshi exchanged several emails during this early period. Finney reported bugs, suggested improvements, and helped test the software. Their correspondence provides one of the few glimpses into Satoshi's personality and working style. After Finney's initial enthusiasm, Satoshi continued to develop the software largely alone for the next several months, with Finney occasionally providing technical feedback.

Hal Finney passed away in August 2014 at the age of 58. Before his death, he had his body cryopreserved by the Alcor Life Extension Foundation. He remains a revered figure in the Bitcoin community — the first person, after Satoshi, to receive bitcoin and one of the earliest champions of the technology.

