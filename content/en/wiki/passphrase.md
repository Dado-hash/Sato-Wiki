---
id: wiki.passphrase
slug: passphrase
language: en
category: privacy-security
title: Passphrase (BIP 39)
description: The optional BIP 39 passphrase, which is mixed into seed derivation so that each passphrase yields a different valid wallet, with what it protects, what it does not, and its pitfalls.
difficulty: advanced
readTimeMinutes: 5
tags:
  - Passphrase
  - BIP 39
  - Seeds
  - Backups
related:
  - wiki.wallet-seeds
  - wiki.seed-backups
  - wiki.hardware-wallets
  - wiki.physical-attacks
sources:
  - title: "BIP 39: Mnemonic code for generating deterministic keys"
    url: https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki
  - title: Seed phrase
    url: https://en.bitcoin.it/wiki/Seed_phrase
    author: Bitcoin Wiki contributors
  - title: Securing your wallet
    url: https://en.bitcoin.it/wiki/Securing_your_wallet
    author: Bitcoin Wiki contributors
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

The BIP 39 passphrase is an optional text that you add to the seed words. It is often called the 25th word, although it is not a word from the list. It can be any text the user chooses. When a passphrase is used, the wallet derives its keys from both the seed and the passphrase. The same seed words with no passphrase, or with a different one, lead to different keys, and the wallet built from them can be empty.

The protection is simple to describe. Someone who finds a seed backup does not automatically get the funds, because the passphrase is also needed. The Bitcoin Wiki gives the same warning: a seed that is not also protected by a secret passphrase lets anyone who finds it take the bitcoin.

The passphrase has a cost. It must be remembered or backed up separately, and it must be recorded exactly. If it is lost, the funds behind it cannot be recovered, even with the seed. The wallet does not tell you when the passphrase is wrong. The next levels explain how the derivation works and why that matters.

## medium

The derivation is defined in BIP 39. The mnemonic words are the password for PBKDF2 with HMAC-SHA512, and the salt is the string "mnemonic" followed by the passphrase. The function runs 2048 iterations and outputs 512 bits. The passphrase therefore changes the whole seed, and so every key that the wallet derives from it.

A passphrase has no checksum. Any passphrase produces a valid seed, so a wrong passphrase gives a valid wallet that happens to be empty, and the software cannot say that the passphrase is incorrect. The specification calls this plausible deniability. It means that a passphrase can hide a holding, and it also means that a typing error looks exactly like an empty wallet.

What the passphrase protects is the seed on its own. A found or stolen backup gives the finder the words but not the keys behind the passphrase. It also makes guessing harder, because each guess requires a full derivation and a check of the result. It does not protect against loss of the passphrase, malware that sees it when it is typed, or someone who forces its owner to reveal it. It also cannot replace the seed. Without the words, the passphrase alone recovers nothing.

A passphrase is not the same as a device PIN. A PIN is an access code that the device checks. The passphrase is an input to key derivation. Any limit on attempts applies only to tries made through the device, not to someone who has the seed and tests passphrases on their own computer. The passphrase is also separate from the password that encrypts a wallet file on disk. The Bitcoin Wiki notes that some wallets call it an extension word for this reason.

Keeping the passphrase safe requires its own plan. Writing it beside the seed defeats the point of having it. Storing it in a separate place keeps the two secrets apart, but then both must be kept and found together when a restore is needed.

## advanced

The derivation uses NFKD normalisation. BIP 39 requires the mnemonic and the passphrase to be converted to UTF-8 in NFKD form before they are used. The effect is that strings which look the same, but are encoded differently, produce the same seed. An accented letter typed as one character and as a base letter followed by a combining mark is one example. Some characters are also rewritten by the normalisation, so a passphrase typed with compatibility forms can match an ASCII version of the same text. The normalisation does not change capital letters, so "Abc" and "abc" are different passphrases. Spaces count as characters too.

The normalisation is a pitfall for implementers and for users. A wallet that does not apply NFKD as the specification requires can derive a different seed from the same text, and a restore on that wallet then shows an empty balance without any warning. A user who changes keyboard layout or copies a passphrase from a document may also produce characters that differ from the original. A restore fails silently in both cases, so the restore should be tested on the same software that will be used later.

Strength matters because of who can test guesses. An attacker who holds the seed words can derive the keys for any candidate passphrase on their own hardware, without the original device, and check whether the derived addresses hold funds. The 2048 iterations of PBKDF2 are a fixed cost and do not change the outcome much. A short or common passphrase is therefore the weak point. The Bitcoin Wiki's advice to protect the seed with a secret passphrase assumes that the passphrase is secret and hard to guess.

Memory is a practical limit. The Bitcoin Wiki warns against overestimating one's memory for a passphrase, particularly when it is used rarely. A passphrase that is written down must be kept somewhere else than the seed, and it should be checked on a test restore before the funds are moved into the wallet. A passphrase that is typed into a device is also exposed to whatever software reads that device, so the place where it is entered is part of the threat model.

The BIP 39 checksum covers the words only, so a mistyped word can be detected but a mistyped passphrase cannot. A restore that uses a passphrase should therefore be checked against addresses known in advance before any large transfer. The passphrase is a strong tool only when its owner understands these limits.
