---
id: wiki.weight-units
slug: weight-units
language: en
category: protocol
title: Weight Units and Virtual Bytes
description: How Bitcoin measures transaction and block size since SegWit, and why fee rates are quoted in virtual bytes.
difficulty: base
readTimeMinutes: 5
tags:
  - Weight
  - Virtual Bytes
  - SegWit
  - Fees
  - Block Size
related:
  - wiki.segregated-witness
  - wiki.transaction-fees
  - wiki.blocks
  - wiki.transactions
  - wiki.fee-market
sources:
  - title: "BIP 141: Segregated Witness (Consensus layer)"
    url: https://github.com/bitcoin/bips/blob/master/bip-0141.mediawiki
    author: Eric Lombrozo, Johnson Lau, Pieter Wuille
    publishedAt: 2015-12-21
  - title: Bitcoin Core consensus constants
    url: https://github.com/bitcoin/bitcoin/blob/master/src/consensus/consensus.h
    author: Bitcoin Core contributors
  - title: Weight units
    url: https://en.bitcoin.it/wiki/Weight_units
    author: Bitcoin Wiki contributors
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

In Bitcoin, the size of a transaction is measured in two related units. Weight units (WU) are what the protocol uses to limit blocks. Virtual bytes (vB) are weight units divided by four, and fee rates are quoted in them. Both units exist because the SegWit upgrade changed how signature data is stored.

Weight counts the non-witness part of a transaction four times and the witness part, which holds the signatures, once. A transaction with no witness data therefore has a virtual size equal to its byte count. A SegWit transaction has part of its data counted at a quarter of the usual rate, so its virtual size is smaller than its raw size.

A block may contain at most 4,000,000 weight units. This replaced the older limit of one megabyte of serialized data. A block full of witness data can be larger than one megabyte in raw bytes, while a block made only of legacy data cannot exceed one million bytes.

Example with round numbers. Suppose a transaction has 200 bytes outside its witness and 100 bytes of witness, for a total of 300 bytes. Its weight is 200 x 3 + 300 = 900 WU, so its virtual size is 900 / 4 = 225 vB. If it pays 4,500 satoshis, its fee rate is 4,500 / 225 = 20 sat/vB.

## medium

The definitions come from BIP 141. The base size is the transaction serialized without its witness data, and the total size includes the witness. Weight is the base size times three, plus the total size. Virtual size is the weight divided by four, rounded up to the next whole number. Take a transaction with 150 bytes of base data and 109 bytes of witness. Its total size is 259 bytes, its weight is 150 x 3 + 259 = 709 WU, and its virtual size is 709 / 4 = 177.25, which rounds up to 178 vB.

The block limit uses the same arithmetic. The weight of a block is computed from its base and total sizes, so the header and the coinbase transaction are part of it, and the sum must not exceed 4,000,000. BIP 141 explains why one composite limit was chosen instead of separate limits for base data and witness data. Two separate limits would make it very hard for miners to pick the most profitable set of transactions, and wallets could not easily know which constraint would bind when their transaction reached a block.

The witness is discounted because of what it does. A transaction's effects are determined by the outputs it spends and the outputs it creates. Signatures are needed to check that a spend was authorized, but they do not change what the transaction does. BIP 141 lists the discounting of witness data among the constraints a soft fork can relax, since moving signatures into a separate structure lets the same rules count them differently. The practical result is more room in each block for the same kind of activity, and a lower cost for transactions that carry their signatures in the witness.

This is why the fee rate, not the raw size, is the figure to compare. Dividing the fee by the virtual size puts transactions with different structures on one scale. It is also the measure that miners use when they decide which transactions fill a block.

## advanced

The numbers rest on two serializations of each transaction. The base size is the transaction as a node that does not understand SegWit would see it, without the marker, the flag and the witness section. The total size uses the extended serialization described in BIP 144, which includes the witness. The formula is applied to each transaction, and to a block by summing the same two quantities over the header and all of its transactions.

Because the witness is separate, the weight of a transaction depends on how its signatures are encoded. A change to a witness element changes the total size and therefore the weight, while the txid stays the same. A wallet knows the base size of its transaction from its inputs and outputs, and it can estimate the witness size from the script types it spends. That estimate is what allows it to set a fee before it signs.

The coinbase transaction counts toward the block weight like any other transaction. When a block contains witness transactions, the coinbase carries a witness commitment, an output that commits to the wtxids of the block's transactions. That output is base data, so it adds to the weight of the block. The coinbase witness itself is discounted like any other witness.

Signature operations have a separate limit, which BIP 141 also changed. The block limit for sigops is 80,000, and operations in legacy scripts are counted at four times their previous value. A P2WPKH input counts as one sigop, and the checks inside a P2WSH witness script are counted as they were before. The sigop rule therefore follows the same logic as the size rule: witness data is cheaper to validate in this accounting.

Consensus and policy both use these numbers. Consensus sets the 4,000,000 weight limit that every valid block must satisfy. Full nodes also apply relay policy to standard transactions, so a transaction can be valid for a block and still not be relayed by default. Miners ordering transactions by fee rate use virtual size as their denominator, which is why the vbyte is the unit that matters for fee markets.

The formula also explains what the discount protects. Non-witness data determines the transaction ids and the outputs that later transactions can spend, so it costs four units. Witness data is needed to verify signatures, but it does not change the txid, so it costs one.
