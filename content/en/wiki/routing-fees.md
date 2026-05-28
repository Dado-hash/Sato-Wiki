---
id: wiki.routing-fees
slug: routing-fees
language: en
category: lightning network
title: Routing Fees
description: The costs charged by intermediate Lightning nodes for forwarding payments, consisting of a base fee and a proportional fee per HTLC.
coverImage: media/wiki/routing-fees/fee-breakdown.svg
difficulty: advanced
readTimeMinutes: 8
tags:
  - Lightning Network
  - Routing Fees
  - Economics
  - Node Operation
related:
  - wiki.lightning-network
  - wiki.channel-liquidity
  - wiki.onion-routing
  - wiki.payment-channels
  - wiki.lightning-invoices
sources:
  - title: "BOLT #7 — P2P Node and Channel Discovery"
    url: https://github.com/lightning/bolts/blob/master/07-routing-gossip.md
    author: Lightning Network Specifications
  - title: "Mastering the Lightning Network — Chapter 11: Pathfinding"
    url: https://github.com/lnbook/lnbook
    author: Andreas M. Antonopoulos, Olaoluwa Osuntokun, Rene Pickhardt
  - title: "Pickhardt Payments — Fee-Aware Pathfinding"
    url: https://arxiv.org/abs/2107.05322
    author: Rene Pickhardt, Stefan Richter
    publishedAt: 2021-07-12
updatedAt: 2026-05-27T00:00:00Z
---

## base

**What are routing fees?** When a payment travels through the Lightning Network, it does not go directly from sender to recipient — it hops through multiple intermediate nodes. Each node that forwards the payment charges a small fee for its service.

**Two components.** Every routing fee consists of two parts:
- **Base fee** (*fee_base_msat*): a fixed amount in millisatoshis charged per forwarded payment, regardless of its size.
- **Proportional fee** (*fee_proportional_millionths*): a variable amount proportional to the payment value, expressed in parts per million (ppm).

The sender pays the cumulative fees of all hops. The recipient receives the full payment amount minus the total fees deducted along the path.

**Why fees exist.** Routing nodes provide essential infrastructure — they lock up channel liquidity, take on HTLC risk (temporary fund locking during forwarding), and maintain always-on connectivity. Fees compensate them for these costs and risks.

**Analogy.** Think of routing fees like toll booths on a highway. Each segment between exits has its own toll. You pay at each booth, and the total toll is the sum of all segments. A longer route with more hops means more fees, just like a longer drive with more toll booths costs more.

![Routing Fee Accumulation](media/wiki/routing-fees/fee-breakdown.svg "A 3-hop payment from Alice to Diana: Bob and Carol each charge a base fee and a proportional fee, reducing the forwarded amount at each step.")

## medium

**Base fee in detail.** The base fee (*fee_base_msat*) is a flat charge per forwarded HTLC, typically ranging from 1 to 1,000 millisatoshis (0.001–1 satoshi). It compensates the node for the operational overhead of forwarding: processing the HTLC, managing the channel state, and taking on the counterparty risk that the HTLC will need to be resolved on-chain. The base fee matters most for small payments — it can be a significant percentage of a 1,000 sat payment but negligible for a 1,000,000 sat payment.

**Proportional fee in detail.** The proportional fee (*fee_proportional_millionths*) is expressed in parts per million (ppm). For example, 100 ppm means 0.01% of the forwarded amount. Typical values range from 1 ppm (0.0001%) to 1,000 ppm (0.1%). The proportional fee scales with payment size, making it the dominant cost for large payments.

**Fee calculation.** The fee for a single hop is:

```
fee = fee_base_msat + (amount_msat × fee_proportional_millionths / 1,000,000)
```

For a 100,000 sat payment through a node charging 10 msat base and 100 ppm:
```
fee = 10 + (100,000,000 × 100 / 1,000,000)
fee = 10 + 10,000 = 10,010 msat = 10.01 sats
```

**Fee obfuscation in the onion.** The onion routing protocol ensures that no intermediate node knows the full route or the total fee. Each node only sees the HTLC it must forward and the fee it will earn. The sender constructs nested encrypted payloads, with each hop's instructions sealed inside layers that only that hop can decrypt. This preserves privacy — Bob does not know whether Alice is the original sender or Carol is the final recipient.

**Impact on pathfinding.** Pathfinding algorithms like Dijkstra's algorithm treat the total fee as an edge weight and search for the lowest-cost path from sender to recipient. Nodes with high fees are deprioritized; nodes with low fees attract more routing traffic. The pathfinding node computes the cumulative fee across candidate paths and selects the cheapest. This creates a competitive marketplace where nodes must set fees strategically to attract flow.

**Fee updates.** Nodes change fees dynamically using `channel_update` gossip messages. Operators adjust fees based on:
- Channel liquidity balance (raising fees when outbound liquidity is scarce)
- Network congestion (raising fees during high demand)
- Competitive positioning (lowering fees to attract routing volume)
- Operational costs (server uptime, rebalancing costs)

![Routing Fee Strategies](media/wiki/routing-fees/fee-strategies.svg "A comparison of cheap, balanced, and premium fee strategies showing the trade-off between volume and per-payment revenue.")

## advanced

**The node's dilemma.** Every routing node faces a fundamental economic choice: low fees attract high routing volume but may not cover costs; high fees earn more per payment but repel traffic. This mirrors the classic Bertrand competition model in economics, where nodes undercut each other on price until fees approach marginal cost. However, Lightning's heterogeneous node quality — differences in reliability, liquidity depth, and channel connectivity — prevents a pure race to the bottom.

**Opportunity cost of liquidity.** The capital locked in Lightning channels could otherwise be deployed elsewhere (lending, trading, on-chain earning). A node operator must consider this opportunity cost when setting fees. For example, if 1 BTC locked in channels could earn 5% APR in DeFi, the monthly opportunity cost is ~4,167 sats. If the node routes 1,000 payments per month, it needs at least ~4.2 sats per payment just to break even with the alternative use of capital.

**HTLC risk cost.** When forwarding an HTLC, the node temporarily locks funds for the duration of the payment (typically seconds to minutes, but potentially hours for failed or contested payments). During this window, the liquidity is unavailable for other routing. If a channel force-closes while an HTLC is pending, resolving it requires on-chain transactions, which adds cost and complexity. The base fee primarily compensates for this HTLC-specific risk.

**Pickhardt payments and uncertainty graphs.** René Pickhardt and Stefan Richter proposed a fee-aware pathfinding approach using uncertainty graphs (2021). Instead of treating channel liquidity as binary (enough / not enough), the model assigns probabilities to channel balances. The pathfinding algorithm then minimizes a combined cost function that includes both fees and the probability of payment failure. This approach reduces the need for trial-and-error payment attempts and improves first-attempt success rates. The total cost minimized is:

```
cost = total_fees - λ × log(p_success)
```

Where λ is a tunable parameter balancing fee minimization against success probability.

**MPP and fee arithmetic.** Multi-path payments (MPP) split a payment across multiple routes, each incurring its own fees. The total fee is the sum of fees across all shards. MPP can sometimes reduce total fees when a single expensive hop can be avoided by splitting around it. However, MPP also increases the number of HTLCs in flight, potentially increasing base fee costs. The optimal split depends on the fee structures of available paths and the liquidity distribution across channels.

**Fee discrimination.** While most nodes apply uniform fees to all peers, nothing prevents a node from setting different fees for different channels. This practice, called fee discrimination, is uncommon because it adds operational complexity and reduces network predictability. In practice, nodes typically set a single fee policy and apply it to all channels, or group channels by liquidity alignment.

**Zero-fee routing.** Some nodes, particularly large hubs and well-capitalized nodes, route payments with zero or near-zero fees. This is a deliberate strategy to bootstrap routing volume and establish centrality in the network graph. These nodes typically earn revenue through other means (exchange integration, Lightning Service Provider operations) and treat routing as a customer acquisition or retention tool. Zero-fee routing has been criticized for centralizing the network topology, but it also lowers the barrier to entry for new users.

**Fee revenue vs. rebalancing costs.** Routing nodes earn fees on outgoing payments but must maintain balanced channel liquidity to continue routing. Rebalancing — moving funds back into depleted channels — costs money (either on-chain transaction fees or circular rebalancing through the Lightning Network itself). The net routing profit is:

```
net_profit = fee_revenue - rebalancing_costs - operational_costs
```

A node might earn 10,000 sats in fees but spend 3,000 sats on rebalancing and 1,000 sats on node infrastructure, for a net profit of 6,000 sats. Many nodes operate at slim margins or at a loss, treating routing as a public good or strategic investment.

**Pathfinding fee estimation.** Modern Lightning implementations use sophisticated fee estimation that considers not just the declared fee policy but also:
- Historical channel reliability (uptime, successful forward rate)
- Channel age and depth
- The probability that a channel's outbound balance can actually accommodate the payment
- The congestion charge (nodes may raise fees during high load)

These factors are combined into a "canonical" cost estimate that pathfinding algorithms use instead of raw fee values.

**Wumbo channels and fee economics.** Large channels (above 0.167 BTC, the pre-Wumbo limit) change fee economics significantly. A Wumbo channel can route many large payments without rebalancing, reducing rebalancing costs. However, it also concentrates liquidity risk and increases the capital opportunity cost. As Wumbo channels become more common, the proportional fee component may decrease (since volume is higher) while the base fee may increase (since HTLC risk per channel is larger).
