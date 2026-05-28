---
id: wiki.splicing
slug: splicing
language: en
category: lightning network
title: Splicing
description: A protocol extension that allows adding or removing funds from an open Lightning channel without closing and reopening it, using a single on-chain transaction.
coverImage: media/wiki/splicing/splicing-flow.svg
difficulty: advanced
readTimeMinutes: 8
tags:
  - Lightning Network
  - Splicing
  - Channel Management
  - BOLT 2
related:
  - wiki.lightning-network
  - wiki.payment-channels
  - wiki.channel-funding-transactions
  - wiki.commitment-transactions
  - wiki.channel-liquidity
sources:
  - title: "BOLT #2 — Peer Protocol for Channel Management (Splicing section)"
    url: https://github.com/lightning/bolts/blob/master/02-peer-protocol.md
    author: Lightning Network Specifications
  - title: "Splicing Proposal — Lightning Network"
    url: https://github.com/lightning/bolts/pull/863
    author: Lightning Network Contributors
  - title: "Mastering the Lightning Network — Splicing"
    url: https://github.com/lnbook/lnbook
    author: Andreas M. Antonopoulos, Olaoluwa Osuntokun, Rene Pickhardt
updatedAt: 2026-05-27T00:00:00Z
---

## base

Splicing allows modifying a channel's capacity without closing it.

A Lightning channel is normally created with a fixed capacity. If Alice opens a channel to Bob with 1.0 BTC, that capacity is locked for the life of the channel. To change it, the traditional approach requires closing the channel (one on-chain transaction), waiting for confirmations, then opening a new channel (a second on-chain transaction). The channel is unavailable during this entire process.

Splicing eliminates this overhead. With splicing, Alice can add more bitcoin to the channel (splice-in) or remove bitcoin from it (splice-out) using a single on-chain transaction. The channel stays open and operational during the entire process — payments continue to flow while the splice transaction confirms on-chain.

**Splice-in.** Alice adds funds to increase the channel capacity. The splice transaction creates a new funding output that replaces the old one. If the channel was 1.0 BTC, a splice-in of 0.5 BTC makes it 1.5 BTC. The existing balance distribution between Alice and Bob is preserved, and the channel remains open.

**Splice-out.** Alice removes funds from the channel, reducing its capacity. A splice-out of 0.3 BTC from a 1.0 BTC channel results in a 0.7 BTC capacity. The removed funds go to an on-chain address controlled by Alice.

![Channel Splicing Flow](media/wiki/splicing/splicing-flow.svg "Splicing allows adding (splice-in) or removing (splice-out) funds from an open channel without closing it. Without splicing, resizing requires two on-chain transactions.")

## medium

**How splicing works.** Splicing is built on a simple insight: a channel's funding transaction can be replaced by a new funding transaction that both parties agree on. The new transaction spends the old 2-of-2 multisig output and creates a new one with an adjusted amount. The channel's state — including all pending HTLCs and the current balance distribution — is carried over to the new funding output.

**Protocol flow.** When Alice initiates a splice, both parties construct a new funding transaction with the adjusted amounts. Alice signs her part of the new funding transaction, and Bob signs his. Once both signatures are exchanged, the new funding transaction can be broadcast. While it confirms, the old channel remains fully operational — payments can still be routed through it. This is a key safety property: there is no interruption of service.

**Atomicity.** If the splice transaction fails to confirm (for example, because fees were too low and it gets dropped from the mempool), the old channel continues unchanged. The splice is atomic — either the new funding transaction confirms and the channel capacity is updated, or nothing changes. Both parties can safely retry with adjusted fee rates.

**Fee management.** The party that initiates the splice typically pays the on-chain transaction fee. The fee is deducted from the channel funds or paid from an external wallet, depending on the implementation. Both parties must agree on the fee rate before signing the splice transaction, since a splice that gets stuck due to low fees would delay the capacity update.

**Use cases.**
- Topping up a routing channel: a node operator adds more capacity to a busy channel to increase routing revenue
- Withdrawing profits: a node operator removes routing earnings without closing the channel and disrupting active payment paths
- Rebalancing: adjusting capacity between multiple channels to match changing payment patterns

![Splicing vs Traditional Channel Resize](media/wiki/splicing/splicing-vs-closed.svg "Splicing requires one on-chain transaction and no channel downtime, compared to the traditional approach which requires closing, waiting, reopening, and waiting again.")

## advanced

**The interactive splicing protocol.** The splicing protocol is defined in BOLT #2 and uses a dedicated set of messages exchanged between channel peers:

1. `splice_init`: The initiator proposes a splice with the desired amount change, the new funding transaction details, and the fee rate. This message includes a partial signature for the new funding transaction.
2. `splice_ack`: The responder acknowledges the splice proposal, accepts the fee rate, and provides their signature for the new funding transaction.
3. `splice_locked`: Once the new funding transaction reaches the required confirmation depth (typically 3 blocks), both parties exchange `splice_locked` to signal that the channel can resume normal operations under the new capacity.

During this exchange, the channel remains in a special state where both the old and new funding transactions are valid. The protocol ensures that at any point, both parties have a backup commitment transaction they can fall back to.

**Commitment transaction interaction during a splice.** When a splice is in progress, the channel's commitment number system is affected. Each splice operation increments the commitment number, and the new series of commitment transactions references the new funding output. Any pending HTLCs at the time of the splice must be carried over to the new commitment transactions. This requires both parties to agree on the set of unresolved HTLCs before the splice can proceed.

The protocol handles this by requiring all in-flight HTLCs to be resolved or incorporated into the new commitment transactions. If there are unresolved HTLCs that cannot be carried over, the splice must wait until they resolve. This ensures that no funds are lost during the transition between funding outputs.

**Splicing and dual-funding.** Splicing can be combined with dual-funding, where both parties contribute funds to the channel. In a dual-funding splice, both Alice and Bob can add or remove funds in the same splice transaction. This is particularly useful for channel rebalancing between peers — instead of sending payments back and forth to shift the balance, both parties can adjust their contributions in a single atomic operation.

In a dual-funding scenario, the splice protocol is extended to allow both parties to specify their contributions. The funding transaction includes inputs from both sides, and the output amounts reflect the new desired balance. This requires more complex negotiation but reduces the number of transactions compared to separate splice operations.

**Relationship with commitment numbers.** Each splice operation resets the channel's commitment number. The commitment number is a monotonically increasing counter that tracks the channel state. After a splice, the commitment number continues from where it left off, ensuring that the revocation mechanism still works correctly. The old commitment transactions (pre-splice) are revoked using the standard Poon-Dryja revocation scheme.

**Security considerations.** The splice transaction must be signed by both parties, just like the original funding transaction. This means neither party can unilaterally force a splice — it is always a cooperative operation. If a peer becomes unresponsive during the splice protocol, the initiating party can safely abort and continue using the old channel.

However, splicing introduces a new attack surface: a malicious peer could propose a splice with unfavorable terms (for example, assigning themselves more of the channel balance). The protocol mitigates this by requiring both parties to validate and agree on the exact outputs of the new funding transaction before signing. Each party verifies that their balance is correctly represented and that the fee is reasonable.

**Splicing vs submarine swaps.** Both splicing and submarine swaps change the on-chain balance of a Lightning node, but they work differently:

- **Splicing** is peer-to-peer: only the two channel participants are involved. The funds stay within the existing channel relationship.
- **Submarine swaps** involve a third-party service provider that acts as an intermediary between the Lightning Network and the Bitcoin blockchain. A submarine swap converts on-chain bitcoin to Lightning funds (or vice versa) through a HTLC-based escrow mechanism.

Splicing is more private (only the channel peers know about the operation) and has no counterparty risk beyond the channel peer. Submarine swaps introduce trust in the swap provider (unless using a trustless protocol).

**LSP integration.** Lightning Service Providers increasingly offer splicing as a premium feature. An LSP can automatically splice-in when a user's channel runs low on outbound liquidity, or splice-out routing fees to the user's on-chain wallet. This provides a seamless experience where the user never needs to manually manage channel capacity. LSPs typically charge a small fee for the on-chain transaction cost plus a service markup.
