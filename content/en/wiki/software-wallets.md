---
id: wiki.software-wallets
slug: software-wallets
language: en
category: software
subcategory: software-wallets
title: Software Wallets
description: Desktop and mobile wallet programs, what they actually store, and how their choices about custody, servers and backups change privacy and risk.
difficulty: base
readTimeMinutes: 6
tags:
  - Wallets
  - Software
  - Privacy
  - Backups
related:
  - wiki.hd-wallets
  - wiki.wallet-seeds
  - wiki.private-keys
  - wiki.hardware-wallets
  - wiki.full-nodes
sources:
  - title: Developer Guide - Wallets
    url: https://developer.bitcoin.org/devguide/wallets.html
    author: Bitcoin.org contributors
  - title: "BIP 174: Partially Signed Bitcoin Transaction Format"
    url: https://github.com/bitcoin/bips/blob/master/bip-0174.mediawiki
    author: Ava Chow
  - title: Electrum documentation - Frequently Asked Questions
    url: https://electrum.readthedocs.io/en/latest/faq.html
    author: Electrum developers
  - title: Compact block filters
    url: https://bitcoinops.org/en/topics/compact-block-filters/
    author: Bitcoin Optech
  - title: Reproducible builds
    url: https://bitcoinops.org/en/topics/reproducible-builds/
    author: Bitcoin Optech
  - title: Electrum protocol
    url: https://github.com/spesmilo/electrum-protocol
    author: Electrum developers
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

A software wallet is a program on a computer or phone that manages the keys for your bitcoin. The first thing to understand is that a wallet does not hold coins. Bitcoin exists as unspent outputs recorded on the blockchain. The wallet stores the private keys that can sign spending of those outputs, and it uses them to build and sign transactions.

Most software wallets run on devices connected to the internet, which makes them convenient for everyday payments. Some are non-custodial, so only you hold the keys. Others are custodial, where a company holds the keys and you have a claim against that company. The difference decides who can move your funds and what happens if the provider fails. Non-custodial software gives you control, but also responsibility: if you lose the seed and the device, nobody can restore the funds for you.

Keep your seed backup offline and private, and check that the wallet can restore from it before you rely on the wallet. A wallet on a phone or laptop is a hot wallet. Its keys sit on a device that is online, which exposes them more than keys kept on a device that never connects.

## medium

A wallet has to learn its balance, and the way it does that decides how much it reveals. The most private option is to connect the wallet to your own full node, which you query directly. Many wallets instead connect to a server that answers on their behalf. An Electrum-style server receives the addresses your wallet cares about, and it can reasonably guess that those addresses belong to the same person. The Electrum FAQ says that the server is trusted about unconfirmed transactions and can lie by omission, which means it can leave out transactions that matter to you. A third-party server therefore costs privacy and some trust, even when the wallet checks confirmed transactions against block headers.

Compact block filters, specified in BIP 157 and BIP 158, offer another model. The wallet downloads a filter for each block, checks it locally, and fetches only the blocks that may contain its transactions. Compared with address-based servers, this gives more privacy and needs less server storage, but it uses more bandwidth in the normal case.

Backups are a separate question. A seed backup restores the keys that the wallet derives from it. Before you depend on a wallet, test a restore on a second device, and check whether the program needs anything beyond the seed to show your full history.

Wallets can also split their work. A watch-only wallet knows the public side of your addresses and can follow the balance without any signing key. A signing device, such as a hardware wallet or an offline program, holds the private keys and signs transactions that the watch-only wallet prepares. Partially Signed Bitcoin Transactions (PSBT, BIP 174) are the usual format for passing these transactions back and forth, because they carry the signing information without giving the online side the keys.

Open source code and reproducible builds let you check a wallet. You can compare the published binary with a build made from the source, and you can review how the program handles keys.

## advanced

A software wallet combines three jobs that can be separated: deciding which public keys to hand out, signing transactions, and talking to the peer-to-peer network. The Bitcoin developer guide calls the simplest form a full-service wallet, which does all three on one device. Its advantage is that it is easy to use. Its disadvantage is that the private keys sit on a machine that is connected to the internet, where a compromise can leak them. Encrypting the wallet file protects the keys at rest, but it does not defend against malware that captures the encryption key or reads decrypted keys from memory.

Splitting the jobs reduces that exposure. A networked wallet monitors outputs, builds unsigned transactions and broadcasts signed ones. A signing-only wallet, often an offline program or a hardware device, holds the parent private key and signs what it is shown. The developer guide notes that the signing side is often given a chance to review the output details before it signs.

Privacy depends on how the wallet learns about its own transactions. Light-client methods differ in what they reveal. Bloom filters, the older approach from BIP 37, have the wallet send a filter to a node and let the node match transactions against it. Bitcoin Optech's comparison says that compact block filters give more privacy against spy nodes than BIP 37 bloom filters, because the matching happens on the wallet side. Address-indexed servers learn the addresses directly, and a user who reuses addresses gives them a long history to link together. Wallets that use a third-party server should be read with this trade-off in mind.

PSBT is the common container that connects a networked wallet to signing devices. The format was designed so that an offline signer can sign without direct access to the UTXO set and without the risk of being defrauded about the transaction. A signer must also pass through unknown fields it does not understand, which lets newer tools add data without breaking older ones.

Reproducible builds apply to wallets as well. When a wallet is compiled deterministically, several people can build the same source and get identical binaries, so an update does not depend on the trust of one build machine. Electrum's documentation also notes that a wallet can be recovered entirely from its seed, which makes the seed the critical backup. Its security depends on how the seed is generated, stored and restored, not on the app alone.
