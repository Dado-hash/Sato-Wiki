---
id: wiki.dust-and-op-return
slug: dust-and-op-return
language: en
category: protocol
title: Dust Limit and OP_RETURN
description: The node policy that makes tiny outputs uneconomical to relay, and the provably unspendable OP_RETURN outputs used for data, with the standardness rules that have changed over time.
difficulty: advanced
readTimeMinutes: 5
tags:
  - Dust
  - OP_RETURN
  - Policy
  - UTXO
related:
  - wiki.utxo-model
  - wiki.bitcoin-script
  - wiki.mempool
  - wiki.transaction-fees
  - wiki.consensus-rules
  - wiki.coin-selection
sources:
  - title: Bitcoin Core policy implementation
    url: https://github.com/bitcoin/bitcoin/blob/master/src/policy/policy.cpp
    author: Bitcoin Core contributors
  - title: Bitcoin Core 0.9.0 release notes
    url: https://github.com/bitcoin/bitcoin/blob/master/doc/release-notes/release-notes-0.9.0.md
    author: Bitcoin Core contributors
  - title: Bitcoin Core 0.12.0 release notes
    url: https://github.com/bitcoin/bitcoin/blob/master/doc/release-notes/release-notes-0.12.0.md
    author: Bitcoin Core contributors
  - title: Bitcoin Core 30.0 release notes
    url: https://github.com/bitcoin/bitcoin/blob/master/doc/release-notes/release-notes-30.0.md
    author: Bitcoin Core contributors
  - title: Bitcoin Wiki - Dust
    url: https://en.bitcoin.it/wiki/Dust
    author: Bitcoin Wiki contributors
  - title: "BIP 141: Segregated Witness (Consensus layer)"
    url: https://github.com/bitcoin/bips/blob/master/bip-0141.mediawiki
    author: Eric Lombrozo, Johnson Lau, Pieter Wuille
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

Dust is an output so small that spending it would cost more in fees than the output is worth. The word describes an economic situation, but in Bitcoin Core it also names a precise relay rule. A transaction that creates dust outputs is not relayed or mined by default. Because the rule is policy, a node applies it on its own, and a miner can still include a dust output that a transaction carries.

The reason for the rule is the UTXO set. Every unspent output stays in the set until it is spent, and every full node keeps that set in its database. An output that nobody can afford to spend imposes its storage cost on the network for as long as it sits there. Dust limits discourage creating such outputs.

OP_RETURN is a different kind of output. Its script marks the output as unspendable, so no later transaction can ever use it. This makes it suitable for attaching a small piece of data to a transaction without creating a coin that must be tracked. Because the output can never be spent, a node does not need to keep it in the spendable UTXO set. Such outputs are subject to a size limit, which belongs to policy and has changed over the years.

## medium

The dust threshold in Bitcoin Core is computed from a feerate, not fixed in satoshis. The default dust relay rate is 3,000 sat/kvB, which is 3 sat/vB. An output is dust when its value is below the cost of spending it at that rate, meaning its serialized size plus the size of a typical input that would spend it. The comments in the source give 546 satoshis for a typical non-segwit P2PKH output and 294 satoshis for a P2WPKH output at this rate. For witness programs, the estimated input size receives the SegWit discount.

Outputs whose scripts are unspendable have a threshold of zero, so they are never classed as dust.

The dust rate is separate from the minimum relay rate. Bitcoin Core 30.0 lowered the default minimum relay feerate and the incremental relay feerate, but its release notes say the dust feerate remains unchanged.

OP_RETURN has a history of changing policy. Bitcoin Core 0.9, released in 2014, began relaying OP_RETURN outputs as a standard transaction type. The release notes describe the change as creating a provably prunable output, intended to stop people from storing arbitrary data such as images as unspendable outputs that bloat the UTXO database. The notes also state that the change is not an endorsement of storing data in the blockchain.

Bitcoin Core 0.12, released in 2016, relaxed what could follow OP_RETURN. Earlier releases relayed an output only if it held a single data push. Version 0.12 allowed any sequence of data pushes and small numeric constants, and applied the size limit to the whole serialized scriptPubKey, which was 83 bytes by default. That figure was the previous 80-byte payload limit plus 3 bytes of overhead.

Bitcoin Core 30.0, released in 2025, raised the default `-datacarriersize` to 100,000 bytes, so the size limit in practice is the maximum transaction size. It also allowed several OP_RETURN outputs in one transaction, with the limit applied to their combined size. Operators who want the old behaviour can set the option back to 83.

## advanced

The distinction between consensus and policy matters most for data outputs. Consensus rules decide whether a block is valid, and Bitcoin's block size limit is expressed as block weight, which is capped at 4,000,000 weight units under BIP 141. OP_RETURN outputs are not singled out in consensus. They count toward block weight like any other output. The per-output size restriction, the number of OP_RETURN outputs and the dust threshold are all policy, which a node can keep or change without a fork.

Bitcoin Core 0.12 also exempted unspendable outputs from dust checks. This follows from the threshold rule: an output that can never be spent has no spending cost to compare against its value. The same reasoning explains why the dust threshold for an unspendable output is zero in current code.

Policy differences have practical effects. A transaction with a dust output or an oversized data output will be rejected by nodes that enforce the rule, so it will not spread through the mempool. A miner who accepts it can still include it in a block, and the block will be valid if the other rules are satisfied. Policy values therefore determine which transactions reach most miners, not which blocks are valid.

Dust also has a wallet dimension. Dusting attacks send tiny amounts to many addresses, hoping that a later spend will link them together. Wallets may hide or freeze dust outputs so that automatic coin selection does not sweep them into a transaction, where the fee could exceed their value. Coin selection, described under change outputs, also treats a change amount below the dust limit differently, adding it to the fee instead of creating a new output.

The OP_RETURN debate reflects a tension in Bitcoin's design. Allowing data outputs gives applications a way to attach information to a transaction, and making those outputs provably unspendable keeps them out of the UTXO set. Restricting their size and number keeps them from becoming a large cost for every node. Each of these limits is a choice made in software, which is why the limits have moved across Bitcoin Core releases while the consensus rules for block validity stayed the same.
