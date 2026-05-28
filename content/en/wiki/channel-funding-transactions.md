---
id: wiki.channel-funding-transactions
slug: channel-funding-transactions
language: en
category: lightning network
title: Channel Funding Transactions
description: The on-chain Bitcoin transaction that opens a payment channel by creating a shared 2-of-2 multisig output funded by both channel parties.
coverImage: media/wiki/channel-funding-transactions/funding-tx-anatomy.svg
difficulty: advanced
readTimeMinutes: 8
tags:
  - Lightning Network
  - Funding Transaction
  - Multisig
  - On-Chain
related:
  - wiki.payment-channels
  - wiki.commitment-transactions
  - wiki.transactions
  - wiki.multisig
  - wiki.bitcoin-addresses
  - wiki.utxo-model
sources:
  - title: "The Bitcoin Lightning Network: Scalable Off-Chain Instant Payments"
    url: https://lightning.network/lightning-network-paper.pdf
    author: Joseph Poon, Thaddeus Dryja
    publishedAt: 2016-01-14
  - title: "BOLT #2 — Peer Protocol for Channel Management"
    url: https://github.com/lightning/bolts/blob/master/02-peer-protocol.md
    author: Lightning Network Specifications
  - title: "Mastering the Lightning Network"
    url: https://github.com/lnbook/lnbook
    author: Andreas M. Antonopoulos, Olaoluwa Osuntokun, René Pickhardt
    publishedAt: 2021-12-07
updatedAt: 2026-05-27T00:00:00Z
---

## base

To open a payment channel on the Lightning Network, the two parties first create a funding transaction on the Bitcoin blockchain. This is a regular Bitcoin transaction that spends existing UTXOs belonging to each party and creates a single output sent to a 2-of-2 multisig address.

The key property of this funding output is that it requires both parties to sign before the funds can be spent. Neither Alice nor Bob can move the channel funds alone. This mutual custody is what makes off-chain payments safe.

The funding transaction is broadcast to the Bitcoin network and confirmed like any other transaction. Miners include it in a block, and after a sufficient number of confirmations (typically 6 on mainnet), the channel is considered open. From that moment, the two parties can exchange signed commitment transactions off-chain without further on-chain activity.

![Funding transaction anatomy](media/wiki/channel-funding-transactions/funding-tx-anatomy.svg "Alice and Bob contribute UTXOs to a funding transaction that creates a shared 2-of-2 multisig output, confirmed in a block.")

## medium

The funding transaction creates a P2WSH (Pay-to-Witness-Script-Hash) output whose witness script is a 2-of-2 multisig:

```
OP_2 <pubkey_A> <pubkey_B> OP_2 OP_CHECKMULTISIG
```

Each party contributes a number of satoshis to the funding output. The sum of their contributions forms the total channel capacity. For example, if Alice contributes 200,000 sats and Bob contributes 100,000 sats, the channel has a capacity of 300,000 sats.

The funding output is identified by its outpoint — a combination of the transaction ID (txid) and the output index (vout). This outpoint serves as the unique identifier of the channel on the Lightning Network and is used in all subsequent protocol messages referencing the channel.

A critical safeguard in the protocol is that the funding transaction must be fully signed by both parties before it is broadcast. This prevents either party from broadcasting a transaction that the other did not agree to. The exchange of signatures happens through the `funding_signed` message defined in BOLT 2.

Once both signatures are exchanged and verified, the transaction can be broadcast. The channel capacity is fixed for the lifetime of the channel — unless splicing (a protocol extension) is used to add or remove funds.

![2-of-2 multisig address creation](media/wiki/channel-funding-transactions/multisig-address.svg "Alice's and Bob's public keys are combined into a 2-of-2 multisig script, which is hashed to produce the P2WSH address.")

## advanced

**Funding flow in detail.** The channel opening process defined in BOLT 2 begins with the `open_channel` message, which includes the funding amount, the feerate for commitment transactions, and the party's public keys. The recipient responds with `accept_channel`. Both parties then construct the funding transaction and their respective commitment transactions *before* the funding transaction is broadcast.

This pre-construction is essential: each party creates an initial commitment transaction that spends the funding output back to themselves (minus the channel reserve). These commitment transactions are signed and exchanged via `funding_signed`, but they are never broadcast unless a party needs to close the channel unilaterally. By pre-signing them, both parties ensure they can always recover their funds even if the other party disappears after the funding transaction confirms.

**The funding_locked message.** After the funding transaction is broadcast, both parties monitor its confirmation depth on the Bitcoin blockchain. When the transaction reaches the required depth (min_depth), which defaults to 6 confirmations on mainnet, each party sends the `funding_locked` message. This message signals that the channel is operational and ready to route payments. The `funding_locked` message includes the party's next per-commitment point, which is needed to construct future commitment transactions.

**Channel ID derivation.** The channel ID is derived from the funding transaction's outpoint. Specifically, the txid and output index are XOR-normalized to produce a 32-byte channel identifier used in all subsequent Lightning messages:
```
channel_id = funding_txid XOR (funding_output_index || 0x0000...)
```

**Dual funding (BOLT 2).** In the dual-funding variant, both parties contribute to the funding output simultaneously. Unlike the single-funder case, where only one party provides all the satoshis, dual funding requires a more complex interactive transaction construction protocol. Both parties add their inputs and outputs to the funding transaction, then exchange signatures interactively until the transaction is complete.

**P2WSH vs P2SH-P2WSH.** Modern Lightning implementations use native P2WSH for the funding output, which is more efficient and has lower fees. However, P2SH-P2WSH (wrapped SegWit) is also supported for compatibility with older wallets that do not support native SegWit addresses. In P2SH-P2WSH, the script hash is embedded in a P2SH output, and the witness data is revealed when spending.

**Fee management.** The funding transaction itself must pay mining fees. Since both parties contribute to the funding output, they must agree on how the fee is deducted. In the single-funder model, the funder pays the fee by contributing slightly more to cover it. In dual funding, the fee is typically split proportionally. The fee rate is negotiated during the `open_channel` / `accept_channel` handshake.

**Channel reserve.** Each channel enforces a minimum balance that each party must maintain — the channel reserve. This reserve (typically 1% of the channel capacity) ensures that both parties have economic incentive to behave honestly. If a party's balance drops to zero, they might be incentivized to broadcast an old state. The reserve mitigates this by ensuring each party always has something to lose.
