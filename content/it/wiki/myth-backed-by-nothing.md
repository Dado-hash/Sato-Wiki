---
id: wiki.myth-backed-by-nothing
slug: myth-backed-by-nothing
language: it
category: myths
title: '"Bitcoin non è garantito da nulla"'
description: Nessun emittente o asset sta dietro a bitcoin, quindi le sue proprietà derivano da regole imposte e dal consenso della rete, mentre il suo valore dipende dalla domanda.
coverImage: media/wiki/myth-backed-by-nothing/myth-backed-by-nothing-hero.svg
difficulty: base
readTimeMinutes: 5
tags:
  - Miti
  - Moneta
  - Consenso
  - Proof of Work
related:
  - wiki.consensus-rules
  - wiki.proof-of-work
  - wiki.full-nodes
  - wiki.block-subsidy
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: "Cryptocurrencies: looking beyond the hype"
    url: https://www.bis.org/publ/arpdf/ar2018e5.htm
    author: Bank for International Settlements
    publishedAt: 2018-06-24
  - title: "Is Bitcoin a Real Currency? An economic appraisal"
    url: https://www.nber.org/papers/w19747
    author: David Yermack
  - title: Block Chain - Bitcoin Developer Guide
    url: https://developer.bitcoin.org/devguide/block_chain.html
    author: Bitcoin.org contributors
  - title: Controlled supply - Bitcoin Wiki
    url: https://en.bitcoin.it/wiki/Controlled_supply
    author: Bitcoin Wiki contributors
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

Vero in un senso, fuorviante in un altro. Nessun emittente, nessuna riserva e nessun asset sta dietro a bitcoin, e nessuno promette di riscattarlo. Questo descrive però come funziona, non se abbia valore, perché le sue proprietà derivano da regole che la rete fa rispettare.

Pensa a un gioco con un regolamento fisso. Il gioco non ha bisogno di una banca alle spalle per tenere la quantità di gettoni entro un limite, purché ogni giocatore controlli le stesse regole. Il calendario di emissione di bitcoin funziona così. Il totale è limitato a poco meno di 21 milioni di monete, e il block subsidy si dimezza ogni 210.000 blocchi, circa ogni quattro anni. I full node rifiutano ogni blocco che viola queste regole, quindi un miner che prova a creare monete in più non vede accettato nulla.

I nuovi blocchi richiedono anche proof of work, che rende costosa la riscrittura della storia recente. I pagamenti passano direttamente tra gli utenti, senza un intermediario che tenga i saldi.

Niente di questo dice che bitcoin abbia un valore preciso, né promette che la domanda durerà. Sono questioni separate. L'obiezione seria alla tesi riguarda proprio queste, ed è trattata nella sezione avanzata.

## medium

L'espressione "non garantito da nulla" di solito significa che nessun asset sta in riserva a copertura di ogni unità, e che nessuna società o governo deve restituire qualcosa ai detentori. Per bitcoin è corretto. Ma è una domanda diversa da quella su cosa dia a bitcoin le sue regole.

Il whitepaper descrive un sistema di pagamento elettronico senza una terza parte fidata. Le transazioni vengono trasmesse alla rete, e la proof of work le registra in una catena di blocchi. La catena più lunga è quella che porta il lavoro accumulato maggiore, ed è quella che i nodi seguono, finché i nodi onesti controllano la maggior parte della potenza di calcolo.

Le regole sull'offerta fanno parte del consenso. Il subsidy è stabilito dal protocollo e si dimezza ogni 210.000 blocchi; la pagina Controlled supply della Bitcoin Wiki afferma che il numero di monete non supererà poco meno di 21 milioni. Si tratta di costanti che non sono cambiate dal lancio, quindi possono essere enunciate con chiarezza. Il calendario funziona però solo perché ogni full node lo verifica. La documentazione per sviluppatori spiega che i full node validano i blocchi con le stesse regole di consenso e che un nodo conserva solo i blocchi che ha validato.

Un blocco richiede anche proof of work. La documentazione descrive l'hash dell'header del blocco, che non deve superare un valore determinato, e il valore deve essere almeno tanto impegnativo quanto la difficoltà attesa.

Un pagamento diventa più difficile da annullare man mano che altri blocchi si aggiungono sopra quello che lo contiene. Il whitepaper tratta questo come una proprietà probabilistica: più blocchi costruiti sopra una transazione, meno probabile che venga sostituita.

Insieme, questi meccanismi danno le proprietà che di solito si intendono con moneta sana: un'offerta che nessun emittente può espandere, e registrazioni che non dipendono da un unico tenutore di registro. Non creano un diritto su flussi di cassa e non obbligano nessuno a riscattare un'unità.

## advanced

La forma più forte della tesi non è che bitcoin sia privo di valore. È che un asset monetario senza garanzie ha valore solo finché le persone si aspettano che altri continueranno ad accettarlo, e che nulla nel protocollo dia una ragione per detenerlo oltre quell'aspettativa. La Bank for International Settlements ha assunto questa posizione nel rapporto annuale del 2018. Ha descritto le criptovalute come simili a una moneta-merce "senza alcun valore intrinseco nell'uso", ha detto che non sono la passività di nessuno, cioè non possono essere riscattate, e ha affermato che "il loro valore deriva solo dall'aspettativa che continueranno a essere accettate da altri". Il capitolo riguarda le criptovalute in generale, non solo bitcoin.

La risposta sopra deve rispondere a questa obiezione. Offerta fissa e proof of work sono proprietà delle regole, ma un insieme di regole non è una riserva di valore. Le regole dicono quante unità esisteranno e come vengono registrate, non quante persone le vorranno né a quale prezzo. David Yermack ha esaminato bitcoin in un working paper NBER, pubblicato nel dicembre 2013, rispetto ai test abituali di una valuta: mezzo di scambio, riserva di valore e unità di conto. Ha concluso che bitcoin si comporta più come un investimento speculativo che come una valuta.

La replica del sostenitore è che gran parte del denaro oggi in uso non è riscattabile in una merce, e che l'accettazione è un fatto sociale che non ha bisogno di un diritto su asset per essere reale. È in parte giusto, e mostra che il diritto di riscatto non è l'unica fonte di valore. Non risponde però a se un asset senza flussi di cassa e senza diritto di riscatto possa essere valutato in modo stabile. Il capitolo BIS collega la volatilità di questi asset all'assenza di un soggetto obbligato a stabilizzarne il valore.

La tesi diventerebbe falsa se bitcoin fosse garantito da una pretesa giuridicamente esigibile su un insieme identificabile di attivi, o se un emittente si impegnasse a riscattarlo. Ciò cambierebbe ciò che bitcoin è, e nessuna regola del protocollo attuale lo fa. L'obiezione seria si risolverebbe in una direzione se emergessero prove che la domanda persiste per lunghi periodi senza alcun reddito o attivo a sostegno, e nell'altra se si mostrasse che la domanda dipende da una fonte di valore che l'obiezione non ha considerato. Le regole di consenso non possono risolverlo.
