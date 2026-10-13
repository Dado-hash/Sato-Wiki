---
id: wiki.server-software
slug: server-software
language: en
category: software
subcategory: servers
title: Servers and Infrastructure
description: Software that sits between a full node and the apps that use it, such as Electrum-protocol servers, address indexes, block explorers and payment processors.
difficulty: base
readTimeMinutes: 6
tags:
  - Servers
  - Indexes
  - Privacy
  - Infrastructure
related:
  - wiki.full-nodes
  - wiki.node-software
  - wiki.software-wallets
  - wiki.bitcoin-addresses
  - wiki.utxo-model
sources:
  - title: Running A Full Node
    url: https://bitcoin.org/en/full-node
    author: Bitcoin.org contributors
  - title: electrs, an Electrum Server in Rust
    url: https://github.com/romanz/electrs
    author: electrs contributors
  - title: Fulcrum
    url: https://github.com/cculianu/Fulcrum
    author: Fulcrum contributors
  - title: Electrum protocol
    url: https://github.com/spesmilo/electrum-protocol
    author: Electrum developers
  - title: Compact block filters
    url: https://bitcoinops.org/en/topics/compact-block-filters/
    author: Bitcoin Optech
  - title: BTCPay Server FAQ
    url: https://docs.btcpayserver.org/FAQ/
    author: BTCPay Server contributors
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

A full node validates Bitcoin for you, but most apps need questions answered that a bare node does not answer well. A wallet wants to know every transaction involving its addresses. A shop wants to know when a payment reaches a certain depth. A block explorer wants to show the history of one address. Server software sits between the node and these apps, and it prepares answers the node was not built to serve.

Common examples include Electrum-protocol servers, address indexers, block explorers you host yourself, and payment processors such as BTCPay Server. Each one takes data from a node, stores extra information and answers requests from its own clients. Running them yourself keeps those requests inside your own infrastructure instead of sending your addresses to a third party.

A bare node has no address index. It stores blocks and the set of unspent outputs, which is enough to validate new blocks, but finding every transaction that touches one address requires an index that Bitcoin Core does not build by default. Building or running that index takes disk space, memory and processing time, and it is a separate job from validating the chain.

## medium

The Electrum protocol is a JSON-RPC interface that light wallets use to talk to a server. The server holds an index of addresses and their history, so the wallet can ask for balances and transactions without downloading the chain. Electrs is a Rust re-implementation of this server. Fulcrum is a C++ server that also speaks the protocol. The two differ in what they need from the node: electrs does not require the node to have the transaction index, while Fulcrum requires the node to run with txindex enabled and not in pruned mode.

Indexing has real costs. The first build reads the whole chain and can take a long time. After that, the server needs disk space for its index and enough memory and CPU to answer requests quickly. A server that serves many wallets needs more of each. These costs are the reason many people use a server run by someone else, and the reason a server you run yourself has a continuing maintenance job: it has to follow new blocks, handle reorgs and be upgraded with the software.

The privacy benefit comes from who sees the queries. A wallet that asks a public server for its addresses reveals those addresses to the server operator. A wallet that asks a server you run reveals them only to you. Electrum's documentation says that connecting to a server sacrifices some privacy, because the server can reasonably guess that the addresses belong to the same entity.

Payment processors such as BTCPay Server are server software for shops and donation pages. BTCPay's FAQ includes questions about deploying it next to an existing Bitcoin full node and about turning node pruning on or off, which shows that it depends on a node and that the node's configuration matters.

Block explorers follow the same pattern. A self-hosted explorer shows the history of your own addresses without sending the lookup to an outside website, but it needs an index and the resources to keep it current.

## advanced

Server software changes the trust and privacy model. An Electrum-style server learns which addresses a wallet is interested in, and it can see the timing and volume of requests. The server can also lie by omission, so a wallet that connects to it should check what it can. Compact block filters are an alternative that moves matching to the client: the wallet downloads a filter for each block and checks it locally, which gives more privacy and needs less server storage and CPU than address-indexed servers, at the cost of more bandwidth in the normal case. Bitcoin Optech's comparison is useful when you choose between these models.

Index design is an engineering choice. Some servers rely on the node's transaction index and need the node configured in a particular way. Others build their own database and do not require that index. Each design changes the upgrade path, the disaster recovery steps and the failure modes. When the node reorganizes, the server must roll back its index correctly, and a server that falls behind can serve stale answers to wallets that trust it.

Exposure is another concern. A server that accepts connections from the internet is part of your attack surface. It needs a firewall, authentication where the protocol supports it, and a clear rule about which clients may connect. A block explorer or payment page makes internal state visible to users, so it should expose only what it needs to show. Running these services on the same machine as a wallet or a signing device mixes trust levels and should be avoided.

For payment processors, the operator has to handle keys, invoices and accounting, along with the node underneath. The BTCPay FAQ shows that deployment questions are common: how to attach a server to an existing node, how to handle the initial sync, and how pruning affects what the server can do. The software is only one part. The operator decides which node it uses, how backups are kept and who has access to the admin interface.

Resource planning should be done before deployment. Disk, memory, bandwidth and CPU needs grow with the amount of data indexed and the number of clients served, and they change with software releases. Measure the server during the initial sync and during normal use before you decide whether to run it yourself, share it with others or use a third party.
