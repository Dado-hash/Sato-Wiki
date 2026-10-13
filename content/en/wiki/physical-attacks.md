---
id: wiki.physical-attacks
slug: physical-attacks
language: en
category: privacy-security
title: Physical Attacks
description: How physical coercion can defeat cryptographic protection, which factors raise the risk, and the design ideas that reduce it along with their limits.
coverImage: media/wiki/physical-attacks/physical-attacks-hero.svg
difficulty: base
readTimeMinutes: 5
tags:
  - Physical Security
  - Coercion
  - Multisig
  - Timelocks
related:
  - wiki.multisig
  - wiki.self-custody
  - wiki.passphrase
  - wiki.timelocks
sources:
  - title: "xkcd 538: Security"
    url: https://xkcd.com/538/
    author: Randall Munroe
  - title: Securing your wallet
    url: https://en.bitcoin.it/wiki/Securing_your_wallet
    author: Bitcoin Wiki contributors
  - title: Secure your wallet
    url: https://bitcoin.org/en/secure-your-wallet
    author: Bitcoin.org contributors
  - title: Timelocks
    url: https://bitcoinops.org/en/topics/timelocks/
    author: Bitcoin Optech
  - title: "BIP 39: Mnemonic code for generating deterministic keys"
    url: https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki
  - title: "BIP 65: OP_CHECKLOCKTIMEVERIFY"
    url: https://github.com/bitcoin/bips/blob/master/bip-0065.mediawiki
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

Cryptography protects a key against guessing and copying. It does not protect the owner against being made to use the key. A physical attack targets the person, the device or the place where the secrets are kept, and it can succeed even when the mathematics holds. The phrase "$5 wrench attack" is a shorthand for this situation. It comes from an xkcd comic in which the attackers skip the mathematics and use a cheap tool instead.

The risk depends partly on who knows what you hold. The Bitcoin Wiki advises keeping holdings private, because a person whose wealth is known is a more obvious target. Records kept by others can expose holdings as well. A list of customers or account holders reveals who owns what if it leaks, and the same is true of any document that links a name to a set of keys.

Security therefore depends on people as well as on technology. The Bitcoin Wiki notes that holdings are secured by people and not by technology alone, and that hardware devices can be defeated by coercion. The defences in the next levels are design ideas. Each one reduces one risk and leaves others in place, and each has limits that are worth knowing before relying on it.

## medium

Several design ideas address physical attacks, and each has a limit.

Not disclosing holdings reduces the number of people who know there is something worth taking. It works only while the secret holds. Heirs, advisers and service providers may need to know parts of the arrangement, and each one is a possible source of disclosure.

Multisig spreads the ability to spend across several keys. Bitcoin.org notes that a multisig setup can stop a thief from taking the funds when one device or location is compromised. Keys held in separate places, and by different people, mean that no single person can spend alone. The limit is that a person who can be forced to sign may be only one of several signers, and an emergency can make it hard to gather the required signatures in time.

Time delays use timelocks. Bitcoin Optech describes a timelock as a condition that stops a spend from confirming before a set block height or time. BIP 65 defines an absolute timelock of this kind. A vault-style design can make a spend take effect only after a delay, which gives the owner a chance to notice and cancel. A delay helps only if the owner can see what is happening during the waiting period. Someone who is kept under pressure for the whole delay gains nothing from it.

A passphrase wallet used as a decoy relies on BIP 39. Each passphrase produces a valid seed, so a second wallet can exist behind a different passphrase that holds a smaller balance. The value of this idea is debated. The decoy works only if the person applying pressure accepts that the wallet shown is the whole holding. A mistyped passphrase also opens an empty wallet without any error, and losing the passphrase makes its funds unrecoverable. The advanced level takes up these points.

## advanced

The central question is which secret a person can be forced to reveal, and how many people or devices a threat can reach. Each extra secret, signer or location makes an attack costlier, but it also adds to the recovery burden. The design should start from realistic threats and from the people who must be able to act in an emergency.

A PIN or passphrase protects against someone who has only the device, not against someone who can make the owner enter it. The Bitcoin Wiki notes that hardware wallets can be defeated by coercion. Spreading keys across devices and locations means an attacker must reach each one, but the owner must then be able to reach them all as well.

The multisig threshold balances the attacker's reach against the owner's ability to act. In a 2-of-3 arrangement, an attacker must reach two locations, while losing one key does not stop spending. A 3-of-3 arrangement is harder to attack but stops every spend when one key is unreachable. A higher threshold is not automatically safer.

A timelock can create a recovery path that opens after a delay, or a cancellation window in which a separate key can stop an unexpected spend. Bitcoin Optech describes timelocks as encumbrances on outputs, and BIP 65 gives the mechanism for an absolute deadline. Cancellation works only if the cancelling key is available during the window, and the delay also slows the owner's own recovery.

The decoy passphrase relies on BIP 39 accepting every passphrase and deriving a valid seed from each one, which the specification describes as plausible deniability. Three limits follow. A decoy must look like a real holding. A mistyped passphrase opens an empty wallet with no warning, so the owner cannot tell a typo from a decoy. A holder of the seed can test passphrases without the device, so the passphrase must be hard to guess. Whether a decoy protects an owner under real pressure has no settled answer, because it depends on the attacker's behaviour.

Records that link a person to their keys are a risk too. Keeping them minimal and in separate places limits the damage of a leak. No arrangement removes the physical risk. The aim is to make an attack slower, costlier and more visible, while keeping a recovery plan the owner can carry out.
