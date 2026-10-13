---
id: wiki.address-reuse
slug: address-reuse
language: en
category: privacy-security
title: Address Reuse
description: Receiving several payments at one address links them together on the public ledger, and modern wallets avoid this by deriving a new address for each payment.
coverImage: media/wiki/address-reuse/address-reuse-hero.svg
difficulty: base
readTimeMinutes: 4
tags:
  - Privacy
  - Addresses
  - Wallets
  - Security
related:
  - wiki.bitcoin-addresses
  - wiki.hd-wallets
  - wiki.public-keys
  - wiki.common-input-ownership
  - wiki.threat-model
sources:
  - title: Protect your privacy
    url: https://bitcoin.org/en/protect-your-privacy
    author: Bitcoin.org contributors
  - title: "BIP 44: Multi-Account Hierarchy for Deterministic Wallets"
    url: https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki
    author: Marek Palatinus, Pavol Rusnak
    publishedAt: 2014-04-24
  - title: "BIP 352: Silent Payments"
    url: https://github.com/bitcoin/bips/blob/master/bip-0352.mediawiki
    author: josibake, Ruben Somsen, Sebastian Falbesoner
  - title: Silent payments - Bitcoin Optech topic
    url: https://bitcoinops.org/en/topics/silent-payments/
    author: Bitcoin Optech
  - title: Bitcoin Developer Guide - Transactions reference
    url: https://developer.bitcoin.org/reference/transactions.html
    author: Bitcoin.org contributors
  - title: Quantum resistance - Bitcoin Optech topic
    url: https://bitcoinops.org/en/topics/quantum-resistance/
    author: Bitcoin Optech
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

An address that receives several payments links them together. Anyone can see that the same address received coins at different times, from different senders, and that those coins were later spent. The ledger is permanent, so the link does not expire. People who pay you can also see your other payments to the same address, and so can anyone who learns the address from a website, an invoice or a social media post.

Reuse also has a security side. When coins are spent, the transaction reveals the public key that controls them. Reusing an address keeps funds under a key that is already public. Today this is a theoretical concern, because breaking such a key would require a quantum computer, and no such machine has been shown to do it.

Modern wallets avoid reuse automatically. They derive a new receiving address for each payment from the same seed, so you do not have to track which addresses you used. Publishing one address on purpose, for example for donations, is one common case where reuse is hard to avoid, and it is a trade-off you choose knowingly.

## medium

Bitcoin.org advises using a new address each time you receive a payment, so that transactions cannot be associated with one another. The advice is simple, but it depends on the wallet creating addresses for you.

Hierarchical deterministic wallets make this practical. A single seed produces a tree of keys, and the wallet hands out the next unused receiving address each time it is needed. BIP 44 defines the account structure used by many wallets. Its address gap limit is set to 20: when a wallet finds 20 unused addresses in a row, it stops searching the chain for used ones. This matters when a wallet is restored from a seed. If many addresses were handed out in a row without receiving payments, a restore can stop before reaching a later address that holds funds.

Some cases remain hard. A donation address published on a website or social network is meant to receive many payments from people who cannot be asked for a fresh address. Bitcoin.org notes that publishing an address is a poor privacy choice unless you intend to receive public donations with full transparency.

BIP 352 describes silent payments, an alternative for static addresses. The receiver publishes one address. Each sender derives a unique output for its payment from one of its inputs and the receiver's address, and the receiver scans the blockchain to find the outputs that belong to it. The BIP states that payments to the same address are not linked by an outside observer and that no notification has to be posted on-chain. The trade-off is scanning cost. Bitcoin Optech notes that scanning is more computationally expensive than looking up scripts in the UTXO set, which is how ordinary wallets find their outputs. Support depends on the wallet software, so check before relying on it.

## advanced

Address reuse does not only merge a few payments. It links every output sent to the same key with every input spent from it, so the transaction graph around that address becomes one connected record. Analysts describe this as identity collapse: once one linked address is known, the ledger connects the others to it.

The security question follows from the same data. A key-based output reveals its public key when it is spent. The Bitcoin Developer Guide's transaction reference describes OP_CHECKSIG as consuming a signature and a full public key, and signature scripts push both onto the stack. After that, an address that has been spent from and still holds funds is controlled by a public key. Bitcoin Optech states that the public keys used by ECDSA are vulnerable to Shor's algorithm on an idealized quantum computer, and that the same applies to the public keys of Schnorr signatures. Quantum-resistant alternatives exist, but they use much larger keys and signatures. Reuse therefore keeps funds exposed for longer, which is why a fresh address for each payment is a safer habit, even though the present risk is theoretical.

Silent payments, specified in BIP 352, address the privacy side without interaction. A receiver publishes a static silent payment address made of a scan key and a spend key. A sender that holds an input with a usable key derives a shared secret through an elliptic curve operation and creates an output for a unique key. The receiver computes the same secret from the summed input public keys and its scan key, and detects matching outputs. The BIP's security goals include that outside observers cannot link payments to the address, that no sender-receiver interaction is needed, and that transactions are indistinguishable from ordinary ones. Silent payments are not free. Scanning requires work for each transaction that may pay the address, and using them in collaborative settings such as coinjoin was left for future work in the Optech summary. Wallets must implement both the sending and the scanning side. A new address generated by a standard wallet remains the simplest form of protection for most users.

Reuse also interacts with other heuristics. An address that receives several payments makes common-input clustering and change detection more reliable for an analyst, because the same key appears in many places.
