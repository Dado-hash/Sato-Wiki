---
id: wiki.myth-anonymous
slug: myth-anonymous
language: en
category: myths
title: '"Bitcoin is anonymous"'
description: Bitcoin is pseudonymous, not anonymous, because every transaction is public and permanent and addresses can often be linked to people.
coverImage: media/wiki/myth-anonymous/myth-anonymous-hero.svg
difficulty: base
readTimeMinutes: 5
tags:
  - Myths
  - Privacy
  - Pseudonymity
  - Chain Analysis
related:
  - wiki.address-reuse
  - wiki.common-input-ownership
  - wiki.coinjoin
  - wiki.tor
  - wiki.threat-model
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: Protect your privacy
    url: https://bitcoin.org/en/protect-your-privacy
    author: Bitcoin.org contributors
  - title: "A Fistful of Bitcoins: Characterizing Payments Among Men with No Names"
    url: https://cseweb.ucsd.edu/~smeiklejohn/files/imc13.pdf
    author: Sarah Meiklejohn, Marjori Pomarole, Grant Jordan, Kirill Levchenko, Damon McCoy, Geoffrey M. Voelker, Stefan Savage
    publishedAt: 2013-10-23
  - title: "Deanonymisation of clients in Bitcoin P2P network"
    url: https://arxiv.org/abs/1405.7418
    author: Alex Biryukov, Dmitry Khovratovich, Ivan Pustogarov
  - title: CoinJoin - Bitcoin Optech topic
    url: https://bitcoinops.org/en/topics/coinjoin/
    author: Bitcoin Optech
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

False as stated: Bitcoin is pseudonymous, not anonymous. Transactions carry no names, but every transaction is public and permanent, and the addresses they use can often be linked to real people.

Think of a public notice board where everyone signs with a nickname. The nickname does not reveal who wrote a message, but if the same nickname posts for years, and someone once learns who it belongs to, its whole history becomes readable. Bitcoin works in a similar way. An address is a string of characters, not a name, but it stays on the ledger forever, together with its amounts and timing.

Most links come from outside the chain. A service that checks identity documents can connect an account to the addresses it uses, and Bitcoin.org points out that users usually have to reveal their identity to receive goods or services. Reusing an address joins all the payments made to it. Your internet connection can reveal where a transaction started, and a page that shows your address adds another piece. Each piece is weak on its own, but together they can identify a person.

Privacy tools help, yet none makes a payment invisible. Avoiding address reuse, CoinJoin and Tor each hide one kind of link and leave others exposed.

## medium

The whitepaper's privacy section is the place to start. In 2008 Satoshi Nakamoto wrote that the public can see someone sending an amount to someone else "but without information linking the transaction to anyone", and that a new key pair should be used for each transaction. That is pseudonymity: the design keeps names out of the ledger, but it does not keep the transactions unlinked. The same section notes that multi-input transactions "necessarily reveal that their inputs were owned by the same owner."

Researchers have tested how far this goes. In a 2013 study, Meiklejohn and colleagues grouped addresses that were spent together, then made purchases from several businesses to see which clusters belonged to which operators. Their paper calls Bitcoin identities pseudo-anonymous and says that all transactions are completely transparent.

Network data is a second route. In 2014, Biryukov, Khovratovich and Pustogarov showed that a few machines connected to the Bitcoin peer-to-peer network could link pseudonyms to the IP addresses from which transactions were sent, and they reported that the attack was verified experimentally. A user who broadcasts from a home connection without protection gives an observer another clue.

Bitcoin.org draws the practical conclusion: because users usually have to reveal their identity to receive services or goods, "Bitcoin addresses cannot remain fully anonymous." It also suggests Tor so that a computer's IP address cannot be logged.

Each privacy tool addresses one link. Using a new address for each payment stops the reuse link. Keeping coins from different sources apart limits common-input links. CoinJoin builds one transaction with several participants so that outside parties cannot easily match inputs with outputs. Tor hides where a node or wallet connects from. Each tool has costs in fees, time or convenience, and none of them removes what the public ledger already records.

## advanced

The strongest version of the claim runs like this. Bitcoin stores no names, anyone can run a wallet without showing documents, and the chain itself does not state who owns an address. A careful user who never reuses addresses, avoids identity-linked services and hides the network source can make the trail very hard to follow. On this reading, "anonymous" is a loose word for something that is hard to trace in practice, and the privacy of a careful user can be strong.

The reply above rests on three objections that defenders of the strong version should take seriously. First, clustering is probabilistic and its errors run in both directions. Meiklejohn and colleagues chose conservative heuristics on purpose, accepting that many true links would be missed, because one false link can merge unrelated users into a very large cluster. Their results are therefore estimates, and the real linkage may be higher or lower than any one study shows. Second, the strongest links are often off-chain: identity documents at services, shipping details, public posts that reveal an address. A protocol cannot remove those, so calling the protocol anonymous describes only part of the system. Third, the countermeasures are imperfect. Optech notes that CoinJoin works efficiently only with a substantial number of similarly valued inputs, and that a non-private change output can keep a deterministic link back to its input. Tor protects the network location, not the contents of the ledger.

A defender can answer that the claim concerns the protocol, which is public, and that the failures above come from the user's environment or from weak practice. That is a fair narrowing, but it changes the meaning of the word. A user who needs anonymity has to build it around the protocol, and the protocol does not provide a default for doing so.

The claim would become true in the ordinary sense if a widely used version of the protocol hid the graph of payments by default, meaning amounts and the links between senders and receivers, without weakening validation or relying on trusted intermediaries, and if the everyday points where money enters and leaves the system stopped requiring identity. The claim would be clearly false if every common wallet and service route kept leaving reliable links, which is the situation the research above describes. Between those poles, the accurate description is pseudonymous, with strong privacy tools that users must apply correctly.
