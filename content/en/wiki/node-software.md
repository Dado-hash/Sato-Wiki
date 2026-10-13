---
id: wiki.node-software
slug: node-software
language: en
category: software
subcategory: nodes
title: Node Software
description: The programs that run a full node, why more than one independent implementation exists, and how to check what you install.
coverImage: media/wiki/node-software/node-software-hero.svg
difficulty: base
readTimeMinutes: 4
tags:
  - Full Nodes
  - Software
  - Consensus
  - Verification
related:
  - wiki.full-nodes
  - wiki.consensus-rules
  - wiki.forks-and-soft-forks
  - wiki.mempool
  - wiki.server-software
sources:
  - title: Running A Full Node
    url: https://bitcoin.org/en/full-node
    author: Bitcoin.org contributors
  - title: Bitcoin Core downloads
    url: https://bitcoincore.org/en/download/
    author: Bitcoin Core contributors
  - title: Bitcoin Core Guix build documentation
    url: https://github.com/bitcoin/bitcoin/blob/master/contrib/guix/README.md
    author: Bitcoin Core contributors
  - title: Reproducible builds
    url: https://bitcoinops.org/en/topics/reproducible-builds/
    author: Bitcoin Optech
  - title: Bitcoin Knots
    url: https://github.com/bitcoinknots/bitcoin
    author: Bitcoin Knots contributors
  - title: btcd, an alternative full node implementation in Go
    url: https://github.com/btcsuite/btcd
    author: btcsuite contributors
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

Node software is the program that runs a full node. A full node checks every block and transaction against the consensus rules before accepting it, and then passes valid data on to other nodes. If you run one, you do not have to rely on someone else's view of which payments are valid.

Several programs can do this job. Each one is an implementation: separate code, written to follow the same rules. Bitcoin Core is the implementation most people run. Bitcoin Knots is a derivative of Core. Its development generally happens in Core and is merged into Knots for each release, and Knots adds changes of its own. btcd is an alternative implementation written in Go, so it does not share Core's code at all.

Because the software decides what your node accepts, check where it came from before you run it. Bitcoin Core publishes checksums and signatures for its releases, and you can compare the file you downloaded with them. Updating to a newer release also matters, because fixes to validation code reach your node only when you install them.

## medium

An implementation is the answer to one question: how does this program read the rules? Serious implementations aim to accept the same blocks, but they are written by different people, in different languages, with different code paths. In most cases they agree. When they disagree on a consensus rule, two nodes can treat the same block differently and follow different chains. Running more than one implementation means a bug in one of them does not have to define the whole network's view, but every implementation has to be checked and fixed on its own.

Policy is a separate layer. Consensus rules decide whether a block is valid. Policy settings decide which transactions a node keeps in its mempool and relays to peers. Bitcoin.org describes a blocks-only mode, in which a node stops requesting and relaying loose transactions and accepts transactions only when they arrive inside blocks. That is a policy choice, not a change to what counts as valid. Two nodes with different policies can still accept the same chain.

Storage is another choice. An archival node keeps the full block history and can serve old blocks to other peers. A pruned node still downloads and validates the chain, but deletes old block data to save disk space. Pruning is incompatible with some optional indexes, such as the transaction index that Bitcoin Core builds with the txindex option, so the choice affects what other software can do with your node.

Release verification is the last step. Bitcoin Core's Guix build process is designed so that independent builders can produce identical binaries, and each builder signs an attestation of the hashes it got. If you compare your file with those attestations, you check the binary itself, not only the website that offered it. Reproducible builds reduce the need to trust a single build machine.

## advanced

The split between consensus and policy matters most when you read what a node does. Consensus rules decide whether a block can belong to the best chain. Policy decides what a node relays and keeps before a block is mined. A transaction that one node refuses by policy can still be valid, and a miner running different policy may include it. This is why an implementation can change its defaults without forking the network, while a change to consensus needs enough nodes to adopt the new rules for the chain to follow them.

Compatibility risk comes from the consensus side. Implementations can disagree on rare paths in the rules, such as unusual script cases or old blocks that were rarely validated. The disagreement may stay hidden until a block triggers it. Reproducible builds help here: when people compile the same source and get identical binaries, they can be more confident that their node enforces the same behavior as the rest of the network. A build that cannot be reproduced leaves users trusting whoever published it.

Verification has layers. You can check the published checksums against the file, check the signatures on the checksum list with keys you trust, and, for Core's Guix builds, compare the attestations of several builders. Each layer answers a different question. The checksums show that the file matches what was signed. The signatures show who signed it. Independent attestations show that the binary can be rebuilt from the source. None of them checks that the source itself is safe, which is why open review of the code still matters.

Pruning and archival operation are a resource trade-off. A pruned node keeps the chainstate it needs to validate new blocks, but it cannot serve old blocks to peers or support tools that depend on full indexes. An archival node needs much more disk space but can answer historical requests. Both validate from the genesis block, so the choice does not change what they accept, only what they store and share.

There is no single best implementation. The validation role is the same across them. What differs is the set of features, default policy, indexes, tooling and release practice. The useful question is which implementation matches the job you want the node to do, and whether you can verify the binary you run.
