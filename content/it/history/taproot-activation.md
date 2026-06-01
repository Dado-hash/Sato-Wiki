---
id: history.taproot-activation
slug: taproot-activation
language: it
date: 2021-11-14
title: Attivazione di Taproot
category: protocol
summary: Taproot (BIP 340-342) si attiva sulla mainnet di Bitcoin, introducendo firme Schnorr, MAST e maggiore privacy ed efficienza per gli smart contract.
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

Il 14 novembre 2021, Taproot si attivò sulla mainnet di Bitcoin all'altezza blocco 709.632. L'aggiornamento introdusse tre Bitcoin Improvement Proposals: BIP 340 (firme Schnorr), BIP 341 (Taproot) e BIP 342 (Tapscript).

![Blocco 709.632 su un block explorer che segna l'attivazione di Taproot sulla mainnet di Bitcoin.](media/history/taproot-activation/taproot-activation-block.webp "Blocco attivazione Taproot")

Taproot rappresentò l'aggiornamento del protocollo più significativo di Bitcoin dopo SegWit. Introdusse tre innovazioni chiave. Primo, le firme Schnorr sostituirono ECDSA, consentendo l'aggregazione delle firme — più parti potevano produrre un'unica firma per una transazione multi-firma, riducendo i dati e migliorando la privacy. Secondo, MAST permetteva che contratti intelligenti complessi venissero rivelati solo parzialmente all'esecuzione, rendendo le transazioni semplici indistinguibili da quelle complesse. Terzo, il nuovo linguaggio di scripting di Taproot — Tapscript — migliorò efficienza e flessibilità.

Il processo di attivazione fu notevolmente fluido rispetto agli aggiornamenti precedenti. A differenza del dibattito acceso su SegWit del 2017, Taproot godette di ampio consenso da parte di miner, sviluppatori e utenti. Oltre il 90% dei miner segnalò la disponibilità entro poche settimane dall'inizio del periodo di signaling.

I miglioramenti in termini di privacy ed efficienza di Taproot ebbero implicazioni per vari casi d'uso di Bitcoin. I portafogli multi-firma divennero più economici e privati. I canali della Lightning Network beneficiarono di dimensioni ridotte delle transazioni. Contratti intelligenti complessi come DLC e vaults divennero più pratici. L'aggiornamento dimostrò la capacità di Bitcoin di continuare l'evoluzione tecnologica attraverso soft fork ben progettati.
