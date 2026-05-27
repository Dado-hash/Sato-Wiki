---
id: wiki.mempool
slug: mempool
language: it
category: protocol
title: Mempool
description: La mempool è l'area d'attesa locale di ogni nodo per le transazioni non confermate — un pool che filtra, ordina e alimenta le transazioni nei blocchi.
coverImage: media/wiki/mempool/mempool-hero.svg
difficulty: advanced
readTimeMinutes: 10
tags:
  - Mempool
  - Transazioni
  - Mining
  - Relay
  - Fee
related:
  - wiki.transactions
  - wiki.utxo-model
  - wiki.full-nodes
  - wiki.blocks
  - wiki.transaction-fees
sources:
  - title: Bitcoin Developer Guide - Transaction relay and the mempool
    url: https://developer.bitcoin.org/devguide/transactions.html
    author: Bitcoin.org contributors
  - title: Bitcoin Core mempool implementation
    url: https://github.com/bitcoin/bitcoin/blob/master/src/txmempool.h
    author: Bitcoin Core contributors
  - title: BIP-125 — Opt-in full replace-by-fee
    url: https://github.com/bitcoin/bips/blob/master/bip-0125.mediawiki
    author: David A. Harding
  - title: BIP-331 — Package relay
    url: https://github.com/bitcoin/bips/blob/master/bip-0331.mediawiki
    author: Gloria Zhao et al.
  - title: Cluster mempool documentation
    url: https://delvingbitcoin.org/t/cluster-mempool-overview/1062
    author: Suhas Daftuar
updatedAt: 2026-05-27T00:00:00Z
---

## base

La mempool è l'area d'attesa personale di ogni nodo per le transazioni non ancora confermate. Quando un wallet crea una transazione, la trasmette ai peer vicini. Ogni full node che riceve la transazione verifica le regole di validità di base. Se la transazione è accettata, il nodo la conserva nella propria mempool finché un miner non la include in un blocco.

Nodi diversi possono avere contenuti della mempool differenti. Il nodo A può aver accettato una transazione che il nodo B ha rifiutato a causa di una politica di fee più restrittiva o di una transazione in conflitto. Non esiste una mempool globale — ogni nodo mantiene la propria visione delle transazioni in attesa.

![Ciclo di vita della transazione attraverso la mempool](media/wiki/mempool/mempool-pipeline.svg "Le transazioni fluiscono dalla trasmissione attraverso la validazione, l'attesa nella mempool e infine l'inclusione in un blocco.")

Quando un miner trova un blocco, tutti i nodi rimuovono le transazioni confermate dalle loro mempool. La mempool è quindi un buffer temporaneo tra la rete di relay peer-to-peer e lo stato confermato della blockchain.

## medium

La mempool non è una semplice lista. Ogni full node esegue un insieme di regole politiche (policy) che determinano quali transazioni vengono accettate:

- **Controlli di standardness**: Bitcoin Core relay only transactions that use standard output types (P2PKH, P2SH, P2WPKH, P2WSH, P2TR), meet a minimum fee rate (default 1 sat/vB), and do not exceed the default size limit (100 kWU).
- **Limiti anti-DoS**: Il nodo limita quante transazioni orfane traccia e imposta un tetto alla dimensione totale della mempool (default 300 MB). Le transazioni che superano il limite vengono espulse a partire da quelle con fee rate più bassa.
- **Regole di sostituzione**: Replace-by-fee (RBF) permette a una nuova transazione di sostituirne una esistente se paga una fee più alta. Il BIP-125 definisce RBF opt-in, in cui la transazione originale segnala la sostituibilità.

I minatori selezionano le transazioni dalla propria mempool per creare un block template. La strategia standard è scegliere le transazioni con fee rate più alta, fino al limite di peso del blocco. La coinbase transaction raccoglie tutte le fee delle transazioni selezionate. Alcuni minatori usano politiche personalizzate come soglie di fee rate, tempo minimo in mempool o inclusione di tipi specifici di transazione.

L'ordinamento delle transazioni dentro un blocco non è casuale. Spesso i minatori ordinano per fee rate decrescente e la prima transazione dopo coinbase è tipicamente quella con la fee più alta. Questo ordine influenza la velocità con cui gli utenti possono aspettarsi la conferma.

## advanced

Quando la mempool si riempie (default 300 MB su Bitcoin Core), il nodo deve espellere transazioni. La politica di espulsione rimuove prima le transazioni con il descendant fee rate più basso. Questa scelta è più sfumata del semplice rimuovere la fee rate individuale più bassa — una transazione con fee bassa ma un figlio con fee alta può essere ancora interessante per il mining.

**CPFP (child-pays-for-parent)** è una tecnica di fee bumping in cui una nuova transazione spende l'output di una transazione non confermata con fee bassa. Il miner vede che includere sia genitore che figlio è redditizio: la fee combinata meno il peso combinato dà un fee rate effettivo più alto. I wallet usano CPFP per accelerare le conferme senza bisogno di segnalazione RBF.

**Package relay (BIP-331)** permette a un nodo di accettare un pacchetto di transazioni correlate insieme quando il genitore da solo non soddisfa la soglia di policy. Senza package relay, CPFP funziona solo se il genitore è già nella mempool del destinatario, cosa che potrebbe non accadere se il genitore è stato rifiutato per fee bassa. Package relay risolve valutando l'intero pacchetto di antenati come un'unità.

**Cluster mempool** è un riprogettazione proposta che tratta la mempool come un insieme di cluster disconnessi di transazioni dipendenti. Ogni cluster è una componente connessa di relazioni genitore-figlio. Questo rende il calcolo dell'ancestor score, l'espulsione e la validazione RBF più efficienti e prevedibili.

**Limiti di antenati e discendenti** impediscono attacchi DoS in cui una singola transazione incatena troppi dipendenti. Bitcoin Core limita una transazione a 25 antenati e 25 discendenti nella mempool. Una transazione che supererebbe questi limiti viene rifiutata.

**v3 transaction relay (BIP-133)** introduce una nuova versione di transazione con regole di sostituzione più strette. Le transazioni v3 devono usare RBF e hanno vincoli di topologia stretti (un singolo figlio). Questo previene attacchi di free relay e rende CPFP con package relay più affidabile per applicazioni come Lightning.

Quando un nodo si riavvia, ricostruisce la mempool riproducendo le transazioni recenti. Il nodo legge l'insieme UTXO dal database chainstate, processa i blocchi dall'ultimo checkpoint e usa i dati di undo dei blocchi per ricostruire le transazioni che erano nella mempool prima del riavvio, caricandole da un file mempool.dat salvato allo spegnimento.

La mempool è anche strettamente legata alla propagazione dei blocchi. Quando un nodo riceve un compact block (BIP-152), riempie le transazioni mancanti dalla propria mempool. Se la mempool ha già tutte le transazioni, il blocco può essere ricostruito in millisecondi con bandwidth minimo. Ecco perché mantenere una mempool ben popolata rende il relay dei blocchi più veloce ed economico.
