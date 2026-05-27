---
id: wiki.consensus-rules
slug: consensus-rules
language: en
category: protocol
title: Consensus Rules
description: The set of rules every full node enforces independently to accept or reject blocks and transactions, ensuring all participants agree on a single history without trust.
coverImage: media/wiki/consensus-rules/consensus-rules-hero.svg
difficulty: advanced
readTimeMinutes: 8
tags:
  - Consensus
  - Validation
  - Protocol Rules
related:
  - wiki.blocks
  - wiki.full-nodes
  - wiki.proof-of-work
  - wiki.transactions
  - wiki.forks-and-soft-forks
  - wiki.mining
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: Bitcoin Developer Reference - Block Chain
    url: https://developer.bitcoin.org/reference/block_chain.html
    author: Bitcoin.org contributors
  - title: Bitcoin Core header validation logic
    url: https://github.com/bitcoin/bitcoin/blob/master/src/validation.h
    author: Bitcoin Core contributors
  - title: Bitcoin Core consensus header
    url: https://github.com/bitcoin/bitcoin/blob/master/src/consensus/consensus.h
    author: Bitcoin Core contributors
updatedAt: 2026-05-27T00:00:00Z
---

## base

Consensus rules are the rules every full node enforces to decide whether a block or transaction is valid. These rules are what make all nodes agree on one history without needing to trust anyone.

When a miner proposes a block, every node checks it independently. The block must follow the correct structure, link to a valid previous block, and contain only valid transactions. The block header must include a proof-of-work hash below the current target. The coinbase transaction can only create a limited amount of new bitcoin — currently the block subsidy plus transaction fees.

If any rule is broken, every node rejects the block. This is how Bitcoin stays consistent across thousands of independently operated nodes.

![Rules validation pipeline](media/wiki/consensus-rules/rules-validation.svg "An incoming block passes through multiple rule categories before the node accepts or rejects it.")

## medium

Consensus rules fall into several categories. Block-level rules govern the container: the block must be within the allowed size and weight limits (1 MB virtual size post-SegWit), the timestamp must not be too far in the past or future, and the proof-of-work target must match the difficulty adjustment schedule. Every 2,016 blocks, the difficulty retargets so blocks continue to arrive near a 10 minute average.

Transaction-level rules govern the content. Every input must reference a previous unspent output, the sum of inputs must equal or exceed the sum of outputs, and each input must carry a valid digital signature spending the referenced output. No transaction can create bitcoin except the coinbase, and no transaction can spend the same output twice — double-spending is blocked at the consensus level.

Script rules govern the execution of Bitcoin Script, the language used to lock and unlock outputs. Stack depth is capped at 1,000 elements, signature operations per block are limited, and opcodes like `OP_RETURN` are restricted to a single 80-byte output.

Consensus rules are distinct from policy rules. Policy rules are set by individual node operators — what relay fee to require, which transaction versions to accept, what standard script patterns to relay. Policy varies per node. Consensus rules must be identical across all nodes. Changing a consensus rule requires a soft fork (backward-compatible tightening) or a hard fork (backward-incompatible loosening), each with different deployment and activation requirements.

## advanced

Bitcoin's consensus rules have evolved through several key BIPs that tightened validation:

**BIP-30** (duplicate coinbase): prevents two coinbase transactions with the same txid from existing in different blocks. Before BIP-30, this was possible due to the same coinbase script being reused. Nodes now reject blocks with duplicate coinbase txids.

**BIP-34** (height in coinbase): requires the block height to be encoded in the coinbase input script. This makes the coinbase unique and provides an unambiguous ordering anchor. Every block since height 227,835 must include its height in the coinbase.

**BIP-66** (strict DER signatures): enforces strict Distinguished Encoding Rules (DER) encoding for ECDSA signatures. Before BIP-66, nodes accepted non-canonical DER encodings, creating malleability vectors. Activated via miner signaling in 2015.

**BIP-65** (OP_CHECKLOCKTIMEVERIFY): adds a new opcode that allows outputs to be locked until a specific time or block height. When an output is spent, CLTV enforces the locktime before allowing the spending transaction to be relayed.

**BIP-112** (CHECKSEQUENCEVERIFY): adds relative locktime enforcement via a new opcode. Combined with BIP-68 (relative locktime in sequence numbers), it enables payment channels and the Lightning Network by allowing outputs to be locked for a relative number of blocks or time.

**BIP-141** (SegWit): introduced segregated witness, separating signature data from the transaction body. This fixed transaction malleability, increased block capacity through the weight system, and added a new set of validation rules for SegWit inputs. The witness data is covered by `sigops` count and block weight limits.

**BIP-341/342** (Taproot): the most recent consensus upgrade. BIP-341 introduces Schnorr signatures and the ability to commit to a Merkle tree of script paths, making all outputs look the same by default. BIP-342 modifies Script to support 32-byte public keys, the `OP_CHECKSIGADD` opcode, and new version 1 witness programs.

A critical distinction is "valid under consensus" versus "standard relay policy." A transaction can be consensus-valid — it follows all the rules every node must enforce — yet be rejected by a node's policy. For example, a transaction with a very low fee is valid under consensus if it is properly signed and spends unspent outputs, but most nodes will not relay it because their policy rejects anything below the configured minimum relay fee. Policy rules exist to prevent spam and denial-of-service attacks, not to define the boundary of valid blocks.

In Bitcoin Core, the validation pipeline is defined across several files. `src/consensus/consensus.h` contains the fundamental consensus constants — maximum block weight, maximum sigops, the proof-of-work limit. `src/validation.cpp` implements the main chain state validation, connecting blocks and managing the UTXO set. The `CheckBlock` and `AcceptBlock` functions separate the cheap structural checks from the expensive stateful checks, allowing nodes to reject obviously invalid blocks before incurring the cost of signature verification.
