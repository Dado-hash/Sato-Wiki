---
id: wiki.bolt-specifications
slug: bolt-specifications
language: en
category: lightning network
title: BOLT Specifications
description: The Basis of Lightning Technology — a set of specifications that define the Lightning Network protocol, covering peer communication, channel management, transaction formats, and routing.
coverImage: media/wiki/bolt-specifications/bolt-architecture.svg
difficulty: advanced
readTimeMinutes: 9
tags:
  - Lightning Network
  - BOLT
  - Specifications
  - Standards
  - Protocol
related:
  - wiki.lightning-network
  - wiki.payment-channels
  - wiki.onion-routing
  - wiki.lightning-invoices
  - wiki.commitment-transactions
  - wiki.splicing
sources:
  - title: "Lightning Network BOLTs Repository"
    url: https://github.com/lightning/bolts
    author: Lightning Network Community
  - title: "BOLT #1 — Base Protocol"
    url: https://github.com/lightning/bolts/blob/master/01-protocol.md
    author: Lightning Network Specifications
  - title: "Mastering the Lightning Network — Appendix: BOLT Reference"
    url: https://github.com/lnbook/lnbook
    author: Andreas M. Antonopoulos, Olaoluwa Osuntokun, Rene Pickhardt
updatedAt: 2026-05-27T00:00:00Z
---

## base

BOLT stands for **Basis of Lightning Technology**. The BOLTs are the official protocol specifications that define how the Lightning Network works — every implementation that wants to be interoperable must follow them.

There are nine active BOLT documents, each covering a different aspect of the protocol. They are hosted on GitHub at `github.com/lightning/bolts`, where anyone can read the source, track changes, and propose improvements.

The specifications ensure that different Lightning implementations — LND, Core Lightning, Eclair, LDK — speak the same language. Without the BOLTs, each implementation would define its own wire format, its own channel logic, and its own routing scheme, making interoperability impossible.

![BOLT Protocol Stack](media/wiki/bolt-specifications/bolt-architecture.svg "The nine active BOLT specifications organised as a protocol stack, from transport to application layer.")

## medium

The BOLT documents are individually numbered. Each addresses a specific layer or function of the protocol:

**BOLT #1 — Base Protocol.** Defines the encrypted transport, the initial cryptographic handshake, the message format (2-byte type + length-prefixed payload), and error handling. Every message exchanged between Lightning nodes uses the framing defined here.

**BOLT #2 — Peer Protocol.** Specifies the complete lifecycle of a payment channel: open, accept, fund, update the commitment transaction, and close. It defines how HTLCs are added and removed, how commitment signatures are exchanged, and how cooperative and unilateral closes work.

**BOLT #3 — Bitcoin Transaction and Script Formats.** Describes the exact structure of commitment transactions, HTLC output scripts, and the penalty mechanism that enforces channel security. Includes details on `to_local`, `to_remote`, and HTLC timeout/success outputs.

**BOLT #4 — Onion Routing.** Covers the construction of onion-encrypted payment packets using the Sphinx protocol. Specifies how the payer builds nested encryption layers, how each hop decrypts its per-hop payload, and how errors bubble back.

**BOLT #5 — Recommendations for On-Chain Transaction Handling.** Provides guidance on fee management, UTXO selection, and how implementations should handle the on-chain close of channels when the peer is unresponsive.

**BOLT #7 — P2P Node and Channel Discovery.** Defines the gossip protocol that lets nodes discover each other and learn about public channels. Covers `node_announcement`, `channel_announcement`, and `channel_update` messages that build the network graph.

**BOLT #8 — Encrypted and Authenticated Transport.** Specifies the Noise protocol framework used for the encrypted transport layer. Defines the exact handshake pattern (`Noise_XK`) and the cryptographic primitives (Secp256k1, ChaCha20-Poly1305, SHA256).

**BOLT #9 — Feature Bits.** A registry of feature bits that nodes use to signal supported protocol extensions. Each feature has an odd/even pair: even bits are mandatory (node must support it or disconnect), odd bits are optional.

**BOLT #11 — Invoice Protocol.** Defines the bech32-encoded invoice format used to request payments. Specifies the human-readable prefix, the timestamp, tagged fields (payment hash, description, expiry, routing hints), and the recoverable ECDSA signature.

## advanced

**BOLT #12 — Offers.** The next-generation invoice protocol intended to replace BOLT 11. Offers solve key limitations of static invoices: they support recurring payments without preimage reuse, enable asynchronous receiving, use route blinding for privacy, and allow refunds (the receiver becomes the spender). An offer is a static string that can generate many invoices, removing the need for the receiver to be online.

**BOLT #2 extensions.** The peer protocol has been extended beyond the original channel lifecycle:
- Dual-funding (BOLTs + `dual-fund`): both parties contribute to the channel opening transaction.
- Splicing: modify channel capacity in-flight by splicing in or out funds without closing.
- Wumbo channels: remove the 0.167 BTC soft cap on channel size, allowing larger capacity.

**The BOLT process.** The lifecycle of a BOLT follows a well-defined path:
1. **Proposal** — an idea is formalised as a spec change.
2. **Draft** — the proposal is written as a BOLT markdown document.
3. **Pull Request** — the draft is submitted to `github.com/lightning/bolts`.
4. **Review** — implementers discuss, comment, and request changes.
5. **Acceptance** — consensus is reached and the PR is merged.
6. **Activated** — implementations deploy and support the new spec.
7. **Amendments** — follow-up PRs refine and update the specification.

![BOLT Specification Lifecycle](media/wiki/bolt-specifications/bolt-lifecycle.svg "From proposal to activated: how BOLT specifications move through the standards process.")

**Feature bits negotiation.** When two nodes connect, they exchange `init` messages that include their feature bit vectors. Each bit signals support for a specific extension:
- Even bits: mandatory — if a node does not support an even bit, the peer must disconnect.
- Odd bits: optional — nodes can ignore unsupported odd bits and continue operating.
This negotiation allows the protocol to evolve without breaking compatibility with older nodes.

**Implementation differences.** Although the BOLTs define a single specification, implementations interpret the spec with minor variations:
- **LND** (Go): the most widely deployed, emphasises production stability.
- **Core Lightning** (C): prioritises spec compliance and modular architecture.
- **Eclair** (Scala): reference implementation with strong security auditing.
- **LDK** (Rust): a library rather than a full node, used to embed Lightning in other apps.
Discrepancies between implementations are discussed in the BOLTs repository and resolved through spec amendments.

**Living specification.** The BOLT repository is not a static document set. New BOLTs are added as the protocol evolves, and existing ones receive amendments through the same PR process. The repository tracks the full history — every discussion, every decision, every change — making it the authoritative source for Lightning Network standards.
