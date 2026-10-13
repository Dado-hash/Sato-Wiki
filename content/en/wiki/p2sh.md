---
id: wiki.p2sh
slug: p2sh
language: en
category: protocol
title: Pay to Script Hash (P2SH)
description: The output type that commits to a hash of a script, so the spender reveals the conditions and a simple address can lock coins behind a complex script.
difficulty: advanced
readTimeMinutes: 4
tags:
  - P2SH
  - Scripts
  - Addresses
  - BIP 16
  - SegWit
related:
  - wiki.bitcoin-script
  - wiki.bitcoin-addresses
  - wiki.multisig
  - wiki.segregated-witness
  - wiki.taproot
sources:
  - title: "BIP 16: Pay to Script Hash"
    url: https://github.com/bitcoin/bips/blob/master/bip-0016.mediawiki
    author: Gavin Andresen
    publishedAt: 2012-01-03
  - title: "BIP 13: Address Format for pay-to-script-hash"
    url: https://github.com/bitcoin/bips/blob/master/bip-0013.mediawiki
    author: Gavin Andresen
  - title: "BIP 141: Segregated Witness (Consensus layer)"
    url: https://github.com/bitcoin/bips/blob/master/bip-0141.mediawiki
    author: Eric Lombrozo, Johnson Lau, Pieter Wuille
  - title: Bitcoin Developer Guide - Transactions
    url: https://developer.bitcoin.org/devguide/transactions.html
    author: Bitcoin.org contributors
  - title: "BIP 341: Taproot - SegWit version 1 spending rules"
    url: https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki
    author: Pieter Wuille, Jonas Nick, Anthony Towns
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

A pay-to-script-hash (P2SH) output does not state its spending conditions in full. It states the 20-byte hash of a script. The person who later spends the coins must show the full script, called the redeem script, together with the data that satisfies it. The node hashes the revealed script and checks it against the output. If the hashes match, the script runs as usual. The redeem script must match the hash exactly, so a single byte of difference makes the coins unspendable. The script is therefore part of the spend, not of the output, and it becomes visible only when the coins move.

This design lets a sender pay into conditions the sender never wrote. A multisig arrangement, for example, can be locked behind one short hash that fits in a payment request or a QR code. The sender does not need to know the full script. The responsibility for supplying the conditions falls on the person who spends the coins, not on the person who pays them.

P2SH addresses use Base58Check with version byte 5, so they begin with the character 3 on the main network. The address does not show what the script requires. Anyone who wants to know the conditions has to see the redeem script, which is revealed only when the coins are spent.

## medium

On chain, the locking script is OP_HASH160, a 20-byte push of the redeem script hash, and OP_EQUAL. To spend, the input's scriptSig pushes the signatures and data the redeem script needs, followed by the redeem script itself. The node checks the hash, then runs the redeem script with the pushed data. Old nodes perform the same hash check, which is why the change could be introduced as a soft fork.

The redeem script is itself subject to the rule for pushed data. BIP 16 states that no pushed item may exceed 520 bytes, so a P2SH output cannot be spent if its redeem script is longer than 520 bytes. This limit matters for large multisig setups. Its successor for longer scripts is P2WSH, where the witness script may be up to 10,000 bytes.

SegWit added a way to nest a witness program inside P2SH. BIP 141 describes a P2WPKH program wrapped in a BIP 16 output, where the redeem script is only the witness version byte and the 20-byte key hash, and the signature and public key sit in the witness. This nested form, often written P2SH-P2WPKH, looks like any other P2SH output on the outside, so it can be paid by wallets that do not yet understand segwit addresses. Its address also starts with 3.

The same pattern of committing to a hash and revealing the content at spend time appears in later output types, and the spender always carries the burden of proof. A P2SH output can therefore hide a complex arrangement at the cost of revealing it later. P2WSH commits to the SHA-256 of a witness script, while Taproot outputs commit to a key and a tree of scripts, so that most spends reveal nothing about the unused branches.

## advanced

BIP 16 describes the purpose of P2SH as moving the responsibility for supplying redeem conditions from the sender to the redeemer. The sender funds any transaction with a fixed 20-byte hash, and the redeemer later supplies the complete script. The BIP explains that this is useful for QR codes and copy-paste, and that it avoids forcing every sender to understand every script type.

Activation is part of the design. The BIP states that the new validation rules apply to blocks with timestamps from 1 April 2012 onward. Transactions created before that date may fail the new rules, so they are validated under the old rules. Because old nodes check the hash but not the script itself, a transaction can be valid to old software and invalid to new software. The BIP discusses this risk, and the timestamp rule is part of the answer to it.

The receiver has to keep the redeem script as well, because the hash alone cannot unlock anything. The 520-byte push limit has a direct consequence. A multisig script with many keys can be too large to be a redeem script, so large arrangements use other patterns. The BIP notes that, because of this limit, a P2SH output can be spent with at most 15 compressed public keys in a multisig redeem script. This is one reason later designs moved the script into the witness, where P2WSH allows scripts up to 10,000 bytes.

Nested segwit is a compatibility bridge. The outer output is an ordinary P2SH output with an address beginning with 3, so software that only knows P2SH can pay it. The witness program inside the redeem script is what segwit-aware software checks. In that case the outer hash commits to a redeem script that is only a witness version byte and a key hash. Native segwit outputs drop the outer hash layer altogether.

P2WSH keeps the same hash commitment in a native segwit output, without the outer layer. Taproot takes the next step. Its output key commits to a Merkle tree of scripts, and the key path spend reveals only one signature. BIP 341 is the reference for how that output is constructed and spent.
