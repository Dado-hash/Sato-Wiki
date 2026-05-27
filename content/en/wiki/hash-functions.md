---
id: wiki.hash-functions
slug: hash-functions
language: en
category: cryptography
title: Hash Functions
description: The mathematical building blocks Bitcoin uses to compress data, commit to values, and secure transactions without revealing secrets.
coverImage: media/wiki/hash-functions/hash-function-diagram.svg
difficulty: advanced
readTimeMinutes: 8
tags:
  - Cryptography
  - Hash Functions
  - Security
  - Fundamentals
related:
  - wiki.sha-256
  - wiki.merkle-trees
  - wiki.digital-signatures
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: "Handbook of Applied Cryptography"
    url: https://cacr.uwaterloo.ca/hac/
    author: Menezes, van Oorschot, Vanstone
  - title: "Mastering Bitcoin - Chapter 4"
    url: https://github.com/bitcoinbook/bitcoinbook/blob/develop/ch04.asciidoc
    author: Andreas M. Antonopoulos
updatedAt: 2026-05-27T00:00:00Z
---

## base

A hash function is a mathematical operation that takes any amount of data and produces a fixed-size result, called a digest or hash. No matter whether you hash one byte or one gigabyte, the output is always the same length. For SHA-256, the hash function Bitcoin uses everywhere, the output is always 256 bits, or 32 bytes.

![Hash function diagram](media/wiki/hash-functions/hash-function-diagram.svg "A hash function maps any amount of data to a fixed-size fingerprint.")

Hash functions have four properties that make them useful in Bitcoin. First, they are deterministic: the same input always produces the same output. Second, they are one-way: given a hash, there is no shortcut to find the original input. Third, they have the avalanche effect: a single bit change in the input produces a completely different output that looks unrelated to the original. Fourth, they produce a fixed-size output regardless of input size.

Bitcoin uses hash functions in every part of the protocol. Mining uses them as the core of Proof of Work: miners search for a block header hash below a target, which requires trillions of tries per second across the network. Each transaction gets a transaction ID that is the hash of its serialized data. Blocks chain together by including the hash of the previous block in each new block's header. Wallet addresses are derived from hashes of public keys.

A good way to think about a hash is as a digital fingerprint. A fingerprint uniquely identifies a person without revealing their identity. A hash uniquely identifies data without revealing the data itself. If you hash a transaction and publish the hash, anyone who later sees the transaction can confirm it matches, but nobody can reconstruct the transaction from the hash alone.

## medium

The security of a hash function rests on three properties that cryptographers formalize as attack models.

**Preimage resistance** means that given a hash output, it is infeasible to find any input that produces it. Bitcoin relies on this property for address security. A Bitcoin address is derived from a public key hash. An attacker who sees an address cannot reverse the hash to recover the public key (before the output is spent) and certainly cannot recover the private key. Preimage resistance is what keeps locked bitcoin safe even though the locking script reveals the hash.

**Second preimage resistance** means that given an input and its hash, it is infeasible to find a different input with the same hash. Bitcoin relies on this for transaction IDs. A transaction that is signed and broadcast has a txid that commits to its exact serialization. If an attacker could find a second preimage, they could create a different transaction that produces the same txid, breaking the explicit input-output chain. The same property protects block chaining: a block commits to its parent by storing the previous block hash.

**Collision resistance** means that it is infeasible to find any two distinct inputs that hash to the same output. Bitcoin relies on this property for Merkle trees, which commit an entire block's transaction list to a single 32-byte Merkle root. If collisions were feasible, an attacker could craft a block with two different transaction sets that share the same Merkle root, breaking the consensus commitment.

Bitcoin applies SHA-256 twice for most hashing operations, a construction called double-SHA-256 or SHA-256d. The block header is hashed with double-SHA-256 during mining. Transaction hashing in the legacy transaction ID also uses double-SHA-256. The reason is partly defensive: double-hashing prevents length-extension attacks that affect plain SHA-256, and it gives an extra margin of security against future cryptanalytic advances. The overhead is negligible because SHA-256 is extremely fast in hardware and software.

Hashes in Bitcoin are always interpreted as little-endian integers for comparison. The proof-of-work check compares the block header hash to the target as an integer. This means the same hash bytes can be written as a hex string, like `0000000000000000000a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e`, or compared numerically.

## advanced

The choice of SHA-256 for Bitcoin was not accidental. In 2008, SHA-256 was the most widely analyzed and trusted cryptographic hash function available. It had been standardized by NIST in 2001 and had withstood years of cryptanalytic scrutiny. SHA-1 had known weaknesses and collision attacks were practical by 2017. MD5 was completely broken. Whirlpool and other alternatives lacked the same level of analysis and hardware adoption.

SHA-256 belongs to the SHA-2 family, designed by the NSA. It processes messages in 512-bit blocks using a compression function that iterates 64 rounds. The internal state is 256 bits wide, organized as eight 32-bit words. Each round applies bitwise operations, modular addition, and logical functions that mix the input thoroughly. The design follows the Merkle-Damgard construction, where the message is padded to a multiple of the block size and each block updates the internal state.

The Merkle-Damgard construction makes SHA-256 vulnerable to length-extension attacks. Given `H(M)`, an attacker can compute `H(M || padding || extra)` without knowing `M`. This is why Bitcoin does not use raw SHA-256 for commitments where length-extension would matter. The most notable example is the coinbase witness commitment in SegWit, which uses a tagged hash scheme similar to HMAC rather than raw double-SHA-256. Tagged hashes prefix the data with a domain-specific tag before hashing, effectively separating the hash domain from all others.

The security margin of SHA-256 is substantial. The output is 256 bits, which means collision resistance offers 128 bits of security due to the birthday bound. Preimage resistance offers the full 256 bits. As of 2026, no practical attack reduces these margins for SHA-256. The best attacks are on reduced-round variants and have no impact on the full 64-round version. Bitcoin's double-SHA-256 construction raises the effective preimage security further because an attacker must invert two hash rounds instead of one.

The random oracle model provides a theoretical framework for reasoning about hash functions. In this model, the hash function is treated as a truly random function that returns a uniformly random output for every new input. While no real hash function is a random oracle, protocols designed in this model often resist attacks that exploit structural weaknesses. Bitcoin's use of double-hashing and domain separation through tagged hashes moves the protocol closer to the ideal, compensating for the gap between SHA-256 and a random oracle.

Hardware acceleration has shaped Bitcoin's hash function landscape. Application-specific integrated circuits (ASICs) for SHA-256 outperform general-purpose hardware by orders of magnitude. This specialization was predictable because SHA-256 is simple, symmetric, and parallelizable. A hash function with more complex addressing, like Scrypt used in Litecoin, resists ASIC optimization differently but trades verification speed. Bitcoin's choice of SHA-256 favors fast verification: any node can check a block header with two SHA-256 compressions, taking microseconds, while mining requires trillions of hashes per block.

Hashes also underlie Bitcoin Script's commitment operations. The `OP_HASH160` opcode computes RIPEMD-160 after SHA-256, producing 160-bit hashes used in P2PKH and P2SH addresses. `OP_SHA256` computes single SHA-256 for generic script commitments. These opcodes let users build custom spending conditions that commit to secrets without revealing them, enabling payment channels, atomic swaps, and other second-layer protocols without changes to the base layer.
