---
id: wiki.lightning-service-providers
slug: lightning-service-providers
language: en
category: lightning network
title: Lightning Service Providers
description: Third-party services that connect end-users to the Lightning Network by offering inbound liquidity, reliable routing, channel management, and always-on node operation.
coverImage: media/wiki/lightning-service-providers/lsp-architecture.svg
difficulty: advanced
readTimeMinutes: 8
tags:
  - Lightning Network
  - LSP
  - Service Provider
  - Inbound Liquidity
  - Node Operation
related:
  - wiki.lightning-network
  - wiki.channel-liquidity
  - wiki.routing-fees
  - wiki.watchtowers
  - wiki.splicing
  - wiki.payment-channels
sources:
  - title: "LSP Specification (LSPS)"
    url: https://github.com/lightning/bolts/issues/818
    author: Lightning Network Community
  - title: "LSP — Lightning Service Provider Overview"
    url: https://docs.lightning.engineering/lightning-network-tools/lsp
    author: Lightning Labs
  - title: "Mastering the Lightning Network — Node Operations"
    url: https://github.com/lnbook/lnbook
    author: Andreas M. Antonopoulos, Olaoluwa Osuntokun, Rene Pickhardt
updatedAt: 2026-05-27T00:00:00Z
---

## base

An LSP (Lightning Service Provider) is a service that manages Lightning connectivity for users, acting as the bridge between a mobile wallet and the wider Lightning Network. Without an LSP, a newly created node starts with zero channels and no ability to receive payments — it can only send funds out through channels it opens itself.

**The main problem LSPs solve is inbound liquidity.** When a user opens a channel to a peer, the funds sit on the user's side, meaning the peer has inbound capacity but the user does not. To receive payments, someone else must open a channel to the user — which is exactly what an LSP does. The LSP opens a channel *to* the user, providing outbound capacity from the LSP's perspective and inbound capacity from the user's.

**What an LSP provides:** a direct channel from the LSP to the user with initial outbound capacity (giving the user immediate receive capability), always-on routing so payments to and from the user reach their destination, watchtower monitoring that protects the user's channel while their wallet is offline, and channel backups that prevent fund loss if the mobile device is wiped.

**Analogy.** An LSP is like an ISP (Internet Service Provider) for the Lightning Network. When you sign up for internet at home, the ISP provides the modem and cable — you do not need to build your own infrastructure. Similarly, an LSP provides the Lightning connectivity so you can send and receive payments without running a full-time node with many channels.

![LSP Architecture](media/wiki/lightning-service-providers/lsp-architecture.svg "An LSP connects end-users to the Lightning Network, providing liquidity, routing, and always-on availability.")

## medium

**How LSPs work.** The LSP operates a well-connected node with many channels to other well-connected nodes on the network. When a user connects to an LSP, the LSP opens a channel to the user, funding it with bitcoin from the LSP's own reserves. From the user's perspective, this channel has inbound capacity — they can immediately receive payments without first spending their own funds to push liquidity to the other side.

**Just-In-Time (JIT) channels.** A more sophisticated model is the JIT channel. In this setup, the LSP does not open a channel to the user upfront. Instead, when a payment arrives for the user, the LSP opens a channel on-the-fly, forwards the payment through it, and keeps the channel open for future payments. JIT channels reduce upfront costs for the user and allow LSPs to allocate capital only when it generates routing fees.

**LSP fee models.** LSPs typically charge through one or more of these structures:

- **Channel lease fee:** a one-time or recurring fee for opening and maintaining a channel of a specific size (e.g., 0.01 BTC channel for 30 days).
- **Per-payment percentage:** a small percentage of each payment routed through the LSP.
- **Flat monthly subscription:** a fixed fee for a bundle of services including inbound liquidity, routing, and watchtower coverage.

**The inbound liquidity market.** LSPs compete on price, reliability, channel size, and geographic proximity (lower latency means faster routing). Users can compare lease offers and choose LSPs that offer the best rates for their desired channel size and duration. Some LSPs also offer free tiers with limited channel sizes to attract new users.

**Channel leases.** A channel lease is a time-bound agreement where the LSP commits funds to a channel with the user. After the lease expires, the LSP may close the channel or the user can renew. Leases are denominated in bitcoin amount and duration, typically ranging from 0.01 BTC to 0.5 BTC for 30 to 365 days.

![LSP Services](media/wiki/lightning-service-providers/lsp-services.svg "LSPs offer inbound liquidity, reliable routing, and channel management services, each with different pricing models.")

## advanced

**LSPS (LSP Specification).** As the LSP ecosystem grew, the need for a standard protocol for LSP-client communication became clear. The LSPS (LSP Specification) is an ongoing effort within the Lightning Network community to define how LSPs and clients interact. It is organized as a set of sub-protocols, each identified by an LSPS number:

**LSPS0 — Transport layer.** Defines the transport protocols that LSPs and clients use to communicate. The two primary transports are WebSocket (recommended for mobile clients) and gRPC (recommended for server-to-server communication). LSPS0 also handles authentication, error reporting, and capability negotiation.

**LSPS1 — Inbound channel purchase.** The most fundamental service: the client requests an inbound channel of a specific size from the LSP, pays a lease fee (on-chain or via Lightning), and the LSP opens the channel. The protocol handles fee negotiation, channel duration, and the funding flow. This is the LSP equivalent of buying a prepaid SIM card.

**LSPS2 — Just-In-Time channels.** Instead of purchasing a channel upfront, the client registers with the LSP and provides an invoice or payment identifier. When a payment arrives for the client, the LSP opens a channel, forwards the payment, and invoices the client for the service. This model is ideal for users who receive payments infrequently and do not want to prepay for channel capacity.

**Tower connectivity.** Many LSPs bundle watchtower services with their channel offering. Since the LSP is already always-on and monitoring the blockchain, extending watchtower coverage to the user's channel is a natural addition. The user delegates the responsibility of watching for revoked commitment transactions to the LSP, or to a dedicated watchtower that the LSP operates.

**Splicing as an LSP service.** Splicing allows a channel's capacity to be adjusted without closing and reopening it. An LSP can offer splicing as a managed service: when a user wants to add or remove funds from their channel, the LSP coordinates the splice transaction. From the user's perspective, the channel remains active throughout — there is no downtime. This is particularly valuable for mobile wallets that need to adjust channel sizes as their spending and receiving patterns change.

**Zero-conf channels.** A zero-conf (zero-confirmation) channel is one that the LSP opens and the user starts using immediately, before the funding transaction is confirmed on the Bitcoin blockchain. The LSP takes on the risk that the funding transaction might not confirm (due to double-spend or low fees), but in practice this risk is minimal with proper fee estimation. Zero-conf channels provide an instant user experience: the user can receive payments seconds after installing a wallet, without waiting for on-chain confirmations.

**Regulatory considerations.** As LSPs handle bitcoin and charge for services, they may be subject to money transmission regulations in certain jurisdictions. While running a Lightning node is generally considered a software activity, operating an LSP as a business that facilitates payments and charges fees can trigger KYC/AML requirements. This creates tension between the self-custodial, permissionless ethos of Bitcoin and the regulatory obligations that LSPs may face. Some LSPs operate without KYC as pure software services, while others implement compliance programs.

**The future of LSPs.** The LSP landscape is evolving toward more decentralized models:

- **Decentralized LSP marketplaces:** platforms where multiple LSPs compete for user channels, allowing users to compare rates and switch providers seamlessly.
- **Liquidity auctions:** users request channel capacity and LSPs bid to provide it, driving prices down through competition.
- **Federated LSPs:** groups of nodes pool liquidity and share the routing revenue, reducing the capital requirements for any single participant.

**LSPs vs submarine swaps.** Both LSPs and submarine swaps provide inbound liquidity, but they work differently. A submarine swap converts on-chain bitcoin to Lightning bitcoin (or vice versa) through a trusted third party, usually in a single atomic transaction. An LSP, by contrast, provides a lasting channel relationship with ongoing routing and management services. Submarine swaps are a one-time liquidity fix; LSPs are a continuous service relationship. Many users combine both: using submarine swaps for occasional adjustments and an LSP for day-to-day connectivity.
