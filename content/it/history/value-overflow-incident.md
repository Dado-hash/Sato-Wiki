---
id: history.value-overflow-incident
slug: value-overflow-incident
language: it
date: 2010-08-15
title: Incidente dell'overflow di valore nel blocco 74638
category: security
summary: Una transazione nel blocco 74638 crea circa 184 miliardi di BTC tramite un overflow di interi; una patch rilasciata lo stesso giorno, la versione 0.3.10, rifiuta tali transazioni.
tags:
  - Sicurezza
  - Overflow di interi
  - Consenso
  - Soft fork
sources:
  - title: "Strange block 74638"
    url: https://bitcointalk.org/index.php?topic=822.0
    author: jgarzik
    publishedAt: 2010-08-15
  - title: "Version 0.3.10 - block 74638 overflow PATCH!"
    url: https://satoshi.nakamotoinstitute.org/posts/bitcointalk/376/
    author: Satoshi Nakamoto
    publishedAt: 2010-08-15
  - title: "Re: overflow bug SERIOUS"
    url: https://satoshi.nakamotoinstitute.org/posts/bitcointalk/387/
    author: Satoshi Nakamoto
    publishedAt: 2010-08-16
  - title: CVE-2010-5139
    url: https://en.bitcoin.it/wiki/CVE-2010-5139
    author: Bitcoin Wiki contributors
related:
  - wiki.consensus-rules
  - wiki.forks-and-soft-forks
  - wiki.proof-of-work
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

Il 15 agosto 2010 uno sviluppatore notò che il blocco 74638 conteneva una transazione che creava circa 184 miliardi di BTC. La transazione aveva due output di circa 92,2 miliardi di BTC ciascuno, e la loro somma superò l'intervallo dell'intero a dimensione fissa usato dal software. Il problema fu segnalato lo stesso giorno nel thread del forum bitcointalk.org intitolato "Strange block 74638". La falla è indicata con il codice CVE-2010-5139.

Il client controllava ogni output separatamente per verificare che non fosse negativo, ma non verificava se la somma degli output andasse in overflow. Due output che singolarmente sembravano validi si sommavano in un numero negativo, che il software accettava. Il difetto stava nel codice di validazione, non nel disegno complessivo della catena.

Satoshi Nakamoto pubblicò "Version 0.3.10 - block 74638 overflow PATCH!" il 15 agosto 2010 alle 23:48 UTC. La patch modificava le regole di consenso in modo che i nodi rifiutassero transazioni con output in overflow. La Bitcoin Wiki descrive la modifica come un soft fork. I nodi non aggiornati continuarono per un certo tempo a costruire sulla catena errata, e la rete si divise brevemente in due storie concorrenti.

Il 16 agosto Satoshi scrisse che la rete aveva superato la catena errata "somewhere around 74689", cioè intorno al blocco 74689. La Bitcoin Wiki indica il blocco 74691 come altezza alla quale tutti i nodi accettarono la catena corretta, quindi l'altezza esatta è approssimativa nelle fonti. Quando la catena corretta divenne più lunga, la transazione e le monete che aveva creato non esistevano più nella catena principale. L'episodio mostra come le regole di consenso decidano quali transazioni contano e perché gli aggiornamenti dovessero essere rapidi.

Per il disegno di Bitcoin, l'episodio mostra la regola del whitepaper secondo cui la catena più lunga di proof of work è quella autorevole. Questa regola permise alla catena corretta di sostituire quella errata senza alcuna azione centrale, anche se solo dopo che i nodi avevano aggiornato il software. La patch è inoltre un primo esempio di soft fork, un cambiamento che rende più severe le regole in modo che i nodi più vecchi continuino ad accettare i nuovi blocchi.
