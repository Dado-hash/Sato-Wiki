---
id: wiki.dandelion
slug: dandelion
language: it
category: privacy-security
title: Dandelion
description: Una proposta di relay che nasconde quale nodo ha annunciato per primo una transazione, facendola passare prima lungo un breve stelo di peer singoli e poi con la normale diffusione, e perché Bitcoin Core non l'ha adottata.
coverImage: media/wiki/dandelion/dandelion-hero.svg
difficulty: advanced
readTimeMinutes: 5
tags:
  - Dandelion
  - Privacy
  - Rete P2P
  - Relay delle transazioni
related:
  - wiki.peer-to-peer-network
  - wiki.mempool
  - wiki.block-propagation
  - wiki.tor
sources:
  - title: "BIP 156: Dandelion - Privacy Enhancing Routing"
    url: https://github.com/bitcoin/bips/blob/master/bip-0156.mediawiki
    author: Brad Denby, Andrew Miller, Giulia Fanti, Surya Bakshi, Shaileshh Bojja Venkatakrishnan, Pramod Viswanath
  - title: "Dandelion++: Lightweight Cryptocurrency Networking with Formal Anonymity Guarantees"
    url: https://arxiv.org/abs/1805.11060
    author: Giulia Fanti, Shaileshh Bojja Venkatakrishnan, Surya Bakshi, Bradley Denby, Shruti Bhargava, Andrew Miller, Pramod Viswanath
  - title: "Bitcoin Core pull request 13947: review comment on Dandelion stem routing"
    url: https://github.com/bitcoin/bitcoin/pull/13947#issuecomment-513858189
    author: Bitcoin Core contributors
  - title: "Bitcoin Optech Newsletter 426: private broadcast fix"
    url: https://bitcoinops.org/en/newsletters/2026/10/09
    author: Bitcoin Optech
  - title: Bitcoin Core 31.0 release notes
    url: https://bitcoincore.org/en/releases/31.0/
    author: Bitcoin Core contributors
  - title: Transaction origin privacy
    url: https://bitcoinops.org/en/topics/transaction-origin-privacy/
    author: Bitcoin Optech
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

Ogni nodo che riceve una transazione può inoltrarla agli altri peer. Un osservatore che gestisce molti nodi, o che si collega a molti di loro, può vedere quale connessione annuncia per prima una transazione. Il primo nodo a inviare una transazione è spesso quello che l'ha creata. Se si conosce l'indirizzo IP di quel nodo, l'osservatore può collegare la transazione a un luogo o a una persona.

Dandelion è una proposta che rende più difficile questo tipo di deduzione. Invece di annunciare una nuova transazione a tutti i peer nello stesso momento, un nodo la fa prima passare lungo una linea di peer singoli. Questa è la fase dello stelo, o stem. A ogni passo la transazione può uscire dallo stelo ed entrare nella fase di fluff, cioè la normale diffusione a tutti i peer. Poiché il primo annuncio ampio arriva ora da un nodo che potrebbe non aver creato la transazione, quell'annuncio dice meno su dove la transazione sia cominciata.

Dandelion non fa parte di Bitcoin Core. Il BIP 156 descrive l'idea e il suo stato è chiuso. Bitcoin Core non usa una fase di stem. Lo stelo aggiunge anche ritardo, e un peer sul percorso può smettere di inoltrare una transazione. Il livello medium spiega come il protocollo affronta questi problemi, e il livello advanced spiega perché la proposta non è stata integrata.

## medium

Il problema ha un modello chiaro. Supponiamo che un osservatore controlli o osservi molti nodi. Per ogni transazione registra quale nodo l'ha annunciata per primo. La diffusione di Bitcoin fa sì che questo primo annuncio sia vicino all'origine. Il BIP 156 descrive il rischio in questi termini: il protocollo di diffusione delle transazioni può essere attaccato con tecniche di fingerprinting da una botnet, che può collegare le transazioni a indirizzi IP. L'articolo su Dandelion++ di Giulia Fanti e coautori studia un avversario simile: una botnet che controlla una frazione dei nodi e può non rispettare il protocollo.

Lo stem routing risponde a questo problema con un percorso. Nel BIP 156 ogni nodo sceglie due peer in uscita come destinazioni Dandelion e invia le transazioni in stem ricevute da un dato peer in entrata sempre alla stessa destinazione. A ogni salto una moneta sbilanciata fa entrare la transazione nella fase di fluff, con una probabilità di circa il 10 per cento. Dandelion++ usa un'idea simile su un grafo in cui ogni nodo ha circa quattro connessioni, e tratta la probabilità di uscire dallo stelo a ogni salto come un parametro. Lo stelo ha quindi lunghezza casuale, e il nodo che avvia la fase di fluff di solito non è l'origine.

Un relay sullo stelo potrebbe scartare una transazione, per guasto o per malizia. Dandelion affronta il problema con un timer di embargo. Quando un nodo riceve una transazione in stem, avvia un timer. Se la transazione non compare nella mempool prima della scadenza del timer, il nodo la trasmette da sé.

Le garanzie sono limitate. L'articolo su Dandelion++ dichiara che lo schema non ferma gli attacchi mirati. Lascia fuori gli avversari a livello di fornitore di connettività, che possono isolare un nodo e poi aggirare le difese basate sul routing per quel nodo. La sua privacy è probabilistica, non assoluta.

Un nodo senza peer capaci di Dandelion torna al comportamento ordinario, secondo il BIP. Un'adozione parziale è quindi possibile, ma il beneficio dipende dal numero di nodi che partecipano.

## advanced

Bitcoin Core non ha adottato il BIP 156, e le ragioni si vedono nella storia delle sue revisioni. La revisione della pull request 13947 ha sollevato preoccupazioni su denial of service durante lo stem routing. Uno sviluppatore di Bitcoin Core ha scritto che il progetto doveva ancora trovare risposte per le catene di transazioni e per le transazioni di sostituzione, oltre che per il modo di prevenire il denial of service mentre una transazione è nello stelo. Un altro revisore ha osservato che una transazione in stem che dipende da un'altra transazione in stem fallirebbe l'accettazione in mempool, perché il codice non aveva un pool separato per le transazioni in stem.

Un pool separato per lo stelo solleva problemi suoi. Lo stesso revisore non era sicuro di come un pool condiviso tra più peer in entrata potesse evitare di far trapelare informazioni di routing a un avversario, e ha notato che pool separati per ogni peer in entrata aggiungerebbero un sovraccarico significativo. La revisione registra questi punti come questioni aperte. Sono la complessità della mempool che sta dietro la decisione, e l'implementazione di riferimento del BIP è un progetto separato.

Bitcoin Core segue invece una strada diversa per la privacy dell'origine, basata sul trasporto. La versione 31.0, rilasciata nell'aprile 2026, ha aggiunto un'opzione opt-in chiamata -privatebroadcast. Quando è attiva, le transazioni inviate tramite la RPC sendrawtransaction vengono trasmesse solo tramite Tor o I2P. I destinatari non vedono mai l'indirizzo IP dell'originatore, e due transazioni non correlate dello stesso originatore non possono essere collegate attraverso la rete. È la connessione di rete a nascondere la fonte.

La funzione ha limiti propri. Un attaccante che controlla uno dei peer di private broadcast potrebbe dedurre l'origine dal modo in cui si concludono i primi tentativi. Una modifica successiva, descritta nella newsletter Optech 426, fa sì che Bitcoin Core completi tutti e tre i primi tentativi tramite Tor o I2P anche dopo che la transazione ha raggiunto la rete più ampia. Le modifiche successive sono descritte nel topic Optech sulla privacy dell'origine, quindi contano le note della versione esatta. Il rebroadcast fa parte dello stesso problema: ogni nuova trasmissione offre a un osservatore un'altra occasione per identificare l'origine, quindi un wallet che ripete le trasmissioni può indebolire la protezione data dalla prima.

Dandelion e private broadcast affrontano la stessa domanda in punti diversi. Dandelion cambia il percorso della transazione tra i peer, mentre private broadcast cambia la connessione di rete che l'originatore usa per inviarla.
