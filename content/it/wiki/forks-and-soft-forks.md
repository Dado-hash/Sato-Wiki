---
id: wiki.forks-and-soft-forks
slug: forks-and-soft-forks
language: it
category: protocol
title: Fork e Soft Fork
description: Come la rete Bitcoin si divide in presenza di regole diverse, e perché i soft fork sono il meccanismo di aggiornamento preferito.
coverImage: media/wiki/forks-and-soft-forks/forks-hero.svg
difficulty: advanced
readTimeMinutes: 8
tags:
  - Fork
  - Soft Fork
  - Hard Fork
  - Consenso
  - Aggiornamenti
related:
  - wiki.consensus-rules
  - wiki.blocks
  - wiki.full-nodes
  - wiki.proof-of-work
  - wiki.blockchain
sources:
  - title: "Bitcoin Developer Guide - Soft Fork Activation"
    url: https://developer.bitcoin.org/devguide/soft_forks.html
    author: Bitcoin Core contributors
  - title: BIP-9 — Version bits with timeout and delay
    url: https://github.com/bitcoin/bips/blob/master/bip-0009.mediawiki
    author: Pieter Wuille
  - title: BIP-8 — Version bits with lock-in by height
    url: https://github.com/bitcoin/bips/blob/master/bip-0008.mediawiki
    author: Shaolin Fry
  - title: BIP-148 — Mandatory activation of SegWit
    url: https://github.com/bitcoin/bips/blob/master/bip-0148.mediawiki
    author: Shaolin Fry
  - title: BIP-341 — Taproot
    url: https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki
    author: Pieter Wuille, Jonas Nick, Anthony Towns
  - title: Soft fork activation terminology
    url: https://bitcoinops.org/en/topics/soft-fork-activation/
    author: Bitcoin Optech
updatedAt: 2026-05-27T00:00:00Z
---

## base

Un fork si verifica quando la rete Bitcoin si divide in due gruppi che seguono regole diverse. I fork possono essere temporanei o permanenti.

I fork temporanei avvengono naturalmente quando due miner trovano blocchi validi quasi contemporaneamente. I nodi vedono due chain concorrenti e seguono quella con più proof of work accumulata. Un ramo viene abbandonato quando un nuovo blocco estende ulteriormente un lato. Non è un cambiamento di regole — è una parte normale del consenso di Bitcoin.

I fork permanenti accadono quando le regole della rete cambiano. Un soft fork restringe le regole: i nodi vecchi vedono ancora tutti i nuovi blocchi come validi. Un hard fork allarga le regole: i nodi vecchi vedono alcuni nuovi blocchi come invalidi.

![Panoramica dei tipi di fork](media/wiki/forks-and-soft-forks/forks-hero.svg "Una blockchain si divide in un soft fork retrocompatibile e un hard fork non retrocompatibile.")

In un soft fork, i nodi vecchi rimangono sulla stessa chain dei nodi aggiornati perché le nuove regole accettano un sottoinsieme di ciò che le vecchie regole accettavano. In un hard fork, i nodi vecchi e nuovi divergono permanentemente a meno che i nodi vecchi non si aggiornino.

## medium

I soft fork modificano le regole di consenso in modo retrocompatibile. Un blocco o transazione precedentemente valido diventa invalido sotto le nuove regole, ma tutto ciò che le nuove regole accettano è anche valido sotto le vecchie regole. Questo significa che i nodi vecchi vedono ancora tutti i nuovi blocchi come validi e seguono la stessa chain.

### Meccanismi di attivazione

L'attivazione dei soft fork si è evoluta attraverso diversi standard BIP:

**BIP-9** ha introdotto il signaling tramite version bits. I miner impostano un bit nel campo version dell'header del blocco per segnalare prontezza. Una volta che 1914 blocchi su 2016 (95% di un periodo di difficoltà) segnalano, il soft fork si blocca e si attiva dopo un periodo di grazia. BIP-9 è ora ritirato.

**BIP-8** ha migliorato BIP-9 aggiungendo un'altezza di blocco obbligatoria per l'attivazione. Se il signaling non raggiunge la soglia, il soft fork si attiva comunque a un'altezza di blocco predefinita. Questo aggiunge una scadenza garantita.

**Speedy Trial** è stato usato per l'attivazione di Taproot. Ha ridotto la finestra di signaling a 2016 blocchi (circa due settimane) con una soglia del 90%. Raggiunta la soglia, il soft fork si è bloccato e attivato mesi dopo.

### Soft fork attivati da miner vs da utenti

La maggior parte dei soft fork sono miner-activated soft fork (MASF): i miner segnalano prontezza e, quando sufficienti segnalano, le regole cambiano.

Un user-activated soft fork (UASF) si attiva a un orario predeterminato indipendentemente dal signaling dei miner. L'esempio più noto è BIP-148, che imponeva il signaling SegWit dal 1 agosto 2017. I nodi BIP-148 avrebbero rifiutato blocchi da miner che non segnalavano prontezza SegWit. Questo ha creato un rischio di riorganizzazione per i miner non allineati e ha catalizzato l'attivazione di SegWit.

### Soft fork importanti

**BIP-30** (coinbase duplicata): impedisce a due transazioni coinbase con lo stesso txid di esistere in blocchi diversi.

**BIP-34** (altezza in coinbase): richiede l'altezza del blocco nell'input coinbase, rendendo ogni coinbase unica.

**BIP-66** (firme DER strette): impone codifica DER canonica per firme ECDSA, rimuovendo vettori di malleabilità.

**BIP-65** (CLTV): aggiunge OP_CHECKLOCKTIMEVERIFY per timelock assoluti.

**BIP-68/112/113** (CSV): aggiunge locktime relativo tramite numeri di sequenza e OP_CHECKSEQUENCEVERIFY, abilitando canali di pagamento e Lightning Network.

**BIP-141** (SegWit): witness segregato, risolve la malleabilità delle transazioni e aumenta la capacità dei blocchi tramite il sistema di peso.

**BIP-341/342** (Taproot): firme Schnorr, impegni MAST e una nuova versione di Script, rendendo tutti gli output identici di default.

### Requisiti di hashrate

Un soft fork necessita di più del 50% di hashrate per imporre le sue regole, perché miner con meno della metà dell'hashrate potrebbero estendere una chain con blocchi che violano le nuove regole. In pratica, la comunità mira a soglie molto più alte: 95% con BIP-9 e 90% con Speedy Trial. Soglie più basse aumentano il rischio di riorganizzazioni persistenti durante l'attivazione.

## advanced

### Confronto tecnico

La differenza tecnica fondamentale tra soft fork e hard fork è ciò che accade alla validità dei blocchi:

Un soft fork rende un blocco precedentemente **valido** **invalido**. Restringe l'insieme dei blocchi accettabili. Ogni blocco che soddisfa le nuove regole più strette soddisfa anche le vecchie regole, quindi i nodi non aggiornati vedono la stessa chain.

Un hard fork rende un blocco precedentemente **invalido** **valido**. Espande l'insieme dei blocchi accettabili. Un nodo non aggiornato rifiuta blocchi che sfruttano le nuove regole, causando una divisione permanente a meno che tutti i nodi si aggiornino.

![Confronto tra soft fork e hard fork](media/wiki/forks-and-soft-forks/soft-hard-fork.svg "A sinistra: un soft fork restringe le regole ma i nodi vecchi accettano ancora i nuovi blocchi. A destra: un hard fork allarga le regole e i nodi vecchi rifiutano i nuovi blocchi.")

### Perché Bitcoin Core preferisce i soft fork

Bitcoin Core ha una forte preferenza istituzionale per i soft fork perché preservano la retrocompatibilità. I nodi vecchi non devono aggiornarsi per rimanere sulla chain corretta. Questo minimizza le interruzioni, riduce i costi di coordinamento e previene divisioni forzate della rete.

Gli hard fork creano due reti concorrenti con la stessa storia fino al punto di fork. La comunità deve decidere quale chain ha il bitcoin valido — una decisione sociale ed economica, non tecnica. Per questo gli hard fork sono riservati a circostanze estreme o quando una separazione netta è l'obiettivo esplicito.

### Incentivi economici e sovranità dei nodi

Il signaling dei miner è usato nell'attivazione dei soft fork perché i miner devono imporre le nuove regole affinché il fork sia sicuro. Se la maggioranza dell'hashrate non impone le nuove regole, una chain di minoranza potrebbe superarla. Tuttavia, i miner non decidono quali sono le regole — lo fanno i full node. Un operatore di nodo che non è d'accordo con un soft fork può scegliere di non aggiornarsi, e il suo nodo seguirà comunque la chain valida più lunga sotto le vecchie regole.

Questo è il principio della maggioranza economica: le regole di Bitcoin sono in ultima analisi imposte dai nodi che gli attori economici (exchange, commercianti, utenti) gestiscono. Se un soft fork è osteggiato da una significativa maggioranza economica, non sarà adottato indipendentemente dal signaling dei miner.

### Hard fork storici

**SegWit2x (2017):** Un hard fork proposto per aumentare il limite di dimensione dei blocchi a 2 MB. Faceva parte del New York Agreement ma fu cancellato a novembre 2017 per insufficiente consenso comunitario. La chain SegWit2x non è mai stata lanciata.

**Bitcoin Cash (2017):** Un hard fork che ha aumentato il limite di dimensione dei blocchi a 8 MB e rimosso SegWit. Si è separato da Bitcoin al blocco 478.558 creando un asset separato. Bitcoin Cash in seguito ha subito un altro hard fork dividendosi in Bitcoin ABC e Bitcoin SV.

**Bitcoin SV (2018):** Un hard fork da Bitcoin Cash che ha ulteriormente aumentato i limiti di dimensione dei blocchi a 128 MB e ripristinato gli opcode originali di Satoshi. Rappresenta un'interpretazione estrema della filosofia "big block".

### Dettagli dei meccanismi di attivazione

BIP-9 usava il campo version dell'header del blocco come bitfield. I miner impostavano il bit N per segnalare supporto al BIP N. Durante ogni periodo di difficoltà (2016 blocchi), se 1914 blocchi su 2016 (95%) avevano il bit impostato, il soft fork si bloccava. Dopo un periodo di grazia di altri 2016 blocchi, si attivava. Se la soglia non veniva raggiunta prima di un timeout, il bit veniva marcato come FALLITO.

BIP-8 ha aggiunto un meccanismo chiamato "lock-in by height." Se la soglia di signaling viene raggiunta prima dell'altezza di timeout, il soft fork si attiva come in BIP-9. Se la soglia non viene raggiunta, il soft fork si attiva comunque all'altezza di timeout — i miner non possono più bloccare l'attivazione. Il parametro LOT (Lock-in On Timeout) controlla questo comportamento.

Speedy Trial, usato per Taproot, ha compresso significativamente la tempistica. Il periodo di signaling era di soli 2016 blocchi (circa due settimane) con una soglia del 90% (1816 su 2016). La soglia è stata raggiunta in un singolo periodo, attivando il blocco e l'attivazione mesi dopo al blocco 709.632.

### Rischio di riorganizzazione durante l'attivazione

Durante l'attivazione di un soft fork, esiste una breve finestra in cui potrebbe verificarsi una riorganizzazione se una chain con hashrate di minoranza continua sotto le vecchie regole mentre la maggioranza si sposta sulle nuove. BIP-148 (UASF per SegWit) ha esplicitamente creato questo rischio come leva: i miner che non segnalavano prontezza SegWit entro il 1 agosto 2017 rischiavano di vedere i loro blocchi rifiutati dai nodi UASF, il che poteva innescare una riorganizzazione della loro chain. Questa pressione economica ha spinto la comunità di mining ad attivare SegWit tramite il meccanismo BIP-9 esistente.

Il principio è che l'attivazione di un soft fork non è solo un processo tecnico ma economico. I nodi impongono le regole. I miner estendono le chain sotto quelle regole. Se utenti e attori economici impongono nuove regole tramite nodi aggiornati, i miner devono seguire o rischiare di costruire su una chain che gli attori economici rifiutano.
