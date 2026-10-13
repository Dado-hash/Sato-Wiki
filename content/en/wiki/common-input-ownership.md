---
id: wiki.common-input-ownership
slug: common-input-ownership
language: en
category: privacy-security
title: Common Input Ownership Heuristic
description: The assumption that all inputs of one transaction belong to the same owner, and how chain analysis uses it to group addresses.
coverImage: media/wiki/common-input-ownership/common-input-ownership-hero.svg
difficulty: advanced
readTimeMinutes: 4
tags:
  - Privacy
  - Chain Analysis
  - Transactions
  - Heuristics
related:
  - wiki.utxo-model
  - wiki.transactions
  - wiki.address-reuse
  - wiki.coinjoin
  - wiki.threat-model
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: "A Fistful of Bitcoins: Characterizing Payments Among Men with No Names"
    url: https://cseweb.ucsd.edu/~smeiklejohn/files/imc13.pdf
    author: Sarah Meiklejohn, Marjori Pomarole, Grant Jordan, Kirill Levchenko, Damon McCoy, Geoffrey M. Voelker, Stefan Savage
    publishedAt: 2013-10-23
  - title: "BIP 78: Receiver-initiated PayJoin"
    url: https://github.com/bitcoin/bips/blob/master/bip-0078.mediawiki
    author: Nicolas Dorier
  - title: Common-input-ownership heuristic - Bitcoin Wiki
    url: https://en.bitcoin.it/wiki/Common-input-ownership_heuristic
    author: Bitcoin Wiki contributors
  - title: Payjoin - Bitcoin Optech topic
    url: https://bitcoinops.org/en/topics/payjoin/
    author: Bitcoin Optech
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

A transaction can spend several coins at once. Each coin is a previous output that a key controls. The common-input-ownership heuristic is the assumption that all the inputs of one transaction belong to the same person or entity. It is a sensible guess, because a wallet usually spends several of its own coins together when no single coin is large enough to cover a payment.

The original whitepaper already notes this link. Its privacy section says that multi-input transactions necessarily reveal that their inputs had the same owner, and that if one owner is identified, other transactions could be linked to that owner too.

Chain analysis software uses the assumption to group addresses into clusters that probably belong to one user. A cluster is not proof of ownership, but it is often strong enough to matter. The practical lesson is simple: when you spend several coins in one payment, you tell outside observers that those coins belong together.

Combining coins can be useful for practical reasons, but it trades privacy for convenience. Decide which coins you are willing to show as one group before you spend them together.

## medium

The heuristic becomes a tool when it is combined with change detection. A payment usually has a change output that returns the remaining value to the sender. In a 2013 study of payments, Meiklejohn and colleagues first clustered the addresses that appear together as inputs, which they call Heuristic 1. They then identified one-time change addresses, meaning outputs that receive change and are never used again, and linked them to the inputs (Heuristic 2). The authors describe the second heuristic as more challenging and significantly less safe than the first.

The two heuristics reinforce each other. Input clustering links the addresses that were spent together. Change detection attaches a fresh output to the same cluster. Once a cluster is large, each new transaction that touches it adds to the picture, so the analysis tends to grow over time.

The authors chose a conservative design on purpose. They preferred the safest heuristic they could design, accepting a high false-negative rate, meaning many true links are missed. The reason is that a single false link can merge unrelated users into a very large cluster. The Bitcoin Wiki gives examples of incorrect clusters produced by the assumption. Conclusions drawn from it are therefore probabilistic, and they can be wrong in both directions.

For ordinary users the heuristic explains several practices. Paying from coins that came from different sources can connect those sources. Spending a small coin next to a large one ties the two together. Keeping groups of coins apart limits how much a single payment reveals. The more often two groups are merged, the more likely an observer is to link them. Analysts therefore weigh each cluster against other evidence, and a cluster that looks solid can still contain a mistake.

## advanced

Some designs break the assumption by construction. In a CoinJoin, several users agree on one transaction whose inputs come from different owners. Each user signs only its own inputs, and the transaction becomes valid only when every signature is present. In that case the input cluster is wrong by design, which is the purpose of the construction.

PayJoin, specified in BIP 78, breaks the assumption in a two-party setting. The receiver adds one of its own inputs to the sender's payment and adjusts its own output, so the transaction contains inputs from two parties. The BIP lists the common-input heuristic, together with change identification by script type and by round amounts, as heuristics that this approach invalidates for the sender. It also notes that a receiver who takes part can make the heuristics mislead an analyst on purpose.

Multi-party transactions also appear in other collaborative constructions. When such a transaction is clustered with the common-input assumption, the result merges people who have no real connection. This is the false-positive side of the heuristic. The Bitcoin Wiki catalogues real examples in which the assumption produced clusters that were wrong, and analysts treat clusters as evidence to weigh rather than as settled facts.

The assumption is a statement about behaviour, not a rule of the protocol. The consensus rules do not require that inputs share an owner, so the assumption is an inference drawn from usage. The whitepaper expected that some linking would remain unavoidable for transactions with multiple inputs.

For a sender, the lesson concerns timing. If a payment spends coins from two previously separate sources, the public ledger records that they were spent together. Consolidating coins that were kept apart, or merging coins that were mixed, can undo a privacy measure taken earlier. The choice of which coins to spend together therefore matters as much as the choice of addresses. Wallets that let you select coins give you control over this decision.

Treat any cluster as a probability that depends on how each wallet actually spends its coins, and check that behaviour before drawing conclusions from it.
