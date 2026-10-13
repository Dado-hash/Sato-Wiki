---
id: wiki.seed-backups
slug: seed-backups
language: en
category: hardware
subcategory: seed-backups
title: Seed Backups
description: How people back up a BIP 39 seed phrase on paper, metal, or split shares, and where those backups usually fail.
difficulty: base
readTimeMinutes: 5
tags:
  - Seed Backup
  - BIP 39
  - SLIP 39
  - Multisig
  - Recovery
related:
  - wiki.wallet-seeds
  - wiki.hd-wallets
  - wiki.multisig
  - wiki.private-keys
  - wiki.hardware-wallets
sources:
  - title: "BIP 39 - Mnemonic code for generating deterministic keys"
    url: https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki
    author: Marek Palatinus, Pavol Rusnak, Aaron Voisine, Sean Bowe
  - title: "SLIP-0039 - Shamir's Secret-Sharing for Mnemonic Codes"
    url: https://github.com/satoshilabs/slips/blob/master/slip-0039.md
    author: SatoshiLabs
  - title: Codex32
    url: https://bitcoinops.org/en/topics/codex32/
    author: Bitcoin Optech contributors
  - title: Bitcoin.org - Secure your wallet
    url: https://bitcoin.org/en/secure-your-wallet
    author: Bitcoin.org contributors
  - title: "Mastering Bitcoin - Chapter 5, Wallets"
    url: https://github.com/bitcoinbook/bitcoinbook/blob/develop/ch05_wallets.adoc
    author: Andreas M. Antonopoulos
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

A seed backup is the written copy of the words that can rebuild a wallet. For most wallets it is a list of 12 or 24 words from the BIP 39 wordlist. Anyone who has those words, and the passphrase if one was used, can restore every key the wallet has created, so the backup is as sensitive as the money it protects.

Most people start with paper. Paper is cheap and easy to read, but it can burn, get wet, fade, or be lost during a move. Metal plates are a common upgrade because they tolerate fire, water and corrosion better than paper. In both cases the backup should sit in a private, dry place, and it helps to check it from time to time, because a backup that was never checked may be unreadable when it is needed.

Never store a seed in digital form. A text file, a photo, a note app, an email draft or a cloud drive can be copied, synced or read by someone else. The seed should exist only as physical words that you write yourself and keep offline. The medium level covers ways to split a backup and why some methods are weaker than they look.

## medium

The first choice is the medium: paper, engraved metal, or both. Paper records are simple, but they degrade. Metal plates are designed to resist heat, water and corrosion, yet they still need a safe place, because anyone who sees the words can use them. Many people keep two copies in different locations, so that one event such as a flood or a fire does not destroy every copy.

The second choice is whether to split the secret. Writing the words on separate cards, for example the first half on one card and the second half on another, does not give threshold protection. Each piece is a usable part of the secret, so anyone who finds one piece has a head start. Shamir's Secret Sharing works differently. It splits the secret into shares, and fewer shares than the threshold reveal nothing about it. SLIP-0039 standardizes this approach for wallet backups. Shares are written as word lists with a checksum that detects errors. In a 2-of-3 scheme, any two of the three shares recover the secret.

Multisig is a third option. Instead of one seed that must be protected, the wallet requires signatures from several keys, each on its own device or seed. Losing one seed does not lose the funds if the threshold can still be met. Multisig adds complexity, though. The wallet setup must be recorded, and recovery depends on every key holder keeping their part.

A passphrase adds a second secret. It must be hard to guess, and it needs its own backup, stored apart from the seed. A lost passphrase makes the funds unrecoverable, and a passphrase written beside the seed offers no protection against someone who finds both.

Backups fail in ordinary ways: a copy is lost in a move, a family member cannot find it when needed, a photo syncs to a cloud account, or a word is misread because the handwriting is unclear.

## advanced

A seed backup is a single point of failure, so its design balances three risks: losing the secret, letting someone else find it, and making recovery too hard to carry out.

Physical durability is the first layer. Paper can fail from water, heat, light and handling, and anyone who finds it can read it. Metal resists heat and water better, but engraved or stamped words still reveal the seed to whoever sees them. Bitcoin.org advises keeping backups in more than one location, so that no single event can remove access, and it warns that any backup stored online is highly vulnerable to theft.

Threshold schemes address the single point of failure in a different way. Shamir's Secret Sharing splits a secret so that a threshold of shares is needed to rebuild it. SLIP-0039 defines a two-level structure: the master secret is split into group shares, and each group share is split again among its members. This allows uneven trust, for example a family member holding one share and a lawyer holding another. Shares are written as 20 or 33 words from a 1,024-word list, and the last three words are a checksum that detects errors in up to three words. Codex32 is a related encoding for BIP 32 seeds, which Bitcoin Optech describes as convenient to store on paper. Both schemes trade simplicity for resilience. The procedure is longer, and a mistake in one share can make recovery harder, so the process should be rehearsed before it is needed.

Multisig moves the backup problem to the wallet level. Each key is held on its own device or seed, and spending requires a threshold of signatures. A compromised key does not reveal the others. The cost is that the wallet's setup information must be kept, and that recovery depends on compatible software.

The passphrase is a second secret, not a checksum. A wrong passphrase during restore produces another valid wallet, and the software cannot say that the passphrase is incorrect. It should be strong, and it must be backed up separately, because losing it makes the funds unrecoverable. Storing it with the seed removes its protection against anyone who finds the backup.

The BIP 39 checksum catches many transcription errors, but it does not catch every mistake, so a careful check of the written words after writing them is worth the time.
