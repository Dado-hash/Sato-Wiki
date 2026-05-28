---
id: wiki.htlcs
slug: htlcs
language: en
category: lightning network
title: HTLCs
description: Hash Time Locked Contracts — conditional payments that can be claimed only with the correct preimage before a timelock expires, enabling secure multi-hop routing on the Lightning Network.
coverImage: media/wiki/htlcs/htlc-flow.svg
difficulty: advanced
readTimeMinutes: 9
tags:
  - Lightning Network
  - HTLC
  - Hashlock
  - Timelock
  - Atomic Routing
related:
  - wiki.lightning-network
  - wiki.payment-channels
  - wiki.commitment-transactions
  - wiki.onion-routing
  - wiki.timelocks
  - wiki.hashlocks
sources:
  - title: "Poon-Dryja Lightning Network paper"
    url: https://lightning.network/lightning-network-paper.pdf
    author: Joseph Poon, Thaddeus Dryja
    publishedAt: 2016-01-14
  - title: "BOLT #2 — Peer Protocol for Channel Management"
    url: https://github.com/lightning/bolts/blob/master/02-peer-protocol.md
    author: Lightning Network Specifications
    publishedAt: 2016-03-30
  - title: "BOLT #4 — Onion Routing"
    url: https://github.com/lightning/bolts/blob/master/04-onion-routing.md
    author: Lightning Network Specifications
    publishedAt: 2016-04-01
  - title: "Mastering the Lightning Network (Chapter 9)"
    url: https://github.com/lnbook/lnbook
    author: Andreas M. Antonopoulos, Olaoluwa Osuntokun, René Pickhardt
    publishedAt: 2021-11-01
updatedAt: 2026-05-27T00:00:00Z
---

## base

A Hash Time Locked Contract (HTLC) is a conditional Bitcoin payment that requires the recipient to prove knowledge of a secret value (the preimage) before a deadline expires. Two conditions must be met:

**Hashlock.** The sender creates the hash of a secret random value, H(x). The recipient can only spend the output by providing the original value x that produces the same hash. This proves the recipient knows the secret.

**Timelock.** The HTLC output includes an absolute time limit using CLTV (OP_CHECKLOCKTIMEVERIFY). If the recipient does not reveal the preimage before this deadline, the sender can reclaim the funds.

HTLCs make multi-hop payments on the Lightning Network possible without trusting intermediate nodes. Alice can pay Carol through Bob without Bob being able to steal the funds — Bob can only claim his routing fee if Carol reveals the preimage, which also allows Alice to confirm the payment succeeded.

![HTLC flow across three nodes](media/wiki/htlcs/htlc-flow.svg "Alice creates an HTLC with hashlock H(x) and timelock 144 blocks. Bob forwards it to Carol with a shorter timelock. Carol reveals the preimage x to claim. The preimage propagates back, proving the payment completed.")

## medium

**Hashlock mechanics.** The sender generates a random 32-byte value x and computes its SHA256 hash H(x). The hash is embedded in the HTLC script. To spend the output, the receiver must provide x and a valid signature. The hashlock guarantees that only the party who knows x can claim the funds. Bitcoin's SHA256 is preimage-resistant — there is no way to derive x from H(x) other than brute force.

**Timelock mechanics.** The HTLC output uses CLTV with an absolute block height. In the Lightning Network, CLTV values are expressed as block heights (not timestamps). A typical HTLC might have a timelock of 144 blocks (~24 hours) from the current chain tip. If the preimage is not revealed before the timelock expires, the sender can spend via the timeout branch.

**Atomicity.** The HTLC is either fully claimed or fully refunded. When Alice pays Carol through Bob using HTLCs, the atomic property ensures:
- If Carol reveals the preimage, all three HTLCs settle forward: Alice pays Bob, Bob pays Carol
- If Carol does not reveal the preimage, all three HTLCs time out: Carol cannot claim, Bob recovers funds from Carol, Alice recovers funds from Bob
- No partial settlement is possible — there is no state where one hop succeeds and another fails

**Offer HTLC and Receive HTLC.** In a channel commitment transaction, each HTLC is represented as two outputs: one for the node that offered the HTLC (the sender side) and one for the node that received it (the receiver side). The offer HTLC output is controlled by the sender, showing the funds they have committed. The receive HTLC output is controlled by the receiver, showing the funds they expect to receive. Both are included in the commitment transaction and updated when a new HTLC is added or removed.

![HTLC success and timeout paths](media/wiki/htlcs/htlc-timeout-vs-success.svg "The successful path: Carol reveals the preimage, Bob claims and forwards it, Alice claims. The timeout path: Carol does not reveal the preimage, the timelock expires, and Bob and Alice reclaim their funds.")

## advanced

**HTLC script in the commitment transaction.** The HTLC output script in a commitment transaction uses a two-branch script:

```
OP_IF
  <remote_pubkey> OP_CHECKSIG                (fulfillment branch)
OP_ELSE
  <cltv_expiry> OP_CHECKLOCKTIMEVERIFY OP_DROP
  <local_pubkey> OP_CHECKSIG                 (timeout branch)
OP_ENDIF
```

The spender chooses which branch to execute by pushing either a true (1) or false (0) value before the script is run.

**Fulfillment branch.** The receiver spends via the IF branch by providing:
1. The preimage x (the hashlock)
2. A valid signature from their private key
3. A value of 1 on the stack to enter the IF branch

The transaction uses the preimage as the hashlock witness element. The full node verifies that H(x) matches the hash committed in the HTLC, and that the signature is valid for the remote pubkey. Once verified, the HTLC output is spent to the receiver.

**Timeout branch.** The sender spends via the ELSE branch by providing:
1. A valid signature from their private key
2. A value of 0 (or anything falsy) on the stack to enter the ELSE branch
3. The transaction must have nLockTime >= cltv_expiry

OP_CHECKLOCKTIMEVERIFY checks that the transaction's locktime is greater than or equal to the cltv_expiry. If the check passes, execution continues to OP_DROP (which removes the expiry value) and then to OP_CHECKSIG with the local pubkey. This guarantees the sender cannot claim the timeout branch before the timelock expires, even with their own signature.

**Accepting an HTLC.** Before accepting an HTLC, a forwarding node verifies several conditions:
- The cltv_expiry of the incoming HTLC is sufficiently far in the future
- The outgoing HTLC has a shorter cltv_expiry, leaving a safety margin (the cltv_expiry_delta from BOLT 2)
- The HTLC amount covers the routing fee plus the outgoing payment

The standard cltv_expiry_delta is 144 blocks (~24 hours) for the first hop and 12 blocks (~2 hours) for subsequent hops in the default LND configuration.

**HTLC forwarding and cltv_expiry_delta.** When Bob forwards an HTLC from Alice to Carol, he must ensure:
- Alice's HTLC to Bob: cltv_expiry = T1
- Bob's HTLC to Carol: cltv_expiry = T2, where T2 < T1

The difference T1 - T2 (the cltv_expiry_delta) gives Bob time to claim the timeout branch on the Alice-Bob channel if Carol fails to reveal the preimage before T2. BOLT 2 specifies minimum cltv_expiry_delta values based on the expected block interval and the forwarding node's risk tolerance.

**Preimage propagation.** The preimage flows backward through the route:
1. Carol reveals x to Bob by spending the HTLC output on the Bob-Carol channel
2. Bob sees x on-chain, which proves Carol claimed the HTLC
3. Bob now knows x and can spend the HTLC output on the Alice-Bob channel
4. Alice sees x on-chain, confirming Carol received the payment

Each hop independently claims its incoming HTLC using the preimage.

**HTLCs and fee management.** Each forwarding node charges a routing fee. When Bob forwards an HTLC, the amount he sends to Carol is less than what he receives from Alice — the difference is his routing fee. The fee structure is:
- Base fee: a fixed amount per HTLC (typically 1-1000 millisatoshis)
- Fee rate: a proportional fee per forwarded amount (typically 1-1000 parts per million)

Both the base fee and fee rate are encoded in the node's channel announcement and can be adjusted dynamically.

**Trimming.** HTLC outputs below the dust limit are not added to the commitment transaction. Instead, they are tracked off-chain and settled when the channel is closed or when a future commitment transaction includes them. The dust limit is typically 546 satoshis for P2WSH outputs. Trimming reduces the transaction weight and keeps commitment transactions smaller, lowering on-chain fees in case of a unilateral close.

**Multi-Path Payments (MPP).** A single payment can be split into multiple partial HTLCs, each routed through a different path. MPP requires:
- All partial HTLCs use the same payment hash H(x)
- The receiver waits until the sum of all partial payments equals the total amount before generating an invoice
- Each partial HTLC is independently atomic, but the overall payment completes only when all parts arrive

MPP improves reliability by routing around congested or failing channels, and improves privacy by distributing the payment across multiple paths.

**KeySend and spontaneous payments.** KeySend is an extension that eliminates the need for an invoice. The sender generates the preimage themselves and derives the payment hash from it. The payment hash is included in the onion payload, allowing the receiver to derive the preimage from the payment hash. This enables spontaneous payments where the sender does not need to request an invoice from the receiver.
