---
id: wiki.myth-can-be-shut-down
slug: myth-can-be-shut-down
language: it
category: myths
title: '"I governi possono spegnere Bitcoin"'
description: "Parzialmente vero: nessuno Stato può spegnere la rete, ma uno Stato può vietarne o limitarne l'uso entro i propri confini, che è un limite diverso e reale."
difficulty: base
readTimeMinutes: 5
tags:
  - Miti
  - Regolamentazione
  - Full Node
  - Mining
related:
  - wiki.full-nodes
  - wiki.peer-to-peer-network
  - wiki.mining
  - wiki.proof-of-work
  - wiki.myth-miners-control
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: Bitcoin Developer Guide - Operating Modes
    url: https://developer.bitcoin.org/devguide/operating_modes.html
    author: Bitcoin.org contributors
  - title: Cambridge Bitcoin Mining Map
    url: https://ccaf.io/cbnsi/cbeci/mining_map
    author: Cambridge Centre for Alternative Finance
  - title: Bitcoin Mining - New Data Reveal a Surprising Resurgence
    url: https://www.jbs.cam.ac.uk/2022/bitcoin-mining-new-data-reveal-a-surprising-resurgence/
    author: Cambridge Centre for Alternative Finance
    publishedAt: 2022-05-17
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

Parzialmente vero. Nessun governo, azienda o server può spegnere Bitcoin nel suo insieme, ma un governo può vietarne o limitarne l'uso entro i propri confini, e questo limite è reale.

Bitcoin non funziona da un unico luogo. Il suo registro è copiato da molti full node gestiti da persone indipendenti in molti paesi. Ogni nodo controlla da sé le regole, quindi spegnerne uno non ferma gli altri, e una copia che viola le regole viene rifiutata dal resto della rete. Per fermare la rete bisognerebbe spegnere quasi tutti i nodi contemporaneamente, in ogni paese, e nessuna autorità controlla una cosa del genere.

Ciò che un governo può fare è più limitato. Può rendere illegale possedere o minare bitcoin, ordinare a exchange e banche di smettere di servire i propri residenti, oppure tassare pesantemente l'attività. Queste misure rendono difficile comprare, vendere e minare bitcoin per chi si trova in quel paese. Non fermano la rete, e le persone fuori dal divieto continuano a usarla.

Le due cose non coincidono. Fermare la rete e rendere difficile l'uso in un solo luogo sono problemi diversi, e il primo richiederebbe il controllo della maggior parte dei nodi del mondo. Il secondo è facile da fare, ed è già successo.

## medium

Le regole di Bitcoin sono applicate dal software, e ogni full node esegue gli stessi controlli. Un nodo scarica i blocchi a partire dal blocco genesis e li valida da sé, quindi la sua visione del registro non dipende da un singolo operatore. Il whitepaper descrive un sistema in cui la catena più lunga di proof of work fa da registro degli eventi, senza una terza parte fidata.

Il mining è la parte più esposta alle norme nazionali. I miner hanno bisogno di elettricità economica, raffreddamento e hardware specializzato, quindi si concentrano dove l'energia costa poco. Nel giugno 2021 il governo cinese ha inasprito la repressione del mining. Il Cambridge Centre for Alternative Finance (CCAF) riferisce che l'hashrate registrato all'interno della Cina è sceso di fatto a zero nei mesi di luglio e agosto 2021.

I dati di Cambridge mostrano anche dove è finita l'attività. Il dataset, che arriva al gennaio 2022 e viene riportato in un articolo del maggio 2022, attribuisce agli Stati Uniti circa il 37,8 per cento dell'hashrate globale, contro il 35,4 per cento dell'agosto 2021. Nello stesso periodo la capacità installata statunitense è salita da circa 42,7 a circa 71,0 EH/s. L'articolo riporta anche che l'hashrate registrato in Cina è tornato all'improvviso a circa 30,5 EH/s nel settembre 2021: Cambridge lo interpreta come miner che hanno continuato a operare di nascosto, quindi il divieto non ha fermato il mining nemmeno dentro il paese. Questi valori derivano da un campione di dati dei pool e cambiano di mese in mese: descrivono un momento, non una tendenza.

Exchange e banche sono l'altro punto di pressione. Un governo può imporre licenze, congelare conti o ordinare a un servizio regolamentato di smettere di servire i propri residenti. Questi ordini sono applicabili perché le aziende sono locali. Chi custodisce le proprie chiavi è più difficile da raggiungere, ma deve comunque convertire le monete in valuta locale, ed è lì che la regolamentazione di solito interviene.

Il costo di un divieto è quindi reale ma limitato. Fa salire il prezzo di usare bitcoin nel paese e sposta l'attività altrove. Non cambia nessuna regola che i nodi verificano.

## advanced

La versione più forte dell'affermazione è questa. La sicurezza di Bitcoin dipende da alcune grandi operazioni di mining, da una manciata di exchange e da pochi fornitori di wallet dominanti. Ciascuno è un soggetto giuridico con sedi, personale e conti bancari, e gli Stati hanno tribunali, polizia e uffici fiscali. Uno Stato grande che agisce insieme alle proprie banche potrebbe rendere bitcoin inutile per la maggior parte dei suoi residenti, e una rete i cui utenti sono in gran parte fuori dalla portata delle sue stesse regole è una nicchia. Secondo questa lettura, la validazione decentralizzata non protegge chi ha bisogno di entrare e uscire.

Diversi punti sono seri. Il mining si concentra dove l'energia costa poco, e un divieto in un grande paese minerario sposta l'hashrate, a volte con costi in tempo e denaro. Gli exchange sono il principale accesso per i nuovi utenti, e la loro regolamentazione è reale. Uno Stato può usare il sistema bancario per bloccare i trasferimenti in valuta, e allora le strade facili diminuiscono anche se il protocollo resta attivo.

La risposta ha tre parti. Primo, nessun ordine raggiunge il protocollo. Nodi in molte giurisdizioni applicano tutti le stesse regole, e uno Stato non può modificare ciò che un nodo straniero verifica. Secondo, il mining si è spostato invece di sparire dopo il divieto del 2021: i dati di Cambridge mostrano che gli Stati Uniti sono diventati il principale polo di mining nel dataset del gennaio 2022. Terzo, i divieti finora hanno colpito l'accesso e il mining all'interno di un paese, non il protocollo.

Le obiezioni a questa risposta sono altrettanto serie. Le cifre di Cambridge provengono da un campione di impianti dei pool, e la stessa mappa avverte che alcune quote per paese sono probabilmente gonfiate dall'uso di VPN e proxy. Misure rivolte ai maggiori exchange e custodi potrebbero rendere molto più difficile la strada ordinaria anche senza che un nodo si fermi. I dati non mostrano che uno Stato abbia già imposto un blocco, né che non potrebbe farlo.

Perché l'affermazione diventi vera in senso forte, uno Stato o una coalizione dovrebbe controllare abbastanza hashrate da censurare o riordinare i blocchi, oppure impedire che blocchi validi raggiungano la maggior parte dei nodi, oppure tagliare quasi tutte le strade con cui le persone comprano e vendono. Perché sia chiaramente falsa in questo senso, i dati dovrebbero mostrare che hashrate e attività dei nodi non possono calare insieme, anche dopo un'azione coordinata nei maggiori paesi minerari.
