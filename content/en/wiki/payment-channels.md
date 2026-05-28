---
id: wiki.payment-channels
slug: payment-channels
language: en
category: lightning network
title: Payment Channels
description: A bidirectional connection between two Bitcoin wallets that allows them to transact off-chain without broadcasting every payment to the network.
coverImage: media/wiki/payment-channels/payment-channel-lifecycle.svg
difficulty: advanced
readTimeMinutes: 9
tags:
  - Lightning Network
  - Payment Channels
  - Layer 2
  - Off-Chain
related:
  - wiki.lightning-network
  - wiki.channel-funding-transactions
  - wiki.commitment-transactions
  - wiki.htlcs
  - wiki.timelocks
  - wiki.multisig
sources:
  - title: "The Bitcoin Lightning Network: Scalable Off-Chain Instant Payments"
    url: https://lightning.network/lightning-network-paper.pdf
    author: Joseph Poon and Thaddeus Dryja
    publishedAt: 2016-01-14
  - title: "Mastering the Lightning Network — Chapter 5: Payment Channels"
    url: https://github.com/lnbook/lnbook
    author: Andreas M. Antonopoulos, Olaoluwa Osuntokun, Rene Pickhardt
    publishedAt: 2021-11-01
  - title: "BOLT #2 — Peer Protocol for Channel Management"
    url: https://github.com/lightning/bolts/blob/master/02-peer-protocol.md
    author: Lightning Network Specifications
    publishedAt: 2020-01-01
updatedAt: 2026-05-27T00:00:00Z
---

## base

A payment channel is a direct private path between two parties on the Lightning Network. It allows them to exchange payments instantly without recording each individual transaction on the Bitcoin blockchain.

Think of it like a prepaid coffee card. You load money onto the card once, then make many purchases by deducting from the balance. Only two events touch the blockchain: loading the card (opening) and discarding the card with the remaining balance (closing). Everything in between happens off-chain between you and the coffee shop.

Opening a channel requires a single on-chain Bitcoin transaction. Alice creates a funding transaction that locks her bitcoin into a 2-of-2 multisig output — a special address that requires both Alice and Bob to sign before the funds can move. This transaction is broadcast and confirmed on the blockchain.

Once the funding transaction is confirmed, Alice and Bob can exchange as many payments as they want. Each payment updates the balance allocation of the channel. Both parties sign new commitment transactions reflecting the latest balance, and the old state is revoked. No additional on-chain transactions are needed.

The channel can remain open for as long as both parties agree on the balance. When they decide to close, the final commitment transaction is broadcast to the blockchain. Each party receives their agreed-upon balance back as a regular on-chain output.

The key benefits are instant settlement between the two parties, near-zero transaction fees for payments within the channel, and the ability to route payments through multiple channels across the Lightning Network.

![Payment channel lifecycle](media/wiki/payment-channels/payment-channel-lifecycle.svg "A payment channel goes through three stages: open with a funding transaction on-chain, update with off-chain commitment exchanges, and close with the final state broadcast to the blockchain.")

## medium

A payment channel is built on a 2-of-2 multisig Bitcoin Script output. The funding transaction creates a shared UTXO that can only be spent when both parties sign. This multisig constraint is the foundation that makes the channel secure — neither party can unilaterally move the funds without the other's consent.

**Commitment transactions.** Once the channel is funded, each party holds a version of the latest channel state in the form of a signed but unconfirmed commitment transaction. Each commitment transaction spends the 2-of-2 multisig output and allocates the balance according to the current state. Alice holds a commitment transaction that sends her balance to an output she controls and sends Bob's balance to an output he controls — but this transaction is not broadcast. It is held off-chain as a guarantee.

**Asymmetric commitment design (Poon-Dryja).** Alice's commitment transaction looks different from Bob's. In Alice's version, her own output includes a to_self_delay enforced by `OP_CHECKSEQUENCEVERIFY` (CSV) — typically 144 blocks (about 24 hours). Bob's output in Alice's commitment is immediately spendable by Bob. This asymmetry is intentional: it gives Alice time to react if Bob tries to broadcast an old, revoked state.

**Revocation mechanism.** When Alice and Bob agree to update the channel balance, they do not simply sign a new commitment transaction. They also exchange revocation secrets that make the previous commitment transaction unspendable. If Alice later tries to cheat by broadcasting an old commitment that favored her, Bob can use the revocation secret to claim all the channel funds as a penalty.

**Cooperative vs unilateral close.** A cooperative close happens when both parties agree to close the channel. They sign and broadcast a mutually agreed settlement transaction with zero timelocks — both parties receive their funds immediately. A unilateral close happens when one party broadcasts their latest commitment transaction without the other's cooperation. The broadcasting party must wait through the to_self_delay (CSV timelock) before they can access their funds, while the other party can claim their funds immediately.

![Channel balance updates](media/wiki/payment-channels/channel-update.svg "Each payment in a channel creates a new commitment transaction that updates the balance allocation between Alice and Bob. Old commitment transactions are revoked.")

## advanced

**Commitment transaction structure.** Each commitment transaction contains two primary outputs: the to_local output and the to_remote output. The to_local output sends funds back to the party who created the commitment transaction, encumbered by a CSV timelock (the to_self_delay). The to_remote output sends the counterparty's funds to an address they control, spendable immediately.

In addition, commitment transactions may contain HTLC outputs for in-flight payments routed through the channel. Each HTLC output is encumbered by both a CLTV timelock (the expiry) and a hashlock (the payment preimage). The structure ensures that funds are either claimed by the intended recipient with the preimage or returned to the sender after the timelock expires.

**Revocation secret derivation.** The Poon-Dryja construction uses a hierarchical revocation scheme. Each party generates a per-commitment secret using an HD key derivation path. The revocation secret for commitment N can be stored as the secret for commitment N-1 after the state is updated. This allows a sliding window of security: at any point, both parties can revoke the previous state by revealing its revocation secret.

The derivation follows a deterministic hierarchy:
1. The funder generates a base revocation secret from the channel seed
2. Each commitment point is derived using SHA256
3. The revocation secret for state N is revealed when transitioning to state N+1
4. The counterparty stores this secret to construct a penalty transaction if needed

**Penalty transaction flow.** If Alice broadcasts an old commitment transaction (state N instead of the current state N+2), Bob detects this by monitoring the blockchain. Bob has 144 blocks (the to_self_delay window) to respond. He constructs a penalty transaction that spends the to_local output using the revocation secret Alice revealed when they moved from state N to N+1. The penalty transaction sends all channel funds — both Alice's and Bob's balances — to Bob. This is the economic deterrent that makes cheating irrational.

**Dust limits.** HTLC outputs below the dust limit (typically 546 satoshis for standard outputs) are not included in commitment transactions. This prevents economic denial-of-service attacks where a tiny HTLC would cost more in fees to claim than its value. The dust limit is negotiated between peers in the open channel handshake.

**Channel reserve.** Each peer maintains a channel reserve — a minimum balance that cannot be spent. The reserve is typically 1% of the channel capacity. This ensures that every commitment transaction has sufficient value in both the to_local and to_remote outputs to make the penalty mechanism economically viable. If one party's balance falls to the reserve, they cannot send more payments until the channel is replenished.

**Interactive commitment construction.** Building a new commitment transaction follows a precise message flow:
1. `update_add_htlc` / `update_fulfill_htlc` / `update_fail_htlc`: Modify the pending HTLC set
2. `commitment_signed`: The initiator sends their signature for the new commitment transaction, along with the revocation secret for the previous state
3. `revoke_and_ack`: The responder acknowledges by sending their revocation secret for the previous state and their signature for the new commitment
4. Both parties now hold a valid signed commitment transaction for the new state

This sign-revoke-commit cycle ensures that at any moment, both parties have a valid commitment transaction for the current state and the ability to penalize a cheat using the previous state.

**Channel establishment message flow (BOLT 2).** Opening a channel follows a structured protocol:
1. `open_channel`: The funder sends channel parameters including capacity, dust limit, to_self_delay, and the funding pubkey
2. `accept_channel`: The responder acknowledges with their parameters
3. `funding_created`: The funder provides the funding transaction details and their signature for the first commitment transaction
4. `funding_signed`: The responder provides their signature for the funding transaction and their signature for the first commitment transaction
5. Both parties broadcast the funding transaction and wait for confirmations
6. `funding_locked`: Once the funding transaction reaches the required depth (typically 3 confirmations), both parties exchange `funding_locked` to signal that the channel is ready for payments

After `funding_locked`, the channel transitions to the ready state and can begin routing payments.
