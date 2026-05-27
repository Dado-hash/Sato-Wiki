---
id: wiki.utxo-model
slug: utxo-model
language: it
category: protocol
title: Modello UTXO
description: Il modello con cui Bitcoin traccia coin spendibili come output non spesi distinti, invece di saldi account.
coverImage: media/wiki/utxo-model/utxo-flow.svg
difficulty: advanced
readTimeMinutes: 8
tags:
  - UTXO
  - Transazioni
  - Validazione
  - Privacy
related:
  - wiki.transactions
  - wiki.full-nodes
  - wiki.transaction-fees
  - wiki.bitcoin-script
  - wiki.blocks
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: Bitcoin Developer Guide - Transactions
    url: https://developer.bitcoin.org/devguide/transactions.html
    author: Bitcoin.org contributors
  - title: Bitcoin Developer Reference - Transactions
    url: https://developer.bitcoin.org/reference/transactions.html
    author: Bitcoin.org contributors
  - title: Bitcoin Core coins implementation
    url: https://github.com/bitcoin/bitcoin/blob/master/src/coins.h
    author: Bitcoin Core contributors
updatedAt: 2026-05-27T00:00:00Z
---

## base

UTXO significa unspent transaction output, cioè output di transazione non speso. Bitcoin non mantiene un saldo account per ogni utente. Tiene traccia di molti output individuali che non sono ancora stati spesi. Il saldo di un wallet è la somma degli UTXO che il wallet può spendere.

![Flusso di spesa e resto UTXO](media/wiki/utxo-model/utxo-flow.svg "Spendere un UTXO consuma l'intero output e crea nuovi output, di solito includendo un output di resto verso chi spende.")

Se hai un UTXO da 50.000 sat e vuoi pagare 20.000 sat, non tagli il vecchio UTXO a metà. La transazione spende tutto l'output da 50.000 sat e crea nuovi output: uno per il destinatario, uno per il resto e una piccola differenza lasciata come fee al miner.

Questo modello rende precisa la proprietà. Una coin è non spesa e disponibile, oppure è spesa e non può più essere usata. I nodi rifiutano qualunque transazione che provi a spendere due volte lo stesso output nella stessa storia valida.

## medium

Ogni UTXO è identificato da un outpoint: l'ID della transazione che lo ha creato e l'indice dell'output dentro quella transazione. Un input di transazione nomina un outpoint e fornisce i dati necessari per soddisfare lo script di blocco di quell'output.

Gli output sono discreti, quindi i wallet devono fare coin selection. Scelgono quali UTXO spendere, stimano la fee e creano resto quando gli input selezionati sono più grandi del pagamento. Una buona coin selection può ridurre fee ed evitare perdite di privacy inutili.

L'insieme UTXO è lo stato spendibile corrente di Bitcoin. È molto più piccolo della storia completa delle transazioni, ma è critico per il consenso. Un full node lo usa per rispondere a una domanda diretta per ogni input: l'output referenziato esiste, è non speso e questa transazione può spenderlo?

Gli UTXO influenzano anche la privacy. Combinare più UTXO in una transazione può rivelare che lo stesso wallet o utente probabilmente li controlla. Anche gli output di resto possono essere indovinati quando importi, tipi di script o riuso degli indirizzi rendono ovvia la struttura.

## advanced

Il modello UTXO dà a Bitcoin una regola di validazione locale per la scarsità globale. Per validare un blocco, un nodo non deve ricalcolare ogni saldo storico. Applica ogni transazione come insieme di cancellazioni e inserimenti sullo stato UTXO corrente: spende vecchie coin, crea nuove coin e controlla che il valore totale in output non superi il valore spendibile in input.

Per questo il rilevamento dei double-spend è esatto. Due transazioni possono essere in conflitto se provano a spendere lo stesso outpoint. Solo una può essere collegata in uno stato di chain valido. Un ramo concorrente può scegliere l'altra transazione, ma il conflitto viene risolto dalla chain valida con più proof of work accumulata.

Gli UTXO separano anche stato di validazione e storia archivistica. Un full node pruned può eliminare vecchi dati di blocco dopo averli validati, ma deve mantenere abbastanza chainstate per validare nuovi blocchi. L'insieme UTXO è quindi una risorsa condivisa scarsa: ogni output non speso impone costi di archiviazione e lookup ai nodi validanti.

Gli script vivono al confine di questo modello. L'output precedente definisce la condizione di spesa; la nuova transazione fornisce dati di sblocco. Una volta soddisfatta la condizione e collegata la transazione, la vecchia condizione scompare con l'UTXO speso e vengono create nuove condizioni per spese future.

Rispetto a un modello account, gli UTXO semplificano validazione parallela, costruzione di prove e rilevamento dei conflitti. Il prezzo è che i wallet devono gestire coin selection, resto e privacy con attenzione invece di affidarsi a un singolo saldo mutabile.
