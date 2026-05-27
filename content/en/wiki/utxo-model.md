---
id: wiki.utxo-model
slug: utxo-model
language: en
category: protocol
title: UTXO Model
description: Bitcoin's model for tracking spendable coins as discrete unspent transaction outputs rather than account balances.
coverImage: media/wiki/utxo-model/utxo-flow.svg
difficulty: advanced
readTimeMinutes: 8
tags:
  - UTXO
  - Transactions
  - Validation
  - Privacy
related:
  - wiki.transactions
  - wiki.full-nodes
  - wiki.transaction-fees
  - wiki.bitcoin-script
  - wiki.blocks
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: Bitcoin Developer Guide - Transactions
    url: https://developer.bitcoin.org/devguide/transactions.html
    author: Bitcoin.org contributors
  - title: Bitcoin Developer Reference - Transactions
    url: https://developer.bitcoin.org/reference/transactions.html
    author: Bitcoin.org contributors
  - title: Bitcoin Core coins implementation
    url: https://github.com/bitcoin/bitcoin/blob/master/src/coins.h
    author: Bitcoin Core contributors
updatedAt: 2026-05-27T00:00:00Z
---

## base

UTXO stands for unspent transaction output. Bitcoin does not keep an account balance for each user. It keeps track of many individual outputs that have not yet been spent. A wallet balance is the sum of the UTXOs the wallet can spend.

![UTXO spend and change flow](media/wiki/utxo-model/utxo-flow.svg "Spending a UTXO consumes the whole output and creates new outputs, usually including a change output back to the spender.")

If you have one UTXO worth 50,000 sats and want to pay 20,000 sats, you do not cut the old UTXO in half. Your transaction spends the whole 50,000 sat output and creates new outputs: one for the recipient, one for change, and a small difference left as the miner fee.

This model makes ownership precise. A coin is either unspent and available, or spent and no longer valid to use again. Nodes reject any transaction that tries to spend the same output twice in the same valid history.

## medium

Every UTXO is identified by an outpoint: the transaction ID that created it and the index of the output inside that transaction. A transaction input names an outpoint and provides the data needed to satisfy that output's locking script.

Outputs are discrete, so wallets need coin selection. They choose which UTXOs to spend, estimate the transaction fee, and create change when the selected inputs are larger than the payment. Better coin selection can reduce fees and avoid unnecessary privacy leaks.

The UTXO set is the current spendable state of Bitcoin. It is much smaller than the full transaction history, but it is consensus-critical. A full node uses it to answer a direct question for each input: does this referenced output exist, is it unspent, and can this transaction spend it?

UTXOs also shape privacy. Combining several UTXOs in one transaction can reveal that the same wallet or user likely controls them. Change outputs can also be guessed when amounts, script types, or address reuse make the transaction structure obvious.

## advanced

The UTXO model gives Bitcoin a local validation rule for global scarcity. To validate a block, a node does not need to recompute every historical balance. It applies each transaction as a set of deletions and insertions against the current UTXO set: spend old coins, create new coins, and ensure the total output value does not exceed the spendable input value.

This is why double-spend detection is exact. Two transactions can conflict if they try to spend the same outpoint. Only one can be connected in a valid chain state. A competing branch may choose the other transaction, but the conflict is resolved by the valid chain with the most accumulated work.

UTXOs also separate validation state from archival history. A pruned full node may discard old block data after validation, but it must keep enough chainstate to validate new blocks. The UTXO set is therefore a scarce shared resource: every unspent output imposes storage and lookup costs on validating nodes.

Scripts live at the boundary of this model. The previous output defines the spending condition; the new transaction supplies unlocking data. Once the condition is satisfied and the transaction is connected, the old condition disappears with the spent UTXO and new conditions are created for future spends.

Compared with an account model, UTXOs make parallel validation, proof construction, and conflict detection simpler. The tradeoff is that wallets must manage coin selection, change, and privacy deliberately instead of relying on a single mutable account balance.
