---
id: wiki.myth-whole-coin
slug: myth-whole-coin
language: en
category: myths
title: '"You have to buy a whole bitcoin"'
description: "False: one bitcoin divides into 100,000,000 satoshi, and the software counts every amount in satoshi."
coverImage: media/wiki/myth-whole-coin/myth-whole-coin-hero.svg
difficulty: base
readTimeMinutes: 5
tags:
  - Myths
  - Units
  - Satoshi
  - Fees
related:
  - wiki.transactions
  - wiki.dust-and-op-return
  - wiki.weight-units
  - wiki.transaction-fees
  - wiki.lightning-network
sources:
  - title: Bitcoin Core consensus amounts
    url: https://github.com/bitcoin/bitcoin/blob/master/src/consensus/amount.h
    author: Bitcoin Core contributors
  - title: "BIP 176: Bits Denomination"
    url: https://github.com/bitcoin/bips/blob/master/bip-0176.mediawiki
    author: Jimmy Song
    publishedAt: 2017-12-12
  - title: Bitcoin Wiki - Units
    url: https://en.bitcoin.it/wiki/Units
    author: Bitcoin Wiki contributors
  - title: Lightning BOLT 00 - Introduction
    url: https://github.com/lightning/bolts/blob/master/00-introduction.md
    author: Lightning Network contributors
  - title: Developer Guide - Transactions
    url: https://developer.bitcoin.org/devguide/transactions.html
    author: Bitcoin.org contributors
  - title: Bitcoin Core policy implementation
    url: https://github.com/bitcoin/bitcoin/blob/master/src/policy/policy.cpp
    author: Bitcoin Core contributors
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

False. You do not have to buy a whole bitcoin. One bitcoin is divided into 100,000,000 satoshi, and the software records every amount in satoshi. Anyone can hold, send or receive a fraction of a coin, down to one satoshi. The price of one whole coin says nothing by itself about what a small amount costs.

The division comes from the software. Bitcoin Core defines one coin as 100,000,000 base units, so eight decimal places separate a coin from its smallest unit. The outputs of a transaction state their value in satoshi. A wallet may display an amount as BTC, as millibitcoin, as bits or in satoshi, but the underlying value is a whole number of satoshi. The unit names are conventions for display. They are not different currencies.

Practical limits do exist. A very small output can cost more to spend than it is worth, and nodes that apply the default relay rules will not pass such outputs on. Fees also set a floor on what is economical on the main chain. Those limits concern which payments make sense at a given moment. They do not stop anyone from owning a fraction of a coin. A whole coin is simply a reference point, in the way a dollar is a reference point with cents below it.

## medium

The main unit names are BTC for one bitcoin, mBTC for one thousandth of a bitcoin, bit for one millionth of a bitcoin and satoshi for one hundred millionth. The Bitcoin Wiki lists these names and the related symbols, and it also notes that satoshi and sat are used for the smallest unit. BIP 176 formalises bits as 100 satoshi, and it was written partly to reduce the bias toward thinking in whole coins and to make small amounts easier to read. Its motivation is about human error in reading decimals, not about what the protocol allows.

The Lightning Network uses a smaller unit internally. The BOLT specifications define the millisatoshi, which is one thousandth of a satoshi, and use it in message fields such as amount_msat. This lets channel balances and payment amounts be expressed with more precision than the base layer's satoshi. The base layer still settles in whole satoshi, and channel opening and closing happen on chain.

On the base layer the practical minimum is set by two things. The first is the dust limit. Bitcoin Core's policy code computes a dust threshold from a feerate, so an output is dust when its value is below the cost of spending it at that rate. That rate is a relay setting of each node, not the market fee of the day, so the threshold is a policy choice that node operators can change. The second is the fee itself, measured in satoshi per virtual byte. A payment whose fee would exceed its value is uneconomical. The fee changes with market conditions and the dust rate is a setting, so no fixed number applies for all time.

The developer guide describes the protocol in satoshi, with each output stating its amount in satoshi.

The unit price of one whole coin is a market quote in some currency. The fiat cost of one satoshi is that price divided by 100,000,000, and the cost of a small payment depends on how many satoshi it moves and on the fee rate of that day. A reader who looks only at the price of one coin will misjudge small amounts, which is the usability problem BIP 176 describes.

## advanced

The strongest version of this claim is not about the software. It is about access. Many people cannot easily acquire a whole coin, and the perception that one must buy a whole coin can discourage participation. On that view the unit system is a barrier even though the protocol is divisible. BIP 176 names the same concern, listing among its motivations the reduction of "unit bias" for users who want a whole bitcoin, and the risk of error when small amounts are shown in large units. The concern is real as a matter of presentation.

The reply separates three things that the claim runs together. Divisibility is a property of the protocol, which counts integer satoshi. Display is a choice made by each wallet and each interface. The minimum economic size of an on-chain payment is a function of fees and policy at a given time. A satoshi-denominated output is valid under consensus, but a node may refuse to relay an output that is too small to spend economically under its policy. Policy can change without a fork, so the practical floor is not a fixed property of the system.

The serious objection to that reply is that the distinction is technically clean but socially thin. A user does not experience the protocol directly. They see the interface, and if it shows eight decimal places, the user may misread the amount. Interfaces that show whole-coin prices shape expectations. The reply is that a wallet can show satoshi or bits without changing the protocol.

A second objection is that on-chain fees can make small payments impractical even though the protocol allows them. The reply is that this is a fee-market fact that depends on conditions at the time, and that layers such as Lightning allow finer amounts to be moved inside channels, with on-chain settlement only at opening and closing. The objection answers that channels themselves need on-chain funds, so the floor moves rather than disappears.

The claim would become true in the protocol sense if consensus did not allow amounts below one coin, for example if outputs had to be whole numbers of bitcoin. It would become true in the economic sense if fee rates made every on-chain output below a fixed size unspendable for long periods and no other layer existed to carry smaller payments. Under the current rules and the cited software, the claim is false: amounts are integers in satoshi, and the minimum payment size depends on policy and fees that change over time.
