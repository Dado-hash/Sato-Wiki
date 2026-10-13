---
id: wiki.mining-hardware
slug: mining-hardware
language: it
category: hardware
subcategory: mining-hardware
title: Hardware di mining
description: I dispositivi che calcolano gli hash di proof of work di Bitcoin, dalle CPU agli ASIC, e i componenti che li compongono.
difficulty: base
readTimeMinutes: 5
tags:
  - Mining
  - ASIC
  - Proof of Work
  - Hardware
  - Open Source
related:
  - wiki.mining
  - wiki.proof-of-work
  - wiki.sha-256
  - wiki.mining-energy-economics
  - wiki.mining-software
sources:
  - title: "Mastering Bitcoin - Capitolo 12, Mining"
    url: https://github.com/bitcoinbook/bitcoinbook/blob/develop/ch12_mining.adoc
    author: Andreas M. Antonopoulos
  - title: Bitcoin Developer Guide - Mining
    url: https://developer.bitcoin.org/devguide/mining.html
    author: Bitcoin.org contributors
  - title: ESP-Miner
    url: https://github.com/bitaxeorg/ESP-Miner
    author: OSMU contributors
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

L'hardware di mining è l'attrezzatura che calcola gli hash richiesti dalla proof of work di Bitcoin. Un miner prova un numero enorme di header di blocco candidati e cerca quello il cui hash rispetta il target della rete. Trovare un blocco valido fa guadagnare la ricompensa del blocco e le fee, e più hash un dispositivo calcola al secondo, più tentativi compie.

Bitcoin è stato minato per la prima volta su CPU normali. Poi sono arrivate le schede grafiche e infine i chip programmabili chiamati FPGA. Ogni passaggio ha prodotto più hash a parità di lavoro. Nel 2013 i chip ASIC hanno determinato un altro grande salto di potenza di mining. Un ASIC è costruito per calcolare solo la doppia SHA-256 usata da Bitcoin. È molto meno flessibile di un computer generico, ma per questo unico compito è molto più veloce ed efficiente.

Le macchine di mining di oggi sono di solito costruite come un unico corpo che contiene diverse schede, una scheda di controllo, un alimentatore e un sistema di raffreddamento. Alcune sono grandi unità industriali per data center. Altre sono piccoli dispositivi domestici che girano con firmware open source. Il livello medium spiega come lavorano insieme queste parti e come confrontare le macchine.

## medium

Un tipico miner ASIC ha quattro parti principali. Le hashboard portano molti chip che eseguono la funzione di hash in parallelo. Una scheda di controllo riceve il lavoro dal software di mining, lo invia alle hashboard, raccoglie i risultati e invia share o blocchi validi a un pool o a un nodo. L'alimentatore converte la corrente di rete nelle tensioni richieste dai chip. Il raffreddamento, di solito ventole, rimuove il calore prodotto dai chip. Ogni parte può guastarsi, e una singola scheda è spesso più facile da sostituire di un'intera macchina.

La metrica chiave è l'efficienza, di solito espressa in joule per terahash. È la potenza consumata divisa per l'hashrate, quindi un numero più basso significa meno elettricità per lo stesso lavoro. L'hashrate da solo può trarre in inganno. Una macchina con hashrate più alto può assorbire così tanta potenza da risultare meno efficiente. Il prezzo dell'elettricità incide sulla redditività più di qualsiasi singola caratteristica, quindi la stessa macchina può avere senso in un posto e non in un altro.

Calore e rumore contano in casa. Le unità industriali sono collocate in strutture con alimentazione e raffreddamento dedicati. Un piccolo miner domestico sta in una stanza, e le sue ventole possono essere rumorose e il calore evidente. Il proprietario deve pianificare il flusso d'aria, i circuiti elettrici e il fatto che la macchina funziona di continuo.

I miner domestici e open source, come il Bitaxe, usano un firmware rilasciato con licenza aperta, quindi il proprietario può ispezionare e modificare il software. Il progetto ESP-Miner è un firmware open source per il controller ESP32 delle schede Bitaxe, distribuito con licenza GPL-3.0. Grandi produttori vendono unità industriali, come le serie Antminer S o Whatsminer M, pensate per installazioni più grandi. Qualunque macchina si scelga, il firmware che la fa girare fa parte del progetto e va tenuto aggiornato.

## advanced

Il mining è una gara in cui la probabilità di un miner di trovare un blocco è proporzionale alla sua quota dell'hashrate totale della rete. La difficoltà si adatta in modo che i blocchi arrivino a un intervallo medio costante, quindi la probabilità di un singolo dispositivo è minuscola rispetto all'intera rete. La Bitcoin Developer Guide descrive la scelta tra mining solo e mining in pool. Un miner solo trattiene l'intera ricompensa del blocco e le fee, ma i pagamenti hanno alta varianza, cioè lunghi intervalli tra una ricompensa e l'altra. Un pool condivide i proventi in modo approssimativamente proporzionale alla potenza di hashing, con pagamenti più piccoli e frequenti e varianza più bassa.

Mastering Bitcoin usa un esempio semplice. Un miner con una frazione molto piccola dell'hashrate della rete potrebbe aspettarsi di trovare un blocco solo dopo un lungo periodo, se la difficoltà non cambiasse mai. Le probabilità reali dipendono dall'hashrate e dalla difficoltà attuali, che cambiano continuamente, quindi la affermazione onesta è qualitativa. Il mining solo è una scommessa, e il pool scambia una parte della ricompensa con la prevedibilità.

In una configurazione tipica, un computer host esegue un nodo e passa gli header di blocco all'hardware di mining, che prova i valori di nonce. Quando lo spazio dei nonce si esaurisce, l'header viene modificato tramite extra nonce, version bits o timestamp, e il test continua. Il software di mining fa quindi parte del perimetro di fiducia. Un bug o un firmware ostile potrebbero produrre share non valide, trattenere il lavoro o indirizzare l'hashpower verso un pool che il proprietario non ha scelto. Controllare firmware, impostazioni del pool e aggiornamenti fa parte della gestione dell'hardware.

L'economia dipende molto dall'elettricità. Il capitolo di Mastering Bitcoin osserva che il fattore principale della redditività è il prezzo del kilowattora, e che i sistemi più efficienti trasformano l'elettricità in hashing vicino al limite del silicio attuale. Lo stesso capitolo descrive un garage domestico pieno di hardware di fascia alta che assorbe decine di kilowatt, e lo confronta con operazioni commerciali che impilano decine di migliaia di macchine vicino alle centrali elettriche. I sistemi di consumo più veloci non possono competere con questa scala.

Eseguire questo hardware in casa solleva questioni pratiche. Il consumo deve rientrare nel circuito elettrico, il calore va smaltito e il rumore deve essere tollerabile per chi vive vicino. Una macchina che lavora in continuo è un carico costante, e la sua installazione va trattata come qualunque altra apparecchiatura elettrica pesante.
