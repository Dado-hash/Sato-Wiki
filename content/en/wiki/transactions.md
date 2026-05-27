---
id: wiki.transactions
slug: transactions
language: en
category: protocol
title: Bitcoin Transactions
description: The data structure Bitcoin uses to spend previous outputs, create new outputs, and express authorization.
coverImage: media/wiki/transactions/transaction-flow.svg
difficulty: advanced
readTimeMinutes: 8
tags:
  - Transactions
  - Payments
  - UTXO
  - Script
  - Mempool
related:
  - wiki.utxo-model
  - wiki.bitcoin-script
  - wiki.transaction-fees
  - wiki.mempool
  - wiki.blocks
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: Bitcoin Developer Reference - Transactions
    url: https://developer.bitcoin.org/reference/transactions.html
    author: Bitcoin.org contributors
  - title: Bitcoin Developer Guide - Transactions
    url: https://developer.bitcoin.org/devguide/transactions.html
    author: Bitcoin.org contributors
  - title: BIP 141 - Segregated Witness
    url: https://github.com/bitcoin/bips/blob/master/bip-0141.mediawiki
    author: Eric Lombrozo, Johnson Lau, Pieter Wuille
updatedAt: 2026-05-27T00:00:00Z
---

## base

A Bitcoin transaction is a signed instruction that spends existing bitcoin and creates new places where bitcoin can be spent later. It does not move balances between accounts. Instead, it consumes previous transaction outputs and creates new outputs with their own spending conditions.

![Transaction input and output flow](media/wiki/transactions/transaction-flow.svg "A transaction consumes previous outputs as inputs, creates new outputs, and leaves the difference as the miner fee.")

Most payments have at least one input and two outputs: one output pays the recipient, and another sends change back to the spender's wallet. The wallet signs the inputs to prove it can satisfy the conditions on the outputs being spent.

Nodes check transactions before relaying them and again when a block includes them. They verify that the inputs exist, have not already been spent, satisfy their scripts, and do not create more satoshis than they spend. A transaction becomes harder to reverse as blocks are added on top of the block that contains it.

## medium

At the raw data level, a transaction contains a version, a list of inputs, a list of outputs, and a locktime. Each input points to a previous output using an outpoint: the previous transaction ID plus the output index. Each output contains a value in satoshis and a locking script, often called `scriptPubKey`.

The fee is not written as a separate field. Nodes calculate it as the total value of the spent inputs minus the total value of the new outputs. If the inputs are worth 100,000 sats and the outputs total 98,500 sats, the fee is 1,500 sats.

The unlocking data depends on the output type being spent. Legacy inputs use `scriptSig`; SegWit inputs place signatures and other witness data in a separate witness structure. This separation changes how transaction weight and identifiers are calculated, but the basic idea remains the same: inputs prove authority, outputs define future authority.

Transactions can be valid by consensus but still not be relayed by default mempool policy. Consensus rules decide whether a transaction may be included in a block. Policy rules decide whether a node wants to keep or forward an unconfirmed transaction before it is mined.

## advanced

Transaction validation is a state transition over the UTXO set. For each non-coinbase input, a full node looks up the referenced outpoint, verifies that it is unspent, executes the required script checks, and then marks that coin as spent if the transaction is connected in a valid block. The transaction's outputs become new UTXOs.

Several fields only make sense in context. `nLockTime` can prevent a transaction from being final until a height or time threshold is reached. Input sequence values can opt into relative timelocks and replacement policy. These mechanisms do not bypass signatures; they add timing constraints to when an otherwise valid spend can be accepted.

Transaction identifiers are also subtle. The traditional `txid` commits to the non-witness serialization. SegWit transactions additionally have a `wtxid` that commits to witness data. This distinction reduces unwanted transaction malleability for SegWit spends while preserving compatibility with older transaction commitments.

Coinbase transactions are the exception to ordinary input rules. They create the block subsidy plus collected fees and have a special coinbase input instead of spending a previous outpoint. Their outputs cannot be spent until they mature, which prevents short reorgs from immediately invalidating newly created mining rewards that have already been spent.

The important mental model is that transactions are not messages of intent. They are executable claims on previous outputs. If the claim is valid under the current rules and becomes part of the valid chain with sufficient work behind it, the UTXO set changes accordingly.
