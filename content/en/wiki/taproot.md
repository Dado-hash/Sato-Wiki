---
id: wiki.taproot
slug: taproot
language: en
category: protocol
title: Taproot
description: A Bitcoin upgrade that makes complex spending conditions look identical to simple ones on-chain, improving privacy and reducing fees.
coverImage: media/wiki/taproot/taproot-hero.svg
difficulty: advanced
readTimeMinutes: 10
tags:
  - Taproot
  - Schnorr
  - MAST
  - BIP
  - Privacy
  - Smart Contracts
related:
  - wiki.transactions
  - wiki.bitcoin-script
  - wiki.segwit
sources:
  - title: "BIP 341 - Taproot: SegWit version 1 spending rules"
    url: https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki
    author: Pieter Wuille, Jonas Nick, Anthony Towns
    publishedAt: 2021-01-21
  - title: "BIP 342 - Validation of Taproot scripts"
    url: https://github.com/bitcoin/bips/blob/master/bip-0342.mediawiki
    author: Pieter Wuille, Jonas Nick, Anthony Towns
    publishedAt: 2021-01-21
  - title: "BIP 343 - Bech32m format"
    url: https://github.com/bitcoin/bips/blob/master/bip-0343.mediawiki
    author: Pieter Wuille
    publishedAt: 2021-01-21
  - title: "BIP 340 - Schnorr Signatures"
    url: https://github.com/bitcoin/bips/blob/master/bip-0340.mediawiki
    author: Pieter Wuille, Jonas Nick, Tim Ruffing
    publishedAt: 2021-01-21
  - title: "Taproot — Bitcoin Optech"
    url: https://bitcoinops.org/en/topics/taproot/
    author: Bitcoin Optech contributors
updatedAt: 2026-05-27T00:00:00Z
---

## base

Taproot is a Bitcoin upgrade activated in November 2021 that changes how outputs can be spent. Before Taproot, if you created an output with multiple spending conditions — for example, "either Alice can spend this alone OR two of three people need to agree" — the blockchain had to show every possible condition when the output was created.

Taproot flips this. All possible spending conditions are committed off-chain using a data structure called a Merkle tree. The on-chain output looks like a simple single-signature payment to everyone else. The actual conditions are only revealed when they are used.

This has two benefits: privacy improves because most transactions look the same, and fees decrease because complex scripts are kept off the chain until they are needed.

![Taproot commitment structure](media/wiki/taproot/taproot-hero.svg "A Taproot output commits to an internal key and a Merkle tree of scripts. The simplest spend uses only the key path.")

Taproot outputs use the address format starting with `bc1p` and are the third major output type after legacy and SegWit.

## medium

Taproot introduces a new output type called Pay-to-Taproot (P2TR) that is SegWit version 1. It builds on two cryptographic primitives: Schnorr signatures and MAST (Merkelized Abstract Syntax Tree).

The key insight is the distinction between a key path spend and a script path spend. Every Taproot output contains an internal public key P and commits to a Merkle tree of script paths. The actual output key that goes on-chain is Q = P + t*G, where t is a hash derived from the Merkle tree root. Anyone seeing this output cannot tell whether it is a simple single-signature payment or an output with dozens of complex spending conditions.

In the cooperative case — the key path — the spender produces a single Schnorr signature with the key P. This is always the cheapest and most private way to spend: 64 bytes plus one input, indistinguishable from any other Taproot spend.

If the cooperative path is not possible — for example, one party refuses to sign — the spender can reveal one of the script paths. This requires revealing the script itself and the Merkle proof showing it belongs to the tree. The proof consists of the sibling hashes along the path from the script leaf to the Merkle root. This is larger than a key path spend and makes the spending conditions visible on-chain.

Schnorr signatures bring a separate benefit: signature aggregation. In a multisignature arrangement under the key path, multiple signers can produce a single aggregate signature that looks identical to a single-party signature. This is much more compact than the CHECKMULTISIG approach in legacy transactions.

Taproot addresses use Bech32m encoding, a modification of the Bech32 format used for SegWit addresses. Bech32m fixes a subtle issue where Bech32 could not reliably detect errors in addresses with variable-length data.

## advanced

Taproot is specified across three BIPs that work together: BIP 341 (spending rules), BIP 342 (script validation), and BIP 343 (address encoding). A fourth BIP, 340, specifies the Schnorr signature algorithm used by the key path.

**BIP 341 — Output key construction.** The output key Q is computed as Q = P + t*G, where P is the internal public key and t is the TapTweak hash. The tweak is defined as t = H_tag("TapTweak", P || m), where m is the Merkle root of the script tree. If there are no script paths, m is replaced by an empty string and the output is called a *raw internal key* output — a pure key path output with no hidden scripts.

The Merkle tree is a binary tree where each leaf is a script version tag concatenated with the script. Internal nodes are hashes of the concatenation of the left and right child hashes. The tree need not be balanced; BIP 341 defines a control block encoding that allows the spend verifier to reconstruct the tree path.

**BIP 342 — Script changes.** Taproot uses a new script version that includes significant improvements:

- The opcode OP_CHECKSIGADD replaces the old CHECKMULTISIG pattern. In legacy Script, multisignature verification required counting the number of valid signatures and comparing it against the required threshold. OP_CHECKSIGADD simplifies this by incrementing a counter directly. This also eliminates the off-by-one bug that plagued CHECKMULTISIG, where the number of public keys had to be placed before the number of signatures.

- Signature operation counting is removed. Legacy consensus rules capped the number of signature checks per transaction. BIP 342 replaces this with an execution cost model based on the actual work done during script evaluation.

- The Schnorr signature algorithm replaces ECDSA for Taproot inputs. Schnorr is provably secure under the random oracle model, supports signature aggregation, is non-malleable by design, and is faster to verify in batch.

**BIP 343 — Bech32m.** The native SegWit address format Bech32 had a design limitation: when the data portion expanded beyond a certain length, error detection degraded significantly. Bech32m modifies the constant modulus used in the checksum from 1 to 0x3bc6a, restoring robust error detection for all address lengths. Taproot addresses always use Bech32m, not Bech32.

**Activation.** Taproot activated through a Speedy Trial mechanism (BIP 9-style signaling with a 90% threshold within a 2-week mining difficulty period). Miners signaled readiness by setting bit 2 in the block version. After reaching the threshold on block 687,408, the rules locked in and activated on block 709,632 in November 2021.

**Advanced contracts enabled by Taproot.**

- Discreet Log Contracts (DLCs) use Taproot to create conditional payments based on oracle attestations. The oracle signs a message about a real-world event, and the winning party can spend using only the key path if both cooperate, or resolve on-chain using a script path if one party defaults.

- Point Time Locked Contracts (PTLCs) replace Hash Time Locked Contracts (HTLCs) by using Schnorr adaptor signatures and points on the elliptic curve instead of hash preimages. PTLCs offer better privacy because the payment condition is not identifiable as a contract on-chain, and they allow more flexible multi-path payments.

- Cross-input signature aggregation. Schnorr signatures allow multiple inputs in the same transaction to share a single signature. This is not yet standardized but is an active area of research that Taproot enables.

![Key path vs script path spending](media/wiki/taproot/taproot-spending.svg "Key path spending uses a single Schnorr signature. Script path spending reveals one script from the Merkle tree with its proof.")

The design principle of Taproot is that the common case should be cheap and private, while the exceptional case remains possible but is more expensive. By committing to the script tree off-chain and only revealing the used branch, Taproot shifts Bitcoin's scripting model toward a future where most transactions look identical regardless of the conditions they enforce.
