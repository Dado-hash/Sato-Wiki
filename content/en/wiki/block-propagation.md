---
id: wiki.block-propagation
slug: block-propagation
language: en
category: protocol
title: Block Propagation
description: How Bitcoin blocks spread across the network and why fast relay matters for security and miner revenue.
coverImage: media/wiki/block-propagation/block-propagation-hero.svg
difficulty: advanced
readTimeMinutes: 10
tags:
  - Block Relay
  - Network
  - Mining
  - BIP
related:
  - wiki.blocks
  - wiki.blockchain
  - wiki.full-nodes
  - wiki.consensus-rules
  - wiki.proof-of-work
sources:
  - title: "BIP-130: sendheaders message"
    url: https://github.com/bitcoin/bips/blob/master/bip-0130.mediawiki
    author: Pieter Wuille
    publishedAt: 2015-05-25
  - title: "BIP-152: Compact Block Relay"
    url: https://github.com/bitcoin/bips/blob/master/bip-0152.mediawiki
    author: Matt Corallo
    publishedAt: 2016-03-21
  - title: "BIP-330: Transaction Announcement Reconciliation (Erlay)"
    url: https://github.com/bitcoin/bips/blob/master/bip-0330.mediawiki
    author: Gleb Naumenko, Pieter Wuille
    publishedAt: 2019-09-17
  - title: "FIBRE: Fast Internet Bitcoin Relay Engine"
    url: http://bitcoinfibre.org/
    author: Matt Corallo
  - title: "Bitcoin Core net_processing implementation"
    url: https://github.com/bitcoin/bitcoin/blob/master/src/net_processing.cpp
    author: Bitcoin Core contributors
  - title: "End-to-end bitcoin block propagation measurement"
    url: https://bitcoin.stackexchange.com/questions/35093/how-long-does-it-take-for-a-block-to-propagate-on-average
    author: Bitcoin Stack Exchange
updatedAt: 2026-05-27T00:00:00Z
---

## base

When a miner finds a valid block, they need to tell the rest of the network. The block is sent to connected peers, who verify it and pass it to their peers. Faster propagation means less time for competing blocks to be found, reducing the orphan rate and network waste.

![Block propagation wave across the network](media/wiki/block-propagation/block-propagation-hero.svg "A discovered block spreads through the peer-to-peer network like a diffusion wave. Each node validates and relays, reducing orphan race risk.")

A block that propagates slowly gives competing miners more time to find their own block on the same parent. When two valid blocks appear at similar times, one becomes an orphan — its work is wasted. The network benefits when all miners learn about the new tip as quickly as possible.

## medium

Bitcoin's block relay has evolved through several protocols. The original design sent the full block to every peer — simple but bandwidth-heavy. Modern relay uses headers-first announcement and compact block relay (BIP-152) to reduce bandwidth by roughly 100x.

The headers-first protocol works through an inv/getheaders/headers exchange. When a node learns of a new block, it sends an inv (inventory) message with the block hash. The peer responds with a getheaders message, and the node replies with the 80-byte block header. Only after validating the header — checking proof of work and the link to the previous block — does the peer request the full block data.

Compact block relay (BIP-152) improves this dramatically. Instead of sending the full block, the node sends only short transaction identifiers (short IDs) alongside a small set of full transactions the peer is unlikely to have. The peer reconstructs the block from its mempool using the short IDs. If a transaction is missing from the mempool, the peer requests it individually. In high-bandwidth mode, a preferred peer sends compact blocks directly without waiting for a request, enabling near-instant relay.

![Compact block relay message flow](media/wiki/block-propagation/propagation-flow.svg "Message sequence between two Bitcoin nodes during compact block relay. Short IDs allow mempool-based block reconstruction.")

Fast propagation directly affects miner revenue. A block that propagates in under one second has a negligible orphan risk. At two to five seconds, the orphan probability becomes measurable. Mining pools therefore compete on relay speed, often connecting to each other through optimized relay networks like FIBRE (Fast Internet Bitcoin Relay Engine) and the Falcon network, which use forward error correction and dedicated links to reduce propagation to tens of milliseconds.

## advanced

Block relay has undergone four major protocol phases, each motivated by the growing blockchain's bandwidth demands and the competitive pressure on mining latency.

**Full block relay (original).** Nodes sent the complete block — roughly 1 MB at the time — to every peer. A node with 8 peers transmitted 8 MB per block. As blocks grew with more transactions, this became unsustainable.

**Headers-first (BIP-130, 2015).** Nodes announce blocks by sending the 80-byte header first. Peers validate the header's proof of work and parent link cheaply, then request the full block only if the header is valid. This prevents bandwidth waste from invalid or outdated blocks, but the full block still transfers in its entirety at least once per peer.

**Compact blocks (BIP-152, 2016).** The block sender constructs short IDs for every transaction using SipHash-2-4 keyed with a nonce shared in the version handshake:

```
short_id = SipHash(k0, k1, tx_hash) & 0xFFFFFFFFFFFFF
```

The 48-bit short ID has a collision probability of roughly 2⁻¹⁶ per million transactions, which is acceptable because any collision triggers a full transaction request for the affected short ID. The compact block message includes:

- The block header (80 bytes)
- A nonce for the SipHash key
- Short IDs for all transactions
- The full serialization of all transactions that the sender expects the peer to be missing (typically coinbase and transactions that arrived after the mempool snapshot)

The peer reconstructs the block by matching short IDs against its mempool. If all transactions are found, the block is reconstructed, validated, and relayed. If some short IDs do not match (due to mempool differences, reorgs, or transactions not yet received), the peer sends a getblocktxn message requesting the missing transactions by index. The sender responds with a blocktxn message containing only the requested transactions.

High-bandwidth mode is a further optimization in BIP-152. Nodes select up to three "preferred" peers and send them compact blocks immediately upon receipt, without waiting for an inv/getheaders exchange. This reduces the announcement round trip to near zero and is safe because the receiving peer can ignore duplicate or invalid blocks at the cost of minimal bandwidth.

**Erlay (BIP-330, 2021).** While compact blocks optimized block relay, transaction relay remained bandwidth-heavy. Erlay replaces flooding-based transaction announcement with set reconciliation using a Minisketch-based protocol. Nodes periodically reconcile their transaction inventory sets rather than announcing each transaction individually. This reduces transaction relay bandwidth by approximately 40% without increasing propagation delay.

### Relay networks and latency

Mining pools face a prisoner's dilemma on relay speed: all miners benefit from fast propagation, but any single miner can gain an advantage by investing in faster links. This has led to specialized relay infrastructure:

- **FIBRE** uses UDP-based forwarding with forward error correction (FEC) to eliminate TCP head-of-line blocking. Blocks propagate through FIBRE in under 200 ms globally.
- **Falcon** operates a dedicated relay backbone connecting major mining pools and Bitcoin Core nodes, offering sub-100 ms propagation.
- **Private relay tunnels** between pools reduce block relay to tens of milliseconds, at the cost of network centralization.

Measured orphan rates on the live network are approximately 0.1–0.3% of all blocks. At Bitcoin's 10-minute average block interval, this translates to roughly 5–15 orphaned blocks per week. Each orphan represents approximately 6.25 BTC in wasted work (plus fees) at network difficulty, underscoring the economic incentive for fast relay.

### Bitcoin Core net_processing architecture

In Bitcoin Core, block relay is handled by the `PeerManager` class in `net_processing.cpp`. The flow is:

1. `ProcessMessage` dispatches incoming messages (`inv`, `headers`, `cmpctblock`, `getblocktxn`, `blocktxn`, etc.) to dedicated handlers.
2. `HandleBlockMessage` validates the block, checks against the active chain, and either connects it immediately or queues it for later processing (if the parent is unknown).
3. `MaybeSendCompact` decides whether to request a compact block or full block from a peer based on negotiated BIP-152 support and whether the peer is in high-bandwidth mode.
4. Block download is parallelized across multiple peers using a block-download scheduling window, where different peers provide different blocks in parallel during initial block download (IBD).

The architecture prioritizes headers over block data, so the node can detect chain tips and reorganizations before committing bandwidth to full block transfer.
