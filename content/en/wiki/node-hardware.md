---
id: wiki.node-hardware
slug: node-hardware
language: en
category: hardware
subcategory: node-hardware
title: Node Hardware
description: What a computer needs to run a Bitcoin full node, including storage, memory, bandwidth, power, and the choice between hardware types.
coverImage: media/wiki/node-hardware/node-hardware-hero.svg
difficulty: base
readTimeMinutes: 5
tags:
  - Full Node
  - Storage
  - Hardware
  - Uptime
  - Pruning
related:
  - wiki.full-nodes
  - wiki.node-software
  - wiki.node-operating-systems
  - wiki.utxo-model
  - wiki.peer-to-peer-network
sources:
  - title: Bitcoin.org - Running a full node
    url: https://bitcoin.org/en/full-node
    author: Bitcoin.org contributors
  - title: Bitcoin Core - Reducing bandwidth usage
    url: https://github.com/bitcoin/bitcoin/blob/master/doc/reduce-traffic.md
    author: Bitcoin Core contributors
  - title: Bitcoin Developer Guide - Operating Modes
    url: https://developer.bitcoin.org/devguide/operating_modes.html
    author: Bitcoin.org contributors
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

A full node needs a computer that can keep up with the blockchain and check every block it receives. The heaviest work happens during the first sync, when the node downloads the full history and verifies it. After that, the node mostly needs reliable storage, a steady network connection and enough uptime to stay in step with the network.

Storage is the first concern. The node keeps block data and a database of unspent outputs. Both grow over time. A node that keeps the full history needs a lot of space, while a pruned node discards older block files and needs less. The chain keeps growing, so check the node software documentation for current figures instead of relying on a number from a guide. Disk speed matters too. Bitcoin.org sets a minimum read and write speed for storage, because a slow disk makes the first sync take much longer.

Memory and processor matter for the first sync, because every block is verified and the processor is busy for the whole download. Bandwidth matters because the node sends and receives data continuously. Uptime matters because a node that is offline cannot relay blocks, and it must catch up when it comes back.

## medium

Several kinds of machine can run a node. A single-board computer, such as a small Linux board, uses little power and fits in a closet, but its memory and storage options are limited, and some boards use an SD card for storage. A mini PC has a faster processor, more memory and room for an internal drive, at a higher cost and power draw. An old laptop or desktop is often a reasonable starting point. It may already have enough memory and a drive, but it needs stable power and may sleep or throttle without warning.

Storage choices follow from the pruning decision. An archival node keeps all block data and can serve historical blocks to peers. A pruned node still validates the whole chain and keeps the current state, but discards older block files. Pruning reduces disk use and still lets the node enforce the rules. It does not keep old blocks, so the node cannot serve them to other peers.

Bandwidth is a planning item. The node uploads and downloads blocks and transactions every day. Bitcoin Core documentation notes that default settings can use significant traffic, mostly from serving historical blocks during the initial sync, and it offers an upload target that limits this. Check your data plan and whether your connection is metered before choosing a setting.

Power and uptime come next. The node is most useful when it runs continuously. Bitcoin.org recommends running the node for most of the day, ideally at all times, and disabling sleep or suspend modes. A battery backup protects against short outages. SD cards tolerate fewer write cycles than most drives, so using one for a node is a deliberate choice that needs monitoring.

Pre-built node boxes are a category of ready-made devices that bundle hardware and node software. They save setup time.

## advanced

The hardware load of a node comes mainly from initial block download and the chainstate. During the download, the node requests historical blocks, verifies each one, and writes the results to its database. Verification uses the processor heavily, and the database performs many small reads and writes. A node that syncs on a slow disk can take much longer than one on a fast disk, so the minimum speed on bitcoin.org should be read as a floor rather than a target.

The chainstate is the set of unspent outputs that the node needs to validate new blocks. Its size is separate from the stored block history, and pruning removes block files while keeping this state. Because the state is updated for every connected block, the storage must handle a steady stream of small writes, not only large sequential transfers. Drives that are built for constant use are generally a safer choice than cards built for occasional writes.

Bitcoin Core exposes several settings that shape resource use: pruning, the number of peer connections, the upload target, and the number of threads used for signature verification. The default connection limits allow a large number of peers, which is useful for the network but adds traffic. The upload target stops serving historical blocks once a daily budget is reached. That protects a limited connection, but a node that refuses to serve old blocks is less useful to new nodes that need them. Owners should set these values on purpose.

Reliability is a hardware concern too. A sudden power loss during a database write can damage the data, so a battery backup or a journaling file system reduces the risk. Small machines can slow down when they get hot, and a throttled node can fall behind. Remote access needs care: if the node is reachable from outside, its management interface should be protected and kept up to date.

The choice of hardware does not change what the node validates. The same rules apply on a single-board computer, a mini PC or a server. Better hardware mainly changes how long the first sync takes, how much traffic and power the node uses, and how many other tasks it can run alongside Bitcoin software.
