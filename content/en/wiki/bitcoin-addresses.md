---
id: wiki.bitcoin-addresses
slug: bitcoin-addresses
language: en
category: cryptography
title: Bitcoin Addresses
description: The alphanumeric identifiers that represent destinations for bitcoin payments, derived from public keys through hashing and encoding.
coverImage: media/wiki/bitcoin-addresses/address-derivation.svg
difficulty: advanced
readTimeMinutes: 8
tags:
  - Cryptography
  - Addresses
  - Wallets
  - Encoding
related:
  - wiki.public-keys
  - wiki.private-keys
  - wiki.segregated-witness
  - wiki.taproot
  - wiki.ecdsa
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: "Mastering Bitcoin - Chapter 4"
    url: https://github.com/bitcoinbook/bitcoinbook/blob/develop/ch04.asciidoc
    author: Andreas M. Antonopoulos
  - title: "BIP 173 — Bech32 Address Format"
    url: https://github.com/bitcoin/bips/blob/master/bip-0173.mediawiki
    author: Pieter Wuille, Greg Maxwell
  - title: "BIP 350 — Bech32m Address Format"
    url: https://github.com/bitcoin/bips/blob/master/bip-0350.mediawiki
    author: Pieter Wuille
updatedAt: 2026-05-27T00:00:00Z
---

## base

A Bitcoin address is an identifier that tells the network where to send bitcoin. It is derived from a public key through a series of cryptographic operations, but it is not the public key itself. Addresses are shorter, easier to share, and include error-detection codes so typos are caught before funds are lost.

The simplest analogy is an email address: you share your email address with others so they can send you messages, but nobody can read your emails with just the address. Similarly, a Bitcoin address lets others send you bitcoin, but they cannot spend your bitcoin with just the address.

An address is created by taking a public key, hashing it twice (SHA-256 then RIPEMD-160), adding a network prefix and a checksum, and encoding the result. The specific encoding determines the address format: legacy addresses start with "1" (Base58Check), SegWit addresses start with "bc1" (Bech32), and Taproot addresses start with "bc1p" (Bech32m).

![Bitcoin address derivation pipeline](media/wiki/bitcoin-addresses/address-derivation.svg "From private key through elliptic curve multiplication, hashing, and encoding to produce the final address.")

## medium

Bitcoin addresses have evolved through several formats, each improving on the previous:

**Legacy (P2PKH).** Pay to Public Key Hash addresses start with "1" and use Base58Check encoding. The hash is RIPEMD-160 of SHA-256 of the public key. A version byte (0x00 for mainnet) is prepended, and a 4-byte double-SHA-256 checksum is appended. Base58 omits similar-looking characters (0, O, I, l) to reduce transcription errors.

**P2SH (Pay to Script Hash).** Addresses starting with "3" use the same Base58Check encoding but hash a redeem script instead of a public key. This enables multisig and other complex spending conditions behind a simple address. P2SH was introduced in BIP 16 (2012).

**Native SegWit (P2WPKH / P2WSH).** Bech32 addresses starting with "bc1" use a different encoding scheme: a human-readable part (hrp = "bc" for mainnet, "tb" for testnet), a separator "1", a data part encoding the witness program, and a 6-character BCH checksum. Bech32 is more efficient (lower transaction fees), case-insensitive, and error-correcting.

**Taproot (P2TR).** Bech32m addresses starting with "bc1p" are the most recent format. They use 32-byte x-only public keys and support both key-path and script-path spending. Bech32m (BIP 350) fixes a weakness in Bech32 that allowed insertion of extraneous characters.

The derivation steps from public key to address:

1. Compute H = RIPEMD160(SHA256(K)) where K is the public key (33 or 65 bytes)
2. Add version byte: network prefix (0x00 for mainnet P2PKH, 0x05 for P2SH)
3. Compute checksum: first 4 bytes of double-SHA-256 of (version || H)
4. Encode in Base58: version || H || checksum, converted to Base58 alphabet

For Bech32 addresses, step 4 is replaced with Bech32 encoding using the segregated witness program (witness version + witness program bytes).

## advanced

**Address collision probability.** A Bitcoin address is 160 bits of hash output. The probability of two different public keys producing the same address is approximately 2⁻¹⁶⁰, or about 1 in 10⁴⁸. Even if every person on Earth generated a billion addresses per second for a century, the collision probability would remain negligible. This is why addresses are considered unique identifiers.

**Base58Check encoding details.** The Base58 alphabet is: `123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz`. The absence of 0, O, I, l reduces visual ambiguity. The encoding process treats the bytes as a big-endian number and converts it to base-58, then prepends "1" characters for each leading zero byte in the original data.

**Bech32 error correction.** Bech32 uses a BCH (Bose-Chaudhuri-Hocquenghem) code over GF(32) that can detect up to 4 errors and correct up to 3 errors within the data part. The checksum guarantees that any substitution error will be detected with overwhelming probability. However, Bech32 has a weakness: inserting or deleting "q" characters can go undetected. Bech32m (BIP 350) fixes this by using a different checksum constant (0x2BC830A3 instead of 0x1).

**Address reuse.** Blockchain analysis tools track addresses. Publicly associating multiple transactions with the same address reveals the ownership cluster. Modern wallets generate a new address for each payment using deterministic key derivation (BIP 32). This is not a protocol rule but a privacy recommendation. Address reuse is technically valid but links transactions on the public ledger.

**x-only public keys in Taproot.** BIP 341 introduced x-only public keys for Taproot addresses: only the x-coordinate of the elliptic curve point is used (32 bytes). The y-coordinate is assumed to be even. This reduces address size and improves efficiency. The corresponding public key cannot be recovered from a Schnorr signature (unlike ECDSA), which is a deliberate trade-off for efficiency.

**Invoice addresses (BIP 21).** Bitcoin addresses are often embedded in a URI format: `bitcoin:address?amount=value&label=text`. This standard allows wallets to generate payment requests with amounts and descriptions. The BIP 21 format is widely supported by wallets and payment processors.
