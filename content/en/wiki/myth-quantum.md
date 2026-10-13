---
id: wiki.myth-quantum
slug: myth-quantum
language: en
category: myths
title: '"Quantum computers will break Bitcoin"'
description: "Partly true: a large enough quantum computer would threaten signatures on exposed keys, but no such machine exists today and no date is known."
difficulty: base
readTimeMinutes: 5
tags:
  - Myths
  - Quantum
  - Cryptography
  - Signatures
related:
  - wiki.digital-signatures
  - wiki.ecdsa
  - wiki.schnorr-signatures
  - wiki.sha-256
  - wiki.address-reuse
sources:
  - title: Bitcoin Optech - Quantum Resistance
    url: https://bitcoinops.org/en/topics/quantum-resistance/
    author: Bitcoin Optech
  - title: "BIP 360: Pay-to-Merkle-Root (P2MR)"
    url: https://github.com/bitcoin/bips/blob/master/bip-0360.mediawiki
    author: Bitcoin BIP authors
  - title: "BIP 341: Taproot: SegWit version 1 spending rules"
    url: https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki
    author: Bitcoin BIP authors
  - title: "Polynomial-Time Algorithms for Prime Factorization and Discrete Logarithms on a Quantum Computer"
    url: https://arxiv.org/abs/quant-ph/9508027
    author: Peter W. Shor
  - title: "A fast quantum mechanical algorithm for database search"
    url: https://arxiv.org/abs/quant-ph/9605043
    author: Lov K. Grover
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

Partly true. A quantum computer that could break Bitcoin's signatures would be a serious long-term threat, but no such machine exists today, and nobody knows when one might. The threat is also narrower than the claim suggests. It applies mainly to coins whose public key is already visible on the blockchain, while hashing, which secures mining, is much less affected.

Bitcoin protects spending with signatures made from a private key. The public key is derived from that private key, and a signature proves that the spender knows the private key. A quantum computer running a suitable algorithm could in principle work backward from a public key to the private key, which would let an attacker spend coins whose key is exposed. Many addresses hide their public key behind a hash until the coins are spent, so they are exposed much less.

The accurate statement is that the risk is real for some outputs, in a future that is uncertain. Developers have proposals for post-quantum signatures and output types, but none is in Bitcoin yet, and the alternatives involve much larger keys and signatures.

## medium

The mechanism depends on the algorithm. Shor's algorithm, described in a paper available as an arXiv preprint, shows that a sufficiently large quantum computer could factor integers and compute discrete logarithms in polynomial time. Bitcoin's signatures rest on elliptic curve discrete logarithms: ECDSA and Schnorr signatures on the secp256k1 curve. A machine that ran Shor's algorithm at the required size could recover a private key from its public key. Optech says such an attack would eliminate the security of ECDSA, and the same applies to the public keys used by Schnorr signatures.

Exposure is the central variable. Under pay-to-public-key-hash, the output commits only to a hash of the public key, so the key is not visible until the coins are spent. Taproot outputs place a tweaked public key directly in the output script, so that key is visible from the moment the output exists, as BIP 341 specifies. Once a spend has been made, its public key is public.

Hashing is a different case. SHA-256 is used for proof of work and for identifiers. Grover's search algorithm gives a quadratic speed-up for unstructured search, reaching a solution in O(sqrt N) steps according to its arXiv paper. The Optech topic page says this halves the security bits of SHA-256 against preimage attacks, from 256 to 128, and that the loss can be recovered by moving to a function with twice as many security bits. The effect on mining is therefore a much smaller loss than the one Shor's algorithm causes for signatures.

What remains unknown is timing. Optech notes that the capacity and reliability of quantum computers would likely grow gradually, so the security of Bitcoin's cryptography would decline gradually as well. No source here gives a date, and this entry does not give one. BIP 360, which is still a draft, proposes a new output type that removes the key path spend of taproot. It addresses long-exposure attacks, not attacks that act while a transaction waits in the mempool. Post-quantum signatures are the other path, and they are larger.

## advanced

The strongest version of the claim goes beyond present machines. Bitcoin holds a large amount of value in outputs whose public keys are already on the ledger, and an owner who has lost keys or stopped paying attention cannot migrate those coins. A capable adversary could take them without anyone's permission, and the network has no way to stop such a theft, because a valid signature is the only test a node applies when coins are spent. The claim is serious because the ledger is public: anyone can check which keys are exposed, so an attacker can choose the easiest targets in advance.

The objections are serious as well. The short-exposure problem is the sharpest. A transaction that spends from a key reveals that key to the mempool before it is confirmed, and a machine fast enough to derive the private key during that window could race the honest transaction. BIP 360 says its proposed output type addresses long-exposure attacks, and that protection against short-exposure attacks may need post-quantum signatures. Optech notes that quantum-resistant alternatives to ECDSA are known but involve much larger keys and signatures, which makes block space and fees a real constraint.

The reply depends on time. Optech describes a progression from attacks that are computationally infeasible, to theoretically possible but implausible, to extraordinarily expensive, and then to very expensive. It argues that Bitcoin can keep its current cryptography while it remains safe and move to post-quantum cryptography when the threat looks near. That reply has a weakness: it assumes the progress can be seen clearly enough, and that the community agrees early enough to migrate. Forcing migration, by freezing or destroying exposed coins, would be a contested rule change, because it would affect owners who have not acted, and it would need a fork that most of the network accepts.

For the claim to become true, a quantum machine would need to solve elliptic curve discrete logarithms at secp256k1 size within the time a transaction waits in the mempool, and enough exposed coins would need to remain unmigrated to make the attack worthwhile. For the claim to be clearly false, a migration path would have to be deployed and most value moved out of exposed outputs before a capable machine exists. Until then, the open questions are when such a machine could exist and whether the community can move before it matters.
