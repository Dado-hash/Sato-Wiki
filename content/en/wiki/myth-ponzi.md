---
id: wiki.myth-ponzi
slug: myth-ponzi
language: en
category: myths
title: '"Bitcoin is a Ponzi scheme"'
description: "Mostly false as a description of how the network works, with a fair point inside it: the price depends on new buyers, and many scams have used bitcoin."
coverImage: media/wiki/myth-ponzi/myth-ponzi-hero.svg
difficulty: base
readTimeMinutes: 5
tags:
  - Myths
  - Economics
  - Scams
  - Market
related:
  - wiki.blockchain
  - wiki.miner-incentives
  - wiki.consensus-rules
  - wiki.full-nodes
  - wiki.myth-miners-control
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: Ponzi scheme
    url: https://en.wikipedia.org/wiki/Ponzi_scheme
    author: Wikipedia contributors
  - title: Bitcoin
    url: https://en.wikipedia.org/wiki/Bitcoin
    author: Wikipedia contributors
  - title: "Yes, Bitcoin is a Ponzi: A Re-Rebuttal"
    url: https://ic.unicamp.br/~stolfi/bitcoin/2021-01-16-yes-ponzi.html
    author: Jorge Stolfi
    publishedAt: 2021-01-16
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

Mostly false as a description of how the network works, with a fair point inside the objection. A Ponzi scheme has an operator who promises returns and pays earlier investors with money from later ones. Bitcoin has no operator, promises no return to anyone, and its rules and ledger are public. The fair point is that the market price depends on whether new buyers keep arriving, and many scams have used bitcoin or its name. That is why critics reach for the word.

Compare the features one by one. A Ponzi scheme needs someone who collects money and decides who gets paid. Bitcoin has no company, fund or treasury that takes deposits and sends them back out. Payments go from one owner to another, and the network records them without an intermediary. A Ponzi scheme promises a return. Bitcoin promises none, and a holder earns nothing simply by holding it. A Ponzi scheme keeps its books hidden. Bitcoin's ledger can be read by anyone who runs a node. The differences are structural, and they are the reason the word fits badly, even though the price risk the critics describe is real.

## medium

Wikipedia's definition of a Ponzi scheme is a useful starting point. It is a form of fraud that pays apparent profits to earlier investors with funds from more recent investors, and the scheme usually promises high returns with little or no risk. Such schemes collapse when it becomes hard to recruit new investors or when many existing investors ask for their money back. The definition has three parts: fraud, an operator, and payments funded by new money.

Bitcoin's design lacks the first two parts. The whitepaper describes a peer-to-peer system in which transactions are verified by the network without a trusted third party. Nobody takes deposits. Miners receive new coins and fees for securing the ledger, which are payments for work done, not returns to investors. Those payments are made by the protocol, not by a manager using later money to pay earlier holders.

The third part is where the critics' argument lives. A holder who sells needs a buyer, and the market price depends on demand. If demand from new buyers stopped, the price could fall a long way. That dependence is real, and it is the reason the word is used loosely.

Scams have used bitcoin, and some have used its name. Wikipedia's Ponzi article notes that cryptocurrencies have been employed by scammers attempting a new generation of Ponzi schemes, including misuse of initial coin offerings, and that most such schemes have low recovery rates for investors. Those cases are operators running schemes on top of bitcoin, not the protocol itself being a scheme. The distinction matters, because a scam can be prosecuted and a protocol cannot be prosecuted in the same way.

Opinions differ. Wikipedia's Bitcoin article reports that economist Nouriel Roubini described bitcoin as a Ponzi scheme in 2014, that legal scholar Eric Posner disagreed because a real Ponzi scheme requires fraud, and that a 2014 World Bank report concluded bitcoin was not a deliberate Ponzi scheme.

## advanced

The strongest version of the claim does not need an operator. It uses a looser definition: a structure in which early holders can be paid only by later buyers, and the asset generates no cash flow of its own. Jorge Stolfi's 2021 essay argues that bitcoin's money flow is one-way, from buyers to miners, and that the miners' costs are covered by outside money. As of that essay he put the net flow from investors to miners since 2009 at about 15 billion US dollars, and he argued that the system must keep attracting new money to continue. On that reading, the Ponzi label describes a dependency, not a fraud.

The reply has several parts. First, the miners are paid for a service, which is securing the ledger, and that service has a function that a Ponzi scheme's payments do not. Second, no one has promised holders an income, so the central promise of a Ponzi scheme is missing. The reply to Stolfi's flow argument is that payments for securing a network are a cost of operating it, and that any system with recurring costs needs revenue from somewhere.

The serious objection to this reply is that the dependency sits in the price, not in a manager, and that the price can behave like a scheme regardless of who runs it. The reply that a dependency on later buyers is not the same as a payment funded by later buyers is fair, but it does not show whether bubble-like price moves are happening. That question is open, and this entry does not answer it.

The fair part of the objection survives both replies. Scams and collapsing schemes have used bitcoin, and a holder who buys into a structure promising returns is exposed to an operator's fraud regardless of the protocol. The protocol is a different thing from the investment products built around it. Treating them as one object is where the claim goes wrong.

The claim would become true in the sense that matters if the protocol had an operator who collected funds and promised returns that were paid from later deposits. It would also become true for a specific product if its operator did exactly that. It is false for the protocol as described in its whitepaper and rules for as long as those features are absent. Whether the price structure resembles a Ponzi dynamic is a separate, open question.
