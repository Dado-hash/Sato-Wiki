---
id: wiki.merkle-trees
slug: merkle-trees
language: en
category: cryptography
title: Merkle Trees
description: The binary hash tree structure Bitcoin uses to commit transactions into blocks and enable efficient membership proofs.
coverImage: media/wiki/merkle-trees/merkle-tree.svg
difficulty: advanced
readTimeMinutes: 8
tags:
  - Cryptography
  - Merkle Trees
  - Blocks
  - Data Structures
related:
  - wiki.hash-functions
  - wiki.sha-256
  - wiki.blocks
  - wiki.segregated-witness
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: "Merkle, R. C. - Protocols for Public Key Cryptosystems"
    url: https://www.win.tue.nl/~berry/2WC15/Literature/Merkle-1980.pdf
    author: Ralph C. Merkle
    publishedAt: 1980
  - title: "Bitcoin Developer Reference - Merkle Trees"
    url: https://developer.bitcoin.org/reference/block_chain.html#merkle-trees
    author: Bitcoin.org contributors
updatedAt: 2026-05-27T00:00:00Z
---

## base

A Merkle tree is a binary tree of hashes. Each leaf is the double-SHA-256 hash of a transaction; every internal node is the double-SHA-256 hash of its two children concatenated. The single hash at the top is called the Merkle root. It commits to every transaction in the block -- changing a single byte in any transaction produces a completely different root.

![Merkle tree diagram](media/wiki/merkle-trees/merkle-tree.svg "Four transactions hashed pairwise into a Merkle root. A proof for Tx2 requires only Tx3 and H01.")

The Merkle root lives in the block header. This is what makes lightweight clients possible. A Simplified Payment Verification (SPV) wallet can verify that a transaction belongs to a block by downloading only the block header (80 bytes) and a Merkle proof -- a path of hashes from the transaction up to the root -- instead of the entire block. The proof size grows as log2(n), so a block with thousands of transactions needs only a handful of hashes.

Think of the Merkle root as a cryptographic checksum for an ordered list of transactions. Just as a hash fingerprints a single piece of data, the Merkle root fingerprints an entire transaction set.

## medium

To build a Merkle tree, start with the list of transaction hashes. Pair adjacent hashes, concatenate them, and hash with double-SHA-256. This produces a new list half the size. Repeat until one hash remains: the Merkle root.

```
Level 2:              Root = H(H01 || H23)
                      /                   \
Level 1:        H01 = H(Tx0 || Tx1)     H23 = H(Tx2 || Tx3)
                /           \             /           \
Level 0:     Tx0           Tx1           Tx2           Tx3
```

Bitcoin uses double-SHA-256 for all Merkle hashes: SHA-256 applied twice, written as SHA256d. This matches the hashing algorithm used for mining and addresses.

When a level has an odd number of hashes, the last hash is duplicated before pairing. A tree with five transactions pairs the fifth with itself. This rule ensures the tree always converges to a single root. The same rule applies at every level, so an odd count at level 1 produces a duplicate internal hash as well.

A Merkle proof provides the sibling hashes along the path from a transaction to the root. To prove Tx2 is in the tree above, a wallet needs Tx3 and H01. The verifier computes H23 = H(Tx2 || Tx3), then Root = H(H01 || H23), and checks the result matches the block header's Merkle root. Only log2(n) hashes are needed, so a proof for a transaction in a 2000-transaction block is 11 hashes (about 352 bytes).

An empty block still has a Merkle root. When a block has no transactions (only the coinbase), the Merkle root is the double-SHA-256 of an empty byte string: SHA256(SHA256("")).

## advanced

The simple Merkle tree described above has known cryptographic weaknesses, and Bitcoin has adopted several variants to address them.

**Second-preimage attack.** A naive Merkle tree is vulnerable to a second-preimage attack. If an attacker can make a leaf node's data look like a valid internal node, they can produce a different tree with the same root. Bitcoin mitigates this by prefixing leaf hashes with 0x00 and internal node hashes with 0x01 before hashing. This domain separation ensures leaves and internal nodes can never collide. The Prefix-Merkle tree used in BIP 341 formalises this by tagging each hash with its position in the tree.

**Duplicate transactions.** If the same transaction appears twice in a block, the naive tree produces the same hash twice, which can lead to balanced subtrees that look different from expected. The duplicate hash at the leaf level propagates up, and under the odd-number rule the duplicated branch may produce a tree that is not collision-resistant in the standard sense. Mitigations include using ordered transaction sets and, more fundamentally, the prefix scheme above.

**Segregated Witness.** SegWit (BIP 141) introduces a separate witness Merkle tree. Witness data is moved out of the main transaction list into a witness structure committed by a separate Merkle root embedded in the coinbase transaction via the witness commitment. This allows nodes to validate transactions without downloading witness data, and allows pruning of older witness data. The witness Merkle tree uses double-SHA-256, the odd-number rule, and the same structure as the main tree, but its root appears in the coinbase output rather than the block header.

**Taproot and BIP 341.** Taproot replaces the traditional script-based locking with a binary Merkle tree of script paths. The TapTweak commits to a Merkle root (the TapLeaf hash tree) concatenated with the internal public key. This lets users spend a UTXO either by using the key path (direct signature) or by revealing any leaf script in the tree. The tree is a binary tree of TapLeaf or TapBranch hashes, using a tagged hash (SHA256 with a domain-specific tag) instead of double-SHA-256. Only the revealed path is visible on-chain -- unexecuted script branches remain hidden, improving privacy and reducing transaction size.

**Compact block relay.** BIP 152 (Compact Blocks) uses Merkle tree structure for efficient block relay. Instead of sending full transactions, a node sends a block header, the list of transaction short IDs (computed from the transaction hash), and a Merkle proof for each transaction the receiver is expected to already have. The receiver reconstructs the full Merkle tree from their mempool transactions and requests only the missing ones. This dramatically reduces bandwidth during block propagation.

The Merkle tree is one of Bitcoin's most elegant design decisions. It decouples block size from verification cost, enables light clients, and continues to evolve with each protocol upgrade.
