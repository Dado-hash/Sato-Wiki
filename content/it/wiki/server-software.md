---
id: wiki.server-software
slug: server-software
language: it
category: software
subcategory: servers
title: Server e infrastruttura
description: Software che si colloca tra un full node e le app che lo usano, come server del protocollo Electrum, indici degli indirizzi, block explorer e processori di pagamento.
difficulty: base
readTimeMinutes: 5
tags:
  - Server
  - Indici
  - Privacy
  - Infrastruttura
related:
  - wiki.full-nodes
  - wiki.node-software
  - wiki.software-wallets
  - wiki.bitcoin-addresses
  - wiki.utxo-model
sources:
  - title: Running A Full Node
    url: https://bitcoin.org/en/full-node
    author: Bitcoin.org contributors
  - title: electrs, an Electrum Server in Rust
    url: https://github.com/romanz/electrs
    author: electrs contributors
  - title: Fulcrum
    url: https://github.com/cculianu/Fulcrum
    author: Fulcrum contributors
  - title: Electrum protocol
    url: https://github.com/spesmilo/electrum-protocol
    author: Electrum developers
  - title: Compact block filters
    url: https://bitcoinops.org/en/topics/compact-block-filters/
    author: Bitcoin Optech
  - title: BTCPay Server FAQ
    url: https://docs.btcpayserver.org/FAQ/
    author: BTCPay Server contributors
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

Un full node valida Bitcoin per te, ma la maggior parte delle app ha bisogno di risposte che un nodo nudo non fornisce bene. Un wallet vuole sapere ogni transazione che riguarda i suoi indirizzi. Un negozio vuole sapere quando un pagamento raggiunge una certa profondità. Un block explorer vuole mostrare la storia di un indirizzo. Il software server si colloca tra il nodo e queste app, e prepara risposte per cui il nodo non è stato costruito.

Esempi comuni sono i server del protocollo Electrum, gli indicizzatori di indirizzi, i block explorer che ospiti da solo e i processori di pagamento come BTCPay Server. Ognuno prende dati da un nodo, conserva informazioni in più e risponde alle richieste dei propri client. Gestirli da sé mantiene quelle richieste nella tua infrastruttura, invece di inviare i tuoi indirizzi a una terza parte.

Un nodo nudo non ha un indice degli indirizzi. Conserva i blocchi e l'insieme degli output non spesi, sufficienti per validare i nuovi blocchi, ma trovare ogni transazione che tocca un indirizzo richiede un indice che Bitcoin Core non costruisce per default. Costruire o far girare quell'indice occupa spazio su disco, memoria e tempo di elaborazione, ed è un compito separato dalla validazione della chain.

## medium

Il protocollo Electrum è un'interfaccia JSON-RPC che i wallet leggeri usano per parlare con un server. Il server tiene un indice degli indirizzi e della loro storia, così il wallet può chiedere saldi e transazioni senza scaricare la chain. Electrs è una re-implementazione in Rust di questo server. Fulcrum è un server in C++ che parla lo stesso protocollo. I due differiscono per ciò che richiedono al nodo: electrs non richiede che il nodo abbia l'indice delle transazioni, mentre Fulcrum richiede che il nodo giri con txindex attivo e non in modalità pruned.

L'indicizzazione ha costi reali. La prima costruzione legge l'intera chain e può richiedere molto tempo. Dopo, il server ha bisogno di spazio su disco per il suo indice e di memoria e CPU sufficienti a rispondere in fretta. Un server che serve molti wallet ne richiede di più. Questi costi spiegano perché molti usano un server gestito da altri, e perché un server gestito da te richiede manutenzione continua: deve seguire i nuovi blocchi, gestire i reorg ed essere aggiornato insieme al software.

Il vantaggio di privacy dipende da chi vede le interrogazioni. Un wallet che chiede a un server pubblico i propri indirizzi li rivela all'operatore del server. Un wallet che chiede a un server gestito da te li rivela solo a te. La documentazione di Electrum dice che collegarsi a un server sacrifica un po' di privacy, perché il server può ragionevolmente supporre che gli indirizzi appartengano alla stessa entità.

I processori di pagamento come BTCPay Server sono software server per negozi e pagine di donazione. La FAQ di BTCPay include domande sul deployment accanto a un full node Bitcoin già esistente e sull'attivare o disattivare il pruning del nodo, il che mostra che dipende da un nodo e che la configurazione del nodo conta.

I block explorer seguono lo stesso schema. Un explorer self-hosted mostra la storia dei tuoi indirizzi senza inviare la ricerca a un sito esterno, ma richiede un indice e le risorse per tenerlo aggiornato.

## advanced

Il software server cambia il modello di fiducia e di privacy. Un server in stile Electrum apprende quali indirizzi interessano a un wallet, e può vedere tempi e volume delle richieste. Il server può anche mentire per omissione, quindi un wallet che si collega a lui dovrebbe verificare ciò che può. I compact block filter sono un'alternativa che sposta il confronto sul client: il wallet scarica un filtro per ogni blocco e lo controlla localmente, il che dà più privacy e richiede meno spazio e CPU sul server rispetto ai server basati sugli indirizzi, al costo di più banda nel caso normale. Il confronto di Bitcoin Optech è utile quando scegli tra questi modelli.

Il disegno dell'indice è una scelta ingegneristica. Alcuni server si appoggiano all'indice delle transazioni del nodo e richiedono che il nodo sia configurato in un certo modo. Altri costruiscono un database proprio e non richiedono quell'indice. Ogni disegno cambia il percorso di aggiornamento, i passi di ripristino dopo un disastro e le modalità di guasto. Quando il nodo riorganizza la chain, il server deve annullare correttamente il proprio indice, e un server che resta indietro può dare risposte vecchie ai wallet che si fidano di lui.

L'esposizione è un'altra preoccupazione. Un server che accetta connessioni da internet fa parte della tua superficie di attacco. Serve un firewall, autenticazione dove il protocollo la supporta e una regola chiara su quali client possono connettersi. Un block explorer o una pagina di pagamento rende visibile lo stato interno agli utenti, quindi dovrebbe esporre solo ciò che serve mostrare. Far girare questi servizi sulla stessa macchina di un wallet o di un dispositivo di firma mescola livelli di fiducia diversi e va evitato.

Per i processori di pagamento, l'operatore deve gestire chiavi, fatture e contabilità, oltre al nodo sottostante. La FAQ di BTCPay mostra che le domande sul deployment sono frequenti: come collegare il server a un nodo esistente, come gestire la sincronizzazione iniziale e come il pruning influisce su ciò che il server può fare. L'operatore decide quale nodo usare, come conservare i backup e chi ha accesso all'interfaccia di amministrazione.

La pianificazione delle risorse va fatta prima del deployment. Disco, memoria, banda e CPU crescono con la quantità di dati indicizzati e con il numero di client serviti, e cambiano con le release del software. Misura il server durante la sincronizzazione iniziale e durante l'uso normale prima di decidere se gestirlo da te, condividerlo con altri o affidarti a una terza parte.
