---
id: wiki.twenty-one-million-cap
slug: twenty-one-million-cap
language: it
category: economics
title: Limite di 21 Milioni
description: Il numero specifico scelto per l'offerta massima di Bitcoin, che emerge dal programma del block subsidy e dall'intervallo di halving.
coverImage: media/wiki/twenty-one-million-cap/twenty-one-million-hero.svg
difficulty: base
readTimeMinutes: 6
tags:
  - Economia
  - Offerta
  - 21 Milioni
  - Politica Monetaria
related:
  - wiki.fixed-supply
  - wiki.issuance-schedule
  - wiki.halving
  - wiki.scarcity
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: L'Offerta Controllata di Bitcoin
    url: https://en.bitcoin.it/wiki/Controlled_supply
    author: Bitcoin Wiki contributors
  - title: Perché 21 Milioni?
    url: https://www.lopp.net/bitcoin-information/21-million.html
    author: Jameson Lopp
updatedAt: 2026-05-28T00:00:00Z
---

## base

Il numero 21 milioni non è casuale. È il risultato matematico del programma del block subsidy di Bitcoin. Il subsidy iniziale di 50 BTC per blocco si dimezza ogni 210.000 blocchi. Se si sommano tutti i subsidy da oggi fino all'ultimo satoshi minato, il totale converge esattamente a 21 milioni di Bitcoin.

Il primo blocco (il blocco genesis, minato nel gennaio 2009) ha creato 50 BTC. Dopo 210.000 blocchi, il subsidy è sceso a 25 BTC. Dopo altri 210.000 blocchi, a 12,5 BTC. Questo processo continua ogni quattro anni finché il subsidy diventa così piccolo da arrotondarsi a zero — intorno all'anno 2140.

A quel punto, non verranno mai più creati nuovi bitcoin. I miner guadagneranno solo dalle commissioni di transazione. L'offerta sarà fissa per sempre.

![Il limite di 21 milioni](media/wiki/twenty-one-million-cap/twenty-one-million-hero.svg "Ripartizione visiva del limite di 21 milioni: monete minate, offerta rimanente, ultimo block subsidy nel ~2140 e divisibilità in 2,1 quadrilioni di satoshi.")

21 milioni può sembrare un numero arbitrario, ma è stata una scelta progettuale deliberata di Satoshi Nakamoto. Bilancia diversi fattori: rendere Bitcoin abbastanza scarso da mantenere valore, abbastanza divisibile per un uso globale (ogni bitcoin si divide in 100 milioni di satoshi) e con un programma di distribuzione che ricompensa i primi adottanti continuando a incentivare i miner per oltre un secolo.

## medium

La matematica dietro i 21 milioni è una serie geometrica. Ogni epoca di halving produce la metà dei bitcoin della precedente:

```
Totale = 210.000 × 50 × (1 + 1/2 + 1/4 + 1/8 + 1/16 + ...)
       = 210.000 × 50 × 2
       = 10.500.000 × 2
       = 21.000.000
```

La somma di una serie geometrica infinita con rapporto 1/2 è esattamente 2 volte il primo termine. Ecco perché il totale converge a un numero finito nonostante gli halving continuino per sempre.

Satoshi Nakamoto ha scelto 50 BTC come subsidy iniziale e 210.000 blocchi come intervallo di halving. A 10 minuti per blocco, 210.000 blocchi richiedono circa 3,99 anni — vicino a quattro anni. La scelta di 50 BTC è stata oggetto di speculazioni: alcuni suggeriscono che sia stato scelto perché 21 milioni diviso 210.000 fa 100, e con la prima epoca che ha una quota del 50%, il subsidy iniziale di 50 si inserisce in modo pulito.

Perché proprio 21 milioni e non 10 milioni o 100 milioni? Satoshi spiegò in una delle prime email che la scelta fu "una stima ragionata" basata sul rendere l'unità abbastanza piccola per le transazioni tipiche mantenendo comunque limitata l'offerta totale. Il ragionamento esatto considera:

- **Divisibilità**: Con 8 decimali, 21 milioni di bitcoin forniscono 2,1 quadrilioni (2,1 × 10¹⁵) di unità individuali
- **Incentivi al mining**: Il programma doveva ricompensare generosamente i primi miner continuando a fornire incentivi per la transizione secolare al mining basato solo su commissioni
- **Confronto con base monetaria**: A varie ipotesi di prezzo, 21 milioni di unità con alta divisibilità potrebbero approssimare gli aggregati monetari globali

Il limite è garantito da ogni full node. Qualsiasi blocco che creerebbe monete oltre il limite del subsidy viene rifiutato come invalido. Questa non è una convenzione sociale — è una regola di consenso verificata dal software eseguito su migliaia di nodi in tutto il mondo.

## advanced

Il limite di 21 milioni è garantito implicitamente piuttosto che controllato esplicitamente come totale corrente nella maggior parte del codice di validazione. Bitcoin Core valida il valore della transazione coinbase contro il subsidy previsto per l'altezza del blocco corrente. La funzione `GetBlockSubsidy` in `src/validation.cpp` calcola il subsidy corretto in base al numero di halving avvenuti. Se l'output della coinbase supera il subsidy più le commissioni, il blocco viene rifiutato.

Questa garanzia implicita significa che anche se `MAX_MONEY` venisse rimosso dal codice, l'offerta sarebbe comunque limitata dal programma del subsidy. La costante `MAX_MONEY` fornisce difesa a più livelli contro overflow ed errori logici.

L'esatto ultimo blocco con un subsidy non nullo può essere calcolato con precisione. Il subsidy si dimezza ogni 210.000 blocchi. Partendo da 50 BTC = 5.000.000.000 satoshi, dopo 64 halving il subsidy diventa inferiore a 1 satoshi e si arrotonda a zero:
```
Altezza del blocco del subsidy finale = 64 × 210.000 = 13.440.000
```
A 10 minuti per blocco, ciò avviene circa 128 anni dopo il genesis, intorno al 2137-2140 a seconda della tempistica effettiva dei blocchi.

C'è un equivoco comune secondo cui il limite potrebbe essere cambiato con un semplice aggiornamento del codice. Modificare il limite di 21 milioni richiederebbe un hard fork — ogni full node e partecipante economico dovrebbe aggiornarsi. Dato che l'offerta fissa è una delle proposte di valore più fondamentali di Bitcoin, un tale cambiamento è considerato estremamente improbabile dalla community. Il consenso sociale attorno al limite di 21 milioni è probabilmente più forte di qualsiasi singola riga di codice che lo impone.

L'aspetto della divisibilità è spesso trascurato. Con 8 decimali, 21 milioni di BTC producono 2.100.000.000.000.000 (2,1 quadrilioni) di satoshi. Questo è sufficiente per un sistema monetario globale: con una popolazione mondiale di 10 miliardi, ogni persona potrebbe detenere fino a 210.000 satoshi (0,0021 BTC) anche se ogni singolo satoshi fosse distribuito equamente. Le soluzioni di secondo livello come la Lightning Network aumentano ulteriormente la granularità abilitando pagamenti sub-satoshi attraverso routing e pagamenti multi-percorso.
