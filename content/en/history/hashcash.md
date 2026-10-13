---
id: history.hashcash
slug: hashcash
language: en
date: 1997-03-28
title: Hashcash Proposed on the Cypherpunks List
category: origin
summary: Adam Back announces Hashcash, a proof-of-work stamp meant to make bulk email costly to send, on the cypherpunks mailing list.
tags:
  - Hashcash
  - Proof of Work
  - Email
  - Cypherpunk
sources:
  - title: "[ANNOUNCE] hash cash postage implementation"
    url: https://diswww.mit.edu/bloom-picayune/crypto/453
    author: Adam Back
    publishedAt: 1997-03-28
  - title: "Hashcash - A Denial of Service Counter-Measure"
    url: http://www.hashcash.org/papers/hashcash.pdf
    author: Adam Back
    publishedAt: 2002-08-01
  - title: Hashcash
    url: https://en.bitcoin.it/wiki/Hashcash
    author: Bitcoin Wiki contributors
  - title: Hashcash - A Denial of Service Counter-Measure
    url: https://nakamotoinstitute.org/library/hashcash/
    author: Adam Back
    publishedAt: 2002-08-01
related:
  - wiki.proof-of-work
  - wiki.hash-functions
  - history.rpow
  - history.bitcoin-whitepaper
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

On March 28, 1997, Adam Back sent an announcement to the cypherpunks mailing list titled "[ANNOUNCE] hash cash postage implementation". The message described a "partial hash collision based postage scheme" and pointed to a first-cut implementation that people could download and test. Back said he had been discussing the idea on the crypto lists for several days before the announcement.

The scheme asked a sender to find a value whose hash begins with a chosen number of matching bits. Finding such a value takes many attempts, so the cost can be set as high as needed, while anyone can check the result with a single hash. Applied to email, the proof is attached to a message as postage, and a recipient or server can refuse mail that lacks it. In December 1997 Back suggested making a would-be spammer spend about 20 seconds of CPU time per message.

The idea had clear limits. It worked only when recipients or servers chose to require the stamp, and a spammer with more computing power could still pay the cost. Adoption stayed limited. Back's 2002 paper, which formally describes the scheme, reports initial experience from experiments and a list of applications and suggested improvements rather than a settled deployment. The paper also gives the date of the original proposal as May 1997, while the announcement itself is dated March 28, 1997.

Hashcash matters for Bitcoin because its CPU cost function is the kind of proof of work that Bitcoin uses. The Bitcoin whitepaper cites Back's paper as reference [6] when it describes a proof-of-work system similar to Hashcash, and it uses proof of work to secure the chain of blocks. Hal Finney's later RPOW project also built on hashcash tokens. Hashcash is therefore one of the direct precursors of Bitcoin's design, though the whitepaper presents its own system rather than adopting Hashcash as it was.
