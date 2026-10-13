---
id: wiki.node-hardware
slug: node-hardware
language: it
category: hardware
subcategory: node-hardware
title: Hardware per nodi
description: Di cosa ha bisogno un computer per far girare un full node Bitcoin, tra storage, memoria, banda, alimentazione e tipi di hardware.
difficulty: base
readTimeMinutes: 5
tags:
  - Full Node
  - Storage
  - Hardware
  - Uptime
  - Pruning
related:
  - wiki.full-nodes
  - wiki.node-software
  - wiki.node-operating-systems
  - wiki.utxo-model
  - wiki.peer-to-peer-network
sources:
  - title: Bitcoin.org - Eseguire un full node
    url: https://bitcoin.org/en/full-node
    author: Bitcoin.org contributors
  - title: Bitcoin Core - Ridurre l'uso della banda
    url: https://github.com/bitcoin/bitcoin/blob/master/doc/reduce-traffic.md
    author: Bitcoin Core contributors
  - title: Bitcoin Developer Guide - Operating Modes
    url: https://developer.bitcoin.org/devguide/operating_modes.html
    author: Bitcoin.org contributors
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

Un full node richiede un computer capace di stare al passo con la blockchain e di controllare ogni blocco che riceve. Il lavoro più pesante avviene durante la prima sincronizzazione, quando il nodo scarica tutta la storia e la verifica. Dopo, il nodo ha soprattutto bisogno di storage affidabile, di una connessione di rete stabile e di uptime sufficiente per restare allineato alla rete.

Lo storage è la prima preoccupazione. Il nodo conserva i dati dei blocchi e un database degli output non spesi. Entrambi crescono nel tempo. Un nodo che conserva tutta la storia richiede molto spazio, mentre un nodo pruned elimina i vecchi file di blocco e ne usa meno. La chain continua a crescere, quindi controlla la documentazione del software del nodo per i dati aggiornati, invece di fidarti di un numero trovato in una guida. Conta anche la velocità del disco. Bitcoin.org fissa una velocità minima di lettura e scrittura per lo storage, perché un disco lento allunga molto la prima sincronizzazione.

Memoria e processore contano per la prima sincronizzazione, perché ogni blocco viene verificato e il processore resta impegnato per tutto il download. La banda conta perché il nodo invia e riceve dati in continuazione. L'uptime conta perché un nodo spento non può inoltrare blocchi e deve recuperare il ritardo quando torna online.

## medium

Diversi tipi di macchina possono far girare un nodo. Un single-board computer, come una piccola scheda Linux, consuma poca energia e sta in un armadio, ma memoria e opzioni di storage sono limitate, e alcune schede usano una scheda SD per lo storage. Un mini PC ha un processore più veloce, più memoria e spazio per un disco interno, a fronte di un costo e di un consumo maggiori. Un vecchio laptop o un desktop è spesso un buon punto di partenza. Può avere già abbastanza memoria e un disco, ma richiede un'alimentazione stabile e può andare in sospensione o rallentare per il calore senza preavviso.

Le scelte di storage seguono la decisione sul pruning. Un nodo archival conserva tutti i dati dei blocchi e può servire blocchi storici ai peer. Un nodo pruned valida comunque tutta la chain e mantiene lo stato corrente, ma elimina i vecchi file di blocco. Il pruning riduce l'uso del disco e permette comunque al nodo di far rispettare le regole. Non conserva i vecchi blocchi, quindi il nodo non può servirli ad altri peer.

La banda è un elemento da pianificare. Il nodo invia e riceve blocchi e transazioni ogni giorno. La documentazione di Bitcoin Core segnala che le impostazioni predefinite possono consumare molto traffico, soprattutto per servire blocchi storici durante la prima sincronizzazione, e offre un limite di upload che lo contiene. Prima di scegliere un'impostazione, controlla il tuo piano dati e se la connessione è a consumo.

Alimentazione e uptime vengono dopo. Il nodo è più utile quando funziona in continuo. Bitcoin.org consiglia di tenerlo acceso per gran parte della giornata, idealmente sempre, e di disattivare sospensione e stand-by. Una batteria di backup protegge da brevi interruzioni. Le schede SD tollerano meno cicli di scrittura della maggior parte dei dischi, quindi usarne una per un nodo è una scelta consapevole che richiede monitoraggio.

I box pronti per nodi sono una categoria di dispositivi già assemblati che unisce hardware e software del nodo. Fanno risparmiare tempo di configurazione.

## advanced

Il carico hardware di un nodo deriva soprattutto dall'initial block download e dal chainstate. Durante il download, il nodo richiede i blocchi storici, verifica ciascuno e scrive i risultati nel database. La verifica usa molto il processore, e il database esegue molte letture e scritture piccole. Un nodo che sincronizza su un disco lento può impiegare molto più tempo di uno su un disco veloce, quindi il minimo indicato su bitcoin.org va letto come soglia minima e non come obiettivo.

Il chainstate è l'insieme degli output non spesi che il nodo usa per validare i nuovi blocchi. La sua dimensione è separata dallo storico dei blocchi, e il pruning elimina i file dei blocchi mantenendo questo stato. Poiché lo stato viene aggiornato per ogni blocco collegato, lo storage deve reggere un flusso costante di piccole scritture, non solo trasferimenti grandi e sequenziali. Dischi progettati per un uso continuo sono in genere una scelta più sicura rispetto a schede pensate per scritture occasionali.

Bitcoin Core espone diverse impostazioni che influenzano le risorse usate: pruning, numero di connessioni peer, limite di upload e numero di thread per la verifica delle firme. I limiti di connessione predefiniti permettono un numero elevato di peer, utile alla rete ma che aumenta il traffico. Il limite di upload interrompe il servizio dei blocchi storici quando si raggiunge un budget giornaliero. Questo protegge una connessione limitata, ma un nodo che non serve i blocchi vecchi è meno utile ai nuovi nodi che ne hanno bisogno. Il proprietario dovrebbe impostare questi valori in modo deliberato.

L'affidabilità è anch'essa un tema hardware. Una caduta di corrente durante una scrittura nel database può danneggiare i dati, quindi una batteria di backup o un file system con journaling riducono il rischio. Le macchine piccole possono rallentare quando si surriscaldano, e un nodo rallentato può restare indietro. L'accesso remoto richiede attenzione: se il nodo è raggiungibile dall'esterno, la sua interfaccia di gestione va protetta e tenuta aggiornata.

La scelta dell'hardware non cambia ciò che il nodo valida. Le stesse regole valgono su un single-board computer, un mini PC o un server. Un hardware migliore cambia soprattutto quanto dura la prima sincronizzazione, quanto traffico ed energia consuma il nodo e quante altre attività può eseguire insieme al software Bitcoin.
