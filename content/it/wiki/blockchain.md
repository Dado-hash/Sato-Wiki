---
id: wiki.blockchain
slug: blockchain
language: it
category: protocol
title: Blockchain
description: La storia collegata di blocchi validi di Bitcoin, selezionata dalla proof of work accumulata.
coverImage: media/wiki/blockchain/linked-chain.svg
difficulty: advanced
readTimeMinutes: 8
tags:
  - Blockchain
  - Consenso
  - Chainwork
  - Storia
related:
  - wiki.blocks
  - wiki.proof-of-work
  - wiki.full-nodes
  - wiki.consensus-rules
  - wiki.block-propagation
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: Bitcoin Developer Guide - Block Chain
    url: https://developer.bitcoin.org/devguide/block_chain.html
    author: Bitcoin.org contributors
  - title: Bitcoin Developer Reference - Block Chain
    url: https://developer.bitcoin.org/reference/block_chain.html
    author: Bitcoin.org contributors
  - title: Bitcoin Core validation implementation
    url: https://github.com/bitcoin/bitcoin/blob/master/src/validation.cpp
    author: Bitcoin Core contributors
updatedAt: 2026-05-27T00:00:00Z
---

## base

La blockchain di Bitcoin è una catena di blocchi validi. Ogni blocco punta all'hash del blocco precedente, quindi modificare un vecchio blocco cambierebbe il suo hash e romperebbe ogni collegamento successivo.

![Schema di blockchain collegata](media/wiki/blockchain/linked-chain.svg "I blocchi si collegano all'indietro tramite hash, mentre i nodi seguono il ramo valido con più proof of work accumulata.")

La blockchain non è semplicemente un database pubblico. È una storia selezionata da regole e proof of work. I nodi rifiutano blocchi invalidi e i miner competono per estendere la chain valida con più lavoro accumulato.

Le conferme misurano quanto una transazione è profonda in quella storia. Una transazione nell'ultimo blocco ha una conferma. Ogni nuovo blocco sopra aggiunge un'altra conferma e rende più costoso sostituire quella transazione.

## medium

Ogni header di blocco impegna il suo parent tramite l'hash del blocco precedente. Questo crea una struttura ordinata dal blocco genesis alla punta corrente. Un nodo può verificare collegamenti, proof of work e regole di ogni blocco mentre costruisce la propria vista locale della chain.

Possono esserci split temporanei quando miner diversi trovano blocchi in momenti vicini. I nodi possono vedere rami validi concorrenti. Non scelgono in base all'identità del miner né restano per sempre sul primo ramo sentito: tracciano il ramo valido con più proof of work accumulata.

La blockchain impegna anche cambiamenti di stato. I blocchi contengono transazioni, le transazioni consumano e creano UTXO, e il chainstate del nodo cambia mentre i blocchi vengono collegati o scollegati durante una riorganizzazione. La catena visibile di blocchi e l'insieme UTXO corrente sono due viste della stessa storia validata.

Per questo "on-chain" significa più di "pubblicato da qualche parte". Una transazione è sulla chain di Bitcoin solo quando è inclusa in un blocco valido che appartiene alla best valid chain del nodo.

## advanced

La blockchain di Bitcoin è un log collegato da hash più una regola di validazione per scegliere tra log concorrenti. I collegamenti hash rendono evidente la manomissione. La proof of work rende costose le storie alternative. La validazione dei full node assicura che il lavoro conti solo quando è attaccato a blocchi che rispettano le regole di consenso.

I nodi di solito imparano gli header prima dei dati di blocco completi. Gli header permettono di confrontare chainwork potenziale a basso costo, ma una chain di header non basta per accettare pagamenti. Il nodo deve validare i blocchi e le transazioni corrispondenti prima di trattare quel ramo come storia pienamente utilizzabile.

Le riorganizzazioni fanno parte del disegno. Se la punta corrente di un nodo perde contro un altro ramo valido con più lavoro accumulato, il nodo scollega blocchi fino al punto di fork e collega il ramo più forte. Le transazioni dei blocchi scollegati possono tornare in mempool se sono ancora valide e non in conflitto.

La chain non offre finalità istantanea. Offre settlement probabilistico: sostituire una transazione richiede produrre un ramo alternativo valido che superi il lavoro accumulato dal ramo pubblico. Più la transazione è profonda, più lavoro deve essere rimpiazzato.

Il risultato pratico è un sistema di ordinamento condiviso senza un'autorità centrale di timestamp. Ogni nodo può ricostruire indipendentemente la stessa migliore storia valida da dati di blocco, proof of work e regole di consenso.
