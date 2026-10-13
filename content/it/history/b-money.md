---
id: history.b-money
slug: b-money
language: it
date: 1998-11-27
title: Wei Dai descrive b-money
category: origin
summary: Wei Dai descrive b-money, una proposta con cui parti pseudonime possono pagarsi a vicenda e far rispettare contratti senza un'autorità fidata, creando nuova moneta con lavoro computazionale.
tags:
  - b-money
  - Moneta digitale
  - Cypherpunk
  - Wei Dai
sources:
  - title: "PipeNet 1.1 and b-money"
    url: https://mailing-list-archive.cryptoanarchy.wiki/archive/1998/11/0e3ccb59b898d6b3dc41250477bb70f593e29f5519439e1ad189bd7fa9234d45
    author: Wei Dai
    publishedAt: 1998-11-27
  - title: b-money
    url: http://www.weidai.com/bmoney.txt
    author: Wei Dai
  - title: b-money
    url: https://nakamotoinstitute.org/library/b-money/
    author: Wei Dai
  - title: B-money
    url: https://en.bitcoin.it/wiki/B-money
    author: Bitcoin Wiki contributors
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
related:
  - wiki.digital-signatures
  - wiki.proof-of-work
  - history.bitcoin-whitepaper
  - history.hashcash
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

Il 27 novembre 1998 (UTC) Wei Dai annunciò sulla mailing list cypherpunk una proposta chiamata b-money, in un messaggio intitolato "PipeNet 1.1 and b-money". Il testo della proposta non riporta una data. La proposta descrive come un gruppo di pseudonimi non tracciabili possa pagarsi a vicenda e far rispettare contratti tra sé senza un'autorità esterna. Parte da una comunità "crypto-anarchica" che avrebbe bisogno di un mezzo di scambio e di un modo per far rispettare gli accordi.

Dai descrisse due protocolli. Il primo presupponeva un canale di trasmissione anonimo difficile da rendere pratico, e prevedeva un database separato dei saldi presso ogni partecipante. Il secondo usava un insieme di custodi dei conti, che detengono i saldi e in ogni periodo decidono quanta nuova moneta creare. La creazione avveniva tramite asta: chiunque poteva offrire una quantità di b-money insieme alla soluzione di un problema di una classe fissata, e le offerte più alte per unità di moneta venivano accreditate. Ogni periodo prevedeva quattro fasi: pianificazione, offerte, calcolo e creazione della moneta.

Il progetto lasciava aperte domande importanti. Dipendeva da custodi dei conti che dovevano accordarsi sui saldi e sulla quantità creata in ogni periodo, e il testo precisa che la creazione sarebbe avvenuta anche senza consenso tra i custodi sulle quote. Non chiariva come i custodi avrebbero raggiunto quell'accordo, e il testo non descrive un'implementazione funzionante.

Il whitepaper di Bitcoin cita b-money come riferimento [1], nel punto in cui spiega che le transazioni devono essere annunciate pubblicamente perché i partecipanti possano concordare un unico ordine dei pagamenti. Lo cita come "W. Dai, 'b-money,' http://www.weidai.com/bmoney.txt, 1998." Bitcoin segue però una strada diversa: al posto dei custodi dei conti usa una catena pubblica di blocchi con proof of work, che ogni nodo può verificare. Entrambi i progetti usano il costo del calcolo come base di fiducia, ma il whitepaper elimina la necessità di un insieme fisso di custodi fidati.
