---
id: wiki.transaction-fees
slug: transaction-fees
language: en
category: protocol
title: Transaction Fees
description: The difference between inputs and outputs that compensates miners for securing the network, forming a competitive fee market for block space.
coverImage: media/wiki/transaction-fees/fees-hero.svg
difficulty: advanced
readTimeMinutes: 10
tags:
  - Fees
  - Mempool
  - Mining
  - Economics
  - SegWit
related:
  - wiki.transactions
  - wiki.mempool
  - wiki.blocks
  - wiki.proof-of-work
  - wiki.utxo-model
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: Bitcoin Developer Guide - Transaction Fees
    url: https://developer.bitcoin.org/devguide/transactions.html#transaction-fees
    author: Bitcoin.org contributors
  - title: BIP 125 - Opt-In Full Replace-by-Fee
    url: https://github.com/bitcoin/bips/blob/master/bip-0125.mediawiki
    author: David A. Harding, Peter Todd
  - title: Fee Estimation in Bitcoin Core
    url: https://bitcoincore.org/en/2017/01/24/zero-confirmation-transaction-fee-estimation/
    author: Alex Morcos
updatedAt: 2026-05-27T00:00:00Z
---

## base

A transaction fee is the difference between the total value of a transaction's inputs and the total value of its outputs. This difference is not written anywhere in the transaction itself — nodes calculate it on the fly. The fee belongs to the miner who includes the transaction in a block.

Fees serve two purposes. They compensate miners for the validation work and energy spent securing the network, and they prevent attackers from flooding the network with free transactions. Every transaction must pay at least a minimal fee to be relayed by nodes.

![Transaction fee as the difference between inputs and outputs](media/wiki/transaction-fees/fees-hero.svg "A transaction with three inputs totalling 200,000 sats provides 190,000 sats to outputs. The 10,000 sats difference is the miner fee.")

Fees are measured in satoshis per virtual byte, written as sat/vB. This feerate — not the absolute fee — determines how quickly a transaction gets confirmed. A transaction paying 1,000 sats total but using 200 vbytes has a feerate of 5 sat/vB. A transaction paying 500 sats but using only 50 vbytes has a feerate of 10 sat/vB and will likely be confirmed first.

Wallets estimate the right feerate based on current network conditions. During quiet periods a low feerate suffices. When many people are sending transactions, the mempool fills and higher feerates become necessary.

## medium

The fee is computed as `fee = sum(inputs) - sum(outputs)`. If a transaction spends outputs worth 1,000,000 sats and creates new outputs worth 995,000 sats, the fee is 5,000 sats. There is no explicit fee field — the fee is implicit by design.

What matters for confirmation speed is the feerate, not the absolute fee. Feerate is the fee divided by the transaction's weight in virtual bytes. Virtual bytes normalize the cost of different transaction types. A legacy transaction with 1,400 bytes of raw data contributes 1,400 vbytes. A SegWit transaction of the same raw size may contribute fewer vbytes because SegWit data is discounted by a factor of four. This means SegWit transactions are cheaper to include than legacy transactions with the same spending pattern, reflecting the protocol's incentive to adopt SegWit.

The mempool is a fee market. Nodes hold unconfirmed transactions in their mempool and relay them to peers. Miners (or mining pools) select transactions from their mempool to build a block candidate. The greedy selection strategy is simple: sort by feerate descending and pick the highest-paying transactions first. A transaction offering 50 sat/vB will be selected before one offering 10 sat/vB, no matter the absolute fee.

Fee estimation is the wallet's critical task. Bitcoin Core provides `estimatesmartfee` which returns the feerate needed for a given confirmation target (e.g., 2 blocks, 6 blocks, 25 blocks). Wallets poll this regularly and adjust their feerate based on mempool pressure. Setting a feerate too low risks hours or days of waiting; setting it too high overpays.

As the block subsidy halves every four years, fees become proportionally more important for miner revenue. At Bitcoin's current block subsidy of 3.125 BTC per block plus fees, fees make up a meaningful fraction of the total reward. In future decades, after many more halvings, the subsidy will approach zero and miners will rely almost entirely on fees. The security budget must transition from inflation-based to fee-based without compromising the network's integrity.

![Supply and demand for block space](media/wiki/transaction-fees/fee-market.svg "The fee market: transactions compete for limited block space. Only the highest-feerate ones fit in each block.")

## advanced

The fee market is a continuous auction for block space. Each block provides roughly 1 million virtual bytes of space for transactions. When total demand (the sum of vbytes of all candidate transactions) exceeds supply, the market clears by feerate: the highest-feerate transactions are included, and the rest wait.

The mempool is not a single global queue. Every full node maintains its own mempool, though in practice they converge on similar contents. Transactions are accepted into the mempool only if they meet policy rules: the feerate must exceed the minimum relay fee (default 1 sat/vB), the transaction must be standard (standard script types only), and the total mempool size must not exceed the node's configured limit (default 300 MB of memory). When the mempool is full, the node evicts the transactions with the lowest feerate, starting from the bottom. This eviction policy creates a natural mempool floor during congestion.

**Fee bumping** allows a sender to raise the feerate of a transaction after it has been broadcast but before it is confirmed. Three mechanisms exist:

- **Replace-by-Fee (RBF)**: defined in BIP-125, RBF lets a sender broadcast a new version of a transaction that pays a higher feerate, replacing the original. The replacement must pay a higher fee than the original and meet several anti-abuse rules (e.g., the replacement must not invalidate unconfirmed descendants of the original). Opt-in RBF marks a transaction as replaceable via its sequence number; full-RBF nodes consider any transaction replaceable.

- **Child Pays for Parent (CPFP)**: the recipient of an unconfirmed transaction can spend its output in a child transaction with a high feerate. Miners who see the parent and child together will include both if the combined feerate is competitive. CPFP does not require the original sender to cooperate.

- **Package relay** (recently deployed in Bitcoin Core): allows a node to announce and relay a package of multiple related transactions as a unit, improving CPFP propagation.

Dust outputs intersect with fees in a subtle way. A dust output is one so small that spending it would cost more in fees than the output itself is worth. Nodes refuse to relay transactions that produce dust outputs (the threshold varies by output type). This prevents economically irrational transactions from occupying block space.

Mining block assembly is more sophisticated than a simple greedy sort by feerate. Miners use ancestor-feerate-aware selection: a transaction's effective priority includes its unconfirmed ancestors. If a low-feerate transaction has a high-feerate descendant, the pair may be selected together even though the parent alone would not be. This ancestor-aware selection accounts for CPFP dynamics and produces better block templates.

The coinbase transaction collects all fees from included transactions. The sum of all fees plus the block subsidy becomes the miner's reward. Miners can also include their own coinbase outputs before all other transactions.

Looking toward the future, a purely fee-based security model raises open questions. If fees drop after the subsidy era, could a costless simulation attack or persistent reorg become feasible? Current research suggests that if fees are too low, the equilibrium could shift toward a higher orphan rate or centralization of mining. Ensuring a robust fee market may require second-layer traffic (Lightning Network and other protocols) to create ongoing demand for block space, even when first-layer transactional demand is low.

The fee distribution in a healthy mempool shows a long tail: thousands of transactions at low feerates and a steep drop-off at the current minimum inclusion feerate. Observing this distribution in real time helps estimate the optimal feerate and anticipate when congestion will ease.
