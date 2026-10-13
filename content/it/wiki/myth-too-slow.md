---
id: wiki.myth-too-slow
slug: myth-too-slow
language: it
category: myths
title: '"Bitcoin è troppo lento per essere utile"'
description: "Parzialmente vero: il base layer conferma solo poche transazioni al secondo per scelta progettuale, e i layer costruiti sopra gestiscono i pagamenti più piccoli con compromessi propri."
coverImage: media/wiki/myth-too-slow/myth-too-slow-hero.svg
difficulty: base
readTimeMinutes: 5
tags:
  - Miti
  - Scalabilità
  - Lightning
  - Blocchi
related:
  - wiki.blocks
  - wiki.fee-market
  - wiki.lightning-network
  - wiki.weight-units
  - wiki.payment-channels
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: "The Bitcoin Lightning Network: Scalable Off-Chain Instant Payments"
    url: https://lightning.network/lightning-network-paper.pdf
    author: Joseph Poon and Thaddeus Dryja
    publishedAt: 2016-01-14
  - title: Bitcoin Core - Chain Parameters (chainparams.cpp)
    url: https://github.com/bitcoin/bitcoin/blob/master/src/kernel/chainparams.cpp
    author: Bitcoin Core contributors
  - title: Bitcoin Core - Consensus Parameters (consensus.h)
    url: https://github.com/bitcoin/bitcoin/blob/master/src/consensus/consensus.h
    author: Bitcoin Core contributors
  - title: Bitcoin Developer Guide - Block Chain
    url: https://developer.bitcoin.org/devguide/block_chain.html
    author: Bitcoin.org contributors
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

Parzialmente vero. Il base layer, cioè la catena principale di Bitcoin, è lento per i pagamenti quotidiani. Un nuovo blocco arriva circa ogni dieci minuti e contiene solo una quantità limitata di dati, quindi la catena gestisce solo poche transazioni al secondo. È comunque il posto in cui i pagamenti diventano definitivi e in cui si regolano i trasferimenti grandi o importanti, perché è questo che è stato costruito per fare. I pagamenti quotidiani più piccoli di solito passano per layer costruiti sopra, come la Lightning Network, che sono più veloci ed economici ma hanno compromessi propri.

Il limite è voluto. Mantenere piccoli i blocchi rende meno costoso per le persone comuni far girare un full node, e i nodi sono ciò che mantiene oneste le regole di Bitcoin. Blocchi più grandi renderebbero più veloce lo spostamento di monete, ma richiederebbero computer più potenti per verificarli, e meno persone potrebbero far girare un nodo. Velocità e possibilità per chiunque di verificare la catena si tirano a vicenda.

La risposta onesta è quindi che Bitcoin è lento per molti usi, e che questa lentezza è una scelta su ciò che il base layer deve fare.

## medium

Due parametri fissano il ritmo e la capacità del base layer. L'intervallo medio tra i blocchi è di dieci minuti, un valore che Bitcoin Core imposta come target di spaziatura della proof of work per la mainnet. Ogni blocco può contenere al massimo 4.000.000 di weight unit secondo il codice di consenso attuale. Le transazioni hanno dimensioni diverse, quindi il numero di transazioni per blocco varia, e alcune al secondo è una media approssimativa, non un ritmo fisso. Il paper della Lightning Network, bozza del gennaio 2016 scritta prima del limite attuale, descriveva Bitcoin come capace di gestire meno di 7 transazioni al secondo con un limite di blocco di 1 megabyte. Il valore è approssimativo e superato: va letto come ordine di grandezza.

Conferma e regolamento sono cose diverse. Una transazione è confermata quando compare in un blocco. Diventa praticamente definitiva solo dopo che sopra di essa sono stati costruiti altri blocchi, perché ogni blocco in più rende un ribaltamento più costoso. Il whitepaper mostra come la probabilità che un attaccante raggiunga la catena cali rapidamente con i blocchi aggiunti. Un pagamento può quindi essere visibile in pochi minuti ma richiedere ancora tempo prima di essere davvero sicuro per il venditore.

Il limite protegge anche la rete. Il paper della Lightning Network sostiene che la validazione completa deve restare economica, così che un computer di consumo collegato a una linea domestica possa verificare la catena. Con blocchi molto grandi, solo pochi soggetti potrebbero validarli, e la fiducia scivolerebbe verso di loro. Bitcoin mantiene piccolo il base layer perché i controlli restino aperti a molte persone.

La Lightning Network sposta i pagamenti ripetuti in canali tra due parti, e sulla catena compaiono solo l'apertura e la chiusura di un canale. Il paper descrive pagamenti che possono essere instradati attraverso più canali e fatti rispettare sulla catena tramite timelock se una parte non collabora. I canali hanno costi propri. Entrambe le parti bloccano fondi, e un pagamento attraverso più canali richiede liquidità sufficiente su ogni tratto del percorso.

## advanced

La versione più forte dell'affermazione è che Bitcoin non può fare da sistema di pagamento per la vita di tutti i giorni. A poche transazioni al secondo, il base layer può trasportare solo una piccola parte dei pagamenti, e se i layer costruiti sopra falliscono o costano troppo, resta solo la transazione on-chain, costosa. Secondo questa lettura, la scelta di progetto di tenere piccoli i blocchi è un tetto permanente e non temporaneo, e tutto il resto è un ripiego.

C'è un punto serio. I blocchi sono limitati, quindi quando la domanda supera lo spazio, gli utenti competono con le fee (vedi la voce sul fee market). La Lightning dipende dalla liquidità dei canali, e un pagamento che attraversa molti canali è disponibile solo quanto il percorso che segue. Anche i canali richiedono transazioni on-chain per aprirsi e chiudersi, quindi un uso intenso del layer continua a produrre attività sul base layer.

La risposta ha tre parti. Primo, il base layer non deve portare tutto. Il suo compito è essere un layer di regolamento in cui la proprietà viene registrata e le controversie risolte, e i suoi progettisti volevano che restasse economico da verificare. Secondo, alzare il limite è possibile ma è una modifica deliberata: la developer guide cita l'aumento della dimensione del blocco oltre 1 MB come esempio di modifica che richiede un hard fork, che ogni nodo deve adottare. Terzo, quanta capacità basti è una questione sociale, e il protocollo da solo non la risolve.

Le obiezioni sono che la risposta può sembrare una scusa. Una modifica di consenso è lenta da coordinare, e il costo dell'attesa ricade sugli utenti che devono pagare adesso. I layer aggiungono complessità e modalità di guasto proprie. Il paper della Lightning dava per scontato che la catena restasse economica da verificare mentre la domanda cresceva, e questa è una scommessa su hardware e condizioni di rete futuri, non una dimostrazione. Un critico può accettare tutta la logica progettuale e chiedersi comunque se serva i pagamenti che le persone fanno davvero.

Perché l'affermazione diventi vera, il base layer dovrebbe restare alla sua capacità attuale mentre i layer costruiti sopra non riescono a servire i pagamenti quotidiani a costi e con sicurezza accettabili, spingendo gli utenti verso custodi. Perché sia chiaramente falsa, i layer dovrebbero gestire i pagamenti quotidiani a basso costo mantenendo le proprietà di autocustodia e sicurezza che rendono utile il base layer. Il test pratico sarebbero i tempi di conferma e le fee misurati nei momenti di picco.
