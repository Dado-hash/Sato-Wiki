---
id: wiki.soft-fork-signalling
slug: soft-fork-signalling
language: en
category: protocol
title: Soft Fork Activation and Signalling
description: How Bitcoin coordinates a soft fork, with miners signalling readiness through version bits, rules moving through defined states, and nodes, not miners, deciding what is valid.
difficulty: advanced
readTimeMinutes: 4
tags:
  - Soft Forks
  - Activation
  - Version Bits
  - Taproot
  - BIP 8
related:
  - wiki.forks-and-soft-forks
  - wiki.consensus-rules
  - wiki.segregated-witness
  - wiki.taproot
  - wiki.full-nodes
sources:
  - title: "BIP 9: Version bits with timeout and delay"
    url: https://github.com/bitcoin/bips/blob/master/bip-0009.mediawiki
    author: Pieter Wuille, Peter Todd, Greg Maxwell, Rusty Russell
  - title: "BIP 8: Version bits with lock-in by height"
    url: https://github.com/bitcoin/bips/blob/master/bip-0008.mediawiki
    author: Shaolin Fry, Luke Dashjr
  - title: "BIP 341: Taproot - SegWit version 1 spending rules"
    url: https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki
    author: Pieter Wuille, Jonas Nick, Anthony Towns
  - title: "BIP 148: Mandatory activation of segwit deployment"
    url: https://github.com/bitcoin/bips/blob/master/bip-0148.mediawiki
    author: Shaolin Fry
  - title: Bitcoin Optech - Soft fork activation
    url: https://bitcoinops.org/en/topics/soft-fork-activation/
    author: Bitcoin Optech
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

A soft fork makes some previously valid blocks invalid. Every block accepted under the new rules is also accepted under the old ones, so nodes that have not upgraded keep following the same chain. Activation is the moment the new rules start to be enforced, and the network needs a way to agree on when that moment comes.

For most of Bitcoin's history, miners signalled readiness. A miner sets a bit in the block version field to say that its software supports the new rule. The network counts these signals period by period, and when enough blocks signal, the rule becomes active a little later. This is coordination: the signal tells everyone that most of the hashrate is ready to enforce the rule.

The signal is a bit in every block header, so anyone who reads the chain can count it. Signalling does not make a rule valid. Nodes check the rule on their own. A block that breaks the new rule is rejected by every upgraded node, even if it carries a signal. The signal tells operators which software miners run. It does not change what nodes accept.

## medium

Version bits make signalling possible without a new block format. The block header version field is read as a 32-bit integer, and each deployment is assigned one bit. A block signals for a deployment by setting that bit while its top three bits are 001. BIP 9 counts signals over retarget periods of 2016 blocks, about two weeks at the target rate. A deployment moves through five states. It starts in DEFINED. It becomes STARTED once its start time has passed. It becomes LOCKED_IN after a period in which at least the threshold of blocks signalled. It becomes ACTIVE one period after lock-in. If the timeout passes before lock-in, it becomes FAILED.

The BIP 9 threshold is 1916 of 2016 blocks, which is 95 percent. BIP 8 describes the weakness of this design: near-unanimous signalling is needed, so a small minority of non-signalling hashrate can veto activation.

BIP 8 keeps version bit signalling but replaces the timeout with lock-in by height. Its lockinontimeout parameter decides what happens if signalling falls short. When the parameter is off, the deployment fails at the timeout, as in BIP 9. When it is on, the deployment enters MUST_SIGNAL in the last period before the timeout. During that period, once 2016 minus the threshold blocks have failed to signal, any further block that fails to signal is invalid. The deployment then locks in whatever the count, so miners cannot block it indefinitely. The BIP suggests a threshold of 1815 blocks, which is 90 percent, for mainnet.

Mandatory signalling is a deployment choice with real consequences. It forces miners to signal before they may mine valid blocks. Anyone running upgraded software needs to know which mode a deployment uses and what its deadline is.

## advanced

Speedy Trial is the name Bitcoin Optech uses for the short deployment process used for Taproot. BIP 341 describes it as BIP 9 with a lower threshold, a minimum activation height and a changed state transition for the DEFINED, STARTED and LOCKED_IN states. For mainnet, the deployment used bit 2, a start time of 24 April 2021, a timeout of 11 August 2021, a threshold of 1815 blocks (90 percent) and a minimum activation height of 709632. The rules activated at that height. A deployment that did not reach the threshold before the timeout would have failed.

BIP 148 is the best-known user-activated soft fork. It was written to take effect on 1 August 2017 and to require the existing SegWit deployment, bit 1, in every block. Under BIP 148, a block that did not signal would be rejected by nodes running it. The BIP is active only if the existing deployment has not locked in by its start time, and it ceases once SegWit locks in. Its purpose was to make non-signalling miners risk having their blocks rejected, which put pressure on miners to activate SegWit through the normal mechanism. The risk is that miners on the old rules keep building a chain that these nodes reject.

Activation is therefore an economic process as well as a technical one. Miners extend chains under the rules the network accepts, while nodes decide what the network accepts. Optech describes the central risk of any activation method: if nodes enforce different rules, blocks that break the non-uniform rule can be accepted by some nodes and rejected by others, causing a chain split. Activation mechanisms exist to reduce that chance, and each one trades the risk of miner delay against the risk of a contested chain.

Advanced readers should separate three questions that BIP 8 and BIP 9 answer differently: when signalling starts, what counts as success, and what happens at the deadline. Those answers determine whether a deployment can be delayed by a minority, and whether it fails or reaches a fixed height at the end.
