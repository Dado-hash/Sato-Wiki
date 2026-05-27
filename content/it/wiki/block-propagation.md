---
id: wiki.block-propagation
slug: block-propagation
language: it
category: protocol
title: Propagazione dei Blocchi
description: Come i blocchi Bitcoin si diffondono attraverso la rete e perché un relay veloce è cruciale per la sicurezza e le entrate dei miner.
coverImage: media/wiki/block-propagation/block-propagation-hero.svg
difficulty: advanced
readTimeMinutes: 10
tags:
  - Relay di Blocchi
  - Rete
  - Mining
  - BIP
related:
  - wiki.blocks
  - wiki.blockchain
  - wiki.full-nodes
  - wiki.consensus-rules
  - wiki.proof-of-work
sources:
  - title: "BIP-130: sendheaders message"
    url: https://github.com/bitcoin/bips/blob/master/bip-0130.mediawiki
    author: Pieter Wuille
    publishedAt: 2015-05-25
  - title: "BIP-152: Compact Block Relay"
    url: https://github.com/bitcoin/bips/blob/master/bip-0152.mediawiki
    author: Matt Corallo
    publishedAt: 2016-03-21
  - title: "BIP-330: Transaction Announcement Reconciliation (Erlay)"
    url: https://github.com/bitcoin/bips/blob/master/bip-0330.mediawiki
    author: Gleb Naumenko, Pieter Wuille
    publishedAt: 2019-09-17
  - title: "FIBRE: Fast Internet Bitcoin Relay Engine"
    url: http://bitcoinfibre.org/
    author: Matt Corallo
  - title: "Implementazione net_processing in Bitcoin Core"
    url: https://github.com/bitcoin/bitcoin/blob/master/src/net_processing.cpp
    author: Bitcoin Core contributors
  - title: "Misurazioni end-to-end della propagazione dei blocchi"
    url: https://bitcoin.stackexchange.com/questions/35093/how-long-does-it-take-for-a-block-to-propagate-on-average
    author: Bitcoin Stack Exchange
updatedAt: 2026-05-27T00:00:00Z
---

## base

Quando un miner trova un blocco valido, deve comunicarlo al resto della rete. Il blocco viene inviato ai peer connessi, che lo verificano e lo passano ai loro peer. Una propagazione più veloce significa meno tempo per trovare blocchi concorrenti, riducendo il tasso di orfani e lo spreco di risorse di rete.

![Onda di propagazione del blocco attraverso la rete](media/wiki/block-propagation/block-propagation-hero.svg "Un blocco scoperto si diffonde attraverso la rete peer-to-peer come un'onda di diffusione. Ogni nodo valida e rilancia, riducendo il rischio di corsa agli orfani.")

Un blocco che si propaga lentamente dà ai miner concorrenti più tempo per trovare il proprio blocco sullo stesso parent. Quando due blocchi validi appaiono in tempi simili, uno diventa orfano — il suo lavoro viene sprecato. La rete beneficia quando tutti i miner apprendono la nuova punta il più rapidamente possibile.

## medium

Il relay dei blocchi di Bitcoin si è evoluto attraverso diversi protocolli. Il progetto originale inviava il blocco completo a ogni peer — semplice ma dispendioso in termini di banda. Il relay moderno usa l'annuncio headers-first e il compact block relay (BIP-152) per ridurre la larghezza di banda di circa 100 volte.

Il protocollo headers-first funziona attraverso uno scambio inv/getheaders/headers. Quando un nodo viene a conoscenza di un nuovo blocco, invia un messaggio inv (inventario) con l'hash del blocco. Il peer risponde con un messaggio getheaders, e il nodo risponde con l'header del blocco di 80 byte. Solo dopo aver validato l'header — verificando la proof of work e il collegamento al blocco precedente — il peer richiede i dati completi del blocco.

Il compact block relay (BIP-152) migliora drasticamente questo processo. Invece di inviare il blocco completo, il nodo invia solo identificatori brevi di transazione (short ID) insieme a un piccolo insieme di transazioni complete che il peer probabilmente non ha. Il peer ricostruisce il blocco dalla propria mempool usando gli short ID. Se una transazione manca nella mempool, il peer la richiede individualmente. In modalità high-bandwidth, un peer preferito invia compact block direttamente senza attendere una richiesta, consentendo un relay quasi istantaneo.

![Flusso di messaggi del compact block relay](media/wiki/block-propagation/propagation-flow.svg "Sequenza di messaggi tra due nodi Bitcoin durante il compact block relay. Gli short ID permettono la ricostruzione del blocco basata sulla mempool.")

La velocità di propagazione influisce direttamente sulle entrate dei miner. Un blocco che si propaga in meno di un secondo ha un rischio di orfanità trascurabile. A due-cinque secondi, la probabilità di orfanità diventa misurabile. I pool di mining quindi competono sulla velocità di relay, spesso collegandosi tra loro attraverso reti di relay ottimizzate come FIBRE (Fast Internet Bitcoin Relay Engine) e la rete Falcon, che usano forward error correction e collegamenti dedicati per ridurre la propagazione a decine di millisecondi.

## advanced

Il relay dei blocchi ha attraversato quattro fasi principali di protocollo, ciascuna motivata dalla crescente domanda di larghezza di banda della blockchain e dalla pressione competitiva sulla latenza di mining.

**Full block relay (originale).** I nodi inviavano il blocco completo — circa 1 MB all'epoca — a ogni peer. Un nodo con 8 peer trasmetteva 8 MB per blocco. Con l'aumento delle transazioni nei blocchi, questo divenne insostenibile.

**Headers-first (BIP-130, 2015).** I nodi annunciano i blocchi inviando prima l'header di 80 byte. I peer verificano a basso costo la proof of work dell'header e il collegamento al parent, poi richiedono il blocco completo solo se l'header è valido. Questo previene lo spreco di banda da blocchi invalidi o obsoleti, ma il blocco completo viene comunque trasferito almeno una volta per peer.

**Compact blocks (BIP-152, 2016).** Il mittente del blocco costruisce short ID per ogni transazione usando SipHash-2-4 con una chiave nonce condivisa nell'handshake di versione:

```
short_id = SipHash(k0, k1, tx_hash) & 0xFFFFFFFFFFFFF
```

Lo short ID a 48 bit ha una probabilità di collisione di circa 2⁻¹⁶ per milione di transazioni, accettabile perché ogni collisione attiva una richiesta di transazione completa per lo short ID interessato. Il messaggio compact block include:

- L'header del blocco (80 byte)
- Un nonce per la chiave SipHash
- Short ID per tutte le transazioni
- La serializzazione completa di tutte le transazioni che il mittente presume manchino al peer (tipicamente coinbase e transazioni arrivate dopo lo snapshot della mempool)

Il peer ricostruisce il blocco confrontando gli short ID con la propria mempool. Se tutte le transazioni vengono trovate, il blocco viene ricostruito, validato e inoltrato. Se alcuni short ID non corrispondono (a causa di differenze di mempool, riorganizzazioni o transazioni non ancora ricevute), il peer invia un messaggio getblocktxn richiedendo le transazioni mancanti per indice. Il mittente risponde con un messaggio blocktxn contenente solo le transazioni richieste.

La modalità high-bandwidth è un'ulteriore ottimizzazione di BIP-152. I nodi selezionano fino a tre peer "preferiti" e inviano loro compact block immediatamente dopo la ricezione, senza attendere uno scambio inv/getheaders. Questo riduce il round trip di annuncio a quasi zero ed è sicuro perché il peer ricevente può ignorare blocchi duplicati o invalidi al costo di una larghezza di banda minima.

**Erlay (BIP-330, 2021).** Mentre i compact block hanno ottimizzato il relay dei blocchi, il relay delle transazioni è rimasto dispendioso in termini di banda. Erlay sostituisce l'annuncio flooding-based delle transazioni con la riconciliazione di insiemi usando un protocollo basato su Minisketch. I nodi riconciliano periodicamente i loro insiemi di inventario delle transazioni invece di annunciare ogni transazione individualmente. Questo riduce la larghezza di banda del relay delle transazioni di circa il 40% senza aumentare il ritardo di propagazione.

### Reti di relay e latenza

I pool di mining affrontano un dilemma del prigioniero sulla velocità di relay: tutti i miner beneficiano di una propagazione veloce, ma ogni singolo miner può ottenere un vantaggio investendo in collegamenti più veloci. Questo ha portato a infrastrutture di relay specializzate:

- **FIBRE** utilizza inoltro basato su UDP con forward error correction (FEC) per eliminare il blocco head-of-line di TCP. I blocchi si propagano attraverso FIBRE in meno di 200 ms a livello globale.
- **Falcon** gestisce una backbone di relay dedicata che collega i principali pool di mining e nodi Bitcoin Core, offrendo propagazione inferiore a 100 ms.
- **Tunnel di relay privati** tra pool riducono il relay dei blocchi a decine di millisecondi, al costo di una centralizzazione della rete.

I tassi di orfanità misurati sulla rete live sono circa 0,1–0,3% di tutti i blocchi. Con l'intervallo medio di 10 minuti di Bitcoin, questo si traduce in circa 5–15 blocchi orfani a settimana. Ogni orfano rappresenta circa 6,25 BTC di lavoro sprecato (più commissioni) alla difficoltà corrente, sottolineando l'incentivo economico per un relay veloce.

### Architettura net_processing in Bitcoin Core

In Bitcoin Core, il relay dei blocchi è gestito dalla classe `PeerManager` in `net_processing.cpp`. Il flusso è:

1. `ProcessMessage` smista i messaggi in arrivo (`inv`, `headers`, `cmpctblock`, `getblocktxn`, `blocktxn`, ecc.) a handler dedicati.
2. `HandleBlockMessage` valida il blocco, controlla la catena attiva, e lo connette immediatamente o lo accoda per elaborazione successiva (se il parent è sconosciuto).
3. `MaybeSendCompact` decide se richiedere un compact block o un full block da un peer in base al supporto negoziato di BIP-152 e se il peer è in modalità high-bandwidth.
4. Il download dei blocchi è parallelizzato attraverso più peer usando una finestra di scheduling, dove peer diversi forniscono blocchi diversi in parallelo durante l'initial block download (IBD).

L'architettura dà priorità agli header rispetto ai dati del blocco, così il nodo può rilevare punte di catena e riorganizzazioni prima di impegnare larghezza di banda nel trasferimento del blocco completo.
