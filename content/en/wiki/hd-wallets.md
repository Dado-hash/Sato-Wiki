---
id: wiki.hd-wallets
slug: hd-wallets
language: en
category: cryptography
title: Hierarchical Deterministic Wallets
description: A system for deriving a tree of key pairs from a single seed, enabling organized, backup-friendly wallet management.
coverImage: media/wiki/hd-wallets/hd-wallet-tree.svg
difficulty: advanced
readTimeMinutes: 8
tags:
  - Cryptography
  - Wallets
  - HD Wallets
  - BIP 32
  - Key Derivation
related:
  - wiki.wallet-seeds
  - wiki.private-keys
  - wiki.public-keys
  - wiki.bitcoin-addresses
sources:
  - title: "BIP 32 — Hierarchical Deterministic Wallets"
    url: https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki
    author: Pieter Wuille
    publishedAt: 2012-02-11
  - title: "BIP 44 — Multi-Account Hierarchy for Deterministic Wallets"
    url: https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki
    author: Marek Palatinus, Pavol Rusnak
    publishedAt: 2014-04-24
  - title: "Mastering Bitcoin - Chapter 4"
    url: https://github.com/bitcoinbook/bitcoinbook/blob/develop/ch04.asciidoc
    author: Andreas M. Antonopoulos
updatedAt: 2026-05-27T00:00:00Z
---

## base

An HD wallet (Hierarchical Deterministic wallet) is a system that generates all your Bitcoin keys from a single starting point — a seed phrase. Instead of creating each key independently and needing to back them all up, an HD wallet creates a tree of keys, where every key is mathematically derived from the seed.

This is why you can back up a 12-word seed phrase and restore your entire wallet — every address you ever used, on any device, across all cryptocurrencies. The seed acts like the root of a tree. Each branch is a different account or cryptocurrency, and each leaf is a specific address.

HD wallets are defined by BIP 32 and extended by BIP 44, BIP 49, BIP 84, and BIP 86 for different address types. The system uses a derivation path to describe exactly which key in the tree to use, for example `m/44'/0'/0'/0/0` describes the first receiving address in a legacy Bitcoin account.

![HD wallet key derivation tree](media/wiki/hd-wallets/hd-wallet-tree.svg "Master seed generates a key hierarchy with purpose, coin type, account, chain, and address index levels.")

## medium

BIP 32 defines two types of child key derivation:

**Normal derivation.** A parent public key can derive child public keys without needing the parent private key. This property enables "watch-only" wallets and auditor setups where public keys are generated on an online device while private keys stay cold:
```
ChildPublicKey = ParentPublicKey + (HMAC-SHA512(chain_code, pubkey || index) right 32 bytes) × G
```

**Hardened derivation.** Uses the parent private key in the HMAC, preventing an attacker who knows a child private key from reverse-engineering the parent. Hardened paths use index values ≥ 2³¹ (denoted with a prime symbol, e.g., `44'`):
```
ChildPrivateKey = ParentPrivateKey + HMAC-SHA512(chain_code, privkey || index) right 32 bytes
```

The standard derivation path structure (BIP 44) is:
```
m / purpose' / coin_type' / account' / change / address_index
```

Where:
- **purpose**: 44' for legacy, 49' for SegWit wrapped, 84' for native SegWit, 86' for Taproot
- **coin_type**: 0' for Bitcoin, 1' for Testnet
- **account': user-defined account number (hardened)
- **change**: 0 for external (receiving), 1 for internal (change)
- **address_index**: sequential index starting from 0

The extended key formats (xprv/xpub) encode the chain code, depth, parent fingerprint, key index, and the key itself. This allows sharing an entire account's public key tree securely.

## advanced

**Extended key serialization.** BIP 32 extended keys encode a chain code and a key with metadata. The extended public key (xpub) allows deriving all descendant public keys without exposing private keys. The format:
- 4 bytes: version (0x0488B21E for xpub, 0x0488ADE4 for xprv)
- 1 byte: depth (0 for master, 1 for child, etc.)
- 4 bytes: parent fingerprint (first 32 bits of parent's Hash160)
- 4 bytes: child number (index in parent's children)
- 32 bytes: chain code
- 33 bytes: public key or private key data

Total: 78 bytes, typically Base58-encoded into a string starting with "xpub" or "xprv".

**Security considerations.** Hardened derivation exists precisely to contain exposure. If an attacker obtains a normal child private key and its chain code, they can compute the parent chain code and derive all sibling keys. With hardened derivation, this is impossible because the parent private key is mixed into the HMAC input. This is why the first three levels of the BIP 44 path (purpose, coin type, account) use hardened derivation.

**Known weaknesses.** Several properties of BIP 32 require careful implementation:
- xpub reuse: sharing multiple xpubs derived from the same seed allows linking accounts — each xpub leaks the chain code, and cross-account analysis is possible
- Weak entropy: a compromised seed compromises all descendant keys, not just one branch
- Non-hardened child key leakage: if a non-hardened child private key leaks, the parent chain code can reconstruct the parent private key using HMAC-SHA512

**Alternative standards.** Several improvements address BIP 32 limitations:
- **BIP 43**: defines purpose field in derivation path
- **BIP 44**: multi-account wallet structure
- **BIP 48**: multisig HD wallet structure
- **SLIP 0010**: universal seed derivation for multiple cryptocurrencies
- **Described Script (BIP 380-383)**: output script descriptors provide a language for describing HD wallet outputs, including derivation paths and script types

**Watch-only wallets.** Normal derivation enables creating a watch-only wallet: an xpub is imported into a device that can generate receiving addresses and detect incoming payments, but cannot sign transactions. The private keys remain on the cold storage device. This is the architecture used by hardware wallets: the device holds the seed and signs, while a phone app or desktop wallet holds the xpub and constructs transactions.
