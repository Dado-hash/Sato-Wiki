---
id: wiki.watchtowers
slug: watchtowers
language: en
category: lightning network
title: Watchtowers
description: Third-party services that monitor the Bitcoin blockchain for revoked channel state broadcasts, enabling Lightning nodes to stay secure while offline.
coverImage: media/wiki/watchtowers/watchtower-flow.svg
difficulty: advanced
readTimeMinutes: 8
tags:
  - Lightning Network
  - Watchtowers
  - Security
  - Penalty Mechanism
  - Offline Protection
related:
  - wiki.lightning-network
  - wiki.commitment-transactions
  - wiki.payment-channels
  - wiki.lightning-service-providers
sources:
  - title: "BOLT #2 — Peer Protocol for Channel Management"
    url: https://github.com/lightning/bolts/blob/master/02-peer-protocol.md
    author: Lightning Network Specifications
  - title: "Watchtower Overview — Lightning Labs"
    url: https://docs.lightning.engineering/lightning-network-tools/lnd/watchtower
    author: Lightning Labs
  - title: "Theoretical and Practical Approaches to Watchtowers"
    url: https://github.com/lightningnetwork/lnd/blob/master/docs/watchtower.md
    author: Conner Fromknecht
updatedAt: 2026-05-27T00:00:00Z
---

## base

A **watchtower** is a third-party service that watches the Bitcoin blockchain on your behalf while your Lightning node is offline. Think of it as a security guard monitoring your house while you are on vacation — if someone tries to break in, the guard alerts the authorities.

**The problem.** Lightning channels rely on the latest commitment transaction to determine who owns what. If your phone is turned off and your channel peer broadcasts an old, revoked commitment transaction that favors them, they could steal your funds. Without a watchtower, you must stay online at all times to catch cheating attempts.

**How it helps.** Before going offline, your node shares encrypted "justice transactions" with the watchtower. The watchtower scans every new Bitcoin block. If it detects a revoked commitment transaction on-chain, it broadcasts the justice transaction — a penalty transaction that sends all channel funds to you, the honest party. You remain secure even when your device is turned off.

![Watchtower in Action](media/wiki/watchtowers/watchtower-flow.svg "A watchtower monitors the blockchain on behalf of an offline node and publishes a penalty transaction if the channel peer cheats.")

## medium

**How watchtowers work.** Before a Lightning node goes offline, it creates and uploads one or more encrypted justice transactions (also called "blobs") to the watchtower. Each blob contains the minimum data needed for the watchtower to act:

- The **txid of the revoked commitment transaction** (or a prefix used as an index hint)
- The **penalty spending path** — a signature that lets anyone spend the revoked output to the honest node's wallet
- A **blinding key** to decrypt the blob

The watchtower stores these blobs indexed by the txid hint. For every new block, the watchtower checks whether any of the transactions in the block match a stored hint. On a match, it fetches the corresponding blob, decrypts it using the blinding key, and broadcasts the penalty transaction.

**Privacy model.** The blob is encrypted so the watchtower cannot read its contents. The watchtower learns:

- The txid prefix (just enough to match on-chain transactions)
- That a payment channel exists (since it receives blobs)
- The block height at which to activate each hint

The watchtower does **not** learn:

- Channel balances or payment amounts
- Counterparty identities
- Channel capacity or node aliases
- The full commitment transaction details

This ensures that even a malicious watchtower cannot steal funds or spy on your channel activity. The encrypted design makes watchtowers trust-minimized — they are watchmen who cannot open the vault.

![Trust-Minimized Watchtower Design](media/wiki/watchtowers/watchtower-privacy.svg "Blob encryption ensures the watchtower learns nothing about channel state or balance.")

**Limitations.** Watchtowers only protect against one specific attack: a channel peer broadcasting a revoked commitment transaction. They do not protect against:

- **Griefing attacks** where a peer force-closes the channel honestly but at an inconvenient time
- **Fee-related attacks** where a peer broadcasts a commitment transaction with insufficient fees, causing it to get stuck in the mempool
- **Routing node downtime** in multi-hop payments
- **Data loss** — if you lose your channel state entirely, a watchtower cannot recover your funds

## advanced

**The watchtower protocol.** Watchtower communication is defined in the BOLT specifications (extensions to BOLT #2). The protocol defines two roles:

- **Client (tower client):** The Lightning node that needs monitoring. Typically a mobile or low-availability device.
- **Tower (watchtower):** The always-on service that monitors the blockchain.

The protocol uses a gRPC-style interface over Noise pipes (encrypted transport). Key protocol messages include:

- `SessionInit`: The client registers with a tower, negotiating parameters like blob size, reward scheme, and policy
- `StateUpdate`: The client uploads new encrypted blobs as channel state advances
- `DeleteSession`: The client removes a session when a channel is closed
- `TowerInfo`: Status requests and session summaries

**Encrypted blob format.** The blob encryption scheme is critical for privacy. The client derives a key from the channel state using a keyed hash function. The blob payload contains:

1. The **encrypted penalty transaction** (the justice transaction that spends the revoked output)
2. The **txid hint** — a truncated hash of the revoked commitment txid used for indexing
3. A **block height hint** — the earliest height at which the watchtower should start scanning

The encryption ensures that only the client (who knows the derivation path) can decrypt the blob. The watchtower performs a simple lookup: given a txid from a new block, compute the hint prefix and check for matches in its database.

**Session management.** A client manages sessions with one or more towers:

1. **Registration:** The client chooses a tower (by public key and address) and initiates a session. The tower may require authentication or payment upfront.
2. **Blob batch upload:** The client can upload multiple blobs in a single batch, each corresponding to a different revoked state. The client filters states and only uploads relevant ones — typically the most recent few states, not the entire history.
3. **Heartbeat:** The client sends periodic keep-alive messages to confirm the tower is operational.
4. **Session teardown:** When a channel closes cooperatively, the client tells the tower to delete the corresponding blobs.

**Client-side filtering.** The client must be selective about which states to upload. Uploading every past state would waste tower storage and bandwidth. The client typically uploads only:

- The **latest n states** (e.g., the 3 most recent commitment transactions)
- States that are **near expiration** (close to the CSV timelock)
- States where the **balance distribution changed significantly**

The exact filter strategy depends on the client's risk tolerance. A conservative client uploads many states; an aggressive one uploads few, accepting a smaller window of vulnerability.

**Reward mechanism.** Some watchtowers charge fees for their service. Two common models:

- **Fixed fee:** The client pays a recurring subscription (e.g., monthly satoshis) regardless of whether a penalty is ever triggered
- **Success fee:** The tower takes a percentage of recovered funds when a penalty transaction is successfully broadcast

The success fee model aligns incentives — the tower only earns when it successfully protects the client. However, it introduces complexity: the penalty transaction must include an output for the tower, which the client must pre-sign.

**LND watchtower implementation.** LND (Lightning Network Daemon) was the first major implementation to ship a production watchtower. Key design decisions:

- LND's watchtower uses a **single-channel session** model — each channel gets its own session with independent blob storage
- Blobs are encrypted using **AEAD** (Authenticated Encryption with Associated Data) with a key derived from the channel's `shachain` element
- The tower stores blobs in a **bolt-backed database** using the local disk
- Clients can register with multiple towers simultaneously for redundancy
- LND supports both "tower" mode (running a watchtower server) and "client" mode (connecting to remote towers)

**BOLT 2 integrated approach.** The BOLT specification takes a more integrated approach than LND's implementation:

- Sessions are established through the existing peer-to-peer encrypted transport (Noise), not separate connections
- The protocol is designed to be implementation-agnostic — any Lightning implementation (c-lightning, Eclair, LDK) can implement watchtower support
- Blob formats are standardized across implementations, enabling interoperability
- The specification includes provisions for **tower-to-tower** redundancy and failover

**Watchtower network topology.** In practice, watchtowers are operated by:

- **LSPs (Lightning Service Providers):** Offering watchtower monitoring as part of a package with channel management
- **Exchanges:** Running towers as a value-add for their hosted Lightning wallets
- **Community volunteers:** Running towers for free as a public good
- **Commercial services:** Specialized watchtower-as-a-service providers

A typical topology involves a mobile client registered with 2–3 towers for redundancy. The towers are geographically distributed and independently operated, so no single tower is a point of failure or trust.

**Current limitations.** Despite their effectiveness, watchtowers have practical limitations:

- **Storage cost:** Each channel state requires a blob. For high-volume nodes with many channels, blob storage can reach gigabytes
- **Scanning latency:** Towers must scan every block. During high-throughput periods, a tower might fall behind
- **Front-running risk:** A sophisticated attacker could try to front-run the tower's penalty transaction, though the penalty output structure makes this difficult
- **No protection against force-close fees:** Watchtowers cannot adjust fee levels on the penalty transaction — if fees spike, the penalty might not confirm in time
- **Trust assumptions:** While trust-minimized, the watchtower still learns the existence of your channel and its approximate opening time
