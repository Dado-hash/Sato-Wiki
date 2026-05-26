---
id: wiki.proof-of-work
slug: proof-of-work
language: it
category: protocol
title: Proof of Work
description: Il meccanismo che Bitcoin usa per rendere costoso riscrivere la storia dei blocchi e semplice verificarla.
coverImage: media/wiki/proof-of-work/pow-mining-loop.svg
difficulty: advanced
readTimeMinutes: 9
tags:
  - Mining
  - Consenso
  - Crittografia
  - Difficoltà
related:
  - wiki.mining
  - wiki.sha-256
  - wiki.difficulty-adjustment
  - wiki.blocks
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: Bitcoin Developer Reference - Block Chain
    url: https://developer.bitcoin.org/reference/block_chain.html
    author: Bitcoin.org contributors
  - title: Bitcoin Core proof-of-work implementation
    url: https://github.com/bitcoin/bitcoin/blob/master/src/pow.cpp
    author: Bitcoin Core contributors
updatedAt: 2026-05-26T00:00:00Z
---

## base

La Proof of Work è il modo in cui Bitcoin rende costoso riscrivere la storia. I miner costruiscono blocchi candidati e cercano un hash inferiore al target corrente della rete. La ricerca richiede molti tentativi, ma ogni nodo può verificare rapidamente l'hash vincente.

![Schema del lavoro accumulato](media/wiki/proof-of-work/accumulated-work.svg "I nodi scelgono il ramo valido con più proof of work accumulata, non semplicemente il primo blocco ricevuto.")

Un blocco è utile solo se rispetta tutte le regole di consenso: le transazioni devono essere valide, il blocco deve collegarsi a un blocco precedente e la prova deve soddisfare il target. La Proof of Work non sostituisce la validazione; assegna un costo oggettivo ai blocchi validi.

Quando i nodi vedono storie concorrenti, seguono la chain valida con più lavoro accumulato. Per modificare una vecchia transazione, un attaccante dovrebbe rifare il lavoro di quel blocco e poi produrre più lavoro della rete onesta. Ogni nuovo blocco rende più difficile questa rincorsa.

## medium

I miner Bitcoin non ricalcolano sempre l'intero blocco: fanno hash dell'header del blocco. L'header contiene l'hash del blocco precedente, la Merkle root delle transazioni, un timestamp, il target compatto chiamato `nBits` e un nonce. I miner variano nonce, timestamp, insieme di transazioni o dati della coinbase finché il doppio SHA-256 non è abbastanza basso.

Il target è una soglia. Un target più basso significa meno hash accettabili, quindi aumenta il numero atteso di tentativi. Poiché l'output degli hash si comporta come dato casuale, il mining è una gara probabilistica: nessun miner può prevedere il nonce vincente, ma chi ha più hash rate ha più tentativi al secondo.

![Schema del lavoro accumulato](media/wiki/proof-of-work/accumulated-work.svg "I nodi scelgono il ramo valido con più proof of work accumulata, non semplicemente il primo blocco ricevuto.")

Ogni 2.016 blocchi, mainnet ricalibra la difficoltà per mantenere i blocchi vicino a una media di 10 minuti. Se il periodo precedente è stato troppo veloce, il target scende e il mining diventa più difficile. Se è stato troppo lento, il target sale e il mining diventa più facile.

La Proof of Work dà a Bitcoin due proprietà importanti. Primo, rende costosi gli attacchi Sybil: il peso non dipende dalle identità di rete, ma dal lavoro dimostrato. Secondo, rende il settlement probabilistico: le conferme non sono finalità magica, ma ogni conferma aggiunge lavoro che un attaccante deve superare.

## advanced

I full node validano la Proof of Work derivando il target da `nBits` e controllando che l'hash dell'header sia minore o uguale a quel target. Controllano anche che il target sia entro il limite consentito e che il blocco rispetti tutte le altre regole di consenso.

La regola di scelta del ramo si basa sulla chainwork accumulata. Un ramo apparentemente più lungo, ma composto da blocchi più facili, può perdere contro un ramo più corto con più lavoro totale. Per questo "longest chain" va letta come chain valida con la maggiore Proof of Work accumulata.

Il ricalcolo della difficoltà è volutamente lento e limitato. Su Bitcoin mainnet avviene solo agli intervalli di aggiustamento, usando il tempo osservato nel periodo precedente di 2.016 blocchi e applicando limiti alla variazione. Questo evita salti improvvisi del target, ma permette di seguire i cambiamenti di hash rate nel lungo periodo.

La Proof of Work definisce anche il costo delle reorg. Un miner può sempre provare a costruire un ramo privato, ma per sostituire storia già confermata quel ramo deve superare la chain pubblica in lavoro accumulato prima che il resto della rete la estenda ancora. La domanda economica non è solo "si possono produrre hash?", ma "si possono produrre più velocemente di tutti gli altri rinunciando ai ricavi del mining onesto?"

Per questo la Proof of Work non è solo una lotteria di mining. È il ponte tra consenso digitale e costo esterno. I nodi restano economici da eseguire e severi sulle regole; i miner spendono energia per proporre una storia ordinata che i nodi possono rifiutare o accettare indipendentemente.
