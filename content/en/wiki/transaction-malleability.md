---
id: wiki.transaction-malleability
slug: transaction-malleability
language: en
category: protocol
title: Transaction Malleability
description: How a transaction's identifier could be changed by a third party without invalidating the transaction, and how SegWit removed the problem for new spends.
difficulty: advanced
readTimeMinutes: 5
tags:
  - Malleability
  - Txid
  - Signatures
  - SegWit
  - Payment Channels
related:
  - wiki.transactions
  - wiki.segregated-witness
  - wiki.ecdsa
  - wiki.payment-channels
  - wiki.digital-signatures
sources:
  - title: "BIP 62: Dealing with malleability"
    url: https://github.com/bitcoin/bips/blob/master/bip-0062.mediawiki
    author: Pieter Wuille
  - title: "BIP 66: Strict DER signatures"
    url: https://github.com/bitcoin/bips/blob/master/bip-0066.mediawiki
    author: Pieter Wuille
  - title: "BIP 146: Dealing with signature encoding malleability"
    url: https://github.com/bitcoin/bips/blob/master/bip-0146.mediawiki
    author: Johnson Lau, Pieter Wuille
  - title: "BIP 141: Segregated Witness (Consensus layer)"
    url: https://github.com/bitcoin/bips/blob/master/bip-0141.mediawiki
    author: Eric Lombrozo, Johnson Lau, Pieter Wuille
    publishedAt: 2015-12-21
  - title: Transaction malleability
    url: https://en.bitcoin.it/wiki/Transaction_malleability
    author: Bitcoin Wiki contributors
  - title: Mt. Gox
    url: https://en.wikipedia.org/wiki/Mt._Gox
    author: Wikipedia contributors
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

A transaction's identifier, the txid, is the double SHA-256 hash of its serialized data. Malleability means that someone who can see a transaction can change part of its data, without any private key, so that the transaction stays valid but gets a different txid. The same coins move, but software that tracks the payment by its txid no longer finds the transaction it expected.

This matters because senders often follow a payment by its txid. If a changed version is the one that confirms, the sender's software may search for a transaction that does not exist and conclude that the payment failed. Some systems also build a second transaction that spends an output of the first, and that second transaction breaks when the first one's txid changes.

Before SegWit, the main source of the problem was the signature. Signature data was part of the txid calculation, and a signature could be encoded in more than one valid way. The window of risk is the time before confirmation, because once a transaction is confirmed, the version in the chain is the one that counts.

SegWit removed the problem for spends of SegWit outputs. Their signatures sit outside the txid calculation. Legacy transactions can still be changed in this way.

## medium

The main sources of malleability are in the signature and the script. An ECDSA signature has a pair of values, r and s, and for any valid signature (r, s) the pair (r, -s modulo the curve order) is also valid for the same message. Anyone can switch between the two without knowing the key. The bitcoin reference software also accepted signatures that were not encoded in strict DER, so the same signature could appear in several byte forms. BIP 66 made strict DER a consensus rule.

Script data gives more ways to vary a transaction. Extra data pushes or other operations in a scriptSig can be added without changing what the script means. An extra stack element consumed by OP_CHECKMULTISIG can also take different values. BIP 62 listed seven sources of malleability and proposed seven rules to remove them, including a low-S rule for signatures and a rule that the dummy element must be empty.

BIP 62 was not adopted, and its status is closed. The BIP itself notes that some forms of malleability cannot be removed by consensus rules alone. BIP 141 later argued that moving signatures out of the txid was a superior fix to the canonical signature approach of BIP 62.

BIP 141 solved the problem by moving the witness out of the txid. The txid is now computed from the transaction without witness data, so changes to signatures do not change it. The witness is still committed to by a separate wtxid, which allows full nodes to check that witness data has not been altered. The result is that a SegWit spend has one stable txid even when its signature bytes differ. The txid then covers the version, the outpoints, the outputs and the locktime, which are the parts that determine what the transaction does.

## advanced

Malleability was costly because of unconfirmed chains. BIP 146 describes the problem directly: for non-SegWit transactions, signature malleability changes the txid and invalidates any unconfirmed child transaction that spends the changed output. A payment that depends on another unconfirmed payment can therefore fail even though nobody lost keys.

Payment channels made the issue more serious. BIP 141 gives the example of a 2-of-2 funding output, with a time-locked spending transaction signed before the funding transaction is broadcast. If the spend is malleable, a party may fail to rely on it. The BIP states that such setups are not possible with BIP 62 as the fix, because the spend could not be created without both parties signing the funding transaction first, which lets one party lock the funds indefinitely. Segregated witness removed that dependency for SegWit inputs.

BIP 146 defined two more rules for signatures in scripts. LOW_S requires the s value to be in the lower half of the range. NULLFAIL requires a failed signature to be an empty byte array. The BIP notes that the reference software had enforced LOW_S as relay policy for legacy transactions since version 0.11.1, and it describes the rules as applying to pre-segregated witness and segregated witness scripts. Relay policy and consensus are not the same. For legacy transactions, the default relay behavior, not block validity, is what stops a transaction that breaks the low-S rule.

Who can malleate depends on the spend. A relay node with no keys can change a legacy signature, for example by switching to the other valid form of its s value. Under BIP 141, the txid of a SegWit spend does not include signature data at all, so changing its signatures leaves the txid unchanged. For m-of-n CHECKMULTISIG scripts, BIP 141 notes that malleation requires the agreement of m key holders, whereas under the BIP 62 approach a single key holder could do it.

Mt. Gox halted all bitcoin withdrawals in February 2014. In a press release of 10 February 2014, the company attributed the problem to transaction malleability, according to the Wikipedia article on the exchange. That is the company's own explanation, reported here without independent verification.

Software that tracks payments should therefore not treat a txid as permanent until the transaction confirms, and should check outputs rather than a single identifier. For transactions that spend only SegWit outputs, the txid is stable against signature changes.
