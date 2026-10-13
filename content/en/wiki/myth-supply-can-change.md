---
id: wiki.myth-supply-can-change
slug: myth-supply-can-change
language: en
category: myths
title: '"The 21 million limit can be changed"'
description: "Partly true: the limit is code that could be edited, but adding coins would be a hard fork that every node must choose to adopt, and nodes that refuse it keep the old chain."
difficulty: base
readTimeMinutes: 5
tags:
  - Myths
  - Supply
  - Forks
  - Consensus
related:
  - wiki.consensus-rules
  - wiki.forks-and-soft-forks
  - wiki.full-nodes
  - wiki.block-subsidy
  - wiki.halving
  - history.value-overflow-incident
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: Bitcoin Core - Monetary Amount Constants (amount.h)
    url: https://github.com/bitcoin/bitcoin/blob/master/src/consensus/amount.h
    author: Bitcoin Core contributors
  - title: Bitcoin Developer Guide - Block Chain
    url: https://developer.bitcoin.org/devguide/block_chain.html
    author: Bitcoin.org contributors
  - title: Bitcoin Wiki - Value Overflow Incident
    url: https://en.bitcoin.it/wiki/Value_overflow_incident
    author: Bitcoin Wiki contributors
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

Partly true. The 21 million limit is a rule written in Bitcoin's software, so the software could in principle be changed. But adding coins would be a hard fork, and every node must choose whether to adopt it. Nodes that refuse keep the old rules and the old chain, so a larger supply would not be the bitcoin that the existing network accepts.

The limit is not a promise made by anyone. It is a check that every full node runs when it accepts a block. A block that creates more coins than the rules allow is invalid, and nodes reject it. To create extra coins, someone would have to persuade the people who run nodes, miners and exchanges to adopt software that accepts a different rule, and then to make that chain the one people use.

That is why the question is about agreement as much as code. The code can be edited, but a change that creates coins only becomes Bitcoin if enough of the network runs it. Nobody can force the new rule onto nodes that keep the old one.

## medium

The supply rule sits in the consensus code. Bitcoin Core defines the maximum money value as 21,000,000 times the base unit, and nodes check that outputs stay within that range. The new coins in each block, the subsidy, shrink on a fixed schedule, which the block subsidy entry explains. The rule is therefore enforced by many independent programs, not by one central server.

Two kinds of change need to be kept apart. A soft fork tightens the rules, so that some blocks older nodes accept are now rejected. Older nodes still treat the new blocks as valid, so the upgrade can happen gradually. Creating more supply does the opposite: it makes blocks valid that older nodes reject. The developer guide describes that as a hard fork, which leaves two permanently divergent chains, one for nodes that upgraded and one for nodes that did not. It gives raising the block size above 1 MB as an example of a change that needs a hard fork.

One case in Bitcoin's history shows coins being created by mistake. On August 15, 2010, block 74638 contained a transaction that created 184,467,440,737.09551616 bitcoins. A patched client was published within five hours of the discovery. The Bitcoin Wiki says the good chain overtook the bad one at block height 74691, after which the bad transaction and the coins it created no longer existed on the longest chain. The episode was a bug, not a decision, and the network removed the coins by adopting the fix.

The lesson is that a supply change is a rule change with a social cost. It works only if the people running the software accept it, and the 2010 case worked because nearly everyone wanted the bad coins gone.

## advanced

The strongest version of the claim goes like this. Bitcoin's rules are whatever the people running the software agree to run. Miners, exchanges and wallet developers form a small group that can coordinate quickly, and a majority of hashrate could in principle mine blocks under new rules. If a large enough share of the economy adopted a larger supply, the rule would change, and the old limit would be an engineering choice rather than a fixed law.

There is a serious point in that. Bitcoin has no formal on-chain voting mechanism for protocol changes. Governance runs through software releases, miner signalling and the choices of node operators and businesses, and these are informal. A hard fork can happen without a central decision, which means it can also happen by surprise. The 2010 incident shows that rules can change in practice, through an emergency patch that the network had to adopt quickly.

The reply is that the incident differs in kind. The patch removed coins created by a bug, and the network adopted it because nearly everyone wanted the bad transaction gone. A supply increase would be a deliberate change that most holders may not want, and a hard fork creates a second chain with its own history rather than moving the existing one. Old nodes keep the rules they checked, so a coin that exists only on the new chain is a different asset, and its value depends on whether the market treats it as bitcoin. Exchanges, wallets and users would each have to make that choice.

The objections to this reply are real. Coordination is not free, and a well-funded group could fork and then persuade services to list the new chain. The reply also depends on an assumption that most economic actors prefer the existing rules, and that assumption is a fact about people, not a technical guarantee. A fork that splits the market would still leave a second asset with the same name and history in question.

For the claim to become true in the strong sense, a set of miners, exchanges and users would have to run software that accepts more coins and be treated by the market as the continuation of Bitcoin. For the claim to be clearly false, the market would have to refuse such a chain and the nodes that matter would have to keep enforcing the current limit. The practical test is whether nearly everyone adopts a supply change, because a change adopted by a minority produces a different asset.
