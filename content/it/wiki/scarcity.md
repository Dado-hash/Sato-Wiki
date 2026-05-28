---
id: wiki.scarcity
slug: scarcity
language: it
category: economics
title: Scarsità
description: La proprietà che rende prezioso il bitcoin — un'offerta massima fissa imposta dalle regole di consenso, creando il primo bene digitale provatamente scarso.
coverImage: media/wiki/scarcity/scarcity-hero.svg
difficulty: base
readTimeMinutes: 6
tags:
  - Economia
  - Scarsità
  - Offerta
  - Valore
related:
  - wiki.fixed-supply
  - wiki.twenty-one-million-cap
  - wiki.store-of-value
  - wiki.sound-money
  - wiki.network-effects
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: The Bitcoin Standard
    url: https://saifedean.com/the-bitcoin-standard/
    author: Saifedean Ammous
    publishedAt: 2018-03-01
  - title: Scarsità e Bitcoin
    url: https://en.bitcoin.it/wiki/Scarcity
    author: Bitcoin Wiki contributors
updatedAt: 2026-05-28T00:00:00Z
---

## base

La scarsità significa che qualcosa è limitato nell'offerta. Bitcoin è scarso perché il suo protocollo impone un massimo di 21 milioni di monete. Non se ne potranno mai creare di più, qualunque cosa accada.

Prima di Bitcoin, la scarsità digitale era impossibile. I file digitali come musica, documenti o immagini potevano essere copiati all'infinito a costo zero. Bitcoin ha risolto questo problema combinando crittografia, proof of work e una rete di consenso distribuita. Ogni bitcoin può essere verificato come genuino, e l'offerta totale può essere controllata indipendentemente da chiunque esegua un full node.

![Confronto della scarsità digitale](media/wiki/scarcity/scarcity-hero.svg "Bitcoin confrontato con oro, moneta fiat e altri beni digitali in base a proprietà chiave: limite di offerta, verificabilità, portabilità e durabilità.")

La scarsità è importante perché preserva il valore nel tempo. Se qualcosa può essere creato in quantità illimitate, il suo potere d'acquisto tende a diminuire (inflazione). Se qualcosa ha un'offerta fissa, il suo potere d'acquisto tende a rimanere stabile o aumentare con la crescita della domanda.

La scarsità di Bitcoin è diversa dalla scarsità dell'oro. L'oro è scarso perché è difficile da trovare ed estrarre, ma l'offerta totale cresce dell'1-2% ogni anno man mano che vengono scoperti nuovi giacimenti. L'offerta di Bitcoin è precisamente limitata e nota a tutti in anticipo.

## medium

La scarsità di Bitcoin emerge da quattro proprietà che lavorano insieme:

**Limite assoluto dell'offerta.** Il limite di 21 milioni è imposto dalle regole di consenso. Ogni full node valida che nessuna transazione crei bitcoin al di fuori del programma del subsidy. Questa non è una promessa — è un'applicazione a livello di codice.

**Emissione prevedibile.** Il programma degli halving garantisce che il tasso di creazione di nuova offerta sia noto con decenni di anticipo. A differenza dell'oro (dove l'offerta dipende dalla fortuna geologica) o della moneta fiat (dove l'offerta dipende dalla discrezione della banca centrale), la traiettoria dell'offerta di Bitcoin è completamente deterministica.

**Verificabilità senza fiducia.** Qualsiasi partecipante può verificare indipendentemente l'offerta totale eseguendo un full node. Questo elimina la necessità di fidarsi delle cifre di offerta riportate da un'autorità centrale. L'offerta è trasparente e verificabile in tempo reale.

**Durabilità della scarsità.** La scarsità di Bitcoin non può essere diluita da attori esterni. Nessun governo può ordinare la creazione di più bitcoin. Nessuna azienda può scoprire nuovi "giacimenti di bitcoin". Le regole sono applicate da migliaia di nodi indipendenti in tutto il mondo.

L'economia della scarsità può essere compresa attraverso il concetto di stock-to-flow (SF):
```
SF = offerta_esistente / nuova_offerta_annua
```
- Rapporto SF dell'oro: ~55 (55 anni di produzione ai tassi attuali)
- Rapporto SF di Bitcoin (2026): ~110 (110 anni all'emissione attuale, post-halving)
- Rapporto SF della moneta fiat: variabile, tipicamente 1-10 per le valute principali

Un rapporto stock-to-flow più alto indica una maggiore scarsità. Il rapporto SF di Bitcoin raddoppia ogni quattro anni con ogni halving, rendendolo sempre più scarso nel tempo.

## advanced

**Il problema del double-spend e la scarsità digitale.** Prima di Bitcoin, i sistemi di moneta digitale fallivano perché non potevano prevenire il double-spend. Un token digitale sono solo dati — senza un registro centrale, nulla impedisce a qualcuno di inviare gli stessi dati a due destinatari diversi. Bitcoin ha risolto questo problema rendendo la storia di ogni bitcoin pubblicamente verificabile e rendendo il double-spend economicamente impraticabile attraverso il proof of work.

**Il costo di creare scarsità.** La scarsità di Bitcoin non è gratuita. È imposta dalla spesa energetica del proof of work. L'aggiustamento della difficoltà garantisce che produrre un blocco valido richieda risorse del mondo reale. Questo costo energetico è ciò che dà alla scarsità digitale la sua ancora fisica — creare un nuovo bitcoin richiede tanto costo economico reale quanto estrarre oro dal terreno.

**Scarsità e bias dell'unità.** Una critica comune è che il bitcoin è troppo costoso per unità. Questo riflette un equivoco sulla divisibilità. Ogni bitcoin è divisibile fino a 8 decimali (100 milioni di satoshi). La scarsità totale è di 2,1 quadrilioni di satoshi — non 21 milioni. La dimensione dell'unità è arbitraria e si aggiusta attraverso la determinazione del prezzo di mercato.

**La scarsità dell'attenzione.** Il premio Nobel Herbert Simon notò che in un mondo ricco di informazioni, la risorsa scarsa è l'attenzione, non l'informazione. La scarsità di Bitcoin forza un calcolo economico: poiché l'offerta è fissa, il prezzo deve aggiustarsi per equilibrare il mercato. Questo crea un pavimento naturale sul valore che gli asset con offerta elastica non hanno.

**La scarsità nel contesto dei beni monetari.** Nel corso della storia, le migliori monete sono state quelle con i più alti rapporti stock-to-flow: oro, argento e ora bitcoin. La ragione è che la moneta solida impedisce il trasferimento di ricchezza attraverso l'inflazione. Quando un governo può creare moneta a piacimento, tassa effettivamente i risparmiatori. L'offerta fissa di Bitcoin elimina questo meccanismo, rendendolo "moneta solida" nella tradizione economica austriaca.

**I limiti della scarsità digitale.** I critici sostengono che la scarsità di Bitcoin è forte solo quanto il consenso sociale di mantenere il limite di 21 milioni. Una maggioranza sufficientemente determinata potrebbe fare un fork del software e aumentare l'offerta. Tuttavia, gli incentivi economici contro un tale fork sono schiaccianti: qualsiasi fork che diluisce l'offerta sarebbe rifiutato dagli utenti e verrebbe scambiato a una frazione del valore della catena originale, come dimostrato da ogni tentativo di fork di Bitcoin nella storia.
