---
id: wiki.consensus-rules
slug: consensus-rules
language: it
category: protocol
title: Regole di Consenso
description: L'insieme di regole che ogni full node applica indipendentemente per accettare o rifiutare blocchi e transazioni, garantendo che tutti i partecipanti concordino su una singola storia senza bisogno di fiducia.
coverImage: media/wiki/consensus-rules/consensus-rules-hero.svg
difficulty: advanced
readTimeMinutes: 8
tags:
  - Consenso
  - Validazione
  - Regole del Protocollo
related:
  - wiki.blocks
  - wiki.full-nodes
  - wiki.proof-of-work
  - wiki.transactions
  - wiki.forks-and-soft-forks
  - wiki.mining
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: Bitcoin Developer Reference - Block Chain
    url: https://developer.bitcoin.org/reference/block_chain.html
    author: Bitcoin.org contributors
  - title: Bitcoin Core header validation logic
    url: https://github.com/bitcoin/bitcoin/blob/master/src/validation.h
    author: Bitcoin Core contributors
  - title: Bitcoin Core consensus header
    url: https://github.com/bitcoin/bitcoin/blob/master/src/consensus/consensus.h
    author: Bitcoin Core contributors
updatedAt: 2026-05-27T00:00:00Z
---

## base

Le regole di consenso sono le regole che ogni full node applica per decidere se un blocco o una transazione è valida. Sono queste regole a far sì che tutti i nodi concordino su una sola storia senza bisogno di fidarsi di nessuno.

Quando un miner propone un blocco, ogni nodo lo verifica indipendentemente. Il blocco deve seguire la struttura corretta, collegarsi a un blocco precedente valido e contenere solo transazioni valide. L'header del blocco deve includere un hash di proof of work inferiore al target corrente. La transazione coinbase può creare solo una quantità limitata di nuovo bitcoin — attualmente la ricompensa di blocco più le commissioni.

Se una qualsiasi regola viene infranta, tutti i nodi rifiutano il blocco. È così che Bitcoin rimane coerente tra migliaia di nodi operati indipendentemente.

![Pipeline di validazione delle regole](media/wiki/consensus-rules/rules-validation.svg "Un blocco in arrivo passa attraverso molteplici categorie di regole prima che il nodo lo accetti o lo rifiuti.")

## medium

Le regole di consenso si dividono in diverse categorie. Le regole a livello di blocco governano il contenitore: il blocco deve rientrare nei limiti di dimensione e peso (1 MB di dimensione virtuale post-SegWit), il timestamp non deve essere troppo lontano nel passato o nel futuro, e il target di proof of work deve corrispondere allo schedule di aggiustamento della difficoltà. Ogni 2.016 blocchi, la difficoltà viene ricalibrata per mantenere i blocchi vicino a una media di 10 minuti.

Le regole a livello di transazione governano il contenuto. Ogni input deve riferirsi a un output precedente non speso, la somma degli input deve essere uguale o superiore alla somma degli output, e ogni input deve portare una firma digitale valida che spenda l'output riferito. Nessuna transazione può creare bitcoin tranne la coinbase, e nessuna transazione può spendere lo stesso output due volte — il double-spending è bloccato a livello di consenso.

Le regole di script governano l'esecuzione di Bitcoin Script, il linguaggio usato per bloccare e sbloccare gli output. La profondità dello stack è limitata a 1.000 elementi, le operazioni di firma per blocco sono limitate, e opcode come `OP_RETURN` sono ristretti a un singolo output di 80 byte.

Le regole di consenso sono distinte dalle regole di policy. Le regole di policy sono decise dai singoli operatori di nodo — quale commissione di relay richiedere, quali versioni di transazione accettare, quali pattern di script standard veicolare. La policy varia per nodo. Le regole di consenso devono essere identiche su tutti i nodi. Modificare una regola di consenso richiede un soft fork (restringimento backward-compatible) o un hard fork (allargamento non backward-compatible), ognuno con diversi requisiti di deployment e attivazione.

## advanced

Le regole di consenso di Bitcoin si sono evolute attraverso diversi BIP chiave che hanno rafforzato la validazione:

**BIP-30** (coinbase duplicata): impedisce che due transazioni coinbase con lo stesso txid esistano in blocchi diversi. Prima del BIP-30 era possibile a causa del riutilizzo dello stesso script coinbase. I nodi ora rifiutano blocchi con coinbase txid duplicati.

**BIP-34** (altezza nella coinbase): richiede che l'altezza del blocco sia codificata nello script di input della coinbase. Questo rende la coinbase univoca e fornisce un anchor di ordinamento inequivocabile. Ogni blocco dall'altezza 227.835 deve includere la propria altezza nella coinbase.

**BIP-66** (firme DER strette): impone la codifica Distinguished Encoding Rules (DER) stretta per le firme ECDSA. Prima del BIP-66, i nodi accettavano codifiche DER non canoniche, creando vettori di malleabilità. Attivato via miner signaling nel 2015.

**BIP-65** (OP_CHECKLOCKTIMEVERIFY): aggiunge un nuovo opcode che permette di bloccare output fino a un momento specifico o a una determinata altezza di blocco. Quando un output viene speso, CLTV impone il locktime prima di permettere il relay della transazione.

**BIP-112** (CHECKSEQUENCEVERIFY): aggiunge l'enforcement del locktime relativo tramite un nuovo opcode. Combinato con BIP-68 (locktime relativo nei numeri di sequenza), abilita i payment channel e la Lightning Network permettendo di bloccare output per un numero relativo di blocchi o di tempo.

**BIP-141** (SegWit): introduce segregated witness, separando i dati di firma dal corpo della transazione. Questo ha risolto la malleabilità delle transazioni, aumentato la capacità del blocco attraverso il sistema di peso, e aggiunto un nuovo set di regole di validazione per gli input SegWit. I dati witness sono coperti dai limiti di `sigops` e peso del blocco.

**BIP-341/342** (Taproot): il più recente aggiornamento del consenso. BIP-341 introduce le firme Schnorr e la possibilità di impegnarsi a un Merkle tree di percorsi script, rendendo tutti gli output identici di default. BIP-342 modifica Script per supportare chiavi pubbliche da 32 byte, l'opcode `OP_CHECKSIGADD` e nuovi programmi witness versione 1.

Una distinzione critica è "valido secondo consenso" versus "policy di relay standard." Una transazione può essere valida secondo consenso — segue tutte le regole che ogni nodo deve applicare — ma essere rifiutata dalla policy di un nodo. Per esempio, una transazione con commissioni molto basse è valida secondo consenso se è firmata correttamente e spende output non spesi, ma la maggior parte dei nodi non la veicola perché la loro policy rifiuta tutto ciò che è sotto la commissione minima configurata. Le regole di policy esistono per prevenire spam e attacchi denial-of-service, non per definire il confine dei blocchi validi.

In Bitcoin Core, la pipeline di validazione è definita in diversi file. `src/consensus/consensus.h` contiene le costanti fondamentali del consenso — peso massimo del blocco, sigops massimi, il limite della proof of work. `src/validation.cpp` implementa la validazione principale dello stato della chain, collegando i blocchi e gestendo l'UTXO set. Le funzioni `CheckBlock` e `AcceptBlock` separano i controlli strutturali economici da quelli costosi legati allo stato, permettendo ai nodi di rifiutare blocchi ovviamente invalidi prima di sostenere il costo della verifica delle firme.
