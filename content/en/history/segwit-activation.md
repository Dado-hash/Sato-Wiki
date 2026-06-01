---
id: history.segwit-activation
slug: segwit-activation
language: en
date: 2017-08-23
title: SegWit Activation
category: protocol
summary: Segregated Witness activates on Bitcoin mainnet after a user-activated soft fork (UASF), enabling Lightning Network and fixing transaction malleability.
coverImage: media/wiki/history-segwit-activation/history-segwit-activation-hero.svg
sources:
  - title: BIP 148 (UASF)
    url: https://github.com/bitcoin/bips/blob/master/bip-0148.mediawiki
  - title: SegWit Activation Stats
    url: https://segwit.co/
related:
  - wiki.segregated-witness
  - wiki.lightning-network
updatedAt: 2026-05-28T00:00:00Z
---

On August 23, 2017, Segregated Witness (SegWit) activated on the Bitcoin mainnet at block height 481,824. The activation followed months of contentious debate and a novel governance mechanism: the User-Activated Soft Fork (UASF), formalized in BIP 148.

![Chart showing miner signaling percentages during the SegWit UASF activation period in mid-2017.](media/history/segwit-activation/uasf-signaling-chart.webp "SegWit UASF miner signaling chart")

The UASF strategy required full nodes to enforce SegWit signaling by a specific deadline, applying economic pressure on miners to signal support. This approach bypassed the traditional miner-driven activation, demonstrating that Bitcoin's governance ultimately rests with node operators and users. Under this pressure, miners began signaling SegWit readiness, reaching the required 95% activation threshold.

With SegWit activated, Bitcoin gained several critical improvements. Transaction malleability was fixed, enabling robust second-layer protocols. The new block weight system increased effective capacity. Additionally, SegWit's script versioning system paved the way for future upgrades like Taproot.

The activation was a watershed moment for Bitcoin governance, proving that the network could evolve through social consensus even against miner opposition.
