---
id: wiki.onion-routing
slug: onion-routing
language: en
category: lightning network
title: Onion Routing
description: The privacy-preserving communication protocol used in Lightning Network that encrypts payment data in layers, ensuring no intermediate node knows the full payment path.
coverImage: media/wiki/onion-routing/onion-routing-layers.svg
difficulty: advanced
readTimeMinutes: 9
tags:
  - Lightning Network
  - Onion Routing
  - Privacy
  - Sphinx
  - Routing
related:
  - wiki.lightning-network
  - wiki.htlcs
  - wiki.payment-channels
  - wiki.lightning-invoices
  - wiki.routing-fees
  - wiki.multipath-payments
sources:
  - title: "BOLT #4 — Onion Routing"
    url: https://github.com/lightning/bolts/blob/master/04-onion-routing.md
    author: Lightning Network Specifications
    publishedAt: 2016-04-01
  - title: "The Sphinx Mix Network Protocol"
    url: https://www.cypherpunks.ca/~iang/pubs/Sphinx_Oakland09.pdf
    author: George Danezis, Ian Goldberg
    publishedAt: 2009-05-01
  - title: "Mastering the Lightning Network — Chapter 8: Onion Routing"
    url: https://github.com/lnbook/lnbook
    author: Andreas M. Antonopoulos, Olaoluwa Osuntokun, Rene Pickhardt
updatedAt: 2026-05-27T00:00:00Z
---

## base

Onion routing is a privacy technique that wraps payment data in multiple layers of encryption, like the layers of an onion. When Alice pays Carol through intermediate nodes, she constructs a packet where each layer can only be opened by one specific node. Each intermediate node peels one layer, learns only the identity of the next hop, and forwards the remaining encrypted payload.

**Analogy.** Imagine passing a sealed envelope inside a series of nested envelopes. Alice puts a letter (the payment) inside an envelope addressed to Carol. She places that inside another envelope addressed to Diana, which goes inside an envelope addressed to Bob. Bob receives the bundle, opens only the outer envelope, sees "forward to Diana", and passes the rest along. Diana opens her envelope, sees "forward to Carol", and forwards the inner envelope. Carol opens the final envelope and reads the payment details. No courier ever sees the full path.

**Privacy property.** Only the sender knows the complete route. Each intermediary sees exactly two nodes: the node that sent them the packet and the node they must forward to. This property protects the privacy of both the sender and the recipient — an intermediate node cannot determine who originated a payment or who ultimately receives it.

![Onion routing layers](media/wiki/onion-routing/onion-routing-layers.svg "Alice constructs an onion with three layers. Bob peels the outer layer, Diana the middle, and Carol receives the innermost payment data. Each node sees only its own hop.")

## medium

**Source routing.** In the Lightning Network, the sender chooses the entire path. Before constructing the onion, Alice runs a pathfinding algorithm over the network graph (discovered via the gossip protocol) to select a route of connected channels with sufficient liquidity. The selected path is encoded into the onion, layered in reverse order — the outermost layer is encrypted for the first hop, the next for the second hop, and so on. The innermost layer is for the final recipient.

**Onion construction.** Alice generates a series of ephemeral ECDH (Elliptic Curve Diffie-Hellman) keys, one per hop. For each hop, she derives a shared secret using her ephemeral private key and the hop's public node key. This shared secret generates a symmetric encryption key (using ChaCha20-Poly1305, previously AES-256 in early BOLT 4) and a MAC key. Alice encrypts each layer starting from the innermost: the per-hop payload for Carol is encrypted with Carol's key, wrapped inside Diana's payload encrypted with Diana's key, wrapped inside Bob's payload encrypted with Bob's key. The result is a fixed-size onion packet.

**The Sphinx protocol.** Lightning's onion routing is built on the Sphinx mix network protocol, designed by George Danezis and Ian Goldberg in 2009. Sphinx provides three guarantees:
- **Compactness:** the packet size remains constant regardless of path length.
- **Replay protection:** each packet includes a unique replay tag that prevents nodes from seeing the same packet twice and linking it to the same sender.
- **Integrity:** each layer includes a MAC (Message Authentication Code) that the node verifies before accepting the packet. Tampering with any byte causes the MAC check to fail.

**Per-hop payload.** When a node peels its layer, it finds:
- The public node key or short channel ID of the next hop.
- The HTLC parameters: amount to forward, CLTV expiry.
- Optional padding or additional TLV data.
- The rest of the onion (inner layers) to forward.

The node does not see the payment amount for the final recipient, the total path length, or the identities of nodes beyond its immediate neighbors.

**Packet structure.** BOLT 4 defines the onion packet as exactly 1300 bytes: a fixed size regardless of path length. This prevents traffic analysis based on packet size. The packet contains:
- A 1-byte version field.
- A 33-byte ephemeral public key.
- A 32-byte replay protection tag.
- A 32-byte HMAC for the entire packet.
- 1300 bytes of encrypted hop data (in modern implementations, 1300 bytes of TLV payload; in legacy, 20 × 65-byte fixed-length per-hop fields with filler).

The fixed size means an attacker cannot tell whether a packet is routing through 2 hops or 20 hops.

![Multi-hop payment path](media/wiki/onion-routing/payment-path.svg "Alice selects a path through Charlie, Bob, and Diana to Carol. HTLCs flow forward along the path; the preimage returns in the reverse direction. Each node knows only its predecessor and successor.")

## advanced

**Sphinx construction: shared secret derivation.** For each hop along the path, Alice computes a shared secret using Diffie-Hellman key agreement. Let the sequence of nodes be N₀ (Alice), N₁, N₂, ..., Nₙ (Carol). For hop i, Alice generates an ephemeral keypair (eᵢ, Eᵢ) where Eᵢ = eᵢ × G. The shared secret with node Nᵢ is:

```
ssᵢ = SHA256(eᵢ × pubkeyᵢ)
```

In practice, a single ephemeral keypair (e, E) is generated and the shared secrets are derived using a blinding factor that re-randomizes the ephemeral key at each hop:

```
ss₁ = SHA256(e × pubkey₁)
E₁ = E
ss₂ = SHA256(e₁ × pubkey₂)  where e₁ = SHA256(ss₁) × e
E₂ = SHA256(ss₁) × E₁
...
ssᵢ = SHA256(eᵢ₋₁ × pubkeyᵢ)
Eᵢ = SHA256(ssᵢ₋₁) × Eᵢ₋₁
```

This blinding ensures that each hop sees a different ephemeral public key, preventing any node from correlating the onion packet across multiple hops. An intermediate node sees Eᵢ and derives ssᵢ using its own private key, but cannot link Eᵢ to Eᵢ₋₁ or Eᵢ₊₁ without the blinding factors.

**Blinding factors.** The re-randomization of the ephemeral key using SHA256(ssᵢ) as a blinding factor is critical for unlinkability. Without blinding, a node that sees the same ephemeral key at two different positions on the network could deduce they belong to the same payment. The blinding factor breaks this correlation entirely — the ephemeral key is different at every hop, and only the sender can recompute the chain.

**MAC verification.** Each layer of the onion includes a 32-byte MAC computed over the encrypted payload. The MAC key is derived from the shared secret:

```
mac_keyᵢ = HMAC-SHA256(ssᵢ, "mac_key")
```

When a node receives the onion packet, it computes the MAC using its derived key and compares it with the MAC in the packet. If the MAC does not match, the packet is invalid and the node MUST reject it. This detects any tampering — if Bob modifies a byte of the onion before forwarding, Diana's MAC check will fail and she will reject the packet.

**Filler generation algorithm.** The fixed 1300-byte packet size creates a challenge: as the onion is peeled at each hop, the remaining raw payload shrinks. To keep the packet size constant, the sender pads the inner layers with a filler string. The filler is generated using a stream cipher keyed with a filler key derived from each hop's shared secret. The sender generates filler for all hops and packs it around the remaining onion data so that after each peel, the visible payload is always exactly 1300 bytes. An attacker cannot distinguish between real hop data and filler, concealing the remaining path length.

**Legacy BOLT 4 vs TLV onion payloads.** Early BOLT 4 implementations used a fixed-format per-hop payload of 65 bytes with specific fields at fixed offsets (amount, CLTV expiry, next hop, padding). This legacy format was rigid and required protocol upgrades to change the payload structure. Modern implementations use TLV (Type-Length-Value) encoding inside the onion, allowing flexible extensibility:

- **TLV onion:** each per-hop payload is a sequence of TLV records. New types can be added without changing the onion format, enabling features like route blinding, KeySend, and Trampoline routing.
- **Backward compatibility:** nodes signal TLV support in their feature bits. A TLV-capable node can receive legacy onions and vice versa, though the full set of modern features requires both sides to support TLV.

**KeySend and spontaneous payments.** KeySend is an extension that enables payments without a pre-generated invoice. In a normal payment, the recipient generates the preimage, computes the payment hash H(x), and provides it to the sender in an invoice. With KeySend, the sender generates the preimage and the payment hash themselves, then embeds the preimage in the onion payload encrypted for the final recipient. The recipient decrypts the payload, learns the preimage, and claims the HTLC. This eliminates the invoice exchange round-trip, enabling spontaneous tipping and donation-style payments where the sender initiates without prior coordination.

**Trampoline routing.** In source routing, the sender must know the entire network topology to select a path. This is impractical for mobile wallets with limited bandwidth and battery. Trampoline routing delegates pathfinding to designated Trampoline nodes. The sender specifies the final recipient and payment details in an inner onion, and the Trampoline node handles the remaining path selection. The sender constructs a multi-layer onion where the outer layers route to the Trampoline node, and the inner layer (encrypted for the recipient) is opaque to the Trampoline. Multiple Trampoline hops can be chained, each doing local pathfinding for their segment. This reduces the sender's bandwidth requirements at the cost of revealing the final recipient to the Trampoline node.

**Route blinding (BOLT 4).** Route blinding hides the final recipient from all intermediate nodes, including the last public node before the recipient. The recipient generates a blinded route: a sequence of blinded node IDs and encrypted forwarding instructions that the sender uses as the tail of the payment path. Each hop in the blinded segment can only be decrypted by the specific node, and the final hop reveals only the blinded recipient ID — not the recipient's actual node public key. The recipient generates multiple blinded routes in advance and distributes them through invoices or other channels. Route blinding is specified in BOLT 4 as an TLV extension and is critical for privacy against adversaries who operate routing nodes on the network.
