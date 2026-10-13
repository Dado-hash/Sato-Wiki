---
id: wiki.dandelion
slug: dandelion
language: en
category: privacy-security
title: Dandelion
description: A relay proposal that hides which node first announced a transaction by passing it along a short stem of single peers before normal broadcast, and why Bitcoin Core has not adopted it.
coverImage: media/wiki/dandelion/dandelion-hero.svg
difficulty: advanced
readTimeMinutes: 5
tags:
  - Dandelion
  - Privacy
  - P2P Network
  - Transaction Relay
related:
  - wiki.peer-to-peer-network
  - wiki.mempool
  - wiki.block-propagation
  - wiki.tor
sources:
  - title: "BIP 156: Dandelion - Privacy Enhancing Routing"
    url: https://github.com/bitcoin/bips/blob/master/bip-0156.mediawiki
    author: Brad Denby, Andrew Miller, Giulia Fanti, Surya Bakshi, Shaileshh Bojja Venkatakrishnan, Pramod Viswanath
  - title: "Dandelion++: Lightweight Cryptocurrency Networking with Formal Anonymity Guarantees"
    url: https://arxiv.org/abs/1805.11060
    author: Giulia Fanti, Shaileshh Bojja Venkatakrishnan, Surya Bakshi, Bradley Denby, Shruti Bhargava, Andrew Miller, Pramod Viswanath
  - title: "Bitcoin Core pull request 13947: review comment on Dandelion stem routing"
    url: https://github.com/bitcoin/bitcoin/pull/13947#issuecomment-513858189
    author: Bitcoin Core contributors
  - title: "Bitcoin Optech Newsletter 426: private broadcast fix"
    url: https://bitcoinops.org/en/newsletters/2026/10/09
    author: Bitcoin Optech
  - title: Bitcoin Core 31.0 release notes
    url: https://bitcoincore.org/en/releases/31.0/
    author: Bitcoin Core contributors
  - title: Transaction origin privacy
    url: https://bitcoinops.org/en/topics/transaction-origin-privacy/
    author: Bitcoin Optech
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

Every node that receives a transaction can pass it on to its other peers. An observer who runs many nodes, or who connects to many of them, can watch which connection announces a transaction first. The first node to send a transaction is often the node that created it. If that node's IP address is known, the observer can link the transaction to a place or a person.

Dandelion is a proposal that makes this kind of guess harder. Instead of announcing a new transaction to all peers at once, a node first passes it along a line of single peers. This is the stem phase. At each step the transaction may leave the stem and enter the fluff phase, which is ordinary broadcast to all peers. Because the first wide announcement now comes from a node that may not have created the transaction, that announcement says less about where the transaction started.

Dandelion is not part of Bitcoin Core. BIP 156 describes the idea, and its status is closed. Bitcoin Core does not use a stem phase. The stem also adds delay, and a peer on the stem path can stop forwarding a transaction. The medium level explains how the protocol deals with these problems, and the advanced level explains why the proposal was not merged.

## medium

The problem has a clear model. Suppose an observer controls or watches many nodes. For each transaction, the observer records which node announced it first. Bitcoin's broadcast relay makes that first announcement close to the origin. BIP 156 describes the risk in these terms: the transaction spreading protocol can be attacked with fingerprinting from a botnet, which can link transactions to IP addresses. The Dandelion++ paper by Giulia Fanti and co-authors studies the same kind of adversary, a botnet that controls a fraction of the nodes and may not follow the protocol.

Stem routing answers this with a path. In BIP 156, each node selects two outbound peers as Dandelion destinations, and it sends the stem transactions it receives from a given inbound peer to the same destination. At each hop a biased coin flip sends the transaction into the fluff phase, with a probability of about 10 percent. Dandelion++ uses a similar idea on a graph in which each node has about four connections, and it treats the chance of leaving the stem at each hop as a parameter. A stem therefore has a random length, and the node that starts the fluff phase is usually not the origin.

A relay on the stem could drop a transaction, whether it is faulty or malicious. Dandelion handles this with an embargo timer. When a node receives a stem transaction, it starts a timer. If the transaction does not appear in the mempool before the timer expires, the node broadcasts it itself.

The guarantees have limits. The Dandelion++ paper states that the scheme does not stop targeted attacks. It leaves out adversaries at the level of an internet provider, which can isolate a node and then defeat routing-based defences for that node. Its privacy is probabilistic, not absolute.

Finally, a node with no Dandelion-capable peers falls back to ordinary behaviour, according to the BIP. A partial rollout is therefore possible, but the benefit depends on how many nodes on a path take part.

## advanced

Bitcoin Core has not adopted BIP 156, and the reasons are visible in its review history. The review of pull request 13947 raised concerns about denial of service during stem routing. A Bitcoin Core developer wrote that the design still needed answers for transaction chains and replacement transactions, as well as for how to prevent denial of service while a transaction is on the stem. Another reviewer pointed out that a stem transaction which depends on another stem transaction would fail mempool acceptance, because the code had no separate pool for stem transactions.

A separate stem pool raises its own questions. The same reviewer was unsure how a pool shared across several inbound peers could avoid leaking routing information to an adversary, and noted that separate pools for each inbound peer would add significant overhead. The review records these as open questions. They are the mempool complexity behind the decision, and the BIP's reference implementation is a separate project.

Bitcoin Core takes a different route to origin privacy, based on the transport. Version 31.0, released in April 2026, added an opt-in option named -privatebroadcast. When it is enabled, transactions submitted through the sendrawtransaction RPC are broadcast only over Tor or I2P. Recipients never see the originator's IP address, and two unrelated transactions from the same originator cannot be linked through the network. The path of the transaction does not change. The network connection is what hides the source.

The feature has its own limits. An attacker that controls one of the private-broadcast peers could infer the origin from the way the initial attempts ended. A later change, reported in Optech newsletter 426, makes Bitcoin Core complete all three initial attempts over Tor or I2P even after the transaction has reached the wider network. Later changes to this feature appear in the Optech topic on transaction origin privacy, so the release notes of the exact version matter. Rebroadcasting is part of the same problem: each rebroadcast gives an observer another chance to identify the origin, so a wallet that repeats broadcasts can weaken the protection that the first broadcast had.

Dandelion and private broadcast address the same question in different places. Dandelion changes the path a transaction takes between peers, while private broadcast changes the network connection that the originator uses to send it.
