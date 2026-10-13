---
id: wiki.psbt
slug: psbt
language: en
category: protocol
title: Partially Signed Bitcoin Transactions (PSBT)
description: A standard container that carries an unsigned transaction and the data each signer needs, so separate devices and programs can sign it in turn.
difficulty: base
readTimeMinutes: 4
tags:
  - PSBT
  - Signing
  - Hardware Wallets
  - Multisig
related:
  - wiki.transactions
  - wiki.multisig
  - wiki.hardware-wallets
  - wiki.software-wallets
  - wiki.sighash
sources:
  - title: "BIP 174: Partially Signed Bitcoin Transaction Format"
    url: https://github.com/bitcoin/bips/blob/master/bip-0174.mediawiki
    author: Ava Chow
    publishedAt: 2017-07-12
  - title: "BIP 370: PSBT Version 2"
    url: https://github.com/bitcoin/bips/blob/master/bip-0370.mediawiki
    author: Ava Chow
    publishedAt: 2021-01-14
  - title: Partially signed bitcoin transactions
    url: https://bitcoinops.org/en/topics/psbt/
    author: Bitcoin Optech
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

A PSBT, or partially signed Bitcoin transaction, is a file format that carries an unsigned transaction together with the information each signer needs to add its signature. BIP 174 defines the format. A PSBT is not a finished transaction. It cannot be broadcast until every input is signed and the signatures are assembled into a complete transaction.

The format exists because signing often happens somewhere else. A wallet may build a transaction on an internet-connected computer, while the keys sit on an air-gapped device or a hardware wallet. Without a shared format, each wallet and signer pair would need its own way to exchange data. A PSBT lets one program create the transaction, a compatible signer add its signature, and another program finish it.

BIP 174 was designed so that an offline signer can sign without access to the full UTXO set and without being defrauded about what the transaction does. The PSBT carries the previous output data the signer needs, so the signer can check the amounts and destinations before it signs.

Each signer adds only its own signatures. Multisig setups, where several keys must sign, and transactions whose inputs are held by different wallets both use this flow. A PSBT can travel as a binary file or as a Base64 string.

## medium

BIP 174 divides the work into six roles. The creator builds the unsigned transaction with empty input and output fields. The updater adds known data, such as the output being spent, redeem and witness scripts, and BIP 32 derivation paths. The signer adds partial signatures for the inputs it controls, and it only adds data. The combiner merges several PSBTs that carry different signatures into one, and it refuses to join two different transactions. The input finalizer builds the final scriptSig and scriptWitness for each input. The transaction extractor turns a fully finalized PSBT into a network-serialized transaction. One program often plays several roles, and a multisig workflow usually repeats the signer role on different devices.

Because the format is standard, software from one vendor can prepare a transaction that a device from another vendor signs. Interoperability requires both sides to read the same fields. BIP 174 addresses this with a rule that a signer must pass through key-value pairs it does not understand, so newer tools can add data without breaking older ones.

Hardware wallets are a common example of a signer. The device receives the PSBT, reads the outputs and fee, and returns the signatures. The device does not need a network connection, and the transaction does not need to be typed in by hand. The same flow can use a laptop, a phone or a second wallet as the signer.

Multisig is the other common case. Each cosigner receives a copy of the PSBT, adds its own partial signature, and returns it. The combiner merges the copies, and the finalizer completes the input once enough valid signatures are present. Each cosigner can check the transaction against its own copy of the data.

Bitcoin Optech notes that a PSBT can be passed among several participants, and that for multisig wallets the signing step can be repeated on different copies by different programs.

## advanced

The original format, version 0, fixes the unsigned transaction in the global map. Inputs and outputs therefore cannot be added after the PSBT is created. BIP 370 defines PSBT version 2, which removes the global unsigned transaction and places each input and output's data in its own map. The version number 2 was chosen to avoid confusion, because version 0 is often called version 1 informally. There are no version 1 PSBTs.

A signer should check several things before it signs. If a non-witness UTXO is provided, its hash must match the transaction ID named in the input's previous output. If a witness UTXO is provided, the signer must not produce a non-witness signature. A redeem script must match the script in the output, and a witness script must match the hash in the output or the redeem script. If a sighash type is present, the signer must accept that type or fail. BIP 174 also suggests that the signer compute the addresses, amounts and fee, and show them to the user before it signs.

The fee check matters because the segwit signing algorithm of BIP 143 does not cover the amounts of the other inputs. BIP 174 records that an attacker could change those amounts and so trick a user into signing malicious transactions that send bitcoin to fees. Many wallets therefore require the full previous transaction for every input. Bitcoin Optech lists this as the fee overpayment attack that led to changes in the specification.

The signer can also detect change outputs by comparing the derivation paths and extended public keys in the PSBT with its own keys. This lets a device hide the change output from the confirmation screen, so the user reviews only the payments.

A PSBT does not protect against everything. It is a container and not a security policy, so it cannot tell the signer what the user intended. A malicious creator or updater can put a misleading output into the transaction, and a signer that does not check the data will sign it. The format is also not private. By design it can carry extended public keys and derivation paths, which reveal a wallet's structure to anyone who reads the file.
