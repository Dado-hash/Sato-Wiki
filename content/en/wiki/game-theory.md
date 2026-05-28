---
id: wiki.game-theory
slug: game-theory
language: en
category: economics
title: Game Theory
description: The study of strategic decision-making that explains why rational participants in Bitcoin follow the rules, making the system secure without central authority.
coverImage: media/wiki/game-theory/game-theory-hero.svg
difficulty: base
readTimeMinutes: 7
tags:
  - Economics
  - Game Theory
  - Incentives
  - Security
related:
  - wiki.miner-incentives
  - wiki.consensus-rules
  - wiki.proof-of-work
  - wiki.fee-market
  - wiki.network-effects
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: The Byzantine Generals Problem
    url: https://lamport.azurewebsites.net/pubs/byz.pdf
    author: Leslie Lamport, Robert Shostak, Marshall Pease
    publishedAt: 1982-07-01
  - title: Game Theory and Bitcoin
    url: https://www.bitcoinplaybook.org/chapters/game-theory/
    author: Hasu, James Prestwich
updatedAt: 2026-05-28T00:00:00Z
---

## base

Game theory is the study of how rational people make decisions when the outcome depends on what others do. Bitcoin uses game theory to ensure that participants behave honestly even though nobody is in charge.

In Bitcoin, there are three main groups of participants:
- **Miners**: Compete to create blocks and earn rewards
- **Full nodes**: Validate blocks and enforce rules
- **Users**: Transact and decide which chain has value

Each group has their own interests, but the rules of Bitcoin are designed so that the most profitable choice for everyone is to follow the rules. This is called incentive alignment.

For example, a miner could try to spend the same bitcoin twice (double-spend). But to do this, they would need to mine a secret chain that outpaces the honest chain. This requires enormous computing power and electricity. If they succeed, the attack would destroy trust in Bitcoin and collapse the price — making their mining equipment worthless. The attack is therefore unprofitable, so rational miners do not attempt it.

![Bitcoin game theory equilibrium](media/wiki/game-theory/game-theory-hero.svg "Three groups — miners, full nodes, and users — have aligned incentives that make honest behavior the dominant strategy for each.")

Think of Bitcoin like a sports league. Players could break the rules for short-term gain, but the referees (full nodes) enforce the rules, and the fans (users) will abandon the league if it becomes known for cheating. Everyone understands this, so most players follow the rules most of the time.

## medium

Bitcoin's game theory can be understood through several classic concepts:

**The Nash Equilibrium.** A Nash equilibrium occurs when no participant can benefit by changing their strategy while others keep theirs unchanged. Bitcoin's protocol creates a Nash equilibrium where honest mining is the dominant strategy. A miner considering a double-spend attack must weigh the reward against the cost: the attack requires controlling more hash power than the honest chain, which is enormously expensive. Even if successful, the resulting loss of confidence would devalue any bitcoin the attacker holds, making the attack self-defeating.

**The Byzantine Generals Problem.** This is a classic problem in distributed computing: how can separated parties agree on a plan when some may be traitors? Satoshi solved this by introducing economic incentives. In Bitcoin, "traitors" (dishonest miners) are not prevented from acting, but their actions are made economically irrational. The cost of cheating exceeds the potential gain.

**The principal-agent problem.** Miners (agents) act on behalf of the network (principal). The subsidy and fees align their interests: miners earn more by following the rules than by breaking them. The halving ensures this alignment persists as the subsidy declines, by forcing miners to compete on efficiency rather than relying on a fixed payout.

**Tragedy of the commons.** Mining is a competitive industry where individual miners increase their hash rate to capture a larger share of rewards. When all miners do this, difficulty adjusts upward, and everyone's share remains similar while costs rise. This is a classic "arms race" but it has a positive side effect: it makes the network extremely secure. The high cost of entry prevents attackers from cheaply acquiring mining power.

Key game theoretic properties of Bitcoin:

| Property | Description |
|----------|-------------|
| Dominant strategy | Honest mining is always the most profitable strategy |
| Cost of cheating | Requires >50% of hash rate, with no guarantee of profit |
| Sybil resistance | Voting power is proportional to hash rate, not identity |
| Trust minimization | No single party needs to be trusted; trust is distributed |
| Self-healing | The difficulty adjustment restores equilibrium after shocks |

## advanced

**The double-spend game in detail.** Consider a miner with hash rate fraction `p` who wants to double-spend. They send a transaction to a merchant, wait for confirmations, receive goods, then try to replace the confirmed transaction with a conflicting one on a private chain. The attacker must privately mine a longer chain than the honest network. The probability of success after `z` confirmations follows:

```
P(success) = 1 - sum(k=0 to z) (λ^k × e^(-λ)) / k!   where λ = z × p / (1-p)
```

This is the same formula Satoshi derived in Section 11 of the whitepaper. For a miner with 10% of hash rate attacking a 6-confirmation transaction, the success probability is approximately 0.02%. For 30% hash rate, it rises to roughly 11%. This is why exchanges and merchants typically wait for at least 3-6 confirmations.

**The Nash equilibrium of selfish mining.** The "selfish mining" attack (Eyal and Sirer, 2013) shows that the simple Nash equilibrium is not the only possibility. A miner with >33% of hash rate can profit by withholding found blocks and strategically releasing them to orphan honest miners' blocks. This strategy is profitable even though the miner wastes some of their own work, because they capture a disproportionate share of rewards.

However, selfish mining has never been observed on Bitcoin mainnet at scale for several reasons:
1. Detection is possible through block propagation analysis
2. The strategy reduces overall network security, potentially devaluing the attacker's holdings
3. The threshold for profitability (>33%) is high and requires covert coordination
4. Counter-strategies exist (unobservable block templates, FIBRE relay)

**Fork choice as a game.** Bitcoin's "longest chain" rule (actually: most accumulated work) creates a Schelling point — a natural focal point that all rational participants converge on. If the network ever split into competing forks, users and miners have a strong incentive to coordinate on one chain. The chain with the most accumulated work is the natural focal point because it objectively represents the most expended resources.

**The honest majority assumption.** Bitcoin's security depends on the assumption that the majority of hash rate is controlled by honest miners. This is not a mathematical guarantee but a game-theoretic one: it is more profitable to be honest than to attack. The assumption has held since Bitcoin's inception, with hash rate growing from a few GH/s to over 700 EH/s, making attack costs astronomically high.

**Incentives in the fee-only era.** As subsidies decline toward zero, the game theory of mining changes. Miners must rely entirely on fee revenue. This creates a new equilibrium where:
- Fee revenue must be sufficient to sustain the desired security level
- Miners may have incentives to censor or prioritize certain transactions
- The alignment between miner profit and network security becomes less direct

Proposed solutions include tail emission (rejected by Bitcoin Core) and reliance on Layer 2 fee traffic to sustain base-layer fees.
