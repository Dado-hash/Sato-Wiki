---
id: wiki.threat-model
slug: threat-model
language: en
category: privacy-security
title: Threat Models
description: Security and privacy in Bitcoin depend on who you are protecting against, so every defence covers some threats and leaves others open.
difficulty: base
readTimeMinutes: 5
tags:
  - Privacy
  - Security
  - Threat Model
  - Opsec
related:
  - wiki.private-keys
  - wiki.common-input-ownership
  - wiki.address-reuse
  - wiki.tor
  - wiki.coinjoin
sources:
  - title: Secure your wallet
    url: https://bitcoin.org/en/secure-your-wallet
    author: Bitcoin.org contributors
  - title: Protect your privacy
    url: https://bitcoin.org/en/protect-your-privacy
    author: Bitcoin.org contributors
  - title: Privacy - Bitcoin Wiki
    url: https://en.bitcoin.it/wiki/Privacy
    author: Bitcoin Wiki contributors
  - title: CoinJoin - Bitcoin Optech topic
    url: https://bitcoinops.org/en/topics/coinjoin/
    author: Bitcoin Optech
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

Security and privacy in Bitcoin start with a question that is easy to skip: protection from whom? Every defence covers some threats and leaves others open. A wallet that keeps keys offline protects them from malware on a computer, but it does nothing about a public address that links all your payments. Hiding your IP address keeps peers from logging your connections, but it does not hide what the transactions contain.

Two kinds of asset need protection. The first is the keys that can sign spending. The second is the privacy of balances and payments, because the ledger is public and permanent. Losing a key can cost you everything at once. Losing privacy cannot be undone, even if no coin is stolen.

Several parties can act as adversaries: someone who gets into your computer, a thief who finds your device, a service that holds your keys or sees your requests, a network observer, an analyst who groups addresses on the chain, and someone who knows you.

Three examples show how needs differ. A freelancer who publishes a donation address wants strangers not to see the income of the whole address. A saver with a large balance mainly needs keys that never sit on a connected device. A person who runs a node at home wants peers not to learn the home IP address. Each defence has a cost.

## medium

A threat model is a short, explicit description of what you protect, against whom, and at what cost. The Bitcoin Wiki privacy page puts the question directly: think about what you are hiding from. Without this step, it is easy to adopt a tool that solves a problem you do not have, or to miss the one you do.

The assets are usually of two kinds. Keys come first. Anyone who learns a private key or a seed can spend the funds it controls. The privacy of balances and payments comes second. Anyone can see the balance and history of any address, and bitcoin.org points out that information which is hard to trace today may become easy to trace later, because the blockchain is permanent.

Adversaries differ in what they can see. Malware on your computer can read files and keystrokes. A network observer can see which addresses send transactions into the peer-to-peer network. A service that your wallet queries learns which addresses you care about. A chain analyst works only from public data, so it relies on assumptions about how wallets behave. A person who knows you can link your published address to your identity through conversation or other records. Each of these sees a different part of your activity.

Defences are specific too. A seed backup protects against losing a device, but it does not protect against someone who finds the device and its unlocked contents. Encryption of a wallet protects against a thief, but it cannot protect against keylogging hardware or software. Tor hides an IP address, but not the transaction itself. Using new addresses makes payments harder to link, but it does not hide the amounts.

Leaks combine. The Bitcoin Wiki describes data fusion: each leak removes some candidates, and two leaks together can remove far more than either one alone.

Good practice starts with the model. Write down the assets, the adversaries you care about, and the cost you accept, then choose the entries that address those threats.

## advanced

A threat model also has to account for what a defence costs and who can see your data after you apply it. A wallet that queries a remote server sends that server the addresses it needs, so the server learns part of your activity in order for the wallet to work. A node that connects through Tor keeps its IP address from its peers, but those peers still receive the transactions it relays. A defence against one adversary can therefore strengthen another one.

Adversaries can be passive or active. A passive observer reads public data and network traffic. An active adversary can also send you coins, run peers, or control a counterparty. The Bitcoin Wiki gives an example in which an adversary runs both the service where coins are bought and the destination that receives them, so the ledger alone connects the two. A defence built for passive observers may not hold against an active one.

Chain analysis relies on heuristics, which are assumptions about how people and software usually behave. The common-input-ownership assumption is one of them. The Bitcoin Wiki notes that these assumptions can be wrong, and one wrong assumption can merge unrelated people into one cluster. Bitcoin Optech describes coinjoin as a way to make it hard for outside parties to use the transaction history to determine who owns which coin, which is exactly the chain-analysis threat. A result from analysis is therefore a probability, not a proof, and it can be wrong in either direction.

Time matters. Because the ledger is permanent, a payment that is hard to link today may be easier to link once more data or better methods exist. A threat model should ask how long a piece of information must stay private, not only whether it is private now.

The model applies to both sides of a payment. A receiver who publishes an address shares a link with every future sender who sees it. A sender who pays from coins with a visible history can reveal that history to the receiver. The Bitcoin Wiki observes that privacy requires a change in behaviour, and that a perfectly private network does not help someone who publishes their real name next to a payment address.

A useful model names the adversary, the asset, the time horizon and the accepted cost. Each later entry in this category changes at least one of these variables.
