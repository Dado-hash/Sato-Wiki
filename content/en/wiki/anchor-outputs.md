---
id: wiki.anchor-outputs
slug: anchor-outputs
language: en
category: lightning network
title: Anchor Outputs
description: Small 1-satoshi outputs in Lightning commitment transactions that enable any channel party to fee-bump the transaction using Child-Pays-For-Parent (CPFP), ensuring timely confirmation even during fee spikes.
coverImage: media/wiki/anchor-outputs/anchor-output-structure.svg
difficulty: advanced
readTimeMinutes: 8
tags:
  - Lightning Network
  - Anchor Outputs
  - CPFP
  - Fee Management
  - Commitment Transactions
related:
  - wiki.commitment-transactions
  - wiki.payment-channels
  - wiki.channel-funding-transactions
  - wiki.lightning-network
  - wiki.transaction-fees
sources:
  - title: "BOLT #3 — Bitcoin Transaction and Script Formats (Anchor Outputs)"
    url: https://github.com/lightning/bolts/blob/master/03-transactions.md
    author: Lightning Network Specifications
  - title: "Anchor Outputs Specification"
    url: https://github.com/lightning/bolts/pull/688
    author: Lightning Network Contributors
  - title: "CPFP Fee Bumping — Bitcoin Developer Guide"
    url: https://developer.bitcoin.org/techguide/transactions.html#fee-bumping
    author: Bitcoin.org
updatedAt: 2026-05-27T00:00:00Z
---

## base

Anchor outputs are tiny 1-satoshi outputs added to commitment transactions. Their sole purpose is to allow either party to increase the transaction fee after the commitment has already been signed.

The problem anchor outputs solve: commitment transactions are pre-signed with a fixed fee. If the Bitcoin fee market spikes between the time the commitment was signed and the time it needs to be broadcast, the pre-signed fee may be too low to confirm. Since the commitment is fully signed, neither party can modify its fee.

The solution: anyone can spend an anchor output with a high-fee child transaction. This technique is called Child-Pays-For-Parent (CPFP). The anchor acts like an emergency handle — either party can pull it to speed up confirmation by creating a child transaction that pays a higher fee rate.

![Anchor output structure](media/wiki/anchor-outputs/anchor-output-structure.svg "A commitment transaction with two anchor outputs (1 sat each) that enable CPFP fee bumping.")

## medium

Commitment transactions are the most critical transactions in the Lightning Network — they represent the latest channel state and must confirm quickly when broadcast. However, they are negotiated and signed in advance, which means their fee is locked in at signing time. If the prevailing fee rate rises significantly before broadcast, the transaction may languish in the mempool indefinitely.

Before anchor outputs, only the party creating the commitment transaction could fee-bump it, using Replace-by-Fee (RBF). This was asymmetrical: one party had fee control, the other did not. Anchor outputs fix this by giving both parties the ability to CPFP the commitment transaction.

A CPFP child transaction spends one of the anchor outputs. Miners evaluating the child see its high fee rate and calculate the combined fee rate of the parent-child package. If the combined rate is competitive, they include both transactions. This works because the anchor output is typically secured by a simple anyone-can-spend script (`OP_TRUE`) in v1 anchors, or by a key-spendable path in v2 anchors.

The anchor output is minted at 1 satoshi — the smallest possible amount that is still economically sensible as a non-dust output. Spending it requires adding at least as much in fees, which is the entire point: the anchor's value forces the fee-bumping transaction to include sufficient fees.

![CPFP fee bumping with anchors](media/wiki/anchor-outputs/anchor-cpfp.svg "A stuck low-fee commitment transaction gets CPFP-bumped via a child transaction spending the anchor output.")

## advanced

### Two Versions of Anchor Outputs

Anchor outputs exist in two flavors, reflecting an evolution in Lightning's security model:

**v1 (OP_TRUE anchors):** The original anchor output script was simply `OP_TRUE`, meaning anyone could spend it — not just the two channel parties. This was the first proposal and was implemented in early versions of c-lightning and Eclair. The spending condition was trivial, making CPFP straightforward for either party.

**v2 (key-spendable anchors):** The v2 specification (defined in BOLT #3) replaced `OP_TRUE` with a key-spendable script that requires a signature from either party. This was a direct response to **pinning attacks**.

### Pinning Attacks

With v1 anchors, a malicious third party could monitor the mempool for commitment transactions, grab the `OP_TRUE` anchor output, and spend it with a low-fee transaction of their own. This low-fee child transaction would "pin" the anchor, preventing the legitimate channel party from CPFP-bumping effectively. The attacker's transaction would need to be included first, or the legitimate party would have to outbid it — a race condition that undermines the reliability of anchor outputs.

v2 anchors solve pinning by requiring a valid signature from one of the two channel parties. A third party cannot create a spending transaction because they don't have either signature key. This ensures that only the two legitimate channel participants can create CPFP child transactions.

### Interaction With Commitment Transaction Fee Calculation

The anchor outputs add two extra outputs to the commitment transaction. Each anchor is 1 satoshi, so the total output value increases by 2 satoshis. The commitment transaction's fee calculation must account for these outputs — they are not part of the balance distribution between the parties. The anchor outputs are created from the transaction's fee budget or from dust that would otherwise be considered uneconomical.

### Timing Considerations: to_self_delay and CPFP

CPFP has a timing constraint when the anchor output is spent by the party whose balance is in the `to_local` output (which carries a CSV timelock). If Alice broadcasts a commitment transaction and wants to CPFP via her anchor, she must do so before the timelock expires or risk a race condition. In practice, CPFP works best when the anchor spender is the party receiving the `to_remote` output, since that output has no timelock and can be confirmed immediately alongside the child transaction.

### Anchor Outputs in Splicing and Dual-Funding

Anchor outputs are particularly valuable in more advanced channel constructions:

- **Splicing:** When a channel is being spliced (in-flight funds added or removed), the old commitment transaction may need to be confirmed on-chain. Anchors ensure either party can fee-bump the old commitment if it gets stuck.
- **Dual-funding:** With both parties contributing to the channel's initial funding, the asymmetric fee control problem is even more pronounced. Anchors give both contributors an equal ability to ensure the funding transaction confirms.

### Implementation Status

| Implementation | v1 Anchor Support | v2 Anchor Support |
|---|---|---|
| **LND** | Experimental | Default (since v0.15) |
| **Core Lightning (CLN)** | Legacy | Default (since v23.05) |
| **Eclair** | Legacy | Default |
| **LDK** | N/A | Supported |

The network has been migrating toward v2 anchors as the standard. Most modern Lightning channels use the v2 anchor output format, and older channels using v1 anchors are gradually being closed and reopened in the v2 format.

### Summary

Anchor outputs are a deceptively simple mechanism that solves a fundamental problem in Lightning Network protocol design: how do you let two mutually-distrusting parties pre-sign a transaction while retaining the ability to respond to changing on-chain conditions? By adding a tiny, spendable output, both parties gain the flexibility to CPFP the commitment transaction without needing to coordinate or re-sign. This small change significantly improves the reliability and security of channel operations.
