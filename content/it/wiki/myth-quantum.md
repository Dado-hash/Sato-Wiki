---
id: wiki.myth-quantum
slug: myth-quantum
language: it
category: myths
title: '"I computer quantistici romperanno Bitcoin"'
description: "Parzialmente vero: un computer quantistico abbastanza grande minaccerebbe le firme delle chiavi esposte, ma oggi nessuna macchina del genere esiste e non se ne conosce la data."
coverImage: media/wiki/myth-quantum/myth-quantum-hero.svg
difficulty: base
readTimeMinutes: 5
tags:
  - Miti
  - Quantistica
  - Crittografia
  - Firme
related:
  - wiki.digital-signatures
  - wiki.ecdsa
  - wiki.schnorr-signatures
  - wiki.sha-256
  - wiki.address-reuse
sources:
  - title: Bitcoin Optech - Quantum Resistance
    url: https://bitcoinops.org/en/topics/quantum-resistance/
    author: Bitcoin Optech
  - title: "BIP 360: Pay-to-Merkle-Root (P2MR)"
    url: https://github.com/bitcoin/bips/blob/master/bip-0360.mediawiki
    author: Bitcoin BIP authors
  - title: "BIP 341: Taproot: SegWit version 1 spending rules"
    url: https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki
    author: Bitcoin BIP authors
  - title: "Polynomial-Time Algorithms for Prime Factorization and Discrete Logarithms on a Quantum Computer"
    url: https://arxiv.org/abs/quant-ph/9508027
    author: Peter W. Shor
  - title: "A fast quantum mechanical algorithm for database search"
    url: https://arxiv.org/abs/quant-ph/9605043
    author: Lov K. Grover
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

Parzialmente vero. Un computer quantistico in grado di rompere le firme di Bitcoin sarebbe una grave minaccia di lungo periodo, ma oggi non esiste una macchina del genere e nessuno sa quando potrebbe esistere. La minaccia è anche più ristretta di quanto suggerisca l'affermazione. Riguarda soprattutto le monete la cui chiave pubblica è già visibile sulla blockchain, mentre l'hashing, che protegge il mining, è molto meno colpito.

Bitcoin protegge la spesa con firme prodotte da una chiave privata. La chiave pubblica deriva da quella privata, e una firma dimostra che chi spende conosce la chiave privata. Un computer quantistico che esegua un algoritmo adatto potrebbe in linea di principio risalire dalla chiave pubblica a quella privata, e permettere così a un attaccante di spendere monete la cui chiave è esposta. Molti indirizzi nascondono la chiave pubblica dietro un hash fino alla spesa, quindi sono esposti molto meno.

Il quadro corretto è che il rischio è reale per alcuni output, in un futuro incerto. Gli sviluppatori hanno proposte per firme e tipi di output post-quantistici, ma nessuna è ancora in Bitcoin, e le alternative richiedono chiavi e firme molto più grandi.

## medium

Il meccanismo dipende dall'algoritmo. L'algoritmo di Shor, descritto in un articolo disponibile come preprint su arXiv, mostra che un computer quantistico sufficientemente grande potrebbe fattorizzare interi e calcolare logaritmi discreti in tempo polinomiale. Le firme di Bitcoin si basano su logaritmi discreti su curve ellittiche: ECDSA e firme Schnorr sulla curva secp256k1. Una macchina che eseguisse l'algoritmo di Shor alla dimensione richiesta potrebbe ricavare una chiave privata dalla chiave pubblica. Optech dice che un attacco del genere eliminerebbe la sicurezza di ECDSA, e lo stesso vale per Schnorr.

L'esposizione è la variabile centrale. Con il pay-to-public-key-hash, l'output si impegna solo verso un hash della chiave pubblica, quindi la chiave non è visibile finché le monete non vengono spese. Gli output taproot inseriscono nello script di output una chiave pubblica modificata (tweaked), visibile dal momento in cui l'output esiste, come specifica la BIP 341. Una volta fatta una spesa, la sua chiave pubblica è pubblica.

L'hashing è un caso diverso. SHA-256 è usato per la proof of work e per gli identificatori. L'algoritmo di Grover offre un'accelerazione quadratica per la ricerca non strutturata, con O(sqrt N) passi secondo il suo articolo su arXiv. Optech dice che questo dimezza i bit di sicurezza di SHA-256 contro gli attacchi di preimmagine, da 256 a 128, e che si recupera con una funzione con il doppio dei bit. Per il mining la perdita è quindi molto più piccola di quella che Shor causa alle firme.

Ciò che resta sconosciuto è il tempo. Optech osserva che la capacità e l'affidabilità dei computer quantistici probabilmente cresceranno gradualmente, quindi anche la sicurezza della crittografia di Bitcoin calerebbe gradualmente. Nessuna fonte indicata fornisce una data, e questa voce non ne dà una. La BIP 360, ancora in stato di bozza, propone un nuovo tipo di output che rimuove il key path spend di taproot. Affronta gli attacchi di lunga esposizione, non quelli che agiscono mentre una transazione attende nella mempool. Le firme post-quantistiche sono l'altra strada, e sono più grandi.

## advanced

La versione più forte dell'affermazione va oltre le macchine attuali. Bitcoin contiene una grande quantità di valore in output le cui chiavi pubbliche sono già nel registro, e un proprietario che ha perso le chiavi o ha smesso di occuparsene non può spostare quelle monete. Un avversario capace potrebbe prenderle senza il permesso di nessuno, e la rete non ha modo di fermare un furto del genere, perché una firma valida è l'unico controllo che un nodo applica alla spesa delle monete. L'affermazione è seria perché il registro è pubblico: chiunque può verificare quali chiavi sono esposte, quindi un attaccante può scegliere in anticipo i bersagli più facili.

Anche le obiezioni sono serie. Il problema della breve esposizione è il più acuto. Una transazione che spende da una chiave rivela quella chiave alla mempool prima di essere confermata, e una macchina abbastanza veloce da ricavare la chiave privata in quella finestra potrebbe battere sul tempo la transazione onesta. La BIP 360 dice che il tipo di output proposto affronta gli attacchi di lunga esposizione, e che la protezione dagli attacchi di breve esposizione potrebbe richiedere firme post-quantistiche. Optech osserva che esistono alternative resistenti ai quantistici rispetto a ECDSA, ma con chiavi e firme molto più grandi, il che rende lo spazio dei blocchi e le fee un vincolo reale.

La risposta dipende dal tempo. Optech descrive una progressione da attacchi computazionalmente irrealizzabili, a teoricamente possibili ma implausibili, a straordinariamente costosi, fino a molto costosi. Sostiene che Bitcoin può mantenere la crittografia attuale finché resta sicura e passare alla crittografia post-quantistica quando la minaccia appare vicina. Quella risposta ha un punto debole: presuppone che il progresso sia visibile abbastanza chiaramente e che la comunità si accordi abbastanza presto per migrare. Forzare la migrazione, congelando o distruggendo le monete esposte, sarebbe una modifica contestata delle regole, perché colpirebbe proprietari che non hanno agito e richiederebbe un fork che la maggior parte della rete accetti.

Perché l'affermazione diventi vera, una macchina quantistica dovrebbe risolvere i logaritmi discreti su curve ellittiche alla dimensione di secp256k1 entro il tempo in cui una transazione attende nella mempool, e abbastanza monete esposte dovrebbero restare non migrate da rendere conveniente l'attacco. Perché sia chiaramente falsa, un percorso di migrazione dovrebbe essere attivo e la maggior parte del valore dovrebbe essere già uscita dagli output esposti prima che esista una macchina capace. Fino ad allora le questioni aperte sono quando una macchina del genere potrebbe esistere e se la comunità riuscirà a muoversi prima che conti.
