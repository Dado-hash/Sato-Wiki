---
id: wiki.myth-miners-control
slug: myth-miners-control
language: en
category: myths
title: '"Miners control Bitcoin"'
description: "Partly true: miners choose which valid transactions enter a block and in what order, but they cannot change the rules that nodes enforce."
difficulty: base
readTimeMinutes: 5
tags:
  - Myths
  - Mining
  - Consensus
  - Governance
related:
  - wiki.mining
  - wiki.mining-pools
  - wiki.full-nodes
  - wiki.consensus-rules
  - wiki.soft-fork-signalling
  - history.segwit-activation
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: "BIP 148: Mandatory activation of segwit deployment"
    url: https://github.com/bitcoin/bips/blob/master/bip-0148.mediawiki
    author: Shaolin Fry
  - title: "BIP 91: Reduced threshold Segwit MASF"
    url: https://github.com/bitcoin/bips/blob/master/bip-0091.mediawiki
    author: James Hilliard
  - title: Bitcoin Optech - Pooled mining
    url: https://bitcoinops.org/en/topics/pooled-mining/
    author: Bitcoin Optech
  - title: Stratum V2 specification
    url: https://github.com/stratum-mining/sv2-spec
    author: Stratum V2 contributors
  - title: Bitcoin Wiki - Segregated Witness
    url: https://en.bitcoin.it/wiki/Segregated_Witness
    author: Bitcoin Wiki contributors
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

Partly true. Miners choose which valid transactions go into each block and in what order, so they influence what gets confirmed and when. They do not set the rules. Every full node checks each block against the consensus rules, and a block that breaks them is rejected, no matter how much hashrate produced it.

Think of miners as the people who pack a mail bag. They can leave a letter out, put some letters first, or hold the bag back for a while. They cannot print new stamps, change the postal rules, or open someone else's envelope. Every post office checks the bag before passing it on. A majority of miners can rewrite the last few bags, so a payment that was just sent can be undone, and they can refuse to carry particular letters for as long as they hold the majority. Those powers are real, but they are narrow and temporary. Creating coins or spending coins that belong to someone else is outside what miners can do. The limits matter as much as the powers, so both are covered below.

## medium

Miners build block templates from the transactions in their mempool, usually ranked by fee rate. Pools often decide the template for their members. Under the Stratum v1 design that most pools have used, a member receives a header and coinbase template from the pool and may not be allowed to change the transactions in it, so whoever builds the template decides what is included. Stratum V2 adds a Job Declaration Protocol that lets a miner declare its own transaction set, which moves that choice back toward the miner.

Full nodes do the other half of the job. They check proof of work, block structure, signatures, script rules and the reward limit of the coinbase, and they reject any block that fails. A miner who finds a block that breaks a rule has spent electricity on a block that no honest node will accept.

A majority of hashrate can still reorganise recent history. The Bitcoin whitepaper shows that an attacker who overtakes the honest chain can change only the attacker's own transactions, to take back money recently spent, and that the chance of a slower attacker catching up falls exponentially as blocks are added. The same paper notes that nodes do not accept invalid transactions, so an attacker cannot create value out of thin air or take money that never belonged to it.

The 2017 SegWit activation shows the difference between signalling and deciding. BIP 148 was written because the existing SegWit deployment had not locked in by 1 August 2017. It proposed that from that date nodes running it would reject any block that did not signal for SegWit. BIP 91, also written in 2017, proposed an 80 percent signalling threshold over a 336-block window. The Bitcoin Wiki says SegWit activated soon after 1 August 2017. The signals were the mechanism, but the credible threat of rejection came from node operators.

## advanced

The strongest form of the claim runs as follows. Bitcoin's security rests on proof of work, and proof of work is controlled by whoever has the most hashrate. Ordering is power: a pool operator that controls the template can exclude transactions, favour its own, and choose which tip to extend. If a few pools dominate, the network's neutrality depends on their goodwill.

The reply has serious answers, but it is not complete. The sharpest objection concerns censorship. The Optech pooled mining topic describes the common Stratum v1 arrangement, in which members do not choose the transactions in a template and the pool may reject their attempts to change it. Stratum V2 offers a full-template mode, but whether pools adopt it is a separate question that the specification cannot answer. A majority can also exclude transactions for as long as it holds the majority. The fair reply is that exclusion is visible, that the excluded transactions can be mined by others, and that the cost falls on the censor. A delay of several blocks can still be expensive for a time-sensitive payment.

A second objection concerns users who do not run a full node. The whitepaper notes that a simplified verifier can be fooled by an attacker's fabricated transactions for as long as the attacker overpowers the network. For those users the honest-majority assumption is the only defence, and the chain they accept is whichever chain their provider shows them. The reply is that anyone can run a full node, which is true, but it does not help a user who never does.

The 2017 episode supports the reply and complicates it. Miners delayed signalling, and node operators used BIP 148 to threaten rejection of non-signalling blocks. Once that threat was credible, miners signalled through BIP 91 and SegWit activated. Critics can fairly say that miners were the mechanism of activation while the economic majority was the lever. Both readings fit the record.

The claim becomes true if rule changes could be imposed by miners against the choice of node operators, which would require nodes to stop validating or to accept whatever chain a few pools present. It would be false if a majority of hashrate tried to impose a rule that nodes rejected, and the network followed the nodes. Whether pool concentration makes censorship practical over long periods is an open question that current measurements have not settled.
