---
id: wiki.developer-tools
slug: developer-tools
language: en
category: software
subcategory: developer-tools
title: Libraries and Developer Tools
description: The libraries, node interfaces and test networks developers use to build Bitcoin software, and the risks of depending on them.
difficulty: base
readTimeMinutes: 4
tags:
  - Developers
  - Libraries
  - Testing
  - Supply Chain
related:
  - wiki.secp256k1
  - wiki.bitcoin-script
  - wiki.consensus-rules
  - wiki.software-wallets
  - wiki.transactions
sources:
  - title: Bitcoin Dev Kit - repository README
    url: https://github.com/bitcoindevkit/bdk
    author: Bitcoin Dev Kit contributors
  - title: rust-bitcoin - repository README
    url: https://github.com/rust-bitcoin/rust-bitcoin
    author: rust-bitcoin contributors
  - title: libsecp256k1 - repository README
    url: https://github.com/bitcoin-core/secp256k1
    author: Bitcoin Core contributors
  - title: bitcoinjs-lib - repository README
    url: https://github.com/bitcoinjs/bitcoinjs-lib
    author: bitcoinjs contributors
  - title: "BIP 174: Partially Signed Bitcoin Transaction Format"
    url: https://github.com/bitcoin/bips/blob/master/bip-0174.mediawiki
    author: Ava Chow
  - title: Bitcoin Developer Examples - Testing Applications
    url: https://developer.bitcoin.org/examples/testing.html
    author: Bitcoin.org contributors
updatedAt: 2026-10-13T00:00:00Z
reviewedAt: 2026-10-13
---

## base

Libraries and developer tools are the building blocks used to write Bitcoin software. A library is code you import into your own program, so you do not have to write signature checks, transaction parsing or address encoding yourself. Most wallets, explorers and payment tools depend on one or more of these components, even when their users never see them.

Some libraries cover one part of the job. The Bitcoin Dev Kit provides building blocks for descriptor-based wallets and is built on rust-bitcoin, which handles encoding, scripts, keys and transactions. libsecp256k1 is the C library that performs signing and verification on the secp256k1 curve. bitcoinjs-lib offers similar building blocks for JavaScript code.

Developers also need a safe place to test. Bitcoin Core can run on testnet, where the coins have no real-world value, or in regtest, a private chain where you create blocks on demand. The bitcoin-cli command sends RPC requests to a running node, so a script can query balances or create blocks without a graphical interface.

Choosing a library is a trade-off between features, programming language and how much review the code has received. Read what each project says it is for, and do not assume that a wallet library is suitable for validating the Bitcoin chain.

## medium

A typical library covers several layers. Key handling includes hierarchical deterministic derivation under BIP 32, which rust-bitcoin supports fully. Script and transaction code handles serialization, parsing and scripts. Descriptors describe the scripts a wallet should track and sign for, and BDK builds wallet logic around them. Chain data reaches the wallet through a backend, and BDK can fetch it from an Esplora server or an Electrum server.

Bitcoin Core exposes its own functions through RPC, and bitcoin-cli is the command-line client for that interface. A program can call the same RPC methods, so an application can be tested against a real node instead of a reimplementation. Pinning the node version the application targets is part of that setup, because RPC methods and their output can change between releases.

Partially signed transactions are how software passes a transaction between signers. BIP 174 defines a binary format that holds the information a signer needs, and each signer adds its own signatures until the transaction is complete. The format lets a signer work offline, since all required data travels inside the transaction.

Testing is where developers spend much of their time. The Bitcoin developer documentation on bitcoin.org describes testnet as a public network where coins have no real value, and it notes that testnet relaxes some standard-transaction checks, so behavior there can differ from mainnet. Regtest is a private chain for situations where interaction with random peers is unnecessary, and the developer generates blocks with commands such as generatetoaddress. The same documentation notes that many developers consider regtest the preferred way to build new applications.

Keep testing separate from real funds. Run experiments on regtest or testnet, and back up any mainnet wallet before a dangerous operation such as deleting data, as the documentation advises.

## advanced

The most important limit of a general library is consensus. The rust-bitcoin README says the library must not be used for consensus code, meaning code that fully validates blockchain data. It states that the library supports such validation technically, but that it deviates from the Bitcoin Core reference implementation in ways known and unknown, and that it will not match Core's rules. Consensus has to be identical across all nodes, so an independent reimplementation can accept or reject blocks differently from the network. For that job, use Bitcoin Core, or validate through a node you trust.

Building transactions is a different job from validating them. A library can construct a transaction that is valid under consensus but not relayed by default nodes because it fails policy. A transaction that is non-standard by policy can still be valid if a miner includes it in a valid block. Developers should separate the two checks in their code and not rely on local rejection as proof of invalidity.

Cryptographic code deserves the same caution. libsecp256k1 aims to be a high-assurance library for secp256k1, with constant-time signing and derandomized ECDSA, and it has optional modules for BIP 340 Schnorr signatures, BIP 324 ElligatorSwift and MuSig2. The project also says that correct use requires care and that usage unlike Bitcoin's may be less tested. Using a well-reviewed primitive correctly matters more than the choice of library.

Chain backends are a trust point. A wallet that asks a remote server for transaction history depends on what that server returns. Whether the library verifies the answer, or only trusts it, depends on the backend and the configuration. Developers should document which backend they use and what it checks.

Supply-chain risk comes from every dependency. The bitcoinjs-lib README says that only tagged releases are stable, that the master branch is a development branch, and that users should audit the code and their dependencies. The rust-bitcoin README recommends checking dependencies with cargo-crev. Each added crate or package is code that runs with access to keys, so the number of dependencies is itself a security decision. Pin versions, review updates, and prefer small dependency trees where the design allows it.
