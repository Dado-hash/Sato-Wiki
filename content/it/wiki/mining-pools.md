---
id: wiki.mining-pools
slug: mining-pools
language: it
category: protocol
title: Mining pool
description: Gruppi di miner che combinano il proprio hashrate, misurano il lavoro con gli share e dividono la ricompensa, con i compromessi che il pooling comporta.
difficulty: base
readTimeMinutes: 5
tags:
  - Mining Pool
  - Mining
  - Pagamenti
  - Centralizzazione
  - Stratum
related:
  - wiki.mining
  - wiki.mining-software
  - wiki.miner-incentives
  - wiki.mining-hardware
  - wiki.proof-of-work
sources:
  - title: Bitcoin Optech - Pooled mining
    url: https://bitcoinops.org/en/topics/pooled-mining/
    author: Bitcoin Optech
  - title: Bitcoin Wiki - Pooled mining
    url: https://en.bitcoin.it/wiki/Pooled_mining
    author: Bitcoin Wiki contributors
  - title: "BIP 22: getblocktemplate - Fundamentals"
    url: https://github.com/bitcoin/bips/blob/master/bip-0022.mediawiki
    author: Luke Dashjr
  - title: Stratum V2 specification
    url: https://github.com/stratum-mining/sv2-spec
    author: Stratum V2 contributors
  - title: Stratum V2 project
    url: https://stratumprotocol.org/
    author: Stratum V2 contributors
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

Il mining è una lotteria. Ogni tentativo di hash ha una piccola probabilità di scendere sotto il target, e la probabilità di un miner di trovare il blocco successivo è più o meno la sua quota dell'hashrate totale. Un miner piccolo può aspettare a lungo tra un blocco e l'altro, e il suo reddito oscilla molto da un giorno all'altro. La trattazione Optech sul pooled mining lo illustra con un pool che controlla l'1 per cento dell'hashrate, il quale può comunque restare giorni senza trovare un blocco.

I mining pool servono ad attenuare questa varianza. Molti miner combinano il proprio hashrate, dividono il lavoro e spartiscono la ricompensa secondo una regola pubblicata. Un pool lavora tramite share. I membri calcolano hash con una difficoltà più bassa di quella della rete, quindi uno share è un hash dell'header che prova il lavoro ma non è un blocco valido. Il pool conta gli share inviati da ciascun membro. Quando un hash soddisfa anche il target della rete, il pool ha trovato un blocco, lo trasmette e paga la ricompensa.

La maggior parte dei membri non costruisce il blocco da sé. Nel protocollo più diffuso, il pool invia un template dell'header e i dati della coinbase, quindi i membri di solito non hanno voce diretta su quali transazioni il blocco contenga.

## medium

I pool differiscono soprattutto per come pagano. Optech descrive tre schemi comuni senza numeri. Il pay per share (PPS) paga ogni share a una tariffa legata al subsidy del blocco, quindi il reddito del miner non dipende dalla fortuna, e la varianza è a carico del pool. Il pay per last N shares (PPLNS) paga la ricompensa effettiva di un blocco trovato, divisa tra gli ultimi N share precedenti. Questo elimina la varianza del pool stesso, ma può lasciare i miner non pagati per lunghi periodi. Il full pay per share (FPPS) funziona come il PPS ma aggiunge le commissioni delle transazioni, che i pool stimano con un proxy, come la media delle commissioni su un periodo recente.

La regola di pagamento influisce anche sul comportamento dei miner. Il Bitcoin Wiki osserva che alcuni schemi basati su punteggio pesano meno gli share più vecchi rispetto a quelli recenti, il che riduce il guadagno nel passare da un pool a un altro a metà di un round. I miner possono cambiare pool, e lo schema decide quanto si perde o si guadagna nel farlo.

La centralizzazione è la preoccupazione principale nei pool. Il progetto Stratum V2 afferma che alcuni mining pool dominano oggi lo spazio dei blocchi di Bitcoin, alcuni agendo come proxy per altri, e che un pool può includere o escludere selettivamente le transazioni. Il motivo sta nel protocollo. Con Stratum v1, usato dalla maggior parte dei pool, i membri ricevono un template dal pool, e il pool può rifiutare modifiche alle proprie transazioni. Chi costruisce il template decide quindi cosa viene minato. Un hashrate concentrato trasforma questa decisione in una decisione concentrata.

I disegni più recenti riportano la scelta del template verso i miner. Stratum V2 può permettere ai membri di scegliere le proprie transazioni. BraidPool è un pool proposto completamente decentralizzato, in cui ogni membro sceglie le proprie transazioni. I dettagli dei template costruiti dai miner sono trattati nella voce sul software di mining.

## advanced

Perché uno share conti, deve rispettare due regole. Deve essere un blocco valido oppure ciò che sarebbe stato un blocco valido al target primario, e la sua transazione coinbase deve seguire il template fornito dal pool. Il pool può quindi fissare il layout della coinbase anche quando il miner sceglie il resto. Optech osserva inoltre che pochi utenti di Stratum v1 controllano l'header del blocco precedente con il proprio full node. In passato questa mancanza di validazione indipendente ha fatto perdere denaro ai miner che costruivano su blocchi contrari alle regole di consenso.

Gli schemi di pagamento spostano il rischio. Con il PPS il pool sopporta la varianza e deve avere capitale per pagare i membri prima di trovare blocchi. Con il PPLNS il pool non sopporta varianza, ma i miner possono restare senza pagamento durante lunghi periodi senza blocchi. Optech dice che il PPLNS elimina i problemi del pool legati alla varianza e agli attacchi di block withholding. Optech nota anche che persino un attacco di block withholding leggero potrebbe portare la redditività di un pool sotto un livello sostenibile, il che spiega perché lo schema di pagamento conta per chi gestisce il pool.

La centralizzazione ha vari livelli. L'hashrate può concentrarsi in pochi pool, e dentro ciascun pool l'operatore controlla il template, a meno che i membri non usino un protocollo che dia loro voce in capitolo. Stratum V2 separa questi ruoli con un Job Declaration Protocol. Un Job Declarator Client, lato miner, dichiara i job che intende minare, e un Job Declarator Server, lato pool, assegna token e riconosce le dichiarazioni. La specifica definisce due modalità. Nella modalità coinbase-only il pool vede la coinbase e le commissioni ma non le transazioni. Nella modalità full-template il miner dichiara l'insieme delle transazioni. Le sue connessioni usano anche un handshake Noise, quindi il collegamento è cifrato e autenticato.

In sintesi, il pooling è efficiente, e lo schema di pagamento e chi costruisce il template sono il punto in cui sorgono i suoi problemi di governance. Un pool che dà ai membri una scelta del template, una regola di pagamento chiara e una validazione indipendente della chain riduce parte del rischio. Un pool che non offre nessuna di queste cose chiede ai suoi membri di fidarsi di lui per molto più che il solo hashing.
