---
id: wiki.private-keys
slug: private-keys
language: en
category: cryptography
title: Private Keys
description: The 256-bit secret numbers that authorize Bitcoin spending and are the root of ownership in the system.
coverImage: media/wiki/private-keys/private-key-generation.svg
difficulty: advanced
readTimeMinutes: 8
tags:
  - Cryptography
  - Private Keys
  - Security
  - Wallets
related:
  - wiki.public-keys
  - wiki.digital-signatures
  - wiki.ecdsa
  - wiki.bitcoin-addresses
  - wiki.wallet-seeds
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: "Mastering Bitcoin - Chapter 4"
    url: https://github.com/bitcoinbook/bitcoinbook/blob/develop/ch04.asciidoc
    author: Andreas M. Antonopoulos
  - title: "secp256k1 standard"
    url: https://www.secg.org/sec2-v2.pdf
    author: SECG
updatedAt: 2026-05-27T00:00:00Z
---

## base

A private key is a secret 256-bit number that proves ownership of bitcoin. Whoever knows the key can spend the associated coins. It is generated randomly and must be kept secret at all times.

From the private key, you derive the public key using elliptic curve multiplication, and from the public key you generate addresses. This process is one-way: there is no mathematical operation that can reverse it. Given a public key, you cannot compute the private key.

Think of a private key like the key to a mailbox. Anyone with the key can open the mailbox and take what is inside. The mailbox itself — the address — is public and visible to everyone, but the key is known only to you. The difference is that in Bitcoin, the mailbox can be created from the key, but the key can never be recovered from the mailbox.

![Private key generation and validation](media/wiki/private-keys/private-key-generation.svg "A private key starts from entropy, passes through a cryptographic RNG, and is validated against the secp256k1 curve order.")

## medium

A Bitcoin private key is any number between 0x1 and 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 inclusive. This upper bound is the order n of the secp256k1 elliptic curve, approximately 2^256 — a number so large that it exceeds the estimated number of atoms in the observable universe.

Private keys must be generated using a cryptographically secure random number generator (CSPRNG). Ordinary pseudo-random number generators are not suitable because they produce predictable output if the seed is known. Operating systems provide CSPRNGs through interfaces like `/dev/urandom` on Unix or `CryptGenRandom` on Windows.

In most wallets, the private key is stored in one of several formats:

- **Raw bytes**: 32 bytes of binary data, the native representation used internally by signing code.
- **WIF (Wallet Import Format)**: A Base58Check-encoded string that includes a version prefix and checksum. WIF is the standard way to export and import a single private key between wallets. A mainnet private key in WIF starts with `5` (uncompressed) or `K`/`L` (compressed).
- **Mini private key format**: A compact format used in situations where space is limited, such as physical bitcoin tokens or paper wallets. Mini keys are typically 22 or 30 characters long.

The relationship between a private key and its public key is defined by elliptic curve multiplication over the field of secp256k1. Given private key k, the public key K is computed as K = k * G, where G is the generator point of the curve and multiplication means repeated point addition on the elliptic curve. This operation is computationally easy in one direction but infeasible to reverse — a property called the discrete logarithm problem.

The 256-bit key length provides enormous security margins. A brute-force search of the private key space is completely infeasible with any known or foreseeable technology. Even if all computers on Earth worked in parallel, finding a single key would take many orders of magnitude longer than the age of the universe.

## advanced

**Key generation security.** The quality of a private key depends entirely on the entropy source. Most software wallets rely on the operating system's CSPRNG, which gathers entropy from hardware sources, interrupt timing, and system events. Hardware wallets use dedicated secure elements or true random number generators (TRNGs) built into the chip.

RNG failures have led to real Bitcoin losses. In 2013, a bug in Android's `SecureRandom` class on Java-based devices produced weak private keys from insufficient entropy. Attackers scanned the blockchain for addresses whose public keys could be derived from the predictable RNG state and stole millions of dollars worth of bitcoin. This incident demonstrated that the security model depends not only on the algorithm but on the quality of entropy at generation time.

**WIF format details.** Wallet Import Format encodes a private key as Base58Check with the following structure:

1. A version byte: 0x80 for mainnet, 0xEF for testnet.
2. The 32-byte private key data.
3. An optional 0x01 suffix byte indicating that the corresponding public key should be derived in compressed form.
4. A 4-byte checksum: the first four bytes of SHA256(SHA256(version || key || suffix)).
5. The entire byte string is Base58-encoded.

The presence or absence of the 0x01 suffix determines whether the WIF string starts with `5` (uncompressed, no suffix) or `K`/`L` (compressed, with suffix). Both represent the same private key, but the compressed format produces smaller transactions because the public key is expressed as only the x-coordinate plus a parity bit (33 bytes) instead of both coordinates (65 bytes).

**BIP 38 encrypted keys.** BIP 38 defines a method for encrypting a private key with a passphrase, producing a Base58Check-encoded string starting with `6P`. This allows storing private keys in a portable format that remains secure even if the medium is compromised. Decryption requires both the encrypted key and the passphrase. The encryption uses AES-256-CBC with a key derived from the passphrase through scrypt key derivation.

**HD wallets and key derivation.** In practice, most modern wallets do not manage individual private keys directly. Instead, they implement BIP 32 hierarchical deterministic (HD) wallets. An HD wallet starts from a single seed phrase (typically 12 or 24 words from the BIP 39 wordlist) and derives an entire tree of key pairs from it using a cryptographic hash function. The derivation path determines which key is used, allowing wallets to generate thousands of addresses from one seed without storing each private key separately.

The master private key is computed from the seed using HMAC-SHA512, then child private keys are derived through a process called CKD (Child Key Derivation). Non-hardened derivation allows a public key and a chain code to derive child public keys without access to any private keys — a property used by watch-only wallets and hardware wallets.

**Key space limitations.** The number of valid private keys is not exactly 2^256 but rather n − 1, where n is the order of the secp256k1 curve: 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141. Zero is excluded because the point at infinity multiplied by zero is not a valid public key. The difference between n and 2^256 is approximately 1.57 × 10^21, which is immaterial for security: the key space is effectively infinite for any practical attacker.
