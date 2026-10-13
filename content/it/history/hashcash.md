---
id: history.hashcash
slug: hashcash
language: it
date: 1997-03-28
title: Hashcash proposto sulla mailing list cypherpunk
category: origin
summary: Adam Back annuncia Hashcash, un francobollo basato su proof of work pensato per rendere costoso l'invio massivo di email, sulla mailing list cypherpunk.
tags:
  - Hashcash
  - Proof of Work
  - Email
  - Cypherpunk
sources:
  - title: "[ANNOUNCE] hash cash postage implementation"
    url: https://diswww.mit.edu/bloom-picayune/crypto/453
    author: Adam Back
    publishedAt: 1997-03-28
  - title: "Hashcash - A Denial of Service Counter-Measure"
    url: http://www.hashcash.org/papers/hashcash.pdf
    author: Adam Back
    publishedAt: 2002-08-01
  - title: Hashcash
    url: https://en.bitcoin.it/wiki/Hashcash
    author: Bitcoin Wiki contributors
  - title: "Hashcash - A Denial of Service Counter-Measure"
    url: https://nakamotoinstitute.org/library/hashcash/
    author: Adam Back
    publishedAt: 2002-08-01
related:
  - wiki.proof-of-work
  - wiki.hash-functions
  - history.rpow
  - history.bitcoin-whitepaper
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

Il 28 marzo 1997 Adam Back inviò alla mailing list cypherpunk un annuncio intitolato "[ANNOUNCE] hash cash postage implementation". Il messaggio descriveva uno "schema di affrancatura basato su collisioni parziali di hash" e rimandava a una prima implementazione che chiunque poteva scaricare e provare. Back spiegò di aver discusso l'idea per alcuni giorni sulle liste di crittografia prima dell'annuncio.

Lo schema chiedeva al mittente di trovare un valore il cui hash inizi con un numero scelto di bit uguali. Trovarlo richiede molti tentativi, quindi il costo può essere fissato a piacere, mentre chiunque può verificare il risultato con un solo hash. Applicato alla posta elettronica, la prova viene allegata al messaggio come francobollo, e un destinatario o un server può rifiutare la posta che ne è priva. Nel dicembre 1997 Back suggerì di far spendere a uno spammer circa 20 secondi di CPU per ogni messaggio.

L'idea aveva limiti evidenti. Funzionava solo se destinatari o server sceglievano di richiedere il francobollo, e uno spammer con più potenza di calcolo poteva comunque pagarne il costo. L'adozione rimase limitata. Il documento del 2002 di Back, che descrive formalmente lo schema, riporta l'esperienza iniziale di alcuni esperimenti e un elenco di applicazioni e miglioramenti proposti, più che un'adozione consolidata. Lo stesso documento colloca la proposta originale nel maggio 1997, mentre l'annuncio è datato 28 marzo 1997.

Hashcash conta per Bitcoin perché la sua funzione di costo basata sulla CPU è il tipo di proof of work che Bitcoin usa. Il whitepaper di Bitcoin cita il documento di Back come riferimento [6] quando descrive un sistema di proof of work simile a Hashcash, e usa la proof of work per proteggere la catena di blocchi. Anche il progetto RPOW di Hal Finney, successivo, si basò sui token hashcash. Hashcash è quindi uno dei precursori diretti del design di Bitcoin, anche se il whitepaper presenta un proprio sistema invece di adottare Hashcash così com'era.
