---
id: wiki.channel-liquidity
slug: channel-liquidity
language: en
category: lightning network
title: Channel Liquidity
description: The distribution of funds across a payment channel that determines how much can be sent or received, and how payments are routed through the network.
coverImage: media/wiki/channel-liquidity/liquidity-balance.svg
difficulty: advanced
readTimeMinutes: 8
tags:
  - Lightning Network
  - Liquidity
  - Channel Balance
  - Routing
  - Inbound Liquidity
related:
  - wiki.lightning-network
  - wiki.payment-channels
  - wiki.routing-fees
  - wiki.lightning-service-providers
  - wiki.multipath-payments
sources:
  - title: "Mastering the Lightning Network — Chapter 6: Node Operations"
    url: https://github.com/lnbook/lnbook
    author: Andreas M. Antonopoulos, Olaoluwa Osuntokun, Rene Pickhardt
  - title: "BOLT #7 — P2P Node and Channel Discovery"
    url: https://github.com/lightning/bolts/blob/master/07-routing-gossip.md
    author: Lightning Network Specifications
  - title: "Lightning Network Routing and Liquidity"
    url: https://lightning.network/docs/
    author: Lightning Network Documentation
updatedAt: 2026-05-27T00:00:00Z
---

## base

Channel liquidity refers to how much bitcoin sits on each side of a payment channel at any given moment. Every channel has a fixed total capacity, set when the channel is opened by locking funds into a 2-of-2 multisig output on the Bitcoin blockchain. That capacity never changes for the lifetime of the channel — only the distribution shifts.

**Fixed capacity, shifting balance.** The sum of both parties' balances always equals the channel capacity. When Alice sends 0.1 BTC to Bob through their 1 BTC channel, Alice's balance decreases by 0.1 BTC and Bob's increases by the same amount. The channel still holds 1 BTC total, but the balance has moved.

**Outbound vs inbound.** Outbound liquidity is the amount you can send — it is your side of the channel balance. Inbound liquidity is the amount you can receive — it is the other party's side of the channel balance. These are mirror images: if you have 0.7 BTC in a channel, you can send up to 0.7 BTC and receive up to 0.3 BTC.

**The see-saw analogy.** Imagine a see-saw with a fixed plank length. When one side goes up, the other goes down by the exact same amount. Channel liquidity works the same way: every satoshi that moves from Alice to Bob reduces Alice's sending capacity and increases Bob's. The total remains constant.

![Channel Liquidity Allocation](media/wiki/channel-liquidity/liquidity-balance.svg "Two channels showing how the same total capacity is split differently between node pairs. Alice can send 0.7 BTC to Bob but Bob can only send 0.3 BTC back through that same channel.")

## medium

**Fixed capacity constraint.** The invariant of any payment channel is: `balance_A + balance_B = channel_capacity`. This means liquidity is a zero-sum game within a channel. Every payment in one direction reduces the sender's outbound capacity by the payment amount and increases the receiver's outbound capacity (by giving them more to send back).

**Payment direction changes the balance.** If Alice sends 0.2 BTC to Bob in a 1 BTC channel, the balance shifts from (0.7, 0.3) to (0.5, 0.5). Now both can send 0.5 BTC. If Alice sends another 0.4 BTC, it shifts to (0.1, 0.9). Now Alice can only send 0.1 BTC, while Bob can send 0.9 BTC. The channel is imbalanced — it favors one direction over the other.

**The inbound liquidity problem.** Receiving is not automatic on Lightning. To receive a payment, you need inbound capacity — someone else must have a channel to you with funds on their side. This is the single most common pain point for new Lightning nodes.

**Why inbound liquidity is hard.** When you open a channel, you fund it entirely from your own wallet. This gives you outbound liquidity (you can send), but it gives you zero inbound liquidity (nobody can send to you through that channel until the other party also has balance on their side). You cannot simply buy or create inbound liquidity on-chain — it must come from other nodes routing payments through your channel in the opposite direction.

**Network topology implications.** Well-connected nodes, or hubs, naturally accumulate inbound liquidity over time because payments flow through them in both directions. A node with many channels balanced in both directions becomes a useful routing node. Small or new nodes with few channels and all balance on their side struggle to receive because no payment can enter.

![The Inbound Liquidity Problem](media/wiki/channel-liquidity/liquidity-problem.svg "Three scenarios showing how inbound liquidity determines whether a payment succeeds or fails. Without inbound capacity, Bob cannot receive despite having an open channel.")

## advanced

**Liquidity on the network graph.** The Lightning Network is a directed graph where each channel has a known capacity (public in channel announcements per BOLT 7) but the exact balance distribution is private — only the two channel partners know it. This creates a fundamental uncertainty problem for routing algorithms: they must guess which channels have enough outbound liquidity for a given payment.

**Probabilistic pathfinding.** Modern Lightning implementations use probabilistic pathfinding to estimate channel liquidity. Instead of assuming a particular balance, they model each channel's balance as a probability distribution. When a payment attempt succeeds or fails, the node updates its beliefs about the liquidity of each channel along the path. The more information a node has (from past payment attempts, gossip, or probing), the better its probability estimates become.

**The uncertainty set.** Each node knows exactly two things: its own channel balances (inbound and outbound for each direct channel) and the total capacity of every public channel (from the gossip protocol). Everything else — the balance distribution of channels between other nodes — is unknown. Successful pathfinding requires navigating this uncertainty: picking routes where the probability of sufficient outbound liquidity exceeds some threshold.

**Circular rebalancing.** When a channel becomes too imbalanced (all balance on one side), a node can perform circular rebalancing. The node sends a payment that loops through the network and returns to itself through the imbalanced channel, shifting balance in the desired direction. This consumes routing fees (each hop in the loop charges its fee) but avoids closing and reopening the channel. Circular rebalancing is an active area of tooling development, with many node implementations offering automated rebalancing strategies.

**Splice-in and splice-out (BOLT 2).** Splice-in adds more funds to an existing channel without closing it, increasing the channel capacity. Splice-out removes funds from a channel, decreasing its capacity. Both operations use a new funding transaction that replaces the old one while preserving the channel's state and HTLCs. Splice-in is useful when a channel needs more total capacity; splice-out is useful when funds are needed elsewhere. Neither operation solves the inbound liquidity problem directly — they only change total capacity, not the balance distribution.

**Dual-funding (BOLT 2).** Standard channel opening requires one party to fund the entire channel. Dual-funding allows both parties to contribute at channel creation. If Alice and Bob open a 1 BTC channel with dual-funding, Alice can contribute 0.6 BTC and Bob 0.4 BTC. Bob now has 0.4 BTC of outbound liquidity and 0.6 BTC of inbound liquidity from the moment the channel opens. Dual-funding solves half the inbound liquidity problem at channel creation, but the balance can still become imbalanced over time as payments flow.

**LSPs and inbound liquidity as a service.** Lightning Service Providers (LSPs) address the inbound liquidity problem by selling it. An LSP opens a channel to you, funding it from their side, giving you immediate inbound capacity. You pay a fee (typically a one-time setup fee plus routing fees) for this service. LSPs are essential for mobile wallets and non-routing nodes, which cannot easily acquire inbound liquidity through organic network participation.

**JIT (Just-In-Time) channels.** A JIT channel is opened by an LSP on-demand when a payment arrives for a user who has no direct channel with the sender. The LSP detects an incoming payment, opens a channel to the recipient, forwards the payment through, and collects routing fees. The user does not need to manage channels or liquidity — the LSP handles it transparently. JIT channels are a key UX improvement for Lightning onboarding.

**Liquidity ads and the liquidity market.** BOLT proposal for liquidity advertisements would allow nodes to publicly advertise that they want to buy or sell inbound liquidity. A liquidity market would let nodes discover each other, negotiate terms (fee, duration, channel size), and open channels programmatically. This is an active area of development that could significantly reduce the friction of acquiring inbound liquidity.

**The channel reserve (1% dust limit).** Each channel has a reserve, typically 1% of the channel capacity, that cannot be spent. This reserve exists to enforce a cost on channel closure: if either party tries to cheat by broadcasting an old state, they lose their entire balance, including the reserve. The reserve is not available as outbound or inbound liquidity — it is locked until the channel closes. For a 1 BTC channel, 0.01 BTC is reserved and 0.99 BTC is usable. Routing algorithms and balance calculations must account for this reserve to avoid routing failures due to insufficient usable liquidity.
