---
id: wiki.mining-hardware
slug: mining-hardware
language: en
category: hardware
subcategory: mining-hardware
title: Mining Hardware
description: The devices that compute Bitcoin's proof-of-work hashes, from CPUs to ASICs, and what they are made of.
difficulty: base
readTimeMinutes: 5
tags:
  - Mining
  - ASIC
  - Proof of Work
  - Hardware
  - Open Source
related:
  - wiki.mining
  - wiki.proof-of-work
  - wiki.sha-256
  - wiki.mining-energy-economics
  - wiki.mining-software
sources:
  - title: "Mastering Bitcoin - Chapter 12, Mining"
    url: https://github.com/bitcoinbook/bitcoinbook/blob/develop/ch12_mining.adoc
    author: Andreas M. Antonopoulos
  - title: Bitcoin Developer Guide - Mining
    url: https://developer.bitcoin.org/devguide/mining.html
    author: Bitcoin.org contributors
  - title: ESP-Miner
    url: https://github.com/bitaxeorg/ESP-Miner
    author: OSMU contributors
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

Mining hardware is the equipment that computes the hashes required by Bitcoin's proof of work. A miner tries very large numbers of candidate block headers and looks for one whose hash meets the network target. Finding a valid block earns the block reward and fees, and the more hashes a device computes per second, the more attempts it makes.

Bitcoin was first mined on ordinary CPUs. Graphics cards came next, then programmable chips called FPGAs. Each step produced more hashes for the same work. In 2013, ASIC chips produced another large jump in mining power. An ASIC is built to compute only the double SHA-256 function that Bitcoin uses. It is far less flexible than a general computer, but for this one task it is much faster and more efficient.

Today's mining machines are typically built as a box that holds several boards, a control board, a power supply and a cooling system. Some are large industrial units for data centers. Others are small devices for home use that run open-source firmware. The medium level explains how these parts work together and how to compare machines.

## medium

A typical ASIC miner has four main parts. Hashboards carry many chips that run the hash function in parallel. A control board receives work from mining software, sends it to the hashboards, collects the results, and submits valid shares or blocks to a pool or a node. The power supply converts mains electricity into the voltages the chips need. Cooling, usually fans, removes the heat the chips produce. Any part can fail, and a single board is often easier to replace than a whole machine.

The key metric is efficiency, usually expressed in joules per terahash. This is the power consumed divided by the hashing rate, so a lower number means less electricity for the same work. Raw hashrate alone can mislead. A machine with a higher hashrate may draw so much power that it is less efficient. Electricity price affects profitability more than any single device feature, so the same machine can make sense in one place and not in another.

Heat and noise matter at home. Industrial units are placed in facilities with dedicated power and cooling. A small home miner sits in a room, and its fans can be loud and its heat noticeable. The owner has to plan airflow, electrical circuits and the fact that the machine runs all the time.

Home and open-source miners, such as the Bitaxe, use firmware released under an open license, so the owner can inspect and change the software. The ESP-Miner project is open-source firmware for the ESP32 controller on Bitaxe boards, and it is released under the GPL-3.0 license. Large manufacturers sell industrial units, such as the Antminer S series or the Whatsminer M series, designed for larger installations. Whichever machine is chosen, the firmware that runs it is part of the design, and it should be kept up to date.

## advanced

Mining is a race in which a miner's chance of finding a block is proportional to its share of total network hashrate. Difficulty adjusts so that blocks arrive at a steady average interval, which means a single device's chance is tiny relative to the whole network. The Bitcoin Developer Guide describes the choice between solo and pool mining. A solo miner keeps the full block reward and fees, but payments come with high variance, meaning long gaps between rewards. A pool shares the proceeds roughly in proportion to hashing power, which gives smaller and more frequent payments with lower variance.

Mastering Bitcoin uses a simple illustration. A miner with a very small fraction of network hashrate might expect to find a block only once in a long period, if difficulty never changed. Real odds depend on current hashrate and difficulty, which keep changing, so the honest statement is qualitative. Solo mining is a gamble, and pooling trades a share of the reward for predictability.

In a typical setup, a host computer runs a node and passes block headers to the mining hardware, which tests nonce values. When the nonce space is exhausted, the header is changed through an extra nonce, version bits or the timestamp, and testing continues. Mining software is therefore part of the trust boundary. A bug or hostile firmware could produce invalid shares, withhold work, or send hashpower to a pool the owner did not choose. Reviewing firmware, pool settings and updates is part of running the hardware.

The economics depend heavily on electricity. The Mastering Bitcoin chapter notes that the main factor in profitability is the price of a kilowatt-hour, and that the most efficient systems turn electricity into hashing at close to the limit of current silicon. The same chapter describes a home garage full of high-end hardware drawing tens of kilowatts, and contrasts it with commercial operations that stack many thousands of machines near power plants. The fastest consumer systems cannot compete with that scale.

Running this equipment at home raises practical questions. Power draw must fit the electrical circuit, heat must be vented, and noise must be tolerable for the people who live nearby. A miner that runs continuously is a sustained load, so its installation should be treated like any other piece of heavy electrical equipment.
