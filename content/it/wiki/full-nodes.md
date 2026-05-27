---
id: wiki.full-nodes
slug: full-nodes
language: it
category: protocol
title: Full Node
description: Software Bitcoin che valida indipendentemente blocchi e transazioni invece di fidarsi della vista della chain di qualcun altro.
coverImage: media/wiki/full-nodes/validation-pipeline.svg
difficulty: advanced
readTimeMinutes: 8
tags:
  - Full Node
  - Validazione
  - Consenso
  - Rete P2P
  - Privacy
related:
  - wiki.consensus-rules
  - wiki.blocks
  - wiki.utxo-model
  - wiki.mempool
  - wiki.peer-to-peer-network
sources:
  - title: Bitcoin Developer Guide - Operating Modes
    url: https://developer.bitcoin.org/devguide/operating_modes.html
    author: Bitcoin.org contributors
  - title: Bitcoin Developer Guide - P2P Network
    url: https://developer.bitcoin.org/devguide/p2p_network.html
    author: Bitcoin.org contributors
  - title: Bitcoin Core validation implementation
    url: https://github.com/bitcoin/bitcoin/blob/master/src/validation.cpp
    author: Bitcoin Core contributors
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
updatedAt: 2026-05-27T00:00:00Z
---

## base

Un full node è un software Bitcoin che controlla la blockchain da sé. Scarica blocchi, verifica transazioni e proof of work, tiene traccia dell'insieme UTXO e rifiuta dati che violano le regole.

![Pipeline di validazione di un full node](media/wiki/full-nodes/validation-pipeline.svg "Un full node riceve dati dai peer, valida header e blocchi, aggiorna l'insieme UTXO e inoltra solo dati accettabili.")

Eseguire un full node significa non dover chiedere a un server wallet quali blocchi o pagamenti siano validi. Il tuo nodo può dire se una transazione è confermata, se un blocco segue le regole e se al tuo wallet viene mostrata la stessa chain che il tuo software accetta.

I full node non sono miner. I miner propongono blocchi facendo proof of work. I full node decidono se quei blocchi sono validi secondo le proprie regole. Un miner può trovare un blocco, ma non può costringere nodi onesti ad accettarne uno invalido.

## medium

Durante l'initial block download, un full node parte dal blocco genesis e valida la chain fino alla punta corrente. Controlla proof of work, struttura dei blocchi, regole delle transazioni, script, regole di emissione e ordine in cui gli output vengono spesi e creati.

Un full node può essere archival o pruned. Un nodo archival conserva i vecchi dati di blocco e può servire blocchi storici ad altri peer. Un nodo pruned valida comunque tutta la chain e mantiene il chainstate corrente, ma elimina vecchi file di blocco quando non servono più localmente.

I full node partecipano anche alla rete peer-to-peer. Scoprono peer, scambiano header, richiedono blocchi, inoltrano transazioni valide e mantengono una mempool di transazioni non confermate che passano la policy locale. Il networking fa muovere i dati; la validazione decide cosa il nodo accetta.

Il vantaggio di sicurezza è l'indipendenza. Anche se molti peer mentono, un full node può rifiutare blocchi e transazioni invalidi. Ha bisogno di connettività per conoscere la rete, ma non esternalizza la domanda sulla validità.

## advanced

Un full node separa consenso e policy. Le regole di consenso determinano se un blocco può far parte della best chain. Le regole di policy determinano cosa il nodo inoltra o conserva in mempool prima del mining. Una transazione può essere non standard per policy ma comunque valida se un miner la include in un blocco valido.

La validazione dei blocchi è stratificata. Il nodo controlla header e proof of work, valida regole contestuali sugli header, scarica i dati di blocco, verifica struttura delle transazioni, controlla gli input contro l'insieme UTXO, esegue gli script, applica vincoli su subsidy e fee e registra il chainstate risultante se il blocco si collega.

I full node rendono prudenti anche i cambi di regole di Bitcoin. Una modifica che rende validi blocchi prima invalidi richiede che utenti e attori economici eseguano software che accetta le nuove regole. Altrimenti i loro nodi continuano a rifiutare quei blocchi. Per questo la validazione locale è parte del modello di governance di Bitcoin, non solo un dettaglio implementativo.

Pruning, default assume-valid e caching possono ridurre l'uso di risorse, ma non cambiano la responsabilità centrale: il nodo deve poter applicare le regole di consenso alla chain che accetta. Le scorciatoie di performance sono accettabili solo quando preservano lo stesso risultato finale di validazione.

Il lavoro silenzioso del full node è essere severo. Ascolta una rete aperta, ma tratta ogni peer come non fidato finché i dati non passano i controlli locali.
