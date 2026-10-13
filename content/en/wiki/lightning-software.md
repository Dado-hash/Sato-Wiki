---
id: wiki.lightning-software
slug: lightning-software
language: en
category: software
subcategory: lightning
title: Lightning Software
description: Lightning node implementations and wallets, how they interoperate through the BOLT specifications, and what channel backups and watchtowers can and cannot protect.
difficulty: base
readTimeMinutes: 4
tags:
  - Lightning
  - Software
  - Channel Backups
  - Custody
related:
  - wiki.lightning-network
  - wiki.payment-channels
  - wiki.bolt-specifications
  - wiki.watchtowers
  - wiki.lightning-service-providers
sources:
  - title: Lightning Network Specifications (BOLTs)
    url: https://github.com/lightning/bolts
    author: Lightning Network developers
  - title: Static channel backups
    url: https://bitcoinops.org/en/topics/static-channel-backups/
    author: Bitcoin Optech
  - title: Watchtowers
    url: https://bitcoinops.org/en/topics/watchtowers/
    author: Bitcoin Optech
  - title: Backup your wallet - Core Lightning
    url: https://docs.corelightning.org/docs/backup
    author: Core Lightning contributors
  - title: LDK, a Lightning implementation packaged as an SDK
    url: https://lightningdevkit.org/
    author: LDK contributors
  - title: Eclair, a Scala implementation of the Lightning Network
    url: https://github.com/ACINQ/eclair
    author: ACINQ
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

Lightning software is the set of programs that open payment channels and send payments over them. There are two broad kinds. A Lightning node implementation runs the channel logic, routing and on-chain actions. A Lightning wallet is the app a person uses to send and receive, and it may run its own node or rely on someone else's. Examples of node implementations include LND, Core Lightning, Eclair and LDK, which is packaged as a library for developers to build on.

These programs can talk to each other because they follow the BOLT specifications, a shared set of rules for messages and channel behavior. Interoperability is the reason you can open a channel with a node made by a different team.

Wallets differ in who controls the funds. In a self-custodial wallet, you hold the keys to your channels. In a custodial wallet, a company holds the funds and records your balance. Some wallets sit in between and use a service provider that helps open and manage channels for you. Each model changes what you must trust and what happens if the provider goes offline.

Lightning channels need attention while you are away. A channel can be used to cheat if the other side publishes an old state, so the software must be online to respond, or you need another service that watches for this.

## medium

A channel is only as recoverable as the data you keep about it. Static channel backups (SCBs) are files that only need an update when a channel is opened or closed. If your node loses its state, an SCB lets it ask a peer to close the channel using the latest state the peer holds. This can recover funds, but Bitcoin Optech lists two risks. The peer may guess that your node is stale and try to close with an old state, and a node that lost its data may not be able to prove it. And if both sides lose state, or the peer disappears, an SCB cannot recover the channel.

Seed recovery covers less than people often expect. Core Lightning's documentation separates its backup items. The HSM secret, stored as the hsm_secret file, is sufficient to recover on-chain funds from the wallet, and it is necessary but not sufficient for funds locked in channels. Channel state and channel database files are needed as well.

A watchtower is a service that watches the blockchain for an old channel state being broadcast. When it sees one, it can publish a penalty transaction on your behalf. Watchtowers do not hold your funds. Their job is to monitor and broadcast, so they cannot spend your channel balance. The design lets you stay offline for long periods without leaving the channel exposed, but a watchtower is still a third party that sees some of your channel activity, and it only helps if the penalty is possible.

Implementation choices also affect the user. A node you run yourself gives you control over fees, channels and privacy settings. Read the documentation to find which backups the software creates, how often they update, and how you restore after a failure.

## advanced

Interoperability depends on the BOLTs and on the features that two peers negotiate. Two implementations can both support a feature while differing in defaults, timing or recovery behavior, so a payment that works between one pair of nodes may behave differently with another.

Channel backups have a clear trade-off. An SCB saves enough channel information to ask the peer to close the channel, so it works without the full state history, but it is only as current as your last update. The option_data_loss_protect mechanism gives the peer a reason to close honestly when it hears from a stale node. That protection depends on the peer, and it fails if the peer also lost its state. A complete backup of channel state is more robust, but it has to be kept in step with the live node, which is a harder operational task.

Watchtowers protect against a specific attack: the counterparty broadcasting a revoked state while you are offline. A tower holds breach remedy transactions that let it claim the funds in that case. Optech notes that breach remedy transactions can be designed so that the tower receives part of the protected funds, which gives it an incentive to act. A tower that is offline, censored or unreachable offers no protection, and a tower that sees your channel updates learns something about your payments. Some implementations let users delete sessions, and some track accountability proofs, which reflects that the service is a trust relationship, not a free guarantee.

Custodial and self-custodial models carry different failure modes. A custodial wallet can freeze, lose or misreport funds, and users rely on its solvency and records. A self-custodial wallet keeps the keys with the user, which removes that counterparty risk but adds the operational risk of backups, uptime and liquidity management. A service-provider wallet sits between them: the provider manages channels and liquidity for the user, so the user must trust the provider's accounting and availability while keeping the keys.

Software choice is therefore part of security design. Read how the implementation handles channel state, how often it saves backups, whether it can run a watchtower, and what it requires to be online. Do not assume that an implementation's behavior in one scenario carries over to another.
