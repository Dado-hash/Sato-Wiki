---
id: wiki.tor
slug: tor
language: en
category: privacy-security
title: Tor and Bitcoin
description: Tor hides the network address of a node or wallet from the peers and observers it talks to, but it does not hide the transactions themselves.
coverImage: media/wiki/tor/tor-hero.svg
difficulty: base
readTimeMinutes: 4
tags:
  - Privacy
  - Tor
  - Networking
  - Onion Services
related:
  - wiki.peer-to-peer-network
  - wiki.full-nodes
  - wiki.onion-routing
  - wiki.threat-model
  - wiki.software-wallets
sources:
  - title: Bitcoin Core documentation - Tor support
    url: https://github.com/bitcoin/bitcoin/blob/master/doc/tor.md
    author: Bitcoin Core contributors
  - title: Bitcoin Core documentation - I2P support
    url: https://github.com/bitcoin/bitcoin/blob/master/doc/i2p.md
    author: Bitcoin Core contributors
  - title: "Deanonymisation of clients in Bitcoin P2P network"
    url: https://arxiv.org/abs/1405.7418
    author: Alex Biryukov, Dmitry Khovratovich, Ivan Pustogarov
  - title: Tor - Bitcoin Wiki
    url: https://en.bitcoin.it/wiki/Tor
    author: Bitcoin Wiki contributors
  - title: Protect your privacy
    url: https://bitcoin.org/en/protect-your-privacy
    author: Bitcoin.org contributors
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

Tor is an anonymity network that routes traffic through several relays, so the peer you connect to sees the address of an exit relay instead of yours. For Bitcoin the useful question is what Tor hides and what stays visible.

Tor hides the network address of your node or wallet from the peers you connect to and from anyone who watches the network near you. This matters because a peer that logs connections can associate a transaction with an IP address. Bitcoin.org suggests Tor for this reason.

Tor does not hide the transactions. The ledger is public, so the inputs, outputs, amounts and timing of a transaction can be read by anyone, whichever network carried it. If your wallet asks a remote server about your addresses, that server still sees the addresses even when the connection is routed through Tor. Tor hides where a connection comes from, not what the ledger contains.

Bitcoin Core can send outgoing connections through a Tor proxy, and it can listen as an onion service so that other nodes reach it without learning its IP address. The onion routing used by Lightning payments is a different mechanism, described in its own entry: it encrypts payment instructions in layers and does not route Bitcoin peer-to-peer traffic.

## medium

Bitcoin Core has three main ways to use Tor. First, when the node is pointed at a local SOCKS proxy, usually on port 9050, outgoing connections go through Tor, and onion addresses can be used as peers. Second, Bitcoin Core can create an onion service automatically through Tor's control port. Third, the option onlynet=onion limits automatic outbound connections to onion peers, while inbound and manual connections are not affected.

DNS is a common gap. The Bitcoin Core documentation says that DNS requests use the proxy only when a proxy is configured for them. Without one, the operating system resolves names, and the lookups can go over the clearnet to the internet provider's resolvers, even though peer connections travel through Tor. The proxy for DNS is set separately from the proxy for onion addresses, so the two need to be configured consistently.

A node that also runs an onion service should keep that service limited to Bitcoin Core's own port. The documentation says that adding another service, such as a web server, to the same onion service makes it trivial to link the two, which may reduce privacy. Automatically created onion services always expose a single port.

The documentation notes that a node which listens on all devices can still receive clearnet connections from a peer that learns its address, and suggests binding the listening address to the Tor proxy. It also warns that a node reachable on several networks can be correlated by an adversary that observes shared runtime characteristics.

For wallets the picture is different. A wallet that connects to its own node over Tor avoids giving its addresses to a third party. A wallet that connects to a remote server must send that server the addresses it cares about, whatever network path it uses. Tor can hide the wallet's IP address from that server, but not the addresses themselves.

## advanced

Tor-only operation trades one exposure for another. Bitcoin Core's documentation says that a node that listens on several networks makes eclipse and partition attacks more costly, because it has more independent connections, and that such bridge nodes help the network. A node that relies only on onion peers loses those paths and depends more on the availability of Tor. The trade-off is between hiding the node's identity and keeping its connectivity diverse.

Research has shown that Tor does not automatically protect the client. Biryukov, Khovratovich and Pustogarov (arXiv:1405.7418, 2014) described how the anti-DoS mechanism of the Bitcoin network could be abused to cut off Tor users. Many Tor users appear to come from the same exit relay, so misbehaviour attributed to one exit address could push its score over the ban threshold. The ban then disconnects every Tor user behind that exit. The paper describes the software of 2014, so its specific attack may not apply to current releases, but the lesson holds: a shared address makes anti-abuse rules affect many users at once.

The documentation also states that from Bitcoin Core 22.0 only Tor v3 onion services are supported, and that Tor removed v2 support beginning with version 0.4.6. The automatic onion service needs Tor's control port, and it works only when proper authentication has been configured.

Bitcoin Core also supports I2P through a SAM proxy, which gives a similar anonymity network with a different design. Its documentation notes that I2P has fewer peers than Tor or IP networks, so a node that uses I2P alone may be more exposed to Sybil attacks.

Tor does not protect the ledger, and it does not make a wallet's server private. The network address that Tor hides is one signal among several. Timing, transaction graphs and the addresses a wallet queries remain visible unless other measures are taken. A complete design therefore pairs the network layer with the privacy practices covered elsewhere in this category, such as careful address handling, rather than relying on Tor as a complete solution.

Whether to run a node as Tor-only depends on what must stay unlinkable. The right answer changes with the threat model, which is why that entry should be read first.
