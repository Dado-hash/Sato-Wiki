---
id: wiki.blocks
slug: blocks
language: it
category: protocol
title: Blocchi
description: I pacchetti di transazioni che i miner propongono e i full node validano come aggiornamenti alla storia condivisa di Bitcoin.
coverImage: media/wiki/blocks/block-anatomy.svg
difficulty: advanced
readTimeMinutes: 8
tags:
  - Blocchi
  - Mining
  - Consenso
  - Merkle Tree
related:
  - wiki.blockchain
  - wiki.proof-of-work
  - wiki.transactions
  - wiki.merkle-trees
  - wiki.mining
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: Bitcoin Developer Reference - Block Chain
    url: https://developer.bitcoin.org/reference/block_chain.html
    author: Bitcoin.org contributors
  - title: Bitcoin Developer Guide - Block Chain
    url: https://developer.bitcoin.org/devguide/block_chain.html
    author: Bitcoin.org contributors
  - title: BIP 141 - Segregated Witness
    url: https://github.com/bitcoin/bips/blob/master/bip-0141.mediawiki
    author: Eric Lombrozo, Johnson Lau, Pieter Wuille
updatedAt: 2026-05-27T00:00:00Z
---

## base

Un blocco è un pacchetto di transazioni proposto da un miner. Si collega al blocco precedente, dimostra che è stato fatto lavoro e chiede ai nodi di accettare un nuovo aggiornamento alla storia delle transazioni di Bitcoin.

![Schema dell'anatomia di un blocco](media/wiki/blocks/block-anatomy.svg "Un blocco contiene un header da 80 byte, una transazione coinbase e una lista di transazioni impegnata dalla Merkle root.")

Ogni blocco ha due parti principali: un header e una lista di transazioni. L'header contiene l'hash del blocco precedente, una Merkle root che impegna le transazioni, un timestamp, il target di difficoltà in forma compatta e un nonce usato durante il mining.

La prima transazione è la coinbase. Crea il subsidy del blocco e raccoglie le fee delle altre transazioni incluse. I nodi accettano il blocco solo se la coinbase non paga più di quanto consentito dalle regole e se ogni transazione inclusa è valida.

## medium

L'header del blocco è piccolo, ma contiene gli impegni di cui i nodi hanno bisogno. L'hash del blocco precedente collega il blocco al suo genitore. La Merkle root impegna la lista ordinata delle transazioni. Il campo `nBits` esprime il target della proof of work e il nonce è uno dei valori che i miner variano mentre cercano un hash valido dell'header.

I blocchi hanno anche vincoli di dimensione. Dopo SegWit, il limite di consenso principale è il block weight, che pesa i dati base delle transazioni più dei dati witness e limita un blocco a 4.000.000 weight unit. Questo permette ai nodi di ragionare sui costi di validazione e relay preservando compatibilità con le vecchie regole di serializzazione.

Una proof of work valida non basta. I full node controllano struttura del blocco, prova, regole sul timestamp, validità delle transazioni, importo coinbase, impegno Merkle e regole contestuali che dipendono dalla storia della chain. Se una regola fallisce, il blocco è invalido anche se il suo hash è sotto il target.

I blocchi danno settlement ordinando le transazioni. Se due transazioni sono in conflitto, un blocco valido può includerne al massimo una. I blocchi successivi costruiscono sopra quella scelta, aumentando il lavoro necessario per sostituirla con una storia diversa.

## advanced

Collegare un blocco è una transizione di stato di consenso. Un nodo valida l'header, controlla che il parent sia noto e accettabile, verifica tutti gli input delle transazioni contro l'insieme UTXO corrente, esegue gli script, spende gli output consumati, crea nuovi output e registra il chainstate risultante.

Alcune regole riguardano il blocco intero, non la singola transazione. La coinbase deve essere la prima. La Merkle root deve corrispondere alle transazioni del blocco. Il valore coinbase non deve superare subsidy più fee. I blocchi SegWit devono impegnare i dati witness attraverso il witness commitment nella coinbase quando sono presenti transazioni witness.

I blocchi portano anche vincoli contestuali. I timestamp sono confrontati con il median-time-past e non possono spingersi troppo nel futuro secondo la policy sul network-adjusted time. Su mainnet la difficoltà cambia solo agli intervalli di retarget. Gli output coinbase richiedono maturità prima di poter essere spesi, riducendo il danno delle riorganizzazioni brevi.

Un blocco può essere salvato, inoltrato, usato come punta di mining o rifiutato a seconda del suo stato di validazione. Gli header possono arrivare prima dei blocchi completi, e un nodo può conoscere più lavoro negli header di quanto abbia già validato come dati di blocco completi. La best chain non è semplicemente il ramo con header: è il miglior ramo pienamente valido che il nodo può collegare secondo le sue regole.

I blocchi sono quindi sia contenitori di dati sia checkpoint di regole. Raggruppano transazioni, impegnano l'ordine, portano proof of work e trasformano l'insieme UTXO un passo valido alla volta.
