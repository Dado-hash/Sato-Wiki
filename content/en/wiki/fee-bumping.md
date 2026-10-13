---
id: wiki.fee-bumping
slug: fee-bumping
language: en
category: protocol
title: "Fee Bumping: RBF and CPFP"
description: Two ways to raise the effective fee of an unconfirmed transaction that is stuck, replace-by-fee with a new conflicting version and child-pays-for-parent with a high-fee child.
coverImage: media/wiki/fee-bumping/fee-bumping-hero.svg
difficulty: base
readTimeMinutes: 5
tags:
  - Fees
  - RBF
  - CPFP
  - Mempool
related:
  - wiki.transaction-fees
  - wiki.fee-market
  - wiki.mempool
  - wiki.transactions
  - wiki.utxo-model
sources:
  - title: "BIP 125: Opt-in Full Replace-by-Fee Signaling"
    url: https://github.com/bitcoin/bips/blob/master/bip-0125.mediawiki
    author: David A. Harding
  - title: Bitcoin Core policy - mempool replacements
    url: https://github.com/bitcoin/bitcoin/blob/master/doc/policy/mempool-replacements.md
    author: Bitcoin Core contributors
  - title: Bitcoin Core 28.0 release notes
    url: https://github.com/bitcoin/bitcoin/blob/master/doc/release-notes/release-notes-28.0.md
    author: Bitcoin Core contributors
  - title: Bitcoin Core policy - packages
    url: https://github.com/bitcoin/bitcoin/blob/master/doc/policy/packages.md
    author: Bitcoin Core contributors
  - title: Bitcoin Optech - Child pays for parent (CPFP)
    url: https://bitcoinops.org/en/topics/cpfp/
    author: Bitcoin Optech
  - title: Bitcoin Optech - Package relay
    url: https://bitcoinops.org/en/topics/package-relay/
    author: Bitcoin Optech
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

A transaction can get stuck when its feerate is too low for the block space that miners are filling. It stays in mempools, waiting for a block, and the sender needs a way to raise the fee without starting over. There are two common methods. Both work only while the transaction is still unconfirmed.

Replace-by-fee (RBF) sends a new transaction that spends at least one of the same inputs and pays a higher total fee. Nodes that accept the replacement drop the original. The sender can do this alone, because they control their own inputs and can reduce their change output to pay the extra fee.

Child-pays-for-parent (CPFP) works from the other side. Someone who holds an output of the stuck transaction spends it in a new child transaction with a high fee. The receiver of a payment can do this, and so can the sender if they have change to spend. A miner that looks at the parent and child together sees a higher combined feerate, so including both is worth it.

Both methods are node policies, not consensus rules. A miner can include any transaction that is valid under the consensus rules, whatever the nodes relaying it prefer. Merchants who accept unconfirmed payments should keep in mind that the sender may be able to replace the payment, so waiting for a confirmation is the safe choice.

## medium

BIP 125 describes the original opt-in form of RBF. A transaction signals that it can be replaced by setting nSequence below 0xfffffffe on at least one input. A transaction can also inherit the signal from an unconfirmed ancestor that signals. A replacement must spend at least one input of the original, may add an unconfirmed input only if that input came from one of the originals, must pay a higher absolute fee than the originals together, and must pay for its own size at the node's incremental relay feerate. The number of transactions it evicts, including their descendants, is capped at 100.

Bitcoin Core's current replacement policy keeps the idea but drops the signal requirement. Full RBF has been an option since version 24.0, and the 28.0 release notes state that the default of the mempoolfullrbf setting changed from 0 to 1. On a node with default settings, version 28.0 and later therefore accept a replacement for any unconfirmed transaction, signalling or not. Nodes that still set mempoolfullrbf to 0 keep the signal-based behaviour. The policy document also lists a feerate-diagram rule, which applies from version 31.0 and requires the replacement to improve the mempool's feerate diagram.

CPFP depends on how miners pick transactions. Miners judge a transaction together with its unconfirmed ancestors, so a child paying a high feerate can pull a low-feerate parent into a block. The fee of the child must be large enough to cover the parent's shortfall as well as its own. The Optech overview calls this ancestor feerate mining and notes that wallets can use CPFP only as long as enough miners behave this way.

Packages are the technical bridge. Bitcoin Core's package policy evaluates a child with its parents together, so a parent that pays too little on its own can be accepted with a child that pays enough. The package rules require a topologically sorted set. Optech describes package relay between peers as a proposed feature, so the two halves of the mechanism are at different stages.

## advanced

The replacement rules are about incentives. Requiring a higher absolute fee means that a miner does not earn less by including the replacement than by including the original. Requiring the extra fee to cover the replacement's own size at the incremental relay feerate stops an attacker from making nodes relay many tiny replacements, each adding a single satoshi. The policy document records these rationales and adds a cluster limit, so that one replacement cannot force a node to recompute a very large set of conflicting transactions at once.

The feerate-diagram rule goes further. A replacement must strictly improve the feerate diagram of the mempool. The policy document gives the purpose as making sure that block fees in future blocks go up after a replacement, rather than down.

Replacement also has a known weakness called transaction pinning, in which a chain of low-value descendants is used to make an original expensive to replace. The count of evicted transactions, including descendants, is what the limits bound. Wallets that build several chained unconfirmed transactions should keep this in mind.

CPFP works on the package feerate: the combined fee of the parent and child divided by their combined virtual size. The child must pay enough to lift that average to the level miners require, and the sender bears that cost. Optech's wording is that a high-feerate child makes miners want to include the low-feerate parent as well.

The fact that both methods are policy matters for merchants. A replacement that is valid under the rules of the node relaying it does not break consensus, so the network has no rule against the sender changing the payment. The risk is practical: a payment seen only in the mempool can be replaced or dropped. Full RBF removes the protection that signalling once gave a recipient. BIP 125 says that a recipient may choose not to treat a signalling transaction as payment until it is confirmed. The same reasoning applies to any unconfirmed transaction once the default policy accepts replacements.

Because this is node policy, nodes can differ. One node may accept a replacement that another rejects, and the mempools of different nodes are not identical. None of this changes what counts as a valid block. It only affects which transactions reach a block in the first place.
