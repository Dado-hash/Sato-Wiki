---
id: wiki.myth-energy-waste
slug: myth-energy-waste
language: it
category: myths
title: '"Bitcoin spreca energia"'
description: Il mining usa molta elettricità per progetto, per rendere costosa la riscrittura della storia, ma se questo sia spreco è un giudizio di valore.
difficulty: base
readTimeMinutes: 5
tags:
  - Miti
  - Mining
  - Energia
  - Proof of Work
related:
  - wiki.proof-of-work
  - wiki.mining
  - wiki.difficulty-adjustment
  - wiki.miner-incentives
  - wiki.halving
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: Cambridge Bitcoin Electricity Consumption Index
    url: https://ccaf.io/cbeci/index
    author: Cambridge Centre for Alternative Finance
  - title: "The Energy Consumption of Blockchain Technology: Beyond Myth"
    url: https://link.springer.com/article/10.1007/s12599-020-00656-x
    author: Johannes Sedlmeir, Hans Ulrich Buhl, Gilbert Fridgen, Robert Keller
  - title: Block Chain - Bitcoin Developer Guide
    url: https://developer.bitcoin.org/devguide/block_chain.html
    author: Bitcoin.org contributors
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

In parte vero. Il mining di bitcoin consuma molta elettricità per progetto, perché la proof of work obbliga i miner a spendere energia per produrre blocchi. Se questo sia spreco è un giudizio di valore, e questa voce non lo decide.

Pensa a una serratura la cui robustezza dipende dallo sforzo necessario per forzarla. Lo sforzo è proprio il punto, e va pagato a ogni tentativo. In Bitcoin lo sforzo equivalente è fatto di elettricità e hardware. Chi vuole riscrivere una storia già confermata deve eguagliare e poi superare il lavoro della rete onesta, quindi l'energia spesa rende costosa la riscrittura.

Il consumo energetico non dipende dal numero di pagamenti che la rete elabora. Dipende dalla concorrenza tra miner, a sua volta legata alla ricompensa del blocco e al costo dell'elettricità. Una giornata piena e una vuota possono consumare energia simile pur trasportando numeri di pagamenti molto diversi.

Se quella elettricità provenga da fonti pulite dipende da dove avviene il mining, e cambia nel tempo. Le stime sul mix energetico differiscono, quindi ogni risposta va letta con le sue ipotesi in vista.

## medium

La cifra più citata è una stima, non una lettura di contatore. Il Cambridge Bitcoin Electricity Consumption Index (CBECI) modella la domanda di potenza della rete a partire dall'hashrate totale e dall'efficienza dell'hardware di mining probabilmente in uso. Pubblica una stima quotidiana best-guess, con il modello che parte dal 18 luglio 2010. Poiché gli input sono modellati, anche l'output ha un'incertezza. L'indice cambia ogni giorno, quindi qui non è riportata alcuna cifra.

Una stima accademica precedente dà un'idea di scala. Sedlmeir e colleghi, in un articolo del 2020 su Business & Information Systems Engineering, hanno stimato il consumo elettrico annuo di Bitcoin tra 60 e 125 TWh. Hanno collocato questo intervallo accanto al consumo di paesi come Austria e Norvegia. Gli stessi autori sostengono che le affermazioni generiche sul consumo energetico della blockchain vadano valutate con cautela.

Due parti di ogni stima sono modellate, non misurate. La prima è l'hashrate totale della rete, che si osserva dalla produzione dei blocchi ma va convertito in potenza con ipotesi sull'efficienza dell'hardware. La seconda è la quota di quella potenza prodotta da ciascuna fonte, che non viene misurata direttamente a livello di rete. Le stime sul mix dipendono quindi dal metodo usato.

Il consumo per transazione è alto perché la rete elabora pochi pagamenti al secondo. Sedlmeir e colleghi osservano che la capacità teorica di Bitcoin è limitata dai parametri dei blocchi. Il loro limite superiore del consumo di mining dipende dal prezzo dell'elettricità e dalla ricompensa del blocco, non dal numero di transazioni.

L'argomento contiene quindi due parti spesso mescolate. La prima è se la sicurezza valga l'energia, che è una questione di valori. La seconda è se l'energia sia sprecata, cosa che dipende dal fatto che un altro progetto possa offrire la stessa sicurezza a costo più basso. Questa voce non decide nessuna delle due.

## advanced

La versione più forte della tesi è che il mining spende risorse reali per un solo scopo, la sicurezza del registro, e che gran parte di quella spesa sia una corsa tra miner che non aggiunge nulla agli utenti. Se la stessa sicurezza si potesse ottenere con meno energia, il costo è evitabile, e presentarlo come una caratteristica necessaria è una scusa.

La risposta sopra risponde in due modi, e entrambi sono esposti a obiezioni serie. La prima: l'argomento della sicurezza presuppone che una corsa costosa sia l'unico modo praticabile per rendere costosa la riscrittura della storia. Sedlmeir e colleghi sostengono in modo più generale che i sistemi blockchain differiscono molto nel consumo energetico, quindi una cifra unica per "blockchain" dice poco. Un critico può accettarlo e sostenere comunque che il progetto stesso di Bitcoin, con la ricompensa fissa e la competizione aperta, spinge il consumo. La difesa poggia allora sul fatto che la sicurezza acquistata valga quel prezzo, che è un giudizio di valore.

La seconda: l'affermazione che il consumo energetico non cresca con le transazioni è vera per il protocollo, ma un critico può ribaltarla. Se l'energia per pagamento è molto alta, anche il costo di ogni pagamento è alto, e il budget di sicurezza della rete si spende comunque, che il sistema abbia molti utenti o no. Il sostenitore può rispondere che la sicurezza è una risorsa condivisa da tutti i detentori del registro, ed è proprio lo scopo di quella spesa.

La terza: le affermazioni sul mix energetico sono le meno definite. Le quote di energia rinnovabile dipendono da ipotesi modellate, e metodi diversi danno risposte diverse. Un critico può sostenere che un'affermazione sull'energia pulita non compensa una cifra di consumo grande finché non è misurata in modo indipendente. La replica è che il mix cambia con la localizzazione del mining e che misurazioni affidabili sono difficili da fare.

La tesi diventerebbe vera, nel senso di spreco, se si mostrasse che un registro con sicurezza comparabile e ampia accettazione richiede molta meno energia, e se la sicurezza offerta da Bitcoin non servisse alle persone che vi fanno affidamento. La tesi diventerebbe falsa se le prove mostrassero che l'energia serve a sostenere la sicurezza che gli utenti apprezzano, e non è spesa per la competizione fine a se stessa. Entrambi gli esiti dipendono dalla misurazione e da come le persone pesano sicurezza e costo, non dal solo protocollo.
