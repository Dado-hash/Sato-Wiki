---
id: wiki.mining
slug: mining
language: en
category: protocol
title: Mining
description: The process of finding valid blocks through proof of work, assembling block candidates, and coordinating hash power across the network.
coverImage: media/wiki/mining/mining-hero.svg
difficulty: advanced
readTimeMinutes: 10
tags:
  - Mining
  - Proof of Work
  - ASIC
  - Mining Pool
  - Consensus
related:
  - wiki.proof-of-work
  - wiki.blocks
  - wiki.sha-256
  - wiki.difficulty-adjustment
  - wiki.transactions
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: Bitcoin Developer Reference - Block Chain
    url: https://developer.bitcoin.org/reference/block_chain.html
    author: Bitcoin.org contributors
  - title: Bitcoin Core miner implementation
    url: https://github.com/bitcoin/bitcoin/blob/master/src/miner.cpp
    author: Bitcoin Core contributors
  - title: Stratum V2 Protocol Specification
    url: https://stratumprotocol.org/
    author: Braiins & Block
    publishedAt: 2022-06-01
updatedAt: 2026-05-27T00:00:00Z
---

## base

Mining is the process by which new blocks are added to the Bitcoin blockchain. Miners collect unconfirmed transactions from their mempool, assemble them into a candidate block, and search for a valid proof of work solution. The first miner to find a valid nonce broadcasts the completed block to the network, collects the block subsidy and transaction fees, and the network builds on top of that block.

![Mining operations diagram](media/wiki/mining/mining-operations.svg "Miners select transactions from the mempool and assemble candidate blocks for the proof of work race.")

Every miner competes in a probability race: the more hash attempts per second, the higher the chance of finding a valid block. Finding a block is never guaranteed; it is a random process where each attempt has an equal and independent probability of success.

Miners can work alone (solo mining) or combine their hash power through a mining pool. In a pool, miners share the work and split the rewards proportionally. Pools provide more predictable income, especially for miners with modest hash power.

## medium

Miners do not build a block from scratch on every attempt. They construct a block template from their local mempool by selecting transactions based on fee rate (satoshis per vbyte). Higher-fee transactions are included first, up to the block's size or weight limit. The template is rebuilt periodically as new transactions arrive or existing ones expire.

The first transaction in every block is the coinbase transaction, which is created by the miner. It collects the block subsidy (6.25 BTC as of the 2024 halving, halving every 210,000 blocks) plus all fees from the included transactions. The coinbase also carries the miner's witness commitment (for SegWit validation) and optionally an extranonce field that gives the miner extra search space.

The block header is assembled from six fields:

- **version**: indicates which block rules the block follows
- **previous block hash**: links the block to its parent
- **Merkle root**: a commitment to every transaction in the block
- **timestamp**: the miner's local time (subject to a validity window)
- **nBits**: the compact representation of the current difficulty target
- **nonce**: a 4-byte field the miner increments for each attempt

The miner computes a double-SHA-256 hash of the 80-byte header. If the hash is below the target encoded in nBits, the block is valid. If not, the miner changes the nonce, timestamp, or coinbase data and tries again.

Because the nonce is only 4 bytes (2^32 possible values), a single miner can exhaust it quickly. Modern ASIC miners use two additional techniques to extend the search space:

1. **Coinbase extranonce**: the miner varies extra data inside the coinbase transaction, which changes the Merkle root and therefore the header hash.
2. **Timestamp rolling**: the miner increments the timestamp within a valid window to produce a different header.

These techniques allow the miner to try trillions of hashes without rebuilding the block template.

The actual hash is computed on the block header alone, not the full block. This is critical for efficiency: the header is 80 bytes versus a block that can be several megabytes. The Merkle root commits to the full transaction list, so any change to a transaction changes the header hash.

### Mining Pools

Most miners participate in a mining pool to smooth out their income. The pool operates a server that distributes mining work (jobs) to connected miners. Each miner receives a block template with a unique coinbase that identifies their contribution.

Miners submit shares — headers whose hashes are below a pool-defined target (easier than the network target) but not necessarily valid for the network. Shares prove that the miner was working on the pool's template. When any miner in the pool finds a block valid for the network, the pool distributes the reward among contributors based on the number and difficulty of shares submitted.

Solo mining is still possible but impractical for all but the largest operations. The variance is extreme: a solo miner with 1% of the network hashrate would find a block on average once every 16 hours, but could easily wait days or weeks between blocks.

## advanced

### ASIC Architecture

Bitcoin mining has gone through three hardware eras:

- **CPU (2009–2010)**: general-purpose processors, anyone with a computer could mine
- **GPU (2010–2013)**: graphics cards offered 10–100x improvement through parallel computation
- **ASIC (2013–present)**: application-specific integrated circuits designed solely for double-SHA-256

An ASIC miner consists of hash boards populated with custom chips, each containing hundreds of SHA-256 engine pipelines running in parallel. A modern ASIC (e.g., Antminer S21, MicroBT M60 series) operates at 100–300 TH/s with power efficiency below 20 J/TH. The chips are designed for maximum hash rate per watt, using low-voltage logic and tightly pipelined datapaths.

The shift from general-purpose hardware to ASICs raised concerns about mining centralization. ASIC manufacturing is concentrated among a few firms (Bitmain, MicroBT, Canaan), and the upfront capital required for large-scale mining favors industrial operations over hobbyists.

### Difficulty and Expected Block Time

Mining is a Bernoulli trial repeated at the miner's hashrate. With network difficulty $D$ and miner hashrate $H$, the expected time to find a block is:

$$T = \frac{D \cdot 2^{32}}{H}$$

The number of blocks found over a time interval follows a Poisson distribution. The probability of finding exactly $k$ blocks in time $t$ with expected block time $\lambda$ is:

$$P(k, t) = \frac{(\lambda t)^k e^{-\lambda t}}{k!}$$

Network hashrate is estimated from the observed block interval and current difficulty. If blocks arrive at an average interval $\bar{t}$, the network hashrate $H_n$ is approximately:

$$H_n \approx \frac{D \cdot 2^{32}}{\bar{t}}$$

### Mining Pool Reward Schemes

Different pools use different methods to distribute rewards:

- **Pay Per Share (PPS)**: miners are paid a fixed amount per share regardless of whether the pool finds a block. The pool bears the variance risk and charges a higher fee (typically 2–4%).
- **Pay Per Last N Shares (PPLNS)**: only shares from a sliding window covering the last $N$ shares are rewarded when a block is found. This discourages pool hopping and aligns miner incentives with the pool.
- **Full Pay Per Share (FPPS)**: also called PPS+, pays both the block subsidy and an estimated transaction fee for each share. This is the most common scheme among large pools as of 2024–2026.

The pool also deducts a fee (0–4%) to cover operating costs and profit.

### Stratum Protocol

The Stratum protocol (V1 and V2) is the standard for pool mining communication. The pool server sends jobs containing:

- The block header prefix (version, prev hash, Merkle root up to the coinbase position)
- The coinbase prefix and suffix (miner fills the extranonce in between)
- The network difficulty target (nBits) and a pool-assigned share difficulty target
- A job ID for result tracking

The miner hashes headers derived from each job, varying the nonce and extranonce. When a hash meets the share target, the miner submits the share (the header and the coinbase extranonce) to the pool. When a hash meets the network target, the miner has found a valid block — the pool broadcasts it and claims the reward.

Stratum V2 adds encryption, better efficiency through negotiated jobs, and allows miners to contribute to block template construction, partially addressing centralization concerns.

### Hashrate and Security

Network hashrate is the sum of all hashing power pointed at the Bitcoin network. It is not directly observable; it is inferred from difficulty and block intervals. The security model assumes that more than 50% of the hashrate is honest. An attacker with majority hashrate could reorganize recent blocks (51% attack), double-spend transactions, or censor blocks.

The game theory of mining creates a strong incentive for honesty: building on valid blocks earns the block reward, while attempting to reorganize confirmed blocks risks wasting hash power on a branch that will not be accepted by the network.

### Centralization Concerns

Two major centralization vectors exist in Bitcoin mining:

1. **ASIC manufacturing**: three companies control the vast majority of ASIC production. Supply chain constraints, geographic concentration, and the high cost of chip fabrication create barriers to entry.

2. **Pool dominance**: as of 2026, the top three mining pools often control more than 50% of the network hashrate. While miners can switch pools freely, the pool operator decides which transactions to include and has the power to censor or reorg in theory.

Solutions being explored include Stratum V2 (which gives miners some control over template construction), better pool diversity through better payout schemes, and geographic diversification of mining operations driven by cheap energy markets worldwide.
