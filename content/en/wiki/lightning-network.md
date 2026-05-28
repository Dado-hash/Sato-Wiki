---
id: wiki.lightning-network
slug: lightning-network
language: en
category: lightning network
title: Lightning Network
description: Bitcoin's second-layer scaling solution that enables instant, low-cost payments through a network of bidirectional payment channels.
coverImage: media/wiki/lightning-network/ln-overview-hero.svg
difficulty: advanced
readTimeMinutes: 10
tags:
  - Lightning Network
  - Layer 2
  - Payment Channels
  - Scalability
related:
  - wiki.payment-channels
  - wiki.commitment-transactions
  - wiki.htlcs
  - wiki.onion-routing
  - wiki.lightning-invoices
sources:
  - title: "The Bitcoin Lightning Network: Scalable Off-Chain Instant Payments"
    url: https://lightning.network/lightning-network-paper.pdf
    author: Joseph Poon, Thaddeus Dryja
    publishedAt: 2016-01-14
  - title: "Mastering the Lightning Network"
    url: https://github.com/lnbook/lnbook
    author: Andreas M. Antonopoulos, Olaoluwa Osuntokun, Rene Pickhardt
  - title: "BOLT #1: Base Protocol"
    url: https://github.com/lightning/bolts/blob/master/01-protocol.md
    author: Lightning Network Specifications (BOLTs)
updatedAt: 2026-05-27T00:00:00Z
---

## base

What is the Lightning Network? It is a second-layer protocol built on top of Bitcoin that enables instant payments between participating nodes. Instead of broadcasting every transaction to the blockchain, the Lightning Network uses payment channels — private ledgers between two parties that can be transacted without block confirmation.

**The problem it solves.** Bitcoin's base layer can process roughly 7 transactions per second (limited by the 1 MB block size and 10-minute block interval). For small payments like buying coffee or streaming satoshis, waiting 10-60 minutes and paying fees of several dollars makes on-chain transactions impractical. The Lightning Network addresses this by moving the vast majority of payments off-chain.

**How it helps.** Payments on Lightning are near-instant (milliseconds to seconds), cost fractions of a cent regardless of the amount sent, and can scale to millions of transactions per second across the network. The security model still relies on Bitcoin — funds are secured by the base layer and can be settled on-chain at any time.

**Analogy.** Think of a coffee shop tab. Instead of swiping a credit card for each $5 coffee, you open a tab at the start: the barista notes your name and runs an initial authorization. Each coffee adds to the running total. At the end of the day, you settle the final amount in one payment. The Lightning Network works similarly: open a channel (the tab), make many micro-payments off-chain, and close the channel to settle the final balance on Bitcoin.

![Lightning Network overview](media/wiki/lightning-network/ln-overview-hero.svg "The Lightning Network sits on top of Bitcoin, enabling instant payments between users through payment channels.")

## medium

**Payment channels as the building block.** A payment channel is a financial relationship between two parties, backed by a 2-of-2 multisignature output on Bitcoin. The channel lifecycle has three phases:

**Opening a channel (funding transaction).** Alice creates a funding transaction that locks a certain amount of bitcoin into a 2-of-2 multisig output. She broadcasts this to the Bitcoin network. Once confirmed, the channel exists with an initial balance: Alice owns the total amount, Bob owns zero. Alice can now send funds to Bob by updating the channel state.

**Updating the channel state (commitment transactions).** Alice and Bob each hold a commitment transaction that reflects the current distribution of funds. When Alice wants to send 0.01 BTC to Bob, they negotiate new commitment transactions: Alice's commitment gives Bob 0.01 BTC and gives Alice the remainder. Crucially, each new version invalidates the previous one using a revocation mechanism — if either party tries to broadcast an old state, the counter-party can claim all funds as a penalty.

**Closing a channel.** Either party can close the channel at any time by broadcasting the latest commitment transaction to the Bitcoin network. The closing transaction spends the 2-of-2 multisig output, distributing the final balances to each party. The channel is settled on-chain in a single transaction, regardless of how many payments occurred inside the channel.

**Multi-hop payments.** You do not need a direct channel with every person you want to pay. The Lightning Network routes payments through intermediate nodes using onion routing. Each node in the path knows only its immediate predecessor and successor — no single node knows the full path. This preserves privacy and enables payments between any two nodes on the network.

**HTLCs (Hashed Timelock Contracts).** The atomic unit of a Lightning payment is the HTLC. An HTLC is a conditional payment that can be claimed by the recipient if they reveal the preimage of a given hash within a timelock, or refunded to the sender after the timelock expires. HTLCs chain together across the payment path, ensuring that either all nodes are paid or none are — the payment is atomic.

**Lightning invoices (BOLT 11).** To receive a payment, a node generates an invoice containing a payment hash, the amount, a description, and an expiry time. The invoice is encoded as a bech32 string and can be shared via QR code or any communication channel. The payer uses the invoice to construct an HTLC route to the recipient.

**Routing vs direct channels.** Direct channels give you the best user experience (no routing fees, no relay node dependency) but require locking up capital in advance. Routing lets you pay anyone through the network but incurs small fees per hop and depends on network topology and liquidity.

![On-chain vs Lightning comparison](media/wiki/lightning-network/ln-vs-onchain.svg "On-chain transactions settle on the base layer. Lightning transactions happen off-chain with only the channel open and close recorded on Bitcoin.")

## advanced

**The Poon-Dryja channel construction.** The original Lightning channel construction, introduced in the 2016 white paper by Joseph Poon and Thaddeus Dryja, establishes a pair of asymmetric commitment transactions. Each party holds a commitment transaction that spends the 2-of-2 funding output. The key innovation is the use of revocation keys: when a new state is negotiated, the old state's revocation key is revealed to the counter-party. If a party broadcasts an old state, the counter-party can use the revocation key to claim all funds in the channel. This economic disincentive ensures both parties always broadcast the latest state.

**Penalty mechanism in detail.** Each commitment transaction includes a `to_local` output (for the party who broadcast) and a `to_remote` output (for the other party). The `to_local` output has a CSV timelock (typically 144 blocks) and a revocation path. If the broadcaster cheats, the counter-party can spend the `to_local` output immediately using the revocation key, bypassing the timelock. The penalty is total — the cheater loses their entire channel balance to the counter-party.

**Gossip protocol for network discovery.** Lightning nodes discover each other and the network topology through a gossip protocol defined in BOLT 7. Three message types manage this:

- `node_announcement`: Contains the node's public key, IP address or Tor onion service, supported features, and an RGB color alias. Nodes broadcast this when they come online.
- `channel_announcement`: Created when a new channel is confirmed on-chain. Contains the channel ID, the two nodes' public keys, and the Bitcoin transaction output that funds it.
- `channel_update`: Updated by each node independently. Contains the fee policy (base fee and proportional fee), HTLC minimum and maximum values, timelock delta, and a disability flag. Nodes update this when their routing policy changes.

The gossip protocol uses timestamp-based freshness and prevents spam through proof-of-work on node IDs.

**Fee economics.** Every routing node charges two fees per forwarded payment:

- **Base fee** (`fee_base_msat`): A fixed amount per HTLC, typically 1-1000 millisatoshis (~0.001-1 sat). Covers the cost of forwarding, including the on-chain risk of having a channel force-closed while an HTLC is pending.
- **Proportional fee** (`fee_proportional_millionths`): A fraction of the payment amount, typically 1-1000 ppm (0.0001%-0.1%). This scales with the value at risk.

Total fee = base_fee + (amount × proportional_fee / 1,000,000). For a 100,000 sat payment with 1000 ppm and 10 msat base, the fee = 10 + (100,000 × 1000 / 1,000,000) = 10 + 100 = 110 msat.

**Max HTLC value and timelock constraints.** Each channel has two critical parameters:
- `htlc_maximum_msat`: The largest HTLC the channel can forward. Prevents nodes from routing payments that exceed channel capacity.
- `htlc_minimum_msat`: The smallest HTLC the channel will forward. Prevents dust HTLCs that would cost more in fees than they are worth.

The **timelock delta** (`cltv_expiry_delta`) specifies how many blocks each hop subtracts from the CLTV. A typical value is 40-144 blocks per hop. This protects each intermediate node by ensuring they have time to claim their funds upstream before the downstream HTLC expires.

**Griefing attacks.** A griefing attack occurs when a malicious node forwards an HTLC with a very long timelock but never claims or fails it. The funds along the path are locked up until the timelock expires. Mitigations include:
- Limiting the total value of pending HTLCs per channel (`max_concurrent_htlcs`, typically 30)
- Setting reasonable minimum and maximum HTLC values
- Monitoring pending HTLC duration and closing channels with unresponsive peers
- Using shorter CLTV deltas where possible

Griefing is a denial-of-service risk, not a theft risk — funds are never lost, only temporarily locked.

**Watchtowers.** A watchtower is a third-party service that monitors the Bitcoin blockchain for channel close transactions on behalf of a Lightning node. If the counter-party broadcasts a revoked commitment transaction, the watchtower publishes the penalty transaction to claim the channel funds. Watchtowers operate in a trust-minimized fashion — they learn only the data needed to detect and respond to cheating attempts (the revocation key and the offending transaction), not the channel balance or payment details. This allows mobile nodes (which may be offline for extended periods) to maintain channel security without running a full-time monitoring node.

**Current limitations.**

- **Inbound liquidity.** To receive payments, a node must have inbound capacity — other nodes must have opened channels to it. Bootstrapping inbound liquidity is one of the hardest problems for new nodes. Solutions include: buying inbound liquidity from providers, opening channels from the other side (dual-funding), and balancing channels through circular rebalancing.
- **Routing failures.** Payment success rates are typically 90-98%, depending on network topology and liquidity distribution. Failures occur when a node along the path has insufficient liquidity, is offline, or charges unexpected fees. Most implementations implement automatic retry with pathfinding heuristics.
- **Channel rebalancing.** Over time, payments in one direction can deplete a channel's local balance. Rebalancing moves liquidity back through circular payments or by closing and re-opening channels. The process is manual or semi-automated in current implementations and consumes routing fees.

**Protocol improvements.** Two notable enhancements in the BOLT specification pipeline:

- **Wumbo (large channel) — BOLT 2.** Early Lightning implementations capped channel sizes at ~16.7 million satoshis (0.167 BTC) to limit risk. Wumbo removes this limit, allowing channels with larger capacities for routing high-value payments. Nodes must signal wumbo support and opt in.

- **Dual-funding — BOLT 2.** The original Poon-Dryja construction requires one party to fund the channel entirely. Dual-funding allows both parties to contribute funds to the channel's initial balance, solving half of the inbound liquidity problem at channel creation. It uses a collaborative transaction construction protocol called interactive funding.
