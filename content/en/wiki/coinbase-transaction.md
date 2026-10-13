---
id: wiki.coinbase-transaction
slug: coinbase-transaction
language: en
category: protocol
title: Coinbase Transaction
description: The first transaction in every block, which creates the new bitcoin of the block subsidy and collects the fees of the block.
coverImage: media/wiki/coinbase-transaction/coinbase-transaction-hero.svg
difficulty: base
readTimeMinutes: 4
tags:
  - Coinbase
  - Mining
  - Block Reward
  - Consensus
related:
  - wiki.blocks
  - wiki.block-subsidy
  - wiki.mining
  - wiki.segregated-witness
  - wiki.utxo-model
  - wiki.block-header
sources:
  - title: Bitcoin Developer Guide - Block Chain
    url: https://developer.bitcoin.org/devguide/block_chain.html
    author: Bitcoin.org contributors
  - title: Bitcoin Developer Reference - Block Chain
    url: https://developer.bitcoin.org/reference/block_chain.html
    author: Bitcoin.org contributors
  - title: "BIP 34: Block v2, Height in Coinbase"
    url: https://github.com/bitcoin/bips/blob/master/bip-0034.mediawiki
    author: Gavin Andresen
  - title: "BIP 141: Segregated Witness (Consensus layer)"
    url: https://github.com/bitcoin/bips/blob/master/bip-0141.mediawiki
    author: Eric Lombrozo
  - title: Bitcoin Core transaction primitives
    url: https://github.com/bitcoin/bitcoin/blob/master/src/primitives/transaction.h
    author: Bitcoin Core contributors
  - title: Bitcoin Wiki - Coinbase
    url: https://en.bitcoin.it/wiki/Coinbase
    author: Bitcoin Wiki contributors
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

Every block starts with a special transaction called the coinbase transaction. A miner creates it while assembling a block, and it is the only transaction that does not spend existing outputs. Its single input has a null outpoint, a placeholder with an all-zero hash and the largest possible index, so it points to nothing. This is how the coinbase creates new bitcoin.

The coinbase collects the block reward: the block subsidy plus the fees paid by the other transactions in the block. Nodes reject the block if the coinbase claims more than that total. A miner may claim less, and the difference is simply lost.

Coinbase outputs cannot be spent until they are 100 blocks deep. The rule protects the network from reorganizations. If the block that paid the miner is replaced by a competing branch, its new coins disappear with it, so spending them right away could invalidate other transactions.

The data field of the coinbase input is otherwise free-form. Since 2013 the block height must appear at the start of it, which makes every coinbase unique. Miners can also place arbitrary bytes there, which is why the genesis block carries a newspaper headline.

## medium

The coinbase input is unusual in its structure as well as its purpose. Its outpoint is null: the hash is 32 zero bytes and the index is 0xffffffff. Because there is no previous output, there is nothing to look up in the UTXO set and no signature to check.

The height rule comes from BIP 34. The first item of the coinbase script must be the block height, encoded as a minimal serialized script number in little-endian order. BIP 34 was a soft fork: after its activation, blocks that did not follow the rule were rejected. Because two blocks at different heights cannot have the same coinbase contents, each coinbase transaction is unique.

The rest of the coinbase script is space the miner can use. Miners use it as an extra nonce: the header nonce is only 32 bits, so miners change the coinbase data, which changes the Merkle root and therefore the header hash. The Developer Reference describes this approach for searching the full nonce range. The coinbase can also carry arbitrary bytes, as the genesis block's headline shows.

The witness commitment comes from BIP 141. When a block contains segwit transactions, the coinbase must include an output whose script begins with 0x6a24aa21a9ed. That is the OP_RETURN opcode, a push of 36 bytes, and the 4-byte commitment header 0xaa21a9ed. The header is followed by a 32-byte hash of the witness root and a reserved value. The reserved value is 32 bytes that sit in the coinbase input witness. Nodes check this commitment, so the witness data is bound to the block's proof of work.

A coinbase that pays too much is invalid, and so is a block with a broken witness commitment. A coinbase that pays too little is valid, but the unclaimed value is destroyed.

## advanced

Validation treats the coinbase as a special case. It has no inputs to check against the UTXO set, and its value check, unlike any ordinary transaction, depends on the rest of the block. Every full node repeats this calculation itself, so no miner can get more than the rule allows by asserting a larger total. The node can only compute the allowed total after it knows the fees of all other transactions, so the coinbase check comes near the end of block validation. In that sense the coinbase is the single place where the total effect of a block meets the monetary schedule.

Maturity is enforced when a later transaction spends a coinbase output. The output cannot be used until at least 100 blocks have been built on top of the block that created it. The waiting period means that a short reorganization cannot invalidate a transaction that already spent coinbase coins.

BIP 34 also serves uniqueness. Because the height changes from block to block, the coinbase contents change too, so the txid of each coinbase is different. The coinbase txid is always the first leaf of the block's Merkle tree, so the coinbase is also the first item committed by the header.

The witness commitment is a hash of two values: the witness root, which is the Merkle root of all wtxids, and the reserved value. BIP 141 defines the wtxid of the coinbase itself as 32 zero bytes, which avoids a circular dependency. The commitment is embedded in the coinbase instead of the header, which lets the change be a soft fork: old nodes see only an extra output they do not check. The reserved value is kept free for future soft forks. BIP 141 states that commitments not needed for consensus, such as merge-mining data, must not use it, so that later upgrades remain possible.

Changing the coinbase changes the Merkle root and therefore the header hash, which is why extra-nonce rolling works without any change to the consensus rules.

The coinbase makes miners the only source of new coins. The consensus rules cap what they can take, but not what they choose to take. This keeps the subsidy schedule enforceable: any block that creates too much bitcoin is invalid, and every full node checks it independently.
