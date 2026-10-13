---
id: wiki.reorganizations
slug: reorganizations
language: it
category: protocol
title: Riorganizzazioni e blocchi stale
description: Come i nodi passano al ramo con più lavoro accumulato quando due blocchi vengono trovati a breve distanza, che cosa succede al blocco perdente e perché le conferme riducono il rischio.
difficulty: base
readTimeMinutes: 5
tags:
  - Riorganizzazione
  - Blocchi stale
  - Fork
  - Conferme
related:
  - wiki.blockchain
  - wiki.blocks
  - wiki.block-propagation
  - wiki.proof-of-work
  - wiki.coinbase-transaction
sources:
  - title: Bitcoin Developer Guide - Block Chain
    url: https://developer.bitcoin.org/devguide/block_chain.html
    author: Bitcoin.org contributors
  - title: Bitcoin Core consensus parameters
    url: https://github.com/bitcoin/bitcoin/blob/master/src/consensus/consensus.h
    author: Bitcoin Core contributors
  - title: Bitcoin Core validation implementation
    url: https://github.com/bitcoin/bitcoin/blob/master/src/validation.cpp
    author: Bitcoin Core contributors
  - title: "BIP 50: March 2013 Chain Fork Post-Mortem"
    url: https://github.com/bitcoin/bips/blob/master/bip-0050.mediawiki
    author: Gavin Andresen
    publishedAt: 2013-03-20
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

A volte due miner trovano blocchi validi quasi nello stesso momento, ed entrambi estendono lo stesso blocco precedente. La rete ha ora un fork con due punte concorrenti alla stessa altezza. I nodi non tengono entrambe per sempre. Ogni nodo segue il ramo che ritiene migliore, cioè quello con più proof of work accumulato. Quando il blocco successivo viene trovato sopra uno dei due rami, quel ramo diventa più forte e l'altro viene abbandonato.

Il blocco perdente si chiama stale. Era valido, ma non fa più parte della chain migliore. Le sue transazioni non vanno semplicemente perse. Quando un nodo cambia ramo, rimuove il blocco stale e prova a rimettere le sue transazioni nella mempool. Una transazione ancora valida, che non è in conflitto con il ramo vincente, può essere inclusa in un blocco successivo. Una transazione che il ramo vincente ha già speso in modo diverso viene scartata. La transazione coinbase del blocco stale non torna in circolo, perché paga una ricompensa che esiste solo sul ramo a cui appartiene.

Le conferme riducono il rischio di una riorganizzazione. Un pagamento sepolto sotto più blocchi richiederebbe un ramo alternativo più lungo per essere sostituito. Anche gli output coinbase non possono essere spesi finché non sono passati 100 blocchi dalla loro creazione. Questa regola impedisce a un miner di spendere una ricompensa che una riorganizzazione breve potrebbe eliminare.

## medium

Quando un nodo riceve un blocco che estende un ramo con più lavoro della propria punta attuale, disconnette i blocchi fino al punto in cui i rami si separano, e poi connette il nuovo ramo. I blocchi trovati in simultanea sono normali, quindi i cambi di ramo avvengono regolarmente. La guida per sviluppatori osserva che, quando arrivano due blocchi insieme, i nodi di solito usano il primo che vedono, e cambiano solo quando un ramo concorrente diventa più forte.

La guida per sviluppatori descrive la regola come seguire la chain più difficile. Significa la chain con più proof of work accumulato, non quella con più blocchi. Il whitepaper di Satoshi Nakamoto descriveva la stessa idea come la chain più lunga, quella che rappresenta la più grande riserva di potenza CPU. Il lavoro è la misura, quindi un ramo con meno blocchi può comunque vincere se i suoi blocchi erano più difficili da trovare.

Blocchi stale e blocchi orfani sono cose diverse. Un blocco stale è valido e ha fatto parte di un fork, ma un blocco successivo ha scelto l'altro lato. La guida per sviluppatori osserva che il termine orfano viene usato sia per i blocchi stale sia per i veri blocchi orfani, cioè blocchi il cui genitore il nodo non ha mai visto. Un nodo conserva un vero orfano finché non arriva il genitore, perché non può collegarlo a una chain che conosce.

La velocità di propagazione dei blocchi incide sulla frequenza dei fork. La propagazione dei blocchi spiega come avviene il relay in pratica.

Le riorganizzazioni sono normali sulla punta della chain e diventano meno probabili man mano che si accumulano blocchi. Una transazione confermata non ha una finalità garantita, ma ogni nuovo blocco sopra di essa rende più costosa la sostituzione. Un pagamento con un solo blocco sopra è più esposto di uno con molti blocchi sopra, ed è per questo che i commercianti scelgono il numero di conferme in base al valore che sono disposti a rischiare.

## advanced

Il whitepaper fornisce un modello di probabilità per un attaccante che prova a superare la chain onesta. Presume che i blocchi onesti arrivino più velocemente di quelli dell'attaccante, e tratta il progresso dell'attaccante come un processo di Poisson. In questo modello, la probabilità che l'attaccante riesca mai a raggiungere la chain onesta cala in modo esponenziale con il crescere dei blocchi che li separano. Il modello spiega il ragionamento dietro il numero di conferme, ma non fissa un valore unico, perché dipende dal valore a rischio e dalle risorse dell'attaccante.

La gestione delle riorganizzazioni in Bitcoin Core è una sequenza di passaggi di disconnessione e connessione. Quando i blocchi vengono disconnessi, le loro transazioni finiscono in un pool che viene riversato nella mempool nell'ordine originale, a partire dalla transazione più antica tra quelle confermate. Le transazioni coinbase non vengono riaggiunte. Se una transazione non supera la validazione sul nuovo ramo, viene rimossa insieme alle transazioni che ne dipendevano, perché in mempool diventerebbero orfane.

La regola dei 100 blocchi per gli output coinbase è una regola di consenso definita nei parametri di consenso di Bitcoin Core. Il suo scopo è impedire a un miner di spendere una ricompensa di blocco prima che una riorganizzazione breve possa eliminare il blocco che l'ha creata. La regola limita i danni delle riorganizzazioni brevi, ma non impedisce quelle lunghe.

Riorganizzazioni profonde sono avvenute, e di solito sono state causate da differenze tra versioni del software più che da un attacco deliberato. Il BIP 50, il post-mortem del marzo 2013, descrive un fork iniziato quando un blocco con un numero maggiore di input nelle transazioni è stato accettato dai nodi Bitcoin 0.8 ma rifiutato da quelli più vecchi. La chain 0.8 aveva circa il 60 percento dell'hash power di mining in quel momento, ma i pool che minavano su di essa hanno retrocesso i propri nodi alla versione 0.7 per rifiutare il blocco. La maggioranza è passata quindi alla chain più vecchia, e i nodi 0.8 si sono riorganizzati su di essa. La causa era un limite sui lock del database nel software più vecchio, diventato una regola di consenso non voluta. Il BIP 50 registra anche un grande double spend avvenuto durante la riorganizzazione, compiuto da qualcuno che stava verificando se fosse possibile.

Le riorganizzazioni sono quindi una proprietà dell'intera rete: nodi con le stesse regole possono stare per un po' su rami diversi.
