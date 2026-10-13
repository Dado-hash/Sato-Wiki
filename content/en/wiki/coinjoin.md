---
id: wiki.coinjoin
slug: coinjoin
language: en
category: privacy-security
title: CoinJoin
description: A way for several users to build one transaction together so that outside observers cannot easily match each input with its output.
difficulty: advanced
readTimeMinutes: 5
tags:
  - Privacy
  - CoinJoin
  - Transactions
  - Anonymity Set
related:
  - wiki.common-input-ownership
  - wiki.address-reuse
  - wiki.transaction-fees
  - wiki.threat-model
  - wiki.transactions
sources:
  - title: "CoinJoin: Bitcoin privacy for the real world"
    url: https://bitcointalk.org/index.php?topic=279249.0
    author: Gregory Maxwell
    publishedAt: 2013-08-22
  - title: CoinJoin - Bitcoin Optech topic
    url: https://bitcoinops.org/en/topics/coinjoin/
    author: Bitcoin Optech
  - title: Payjoin - Bitcoin Optech topic
    url: https://bitcoinops.org/en/topics/payjoin/
    author: Bitcoin Optech
  - title: CoinJoin - Bitcoin Wiki
    url: https://en.bitcoin.it/wiki/CoinJoin
    author: Bitcoin Wiki contributors
  - title: "BIP 78: Receiver-initiated PayJoin"
    url: https://github.com/bitcoin/bips/blob/master/bip-0078.mediawiki
    author: Nicolas Dorier
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

CoinJoin is a way for several people to build one Bitcoin transaction together, so that an outside observer cannot easily tell which input paid which output. Each participant contributes coins and receives a new output. The result looks like one transaction with many inputs and many outputs, and the public ledger does not show which output belongs to which contributor.

Gregory Maxwell proposed the idea in 2013 on the bitcointalk forum. The key observation is that the signatures on the inputs are independent of one another. Participants can agree on the set of inputs and outputs, sign their own inputs separately, and merge the signatures. The transaction is not valid until every signature is present, so no participant can take another's coins.

The privacy comes from ambiguity. If several outputs have the same amount, an observer can only say that any of them could have come from any input of that amount. The larger the group of indistinguishable outputs, the larger the anonymity set. A transaction with two participants gives little protection. A transaction with many participants, or several rounds one after another, gives much more.

CoinJoin does not hide that the transaction was joined. It makes the link between an input and an output harder to establish. It also has costs: fees, timing and small mistakes can undo the benefit.

## medium

In Maxwell's proposal, the participants agree on a uniform output size and each provides inputs that cover at least that size. The transaction then has one output of that size per participant, plus change outputs for anyone who contributed more than the target. Every participant signs the same transaction. Maxwell stressed that no one is at risk of theft at any point, because no one will sign a transaction that is not to their liking.

The participants still need a way to meet. In the simplest form they connect directly, for example over an anonymous network such as Tor, and negotiate the transaction. In that case each participant learns which input maps to which output, because they all see the same data. A more common design uses a coordinator, a server that collects inputs and output addresses, builds the transaction and asks each participant to sign. The coordinator learns the mapping between inputs and outputs, but it still cannot spend the coins, because every participant's signature covers only a transaction that the participant has accepted.

Coordinators differ in what they see. Some learn the mapping and the connection details of each participant. Some designs are built so that even the coordinator does not learn which input maps to which output. Maxwell described blinded output addresses as one such approach, where participants receive signed tokens that they can later exchange for addresses without the server seeing the link.

Bitcoin Optech describes the goal as making it difficult for outside parties to use the transaction history to determine who owns which coin. The result is a set of possible matches rather than a certain one, and it is less useful when amounts or timing make some matches obvious.

CoinJoin is a privacy technique for the transaction graph. It does not change the consensus rules, and it does not hide your IP address, so it is usually combined with network privacy measures such as Tor. The entry on Tor explains that part.

## advanced

The anonymity set of one CoinJoin transaction is bounded by its number of participants, because an observer can only narrow an output to the inputs in the same round. Maxwell noted that the set can grow beyond that bound. If several rounds are chained so that outputs of one round feed the next, a link across the whole sequence is much harder to follow. As an example he described three stages of transactions with 32 inputs each, which would let any of 1024 final outputs have come from any of 1024 original inputs using 96 transactions.

Equal output amounts are central to the design. When every output in a round has the same size, an output can only be compared with other outputs of that size. Change outputs, and outputs of different sizes, narrow the set, so amount design affects privacy as much as the number of participants does.

Trust depends on the design. A coordinator sees the mapping in designs where it builds the transaction, and it decides which inputs are accepted into a round. Protocols that use blinded tokens reduce what the coordinator learns, at the cost of more complexity. Designs without a single coordinator, such as the maker and taker model that Joinmarket uses, move the coordination to the participants. In every case a participant signs only what it has accepted, so no one gives up control of its coins to join.

The costs are real. Each participant pays a share of the fee, and some services add a coordinator fee. All inputs must be available at the same time, so a round can fail if one participant drops out, and retrying creates timing patterns that an observer can study. A participant also needs a coin of the right size when the round starts.

Mistakes after mixing can undo the benefit. If a mixed output is later spent together with an unmixed coin, the common-input assumption links the two again.

PayJoin, specified in BIP 78, is a two-party variant. The receiver contributes one of its own inputs and adjusts its output, so the transaction no longer has the single-owner input pattern that analysts rely on. The receiver publishes a PayJoin endpoint in a BIP 21 URI, and the sender should contact it only over authenticated and encrypted transport. Its anonymity set is limited to the two parties.

This entry describes how the protocols work. It does not assess any particular service or implementation.
