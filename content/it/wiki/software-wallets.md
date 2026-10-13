---
id: wiki.software-wallets
slug: software-wallets
language: it
category: software
subcategory: software-wallets
title: Software wallet
description: I programmi wallet per desktop e mobile, che cosa memorizzano davvero e in che modo le scelte su custodia, server e backup cambiano privacy e rischio.
difficulty: base
readTimeMinutes: 5
tags:
  - Wallet
  - Software
  - Privacy
  - Backup
related:
  - wiki.hd-wallets
  - wiki.wallet-seeds
  - wiki.private-keys
  - wiki.hardware-wallets
  - wiki.full-nodes
sources:
  - title: Developer Guide - Wallets
    url: https://developer.bitcoin.org/devguide/wallets.html
    author: Bitcoin.org contributors
  - title: "BIP 174: Partially Signed Bitcoin Transaction Format"
    url: https://github.com/bitcoin/bips/blob/master/bip-0174.mediawiki
    author: Ava Chow
  - title: Electrum documentation - Frequently Asked Questions
    url: https://electrum.readthedocs.io/en/latest/faq.html
    author: Electrum developers
  - title: Compact block filters
    url: https://bitcoinops.org/en/topics/compact-block-filters/
    author: Bitcoin Optech
  - title: Reproducible builds
    url: https://bitcoinops.org/en/topics/reproducible-builds/
    author: Bitcoin Optech
  - title: Electrum protocol
    url: https://github.com/spesmilo/electrum-protocol
    author: Electrum developers
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

Un software wallet è un programma su computer o telefono che gestisce le chiavi dei tuoi bitcoin. La prima cosa da capire è che un wallet non contiene monete. I bitcoin esistono come output non spesi registrati sulla blockchain. Il wallet conserva le chiavi private che possono firmare la spesa di quegli output, e le usa per costruire e firmare le transazioni.

La maggior parte dei software wallet gira su dispositivi connessi a internet, il che li rende comodi per i pagamenti di tutti i giorni. Alcuni sono non-custodial, quindi solo tu hai le chiavi. Altri sono custodial, cioè una società custodisce le chiavi e tu hai un credito verso di lei. La differenza decide chi può muovere i tuoi fondi e che cosa succede se il fornitore fallisce. Il software non-custodial ti dà il controllo, ma anche la responsabilità: se perdi il seed e il dispositivo, nessuno può ripristinare i fondi al posto tuo.

Tieni il backup del seed offline e privato, e verifica che il wallet possa ripristinarsi da esso prima di affidarti al wallet. Un wallet su telefono o portatile è un hot wallet. Le sue chiavi stanno su un dispositivo online, che le espone più di chiavi tenute su un dispositivo che non si connette mai.

## medium

Un wallet deve sapere quale saldo possiede, e il modo in cui lo fa decide quanto rivela. L'opzione più privata è collegare il wallet al tuo full node, che interroghi direttamente. Molti wallet, invece, si collegano a un server che risponde per loro. Un server in stile Electrum riceve gli indirizzi che interessano al wallet, e può ragionevolmente supporre che appartengano alla stessa persona. La FAQ di Electrum dice che il server è considerato affidabile per le transazioni non confermate e può mentire per omissione, cioè omettere transazioni che ti riguardano. Un server di terze parti costa quindi privacy e un po' di fiducia, anche quando il wallet verifica le transazioni confermate rispetto agli header dei blocchi.

I compact block filter, specificati in BIP 157 e BIP 158, offrono un altro modello. Il wallet scarica un filtro per ogni blocco, lo controlla localmente e richiede solo i blocchi che possono contenere sue transazioni. Rispetto ai server basati sugli indirizzi, questo dà più privacy e richiede meno spazio sul server, ma nel caso normale usa più banda.

I backup sono una questione a parte. Un backup del seed ripristina le chiavi che il wallet deriva da esso. Prima di affidarti a un wallet, prova un ripristino su un secondo dispositivo, e verifica se il programma ha bisogno di qualcos'altro oltre al seed per mostrare tutto il tuo storico.

I wallet possono anche dividere il lavoro. Un wallet watch-only conosce la parte pubblica dei tuoi indirizzi e può seguire il saldo senza alcuna chiave di firma. Un dispositivo di firma, come un hardware wallet o un programma offline, custodisce le chiavi private e firma le transazioni preparate dal wallet watch-only. Le Partially Signed Bitcoin Transaction (PSBT, BIP 174) sono il formato usuale per passare avanti e indietro queste transazioni, perché trasportano le informazioni di firma senza dare al lato online le chiavi.

Il codice open source permette di verificare il binario pubblicato confrontandolo con una build ottenuta dal sorgente.

## advanced

Un software wallet combina tre compiti separabili: decidere quali chiavi pubbliche consegnare, firmare le transazioni e comunicare con la rete peer-to-peer. La guida per sviluppatori di Bitcoin chiama la forma più semplice wallet full-service, che svolge tutti e tre i compiti su un solo dispositivo. Lo svantaggio è che le chiavi private stanno su una macchina connessa a internet, dove una compromissione può farle trapelare. Cifrare il file del wallet protegge le chiavi a riposo, ma non difende da malware che cattura la chiave di cifratura o legge le chiavi decifrate dalla memoria.

Separare i compiti riduce questa esposizione. Un wallet collegato monitora gli output, costruisce transazioni non firmate e trasmette quelle firmate. Un wallet di sola firma, spesso un programma offline o un dispositivo hardware, custodisce la chiave privata master e firma ciò che gli viene mostrato. La guida per sviluppatori osserva che al lato di firma viene spesso data la possibilità di rivedere i dettagli degli output prima di firmare.

La privacy dipende da come il wallet viene a sapere delle proprie transazioni. I metodi light client rivelano cose diverse. I bloom filter, l'approccio più vecchio di BIP 37, fanno sì che il wallet mandi un filtro a un nodo, che confronta le transazioni con quel filtro. Il confronto di Bitcoin Optech dice che i compact block filter danno più privacy contro i nodi spia rispetto ai bloom filter di BIP 37, perché il confronto avviene dal lato del wallet. I server basati sugli indirizzi apprendono direttamente gli indirizzi, e chi riutilizza gli indirizzi offre loro una lunga storia da collegare.

La PSBT è il contenitore comune che collega un wallet collegato ai dispositivi di firma. Il formato è stato progettato perché un firmatario offline possa firmare senza accesso diretto all'insieme UTXO e senza il rischio di essere ingannato sulla transazione. Un firmatario deve inoltre far passare i campi che non riconosce, così strumenti più recenti possono aggiungere dati senza rompere quelli più vecchi.

Anche le build riproducibili si applicano ai wallet. Quando un wallet viene compilato in modo deterministico, più persone possono compilare lo stesso sorgente e ottenere binari identici, quindi un aggiornamento non dipende dalla fiducia in una sola macchina di build. La documentazione di Electrum osserva inoltre che un wallet può essere recuperato interamente dal suo seed, il che rende il seed il backup critico. La sicurezza dipende da come il seed viene generato, conservato e ripristinato, non dalla sola app.
