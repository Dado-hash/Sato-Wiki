---
id: wiki.block-header
slug: block-header
language: en
category: protocol
title: Block Header
description: The 80-byte header of every block, its six fields, how its double SHA-256 hash is compared with the target, and why the nonce alone is no longer enough.
difficulty: advanced
readTimeMinutes: 4
tags:
  - Block Header
  - Proof of Work
  - Difficulty
  - Timestamps
related:
  - wiki.blocks
  - wiki.proof-of-work
  - wiki.difficulty-adjustment
  - wiki.merkle-trees
  - wiki.coinbase-transaction
  - wiki.mining
sources:
  - title: Bitcoin Developer Reference - Block Chain
    url: https://developer.bitcoin.org/reference/block_chain.html
    author: Bitcoin.org contributors
  - title: Bitcoin Wiki - Block hashing algorithm
    url: https://en.bitcoin.it/wiki/Block_hashing_algorithm
    author: Bitcoin Wiki contributors
  - title: Bitcoin Wiki - Difficulty
    url: https://en.bitcoin.it/wiki/Difficulty
    author: Bitcoin Wiki contributors
  - title: "BIP 113: Median time-past as endpoint for lock-time calculations"
    url: https://github.com/bitcoin/bips/blob/master/bip-0113.mediawiki
    author: Thomas Kerin
  - title: "BIP 320: nVersion bits for general purpose use"
    url: https://github.com/bitcoin/bips/blob/master/bip-0320.mediawiki
    author: BtcDrak
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

The block header is the part of a block that proof of work is computed on. It is always 80 bytes and holds six fields: a version, the hash of the previous block header, the Merkle root of the block's transactions, a timestamp, the target in a compact form called nBits, and a nonce. Because the header is so small, a miner can test many candidate hashes without moving the transaction data around.

Miners change the nonce and the other flexible fields until the hash of the header falls below the target. Nodes do not repeat the search. They hash the header once and compare the result with the target that nBits encodes. The hash is computed with SHA-256 applied twice, which is why it is called a double SHA-256.

The header also carries the links that make the chain hard to rewrite. The previous block hash ties each header to its parent, and the Merkle root ties the header to every transaction in the block. Changing one transaction changes the root, which changes the header hash, so a rewritten block would need its own proof of work, and so would every block after it.

## medium

Field sizes and byte order matter. The version, timestamp, nBits and nonce are 4-byte integers stored in little-endian order. The previous block hash and the Merkle root are 32-byte values stored in internal byte order. Block explorers usually display hashes reversed, so the hex string you see for a block hash is the reverse of the bytes that were actually hashed.

![Block header bytes diagram](media/wiki/block-header/block-header-bytes.svg "The 80-byte block header is the data miners hash twice with SHA-256, and the nonce is the field they change most often.")

The nBits field is a compact form of the 256-bit target. Its first byte is an exponent, and the following three bytes are a mantissa. The target equals the mantissa multiplied by 256 raised to the power of the exponent minus three. The difficulty 1 value, 0x1d00ffff, has the mantissa 0x00ffff and the exponent 0x1d on mainnet. Difficulty is the ratio between that difficulty 1 target and the current target, so a smaller target means a higher difficulty. Bitcoin Core rejects an nBits value that encodes a negative target (sign bit set with a non-zero mantissa).

On mainnet the nBits value changes only at difficulty adjustments, which happen every 2,016 blocks.

Timestamps follow two rules. A block time must be strictly greater than the median of the previous 11 block times, which is the median time past. A block time also cannot be more than two hours ahead of the clock of the node checking it. The first rule keeps time moving forward even when miners' clocks disagree. The second limits how far a miner can move the timestamp into the future. BIP 113 uses the same median for locktime checks.

The nonce is not the only field a miner may vary. The timestamp can be moved forward within the allowed window, and the coinbase can be changed to alter the Merkle root. Either change produces a new header to hash.

## advanced

The Developer Reference describes the header as the structure that is hashed for proof of work, so the transactions enter that hash only through the Merkle root. Their full content is not needed to check the work.

![Block header bytes diagram](media/wiki/block-header/block-header-bytes.svg "The 80-byte block header is the data miners hash twice with SHA-256, and the nonce is the field they change most often.")

The nonce is four bytes, which is too little for current mining hardware. BIP 320 notes that mining hardware can exhaust the 32-bit nonce in less than 200 milliseconds, which forces the mining controller to send new work to each chip very often. Miners therefore roll other fields. The coinbase extra nonce changes the coinbase, the Merkle root and so the header. The timestamp can be rolled within its window, although BIP 320 warns that rolling too many bits of the timestamp distorts time over a long period.

The version field is the third source of variation. BIP 320 reserves 16 bits of nVersion for general use, so that miners can roll them without triggering false warnings about unknown soft-fork signals. BIP 320 says the bits can be negotiated with pools through the Stratum version-rolling extension. The BIP is still a draft, so its reservation should not be read as a settled consensus rule.

The timestamp rules bound how far a block time can move in either direction. The median rule stops a single block from pulling time backwards past the recent history, and the two-hour limit stops it from running ahead of real time. Both are enforced by every full node, so a block that breaks them is rejected even if its hash meets the target.

The target comparison treats the header hash as an unsigned 256-bit integer. Compact encoding loses precision, so the exact target is the decoded value of nBits, not a rounded difficulty figure. Pools often use a less truncated target for their shares, as the Bitcoin Wiki notes, but that is a pool choice. It does not change what the network accepts as a block.

The header is therefore a small, fixed-size commitment that combines proof of work, the link to the parent, the commitment to the transactions, and the time and difficulty context. Each field has a narrow job, and the consensus rules check each of them.
