---
id: wiki.myth-supply-can-change
slug: myth-supply-can-change
language: it
category: myths
title: '"Il limite di 21 milioni si può cambiare"'
description: "Parzialmente vero: il limite è codice che potrebbe essere modificato, ma aggiungere monete sarebbe un hard fork che ogni nodo deve scegliere di adottare, e i nodi che lo rifiutano mantengono la vecchia chain."
difficulty: base
readTimeMinutes: 5
tags:
  - Miti
  - Offerta
  - Fork
  - Consenso
related:
  - wiki.consensus-rules
  - wiki.forks-and-soft-forks
  - wiki.full-nodes
  - wiki.block-subsidy
  - wiki.halving
  - history.value-overflow-incident
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: Bitcoin Core - Monetary Amount Constants (amount.h)
    url: https://github.com/bitcoin/bitcoin/blob/master/src/consensus/amount.h
    author: Bitcoin Core contributors
  - title: Bitcoin Developer Guide - Block Chain
    url: https://developer.bitcoin.org/devguide/block_chain.html
    author: Bitcoin.org contributors
  - title: Bitcoin Wiki - Value Overflow Incident
    url: https://en.bitcoin.it/wiki/Value_overflow_incident
    author: Bitcoin Wiki contributors
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

Parzialmente vero. Il limite di 21 milioni è una regola scritta nel software di Bitcoin, quindi il software potrebbe in linea di principio essere modificato. Ma aggiungere monete sarebbe un hard fork, e ogni nodo deve scegliere se adottarlo. I nodi che rifiutano mantengono le vecchie regole e la vecchia chain, quindi un'offerta più grande non sarebbe il bitcoin che la rete esistente accetta.

Il limite non è una promessa fatta da qualcuno. È un controllo che ogni full node esegue quando accetta un blocco. Un blocco che crea più monete di quante le regole consentano è invalido, e i nodi lo rifiutano. Per creare monete in più, qualcuno dovrebbe convincere chi gestisce i nodi, i miner e gli exchange ad adottare un software che accetta una regola diversa, e poi a rendere quella chain quella che la gente usa.

Per questo la questione riguarda l'accordo tanto quanto il codice. Il codice può essere modificato, ma una modifica che crea monete diventa Bitcoin solo se una parte sufficiente della rete la esegue. Nessuno può imporre la nuova regola ai nodi che mantengono quella vecchia.

## medium

La regola sull'offerta si trova nel codice di consenso. Bitcoin Core definisce il valore massimo della moneta come 21.000.000 di unità di base, e i nodi verificano che gli output restino entro quell'intervallo. I nuovi bitcoin di ogni blocco, il subsidy, diminuiscono secondo un calendario fisso, come spiega la voce sul block subsidy. La regola è quindi applicata da molti programmi indipendenti, non da un unico server centrale.

Vanno distinti due tipi di modifica. Un soft fork rende più severe le regole, così che alcuni blocchi che i nodi più vecchi accettavano vengono ora rifiutati. I nodi più vecchi continuano a considerare validi i nuovi blocchi, quindi l'aggiornamento può avvenire gradualmente. Creare più offerta fa l'opposto: rende validi blocchi che i nodi più vecchi rifiutano. La developer guide lo descrive come un hard fork, che produce due catene divergenti in modo permanente, una per i nodi aggiornati e una per quelli non aggiornati. Come esempio di modifica che richiede un hard fork, la guida cita l'aumento della dimensione del blocco oltre 1 MB.

Un caso della storia di Bitcoin mostra monete create per errore. Il 15 agosto 2010 il blocco 74638 conteneva una transazione che creava 184.467.440.737,09551616 bitcoin. Una versione corretta del client è stata pubblicata entro cinque ore dalla scoperta. La Bitcoin Wiki riferisce che la catena valida ha superato quella errata all'altezza di blocco 74691, dopodiché la transazione errata e le monete che aveva creato non esistevano più sulla catena più lunga. L'episodio fu un bug, non una decisione, e la rete eliminò le monete adottando la correzione.

La lezione è che un cambio di offerta è una modifica delle regole con un costo sociale. Funziona solo se chi gestisce il software lo accetta, e il caso del 2010 ha funzionato perché quasi tutti volevano eliminare le monete errate.

## advanced

La versione più forte dell'affermazione è questa. Le regole di Bitcoin sono ciò che le persone che fanno girare il software accettano di eseguire. Miner, exchange e sviluppatori di wallet formano un gruppo ristretto che può coordinarsi rapidamente, e una maggioranza di hashrate potrebbe in linea di principio minare blocchi secondo nuove regole. Se una quota abbastanza grande dell'economia adottasse un'offerta più ampia, la regola cambierebbe, e il vecchio limite sarebbe una scelta ingegneristica più che una legge fissa.

C'è un punto serio in questo. Bitcoin non ha un meccanismo formale di voto on-chain per le modifiche del protocollo. La governance passa attraverso i rilasci del software, la segnalazione dei miner e le scelte degli operatori dei nodi e delle aziende, e tutto questo è informale. Un hard fork può avvenire senza una decisione centrale, il che significa che può anche avvenire a sorpresa. L'episodio del 2010 mostra che le regole possono cambiare nella pratica, attraverso una patch d'emergenza che la rete ha dovuto adottare in fretta.

La risposta è che l'episodio è diverso per natura. La patch ha eliminato monete create da un bug, e la rete l'ha adottata perché quasi tutti volevano che la transazione errata sparisse. Un aumento dell'offerta sarebbe invece una modifica deliberata che molti detentori potrebbero non volere, e un hard fork crea una seconda catena con una storia propria anziché spostare quella esistente. I vecchi nodi mantengono le regole che hanno verificato, quindi una moneta che esiste solo sulla nuova catena è un asset diverso, e il suo valore dipende dal fatto che il mercato la tratti come bitcoin.

Le obiezioni a questa risposta sono reali. Il coordinamento non è gratuito, e un gruppo ben finanziato potrebbe fare un fork e poi convincere i servizi a quotare la nuova catena. La risposta dipende anche dall'ipotesi che la maggior parte degli attori economici preferisca le regole esistenti, e questa ipotesi riguarda le persone, non è una garanzia tecnica. Un fork che divide il mercato lascerebbe comunque in discussione un secondo asset con lo stesso nome.

Perché l'affermazione diventi vera in senso forte, un insieme di miner, exchange e utenti dovrebbe eseguire software che accetta più monete ed essere trattato dal mercato come la continuazione di Bitcoin. Perché sia chiaramente falsa, il mercato dovrebbe rifiutare una catena del genere e i nodi che contano dovrebbero continuare ad applicare il limite attuale. Il test pratico è se quasi tutti adottano un cambio di offerta, perché un cambiamento adottato da una minoranza produce un asset diverso.
