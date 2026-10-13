---
id: wiki.myth-anonymous
slug: myth-anonymous
language: it
category: myths
title: '"Bitcoin è anonimo"'
description: Bitcoin è pseudonimo e non anonimo, perché ogni transazione è pubblica e permanente e gli indirizzi possono spesso essere collegati a persone.
coverImage: media/wiki/myth-anonymous/myth-anonymous-hero.svg
difficulty: base
readTimeMinutes: 5
tags:
  - Miti
  - Privacy
  - Pseudonimia
  - Analisi della chain
related:
  - wiki.address-reuse
  - wiki.common-input-ownership
  - wiki.coinjoin
  - wiki.tor
  - wiki.threat-model
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: Protect your privacy
    url: https://bitcoin.org/en/protect-your-privacy
    author: Bitcoin.org contributors
  - title: "A Fistful of Bitcoins: Characterizing Payments Among Men with No Names"
    url: https://cseweb.ucsd.edu/~smeiklejohn/files/imc13.pdf
    author: Sarah Meiklejohn, Marjori Pomarole, Grant Jordan, Kirill Levchenko, Damon McCoy, Geoffrey M. Voelker, Stefan Savage
    publishedAt: 2013-10-23
  - title: "Deanonymisation of clients in Bitcoin P2P network"
    url: https://arxiv.org/abs/1405.7418
    author: Alex Biryukov, Dmitry Khovratovich, Ivan Pustogarov
  - title: CoinJoin - Bitcoin Optech topic
    url: https://bitcoinops.org/en/topics/coinjoin/
    author: Bitcoin Optech
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

Falso così com'è scritto: Bitcoin è pseudonimo, non anonimo. Le transazioni non riportano nomi, ma ogni transazione è pubblica e permanente, e gli indirizzi usati possono spesso essere collegati a persone reali.

Immagina una bacheca pubblica dove tutti firmano con un soprannome. Il soprannome non rivela chi ha scritto un messaggio, ma se lo stesso soprannome pubblica per anni e qualcuno scopre una volta a chi appartiene, tutta la sua storia diventa leggibile. Bitcoin funziona in modo simile. Un indirizzo è una sequenza di caratteri, non un nome, ma resta nel registro per sempre, insieme a importi e orari.

I collegamenti più forti arrivano spesso dall'esterno della chain. Un servizio che verifica i documenti d'identità può associare un account agli indirizzi che usa, e Bitcoin.org ricorda che di solito bisogna rivelare la propria identità per ricevere beni o servizi. Riusare un indirizzo unisce tutti i pagamenti ricevuti. La connessione internet può rivelare da dove parte una transazione, e una pagina che mostra il tuo indirizzo aggiunge un altro pezzo. Ogni pezzo è debole da solo, ma insieme possono identificare una persona.

Gli strumenti di privacy aiutano, ma nessuno rende invisibile un pagamento. Evitare il riuso degli indirizzi, CoinJoin e Tor nascondono ciascuno un tipo di collegamento e ne lasciano scoperti altri.

## medium

Il punto di partenza è la sezione sulla privacy del whitepaper. Nel 2008 Satoshi Nakamoto scrisse che il pubblico può vedere qualcuno inviare un importo a un altro "senza informazioni che colleghino la transazione a qualcuno", e che per ogni transazione andrebbe usata una nuova coppia di chiavi. Questa è la pseudonimia: il progetto tiene i nomi fuori dal registro, ma non garantisce che le transazioni restino scollegate. La stessa sezione osserva che le transazioni con più input "rivelano necessariamente che i loro input appartenevano allo stesso proprietario".

I ricercatori hanno verificato fin dove si arriva. In uno studio del 2013, Meiklejohn e colleghi hanno raggruppato gli indirizzi spesi insieme, poi hanno effettuato acquisti presso diverse attività per capire quali cluster appartenessero a quali operatori. Il loro articolo definisce le identità Bitcoin pseudo-anonime e afferma che tutte le transazioni sono completamente trasparenti.

I dati di rete sono una seconda strada. Nel 2014 Biryukov, Khovratovich e Pustogarov hanno mostrato che alcune macchine collegate alla rete peer-to-peer di Bitcoin potevano associare gli pseudonimi agli indirizzi IP da cui venivano inviate le transazioni, e hanno riportato che l'attacco è stato verificato sperimentalmente. Chi trasmette da una connessione domestica senza protezione lascia a un osservatore un altro indizio.

Bitcoin.org trae la conseguenza pratica: poiché di solito occorre rivelare la propria identità per ricevere beni o servizi, "gli indirizzi Bitcoin non possono restare completamente anonimi". Il sito suggerisce anche Tor, così che l'indirizzo IP del computer non possa essere registrato.

Ogni strumento di privacy agisce su un collegamento. Usare un indirizzo nuovo per ogni pagamento elimina il collegamento da riuso. Tenere separate le monete di fonti diverse limita i collegamenti da input comuni. CoinJoin costruisce una transazione unica con più partecipanti, così che soggetti esterni non possano abbinare facilmente input e output. Tor nasconde da dove si collegano un nodo o un wallet. Ogni strumento ha costi in commissioni, tempo o comodità, e nessuno cancella ciò che il registro pubblico già registra.

## advanced

La versione più forte della tesi è questa. Bitcoin non registra nomi, chiunque può usare un wallet senza mostrare documenti, e la chain non dichiara chi possiede un indirizzo. Un utente attento che non riusa gli indirizzi, evita servizi collegati all'identità e nasconde l'origine della rete può rendere la traccia molto difficile da seguire. Secondo questa lettura, "anonimo" è un'espressione approssimativa per qualcosa che in pratica è difficile da tracciare, e la privacy di un utente attento può essere forte.

La risposta sopra regge su tre obiezioni che chi difende la versione forte deve prendere sul serio. La prima: il clustering è probabilistico e i suoi errori vanno in entrambe le direzioni. Meiklejohn e colleghi hanno scelto euristiche conservative di proposito, accettando di perdere molti collegamenti veri, perché un solo collegamento falso può unire utenti non correlati in un cluster molto grande. I loro risultati sono quindi stime, e il collegamento reale può essere più alto o più basso di quanto mostri qualunque singolo studio. La seconda: i collegamenti più forti spesso stanno fuori dalla chain, nei documenti d'identità presso i servizi, nei dettagli di spedizione e nei post pubblici che rivelano un indirizzo. Un protocollo non può eliminarli, quindi definire anonimo il protocollo descrive solo una parte del sistema. La terza: le contromisure sono imperfette. Optech osserva che CoinJoin funziona in modo efficiente solo con un numero consistente di input di valore simile, e che un output di resto non privato può conservare un collegamento deterministico con il suo input. Tor protegge la posizione di rete, non il contenuto del registro.

Un sostenitore può rispondere che la tesi riguarda il protocollo, che è pubblico, e che i problemi elencati derivano dall'ambiente dell'utente o da una pratica debole. È una delimitazione corretta, ma cambia il significato della parola. Chi ha bisogno di anonimato deve costruirlo attorno al protocollo, e il protocollo non offre un'impostazione predefinita per farlo.

La tesi diventerebbe vera nel senso comune se una versione del protocollo molto usata nascondesse per default il grafo dei pagamenti, cioè importi e collegamenti tra mittenti e destinatari, senza indebolire la validazione né affidarsi a intermediari fidati, e se i punti quotidiani di ingresso e uscita dal sistema smettessero di richiedere l'identità. La tesi sarebbe chiaramente falsa se ogni wallet e ogni servizio comune continuasse a lasciare collegamenti affidabili, come descrive la ricerca citata sopra. Tra questi due estremi, la descrizione accurata è: pseudonimo, con strumenti di privacy forti che gli utenti devono usare correttamente.
