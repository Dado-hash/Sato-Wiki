---
id: wiki.myth-ponzi
slug: myth-ponzi
language: it
category: myths
title: '"Bitcoin è uno schema Ponzi"'
description: "Falso come descrizione del funzionamento della rete, con un punto valido dentro l'obiezione: il prezzo dipende dai nuovi acquirenti e molte truffe hanno usato bitcoin."
difficulty: base
readTimeMinutes: 5
tags:
  - Miti
  - Economia
  - Truffe
  - Mercato
related:
  - wiki.blockchain
  - wiki.miner-incentives
  - wiki.consensus-rules
  - wiki.full-nodes
  - wiki.myth-miners-control
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: Ponzi scheme
    url: https://en.wikipedia.org/wiki/Ponzi_scheme
    author: Wikipedia contributors
  - title: Bitcoin
    url: https://en.wikipedia.org/wiki/Bitcoin
    author: Wikipedia contributors
  - title: "Yes, Bitcoin is a Ponzi: A Re-Rebuttal"
    url: https://ic.unicamp.br/~stolfi/bitcoin/2021-01-16-yes-ponzi.html
    author: Jorge Stolfi
    publishedAt: 2021-01-16
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

Falso come descrizione del funzionamento della rete, con un punto valido dentro l'obiezione. Uno schema Ponzi ha un operatore che promette rendimenti e paga gli investitori precedenti con il denaro di quelli successivi. Bitcoin non ha un operatore, non promette alcun rendimento a nessuno, e le sue regole e il suo registro sono pubblici. Il punto valido è che il prezzo di mercato dipende dal fatto che arrivino nuovi acquirenti, e molte truffe hanno usato bitcoin o il suo nome. È per questo che i critici usano la parola.

Confronta le caratteristiche una per una. Uno schema Ponzi ha bisogno di qualcuno che raccoglie denaro e decide chi viene pagato. Bitcoin non ha una società, un fondo o una tesoreria che riceve depositi e li rimanda indietro. I pagamenti vanno da un proprietario all'altro, e la rete li registra senza intermediari. Uno schema Ponzi promette un rendimento. Bitcoin non promette nulla, e chi lo detiene non guadagna semplicemente detenendolo. Uno schema Ponzi tiene nascosti i conti. Il registro di Bitcoin può essere letto da chiunque esegua un nodo. Le differenze sono strutturali, ed è il motivo per cui la parola si adatta male, anche se il rischio di prezzo descritto dai critici è reale.

## medium

La definizione di schema Ponzi di Wikipedia è un buon punto di partenza. È una forma di frode che paga profitti apparenti agli investitori precedenti con fondi di investitori più recenti, e di solito promette rendimenti elevati con poco o nessun rischio. Questi schemi crollano quando diventa difficile reclutare nuovi investitori o quando molti investitori chiedono indietro i soldi. La definizione ha tre parti: la frode, un operatore e pagamenti finanziati da denaro nuovo.

Il design di Bitcoin non ha le prime due parti. Il whitepaper descrive un sistema peer-to-peer in cui le transazioni sono verificate dalla rete senza una terza parte fidata. Nessuno raccoglie depositi. I miner ricevono nuove monete e commissioni per proteggere il registro, che sono pagamenti per un lavoro svolto, non rendimenti per investitori.

La terza parte è dove vive l'argomento dei critici. Chi vende ha bisogno di un acquirente, e il prezzo di mercato dipende dalla domanda. Se la domanda dei nuovi acquirenti si fermasse, il prezzo potrebbe scendere molto. Questa dipendenza è reale, ed è il motivo per cui la parola viene usata in senso lato.

Le truffe hanno usato bitcoin, e alcune ne hanno usato il nome. L'articolo di Wikipedia sugli schemi Ponzi osserva che le criptovalute sono state impiegate da truffatori che tentano una nuova generazione di schemi Ponzi, incluso l'uso scorretto delle initial coin offering, e che la maggior parte di questi schemi ha tassi di recupero bassi per gli investitori. Quei casi sono operatori che gestiscono schemi sopra bitcoin, non il protocollo stesso che è uno schema. La distinzione conta, perché una truffa può essere perseguita e un protocollo non può esserlo allo stesso modo.

Le opinioni divergono. L'articolo Bitcoin di Wikipedia riporta che l'economista Nouriel Roubini ha descritto bitcoin come uno schema Ponzi nel 2014, che il giurista Eric Posner ha dissentito perché uno schema Ponzi reale richiede una frode, e che un rapporto della Banca Mondiale del 2014 ha concluso che bitcoin non era uno schema Ponzi deliberato.

## advanced

La versione più forte dell'affermazione non ha bisogno di un operatore. Usa una definizione più larga: una struttura in cui i detentori precoci possono essere pagati solo da acquirenti successivi, e in cui l'asset non genera flussi di cassa propri. Il saggio del 2021 di Jorge Stolfi sostiene che il flusso di denaro di bitcoin è a senso unico, dagli acquirenti ai miner, e che i costi dei miner sono coperti da denaro esterno. Secondo quel saggio, il flusso netto dagli investitori ai miner dal 2009 ammontava a circa 15 miliardi di dollari USA, e il sistema deve continuare ad attrarre denaro nuovo per restare in funzione. Con questa lettura, l'etichetta Ponzi descrive una dipendenza, non una frode.

La risposta ha più parti. Primo, i miner sono pagati per un servizio, cioè proteggere il registro, e questo servizio ha una funzione che i pagamenti di uno schema Ponzi non hanno. Secondo, nessuno ha promesso ai detentori un reddito, e manca quindi la promessa centrale dello schema. Alla tesi di Stolfi sul flusso si risponde che i pagamenti per proteggere una rete sono un costo di gestione, e che ogni sistema con costi ricorrenti ha bisogno di entrate da qualche parte.

L'obiezione seria a questa risposta è che la dipendenza sta nel prezzo, non in un gestore, e che il prezzo può comportarsi come uno schema indipendentemente da chi lo gestisce. La distinzione secondo cui una dipendenza da acquirenti successivi non è la stessa cosa di un pagamento finanziato da acquirenti successivi è corretta, ma non mostra se stiano avvenendo movimenti di prezzo simili a una bolla. Quella domanda è aperta, e questa voce non la risolve.

La parte valida dell'obiezione resta in piedi dopo entrambe le risposte. Truffe e schemi crollati hanno usato bitcoin, e chi acquista in una struttura che promette rendimenti è esposto alla frode di un operatore a prescindere dal protocollo. Il protocollo è cosa diversa dai prodotti di investimento costruiti intorno ad esso. Trattarli come un unico oggetto è dove l'affermazione sbaglia.

L'affermazione diventerebbe vera nel senso che conta se il protocollo avesse un operatore che raccoglie fondi e promette rendimenti pagati con depositi successivi. Diventerebbe vera anche per un singolo prodotto se il suo operatore facesse esattamente questo. È falsa per il protocollo descritto nel whitepaper e nelle sue regole, finché quelle caratteristiche mancano. Se la struttura dei prezzi assomigli a una dinamica Ponzi è una questione separata e aperta.
