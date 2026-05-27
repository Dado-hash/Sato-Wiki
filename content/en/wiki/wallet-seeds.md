---
id: wiki.wallet-seeds
slug: wallet-seeds
language: en
category: cryptography
title: Wallet Seeds
description: The human-readable mnemonic phrases that encode the entropy needed to deterministically generate all keys in a Bitcoin wallet.
coverImage: media/wiki/wallet-seeds/wallet-seed-flow.svg
difficulty: advanced
readTimeMinutes: 8
tags:
  - Cryptography
  - Seeds
  - Wallets
  - BIP 39
related:
  - wiki.hd-wallets
  - wiki.private-keys
  - wiki.bitcoin-addresses
  - wiki.public-keys
sources:
  - title: "BIP 39 — Mnemonic code for generating deterministic keys"
    url: https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki
    author: Marek Palatinus, Pavol Rusnak, Aaron Voisine, Sean Bowe
  - title: "BIP 32 — Hierarchical Deterministic Wallets"
    url: https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki
    author: Pieter Wuille
  - title: "Mastering Bitcoin - Chapter 4"
    url: https://github.com/bitcoinbook/bitcoinbook/blob/develop/ch04.asciidoc
    author: Andreas M. Antonopoulos
updatedAt: 2026-05-27T00:00:00Z
---

## base

A wallet seed is a sequence of words — typically 12 or 24 — that can generate every key in a Bitcoin wallet. This is the "master key" you write down when setting up a wallet. If you lose your phone or computer, the seed words are all you need to restore access to your bitcoin.

The seed is generated once by your wallet using a source of randomness (entropy). These random bits are split into groups and mapped to words from the BIP 39 wordlist — a carefully curated list of 2048 common English words. The word sequence is then processed through a key-stretching function called PBKDF2 to produce a 512-bit master seed.

The system is hierarchical and deterministic. "Deterministic" means the same seed always produces the same sequence of keys. "Hierarchical" means keys are organized in a tree structure, with different branches for different purposes (receiving, change, different cryptocurrencies). This one-to-many relationship between a seed and all its descendant keys is what makes wallet backup so simple.

![Wallet seed generation from entropy to master seed](media/wiki/wallet-seeds/wallet-seed-flow.svg "Random entropy is encoded into a mnemonic phrase via BIP 39, then stretched into a 512-bit master seed via PBKDF2.")

## medium

BIP 39 defines the mnemonic code standard. The process has three steps:

**Step 1: Generate entropy.** The wallet generates ENT random bits using a cryptographically secure random number generator (CSPRNG). Standard entropy sizes:
- 128 bits → 12-word mnemonic
- 192 bits → 18-word mnemonic  
- 256 bits → 24-word mnemonic

**Step 2: Compute checksum.** A SHA-256 hash of the entropy provides CS = ENT/32 checksum bits. These bits are appended to the entropy.

**Step 3: Encode to words.** The combined bit string (ENT + CS) is split into 11-bit segments. Each segment is an index into the BIP 39 wordlist (0-2047). Each index maps to one word from the list.

The mnemonic sentence is then processed by PBKDF2 with HMAC-SHA512:
```
seed = PBKDF2(mnemonic, "mnemonic" + passphrase, iterations = 2048, dklen = 512)
```

The optional passphrase adds an additional security layer. The same mnemonic with a different passphrase produces a completely different seed. This is sometimes called a "thirteenth word" or "twenty-fifth word."

## advanced

**Entropy and security.** A 128-bit entropy seed provides 128 bits of security against brute-force attacks. This is considered sufficient for all practical purposes: 2¹²⁸ operations is astronomically large, exceeding the combined computing power of all human-made devices. Even 2⁸⁰ operations is currently considered infeasible for a well-funded adversary. The effective security is somewhat lower because mnemonic sentences represent a known structure, but with 2048¹² ≈ 2¹³² possible 12-word phrases, the margin remains generous.

**Wordlist properties.** The BIP 39 wordlist (available in English, Japanese, Korean, Spanish, French, Italian, Czech, Portuguese, and Chinese) was chosen with specific properties:
- Each word is 4-8 characters long
- The first 4 characters uniquely identify each word (prefix code)
- Words are selected for ease of pronunciation and resistance to transcription errors
- The list avoids similar-sounding or similar-looking word pairs

**Vulnerability of physical seeds.** Since the seed is the single point of failure for a wallet, its storage is critical. Common approaches:
- **Paper backups**: written down and stored in a safe
- **Metal backups**: engraved on stainless steel (fireproof, waterproof)
- **Shamir's Secret Sharing (SLIP 39)**: split the seed into multiple shares. M-of-N recovery requires M shares, providing redundancy and security separation
- **Multi-signature**: distribute keys across multiple devices, each with its own seed

**SLIP 39 (Shamir's Secret Sharing).** An alternative to BIP 39 that uses Shamir's Secret Sharing to split the master secret into multiple shares. For example, a 2-of-3 scheme requires any 2 out of 3 shares to recover the wallet. This eliminates the single-point-of-failure problem of BIP 39 seeds. SLIP 39 also includes a backup group structure: shares can be organized into groups, each with its own threshold.

**BIP 39 passphrase attacks.** The passphrase is not checked for correctness during wallet restoration. An incorrect passphrase produces valid keys — they just access an empty wallet. Attackers who discover a mnemonic must brute-force the passphrase if one was used. The PBKDF2 cost (2048 iterations) adds marginal protection against this, but hardware wallet implementations enforce rate limiting on passphrase attempts.

**Compared to BIP 32 raw seeds.** Before BIP 39, some wallets just backed up the raw 256-bit master private key in hexadecimal or WIF format. BIP 39 improved usability by encoding entropy into memorable words with built-in checksum verification, reducing the risk of transcription errors during backup.
