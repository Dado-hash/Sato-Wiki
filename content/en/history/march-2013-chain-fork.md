---
id: history.march-2013-chain-fork
slug: march-2013-chain-fork
language: en
date: 2013-03-11
title: March 2013 Chain Fork
category: security
summary: In March 2013 nodes older than version 0.8 rejected a valid block with many inputs because of a database lock limit, and the network split into two chains.
tags:
  - Fork
  - Berkeley DB
  - Consensus
  - Mining pool
sources:
  - title: "BIP 50: March 2013 Chain Fork Post-Mortem"
    url: https://github.com/bitcoin/bips/blob/master/bip-0050.mediawiki
    author: Gavin Andresen
    publishedAt: 2013-03-20
  - title: "Common Vulnerabilities and Exposures (CVE-2013-3220 entry)"
    url: https://en.bitcoin.it/wiki/Common_Vulnerabilities_and_Exposures
    author: Bitcoin Wiki contributors
    publishedAt: 2013-03-11
related:
  - wiki.forks-and-soft-forks
  - wiki.mining-pools
  - wiki.reorganizations
  - wiki.full-nodes
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## What happened

On 11 March 2013, a block with more transaction inputs than any earlier block was mined and broadcast. Nodes running Bitcoin 0.8 could process it, but some nodes running older versions rejected it, and the network split into two chains. The chain that included the block, which BIP 50 calls the 0.8 chain, held about 60% of the mining hash power. That share meant the split did not resolve on its own.

## Why it happened

Versions before 0.8 used Berkeley DB and were configured with too few locks to process large but valid blocks. The lock limit had effectively become a consensus rule, although the actual usage could vary from node to node. Bitcoin 0.8 used LevelDB instead, which did not have the same limit. BIP 50 adds that the same weakness could have affected version 0.7.2 nodes even if the whole network ran that version.

## How it was resolved

To restore one chain quickly, BTCGuild and Slush downgraded their 0.8 nodes to 0.7, so their pools rejected the larger block. This gave majority hash power to the chain without that block, and the 0.8 nodes reorganized onto it. The split was detected quickly, and deposits at the major exchanges were suspended for a short time. During the split a double spend succeeded. BIP 50 says it was carried out by someone testing whether it was possible and was not intended to be malicious.

## What changed afterwards

Developers released version 0.8.1, forked from 0.8.0. For two months it rejected blocks that would probably need more than 10,000 locks, and it capped the size of the blocks it created at 500,000 bytes. The plan also called for a patch for older versions that raised the lock limit to 537,000, but BIP 50 does not mark that item as done. The alert system gained an option that runs a command when an alert applies to a node, and test alerts were scheduled weekly on testnet.
