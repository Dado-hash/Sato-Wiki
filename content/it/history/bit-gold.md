---
id: history.bit-gold
slug: bit-gold
language: it
date: 2005-12-29
title: Nick Szabo pubblica Bit Gold
category: origin
summary: Nick Szabo pubblica il post "Bit gold" sul suo blog Unenumerated, proponendo token digitali non falsificabili costruiti con catene di proof of work e un registro distribuito dei titoli.
tags:
  - Bit Gold
  - Nick Szabo
  - Proof of Work
  - Moneta digitale
sources:
  - title: Bit gold
    url: https://unenumerated.blogspot.com/2005/12/bit-gold.html
    author: Nick Szabo
  - title: Bit Gold
    url: https://nakamotoinstitute.org/library/bit-gold/
    author: Nick Szabo
    publishedAt: 2005-12-29
  - title: Bit Gold
    url: https://en.bitcoin.it/wiki/Bit_Gold
    author: Bitcoin Wiki contributors
related:
  - wiki.proof-of-work
  - wiki.digital-signatures
  - history.rpow
  - history.b-money
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

Nick Szabo pubblicò sul suo blog Unenumerated un post intitolato "Bit gold" nel dicembre 2005. Il giorno esatto è incerto: la pagina del post mostra una data di ripubblicazione del 27 dicembre 2008, e il Nakamoto Institute indica come data originale il 29 dicembre 2005, usata qui. Il post apre dicendo che il suo autore ha avuto "l'idea di bit gold" molto tempo prima, e sostiene che il valore del denaro dipende dalla fiducia in una terza parte.

La proposta era un protocollo per creare online token digitali non falsificabili. Ogni nuova stringa di bit sarebbe il risultato di un enigma computazionale, una proof of work costosa da produrre e facile da verificare. La sfida di ogni enigma è la stringa creata subito prima, così ogni token dipende da quello precedente. La prova viene marcata temporalmente da più servizi e registrata in un registro distribuito dei titoli di proprietà. La titolarità è mostrata dalla catena ininterrotta di firme digitali in quel registro, e chiunque può verificare la sfida, la prova e la marca temporale di un token.

Szabo stesso elencò i limiti principali: la sicurezza dello schema dipende da quanto bene la fiducia è distribuita tra i servizi di marcatura temporale e il registro, e dal problema dell'architettura delle macchine. Il post non descrive un sistema finito con software funzionante e lascia aperta la questione di come mantenere onesto il registro nella pratica. La versione online menziona anche RPOW di Hal Finney, che è del 2004, quindi il testo è stato aggiornato dopo la prima pubblicazione.

Il whitepaper di Bitcoin non cita bit gold. Le sue referenze sono b-money, Hashcash e ricerche sulla marcatura temporale, e il post di bit gold non è tra queste. Tuttavia bit gold e Bitcoin condividono uno schema di progetto: una catena di proof of work, registrazioni con marca temporale e titolarità dimostrata tramite firme. Il whitepaper di Bitcoin presenta una propria versione di questo schema, con una catena pubblica di blocchi al posto del registro dei titoli.
