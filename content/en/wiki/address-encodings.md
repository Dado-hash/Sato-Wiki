---
id: wiki.address-encodings
slug: address-encodings
language: en
category: cryptography
title: Base58Check, Bech32 and Bech32m
description: The checksummed encodings behind Bitcoin addresses, how each one catches typing errors, and which address types use which encoding.
coverImage: media/wiki/address-encodings/address-encodings-hero.svg
difficulty: advanced
readTimeMinutes: 4
tags:
  - Base58Check
  - Bech32
  - Bech32m
  - Addresses
  - Checksums
related:
  - wiki.bitcoin-addresses
  - wiki.segregated-witness
  - wiki.taproot
  - wiki.hash-functions
  - wiki.public-keys
sources:
  - title: "BIP 13: Address Format for pay-to-script-hash"
    url: https://github.com/bitcoin/bips/blob/master/bip-0013.mediawiki
  - title: "BIP 173: Base32 address format for native v0-16 witness outputs"
    url: https://github.com/bitcoin/bips/blob/master/bip-0173.mediawiki
  - title: "BIP 350: Bech32m format for v1+ witness addresses"
    url: https://github.com/bitcoin/bips/blob/master/bip-0350.mediawiki
  - title: Base58Check encoding
    url: https://en.bitcoin.it/wiki/Base58Check_encoding
    author: Bitcoin Wiki contributors
  - title: Bech32(m)
    url: https://bitcoinops.org/en/topics/bech32/
    author: Bitcoin Optech
  - title: Bitcoin Core chain parameters (src/kernel/chainparams.cpp)
    url: https://github.com/bitcoin/bitcoin/blob/master/src/kernel/chainparams.cpp
    author: Bitcoin Core contributors
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

An address is a short string that encodes a hash, a type or network prefix, and a checksum. The checksum exists so that a mistyped character is caught before money is sent to the wrong place. Bitcoin uses three encodings: Base58Check for legacy addresses, Bech32 for SegWit version 0, and Bech32m for Taproot and later witness versions.

Base58Check uses 58 characters and leaves out 0, O, I and l, which look alike in many fonts. A version byte comes before the payload, and a four-byte checksum from a double SHA-256 hash comes after it. Mainnet pay-to-public-key-hash addresses begin with 1, and pay-to-script-hash addresses begin with 3.

Bech32 uses 32 lowercase letters and digits, and it does not mix cases. A string has three parts: a human-readable part such as bc, a separator that is always the digit 1, and a data part whose last six characters are the checksum. Because the text is alphanumeric, Bech32 fits better in QR codes.

The Bech32 checksum detects any error that affects at most four characters. Bech32m uses the same structure with a different checksum constant, and it is required for witness version 1 and later. A string valid in one encoding is not valid in the other.

## medium

Base58Check begins with a version byte, such as 0x00 for mainnet pay-to-public-key-hash. A checksum made from the first four bytes of a double SHA-256 hash of the version and payload is appended, and the result is written in base 58. Each leading zero byte becomes a leading 1, so the leading zeros survive the conversion. BIP 13 specified pay-to-script-hash addresses in this format, using version 0x05, which begin with 3.

Bech32 has a human-readable part of one to 83 characters, a separator 1, and a data part of at least six characters. The whole string is at most 90 characters. The alphabet is qpzry9x8gf2tvdw0s3jn54khce6mua7l, which has 32 symbols, and it excludes 1, b, i and o from the data part. The checksum is six characters, computed over the expanded human-readable part and the data values.

Case has rules. Encoders must output an all-lowercase string, and decoders must reject strings that mix uppercase and lowercase letters. Uppercase is allowed for presentation or QR codes, but it is produced by converting the finished lowercase string, not by mixing cases.

Bech32m replaces the checksum constant with 0x2bc830a3 in place of 1, and the rest of the encoding is unchanged. Version 0 uses Bech32 and versions 1 through 16 use Bech32m. Version 0 addresses keep Bech32 for compatibility with existing P2WPKH and P2WSH outputs. A decoder accepts a string only if the checksum matches the constant for its witness version.

Which encoding an address uses follows from its type. Pay-to-public-key-hash and pay-to-script-hash addresses, including nested SegWit addresses that wrap a SegWit program in a P2SH output, use Base58Check. Native P2WPKH and P2WSH addresses use Bech32. Pay-to-taproot addresses use Bech32m, because they are witness version 1. The encoding only wraps the payload; the spending rules come from the output script.

## advanced

The Bech32 checksum has a stated guarantee. BIP 173 says the BCH code detects any error affecting at most four characters, and that it can also correct some errors. Correction changes some invalid strings into valid ones, so it weakens detection when many errors occur. The design goal was detection of the small numbers of errors that typing and reading produce.

Bech32 has an insertion weakness, which BIP 350 documents. When the final character of the string is p, inserting or deleting any number of q characters immediately before it does not invalidate the checksum. BIP 350 says this does not affect existing version 0 addresses, and it introduces Bech32m to mitigate this weakness and related issues for version 1 and later.

BIP 350 also explains why version 0 does not accept both encodings. Accepting both would reduce the effective checksum strength to the equivalent of about 29 bits, because a string could be read under either constant. A decoder therefore tries both constants and then applies the version rule, so a string is never accepted under the wrong encoding.

Witness addresses have further rules after the checksum passes. The witness version must be from 0 to 16, and the program must be between 2 and 40 bytes. Version 0 programs must be exactly 20 or 32 bytes, which distinguish P2WPKH from P2WSH. These checks stop a valid checksum from wrapping a program that is not allowed for its version.

Base58Check is weaker for transcription. According to BIP 173, its double SHA-256 checksum has no error-detection guarantee. Its alphabet avoids some confusing characters, but it is case-sensitive and cannot use the alphanumeric mode of QR codes, which is why BIP 173 describes Base58 as costly in QR codes.

Wallets that accept user input should validate the checksum and the witness rules before treating an address as correct. They should reject mixed case instead of normalizing it silently.

Encoding does not change what an address controls. The payload is still a hash, a key or a witness program. The encoding only changes how that payload is written and checked, so the same spending rules apply whichever encoding the output uses. A wallet can accept old and new formats side by side while the chain validates each output by its script.
