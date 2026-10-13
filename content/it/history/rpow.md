---
id: history.rpow
slug: rpow
language: it
date: 2004-08-15
title: Hal Finney annuncia RPOW
category: origin
summary: Hal Finney annuncia Reusable Proofs of Work (RPOW), un server che scambia token hashcash con token utilizzabili ancora una volta.
tags:
  - RPOW
  - Proof of Work
  - Hal Finney
  - Moneta digitale
sources:
  - title: "RPOW - Reusable Proofs of Work (cryptography list repost)"
    url: https://www.metzdowd.com/pipermail/cryptography/2004-August/007362.html
    author: Hal Finney
    publishedAt: 2004-08-15
  - title: RPOW - Reusable Proofs of Work
    url: https://web.archive.org/web/2004/http://www.finney.org/~hal/rpow/
    author: Hal Finney
  - title: RPOW - Reusable Proofs of Work
    url: https://nakamotoinstitute.org/library/rpow/
    author: Hal Finney
related:
  - wiki.proof-of-work
  - history.hashcash
  - history.bit-gold
  - history.bitcoin-whitepaper
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

Il 15 agosto 2004 Hal Finney annunciò RPOW, acronimo di Reusable Proofs of Work, sulla mailing list cypherpunk. L'annuncio fu ripubblicato lo stesso giorno sulla lista di crittografia ospitata da metzdowd.com. Finney descrisse RPOW come la prima implementazione pubblica di un server che permette agli utenti di scambiarsi proof of work trasformandole in nuovi token, così che un token potesse passare da una persona all'altra.

Il sistema prendeva in ingresso token hashcash, valori i cui hash SHA-1 hanno molti bit alti a zero, che richiedono calcolo per essere prodotti e si verificano rapidamente. L'utente consegnava un token al server RPOW e ne riceveva uno nuovo, utilizzabile una volta e scambiabile di nuovo. Questo riutilizzo sequenziale permetteva di far passare una stessa proof of work lungo una catena, con ogni passaggio che produceva un token nuovo. Finney sosteneva che ciò rendeva le proof of work più pratiche per molti usi, mantenendo significativo il costo di creazione di un token.

RPOW aveva limiti chiari. L'integrità del server dipendeva dalla fiducia nel suo hardware e nel suo software. Finney lo fece girare su un processore sicuro e permise a terzi di verificare quale programma fosse in esecuzione, ma gli utenti dovevano comunque affidarsi al server per mantenere onesti i token. Le pagine archiviate del progetto dicono che è stato terminato e sono conservate a scopo storico. Poiché un unico server emetteva e controllava ogni token, il progetto non eliminava la terza parte fidata dal sistema.

Il whitepaper di Bitcoin non cita RPOW. Le sue otto referenze riguardano b-money, Hashcash e ricerche sulla marcatura temporale, e nessuna è RPOW. Bitcoin differisce per struttura: sostituisce il server centrale con una catena pubblica di blocchi con proof of work che ogni nodo verifica. Il post di Nick Szabo su bit gold, che descrive un obiettivo simile, menziona RPOW di Finney come implementazione di una delle sue varianti, quindi RPOW appartiene alla stessa linea di lavoro, e la differenza strutturale decisiva rispetto a Bitcoin è il server centrale.
