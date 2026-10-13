---
id: wiki.coin-selection
slug: coin-selection
language: en
category: protocol
title: Change Outputs and Coin Selection
description: How a wallet chooses which UTXOs to spend, where the change goes, and what those choices cost in fees and privacy.
difficulty: base
readTimeMinutes: 5
tags:
  - Coin Selection
  - Change
  - UTXO
  - Privacy
related:
  - wiki.utxo-model
  - wiki.transactions
  - wiki.transaction-fees
  - wiki.common-input-ownership
  - wiki.address-reuse
sources:
  - title: Bitcoin Core coin selection implementation
    url: https://github.com/bitcoin/bitcoin/blob/master/src/wallet/coinselection.cpp
    author: Bitcoin Core contributors
  - title: "An Evaluation of Coin Selection Strategies"
    url: https://murch.one/erhardt2016coinselection.pdf
    author: Mark Erhardt
  - title: Coin selection
    url: https://bitcoinops.org/en/topics/coin-selection/
    author: Bitcoin Optech
  - title: Bitcoin Developer Reference - Transactions
    url: https://developer.bitcoin.org/reference/transactions.html
    author: Bitcoin.org contributors
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

A UTXO cannot be split. If a wallet holds one coin worth 50,000 sats and wants to pay 20,000 sats, the whole coin is spent. The difference goes to a new output that the wallet controls, called change. Change is an ordinary output, so it adds to the transaction size and creates one more coin that must be spent later.

Coin selection is the step where the wallet chooses which of its UTXOs to spend. The chosen set has to cover the payment and the fee. Good selection balances several goals: keep the fee low, avoid creating outputs too small to spend economically, avoid leaking information about the wallet, and keep the number of inputs reasonable.

No single method meets every goal. Some wallets spend the oldest coins first, which is simple but can cost more in fees. Others look for a combination that matches the payment exactly, so no change is needed, and fall back to other methods when no exact match exists.

Consolidation means spending many small coins into one new output. It makes sense when fees are low, because adding those inputs now costs less than it will cost later. It also has privacy costs, which is why wallets do not always consolidate.

## medium

One of Bitcoin Core's methods is Branch and Bound. It searches for a set of inputs whose total falls inside a window: from the payment plus fee up to that amount plus the cost of creating and later spending a change output. If a set lands in this window, the transaction can be built without a change output. The search walks the possible combinations depth first, stops early when a branch cannot improve on the best result, and gives up after a fixed number of tries.

When no changeless match is found, the wallet needs another method. Bitcoin Core has used Single Random Draw, which adds randomly ordered coins until the target is reached. Erhardt's thesis describes Branch and Bound's fallback as equivalent to this method. Newer Bitcoin Core versions also include CoinGrinder, a strategy that searches for solutions with a change output.

The best candidate is chosen by a waste score. Bitcoin Core's source defines it as the inputs multiplied by the difference between the current feerate and a long-term feerate, plus the excess above the target. When the current feerate is above the long-term estimate, each extra input costs more now than it will later, so the score favours fewer inputs. When the current feerate is below it, extra inputs are cheap, and a larger set becomes a sensible choice. This is the reason consolidation is tied to low fee periods.

A change amount below the dust limit is usually not worth a new output. Erhardt's thesis describes one shuffle-based method in which a change output smaller than the dust limit is added to the fee instead of being paid to the sender. The transaction then avoids an output that would cost more to spend than it is worth.

Wallets also differ in what they prefer. Bitcoin Core favours input sets made of a single output type for privacy, according to Bitcoin Optech. Erhardt's thesis also notes that Bitcoin Core lets users choose their coins by hand through its coin control feature.

## advanced

Coin selection is a trade-off between goals that pull in different directions. Lopp, as summarised by Erhardt, lists four goals: prevent blockchain bloat, support high transaction volume, protect privacy, and minimise cost. Spending one large UTXO minimises fees but leaves a small change coin behind. Spending many small coins reduces the UTXO set and the number of coins to track, but raises the fee and the number of inputs. No algorithm satisfies all four.

Privacy is the goal that most depends on choices the wallet makes. Every input in a transaction is evidence that the same party controls all of them, which is the basis of common-input-ownership heuristics. Erhardt notes that paying a ticket by combining more than fifty UTXOs is a privacy hazard, while using a very large coin for a small purchase reveals more about the wallet's holdings than necessary.

Change is the second source of leakage. A change output can often be told apart from the payment when amounts, script types or address reuse make the structure obvious. Lopp proposed making the change the same size as the payment, so that an observer cannot tell them apart by value. Erhardt observes that the sender controls the size of the change, so it can be used to shape the wallet's UTXO pool.

Coin selection also has to avoid reusing coins that were created by earlier transactions in later, unrelated payments. Bitcoin Optech describes this as a privacy use of coin selection: keep the history of different groups of coins apart, so that a later payment does not join them together. Deterministic rules such as first in, first out or largest first are easy to predict, and Erhardt notes that their patterns can reveal the type of wallet and something about the age or size of its coins.

Exact matches are the strongest privacy result within a single transaction. If a set of inputs equals the payment and the fee, no change output exists to link back to the wallet. The fallback methods then matter, because they produce the transactions that carry change. Users who want tighter control can keep coins apart and select inputs themselves through coin control, instead of relying on the default algorithm.
