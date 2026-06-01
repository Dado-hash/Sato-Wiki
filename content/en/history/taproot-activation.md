---
id: history.taproot-activation
slug: taproot-activation
language: en
date: 2021-11-14
title: Taproot Activation
category: protocol
summary: Taproot (BIP 340-342) activates on Bitcoin mainnet, introducing Schnorr signatures, MAST, and improved smart contract privacy and efficiency.
sources:
  - title: BIP 340 (Schnorr)
    url: https://github.com/bitcoin/bips/blob/master/bip-0340.mediawiki
  - title: BIP 341 (Taproot)
    url: https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki
  - title: BIP 342 (Tapscript)
    url: https://github.com/bitcoin/bips/blob/master/bip-0342.mediawiki
related:
  - wiki.taproot
  - wiki.schnorr-signatures
updatedAt: 2026-05-28T00:00:00Z
---

On November 14, 2021, Taproot activated on the Bitcoin mainnet at block height 709,632. The upgrade introduced three Bitcoin Improvement Proposals: BIP 340 (Schnorr signatures), BIP 341 (Taproot), and BIP 342 (Tapscript).

![Block 709,632 on a block explorer marking Taproot activation on Bitcoin mainnet.](media/history/taproot-activation/taproot-activation-block.webp "Taproot activation block")

Taproot represented Bitcoin's most significant protocol upgrade since SegWit. It introduced three key innovations. First, Schnorr signatures replaced ECDSA, enabling signature aggregation — multiple parties could produce a single signature for a multi-signature transaction, reducing data and improving privacy. Second, MAST allowed complex smart contracts to be revealed only partially upon execution, making simple transactions indistinguishable from complex ones. Third, Taproot's new scripting language — Tapscript — improved efficiency and flexibility.

The activation process was notably smooth compared to previous upgrades. Unlike the contentious SegWit debate of 2017, Taproot enjoyed broad consensus from miners, developers, and users. Over 90% of miners signaled readiness within weeks of the signaling period's start.

Taproot's privacy and efficiency improvements had implications for various Bitcoin use cases. Multi-signature wallets became cheaper and more private. Lightning Network channels benefited from reduced transaction sizes. Complex smart contracts like DLCs and vaults became more practical. The upgrade demonstrated Bitcoin's capacity for continued technological evolution through well-designed soft forks.
