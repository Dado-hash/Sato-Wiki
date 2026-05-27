---
id: wiki.peer-to-peer-network
slug: peer-to-peer-network
language: en
category: protocol
title: Peer-to-Peer Network
description: Bitcoin nodes form a permissionless mesh network where each participant connects directly to others, discovers peers, and exchanges blocks and transactions without a central server.
coverImage: media/wiki/peer-to-peer-network/p2p-hero.svg
difficulty: base
readTimeMinutes: 10
tags:
  - P2P Network
  - Node Discovery
  - Relay
  - Network Protocol
related:
  - wiki.full-nodes
  - wiki.blocks
  - wiki.mempool
  - wiki.consensus-rules
sources:
  - title: Bitcoin Developer Guide - P2P Network
    url: https://developer.bitcoin.org/devguide/p2p_network.html
    author: Bitcoin.org contributors
  - title: Bitcoin Core - net_processing.cpp
    url: https://github.com/bitcoin/bitcoin/blob/master/src/net_processing.cpp
    author: Bitcoin Core contributors
  - title: BIP-324 — Version 2 P2P Transport
    url: https://github.com/bitcoin/bips/blob/master/bip-0324.mediawiki
    author: Pieter Wuille, Matt Corallo, Jonas Schnelli, et al.
  - title: BIP-330 — Erlay
    url: https://github.com/bitcoin/bips/blob/master/bip-0330.mediawiki
    author: Gleb Naumenko, Gregory Maxwell
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
updatedAt: 2026-05-27T00:00:00Z
---

## base

Bitcoin nodes connect to each other in a peer-to-peer network. There is no central server, no single point of control. Each node discovers other nodes, establishes connections, and exchanges blocks and transactions. Nodes can join and leave freely, and the network adapts.

This design is permissionless: any node can connect to any other node that accepts inbound connections. No one needs approval. The network treats all participants as equal — there is no privileged relay or routing layer.

When a new node starts, it needs to find other nodes. It uses one or more seed mechanisms: DNS seeders (hardcoded domain names that resolve to reliable node addresses), hardcoded seed nodes in Bitcoin Core, or — historically — the IRC bootstrap channel. Once connected, the node learns more addresses from its peers through addr messages and can build its own map of the network.

A node typically maintains 8 to 12 outbound connections and accepts up to 125 inbound connections. The outbound count is deliberately small to reduce bandwidth while keeping the node connected to different parts of the network.

## medium

### Node discovery

A fresh Bitcoin node starts with a short list of hardcoded seed nodes and several DNS seed names. DNS seeds are domain names maintained by volunteers or organizations. When queried, they return a rotating set of IP addresses of reachable nodes. The node connects to a few of these, performs the version handshake, and then receives addr messages containing more addresses.

Historically, Bitcoin used an IRC bootstrap channel as an additional discovery method. Nodes joined a specific channel and received a list of participants. IRC bootstrap was removed in later versions.

After initial discovery, the node maintains an address manager with two main tables: tried and new. The tried table stores addresses that the node has successfully connected to in the past. The new table stores addresses learned from peers that have not been tested yet. Each table contains multiple buckets to prevent one peer from flooding the address space.

### Connection handshake

When Node A wants to connect to Node B over TCP (port 8333 by default), it sends a version message containing its protocol version, timestamp, best block height, relay preference, and a random nonce. Node B responds with its own version message and immediately follows with a verack (version acknowledgment). Node A sends its own verack in return. Once both nodes have exchanged version and verack, the connection is established and they can begin exchanging inventory messages.

After the handshake, nodes may exchange sendheaders or sendcmpct messages to negotiate block relay preferences. A node can also send a feefilter message to ask the peer not to relay transactions below a given fee rate.

### Relay preferences

Bitcoin Core nodes can signal whether they prefer to receive new blocks as headers announcements (sendheaders) or as compact blocks (sendcmpct). Compact blocks reduce bandwidth by sending only the transactions the receiver may already have in its mempool, plus short identifiers for unknown ones. This optimization was introduced in Bitcoin Core 0.13.0 with BIP-152.

### Inbound and outbound limits

A Bitcoin Core node by default opens 8 outbound connections and divides them into categories: full-relay, block-relay-only (no transaction relay), and feeler connections (short-lived probes for address testing). It accepts up to 125 inbound connections. Each inbound connection consumes a socket and some memory, but the main bottleneck is the processing work for relaying transactions and blocks.

### Feelers

Feeler connections are short-lived outbound connections (around 100 seconds) that probe whether an address from the new table is actually reachable. They test one address at a time and disconnect quickly. If the address responds correctly, it is moved to the tried table. This prevents the tried table from filling up with unreachable addresses.

### Privacy and transport

Bitcoin Core supports Tor (both v2 and v3 onion services), I2P, and CJDNS for transport privacy. Onion and I2P addresses are self-authenticating — the address itself encodes the rendezvous point and the destination's public key. CJDNS provides an encrypted IPv6 mesh. Nodes can connect over clearnet, Tor, I2P, or any combination. Bitcoin Core isolates connections by network type to prevent linking activity across different transports.

Light clients (SPV wallets) do not relay blocks or transactions. They connect to listening nodes, request relevant transactions, and rely on the node for connectivity. They do not contribute to network propagation and are not counted as part of the peer-to-peer mesh in the same way as full nodes.

## advanced

### Wire protocol format

Every Bitcoin P2P message on the network (before BIP-324 v2 transport) begins with a fixed header:

| Field | Size | Description |
|-------|------|-------------|
| Magic | 4 bytes | Network identifier (0xD9B4BEF9 for mainnet) |
| Command | 12 bytes | ASCII command name, padded with null bytes |
| Payload length | 4 bytes | Little-endian unsigned integer |
| Checksum | 4 bytes | First 4 bytes of double-SHA256 of payload |
| Payload | Variable | Command-specific data |

The message header is 24 bytes. The payload is interpreted according to the command field. Commands include version, verack, addr, inv (inventory), getdata, tx, block, headers, getheaders, ping, pong, sendheaders, sendcmpct, feefilter, getaddr, mempool, reject, filterload, filteradd, filterclear (BIP-37), and more.

### BIP-324: Version 2 P2P transport

BIP-324 introduces opportunistic encryption for Bitcoin P2P connections. The transport layer adds a version-1 handshake (used for backward compatibility) and a version-2 encrypted handshake based on the Noise protocol framework. Once established, the connection is encrypted and authenticated. The v2 transport prevents passive surveillance of transaction and block relay and makes it harder for network observers to identify which node sent which message. Bitcoin Core fully supports v2 transport since version 26.0.

### Address manager: tried and new

The Bitcoin Core address manager (CAddrMan) organizes known peer addresses into two groups:

- **Tried table**: Up to 64 buckets with 64 entries each (4096 addresses total). Only addresses that the node has successfully connected to and completed a handshake with are stored here.
- **New table**: Up to 256 buckets with 64 entries each (16384 addresses total). Addresses learned from peers but not yet tested go here.

When a new address arrives, the node selects a bucket deterministically based on the source address and the address's own network group. This ensures that a single hostile peer cannot fill the address manager with its own entries. When a bucket is full, the node applies a randomized eviction policy weighted by last-seen time and connection success rate.

The two-table design is an anti-DoS mechanism. Without it, an attacker could flood a node with fake addresses, isolating it from the network or wasting its connection attempts.

### Inbound connection eviction

Bitcoin Core has a fixed maximum for inbound connections. When a new inbound connection arrives and the limit is reached, the node selects a candidate for eviction based on: lowest version, longest idle time, no known address, lowest ping time, or lowest address group diversity. The eviction algorithm tries to protect a diverse set of peers and avoids disconnecting well-behaved nodes.

### Feeler connections

Feeler connections are outbound connections opened specifically to probe an address from the new table. They last about 100 seconds. If the remote peer responds and completes a version handshake, the address is promoted to the tried table. If not, the address remains in the new table or is discarded. Bitcoin Core opens at most one feeler connection per 90 seconds to avoid aggressive scanning.

### Anti-DoS measures

Bitcoin Core limits the rate at which it processes messages per peer:

- **Inv/addr flood control**: A peer that sends too many inventory or address messages is penalized and eventually disconnected.
- **Version checks**: If a peer's advertised protocol version is too low, the connection is rejected.
- **Time misbehavior**: A peer whose timestamp on the version message is too far from the node's time is treated skeptically.
- **Ban scores**: Misbehaving peers accumulate a ban score. When the score exceeds a threshold, the peer is banned for a configurable period.
- **DoS resistance on addr relay**: The bucket structure of the address manager prevents a single malicious peer from injecting fake addresses that crowd out honest ones.

### Erlay (BIP-330)

Erlay replaces the current flood-based transaction relay with a set reconciliation protocol. Instead of broadcasting each new transaction to all peers, a node sends announcements to a small subset and periodically reconciles its set of announced transactions with each peer. This reduces bandwidth by approximately 40% for transaction relay without increasing latency for block propagation.

The protocol uses a Minisketch-based set reconciliation sketch. Each peer maintains a sketch of recently announced transaction hashes. When two peers reconcile, they exchange sketches and compute the symmetric difference. Only the missing transactions are sent individually. Erlay was deployed on the Bitcoin network starting in 2022.

### Tor, I2P, and CJDNS

Bitcoin Core supports:

- **Tor v3 onion services** (BIP-155): Onion addresses are 56 characters ending in .onion. The node can both listen as a Tor hidden service and make outbound connections through Tor. Tor v2 was deprecated and removed.
- **I2P**: Similar to Tor, I2P provides anonymous, encrypted connections. Bitcoin Core can connect to I2P peers and listen as an I2P destination. I2P addresses are base32 strings ending in .b32.i2p.
- **CJDNS**: An encrypted IPv6 mesh network. CJDNS addresses always start with fc. Bitcoin Core treats CJDNS as a separate network type.

Connections are isolated by network type. Clearnet, Tor, I2P, and CJDNS traffic are not mixed, preventing linkage across anonymity sets. The node resolves .onion, .b32.i2p, and fc00:: addresses and routes them through the correct proxy.

![Peer-to-peer connection handshake](media/wiki/peer-to-peer-network/p2p-message-flow.svg "Two nodes establish a connection through the version/verack handshake, then exchange inventory and data messages.")
