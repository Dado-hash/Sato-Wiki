---
id: wiki.output-descriptors
slug: output-descriptors
language: en
category: protocol
title: Output Descriptors
description: A compact text language that states exactly which output scripts a wallet uses, with the keys, derivation paths and checksum needed to rebuild them.
difficulty: advanced
readTimeMinutes: 4
tags:
  - Descriptors
  - Wallets
  - Backups
  - Miniscript
related:
  - wiki.hd-wallets
  - wiki.wallet-seeds
  - wiki.multisig
  - wiki.bitcoin-addresses
  - wiki.taproot
sources:
  - title: "BIP 380: Output Script Descriptors General Operations"
    url: https://github.com/bitcoin/bips/blob/master/bip-0380.mediawiki
    author: Pieter Wuille
  - title: "BIP 383: Multisig Output Script Descriptors"
    url: https://github.com/bitcoin/bips/blob/master/bip-0383.mediawiki
    author: Pieter Wuille
  - title: "BIP 386: tr() Output Script Descriptors"
    url: https://github.com/bitcoin/bips/blob/master/bip-0386.mediawiki
    author: Pieter Wuille
  - title: Support for Output Descriptors in Bitcoin Core
    url: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md
    author: Bitcoin Core contributors
  - title: Output script descriptors
    url: https://bitcoinops.org/en/topics/output-script-descriptors/
    author: Bitcoin Optech
  - title: "BIP 379: Miniscript"
    url: https://github.com/bitcoin/bips/blob/master/bip-0379.md
    author: Pieter Wuille, Andrew Poelstra, Sanket Kanjalkar, Antoine Poinsot, Ava Chow
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

An output descriptor is a short text string that describes a set of output scripts a wallet can use. It names the script type, the public keys, and where those keys came from. For example, a wpkh() descriptor with one key describes a single-key native segwit output, and the descriptor tells software exactly how to turn that key into a script.

Descriptors matter for backups. A wallet's addresses come from its keys and from a script template. A backup that holds only private keys leaves the restoring program to guess which script types and derivation paths the wallet used. BIP 380 notes that such backups are insufficient, especially since segwit added new output types, and that they cause incompatibilities between wallets.

A descriptor records the template together with the keys, so a restored or watch-only wallet can produce the same addresses. Many descriptors end with a hash sign and an 8-character checksum that detects typing errors. A descriptor that contains private keys is as sensitive as the keys themselves, and a version that contains only public keys is the one a watch-only wallet needs.

## medium

Descriptors are built from script functions. The function name fixes the output type. pkh(KEY) describes a P2PKH output, and wpkh(KEY) describes a P2WPKH output. Wrapping a segwit function in sh(), as in sh(wpkh(KEY)), describes a nested P2SH-P2WPKH output. A multisig descriptor such as wsh(multi(2,KEY1,KEY2,KEY3)) describes a 2-of-3 P2WSH output, where the keys appear in the order given. A tr(KEY) descriptor describes a Taproot output spendable through its key path, and tr(KEY,TREE) adds a tree of script paths.

Each key expression can carry key origin information in square brackets. It starts with the 8-hex-character fingerprint of the master key, followed by the derivation steps, for example [d34db33f/84h/0h/0h]. Hardened steps can be marked with h or an apostrophe. This tells a signing device which branch of its own key tree the key came from, so the device can recognise keys it controls without needing the full wallet.

The checksum follows the final # sign. BIP 380 defines it over a character set arranged so that the checksum catches more kinds of error. Parsers may accept a descriptor without a checksum, but applications may choose to reject one that lacks it. The checksum protects against typos when a descriptor is copied, and it does not protect the descriptor's meaning against deliberate changes, because anyone can compute a new checksum.

Bitcoin Core uses descriptors internally. Its documentation lists the functions it supports, including wpkh and sh(wpkh) at the top level, multi and sortedmulti for multisig, and tr for Taproot. The differences in where each function may appear, for example that multi is not allowed inside tr, are part of the language and are checked by the parser.

A descriptor is therefore a complete recipe. It answers the three questions a wallet needs: which script to build, which keys to put into it, and which derivation path each key came from.

## advanced

BIP 380 defines the general syntax, the key expressions and the checksum. The later BIPs define the individual functions. BIP 381 covers pk, pkh and sh. BIP 382 covers wpkh and wsh. BIP 383 covers multi and sortedmulti, where sortedmulti sorts the keys lexicographically in the resulting script. BIP 384 defines combo, which covers the output types that apply to a key, and BIP 385 defines raw and addr. BIP 386 defines tr. Taproot multisig uses multi_a and sortedmulti_a inside tr, which BIP 387 specifies.

The seed phrase is not a complete backup for every wallet. A seed restores the keys, but the wallet also needs to know which output scripts to build from them and which derivation paths to use. For a single-key wallet with standard paths, the restoring software can often infer this. For multisig, a seed from one cosigner yields only that cosigner's keys. The restoring wallet also needs the other cosigners' extended public keys, the threshold, and the key order, which a descriptor records. Non-default derivation paths and mixed script types follow the same rule: without the descriptor, the restoring wallet may generate the wrong addresses.

Miniscript describes a restricted subset of Bitcoin script in a structured form that software can analyse. The draft BIP 379 specifies miniscript. Bitcoin Optech explains that miniscript lets software determine the witness data needed to spend a script, so a wallet does not need new code for each script template. Bitcoin Core uses miniscript expressions inside wsh and tr descriptors. Miniscripts can also be written in a policy language, and policies can be composed from smaller valid parts.

Descriptors also work with PSBTs. Because a descriptor states the keys and script, a wallet can determine which keys in a multisig script it controls. The descriptor describes what the wallet holds, and the PSBT describes what a particular transaction does.

Descriptors are a backup and interoperability format rather than a key format. They contain public keys and derivation paths, so a backup can reveal the structure of a wallet to anyone who reads it, even when it holds no private keys. Treat descriptor backups as sensitive information, and test the restore on a second device before relying on it, just as with a seed phrase.
