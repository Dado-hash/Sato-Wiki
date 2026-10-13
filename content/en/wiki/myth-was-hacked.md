---
id: wiki.myth-was-hacked
slug: myth-was-hacked
language: en
category: myths
title: '"Bitcoin has been hacked"'
description: "Partly true: exchanges and wallets have been broken into and the software has had serious bugs, but no known flaw let anyone spend coins without their keys."
difficulty: base
readTimeMinutes: 5
tags:
  - Myths
  - Security
  - Exchanges
  - Software Bugs
related:
  - wiki.consensus-rules
  - wiki.forks-and-soft-forks
  - wiki.self-custody
  - wiki.threat-model
  - history.mtgox-collapse
  - history.value-overflow-incident
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: "BIP 50: March 2013 Chain Fork Post-Mortem"
    url: https://github.com/bitcoin/bips/blob/master/bip-0050.mediawiki
    author: Gavin Andresen
    publishedAt: 2013-03-20
  - title: Bitcoin Core - Disclosure of CVE-2018-17144
    url: https://bitcoincore.org/en/2018/09/20/notice/
    author: Bitcoin Core contributors
    publishedAt: 2018-09-20
  - title: Bitcoin Wiki - Value overflow incident
    url: https://en.bitcoin.it/wiki/Value_overflow_incident
    author: Bitcoin Wiki contributors
  - title: Bitcoin Wiki - Mt. Gox
    url: https://en.bitcoin.it/wiki/Mt._Gox
    author: Bitcoin Wiki contributors
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

Partly true, and the useful question is which part. The protocol has not been hacked in the sense that anyone has forged signatures or spent coins without their keys. But the software has had serious bugs, and services built around bitcoin, such as exchanges and online wallets, have been broken into many times, with customers losing funds.

Think of three layers. The protocol is the set of rules. The software is the program that implements them. The services are the exchanges and wallet companies that hold keys or balances for other people. A break-in at a service is theft from that service's customers, and it does not change the protocol. A bug in the software can be more serious. In 2010 a flaw let one transaction create far more coins than the rules allow, and the network had to be patched quickly. Such bugs were found and fixed through disclosure and upgrades. The accurate statement is that software and services can fail and that the failures have cost people money. The inaccurate statement is that an outsider can take bitcoin from a holder who keeps their own keys.

## medium

The three layers need separate answers. The protocol is what full nodes enforce: block structure, proof of work, signatures, script and the supply limit. A transaction with a forged signature is rejected, and nothing in the protocol moves coins whose keys are not presented. Exchanges and custodial wallets are different. When a company holds the keys, an attacker who compromises the company can take them, and the customer's claim is against the company. Mt. Gox is a known case. In June 2011 an attacker used credentials taken from an auditor's compromised computer and used the exchange's own software to sell bitcoins it did not hold, which briefly pushed the displayed price down. The exchange later collapsed in February 2014, and the Bitcoin Wiki records heavy losses for its customers.

Software bugs form the second layer. In March 2013 a block with more transaction inputs than some older nodes could handle caused a chain split. Nodes running pre-0.8 software rejected the block, while 0.8 nodes accepted it. BIP 50, written afterwards, explains that the root cause was a database lock limit that had effectively become a consensus rule. Miners and pools downgraded their nodes to restore the older chain, and the split was resolved.

In September 2018 Bitcoin Core disclosed CVE-2018-17144, a flaw in the check that stops one transaction from spending the same input twice. The disclosure states that it was a critical inflation vulnerability, meaning a miner could have inflated the supply. The fix was released in Bitcoin Core 0.16.3 and 0.17.0rc4 on 18 September 2018.

The 2010 value overflow belongs to the same family. A block created coins through an output sum that overflowed, a rule change was released within hours, and the chain briefly forked before the valid chain overtook the invalid one.

The practical lesson concerns custody. Where a holder controls the keys, the protocol's protections apply to those coins. Where a company holds the keys, the company's security is the security that matters.

## advanced

The strongest form of the claim is that bitcoin is only as secure as the weakest software and service around it. If an exchange holds much of the money people use, one break-in moves a large amount of value. If the software can inflate supply through a bug, the supply guarantee depends on code that can be wrong.

The serious reply accepts most of this and narrows it. A protocol failure means a failure of the rules every node enforces, and the record shows such failures were caught and corrected. None of the known cases let a holder's coins be spent without the holder's key. The whitepaper grounds ownership in digital signatures: each transfer is authorised by a signature over the transaction and the next owner's public key. A forged signature fails validation at every full node.

The objection to this reply is that "no one spent coins without keys" is a narrow test. A bug that creates coins dilutes every holder, which is a loss even if no key is touched. A chain split can leave a double spend valid on one side for a while. BIP 50 records one large double spend during the 2013 split, which was made by someone experimenting to see whether it was possible. The reply answers that dilution still requires a bug, and that bugs are caught by testing and disclosure. The critic answers that catching them has depended on individuals who happened to be watching.

Services are a separate matter. Custodial exchanges and wallets are not part of the protocol, and their losses are not evidence that the protocol was hacked. Still, the practical question is how much of the money people hold sits under someone else's keys. That share depends on user choice and differs from person to person and period to period, so no general figure can be given here.

The claim would become true in the narrow sense if an attacker could spend a holder's coins without that holder's key, for example through a break of the signature scheme or a consensus bug that skipped signature checks. It would be false in that sense for as long as signature verification holds. The claim becomes broadly true in practice if most holdings sit with custodians whose security fails often. The claim is false as a statement about the protocol's design, since the record shows its known failures were bugs in code, not a flaw in the ownership model.
