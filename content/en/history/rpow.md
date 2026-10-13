---
id: history.rpow
slug: rpow
language: en
date: 2004-08-15
title: Hal Finney Announces RPOW
category: origin
summary: Hal Finney announces Reusable Proofs of Work (RPOW), a server that exchanges hashcash tokens for tokens that can be spent once more.
tags:
  - RPOW
  - Proof of Work
  - Hal Finney
  - Digital Cash
sources:
  - title: "RPOW - Reusable Proofs of Work (cryptography list repost)"
    url: https://www.metzdowd.com/pipermail/cryptography/2004-August/007362.html
    author: Hal Finney
    publishedAt: 2004-08-15
  - title: RPOW - Reusable Proofs of Work
    url: https://web.archive.org/web/2004/http://www.finney.org/~hal/rpow/
    author: Hal Finney
  - title: RPOW - Reusable Proofs of Work
    url: https://nakamotoinstitute.org/library/rpow/
    author: Hal Finney
related:
  - wiki.proof-of-work
  - history.hashcash
  - history.bit-gold
  - history.bitcoin-whitepaper
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

On August 15, 2004, Hal Finney announced RPOW, short for Reusable Proofs of Work, on the cypherpunks mailing list. The announcement was reposted the same day on the cryptography list hosted at metzdowd.com. Finney described RPOW as the first public implementation of a server that lets users exchange proofs of work for new tokens, so that a token could pass from one person to another.

The system took hashcash tokens as input. Hashcash tokens are values whose SHA-1 hashes have many high bits set to zero, so they take real computation to produce and are quick to check. A user gave a token to the RPOW server and received a new one in return, which could be used once and exchanged again. This sequential reuse meant that a single proof of work could be passed along a chain, with each step producing a fresh token. Finney argued that this made proofs of work more practical for several purposes while keeping the cost of creating a token meaningful.

RPOW had clear limits. The server's integrity rested on trust in its hardware and software. Finney ran it on a secure processor and let third parties verify which program was running on it, but users still had to rely on the server to keep the tokens honest. The project's archived pages later state that it was terminated, and they are kept only for historical purposes. Because a single server issued and checked every token, the design did not remove the trusted third party from the system.

The Bitcoin whitepaper does not cite RPOW. Its eight references cover b-money, Hashcash and timestamping work, and none of them is RPOW. Bitcoin differs in its structure: it replaces the central server with a public chain of proof-of-work blocks that every node verifies. Nick Szabo's bit gold post, which describes a similar goal, mentions Finney's RPOW as an implementation of one of its variants, so RPOW belongs to the same line of work, with the central server as its defining structural difference from Bitcoin.
