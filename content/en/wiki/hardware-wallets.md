---
id: wiki.hardware-wallets
slug: hardware-wallets
language: en
category: hardware
subcategory: hardware-wallets
title: Hardware Wallets
description: Signing devices that keep private keys off the computer, what they protect against, and what they leave to the user.
difficulty: base
readTimeMinutes: 5
tags:
  - Hardware Wallets
  - Signing
  - Security
  - PSBT
related:
  - wiki.private-keys
  - wiki.wallet-seeds
  - wiki.software-wallets
  - wiki.multisig
  - wiki.digital-signatures
sources:
  - title: "BIP 174 - Partially Signed Bitcoin Transaction Format"
    url: https://github.com/bitcoin/bips/blob/master/bip-0174.mediawiki
  - title: Exfiltration-resistant signing
    url: https://bitcoinops.org/en/topics/exfiltration-resistant-signing/
    author: Bitcoin Optech contributors
  - title: Jade firmware README
    url: https://github.com/Blockstream/Jade/blob/master/README.md
    author: Blockstream
  - title: Coldcard firmware README
    url: https://github.com/Coldcard/firmware/blob/master/README.md
    author: Coinkite
  - title: "Mastering Bitcoin - Chapter 5, Wallets"
    url: https://github.com/bitcoinbook/bitcoinbook/blob/develop/ch05_wallets.adoc
    author: Andreas M. Antonopoulos
  - title: Bitcoin.org - Secure your wallet
    url: https://bitcoin.org/en/secure-your-wallet
    author: Bitcoin.org contributors
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

A hardware wallet is a small device that holds the private keys of a Bitcoin wallet and signs transactions inside its own hardware. The computer or phone you use shows balances and prepares payments, but the keys stay on the device. When you send bitcoin, the device checks what it is asked to sign and returns a signature, so the keys never need to be copied to the computer.

The main purpose is to protect the keys from the computer. Malware on a laptop cannot read a key that was never stored there, and it cannot easily forge a signature. Some risks remain. A device can be stolen, a tampered unit can arrive from a seller, and a user can approve a payment without checking it. A hardware wallet lowers one class of risk. It does not make the rest of the setup safe.

Before relying on a device, read the receiving address on its own screen and compare it with the address you intended to pay. Also make sure your seed backup can restore the funds if the device is lost or breaks. The next levels explain how devices differ and what their limits are.

## medium

Hardware wallets differ first in the chip that holds the keys. Some devices use a dedicated secure element, a chip designed to store secrets and resist extraction. Others run the wallet on a general-purpose microcontroller and protect keys with software and memory design. A secure element can make some physical attacks harder, but it is usually closed hardware that users cannot inspect. A microcontroller design is easier to examine, yet its protection depends more on the code running on it.

Firmware is the second design choice. Open-source firmware can be read by anyone, and when the build is reproducible, a user can rebuild the published source and compare the result with the installed code. Closed firmware asks the user to trust the maker's process. Publishing source does not prove that an installed binary matches it, which is why reproducible builds and signature checks matter.

The connection to the computer is the third choice. A device attached by USB or Bluetooth is convenient, but the link carries data the host can see. Air-gapped devices avoid a live link. The unsigned transaction moves to the device as a QR code or from a microSD card, and the signed result comes back the same way. The Partially Signed Bitcoin Transaction format, defined in BIP 174, lets wallets from different vendors hand an unsigned transaction to a signer and receive it back partially signed.

Whatever the connection, check the receiving address and the amount on the device screen before approving. If the computer changed the address, the screen shows what the device will actually pay. Some devices also rely on a companion app on the computer or phone, and that app is another piece of software to keep updated and to check. Verifying the signature of a firmware update before installing it is a simple habit that closes one common gap.

## advanced

Hardware wallets are signers, not full nodes. A device that holds keys can show that it signed something, but it cannot tell you whether the chain is valid. The host computer, or a node you choose, supplies the transaction and the data needed to build it. Keeping the signer and the view of the chain separate is part of the security model, and a compromised host can still show a misleading picture of payments.

One threat that some devices try to resist is exfiltration, where malicious software on the host learns the key through the signature itself, for example through a biased nonce. Bitcoin Optech tracks this topic and links to anti-exfiltration techniques used in some devices, along with work on protocols whose signatures can be audited. These protections are an active area of research and do not replace careful key storage.

Supply chain attacks are a separate risk. A device bought from an unofficial reseller, or one left unattended, can be replaced or modified before it reaches its owner. Open firmware with reproducible builds allows a technical check that the installed code matches the published source, and the Coldcard firmware README describes rebuilding from source for exactly that reason. Closed firmware requires trust in the vendor's signing process. Vendors also publish security advisories when firmware bugs are found. The Coldcard repository documents one such bug that affected entropy in some releases, which is why users should follow the maker's advisories and update channel.

Physical attacks, such as probing a chip or forcing an enclosure open, depend on the hardware design. Dedicated secure elements aim to make these harder, but no device is immune given enough time and resources. A user who is coerced into revealing a secret or approving a payment cannot be protected by the device alone.

The BIP 39 passphrase adds a second secret to the seed. A stolen seed without the passphrase does not give access to the funds held behind that passphrase. A wrong passphrase on restore produces a valid but empty wallet, and the device gives no error to warn the user, because it cannot check the passphrase for correctness. Losing the passphrase makes the funds unrecoverable, and writing it next to the seed defeats its purpose.

Finally, user error remains a common cause of loss: approving a transaction without reading it, buying from an unofficial source, or ignoring a firmware warning. A good design reduces the surface, but the user still decides what to sign.
