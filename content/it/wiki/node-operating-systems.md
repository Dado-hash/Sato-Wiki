---
id: wiki.node-operating-systems
slug: node-operating-systems
language: it
category: software
subcategory: node-systems
title: Sistemi per nodo domestico
description: Sistemi operativi e piattaforme di app preconfigurati che installano un nodo Bitcoin e servizi collegati su un piccolo computer, e cosa aggiungono al software del nodo.
coverImage: media/wiki/node-operating-systems/node-operating-systems-hero.svg
difficulty: base
readTimeMinutes: 5
tags:
  - Nodo domestico
  - Full Node
  - Self-hosting
  - Software preconfigurato
  - Backup
related:
  - wiki.full-nodes
  - wiki.node-software
  - wiki.node-hardware
  - wiki.lightning-software
  - wiki.seed-backups
sources:
  - title: umbrel - umbrelOS repository README
    url: https://github.com/getumbrel/umbrel
    author: Umbrel
  - title: umbrel-apps - Umbrel App Store packages
    url: https://github.com/getumbrel/umbrel-apps
    author: Umbrel
  - title: start-technologies - Start9 monorepo README
    url: https://github.com/Start9Labs/start-technologies
    author: Start9 Labs
  - title: StartOS documentation - Tor
    url: https://github.com/Start9Labs/start-technologies/blob/master/projects/start-os/docs/src/tor.md
    author: Start9 Labs
  - title: StartOS documentation - Creating Backups
    url: https://github.com/Start9Labs/start-technologies/blob/master/projects/start-os/docs/src/backup-create.md
    author: Start9 Labs
  - title: StartOS documentation - Updating
    url: https://github.com/Start9Labs/start-technologies/blob/master/projects/start-os/docs/src/updating.md
    author: Start9 Labs
updatedAt: 2026-10-13T00:00:00Z
reviewedAt: 2026-10-13
---

## base

Un sistema per nodo domestico è un sistema operativo o una piattaforma di app preconfigurata che installa un nodo Bitcoin su un piccolo computer e lo gestisce al posto tuo. Invece di configurare a mano ogni programma, installi un'immagine, completi una schermata di setup e aggiungi applicazioni da un catalogo integrato. Umbrel, StartOS e RaspiBlitz sono esempi di questo tipo di prodotto.

Il pacchetto include di solito il full node stesso, insieme ai servizi che spesso si usano accanto: un server Electrum perché i wallet possano interrogare la chain, un nodo Lightning e un app store da cui aggiungere o rimuovere altri programmi. La comodità è reale, perché aggiornamenti, dashboard e installazione dei servizi vengono gestiti per te.

Questa comodità ha un costo. Ora ti fidi del packager, del suo app store e del suo processo di aggiornamento, non solo del software Bitcoin. Un'app di terze parti nello store gira sulla stessa macchina del tuo nodo. Il nodo continua a verificare da sé i dati della chain, ma il sistema che lo circonda decide cos'altro viene eseguito e quando cambia.

Poi c'è l'accesso remoto. Molti sistemi permettono di raggiungere la dashboard da fuori casa. In StartOS, Tor è una delle opzioni e non richiede alcuna configurazione del router. Qualunque sistema tu scelga, i backup restano compito tuo.

## medium

Quasi tutti questi sistemi sono costruiti attorno a pochi componenti. Il nodo esegue Bitcoin Core o un'altra implementazione di full node. I server compatibili con Electrum permettono ai wallet di leggere saldi e storico senza scaricare la chain. Un nodo Lightning aggiunge la gestione dei canali, e l'app store installa software opzionale da un catalogo. I pacchetti dell'App Store di Umbrel includono Bitcoin, Core Lightning e diverse implementazioni di server Electrum.

Ogni sistema ha il proprio modello di aggiornamento. umbrelOS offre un programma beta a cui l'utente aderisce nelle impostazioni. StartOS mostra per ogni registry gli aggiornamenti in attesa, elenca le note di rilascio e aspetta che tu clicchi Update. In entrambi i casi il percorso di aggiornamento fa parte della decisione di fiducia, perché un aggiornamento difettoso arriva al tuo nodo esattamente come uno buono.

L'accesso remoto è il punto in cui molte configurazioni differiscono. Tor ti dà un indirizzo .onion che funziona senza aprire porte sul router, ma StartOS non include Tor di default, quindi va prima installato come servizio. Le connessioni Tor sono più lente e a volte poco affidabili, come la documentazione StartOS dichiara apertamente. Una VPN o un dominio pubblico sono altre strade, con più configurazione di router e DNS.

I backup sono la parte che resta tua. StartOS cifra i backup con la master password e li scrive su un disco collegato o su una cartella di rete. Esclude la blockchain perché un nodo può ricostruirla risincronizzando. La documentazione avverte che senza backup, prima o poi, perderai dati. Tieni i backup del seed del wallet come passaggio separato, come descritto nella voce sui seed di backup, e non condividere mai una seed phrase con app o servizi.

Le licenze cambiano da progetto a progetto. Il README di umbrelOS indica la licenza PolyForm Noncommercial 1.0.0, che consente uso personale e nonprofit e chiede ai soggetti commerciali di contattare l'azienda. Il monorepo di Start9 è sotto licenza MIT. Leggi la licenza del sistema esatto che vuoi usare prima di costruirci un'attività.

## advanced

Un sistema per nodo domestico trasforma un singolo full node in una piccola piattaforma con una propria filiera di software. Lo strato di base è ancora la validazione di Bitcoin Core, che non cambia per effetto del pacchetto. Il rischio sta sopra: l'immagine che installi, i pacchetti dello store, il codice che parla con il nodo via RPC e il canale di aggiornamento. Ogni servizio aggiunto aumenta la quantità di software che può raggiungere il nodo e i dati del wallet.

I modelli di pacchettizzazione differiscono nel modo in cui limitano questa esposizione. StartOS dichiara che i servizi girano in container LXC isolati e che i pacchetti usano un formato firmato e con archivio Merkle, che supporta la verifica crittografica. Questo non rende sicuro un pacchetto difettoso, ma offre al sistema operativo un modo per verificare ciò che installa. Uno store gestito dal progetto e pacchetti aggiunti dalla comunità comportano assunzioni di revisione e fiducia diverse, e l'utente dovrebbe capire da quale dei due sta installando.

L'esposizione di rete è la seconda area. Un nodo che accetta peer in ingresso sulla linea di casa espone già una superficie. Aggiungere una dashboard web, un endpoint Electrum pubblico o un dominio clearnet ne aggiunge altra. I servizi onion spostano parte di quell'esposizione su Tor, ma richiedono comunque che password della dashboard e software del server restino protetti. Anche impostazioni predefinite e servizi già attivi fanno parte della stessa superficie, quindi verificali dopo l'installazione invece di dare per scontato che siano minimi.

Il ripristino è l'ultima area da pianificare. Un sistema pacchettizzato ripristina i suoi servizi dal proprio formato di backup, e quel formato è utile solo se riesci a raggiungere il backup in seguito. La documentazione StartOS osserva che i servizi possono escludere alcuni file o cartelle dal backup, quindi controlla cosa salva davvero ciascun servizio. Prova il ripristino su un disco di riserva prima di farvi affidamento, e tieni i backup del seed del wallet come passaggio separato.

La scelta tra questi sistemi dipende da cosa ti serve. Alcune persone vogliono un unico apparecchio con un ampio catalogo di app, altre un nodo minimo con meno componenti in movimento. Il compromesso è tra comodità, numero di componenti di cui ti fidi e quanta manutenzione sei disposto a fare tu.
