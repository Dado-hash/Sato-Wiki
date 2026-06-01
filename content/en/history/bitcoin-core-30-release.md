---
id: history.bitcoin-core-30-release
slug: bitcoin-core-30-release
language: en
date: 2025-10-10
title: Bitcoin Core 30.0 Released
category: protocol
summary: Bitcoin Core 30.0 is released, introducing relay policy changes and sparking debate on OP_RETURN, datacarrier limits, and node operational behavior.
sources:
  - title: Bitcoin Core 30.0 Release Announcement
    url: https://bitcoincore.org/en/2025/10/10/release-30.0/
  - title: Bitcoin Core 30.0 Release Notes
    url: https://bitcoincore.org/en/releases/30.0/
related:
  - wiki.full-nodes
  - wiki.mempool
  - wiki.bitcoin-script
updatedAt: 2026-05-28T00:00:00Z
---

On October 10, 2025, Bitcoin Core 30.0 was released, marking a significant update to the reference Bitcoin software implementation. While not a consensus-level change — meaning it did not alter the blockchain's fundamental rules — the release introduced notable modifications to relay policy and node behavior that generated discussion across the Bitcoin development community.

![Bitcoin Core 30.0 terminal output during compilation or node operation.](media/history/bitcoin-core-30-release/bitcoin-core-terminal.webp "Bitcoin Core 30.0 terminal")

The release's key debates centered around OP_RETURN and datacarrier policy — the mechanisms by which data can be embedded in Bitcoin transactions. Since the introduction of OP_RETURN in Bitcoin Core 0.9 (2014), transaction outputs using this opcode have been used for everything from colored coins and asset issuance (Omni, Counterparty) to Ordinals inscriptions and general data storage. Bitcoin Core 30.0 revisited the default datacarrier size limits and relay behavior, prompting discussion about what types of data transactions the network should relay by default.

For node operators, the release included performance improvements and refinements to mempool policy — the rules that determine which transactions a node will accept and relay. These changes affected how nodes handle transaction replacement (BIP 125), fee estimation, and mempool resource management. The release also continued Bitcoin Core's ongoing work on package relay and other mempool improvements that benefit the broader network's transaction processing efficiency.

The significance of Bitcoin Core 30.0 for the historical timeline was twofold. First, it demonstrated the continued vitality of Bitcoin's development process, with contributors iterating on network policy years after the protocol's creation. Second, the debates around relay policy and datacarrier limits highlighted the tensions within the Bitcoin community about the appropriate use of blockchain space — a recurring theme in Bitcoin's governance, from the block size war to Ordinals to every policy parameter that shapes what transactions are economically viable.
