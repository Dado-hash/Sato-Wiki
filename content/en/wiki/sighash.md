---
id: wiki.sighash
slug: sighash
language: en
category: protocol
title: Signature Hash Types
description: The sighash flags that decide which parts of a transaction a signature commits to, and how segwit and taproot changed the digest that gets signed.
difficulty: advanced
readTimeMinutes: 4
tags:
  - Sighash
  - Signatures
  - Transactions
  - Taproot
related:
  - wiki.digital-signatures
  - wiki.transactions
  - wiki.segregated-witness
  - wiki.taproot
  - wiki.schnorr-signatures
  - wiki.ecdsa
sources:
  - title: Bitcoin Developer Guide - Transactions
    url: https://developer.bitcoin.org/devguide/transactions.html
    author: Bitcoin.org contributors
  - title: "BIP 143: Transaction Signature Verification for Version 0 Witness Program"
    url: https://github.com/bitcoin/bips/blob/master/bip-0143.mediawiki
    author: Johnson Lau
  - title: "BIP 341: Taproot: SegWit version 1 spending rules"
    url: https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki
    author: Pieter Wuille
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

A signature in Bitcoin does not always cover the whole transaction. Each signature ends with a sighash byte that tells the verifier which parts were signed. The most common value, SIGHASH_ALL, commits to every input and every output. If someone changes an amount, an address or an input after signing, the signature no longer verifies.

The other flags leave room for others on purpose. SIGHASH_NONE signs the inputs but no outputs, so the destinations can be filled in later. SIGHASH_SINGLE signs the inputs and only the output at the same position as the input being signed. The ANYONECANPAY modifier narrows any of these to the one input being signed, so other people can add inputs to the transaction.

Each flag is a decision about how much the signer is willing to leave open. The choice depends on how far the signer trusts the rest of the transaction to stay as written. Wallets almost always use SIGHASH_ALL. A normal payment from one person to another has no reason to let anyone else change it. The other flags are useful mainly when several parties build one transaction together, each signing only their own part and letting the others add theirs.

## medium

Consider a transaction in which Alice spends one input and pays Carol. With SIGHASH_ALL, Alice's signature fixes her input and both outputs. Bob cannot change the amount Carol receives or add an output to the transaction without invalidating Alice's signature.

With SIGHASH_NONE, Alice's signature fixes her input only. Whoever holds the signed input can attach any outputs they like. The Developer Guide describes this as allowing anyone to change where the satoshis go, so it is only safe when the signer does not care about the destination.

With SIGHASH_SINGLE, Alice's signature fixes her input and the output at the same index. Other outputs, such as a change output that another party adds, can be changed without affecting her signature. ANYONECANPAY adds a further freedom: Alice's signature no longer fixes the other inputs, so a stranger can contribute an input. The Developer Guide notes that SIGHASH_ALL with ANYONECANPAY lets anyone add satoshis but cannot change how many satoshis are sent or where they go.

Legacy SIGHASH_SINGLE has a bug. If the transaction has no output at the same index as the signed input, the signed value is the number 1 rather than a hash of the transaction. The Developer Guide says that this breaks the security scheme. Because the signed value no longer depends on the transaction, the signature is not tied to the transaction it was made for.

The sighash byte is part of each input's signature, so the inputs of one transaction can use different flags. For example, one input may sign ALL while another signs NONE. Each input protects only what its own flag covers, so a strong flag on one input does not protect the parts that another input leaves open.

## advanced

Segwit version 0 changed the digest in BIP 143. Under the legacy digest, the amount of data hashed for each signature grew with the size of the transaction, so verifying all signatures grew with the square of the number of signatures. BIP 143 computes three shared hashes, one each for the outpoints, the sequence numbers and the outputs, and reuses them across inputs, which makes the total work linear. The new digest also includes the amount of the input being spent. An offline signer that is given a wrong amount produces an invalid signature rather than a valid one for a different value.

Taproot changed the digest again, in BIP 341. The message now commits to the amounts of all inputs and to the scriptPubKeys of all spent outputs, unless ANYONECANPAY is set. The BIP explains that these commitments stop a signer from being lied to about the value being spent, which removes the need to trust a remote source for the fee. The message is hashed with a single SHA-256 inside a tagged hash, rather than the double SHA-256 used before, and it includes a one-byte epoch prefix that leaves room for future signature algorithms.

Taproot also defines SIGHASH_DEFAULT, the value 0x00. It signs the whole transaction exactly as SIGHASH_ALL does, but the signature is 64 bytes because the sighash byte is omitted. A 65-byte Schnorr signature that ends in 0x00 is invalid, since allowing it would let a third party turn a 64-byte signature into a 65-byte one with a different wtxid and fee rate. Taproot rejects undefined hash types, so only 0x00, 0x01, 0x02, 0x03, 0x81, 0x82 and 0x83 are valid.

The legacy flags still exist in the Taproot digest, so the same four base types and the ANYONECANPAY modifier keep their meaning. What changes is what each flag hashes and how. With SIGHASH_NONE or SIGHASH_SINGLE, nSequence values of all inputs are committed unless ANYONECANPAY is set, which keeps the sequence semantics consistent with the rest of the message.

The main practical reason to choose a narrower flag is coordination: a signer gives up control of part of the transaction so that someone else can complete it, and gives up that part's protection in the same move. The Developer Guide names SIGHASH_ALL as the default. The stricter commitments in BIP 143 and BIP 341 make that default safer, because a signature covers the amounts and scripts of all inputs unless ANYONECANPAY is set, not only the input it spends.
