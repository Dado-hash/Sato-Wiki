---
id: history.mtgox-collapse
slug: mtgox-collapse
language: en
date: 2014-02-01
title: Mt. Gox Collapse
category: security
summary: Mt. Gox, the world's largest Bitcoin exchange, files for bankruptcy after losing approximately 850,000 BTC due to security breaches and mismanagement.
tags:
  - Bitcoin
  - Mt. Gox
  - Exchange
  - Security
  - Bankruptcy
related:
  - id: wiki.private-keys
    title: Private Keys
  - id: wiki.transactions
    title: Bitcoin Transactions
  - id: wiki.volatility
    title: Volatility
  - id: wiki.full-nodes
    title: Full Nodes
sources:
  - title: The inside story of Mt. Gox — Wired
    url: https://www.wired.com/2014/03/bitcoin-exchange/
    author: Robert McMillan
    publishedAt: 2014-03-03
  - title: Mt. Gox files for bankruptcy — BBC
    url: https://www.bbc.com/news/technology-26400932
    author: BBC News
    publishedAt: 2014-02-28
  - title: The collapse of Mt. Gox — The New York Times
    url: https://www.nytimes.com/2014/02/28/technology/mt-gox-files-for-bankruptcy.html
    author: Nathaniel Popper
    publishedAt: 2014-02-28
updatedAt: 2026-05-28T00:00:00Z
---

In February 2014, Mt. Gox — once handling over 70% of all Bitcoin trades worldwide — collapsed in spectacular fashion. The exchange revealed that it had lost approximately 850,000 bitcoin, worth over $450 million at the time, due to a combination of security breaches, software bugs, and gross mismanagement. The collapse was the single most catastrophic event in Bitcoin's history up to that point and remains one of the largest financial frauds ever recorded.
![Mt. Gox logo](media/history/mtgox-collapse/mtgox-collapse-logo.webp "The Mt. Gox logo, once the dominant Bitcoin exchange, now a cautionary tale.")


## The Years of Neglect

The seeds of Mt. Gox's failure were planted long before the collapse. After Mark Karpelès acquired the exchange in 2011, he struggled to maintain and improve the platform's security. The exchange's codebase was a patchwork of undocumented modifications, its wallet management was primitive, and it lacked basic security auditing.

The core technical problem was transaction malleability. Bitcoin's ECDSA signatures could be mutated by a third party without invalidating them, producing a different transaction ID. Mt. Gox's withdrawal system checked whether a transaction had been confirmed by monitoring its TXID. When an attacker mutated a withdrawal transaction, the new TXID would not match what Mt. Gox was monitoring, and the exchange's automated systems would interpret this as a failed withdrawal — and issue a new payment. This allowed attackers to drain funds from the exchange repeatedly.

## The Leak

Over several years, attackers exploited these vulnerabilities to steal approximately 850,000 BTC from Mt. Gox. Approximately 200,000 of those coins were eventually recovered, but 650,000 — worth billions of dollars at current prices — were never recovered. The theft went undetected by Mt. Gox's management for years, partly due to their failure to reconcile hot wallet balances against exchange liabilities.

In late 2013, when Mt. Gox finally attempted to reconcile its accounts, it discovered massive discrepancies. The exchange suspended withdrawals in February 2014, citing "technical issues." On February 28, Mt. Gox filed for bankruptcy protection in Japan and the United States, revealing the full extent of the losses.

## The Aftermath

The Mt. Gox collapse had devastating effects on the Bitcoin ecosystem. The price of bitcoin fell from approximately $800 to $400 in the weeks following the announcement. Many users lost their life savings. Trust in cryptocurrency exchanges was severely damaged, and the event triggered calls for regulation of the industry.

For the Bitcoin community, the collapse was a painful lesson in the importance of security and the risks of centralized services. The phrase "not your keys, not your coins" became central to Bitcoin philosophy. The event also accelerated the development of better wallet technology, including hardware wallets, multisignature schemes, and improved exchange security practices.

## Legal Proceedings

Mark Karpelès was arrested in Japan in 2015 and charged with embezzlement and data manipulation. After a lengthy trial, he was found guilty in 2019 of manipulating exchange data but acquitted of embezzlement. He received a suspended sentence.

The bankruptcy proceedings for Mt. Gox have been ongoing for over a decade. In 2024, the trustee began distributing recovered assets to creditors, who received approximately 15-20% of their original claims in bitcoin and bitcoin cash. The final chapter of the Mt. Gox saga was still being written more than ten years after the collapse.

## Long-Term Impact

Despite the devastation, the Bitcoin network itself was never compromised. The Mt. Gox collapse was a failure of a centralized service, not of the underlying protocol. This distinction was crucial: Bitcoin's blockchain continued operating normally throughout the crisis, processing transactions every 10 minutes without interruption.

The collapse led to significant improvements in the cryptocurrency ecosystem. Exchanges implemented cold storage, multi-signature wallets, regular audits, and insurance. Developers deployed Segregated Witness in 2017, which fixed the transaction malleability issue at the protocol level. The lessons of Mt. Gox shaped the development of the entire industry.

