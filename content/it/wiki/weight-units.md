---
id: wiki.weight-units
slug: weight-units
language: it
category: protocol
title: Weight unit e vbyte
description: Come Bitcoin misura la dimensione di transazioni e blocchi dopo SegWit, e perché le fee rate si esprimono in vbyte.
difficulty: base
readTimeMinutes: 5
tags:
  - Weight
  - Vbyte
  - SegWit
  - Commissioni
  - Dimensione dei blocchi
related:
  - wiki.segregated-witness
  - wiki.transaction-fees
  - wiki.blocks
  - wiki.transactions
  - wiki.fee-market
sources:
  - title: "BIP 141: Segregated Witness (Consensus layer)"
    url: https://github.com/bitcoin/bips/blob/master/bip-0141.mediawiki
    author: Eric Lombrozo, Johnson Lau, Pieter Wuille
    publishedAt: 2015-12-21
  - title: Bitcoin Core consensus constants
    url: https://github.com/bitcoin/bitcoin/blob/master/src/consensus/consensus.h
    author: Bitcoin Core contributors
  - title: Weight units
    url: https://en.bitcoin.it/wiki/Weight_units
    author: Bitcoin Wiki contributors
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

In Bitcoin la dimensione di una transazione si misura con due unità collegate. Le weight unit (WU) limitano i blocchi. I vbyte (vB) sono le weight unit divise per quattro, e le fee rate si esprimono in vbyte. Entrambe esistono perché SegWit ha cambiato il modo in cui sono memorizzate le firme.

Il peso conta quattro volte la parte non witness di una transazione e una sola volta la parte witness, che contiene le firme. Una transazione senza dati witness ha quindi una dimensione virtuale uguale al numero dei suoi byte. Nelle transazioni SegWit parte dei dati costa un quarto, quindi la dimensione virtuale è minore di quella grezza.

Un blocco può contenere al massimo 4.000.000 di weight unit. Questo ha sostituito il vecchio limite di un megabyte di dati serializzati. Un blocco pieno di dati witness può superare un megabyte in byte grezzi, mentre un blocco composto solo da dati legacy non può superare un milione di byte.

Esempio con numeri tondi. Supponiamo che una transazione abbia 200 byte fuori dal witness e 100 byte di witness, per un totale di 300 byte. Il suo peso è 200 x 3 + 300 = 900 WU, quindi la sua dimensione virtuale è 900 / 4 = 225 vB. Se paga 4.500 satoshi, la sua fee rate è 4.500 / 225 = 20 sat/vB.

## medium

Le definizioni vengono dal BIP 141. La base size è la transazione serializzata senza dati witness, mentre la total size include il witness. Il peso è la base size moltiplicata per tre, più la total size. La dimensione virtuale è il peso diviso per quattro, arrotondato per eccesso al numero intero successivo. Prendiamo una transazione con 150 byte di dati base e 109 byte di witness. La sua total size è 259 byte, il suo peso è 150 x 3 + 259 = 709 WU, e la sua dimensione virtuale è 709 / 4 = 177,25, che arrotondata per eccesso dà 178 vB.

Il limite del blocco usa la stessa aritmetica. Il peso di un blocco si calcola dalla sua base size e dalla sua total size, quindi include header e transazione coinbase, e la somma non può superare 4.000.000. Il BIP 141 spiega perché è stato scelto un unico limite composito invece di limiti separati per i dati base e per i dati witness. Due limiti separati renderebbero molto difficile per i miner scegliere l'insieme di transazioni più redditizio, e i wallet non saprebbero facilmente quale vincolo avrebbe limitato la loro transazione.

Il witness è scontato per ciò che fa. Gli effetti di una transazione sono determinati dagli output che spende e da quelli che crea. Le firme servono a verificare che una spesa sia autorizzata, ma non cambiano ciò che la transazione fa. Il BIP 141 elenca lo sconto sui dati witness tra i vincoli che un soft fork può allentare, perché spostare le firme in una struttura separata permette di contarle diversamente pur con le stesse regole. Il risultato pratico è più spazio in ogni blocco per la stessa attività, e un costo minore per le transazioni che portano le firme nel witness.

Per questo la cosa da confrontare è la fee rate, non la dimensione grezza. Dividere la fee per la dimensione virtuale porta transazioni con strutture diverse sulla stessa scala. È anche la misura che i miner usano per riempire i blocchi.

## advanced

I numeri poggiano su due serializzazioni di ogni transazione. La base size è la transazione come la vedrebbe un nodo che non conosce SegWit, cioè senza marker, flag e sezione witness. La total size usa la serializzazione estesa descritta nel BIP 144, che include il witness. La formula si applica a ogni transazione, e a un blocco sommando le stesse due grandezze su header e tutte le sue transazioni.

Poiché il witness è separato, il peso di una transazione dipende da come sono codificate le sue firme. Una modifica a un elemento del witness cambia la total size e quindi il peso, mentre il txid resta lo stesso. Un wallet conosce la base size della propria transazione dai suoi input e output, e può stimare la dimensione del witness dai tipi di script che spende. È questa stima che gli permette di fissare la fee prima di firmare.

La transazione coinbase conta nel peso del blocco come qualsiasi altra transazione. Quando un blocco contiene transazioni witness, la coinbase porta un witness commitment, un output che impegna i wtxid delle transazioni del blocco. Quell'output è dato base, quindi aumenta il peso del blocco. Anche il witness della coinbase è scontato come ogni altro witness.

Le operazioni di firma hanno un limite proprio, che il BIP 141 ha modificato. Il limite dei sigop per blocco è 80.000, e le operazioni negli script legacy sono contate a quattro volte il valore precedente. Un input P2WPKH conta come un sigop, mentre i controlli dentro uno script witness P2WSH sono contati come prima. La regola dei sigop segue quindi la stessa logica di quella sulle dimensioni: il dato witness costa meno da validare in questo conteggio.

Consenso e policy usano entrambi questi numeri. Il consenso fissa il limite di 4.000.000 di weight unit che ogni blocco valido deve rispettare. I full node applicano anche una policy di relay alle transazioni standard, quindi una transazione può essere valida per un blocco e non essere inoltrata di default. I miner che ordinano le transazioni per fee rate usano la dimensione virtuale come denominatore, ed è per questo che il vbyte è l'unità che conta per il fee market.

La formula spiega anche cosa protegge lo sconto. I dati non witness determinano i txid e gli output che le transazioni successive possono spendere, quindi costano quattro unità. I dati witness servono a verificare le firme, ma non cambiano il txid, quindi costano una unità.
