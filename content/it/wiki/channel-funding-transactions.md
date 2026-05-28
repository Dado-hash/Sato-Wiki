---
id: wiki.channel-funding-transactions
slug: channel-funding-transactions
language: it
category: lightning network
title: Transazioni di Funding del Canale
description: La transazione Bitcoin on-chain che apre un canale di pagamento creando un output multisig 2-of-2 condiviso finanziato da entrambe le parti del canale.
coverImage: media/wiki/channel-funding-transactions/funding-tx-anatomy.svg
difficulty: advanced
readTimeMinutes: 8
tags:
  - Lightning Network
  - Transazione di Funding
  - Multisig
  - On-Chain
related:
  - wiki.payment-channels
  - wiki.commitment-transactions
  - wiki.transactions
  - wiki.multisig
  - wiki.bitcoin-addresses
  - wiki.utxo-model
sources:
  - title: "The Bitcoin Lightning Network: Scalable Off-Chain Instant Payments"
    url: https://lightning.network/lightning-network-paper.pdf
    author: Joseph Poon, Thaddeus Dryja
    publishedAt: 2016-01-14
  - title: "BOLT #2 — Peer Protocol for Channel Management"
    url: https://github.com/lightning/bolts/blob/master/02-peer-protocol.md
    author: Lightning Network Specifications
  - title: "Mastering the Lightning Network"
    url: https://github.com/lnbook/lnbook
    author: Andreas M. Antonopoulos, Olaoluwa Osuntokun, René Pickhardt
    publishedAt: 2021-12-07
updatedAt: 2026-05-27T00:00:00Z
---

## base

Per aprire un canale di pagamento sulla Lightning Network, le due parti creano prima una transazione di funding sulla blockchain di Bitcoin. Si tratta di una normale transazione Bitcoin che spende UTXO esistenti appartenenti a ciascuna parte e crea un singolo output inviato a un indirizzo multisig 2-of-2.

La proprietà fondamentale di questo output di funding è che richiede la firma di entrambe le parti prima che i fondi possano essere spesi. Né Alice né Bob possono muovere i fondi del canale da soli. Questa custodia reciproca è ciò che rende sicuri i pagamenti off-chain.

La transazione di funding viene trasmessa alla rete Bitcoin e confermata come qualsiasi altra transazione. I miner la includono in un blocco e, dopo un numero sufficiente di conferme (tipicamente 6 su mainnet), il canale è considerato aperto. Da quel momento, le due parti possono scambiarsi transazioni di commitment firmate off-chain senza ulteriore attività on-chain.

![Anatomia della transazione di funding](media/wiki/channel-funding-transactions/funding-tx-anatomy.svg "Alice e Bob contribuiscono con UTXO a una transazione di funding che crea un output multisig 2-of-2 condiviso, confermato in un blocco.")

## medium

La transazione di funding crea un output P2WSH (Pay-to-Witness-Script-Hash) il cui script witness è un multisig 2-of-2:

```
OP_2 <pubkey_A> <pubkey_B> OP_2 OP_CHECKMULTISIG
```

Ogni parte contribuisce con un numero di satoshi all'output di funding. La somma dei loro contributi forma la capacità totale del canale. Per esempio, se Alice contribuisce con 200.000 sats e Bob con 100.000 sats, il canale ha una capacità di 300.000 sats.

L'output di funding è identificato dal suo outpoint — una combinazione dell'ID della transazione (txid) e dell'indice dell'output (vout). Questo outpoint funge da identificatore unico del canale sulla Lightning Network e viene utilizzato in tutti i successivi messaggi del protocollo che fanno riferimento al canale.

Una salvaguardia critica del protocollo è che la transazione di funding deve essere completamente firmata da entrambe le parti prima di essere trasmessa. Questo impedisce a una delle parti di trasmettere una transazione non concordata dall'altra. Lo scambio delle firme avviene attraverso il messaggio `funding_signed` definito in BOLT 2.

Una volta che entrambe le firme sono state scambiate e verificate, la transazione può essere trasmessa. La capacità del canale è fissa per tutta la durata del canale — a meno che non venga utilizzato lo splicing (un'estensione del protocollo) per aggiungere o rimuovere fondi.

![Creazione dell'indirizzo multisig 2-of-2](media/wiki/channel-funding-transactions/multisig-address.svg "Le chiavi pubbliche di Alice e Bob sono combinate in uno script multisig 2-of-2, che viene hashato per produrre l'indirizzo P2WSH.")

## advanced

**Flusso di funding in dettaglio.** Il processo di apertura del canale definito in BOLT 2 inizia con il messaggio `open_channel`, che include l'importo del funding, il feerate per le transazioni di commitment e le chiavi pubbliche della parte. Il destinatario risponde con `accept_channel`. Entrambe le parti costruiscono poi la transazione di funding e le rispettive transazioni di commitment *prima* che la transazione di funding venga trasmessa.

Questa pre-costruzione è essenziale: ogni parte crea una transazione di commitment iniziale che spende l'output di funding verso sé stessa (meno la riserva del canale). Queste transazioni di commitment vengono firmate e scambiate tramite `funding_signed`, ma non vengono mai trasmesse a meno che una parte non debba chiudere il canale unilateralmente. Pre-firmandole, entrambe le parti si assicurano di poter sempre recuperare i propri fondi anche se l'altra parte scompare dopo la conferma della transazione di funding.

**Il messaggio funding_locked.** Dopo che la transazione di funding è stata trasmessa, entrambe le parti monitorano la sua profondità di conferma sulla blockchain di Bitcoin. Quando la transazione raggiunge la profondità richiesta (min_depth), che per default è di 6 conferme su mainnet, ogni parte invia il messaggio `funding_locked`. Questo messaggio segnala che il canale è operativo e pronto per instradare pagamenti. Il messaggio `funding_locked` include il successivo per-commitment point della parte, necessario per costruire future transazioni di commitment.

**Derivazione del Channel ID.** Il channel ID è derivato dall'outpoint della transazione di funding. Nello specifico, il txid e l'indice dell'output vengono XOR-normalizzati per produrre un identificatore di canale a 32 byte utilizzato in tutti i successivi messaggi Lightning:
```
channel_id = funding_txid XOR (funding_output_index || 0x0000...)
```

**Dual funding (BOLT 2).** Nella variante dual funding, entrambe le parti contribuiscono simultaneamente all'output di funding. A differenza del caso single-funder, dove una sola parte fornisce tutti i satoshi, il dual funding richiede un protocollo di costruzione della transazione interattivo più complesso. Entrambe le parti aggiungono i propri input e output alla transazione di funding, poi si scambiano le firme in modo interattivo fino al completamento della transazione.

**P2WSH vs P2SH-P2WSH.** Le implementazioni Lightning moderne usano P2WSH nativo per l'output di funding, che è più efficiente e ha commissioni più basse. Tuttavia, P2SH-P2WSH (SegWit incapsulato) è anche supportato per compatibilità con wallet più vecchi che non supportano indirizzi SegWit nativi. In P2SH-P2WSH, l'hash dello script è incorporato in un output P2SH, e i dati witness vengono rivelati al momento della spesa.

**Gestione delle fee.** La transazione di funding deve pagare le commissioni di mining. Poiché entrambe le parti contribuiscono all'output di funding, devono concordare come viene dedotta la commissione. Nel modello single-funder, il finanziatore paga la commissione contribuendo leggermente di più per coprirla. Nel dual funding, la commissione viene tipicamente suddivisa proporzionalmente. Il feerate viene negoziato durante l'handshake `open_channel` / `accept_channel`.

**Riserva del canale.** Ogni canale impone un saldo minimo che ciascuna parte deve mantenere — la riserva del canale. Questa riserva (tipicamente l'1% della capacità del canale) garantisce che entrambe le parti abbiano un incentivo economico a comportarsi onestamente. Se il saldo di una parte scende a zero, potrebbe essere incentivata a pubblicare uno stato obsoleto. La riserva mitiga questo rischio assicurando che ogni parte abbia sempre qualcosa da perdere.
