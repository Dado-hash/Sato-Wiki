---
id: wiki.myth-backed-by-nothing
slug: myth-backed-by-nothing
language: en
category: myths
title: '"Bitcoin is backed by nothing"'
description: No issuer or asset stands behind bitcoin, so its properties come from enforced rules and network consensus, and its value depends on continued demand.
coverImage: media/wiki/myth-backed-by-nothing/myth-backed-by-nothing-hero.svg
difficulty: base
readTimeMinutes: 5
tags:
  - Myths
  - Money
  - Consensus
  - Proof of Work
related:
  - wiki.consensus-rules
  - wiki.proof-of-work
  - wiki.full-nodes
  - wiki.block-subsidy
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: "Cryptocurrencies: looking beyond the hype"
    url: https://www.bis.org/publ/arpdf/ar2018e5.htm
    author: Bank for International Settlements
    publishedAt: 2018-06-24
  - title: "Is Bitcoin a Real Currency? An economic appraisal"
    url: https://www.nber.org/papers/w19747
    author: David Yermack
  - title: Block Chain - Bitcoin Developer Guide
    url: https://developer.bitcoin.org/devguide/block_chain.html
    author: Bitcoin.org contributors
  - title: Controlled supply - Bitcoin Wiki
    url: https://en.bitcoin.it/wiki/Controlled_supply
    author: Bitcoin Wiki contributors
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

True in one sense, misleading in another. No issuer, reserve or asset stands behind bitcoin, and nobody promises to redeem it. That describes how it works, not whether it has value, because its properties come from rules that the network enforces.

Think of a game with a fixed rulebook. The game needs no bank behind it to keep the supply of tokens within a limit, as long as every player checks the same rules. Bitcoin's supply schedule works this way. The total is capped at slightly less than 21 million coins, and the block subsidy halves every 210,000 blocks, about every four years. Full nodes reject any block that breaks these rules, so a miner who tries to create extra coins gets nothing accepted.

New blocks also need proof of work, which makes rewriting recent history expensive. Payments move between users without an intermediary that keeps the balances.

None of this says that bitcoin has a particular value, and it does not promise that demand will last. Those are separate questions. The serious objection to the claim is about them, and it is covered in the advanced section.

## medium

The phrase "backed by nothing" usually means that no asset sits in a reserve against each unit, and that no company or government owes holders anything in return. That is accurate for bitcoin. It is a different question from what gives bitcoin its rules.

The whitepaper describes an electronic payment system without a trusted third party. Transactions are broadcast to the network, and proof of work records them in a chain of blocks. The longest chain is the record that carries the most accumulated work, and it is the one nodes follow, as long as honest nodes control most of the computing power.

The supply rules are part of the consensus. The subsidy is set by the protocol and halves every 210,000 blocks, and the Bitcoin Wiki's Controlled supply page states that the number of coins will not exceed slightly less than 21 million. These are constants that have not changed since launch, so they can be stated plainly. The schedule works only because each full node checks it. The Bitcoin developer documentation says that full nodes validate blocks using the same consensus rules, and that a node stores only the blocks it has validated.

A block also needs proof of work. The documentation describes it as a hash of the block header that must not exceed a certain value, and the value must be at least as demanding as the expected difficulty.

A payment becomes harder to reverse as more blocks are added on top of the block that contains it. The whitepaper treats this as a probabilistic property: the more blocks build on a transaction, the less likely it is to be replaced.

Taken together, these mechanisms give the properties people usually mean by sound money: a supply that no issuer can expand, and records that do not depend on one ledger-keeper. They do not create a claim on cash flows, and they do not oblige anyone to redeem a unit.

## advanced

The strongest form of the claim is not that bitcoin is worthless. It is that a monetary asset with no backing has value only while people expect others to keep accepting it, and that nothing in the protocol gives a reason to hold it beyond that expectation. The Bank for International Settlements took this position in its 2018 annual report. It described cryptocurrencies as akin to a commodity money "without any intrinsic value in use", said they are "no one's liability, ie they cannot be redeemed", and stated that "their value derives only from the expectation that they will continue to be accepted by others." The chapter covers cryptocurrencies in general, not bitcoin alone.

The reply above has to answer this objection. Fixed supply and proof of work are properties of the rules, but a rule set is not a store of value. The rules say how many units will exist and how they are recorded, not how many people will want them or at what price. David Yermack tested bitcoin in an NBER working paper, issued in December 2013, against the usual tests of a currency: medium of exchange, store of value and unit of account. He concluded that bitcoin behaves more like a speculative investment than a currency.

The defender's reply is that much of the money in use today is also not redeemable for a commodity, and that acceptance is a social fact that does not need a claim on assets to be real. That is partly right, and it shows that redemption rights are not the only source of value. It does not answer whether an asset with no cash flows and no redemption right can be valued in a stable way. The BIS chapter ties the volatility of these assets to the lack of any agent obliged to stabilise their value.

The claim would become false if bitcoin were backed by a legally enforceable claim on an identifiable pool of assets, or if an issuer undertook to redeem it. That would change what bitcoin is, and no current protocol rule does it. The serious objection would be settled in one direction if evidence showed that demand persists over long periods without any income or asset behind it, and in the other if demand were shown to depend on a source of value that the objection has not considered. The consensus rules cannot settle it.
