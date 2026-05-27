---
id: wiki.segregated-witness
slug: segregated-witness
language: it
category: protocol
title: Segregated Witness
description: Un aggiornamento del protocollo che separa le firme delle transazioni dai dati usati per calcolare l'ID della transazione, risolvendo la malleabilità e aumentando la capacità dei blocchi.
coverImage: media/wiki/segregated-witness/segwit-hero.svg
difficulty: advanced
readTimeMinutes: 10
tags:
  - SegWit
  - Aggiornamento Protocollo
  - Scalabilità
  - Malleabilità
  - Transazioni
related:
  - wiki.transactions
  - wiki.blocks
  - wiki.bitcoin-script
sources:
  - title: "BIP 141 — Segregated Witness (Consensus layer)"
    url: https://github.com/bitcoin/bips/blob/master/bip-0141.mediawiki
    author: Eric Lombrozo, Johnson Lau, Pieter Wuille
    publishedAt: 2015-12-21
  - title: "BIP 143 — Transaction Signature Verification for Segregated Witness"
    url: https://github.com/bitcoin/bips/blob/master/bip-0143.mediawiki
    author: Johnson Lau, Pieter Wuille
    publishedAt: 2016-01-13
  - title: "BIP 147 — Dealing with dummy stack element malleability"
    url: https://github.com/bitcoin/bips/blob/master/bip-0147.mediawiki
    author: Johnson Lau
    publishedAt: 2016-03-07
  - title: "BIP 148 — Mandatory activation of Segregated Witness"
    url: https://github.com/bitcoin/bips/blob/master/bip-0148.mediawiki
    author: Shaolin Fry
    publishedAt: 2017-03-03
  - title: "Bitcoin Developer Guide — Segregated Witness"
    url: https://developer.bitcoin.org/devguide/segwit_wallet_dev.html
    author: Bitcoin.org contributors
updatedAt: 2026-05-27T00:00:00Z
---

## base

Segregated Witness (SegWit) è un aggiornamento del protocollo attivato sulla rete Bitcoin nell'agosto 2017. Cambia il modo in cui i dati delle transazioni sono strutturati separando la firma — il dato "witness" — dal resto della transazione. Prima di SegWit, le firme facevano parte dei dati che determinavano l'identificatore di una transazione (txid). Chiunque poteva modificare leggermente una firma prima che la transazione fosse confermata, cambiandone il txid senza invalidarla — un problema chiamato malleabilità delle transazioni. SegWit risolve questo problema mettendo i dati witness in una struttura separata che non influenza il txid. Aumenta anche la capacità effettiva del blocco perché i dati witness contano meno verso il limite di dimensione del blocco.

![Separazione Segregated Witness](media/wiki/segregated-witness/segwit-hero.svg "Le firme vengono estratte dai dati della transazione, rendendo il txid non malleabile.")

## medium

La malleabilità delle transazioni non era solo una preoccupazione teorica. Quando il team di Lightning Network progettò i canali di pagamento, aveva bisogno che il txid di ogni transazione fosse prevedibile prima della conferma in modo che la transazione successiva potesse riferirlo. Se un attaccante poteva cambiare il txid, il canale poteva essere interrotto. SegWit ha risolto il problema rimuovendo le firme malleabili dal calcolo del txid.

L'aggiornamento ha introdotto un nuovo formato di transazione. Il vecchio formato include le firme dentro il campo `scriptSig` di ogni input. Il nuovo formato inserisce un byte marcatore (`0x00`) e un byte flag (`0x01`) dopo il campo versione, mantiene lo `scriptSig` vuoto e aggiunge i dati witness come sezione separata dopo gli output. I nodi che comprendono SegWit validano i dati witness. I nodi vecchi vedono marcatore e flag come una transazione valida ma trivialmente spendibile e ignorano i dati witness — questo design rende SegWit un soft fork, cioè i nodi vecchi continuano a seguire la stessa catena.

![Struttura legacy vs SegWit](media/wiki/segregated-witness/segwit-structure.svg "Il formato SegWit aggiunge marcatore, flag e sezione witness mantenendo i dati core della transazione compatibili.")

SegWit ha anche introdotto il concetto di peso del blocco, misurato in unità di peso (WU). Il vecchio limite di 1 MB è stato sostituito da un limite di 4.000.000 WU. I dati non witness contano 4 WU per byte, mentre i dati witness contano 1 WU per byte. Questo aumenta la capacità effettiva del blocco a circa 1,6–2 MB per le transazioni tipiche e dà ai wallet un incentivo economico ad adottare output SegWit, poiché le loro transazioni sono più piccole e pagano commissioni più basse.

Sono stati introdotti due formati di indirizzo: indirizzi SegWit nativi che iniziano con `bc1` (P2WPKH e P2WSH) e indirizzi SegWit annidati (P2SH-P2WPKH e P2SH-P2WSH) che avvolgono l'output SegWit dentro un output legacy pay-to-script-hash per compatibilità con i wallet che non si erano ancora aggiornati.

L'attivazione richiedeva che il 95 % dei blocchi in un periodo di retarget di 2.016 blocchi segnalasse la propria disponibilità, usando i BIP-9 version bits. Quando la segnalazione era insufficiente, la comunità attivò un user-activated soft fork (UASF, BIP-148) come contingenza, che garantì l'attivazione dell'aggiornamento nei tempi previsti.

## advanced

BIP-141 definisce la specifica core di SegWit. La struttura witness è una lista serializzata di dati witness, dove ogni input della transazione ha uno stack corrispondente di elementi witness. Il witness program, trasportato nello `scriptPubKey` degli output SegWit, consiste in un byte di versione (attualmente `0x00`) seguito dai dati del programma. Questo sistema di versionamento degli script permette aggiornamenti futuri come Taproot, che ha usato la versione witness `0x01`.

La formula del peso per le transazioni è:

- `weight = base_size × 3 + total_size`
- `base_size` è la dimensione serializzata della transazione **senza** i dati witness
- `total_size` è la dimensione serializzata della transazione **inclusi** i dati witness
- Un blocco deve soddisfare `total_weight ≤ 4.000.000 WU`

Poiché i dati witness hanno uno sconto del 75 % rispetto ai dati base (1 byte witness = 1 WU vs 1 byte base = 4 WU), le transazioni SegWit sono più economiche per byte da includere in un blocco. Questo crea un incentivo economico per i wallet ad adottare output SegWit.

La transazione coinbase si impegna verso tutti i dati witness tramite un output `OP_RETURN` speciale. L'impegno è la radice di un albero di Merkle di **wtxid** anziché di txid. Il wtxid impegna tutti i dati della transazione inclusi i witness, mentre il txid impegna solo i dati non witness. Questo permette ai full node di verificare che i dati witness non siano stati manomessi preservando al contempo il vecchio txid per compatibilità.

SegWit ha anche risolto il problema dell'hashing quadratico. Nel sistema legacy, verificare tutte le operazioni di firma in un blocco richiedeva O(n²) hash perché ogni controllo di firma poteva fare hash di una quantità potenzialmente grande di dati della transazione molteplici volte. La validazione SegWit limita i dati da hashare all'input specifico che viene firmato, rendendo la verifica delle firme lineare.

Esistono quattro formati di indirizzo:

- **P2WPKH** (SegWit nativo, `bc1q...`): Pay-to-Witness-Public-Key-Hash, per spese a chiave singola.
- **P2WSH** (SegWit nativo, `bc1q...`): Pay-to-Witness-Script-Hash, per script complessi.
- **P2SH-P2WPKH** (SegWit annidato, `3...`): P2WPKH dentro un wrapper P2SH legacy.
- **P2SH-P2WSH** (SegWit annidato, `3...`): P2WSH dentro un wrapper P2SH legacy.

L'attivazione ha usato BIP-9 version bits con bit 1. I miner segnalavano la propria disponibilità impostando bit 1 nel campo versione del blocco. Una volta che il 95 % dei blocchi in una finestra di segnalazione di 2.016 blocchi aveva segnalato, iniziava un periodo di grazia e SegWit si attivava dopo circa due settimane. Quando la segnalazione si bloccò, BIP-148 (UASF) fu implementato: i nodi imponevano che i blocchi dopo il 1 agosto 2017 dovessero segnalare per SegWit, costringendo i miner ad attivarsi o a rischiare una scissione della catena.
