---
id: history.bip66-chain-fork
slug: bip66-chain-fork
language: en
date: 2015-07-04
title: BIP 66 Chain Fork of July 2015
category: security
summary: Miners who did not fully validate blocks built on an invalid block in July 2015, which produced short forks while BIP 66 was taking effect.
tags:
  - Fork
  - BIP 66
  - SPV mining
  - Soft fork
sources:
  - title: "BIP 66: Strict DER signatures"
    url: https://github.com/bitcoin/bips/blob/master/bip-0066.mediawiki
    author: Pieter Wuille
    publishedAt: 2015-01-10
  - title: Some Miners Generating Invalid Blocks
    url: https://bitcoin.org/en/alert/2015-07-04-spv-mining
    author: Bitcoin.org
    publishedAt: 2015-07-04
related:
  - wiki.consensus-rules
  - wiki.ecdsa
  - wiki.soft-fork-signalling
  - wiki.spv-and-pruning
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## What happened

Once 950 of the last 1,000 blocks were version 3, upgraded miners would reject version 2 blocks. Early on 4 July 2015 that 95% threshold was reached. Shortly afterwards a small miner that had not upgraded mined an invalid block. About half of the network hash rate was doing SPV mining, which means mining without fully validating blocks, and that half built new blocks on top of the invalid one.

## Why it happened

BIP 66 is a soft fork that requires signatures to use strict DER encoding. Some miners had said they would enforce the rule, but they did not check blocks themselves, so they accepted the invalid block. Software that assumes blocks are valid, such as SPV wallets and older versions of Bitcoin Core, could show transactions as confirmed when they were not. Bitcoin Core 0.9.4 and earlier did not know the BIP 66 rules and could not reject these blocks, while 0.9.5 and later could.

## How it was resolved

The recommended fix was to return miners to full validation, at least for a time. The alert told pool miners to switch to a pool that validates blocks properly, and solo miners to run Bitcoin Core 0.10.2. Wallet users were advised to wait about 30 extra confirmations, and the alert said that Bitcoin.org would lower that recommendation once miners returned to full validation. Later updates reported a further fork starting on 5 July and stated that the situation was not fully resolved, so the advice to wait stayed in place.
