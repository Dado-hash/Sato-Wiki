---
id: wiki.mempool
slug: mempool
language: en
category: protocol
title: Mempool
description: The mempool is each node's private waiting area for unconfirmed transactions — a local pool that filters, orders, and feeds transactions into blocks.
coverImage: media/wiki/mempool/mempool-hero.svg
difficulty: advanced
readTimeMinutes: 10
tags:
  - Mempool
  - Transactions
  - Mining
  - Relay
  - Fee
related:
  - wiki.transactions
  - wiki.utxo-model
  - wiki.full-nodes
  - wiki.blocks
  - wiki.transaction-fees
sources:
  - title: Bitcoin Developer Guide - Transaction relay and the mempool
    url: https://developer.bitcoin.org/devguide/transactions.html
    author: Bitcoin.org contributors
  - title: Bitcoin Core mempool implementation
    url: https://github.com/bitcoin/bitcoin/blob/master/src/txmempool.h
    author: Bitcoin Core contributors
  - title: BIP-125 — Opt-in full replace-by-fee
    url: https://github.com/bitcoin/bips/blob/master/bip-0125.mediawiki
    author: David A. Harding
  - title: BIP-331 — Package relay
    url: https://github.com/bitcoin/bips/blob/master/bip-0331.mediawiki
    author: Gloria Zhao et al.
  - title: Cluster mempool documentation
    url: https://delvingbitcoin.org/t/cluster-mempool-overview/1062
    author: Suhas Daftuar
updatedAt: 2026-05-27T00:00:00Z
---

## base

The mempool is each node's personal waiting area for unconfirmed transactions. When a wallet creates a transaction it broadcasts it to nearby peers. Each full node that receives the transaction checks basic validity rules. If the transaction passes, the node keeps it in its own mempool until a miner eventually includes it in a block.

Different nodes can have different mempool contents. Node A may have accepted a transaction that Node B rejected because of a stricter fee policy or a conflicting transaction. There is no single global mempool — each node maintains its own view of pending transactions.

![Transaction lifecycle through the mempool](media/wiki/mempool/mempool-pipeline.svg "Transactions flow from broadcast through validation, mempool waiting, and finally block inclusion.")

When a miner finds a block, all nodes remove the confirmed transactions from their mempools. The mempool is therefore a temporary buffer between the peer-to-peer relay network and the confirmed blockchain state.

## medium

The mempool is not a simple list. Every full node runs a set of policy rules that determine which transactions are accepted:

- **Standardness checks**: Bitcoin Core only relays transactions that use standard output types (P2PKH, P2SH, P2WPKH, P2WSH, P2TR), meet a minimum fee rate (default 1 sat/vB), and do not exceed the default size limit (100 kWU).
- **Anti-DoS limits**: The node limits how many orphan transactions it tracks and caps the total mempool size (default 300 MB). Transactions that exceed the cap are evicted starting from the lowest fee rate.
- **Replacement rules**: Replace-by-fee (RBF) allows a new transaction to replace an existing one if it pays a higher fee. BIP-125 defines opt-in RBF where the original transaction signals replaceability.

Miners select transactions from their mempool to build a block template. The standard strategy is to pick the highest fee-rate transactions first, up to the block weight limit. The coinbase transaction collects all fees from the selected transactions. Some miners use custom policies like fee-rate thresholds, minimum time in mempool, or inclusion of specific transaction types.

Transaction ordering inside a block is not random. Miners often sort by fee rate descending, and the first transaction after coinbase is typically the highest-paying one. This ordering affects how fast users can expect confirmation for their transactions.

## advanced

When the mempool fills up (default 300 MB on Bitcoin Core), the node must evict transactions. The eviction policy removes transactions with the lowest descendant fee rate first. This is more nuanced than simply removing the lowest individual fee rate — a transaction with a low fee rate but a high-fee child may still be attractive for mining.

**CPFP (child-pays-for-parent)** is a fee-bumping technique where a new transaction spends the output of a low-fee unconfirmed transaction. The miner sees that including both the parent and the child is profitable: the combined fee minus the combined weight gives a higher effective fee rate. Wallets use CPFP to accelerate confirmations without needing RBF signalling.

**Package relay (BIP-331)** allows a node to accept a package of related transactions together when the parent might not meet the fee policy threshold on its own. Without package relay, CPFP only works if the parent is already in the recipient's mempool, which may not be the case if the parent was rejected for low fee. Package relay solves this by evaluating the ancestor package as a whole.

**Cluster mempool** is a proposed redesign that treats the mempool as a set of disconnected clusters of dependent transactions. Each cluster is a connected component of parent-child relationships. This makes ancestor score calculation, eviction, and RBF validation more efficient and predictable.

**Ancestor and descendant limits** prevent DoS attacks where a single transaction chains too many dependents. Bitcoin Core limits a transaction to 25 ancestors and 25 descendants in the mempool. A transaction that would exceed these limits is rejected.

**v3 transaction relay (BIP-133)** introduces a new transaction version that enforces stricter replacement rules. v3 transactions must use RBF and have tight topology constraints (single child). This prevents free relay attacks and makes CPFP with package relay more reliable for applications like Lightning.

When a node restarts, it rebuilds its mempool by replaying recent transactions. The node reads the UTXO set from the chainstate database, processes blocks from the last checkpoint, and uses the block undo data to reconstruct transactions that were in the mempool before the restart, loading them from a mempool.dat file saved on shutdown.

The mempool is also tightly linked to block propagation. When a node receives a compact block (BIP-152), it fills in the missing transactions from its mempool. If the mempool already has all transactions, the block can be reconstructed in milliseconds with minimal bandwidth. This is why keeping a well-populated mempool makes block relay faster and cheaper.
