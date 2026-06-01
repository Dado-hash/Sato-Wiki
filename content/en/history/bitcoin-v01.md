---
id: history.bitcoin-v01
slug: bitcoin-v01
language: en
date: 2009-01-09
title: Bitcoin v0.1 Released
category: origin
summary: Satoshi Nakamoto releases Bitcoin v0.1 on SourceForge, publishing the first open-source implementation of the Bitcoin protocol in C++.
tags:
  - Bitcoin
  - Software
  - Open Source
  - Satoshi Nakamoto
related:
  - id: wiki.transactions
    title: Bitcoin Transactions
  - id: wiki.blocks
    title: Blocks
  - id: wiki.mining
    title: Mining
  - id: wiki.full-nodes
    title: Full Nodes
  - id: wiki.peer-to-peer-network
    title: Peer-to-Peer Network
  - id: wiki.bitcoin-script
    title: Bitcoin Script
sources:
  - title: Bitcoin v0.1 release on SourceForge
    url: https://sourceforge.net/projects/bitcoin/files/Bitcoin/bitcoin-0.1/
    author: Satoshi Nakamoto
    publishedAt: 2009-01-09
  - title: Bitcoin v0.1 README
    url: https://bitcointalk.org/index.php?topic=68121.0
    author: Satoshi Nakamoto
    publishedAt: 2009-01-09
  - title: The first announcement of Bitcoin software
    url: https://www.metzdowd.com/pipermail/cryptography/2009-January/014994.html
    author: Satoshi Nakamoto
    publishedAt: 2009-01-09
updatedAt: 2026-05-28T00:00:00Z
---

On January 9, 2009, six days after mining the genesis block, Satoshi Nakamoto released Bitcoin v0.1 on SourceForge. This was the first working implementation of the Bitcoin protocol, written in C++ and released as open-source software. The announcement was made on the same cryptography mailing list where the whitepaper had been posted two months earlier.

![Bitcoin v0.1 screenshot](media/history/bitcoin-v01/bitcoin-v01-screenshot.webp "The Bitcoin v0.1 Windows client interface, showing the simple UI with a single address and basic controls.")

## The Software

Bitcoin v0.1 was a complete, self-contained implementation. It included a full-node client, a wallet, a miner, and a peer-to-peer networking layer. The software was designed for Windows, with the source code also available for compilation on other platforms. The installer was approximately 100 KB — a striking contrast to the multi-gigabyte blockchain that would eventually be required.

The release consisted of the following components:

- **bitcoin.exe**: The main application, combining a full node, wallet, and miner.
- **bitcoin.conf**: The configuration file where users could set parameters like the port number and IRC bootstrap server.
- **README.txt**: Documentation explaining installation, operation, and the cryptographic principles behind Bitcoin.
- **Source code**: The full C++ source, released under the MIT license.

The README included a prescient note about the fixed supply: "Bitcoins are generated at a rate of 50 BTC per block, and the total supply is 21 million."

## Key Design Decisions in v0.1

The first release already contained most of the fundamental design elements that Bitcoin uses today:

- **SHA-256 proof of work**: Mining used double SHA-256 of the block header.
- **Base58 addresses**: The address format using Base58Check was present from the start.
- **ECDSA signatures**: Transactions were secured with the Elliptic Curve Digital Signature Algorithm over secp256k1.
- **Script system**: The Bitcoin Script language was already implemented for locking and unlocking transactions.
- **Peer discovery via IRC**: Nodes discovered each other through an IRC channel, a pragmatic choice for the early network.
- **Port 8333**: The default port for Bitcoin peer-to-peer communication.

## The Open-Source Decision

By releasing Bitcoin as open-source software under the MIT license, Satoshi ensured that the project could outlive any single contributor. The decision was strategic: a decentralized currency required decentralized development. Anyone could inspect the code, verify the security, and contribute improvements. This transparency was essential for building the trust that a distributed financial system demands.

The choice of SourceForge as the distribution platform reflected the open-source conventions of the era. The project would later move to GitHub, where Bitcoin Core development continues today with hundreds of contributors.

## Running Bitcoin v0.1

Running the first version required technical proficiency. Users needed to download the installer, configure their firewall to allow incoming connections on port 8333, and wait for the blockchain to synchronize — which, at the time, took only a few seconds. The software would generate a cryptographic key pair locally and display the public address. Mining was CPU-based and built directly into the client — simply running the software would contribute hashing power to the network.

The early network was tiny. For the first few weeks, Satoshi was likely the only person mining. The difficulty was so low that blocks could be found with a standard desktop CPU in a matter of hours. This period of solo CPU mining would last for months before GPU mining became practical.

## Legacy

Bitcoin v0.1 represents the moment the theoretical Bitcoin became real. Six days after the genesis block, the software that would operate the network was in the hands of the public. Every subsequent Bitcoin implementation — from Bitcoin Core to btcd to libbitcoin — descends conceptually from this first release. The code itself has been almost entirely rewritten, but the protocol it implemented remains the foundation of the entire cryptocurrency ecosystem.

