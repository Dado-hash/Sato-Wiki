---
id: wiki.myth-can-be-shut-down
slug: myth-can-be-shut-down
language: en
category: myths
title: '"Governments can shut Bitcoin down"'
description: "Partly true: no state can switch off the network, but a state can ban or restrict its use inside its borders, which is a different and real limit."
difficulty: base
readTimeMinutes: 5
tags:
  - Myths
  - Regulation
  - Full Nodes
  - Mining
related:
  - wiki.full-nodes
  - wiki.peer-to-peer-network
  - wiki.mining
  - wiki.proof-of-work
  - wiki.myth-miners-control
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: Bitcoin Developer Guide - Operating Modes
    url: https://developer.bitcoin.org/devguide/operating_modes.html
    author: Bitcoin.org contributors
  - title: Cambridge Bitcoin Mining Map
    url: https://ccaf.io/cbnsi/cbeci/mining_map
    author: Cambridge Centre for Alternative Finance
  - title: Bitcoin Mining - New Data Reveal a Surprising Resurgence
    url: https://www.jbs.cam.ac.uk/2022/bitcoin-mining-new-data-reveal-a-surprising-resurgence/
    author: Cambridge Centre for Alternative Finance
    publishedAt: 2022-05-17
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

Partly true. No government, company or server can switch off Bitcoin as a whole, but a government can ban or restrict its use inside its own borders, and that limit is real.

Bitcoin is not run from one place. Its ledger is copied by many full nodes that independent people run in many countries. Each node checks the rules for itself, so turning off one of them does not stop the others, and a copy that breaks the rules is rejected by the rest. To stop the network, someone would have to shut down almost every node at once, in every country, and no authority controls that.

What a government can do is narrower. It can make it illegal to own or mine bitcoin, order exchanges and banks to stop serving its residents, or tax the activity heavily. Those measures make bitcoin hard to buy, sell and mine for people inside that country. They do not stop the network, and people outside the ban keep using it.

The two things are not the same. Stopping the network and making it hard to use in one place are different problems, and the first would need control over most of the world's nodes. The second is easy to do, and it has happened.

## medium

Bitcoin's rules are enforced by software, and every full node runs the same checks. A node downloads blocks from the genesis block and validates them itself, so its view of the ledger does not depend on any single operator. The whitepaper describes a system where the longest chain of proof of work serves as the record of events, with no trusted third party needed to settle disputes.

Mining is the part most exposed to national rules. Miners need cheap electricity, cooling and specialised hardware, so they tend to concentrate where power is inexpensive and policy is tolerant. In June 2021 the Chinese government cracked down on mining. The Cambridge Centre for Alternative Finance (CCAF) reports that the hashrate recorded inside China effectively fell to zero in July and August 2021.

The Cambridge data also show where the activity went. Its dataset running to January 2022, reported in a May 2022 article, puts the United States at about 37.8 percent of global hashrate, up from 35.4 percent in August 2021. Installed capacity in the United States rose from about 42.7 EH/s to about 71.0 EH/s over that period. The same article reports that hashrate recorded in China suddenly returned to about 30.5 EH/s in September 2021, which Cambridge reads as miners that kept operating covertly, so the ban did not end mining even inside the country. These figures come from a sample of mining pool data and change from month to month, so they describe a moment, not a trend.

Exchanges and banks are the other point of pressure. A government can require licences, freeze accounts or order a regulated service to stop serving its residents. Such orders are enforceable because the companies are local. People who hold their own keys are harder to reach, but they still need some way to convert coins into local money, and that is where regulation usually applies.

The cost of a ban is therefore real but limited. It raises the price of using bitcoin inside the country and moves activity elsewhere. It does not change any rule that nodes check.

## advanced

The strongest version of the claim runs like this. Bitcoin's security depends on a few large mining operations, a handful of exchanges and a few dominant wallet providers. Each of these is a legal entity with premises, staff and bank accounts, and states have courts, police and tax offices. A large state that acts together with its banks could make bitcoin useless to most of its residents, and a network whose users are mostly outside the reach of its own rules is a niche. On this view, decentralised validation does not protect the people who need a way in and out.

Several parts of that are serious. Mining is concentrated where power is cheap, and a ban in a major mining country moves hashrate, sometimes at a cost in time and money. Exchanges are the main gate for most newcomers, and their regulation is real. A state can use the banking system to cut off fiat transfers, and then the number of easy routes falls even while the protocol keeps running.

The reply has three parts. First, no order reaches the protocol. The ledger is kept by nodes in many jurisdictions, each enforcing the same rules, and a state cannot change what a foreign node checks. Second, mining moved rather than vanished after the 2021 ban: the Cambridge data show the United States as the largest mining hub in its January 2022 dataset, with installed capacity rising in the same period. Third, the bans so far have targeted access and mining inside one country, not the protocol.

The objections to that reply are also serious. The Cambridge figures come from a sample of pool facilities, and the mining map itself warns that some country shares are likely inflated by VPN and proxy use. Measures aimed at the largest exchanges and custody providers could make the ordinary route much harder even while no node stops. The data do not show that any state has enforced a halt, and they do not show that it could not.

For the claim to become true in the strong sense, a state or coalition would need to control enough hashrate to censor or reorder blocks, or to stop valid blocks from reaching most nodes, or to cut off almost every route by which people buy and sell. For it to be clearly false in that sense, the data would need to show that hashrate and node activity cannot be made to fall together, even after coordinated action in the largest mining countries.
