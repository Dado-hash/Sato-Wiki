---
id: wiki.node-operating-systems
slug: node-operating-systems
language: en
category: software
subcategory: node-systems
title: Home Node Systems
description: Packaged operating systems and app platforms that install a Bitcoin node and related services on a small computer, and what they add on top of the node software.
difficulty: base
readTimeMinutes: 4
tags:
  - Home Node
  - Full Node
  - Self-Hosting
  - Packaged Software
  - Backups
related:
  - wiki.full-nodes
  - wiki.node-software
  - wiki.node-hardware
  - wiki.lightning-software
  - wiki.seed-backups
sources:
  - title: umbrel - umbrelOS repository README
    url: https://github.com/getumbrel/umbrel
    author: Umbrel
  - title: umbrel-apps - Umbrel App Store packages
    url: https://github.com/getumbrel/umbrel-apps
    author: Umbrel
  - title: start-technologies - Start9 monorepo README
    url: https://github.com/Start9Labs/start-technologies
    author: Start9 Labs
  - title: StartOS documentation - Tor
    url: https://github.com/Start9Labs/start-technologies/blob/master/projects/start-os/docs/src/tor.md
    author: Start9 Labs
  - title: StartOS documentation - Creating Backups
    url: https://github.com/Start9Labs/start-technologies/blob/master/projects/start-os/docs/src/backup-create.md
    author: Start9 Labs
  - title: StartOS documentation - Updating
    url: https://github.com/Start9Labs/start-technologies/blob/master/projects/start-os/docs/src/updating.md
    author: Start9 Labs
updatedAt: 2026-10-13T00:00:00Z
reviewedAt: 2026-10-13
---

## base

A home node system is a packaged operating system or app platform that installs a Bitcoin node on a small computer and manages it for you. Instead of configuring every program by hand, you install an image, go through a setup screen, and add applications from a built-in list. Umbrel, StartOS and RaspiBlitz are examples of this type of product.

The package usually includes the full node itself, along with services people often run next to it: an Electrum server so wallets can query the chain, a Lightning node, and an app store where you add or remove other programs. The convenience is real, since updates, dashboards and service installation are handled for you.

That convenience has a cost. You now trust the packager, its app store and its update process, not only the Bitcoin software. A third-party app in the store runs on the same machine as your node. Your node still checks chain data for itself, but the surrounding system decides what else runs and when it changes.

Remote access is the next question. Many systems let you reach the dashboard from outside your home. In StartOS, Tor is one option, and it needs no router configuration. Whatever system you use, backups stay your job.

## medium

Most of these systems are built around a small set of components. The node runs Bitcoin Core or another full node implementation. Electrum-compatible servers let wallets look up balances and history without downloading the chain. A Lightning node adds channel management, and an app store installs optional software from a catalogue. The Umbrel App Store packages include Bitcoin, Core Lightning and several Electrum server implementations.

Each system has its own update model. umbrelOS offers a beta program that users opt into in the settings. StartOS shows pending updates for each registry, lists release notes, and waits for you to click Update. In both cases, the update path is part of your trust decision, because a bad update reaches your node the same way a good one does.

Remote access is where many setups differ. Tor gives you a .onion address that works without opening ports on your router, but StartOS does not include Tor by default, so you must install it as a service first. Tor connections are slower and sometimes unreliable, which the StartOS documentation states plainly. A VPN or a public domain is another path, with more router and DNS setup.

Backups are the part that remains yours. StartOS encrypts its backups with your master password and writes them to a drive you plug in or to a network folder. It excludes the blockchain because a node can rebuild that by syncing again. The documentation says plainly that without backups you will eventually lose data. Keep wallet seed backups as a separate step, as described in the seed backup entry, and never share a seed phrase with any app or service.

Licenses differ between projects. The umbrelOS README says the software is under the PolyForm Noncommercial 1.0.0 license, which allows personal and nonprofit use and asks commercial users to contact the company. The Start9 monorepo is MIT licensed. Read the license of the exact system you plan to run before building a business on it.

## advanced

A home node system turns a single full node into a small platform with its own supply chain. The base layer is still Bitcoin Core validation, which does not change because of the packaging. The risk sits above it: the image you install, the packages from the store, the code that talks to the node over RPC, and the update channel. Each added service increases the amount of software that can reach your node and its wallet data.

Packaging models differ in how they limit that exposure. StartOS states that services run in isolated LXC containers and that packages use a signed, Merkle-archived format that supports cryptographic verification. This does not make a bad package safe, but it gives the operating system a way to check what it installs. A store run by the project and packages added by the community carry different review and trust assumptions, and users should understand which one they are installing from.

Network exposure is the second area. A node that accepts inbound peers on a home connection already exposes some surface. Adding a web dashboard, a public Electrum endpoint or a clearnet domain adds more. Onion services shift part of that exposure to Tor, while still requiring that the dashboard password and the server software stay protected. Default settings and pre-enabled services are part of the same surface, so review them after installation instead of assuming they are minimal.

Recovery is the last area to plan. A packaged system restores its services from its own backup format, and that format is only as useful as your ability to reach the backup later. The StartOS documentation notes that services may exclude certain files or folders from a backup, so check what each service actually saves. Test the restore process on a spare drive before you rely on it, and keep wallet seed backups as a separate step.

Choosing among these systems depends on what you need. Some people want a single appliance with a large app catalogue, while others want a minimal node with fewer moving parts. The trade-off is between convenience, the number of components you trust, and how much you are willing to maintain yourself.
