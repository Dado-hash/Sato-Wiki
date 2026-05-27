---
id: wiki.bitcoin-script
slug: bitcoin-script
language: en
category: protocol
title: Bitcoin Script
description: The stack-based programming language that defines spending conditions and authorization rules for every UTXO on the Bitcoin network.
coverImage: media/wiki/bitcoin-script/script-hero.svg
difficulty: advanced
readTimeMinutes: 10
tags:
  - Script
  - Transactions
  - UTXO
  - Opcodes
  - SegWit
  - Taproot
related:
  - wiki.transactions
  - wiki.utxo-model
  - wiki.blocks
  - wiki.consensus-rules
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: Bitcoin Developer Reference - Transactions
    url: https://developer.bitcoin.org/reference/transactions.html
    author: Bitcoin.org contributors
  - title: "BIP 141 - Segregated Witness"
    url: https://github.com/bitcoin/bips/blob/master/bip-0141.mediawiki
    author: Eric Lombrozo, Johnson Lau, Pieter Wuille
  - title: "BIP 341 - Taproot: SegWit version 1 spending rules"
    url: https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki
    author: Pieter Wuille, Jonas Nick, Anthony Towns
  - title: "BIP 342 - Validation of Taproot Scripts"
    url: https://github.com/bitcoin/bips/blob/master/bip-0342.mediawiki
    author: Pieter Wuille, Jonas Nick, Anthony Towns
updatedAt: 2026-05-27T00:00:00Z
---

## base

Bitcoin Script is the programming language Bitcoin uses to set spending conditions on transactions. Every UTXO carries a locking script, called the `scriptPubKey`, that defines who can spend it. When someone wants to spend that UTXO, they must provide an unlocking script—the `scriptSig` in legacy transactions or the witness in SegWit transactions—that satisfies the locking script's conditions.

Script is stack-based, meaning all operations work on a last-in-first-out stack. There are no variables, loops, or function calls. The language is simple by design and intentionally not Turing-complete. It cannot perform unbounded computation because it has no looping construct and the total number of operations per script is strictly limited.

The core idea is straightforward: the locking script describes a puzzle, and the unlocking script provides the solution. The two scripts are concatenated and executed together. If the combined execution leaves a true value on top of the stack, the spend is valid.

![Locking and unlocking scripts at work](media/wiki/bitcoin-script/script-hero.svg "The locking script (scriptPubKey) guards every UTXO. The spender provides an unlocking script that satisfies its conditions.")

## medium

Script execution combines the unlocking and locking scripts into one sequence. In legacy transactions, the scriptSig is pushed first, then the scriptPubKey runs. In P2PKH this produces:

`<sig> <pubKey> OP_DUP OP_HASH160 <pubKeyHash> OP_EQUALVERIFY OP_CHECKSIG`

The stack starts empty. The signature and public key are pushed, then each opcode consumes, transforms, or pushes new data. The combined script must end with a true value on the stack for the transaction to be valid.

### Common script types

| Type | Locking script (approx.) | Description |
|------|--------------------------|-------------|
| P2PK | `<pubKey> OP_CHECKSIG` | Pay to a public key directly. Rare today. |
| P2PKH | `OP_DUP OP_HASH160 <hash> OP_EQUALVERIFY OP_CHECKSIG` | Pay to a public key hash. The standard for legacy addresses. |
| P2SH | `OP_HASH160 <scriptHash> OP_EQUAL` | Pay to a script hash. The spender reveals the redeem script. |
| P2WPKH | `OP_0 <hash>` | Pay to witness public key hash. SegWit version of P2PKH. |
| P2WSH | `OP_0 <scriptHash>` | Pay to witness script hash. SegWit version of P2SH. |
| P2TR | `OP_1 <x-only-pubkey>` | Pay to Taproot. Supports key-path and script-path spending. |

### Combined execution

Bitcoin nodes do not evaluate the scriptSig and scriptPubKey separately. They concatenate the two and run them as one program. This design was chosen so that the locking script can validate the data the unlocking script provides inside the same execution environment.

### ScriptSig vs. Witness

Before SegWit, all unlocking data lived in the `scriptSig` field inside the transaction input. This meant the signature itself was part of the data that the `txid` committed to—making the transaction ID malleable: third parties could change the signature representation and change the txid without invalidating the spend.

SegWit moved the unlocking data into a separate witness structure. The witness is not included in the `txid` computation. This eliminated the malleability vector and allowed nodes to validate scripts without transmitting witness data to non-SegWit peers.

## advanced

### Opcode categories

Bitcoin Script opcodes are divided into functional groups. Only a subset is enabled in the current consensus rules.

**Stack operations.** `OP_DUP` duplicates the top item. `OP_SWAP` swaps the top two items. `OP_DROP` removes the top item. `OP_PICK` and `OP_ROLL` copy or move an item from deeper in the stack.

**Arithmetic.** `OP_ADD`, `OP_SUB`, `OP_NEGATE`, `OP_ABS`, `OP_WITHIN`. Numbers are encoded as little-endian signed integers up to 4 bytes. Arithmetic opcodes push numeric results back onto the stack.

**Bitwise.** `OP_EQUAL` and `OP_EQUALVERIFY` compare two items for exact byte equality. Several bitwise opcodes like `OP_AND`, `OP_OR`, `OP_XOR`, `OP_LSHIFT`, and `OP_RSHIFT` exist in the original specification but are disabled in Bitcoin Core.

**Crypto.** `OP_RIPEMD160`, `OP_SHA1`, `OP_SHA256`, `OP_HASH160` (SHA256 followed by RIPEMD160), and `OP_HASH256` (double SHA256) compute hashes. `OP_CHECKSIG` verifies an ECDSA signature against a public key and message. `OP_CHECKMULTISIG` verifies M-of-N multisignature. Taproot introduced `OP_CHECKSIGADD` for aggregated Schnorr verification.

**Timelock.** `OP_CHECKLOCKTIMEVERIFY` (BIP-65) rejects a spend until a block height or UNIX timestamp is reached. `OP_CHECKSEQUENCEVERIFY` (BIP-112) rejects a spend until a relative number of blocks or time has passed.

### Script limits

Consensus rules enforce strict limits on script evaluation:

- **201 opcode limit.** No script may contain more than 201 non-push opcodes. Push operations (data pushes) are not counted.
- **10,000 signature operations.** The total number of signature-checking operations across all inputs in a block may not exceed 10,000. This limits block validation CPU time.
- **Stack element size.** Each element on the stack may be at most 520 bytes in legacy scripts. SegWit increased this for certain contexts.
- **Script size.** Non-SegWit scripts are limited to 10,000 bytes. SegWit scripts have a 10,000 byte limit for the script part of the witness.
- **Stack depth.** The combined stack may hold at most 1,000 elements.

### SegWit script changes

SegWit (BIP 141) fundamentally changed how scripts are validated. In a SegWit input, the `scriptSig` is replaced with a push of the witness program, and the actual witness data is placed in a separate `witness` field outside the transaction body.

The critical consequence: the witness is not committed to by the `txid`, only by the `wtxid`. This means:
- Transaction malleability no longer applies to SegWit spends.
- Nodes can prune witness data after validation without breaking future transaction references.
- Script versioning became possible: the witness version byte (currently 0 or 1) selects the validation rules.

P2WPKH is the SegWit equivalent of P2PKH but uses a smaller proof and moves the public key and signature into the witness. The `scriptPubKey` is simply `OP_0 <20-byte-hash>` — only 22 bytes versus the 25 bytes of a P2PKH `scriptPubKey`.

### Taproot and MAST

Taproot (BIP 341, activated in 2021) introduced the most significant script changes since SegWit. The core innovation is the Merkelized Abstract Syntax Tree (MAST).

In a MAST-based spend, the locking script commits to a Merkle tree of script leaves. The spender reveals only the script they actually execute and the Merkle path proving it is in the tree. This means:

- Unused spending conditions remain hidden at spend time.
- Large multisignature or complex contracts appear as a single public key on chain unless an alternative path is taken.
- Privacy improves because most spends look identical.

Taproot adds two spending paths:

**Key-path spending.** The simplest and most common. The spender provides a Schnorr signature for the public key committed in the `scriptPubKey`. No script is revealed at all. This is the default for single-signer wallets.

**Script-path spending.** The spender reveals which leaf script they are executing plus the Merkle path to that leaf. The script is then evaluated normally. This path is used when the key-path signer is unavailable or when the spend must satisfy a multisignature or timelock condition.

### OP_CHECKSIGADD and Schnorr

Taproot replaced the old `OP_CHECKMULTISIG` with a new opcode, `OP_CHECKSIGADD` (BIP 342). Instead of the awkward M-of-N design with its infamous off-by-one bug (where a dummy element must be pushed before the signatures), `OP_CHECKSIGADD` uses an accumulator:

Start with a counter of 0. For each public key, execute `OP_CHECKSIGADD`. If the signature matches that key, the counter increments by 1. At the end, check that the counter is at least the required threshold.

Schnorr signatures (BIP 340) enable this design because they support batch verification: multiple signatures can be validated together faster than validating each individually. Schnorr also enables signature aggregation, where multiple signers produce a single signature for a single public key.

### Disabled opcodes and safety

Several opcodes from the original specification are disabled in Bitcoin Core. They remain disabled because they were found to be dangerous or poorly specified:

- **OP_CAT.** Concatenates two stack elements. Disabled because it could be used to build recursive structures and enable denial-of-service attacks.
- **OP_LSHIFT, OP_RSHIFT.** Bitwise shifts. Disabled after integer overflow concerns.
- **OP_OR, OP_AND, OP_XOR.** Bitwise logic. Disabled to limit the expressiveness of scripts and avoid unexpected behavior.
- **OP_VERIF, OP_VERNOTIF.** Conditional opcodes that could create opaque spending conditions.
- **OP_MUL, OP_DIV, OP_MOD.** Arithmetic that was disabled after the 2010 overflow incident.

The general principle is conservative: if an opcode enables computation that cannot be bounded or introduces ambiguity about its effect, it stays disabled. The Bitcoin community has consistently prioritized predictability and security over expressiveness. New opcodes require a BIP, careful analysis, and broad consensus before activation.

![P2PKH script execution flow](media/wiki/bitcoin-script/script-execution.svg "Each step of a P2PKH script execution, showing the stack before and after every opcode.")
