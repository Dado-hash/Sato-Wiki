---
id: wiki.node-software
slug: node-software
language: it
category: software
subcategory: nodes
title: Software per nodi
description: I programmi che fanno girare un full node, perché esistono più implementazioni indipendenti e come verificare ciò che si installa.
difficulty: base
readTimeMinutes: 5
tags:
  - Full Node
  - Software
  - Consenso
  - Verifica
related:
  - wiki.full-nodes
  - wiki.consensus-rules
  - wiki.forks-and-soft-forks
  - wiki.mempool
  - wiki.server-software
sources:
  - title: Running A Full Node
    url: https://bitcoin.org/en/full-node
    author: Bitcoin.org contributors
  - title: Bitcoin Core downloads
    url: https://bitcoincore.org/en/download/
    author: Bitcoin Core contributors
  - title: Bitcoin Core Guix build documentation
    url: https://github.com/bitcoin/bitcoin/blob/master/contrib/guix/README.md
    author: Bitcoin Core contributors
  - title: Reproducible builds
    url: https://bitcoinops.org/en/topics/reproducible-builds/
    author: Bitcoin Optech
  - title: Bitcoin Knots
    url: https://github.com/bitcoinknots/bitcoin
    author: Bitcoin Knots contributors
  - title: btcd, an alternative full node implementation in Go
    url: https://github.com/btcsuite/btcd
    author: btcsuite contributors
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

Il software per nodi è il programma che fa girare un full node. Un full node controlla ogni blocco e ogni transazione rispetto alle regole di consenso prima di accettarli, poi inoltra i dati validi agli altri nodi. Se ne gestisci uno, non devi fidarti della lista dei pagamenti validi di qualcun altro.

Più programmi possono svolgere questo compito. Ognuno è un'implementazione: codice proprio, scritto per seguire le stesse regole. Bitcoin Core è l'implementazione che usa la maggior parte delle persone. Bitcoin Knots è un derivato di Core. Lo sviluppo avviene in genere in Core e viene riportato in Knots a ogni release, e Knots aggiunge modifiche proprie. btcd è un'implementazione alternativa scritta in Go, quindi non condivide affatto il codice di Core.

Poiché il software decide che cosa accetta il tuo nodo, verifica da dove arriva prima di eseguirlo. Bitcoin Core pubblica checksum e firme per le sue release, e puoi confrontare il file scaricato con questi dati. Anche aggiornare alla release più recente conta, perché le correzioni al codice di validazione arrivano al tuo nodo solo quando le installi.

## medium

Un'implementazione risponde a una sola domanda: come legge questo programma le regole? Le implementazioni serie puntano ad accettare gli stessi blocchi, ma sono scritte da persone diverse, in linguaggi diversi, con percorsi di codice diversi. Nella maggior parte dei casi concordano. Quando non concordano su una regola di consenso, due nodi possono trattare lo stesso blocco in modo diverso e seguire catene diverse. Avere più implementazioni significa che un bug in una di esse non definisce da solo la visione dell'intera rete, ma ognuna va controllata e corretta per conto proprio.

La policy è un livello separato. Le regole di consenso decidono se un blocco è valido. Le impostazioni di policy decidono quali transazioni il nodo conserva nella mempool e inoltra ai peer. Bitcoin.org descrive una modalità blocks-only, in cui il nodo smette di richiedere e inoltrare transazioni sciolte e accetta le transazioni solo quando arrivano dentro un blocco. È una scelta di policy, non un cambio di ciò che è valido. Due nodi con policy diverse possono comunque accettare la stessa chain.

Anche lo storage è una scelta. Un nodo archival conserva l'intera storia dei blocchi e può servire blocchi vecchi ad altri peer. Un nodo pruned scarica e valida comunque la chain, ma elimina i vecchi dati dei blocchi per risparmiare spazio su disco. Il pruning è incompatibile con alcuni indici opzionali, come l'indice delle transazioni che Bitcoin Core costruisce con l'opzione txindex, quindi la scelta influisce su ciò che altro software può fare con il tuo nodo.

L'ultimo passo è la verifica della release. Il processo di build Guix di Bitcoin Core è pensato perché builder indipendenti possano produrre binari identici, e ciascun builder firma un'attestazione degli hash che ha ottenuto. Se confronti il tuo file con queste attestazioni, controlli il binario stesso, non solo il sito che lo offre. Le build riproducibili riducono la necessità di fidarsi di una sola macchina di build.

## advanced

La differenza tra consenso e policy conta soprattutto quando osservi che cosa fa un nodo. Le regole di consenso decidono se un blocco può appartenere alla best chain. La policy decide che cosa un nodo inoltra e conserva prima che un blocco venga minato. Una transazione che un nodo rifiuta per policy può essere comunque valida, e un miner con una policy diversa potrebbe includerla. Per questo un'implementazione può cambiare i suoi default senza creare un fork della rete, mentre una modifica del consenso richiede che abbastanza nodi adottino le nuove regole perché la chain le segua.

Il rischio di compatibilità nasce dal lato del consenso. Le implementazioni possono non concordare su percorsi rari delle regole, come casi insoliti negli script o vecchi blocchi raramente validati. Il disaccordo può restare nascosto finché un blocco non lo fa emergere. Le build riproducibili aiutano: quando persone diverse compilano lo stesso sorgente e ottengono binari identici, possono essere più sicure che il loro nodo applichi lo stesso comportamento del resto della rete. Una build che non si può riprodurre lascia l'utente a fidarsi di chi l'ha pubblicata.

La verifica ha più livelli. Puoi confrontare i checksum pubblicati con il file, controllare le firme sulla lista dei checksum con chiavi di cui ti fidi e, per le build Guix di Core, confrontare le attestazioni di più builder. Ogni livello risponde a una domanda diversa. I checksum mostrano che il file corrisponde a ciò che è stato firmato. Le firme mostrano chi l'ha firmato. Le attestazioni indipendenti mostrano che il binario può essere ricostruito dal sorgente. Nessuno di questi controlli dice che il sorgente è sicuro, ed è per questo che la revisione aperta del codice conta ancora.

Pruning e modalità archival sono un compromesso sulle risorse. Un nodo pruned conserva lo stato necessario per validare i nuovi blocchi, ma non può servire ai peer i blocchi vecchi né supportare strumenti che dipendono dagli indici completi. Un nodo archival richiede molto più spazio su disco, ma può rispondere alle richieste storiche. Entrambi validano dal blocco genesis, quindi la scelta non cambia ciò che accettano, solo ciò che memorizzano e condividono.

Non esiste un'implementazione migliore in assoluto. Il ruolo di validazione è lo stesso in tutte. Ciò che cambia è l'insieme delle funzioni, la policy di default, gli indici, gli strumenti e le pratiche di rilascio. La domanda utile è quale implementazione corrisponde al lavoro che vuoi far fare al nodo, e se puoi verificare il binario che esegui.
