---
id: wiki.commitment-transactions
slug: commitment-transactions
language: en
category: lightning network
title: Commitment Transactions
description: The asymmetric off-chain transactions that represent the latest channel balance, designed with a penalty mechanism to deter dishonest channel closes.
coverImage: media/wiki/commitment-transactions/commitment-tx-structure.svg
difficulty: advanced
readTimeMinutes: 10
tags:
  - Lightning Network
  - Commitment Transactions
  - Penalty Mechanism
  - Off-Chain
related:
  - wiki.payment-channels
  - wiki.channel-funding-transactions
  - wiki.htlcs
  - wiki.timelocks
  - wiki.bitcoin-script
  - wiki.lightning-network
sources:
  - title: "Poon-Dryja LN paper"
    url: https://lightning.network/lightning-network-paper.pdf
    author: Joseph Poon, Thaddeus Dryja
    publishedAt: 2016-01-14
  - title: "BOLT #3 — Bitcoin Transaction and Script Formats"
    url: https://github.com/lightning/bolts/blob/master/03-transactions.md
    author: Lightning Network Specifications
    publishedAt: 2016-07-11
  - title: "Mastering the Lightning Network"
    url: https://github.com/lnbook/lnbook
    author: Andreas M. Antonopoulos, Olaoluwa Osuntokun, Rene Pickhardt
    publishedAt: 2021-12-01
updatedAt: 2026-05-27T00:00:00Z
---

## base

Commitment transactions are the heart of the Lightning Network protocol. Every time two parties make or forward a payment in a channel, they create a new commitment transaction that reflects the updated balance. This transaction is never broadcast to the Bitcoin blockchain under normal operation — it exists only as a signed, off-chain agreement between the two channel participants.

Each commitment transaction spends the 2-of-2 multisig funding output of the channel's funding transaction. It pays each party their current balance according to the latest channel state. If either party disappears or attempts to cheat, the other can broadcast the latest commitment transaction to recover their funds on-chain.

The key security property: only the most recent commitment transaction is valid. Older states, if broadcast, trigger a penalty that gives all channel funds to the honest party.

![Commitment transaction structure](media/wiki/commitment-transactions/commitment-tx-structure.svg "Commitment transaction for the channel funder showing the funding UTXO input, the commitment outputs to local and remote, and HTLC outputs.")

## medium

The commitment transaction design is deliberately asymmetric. In Alice's version of the commitment transaction, Alice's own output (called to_local) carries a relative timelock via OP_CHECKSEQUENCEVERIFY, typically 144 blocks (about 24 hours). Bob's output (called to_remote) has no timelock and is immediately spendable by Bob. In Bob's commitment transaction, the roles are reversed: Bob's output has the timelock and Alice's is immediate.

This asymmetry is what makes the penalty mechanism work. When a new channel state is negotiated, both parties exchange revocation secrets for the old state. If either party tries to broadcast an old commitment transaction, the other party can:

1. Spend their own to_remote output immediately (it has no timelock)
2. Use the revocation key to spend the cheating party's to_local output, bypassing the CSV timelock entirely

The revoked output script contains both the honest party's revocation pubkey and the delayed spending path. Since the revocation secret for the old state is now known, the honest party can construct a signature using the revocation key and claim the cheating party's funds as a penalty.

![Penalty mechanism](media/wiki/commitment-transactions/penalty-mechanism.svg "If Alice broadcasts an old state, Bob can claim all channel funds using the revocation key, bypassing the CSV timelock.")

## advanced

### Per-commitment secret derivation

Each commitment state is tied to a unique per-commitment secret. BOLT #3 specifies the use of a shachain or an indexed hash chain to derive these secrets efficiently. The funding node generates a base secret and derives a sequence of secrets using a one-way hash function:

```
secret_n = SHA256(secret_{n+1})
```

Given secret_n, anyone can derive all previous secrets in the chain, but cannot derive any future secrets. This allows efficient storage: nodes only need to store the most recent secret and can regenerate older ones when needed.

### Revocation process

After both parties sign a new commitment transaction (state N), they immediately exchange the revocation secrets for the previous state (state N-1). This means after state N is agreed upon, both parties hold the ability to penalize state N-1. The protocol ensures that no valid state older than the most recent one can be safely broadcast.

### Transaction structure details

The commitment transaction uses specific field values to enable the penalty mechanism:

**nLocktime.** Set to 0 for normal operation. The relative timelock is enforced through the sequence number on the funding input and the CSV in the output script.

**Sequence.** The funding input has its sequence number set to the CSV delay value (e.g., 144). This, combined with the OP_CSV in the to_local script, prevents the delayed output from being spent until the required number of blocks have passed.

**to_local output script:**
```
OP_IF
    <remote_revocation_pubkey>
OP_ELSE
    <csv_delay> OP_CHECKSEQUENCEVERIFY OP_DROP
    <local_delayed_pubkey>
OP_ENDIF
OP_CHECKSIG
```

If the remote party knows the revocation private key (from the old state's revocation secret), they can spend using the first branch immediately. Otherwise, the local party must wait through the CSV delay to spend via the second branch.

**to_remote output script:**
```
<remote_pubkey> OP_CHECKSIG
```

Simple pay-to-pubkey. The remote party can spend this immediately.

### HTLC outputs in commitment transactions

Each pending HTLC generates two outputs in the commitment transaction:

- **Offered HTLC:** The HTLC offered by the local node to the remote node. The remote claims it by providing the preimage within the CLTV timeout.
- **Received HTLC:** The HTLC offered by the remote node to the local node. The local claims it by providing the preimage, or the remote reclaims it after timeout.

Each HTLC output uses a script with two spending paths (like the to_local script): one path requiring the preimage and the other requiring a timeout.

### Fee management

Every commitment transaction includes a fee that is deducted from the channel balance. The fee is calculated from the transaction weight and a fee rate negotiated between the parties. The fee is always paid by the funder of the channel. If the fee is too low to be attractive to miners, either party can refuse to sign a new commitment and request a fee update.

### Dust HTLCs

HTLCs whose value falls below the dust limit (currently 546 satoshis for a P2WPKH output) are not included in the commitment transaction. Instead, the value is added to the fee. This prevents the blockchain from being polluted with uneconomical outputs and keeps the commitment transaction size bounded.
