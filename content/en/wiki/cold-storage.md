---
id: wiki.cold-storage
slug: cold-storage
language: en
category: privacy-security
title: Cold Storage
description: Keeping the private keys on a device that never connects to the internet, and how a cold wallet receives payments and signs spends through a watch-only wallet and an unsigned transaction.
coverImage: media/wiki/cold-storage/cold-storage-hero.svg
difficulty: base
readTimeMinutes: 5
tags:
  - Cold Storage
  - Air-gap
  - Offline Signing
  - PSBT
related:
  - wiki.hardware-wallets
  - wiki.seed-backups
  - wiki.psbt
  - wiki.private-keys
sources:
  - title: Cold storage
    url: https://en.bitcoin.it/wiki/Cold_storage
    author: Bitcoin Wiki contributors
  - title: Secure your wallet
    url: https://bitcoin.org/en/secure-your-wallet
    author: Bitcoin.org contributors
  - title: "BIP 174: Partially Signed Bitcoin Transaction Format"
    url: https://github.com/bitcoin/bips/blob/master/bip-0174.mediawiki
    author: Ava Chow
  - title: Developer Guide - Wallets
    url: https://developer.bitcoin.org/devguide/wallets.html
    author: Bitcoin.org contributors
  - title: Partially signed bitcoin transactions (PSBT)
    url: https://bitcoinops.org/en/topics/psbt/
    author: Bitcoin Optech
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

Cold storage keeps the private keys on a device that never connects to the internet. The device that holds the keys is the cold side. The computer or phone that shows balances and broadcasts transactions is the hot side. The idea is that malware or an attacker on the network cannot read the keys, because they never reach a machine that is online. The Bitcoin Wiki describes cold storage as a way to resist theft by hackers and malware, which is why it is often used for large holdings.

A cold wallet can still receive bitcoin. A watch-only wallet on an online computer holds only public keys. It generates receiving addresses and tracks incoming payments, and the offline device never needs to be connected for this.

Spending is the harder part. The online computer builds an unsigned transaction. That transaction moves to the offline device by USB drive, QR code or manual transcription. The offline device signs it, the signed result returns to the online computer, and the online computer broadcasts it. A standard format for this exchange is the PSBT.

The offline device is only as safe as its setup and as careful as the checks you make on it. The next levels cover the remaining risks and compare cold storage with a hardware wallet used every day.

## medium

The setup is the first risk. The Bitcoin Wiki suggests a used laptop or phone from a reputable manufacturer, wiped, kept off the internet, and loaded only with an operating system and wallet software from a USB drive. Wiping may not remove firmware or BIOS threats, and a live operating system may not stop sophisticated malware. The keys should be generated on the offline device, and their backup should be written on paper or metal, as described in the seed backups entry.

An air gap is a physical separation, not a guarantee. The Bitcoin Wiki notes that data can cross an air gap through side channels such as radio, audio, light, magnetic or thermal signals. Keeping the two machines apart and running the offline one on battery reduces that exposure. USB drives are also an attack surface, so the same drive should not carry data back and forth without care.

The signing exchange needs care too. The offline signer should not rely on the online computer for facts about the payment. The PSBT format carries the data that the signer needs, and BIP 174 requires the signer to check that the data matches the outputs it is spending before it signs. The Developer Guide describes signing-only wallets that work with a networked wallet, and an offline wallet is meant to run on a device that connects to no network.

The last check is the address. Malware on the online computer could swap the destination address, so the Bitcoin Wiki advises checking the entire address before signing. The signing device can display the payment details on its own screen, which is the right place to compare them with the address you intended to pay.

Cold storage is therefore a workflow, not only a device. It works best when the setup, the backup and the signing steps all follow the same discipline. The hardware wallets entry describes the daily-use alternative.

## advanced

Cold storage and a hardware wallet solve a similar problem in different ways. A hardware wallet is a signer that keeps keys on a device and shows what it is asked to sign. Some hardware wallets are air-gapped, exchanging data by QR code or microSD card, and that model is the same as the offline workflow above. The practical difference is how often the device is used and how much of the signing process is automated. Bitcoin.org calls hardware wallets the best balance of security and ease of use, which explains why they are common for everyday use, while a device kept in a drawer suits savings that rarely move.

The watch-only side has a trust problem. The wallet that tracks the chain learns the addresses it monitors, so its privacy depends on the node or server it uses, as the software wallets entry explains. If the online computer is compromised, it can show false addresses or build a transaction that pays someone else. The offline signer is the last line of defence, so the review step on the device matters. BIP 174 is written so that the signer needs no data source other than the PSBT itself.

Supply chain risk applies here too. A device bought used, or from an unofficial seller, has an unknown history. The Bitcoin Wiki's suggestion of a reputable maker shows the trade-off: wiping a device is a step, not a proof. Open firmware with reproducible builds allows a user to compare the installed code with the published source. Closed firmware requires trust in the maker's process, which is one reason why the update channel and the verification of updates matter as much as the initial setup.

Cold storage does not protect against the owner's mistakes, such as signing without reading the screen or keeping a backup that was never tested. Multisig can be combined with cold storage. Keys held on several offline devices in separate places mean that no single device, seed or location is enough to spend, which Bitcoin.org describes as a way to reduce a single point of failure.

The workflow has costs. Each spend requires moving data between two machines, and an error in that process can leave a payment unsigned or a transaction incomplete. For coins that change hands often, the extra steps may outweigh the benefit. For funds that rarely move, the extra steps are part of the protection, because the device is seldom exposed.
