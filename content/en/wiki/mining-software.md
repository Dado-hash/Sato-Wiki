---
id: wiki.mining-software
slug: mining-software
language: en
category: software
subcategory: mining-software
title: Mining Software
description: The software layers used in Bitcoin mining, from miner firmware and pool software to the protocols that carry work and block templates between them.
coverImage: media/wiki/mining-software/mining-software-hero.svg
difficulty: advanced
readTimeMinutes: 4
tags:
  - Mining
  - Firmware
  - Stratum
  - Block Templates
  - Mining Pool
related:
  - wiki.mining
  - wiki.mining-hardware
  - wiki.proof-of-work
  - wiki.miner-incentives
  - wiki.blocks
sources:
  - title: Stratum V2 project website
    url: https://stratumprotocol.org/
    author: Stratum V2 project
  - title: Stratum V2 Specification - Job Declaration Protocol
    url: https://github.com/stratum-mining/sv2-spec/blob/main/06-Job-Declaration-Protocol.md
    author: Stratum V2 contributors
  - title: Bitcoin Optech - Pooled mining
    url: https://bitcoinops.org/en/topics/pooled-mining/
    author: Bitcoin Optech
  - title: DATUM Gateway README
    url: https://github.com/OCEAN-xyz/datum_gateway
    author: Bitcoin Ocean, LLC
  - title: "BIP 22: getblocktemplate - Fundamentals"
    url: https://github.com/bitcoin/bips/blob/master/bip-0022.mediawiki
    author: Luke Dashjr
  - title: Braiins OS - Installation on S21 and S19 series
    url: https://academy.braiins.com/en/braiins-os/installation/install
    author: Braiins
updatedAt: 2026-10-13T00:00:00Z
reviewedAt: 2026-10-13
---

## base

Mining software is the set of programs that sits between mining hardware and the Bitcoin network. It has three main layers. The first is the firmware that runs on the miner itself. Stock firmware comes with the device, while aftermarket firmware such as Braiins OS can be installed on supported Antminer S19 and S21 series control boards. The second layer is pool software, which hands out work, accepts shares and tracks each miner's contribution. The third is the protocol that connects miner and pool.

In a pool, miners usually do not choose which transactions go into a block. The pool supplies the block template, and the miner hashes headers derived from it. Whoever builds that template decides which transactions are included, so the choice of template builder matters beyond efficiency.

The long-standing protocol for pool work is Stratum, introduced in 2012. Stratum V2 is its successor, with encrypted connections and a design that lets miners take part in building the template. Newer approaches, such as DATUM, have the miner's own node build the template.

Payout rules are a separate decision. Pools split rewards in different ways, and that choice changes how income varies from day to day for each miner.

## medium

A Stratum V1 pool sends each miner a job. The job includes the parts of the block header that do not change, a coinbase prefix and suffix, the network target and a share target that is easier than the network target. The miner varies the nonce and the coinbase extranonce, hashes the result, and submits any header that meets the share target. A header that also meets the network target is a full block, and the pool broadcasts it. Because the pool gives the job, the pool also decides what goes into the coinbase.

Stratum V2 keeps this basic loop but changes several things. Traffic between miner and pool is encrypted and authenticated, which blocks attacks that swap pool credentials to redirect hashrate, and it hides shares from network observers who could otherwise estimate a miner's output. Its Job Declaration Protocol lets a miner-side client declare a custom job to a pool-side server, which allocates a token for it. The specification describes two modes. In coinbase-only mode, the pool sees the coinbase and fee revenue but not the transactions. In full-template mode, the miner declares the transaction set.

The block template comes from getblocktemplate, the RPC defined in BIP 22. A node returns the data needed to assemble a candidate block, and the mining software builds the header from it. BIP 23 extends the same call for pooled mining.

DATUM takes a different route. The DATUM Gateway asks a local node for block templates, generates work for the mining hardware, and submits solved blocks to the network. A DATUM-supporting pool coordinates the reward split and does not create work for the miner. The gateway serves hardware over Stratum V1 with version rolling, and it needs a node that supports getblocktemplate. Its README notes that the pool still validates blocks in the current version of the protocol.

## advanced

Template construction is the point where mining software touches censorship resistance. The Stratum V2 project describes a few large pools that now dominate block space, sometimes acting as proxies for other pools, and notes that a pool can selectively include or exclude transactions. Moving template construction toward miners is meant to reduce that single point of control. Its effect depends on how many miners actually build their own templates.

The Job Declaration Protocol divides work between two roles. The Job Declarator Client runs on the miner side and declares custom jobs. The Job Declarator Server runs on the pool side, allocates tokens, acknowledges declarations and keeps its own mempool through a node. The specification states that a pool working in coinbase-only mode cannot see which transactions are in the miner's template, which protects the miner's mempool privacy. It also says that this mode leaves the pool open to a miner declaring a coinbase whose fee revenue does not match the real template. The specification compares that risk to block withholding and suggests mitigations, such as proofs that the fee revenue belongs to a valid template without revealing it.

DATUM shows the same tension from another side. Its README says the real miner is whoever runs the Bitcoin node, not the pool, and that the pool coordinates payouts. The project also states that the current pool validates blocks as a safety measure during testing, and that a future protocol version would leave the pool almost blind to the template. The README also says that Bitcoin Core offers limited template control options, which the project considers a centralizing factor.

Firmware is a separate risk. It runs on the miner's control board, where it controls hashing and the network connection to the pool. Pool URLs, credentials and firmware updates all reach the device through that path. Stratum V1 traffic can be read by network intermediaries, and the Stratum V2 project argues that its encryption and authentication prevent hashrate from being hijacked by swapping pool credentials. Encryption protects the link, but it does not make the pool or the firmware trustworthy.

Payout schemes add a further layer. Under pay-per-share, a pool pays a set amount for each share, and the variance of finding blocks moves onto the pool. Other schemes pay only when a block is found.
