---
id: wiki.soft-fork-signalling
slug: soft-fork-signalling
language: it
category: protocol
title: Attivazione e segnalazione dei soft fork
description: Come Bitcoin coordina un soft fork, con i miner che segnalano la prontezza tramite i version bit, le regole che passano tra stati definiti e i nodi, non i miner, che decidono cosa è valido.
coverImage: media/wiki/soft-fork-signalling/soft-fork-signalling-hero.svg
difficulty: advanced
readTimeMinutes: 4
tags:
  - Soft Fork
  - Attivazione
  - Version Bit
  - Taproot
  - BIP 8
related:
  - wiki.forks-and-soft-forks
  - wiki.consensus-rules
  - wiki.segregated-witness
  - wiki.taproot
  - wiki.full-nodes
sources:
  - title: "BIP 9: Version bits with timeout and delay"
    url: https://github.com/bitcoin/bips/blob/master/bip-0009.mediawiki
    author: Pieter Wuille, Peter Todd, Greg Maxwell, Rusty Russell
  - title: "BIP 8: Version bits with lock-in by height"
    url: https://github.com/bitcoin/bips/blob/master/bip-0008.mediawiki
    author: Shaolin Fry, Luke Dashjr
  - title: "BIP 341: Taproot - SegWit version 1 spending rules"
    url: https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki
    author: Pieter Wuille, Jonas Nick, Anthony Towns
  - title: "BIP 148: Mandatory activation of segwit deployment"
    url: https://github.com/bitcoin/bips/blob/master/bip-0148.mediawiki
    author: Shaolin Fry
  - title: Bitcoin Optech - Soft fork activation
    url: https://bitcoinops.org/en/topics/soft-fork-activation/
    author: Bitcoin Optech
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

Un soft fork rende invalidi alcuni blocchi che prima erano validi. Ogni blocco accettato dalle regole nuove è accettato anche da quelle vecchie, quindi i nodi che non hanno aggiornato continuano a seguire la stessa chain. L'attivazione è il momento in cui le nuove regole iniziano a essere applicate, e la rete ha bisogno di un modo per concordare quando quel momento arriva.

Per gran parte della storia di Bitcoin sono stati i miner a segnalare la prontezza. Un miner imposta un bit nel campo versione dell'header per dire che il suo software supporta la nuova regola. La rete conta questi segnali periodo per periodo, e quando abbastanza blocchi segnalano, la regola diventa attiva poco dopo. È un lavoro di coordinamento: il segnale dice a tutti che la maggior parte dell'hashrate è pronta ad applicare la regola.

Il segnale è un bit in ogni header di blocco, quindi chiunque legga la chain può contarlo. La segnalazione però non rende valida una regola. I nodi controllano la regola da soli. Un blocco che viola la nuova regola viene rifiutato da ogni nodo aggiornato, anche se porta un segnale. Il segnale indica quale software eseguono i miner, ma non cambia ciò che i nodi accettano.

## medium

I version bit rendono possibile la segnalazione senza un nuovo formato di blocco. Il campo versione dell'header viene letto come un intero a 32 bit, e a ogni deployment è assegnato un bit. Un blocco segnala per un deployment impostando quel bit mentre i suoi tre bit più alti valgono 001. Il BIP 9 conta i segnali su periodi di retarget da 2016 blocchi, circa due settimane al ritmo previsto. Un deployment attraversa cinque stati. Parte da DEFINED. Diventa STARTED quando è passato il suo start time. Diventa LOCKED_IN dopo un periodo in cui almeno la soglia di blocchi ha segnalato. Diventa ACTIVE un periodo dopo il lock-in. Se il timeout scade prima del lock-in, diventa FAILED.

La soglia del BIP 9 è 1916 blocchi su 2016, cioè il 95 per cento. Il BIP 8 descrive il difetto di questo disegno: serve una segnalazione quasi unanime, quindi una piccola minoranza di hashrate che non segnala può mettere il veto sull'attivazione.

Il BIP 8 mantiene la segnalazione tramite version bit ma sostituisce il timeout con il lock-in per altezza. Il parametro lockinontimeout decide cosa succede se la segnalazione non basta. Quando è disattivato, il deployment fallisce al timeout, come nel BIP 9. Quando è attivo, il deployment entra in MUST_SIGNAL nell'ultimo periodo prima del timeout. In quel periodo, appena 2016 meno la soglia di blocchi hanno mancato la segnalazione, ogni ulteriore blocco che non segnala è invalido. Il deployment poi va in lock-in qualunque sia il conteggio, quindi i miner non possono bloccarlo indefinitamente. Il BIP suggerisce per la mainnet una soglia di 1815 blocchi, cioè il 90 per cento.

La segnalazione obbligatoria è una scelta di deployment con conseguenze concrete. Obbliga i miner a segnalare prima di poter minare blocchi validi. Chi esegue software aggiornato deve sapere quale modalità usa un deployment e quale ne è la scadenza.

## advanced

Speedy Trial è il nome che Bitcoin Optech usa per il processo di deployment breve usato per Taproot. Il BIP 341 lo descrive come il BIP 9 con una soglia più bassa, un'altezza minima di attivazione e una transizione di stato modificata per gli stati DEFINED, STARTED e LOCKED_IN. Per la mainnet, il deployment usava il bit 2, uno start time del 24 aprile 2021, un timeout dell'11 agosto 2021, una soglia di 1815 blocchi (90 per cento) e un'altezza minima di attivazione pari a 709632. Le regole si sono attivate a quell'altezza. Un deployment che non avesse raggiunto la soglia prima del timeout sarebbe fallito.

BIP 148 è il soft fork attivato dagli utenti più noto. Era stato scritto per entrare in vigore il 1 agosto 2017 e per richiedere il deployment esistente di SegWit, bit 1, in ogni blocco. Secondo il BIP 148, un blocco che non segnalava sarebbe stato rifiutato dai nodi che lo eseguivano. Il BIP è attivo solo se il deployment esistente non è andato in lock-in entro il suo start time, e cessa quando SegWit va in lock-in. Lo scopo era far correre ai miner che non segnalano il rischio che i loro blocchi vengano rifiutati, il che spingeva i miner ad attivare SegWit con il meccanismo normale. Il rischio è che i miner che restano sulle regole vecchie continuino a costruire una chain che questi nodi rifiutano.

L'attivazione è quindi un processo economico oltre che tecnico. I miner estendono le chain secondo le regole che la rete accetta, mentre sono i nodi a decidere cosa la rete accetta. Optech descrive il rischio centrale di qualunque metodo di attivazione: se i nodi applicano regole diverse, blocchi che violano la regola non uniforme possono essere accettati da alcuni nodi e rifiutati da altri, causando uno split della chain. I meccanismi di attivazione esistono per ridurre questa possibilità, e ciascuno bilancia il rischio di ritardo dei miner con il rischio di una chain contesa.

Chi legge a livello avanzato dovrebbe separare tre domande a cui BIP 8 e BIP 9 rispondono in modo diverso: quando inizia la segnalazione, cosa conta come successo e cosa accade alla scadenza. Queste risposte determinano se un deployment può essere ritardato da una minoranza, e se fallisce o raggiunge un'altezza fissa alla fine.
