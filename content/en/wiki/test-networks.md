---
id: wiki.test-networks
slug: test-networks
language: en
category: protocol
title: Testnet, Signet and Regtest
description: The networks developers use to test Bitcoin software with coins that have no value, and how each one trades realism for predictability.
coverImage: media/wiki/test-networks/test-networks-hero.svg
difficulty: base
readTimeMinutes: 5
tags:
  - Testnet
  - Signet
  - Regtest
  - Development
  - Test Networks
related:
  - wiki.developer-tools
  - wiki.node-software
  - wiki.bitcoin-addresses
  - wiki.blockchain
  - wiki.consensus-rules
sources:
  - title: "BIP 94: Testnet 4"
    url: https://github.com/bitcoin/bips/blob/master/bip-0094.mediawiki
    author: Fabian Jahr
    publishedAt: 2024-05-27
  - title: "BIP 325: Signet"
    url: https://github.com/bitcoin/bips/blob/master/bip-0325.mediawiki
    author: Karl-Johan Alm, Anthony Towns
  - title: Bitcoin Core 28.0 release notes
    url: https://github.com/bitcoin/bitcoin/blob/master/doc/release-notes/release-notes-28.0.md
    author: Bitcoin Core contributors
  - title: Bitcoin Core chain parameters (src/kernel/chainparams.cpp)
    url: https://github.com/bitcoin/bitcoin/blob/master/src/kernel/chainparams.cpp
    author: Bitcoin Core contributors
  - title: Testnet
    url: https://en.bitcoin.it/wiki/Testnet
    author: Bitcoin Wiki contributors
  - title: Signet
    url: https://bitcoinops.org/en/topics/signet/
    author: Bitcoin Optech
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

Developers need to test wallets, nodes and payment software without risking money. Test networks make that possible. They work like the main network, with blocks, transactions and addresses, but their coins have no market value. Each network trades some realism for predictability.

Testnet is a public network that anyone can join. Its blocks are found with proof of work, as on the main network, but it is less stable. Its history includes several resets, and its difficulty can drop sharply, which allowed bursts of very fast blocks. Testnet4 is the current successor to testnet3.

Signet is a test network where each block must also carry a signature from a key set by the network's creator. Block production is therefore predictable. Regtest is a private chain on one machine, where the user creates blocks when needed, which suits automated tests.

Each network has its own address prefixes. Bech32 addresses on testnet and signet begin with tb1, and on regtest with bcrt1. A careful wallet checks the network of an address and refuses one that belongs to another.

Test coins usually come from faucets, which are services that send small amounts to whoever asks. The coins are useful only for testing, so treat them as having no value.

## medium

Testnet3 shows the limits of a public proof-of-work test network. Its blocks can be produced cheaply, and BIP 94 aims to make attacks using only CPU mining impractical, which implies they were possible there. The minimum difficulty rule lets a block be mined at the lowest difficulty when no block has appeared for twenty minutes. Together these effects produce block storms, bursts of hundreds of blocks, and long gaps. Software tested on such a chain may behave differently on mainnet.

BIP 94 specifies testnet4 to replace testnet3. It keeps the 20-minute minimum difficulty exception, but it changes the difficulty adjustment. The base for the adjustment comes from the first block of the previous period, not its last block, and the first block of each period must use the actual network difficulty. The BIP also adds a timestamp rule for the first block of a period. Testnet4 follows mainnet consensus rules as of May 2024, with those soft forks enforced from the genesis block.

Bitcoin Core 28.0 added testnet4 support. Users select it with the testnet4 option, and the configuration file uses a separate testnet4 section.

Signet, specified in BIP 325, works differently. Its challenge script is set by the creator and is usually a public key or a multisig. Every block must satisfy it in addition to proof of work, and the solution is carried in a commitment inside the coinbase transaction. The creator therefore decides when blocks appear. The BIP's goal is a predictable amount of unreliability rather than none at all.

Regtest is a local chain with its own genesis block and parameters, used by one developer or one test suite. It does not talk to the public network, and the user decides how many blocks exist and when they are created.

Faucets are the usual way to get test coins. They are run by individuals and projects outside the protocol, and they can disappear or change their rules, so a developer should not depend on one.

## advanced

The chain parameters in Bitcoin Core show how the networks differ. Mainnet uses 0 and 5 as the version bytes for pay-to-public-key-hash and pay-to-script-hash addresses. Testnet, testnet4, signet and regtest all use 111 (0x6f) and 196 (0xc4), and 239 for private keys. The bech32 human-readable part is bc on mainnet, tb on testnet, testnet4 and signet, and bcrt on regtest. A testnet address is not valid on mainnet, even when it encodes the same hash.

BIP 94 names three exceptions to mainnet rules. The 20-minute minimum difficulty rule is kept, with the minimum nBits value 0x1d00ffff for non-first blocks in a period. The adjustment base comes from the first block of the previous period, which removes the reset that let difficulty fall to its minimum at the end of a period. The timestamp rule for the first block of a period prevents miners from manipulating timestamps to lower difficulty.

Signet adds a constraint at the block level. A block passes the normal checks and also carries a solution to the challenge script. The solution is committed through the coinbase's witness commitment, so it is part of the block itself. The BIP builds the solution from a virtual transaction that spends an output whose script is the challenge. A custom signet may use an empty solution when the challenge is trivially satisfied.

Because the challenge is a script, a signet can require a k-of-n multisig from a group of operators. That lets several parties agree on when blocks appear, which is useful for integration work and for testing soft forks. The trade-off is that the key holders control the chain's progress, so a signet is a trusted environment.

Regtest uses the same consensus engine with different chain parameters. Its genesis block and parameters differ from the public networks, so block production is under the developer's control. Its results cannot be read as evidence of how the public network would behave, and tests should record which network produced each result.

Software should check the network before it sends. The checksum protects against typing errors but does not reveal the network, so the prefix must be read. Test wallets should be connected to the network they are configured for and refuse destinations that belong to another network. The script system is the same on all of them, so the differences lie in the chain's history and parameters.
