---
id: wiki.self-custody
slug: self-custody
language: en
category: privacy-security
title: Custody and Self-Custody
description: Who holds the keys to bitcoin, a custodian or the owner, and the trade-offs of each model, including multisig and collaborative custody as middle grounds.
difficulty: base
readTimeMinutes: 4
tags:
  - Custody
  - Self-Custody
  - Multisig
  - Security
related:
  - wiki.private-keys
  - wiki.multisig
  - wiki.wallet-seeds
  - wiki.seed-backups
sources:
  - title: Secure your wallet
    url: https://bitcoin.org/en/secure-your-wallet
    author: Bitcoin.org contributors
  - title: Securing your wallet
    url: https://en.bitcoin.it/wiki/Securing_your_wallet
    author: Bitcoin Wiki contributors
  - title: Mt. Gox
    url: https://en.bitcoin.it/wiki/Mt._Gox
    author: Bitcoin Wiki contributors
  - title: Multisignature
    url: https://bitcoinops.org/en/topics/multisignature/
    author: Bitcoin Optech
  - title: Threshold signatures
    url: https://bitcoinops.org/en/topics/threshold-signature/
    author: Bitcoin Optech
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

Custody answers one question: who can move the bitcoin? In custodial storage, a company holds the keys. You do not control the coins directly. You have a claim against the company, and it decides whether and when a withdrawal happens. In self-custody, you hold the keys yourself, and no third party is needed to spend.

Each model has its own risks. A custodian carries counterparty risk. The company can fail, freeze withdrawals or misreport balances, and you rely on its security and honesty. Self-custody removes that dependence, but it puts the responsibility on you. If you lose the keys and the backup, nobody can restore the funds. If someone else obtains the keys, they can move the coins without asking anyone.

Neither model is free of risk, and inheritance raises the same question, because heirs need a way to reach the custodian or the keys. The choice depends on how much security you can maintain, how often you need to move funds, and what will happen to the funds if you cannot act yourself. The next levels describe the trade-offs in more detail and the arrangements that sit between the two extremes.

## medium

The counterparty risk of custody has been shown in practice. The Mt. Gox exchange closed in February 2014 after bitcoin held for its customers went missing, and it later filed for bankruptcy protection. Customers who had a claim on the exchange, rather than control of their own keys, depended on its records and on the bankruptcy process that followed. The app's history section covers the event in more detail.

Self-custody has different failure modes. They are mostly about secrecy and backups. A seed or key that leaks lets the finder take the funds, and a seed that is lost or damaged cannot be replaced. A backup that was never tested may fail when it is needed. These are the risks that the private keys, wallet seeds and seed backup entries describe.

Between the two extremes, multisig spreads control across several keys. In an M-of-N setup, a spend needs M signatures from N keys. A 2-of-3 arrangement can keep the funds spendable if one key is lost, and it can keep them safe if one key is stolen, as long as the attacker does not get a second key. Keys can be held on separate devices or in separate places, which is why multisig is often described as a middle ground. The multisig entry describes how the script and the signatures fit together.

A related idea is collaborative custody. One key is held by the user and another by a service, and both must sign. The service cannot move the coins alone, and the user cannot move them alone either. This shifts the risk rather than removing it. A service that stops cooperating can block spending, and if the user loses their key, recovery depends on the service still being available.

## advanced

A custodial claim is a claim on a ledger. The company records balances and performs withdrawals on its own systems, so the depositor's protection depends on its accounting, its operational controls and its solvency. The Bitcoin.org guidance puts the core point plainly: when a third party controls your keys, you rely entirely on its security and honesty. The legal terms of any particular service are a separate question, and this entry does not assess them.

Self-custody moves that trust to the owner's procedures. Possession of the seed is equivalent to control of the funds. The Bitcoin Wiki recommends keeping backups in more than one location, encrypting any copy that touches a network, covering the whole wallet, and checking backups from time to time. Each of these steps adds effort, and each one can fail in a different way. Inheritance also depends on these procedures. Heirs need to know that the funds exist, where the backup is and how to use it, which is information that a plan has to record.

Multisig changes what a single failure means. Scripted multisig publishes several public keys and the threshold on chain when the coins are spent. Scriptless multisignature and threshold signatures publish one key and one signature, so the payment looks like an ordinary single-signature payment. Bitcoin Optech notes that this gives both greater privacy and lower cost. In threshold schemes, a subset of the signers can sign. For example, in a 2-of-3 setup each signer holds a share of one key, and any two signers can produce a valid signature together. Observers cannot tell which parties signed, which makes third-party auditing harder.

These designs carry their own trade-offs. Each signer must protect a key, and the group must agree on the setup, so the arrangement can be harder to recover if the participants do not keep records. The signers' software must also be compatible with the setup. A collaborative custody arrangement adds one more party to the signing process. Its key security, its availability and its policies all affect whether the user can spend, so the question of who controls the funds does not disappear. Time-locked recovery paths can reduce some of these risks, because a timelock can prevent an output from being spent before a set block height or time, which allows a recovery route to become available only after a delay.
