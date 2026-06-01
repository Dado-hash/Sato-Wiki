---
id: history.genesis-block
slug: genesis-block
language: en
date: 2009-01-03
title: Genesis Block Mined
category: origin
summary: Block 0 of the Bitcoin blockchain is mined by Satoshi Nakamoto, embedding the message "The Times 03/Jan/2009 Chancellor on brink of second bailout for banks."
tags:
  - Bitcoin
  - Genesis Block
  - Blockchain
  - Satoshi Nakamoto
related:
  - id: wiki.blocks
    title: Blocks
  - id: wiki.blockchain
    title: Blockchain
  - id: wiki.mining
    title: Mining
  - id: wiki.proof-of-work
    title: Proof of Work
  - id: wiki.transactions
    title: Bitcoin Transactions
sources:
  - title: Bitcoin Genesis Block — Blockchain.com
    url: https://www.blockchain.com/explorer/blocks/0
    author: Blockchain.com
  - title: The Times — Chancellor on brink of second bailout for banks
    url: https://www.thetimes.co.uk/article/chancellor-alistair-darling-on-brink-of-second-bailout-for-banks-n9l382mn62h
    author: The Times
    publishedAt: 2009-01-03
  - title: Genesis Block — Bitcoin Wiki
    url: https://en.bitcoin.it/wiki/Genesis_block
    author: Bitcoin Wiki contributors
updatedAt: 2026-05-28T00:00:00Z
---

On January 3, 2009, Satoshi Nakamoto mined block 0 of the Bitcoin blockchain — the genesis block. This was the first block in existence, the root of the entire chain from which all subsequent blocks would descend. The block carried a special message embedded in the coinbase transaction: "The Times 03/Jan/2009 Chancellor on brink of second bailout for banks."

![Genesis block landmark](media/history/genesis-block/genesis-block-landmark.webp "The genesis block as displayed on a block explorer, showing zero confirmations and no previous block hash.")

## The Timestamp Message

The message served multiple purposes. It proved that the block could not have been mined before January 3, 2009, establishing a verifiable timestamp. It also provided a political and philosophical statement: the traditional banking system was failing, and a decentralized alternative was now being launched. The reference to the British bank bailout was not incidental — it was the very crisis that motivated Bitcoin's creation.

The headline from The Times newspaper described Chancellor Alistair Darling's consideration of a second bailout package for British banks, which had been severely affected by the 2008 financial crisis. By embedding this headline in the genesis block, Nakamoto permanently linked Bitcoin's origin to the failure of trust in traditional finance.

## Technical Details

The genesis block is unique in several ways. Unlike all subsequent blocks, it has no previous block to reference — its `prev_block` field is all zeros. The coinbase transaction's output of 50 BTC cannot be spent because the genesis block is hardcoded into every Bitcoin client as a special case. The block timestamp is 1231006505 (UNIX time), and the difficulty target was set at the initial value of 1.

The input script of the coinbase transaction contains the famous Times headline as an ASCII string. This makes the genesis block not just a technical artifact but also a historical document, permanently recording the economic circumstances of its creation.

## The Mining Process

Mining the genesis block required finding a nonce that, when hashed with the rest of the block header, produced a hash below the target. The nonce that Satoshi found was 2083236893. This process, while trivial by today's standards (the difficulty was 1), represented the first proof of work on the Bitcoin network.

The genesis block contained only the coinbase transaction — no other transactions existed yet. The network was not yet operational in any meaningful sense: there were no other nodes, no peers, and no way to broadcast. The genesis block was created in isolation, the first step in bootstrapping a new financial system.

## Symbolic Significance

For the Bitcoin community, the genesis block has become a symbol of the project's origins and ideals. The embedded newspaper headline is frequently cited as evidence of Bitcoin's purpose: a response to monetary instability and the failure of fractional-reserve banking. Every Bitcoin block that follows — hundreds of thousands of them — traces its lineage back to this single block. Block explorers display it with special reverence, and cryptocurrency enthusiasts often visit it as a pilgrimage of sorts.

