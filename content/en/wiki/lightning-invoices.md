---
id: wiki.lightning-invoices
slug: lightning-invoices
language: en
category: lightning network
title: Lightning Invoices
description: Standardized payment requests in the Lightning Network encoded as bech32 strings, containing the payment hash, amount, description, and cryptographic proof.
coverImage: media/wiki/lightning-invoices/invoice-creation.svg
difficulty: advanced
readTimeMinutes: 8
tags:
  - Lightning Network
  - Invoices
  - BOLT 11
  - Payments
  - Bech32
related:
  - wiki.lightning-network
  - wiki.htlcs
  - wiki.onion-routing
  - wiki.multipath-payments
  - wiki.routing-fees
sources:
  - title: "BOLT #11 — Invoice Protocol for Lightning Payments"
    url: https://github.com/lightning/bolts/blob/master/11-payment-encoding.md
    author: Lightning Network Specifications
    publishedAt: 2017-05-01
  - title: "Mastering the Lightning Network — Chapter 10: Invoices"
    url: https://github.com/lnbook/lnbook
    author: Andreas M. Antonopoulos, Olaoluwa Osuntokun, Rene Pickhardt
updatedAt: 2026-05-27T00:00:00Z
---

## base

A Lightning invoice is a payment request that tells the payer what to pay and where to send it. Like an invoice from a plumber — it describes the service, the amount due, and where to send payment.

An invoice contains a payment hash (the SHA256 hash of a secret preimage chosen by the receiver), the amount requested, a merchant description, and an expiry time. It is encoded as a bech32 string starting with `lnbc` for mainnet. The invoice can be shared as text, a QR code, or via NFC.

When the payer receives the invoice, their wallet decodes it, finds the payment hash, constructs a route through the Lightning Network to the receiver, and sends HTLCs (Hash Time Locked Contracts) along that route. The receiver claims the payment by revealing the preimage, which the payer can verify matches the payment hash.

![Lightning Invoice Lifecycle](media/wiki/lightning-invoices/invoice-creation.svg "The receiver creates an invoice with a payment hash; the payer decodes it and routes a payment back through the network.")

## medium

**BOLT 11 format.** A Lightning invoice has three parts: a human-readable prefix, a data part, and a signature. The human-readable prefix begins with `ln` (Lightning), followed by `bc` (mainnet Bitcoin) and the amount. For example, `lnbc10u` means 10 microBTC (10,000 satoshis). Amounts use SI suffixes: `p` (pico), `n` (nano), `u` (micro), `m` (milli).

**Tagged fields.** The data part encodes fields as type-length-value tuples. Each field starts with a single character type tag followed by a 2-character data length and the field value:

- `p` — Payment hash (256-bit SHA256 of the preimage)
- `d` — Description, a short plaintext string
- `h` — Description hash, SHA256 of a long description
- `x` — Expiry time in seconds (default 3600)
- `n` — Payer ID (the node ID of the creator)
- `r` — Routing hints for private channels
- `9` — Feature bits for protocol extensions

**Signature.** The last 520 bits (65 bytes) are a recoverable ECDSA signature. It covers the entire data part and lets anyone verify the invoice was created by the holder of the node's private key. The recovery id allows extracting the public key from the signature alone.

**How the payment hash connects to HTLCs.** The payer uses the payment hash from the invoice as the hash lock in every HTLC along the route. Only the receiver knows the preimage, so only they can claim the payment by revealing it. Once the preimage propagates back, every intermediate hop is reimbursed and the payer has cryptographic proof that the receiver got the funds.

**Expiry and CLTV.** The `x` field sets the invoice expiry (default 1 hour). The `min_final_cltv_expiry` tells the payer the minimum timelock delta to set on the final HTLC, protecting the receiver from funds being stuck if the payment route is slow.

![BOLT 11 Invoice Structure](media/wiki/lightning-invoices/invoice-anatomy.svg "A bech32-encoded string segmented into HRP, amount, timestamp, tagged fields, and signature.")

## advanced

**Bech32 encoding details.** BOLT 11 uses the same bech32 encoding as SegWit addresses (BIP 173). Data is split into 5-bit words, making it efficient for QR codes and human transcription. Bech32 includes a BCH checksum (6 characters) that detects up to 4 errors and corrects 1 error. The encoding uses a limited character set (32 characters: alphanumeric excluding `1`, `b`, `i`, `o`) to minimize ambiguity.

**Data part structure.** The data part begins with a 35-bit timestamp (Unix epoch seconds). After the timestamp, one or more tagged fields follow, each with a 1-character type, 2-character length, and variable-length value. The signature occupies the final 520 bits: 256-bit `r`, 256-bit `s`, and an 8-bit recovery id.

**Description hash vs plaintext.** When the description is short (under 639 bytes), wallets typically use the `d` field with the literal text. For longer descriptions, the `h` field stores SHA256(description) and the description must be communicated out of band. The payer's wallet hashes the provided description and checks it against the invoice's `h` field to ensure it matches what the receiver intended.

**Routing hints (`r` field).** If the receiver is behind one or more private (non-announced) channels, they include routing hints. Each hint is a channel hop containing: `short_channel_id`, `node_id`, `fee_base_msat`, `fee_proportional_millionths`, `cltv_expiry_delta`. The payer incorporates these into route finding. Multiple hints for different paths increase the payer's chance of reaching the receiver.

**Feature bits (`9` field).** Feature bits advertise protocol capabilities:
- Bit 8/9 — MPP (Multi-Path Payments): split a payment across multiple routes
- Bit 9/9 — Keysend: spontaneous payments without an invoice
- Bit 15 — Trampoline: delegated routing through trampoline nodes
- Bit 17/19 — BOLT 12 Offers

Future feature assignments are tracked in the BOLTs repository.

**BOLT 12 Offers.** The Offers protocol is the next-generation replacement for BOLT 11. Unlike invoices, offers are not single-use: one offer can generate many invoices, enabling recurring payments and async receipt. Offers use blinded paths (route blinding) instead of routing hints, improving privacy. The preimage is derived deterministically from a static secret, avoiding preimage reuse concerns. Offers also support refunds (the receiver becomes the spender) and is better suited for automation.

**Keysend / Spontaneous Payments.** Keysend bypasses the invoice workflow entirely. The sender generates a payment hash from a preimage they choose, sends the payment, and includes the preimage in the onion payload using the `key_send` TLV record. The receiver extracts the preimage, claims the payment, and learns the preimage from the onion. Because the payer chooses the preimage, Keysend does not provide proof of payment — only the payer, not the receiver, can prove the payment occurred.
