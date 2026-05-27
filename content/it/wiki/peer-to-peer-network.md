---
id: wiki.peer-to-peer-network
slug: peer-to-peer-network
language: it
category: protocol
title: Rete Peer-to-Peer
description: I nodi Bitcoin formano una rete a maglia senza permessi dove ogni partecipante si connette direttamente agli altri, scopre peer e scambia blocchi e transazioni senza un server centrale.
coverImage: media/wiki/peer-to-peer-network/p2p-hero.svg
difficulty: base
readTimeMinutes: 10
tags:
  - Rete P2P
  - Scoperta Nodi
  - Relay
  - Protocollo di Rete
related:
  - wiki.full-nodes
  - wiki.blocks
  - wiki.mempool
  - wiki.consensus-rules
sources:
  - title: Bitcoin Developer Guide - P2P Network
    url: https://developer.bitcoin.org/devguide/p2p_network.html
    author: Bitcoin.org contributors
  - title: Bitcoin Core - net_processing.cpp
    url: https://github.com/bitcoin/bitcoin/blob/master/src/net_processing.cpp
    author: Bitcoin Core contributors
  - title: BIP-324 — Version 2 P2P Transport
    url: https://github.com/bitcoin/bips/blob/master/bip-0324.mediawiki
    author: Pieter Wuille, Matt Corallo, Jonas Schnelli, et al.
  - title: BIP-330 — Erlay
    url: https://github.com/bitcoin/bips/blob/master/bip-0330.mediawiki
    author: Gleb Naumenko, Gregory Maxwell
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
updatedAt: 2026-05-27T00:00:00Z
---

## base

I nodi Bitcoin si connettono tra loro in una rete peer-to-peer. Non esiste un server centrale, nessun singolo punto di controllo. Ogni nodo scopre altri nodi, stabilisce connessioni e scambia blocchi e transazioni. I nodi possono unirsi e andarsene liberamente, e la rete si adatta.

Questo design è senza permessi: qualsiasi nodo può connettersi a qualsiasi altro nodo che accetta connessioni in entrata. Nessuno ha bisogno di approvazione. La rete tratta tutti i partecipanti come uguali — non esiste un livello di relay o routing privilegiato.

Quando un nuovo nodo si avvia, deve trovare altri nodi. Usa uno o più meccanismi di seed: DNS seeders (nomi di dominio hardcodati che risolvono in indirizzi di nodi affidabili), seed node hardcodati in Bitcoin Core o — storicamente — il canale IRC di bootstrap. Una volta connesso, il nodo apprende più indirizzi dai suoi peer tramite messaggi addr e può costruire la propria mappa della rete.

Un nodo mantiene tipicamente da 8 a 12 connessioni in uscita e accetta fino a 125 connessioni in entrata. Il numero di connessioni in uscita è volutamente basso per ridurre la larghezza di banda mantenendo il nodo connesso a diverse parti della rete.

## medium

### Scoperta dei nodi

Un nuovo nodo Bitcoin parte con una breve lista di seed node hardcodati e diversi nomi di DNS seed. I DNS seed sono nomi di dominio mantenuti da volontari o organizzazioni. Quando interrogati, restituiscono un insieme rotante di indirizzi IP di nodi raggiungibili. Il nodo si connette ad alcuni di essi, esegue l'handshake version e poi riceve messaggi addr contenenti più indirizzi.

Storicamente, Bitcoin usava un canale IRC di bootstrap come metodo aggiuntivo di scoperta. I nodi si univano a un canale specifico e ricevevano una lista dei partecipanti. Il bootstrap IRC è stato rimosso nelle versioni successive.

Dopo la scoperta iniziale, il nodo mantiene un address manager con due tabelle principali: tried e new. La tabella tried memorizza indirizzi a cui il nodo si è connesso con successo in passato. La tabella new memorizza indirizzi appresi dai peer ma non ancora testati. Ogni tabella contiene multipli bucket per impedire a un singolo peer di inondare lo spazio degli indirizzi.

### Handshake di connessione

Quando il nodo A vuole connettersi al nodo B tramite TCP (porta 8333 di default), invia un messaggio version contenente la versione del protocollo, timestamp, altezza del blocco migliore, preferenza di relay e un nonce casuale. Il nodo B risponde con il proprio messaggio version e subito dopo invia un verack (conferma di versione). Il nodo A invia il proprio verack in risposta. Una volta che entrambi i nodi hanno scambiato version e verack, la connessione è stabilita e possono iniziare a scambiare messaggi di inventario.

Dopo l'handshake, i nodi possono scambiare messaggi sendheaders o sendcmpct per negoziare le preferenze di relay dei blocchi. Un nodo può anche inviare un messaggio feefilter per chiedere al peer di non inoltrare transazioni al di sotto di una certa commissione.

### Preferenze di relay

I nodi Bitcoin Core possono segnalare se preferiscono ricevere nuovi blocchi come annunci di header (sendheaders) o come blocchi compatti (sendcmpct). I blocchi compatti riducono la larghezza di banda inviando solo le transazioni che il ricevente potrebbe già avere nella sua mempool, più identificatori brevi per quelle sconosciute. Questa ottimizzazione è stata introdotta in Bitcoin Core 0.13.0 con BIP-152.

### Limiti di entrata e uscita

Un nodo Bitcoin Core di default apre 8 connessioni in uscita e le divide in categorie: full-relay, block-relay-only (nessun relay di transazioni) e feeler connection (sonde di breve durata per testare indirizzi). Accetta fino a 125 connessioni in entrata. Ogni connessione in entrata consuma un socket e un po' di memoria, ma il collo di bottiglia principale è il lavoro di elaborazione per inoltrare transazioni e blocchi.

### Feeler

Le feeler connection sono connessioni in uscita di breve durata (circa 100 secondi) che verificano se un indirizzo dalla tabella new è effettivamente raggiungibile. Testano un indirizzo alla volta e si disconnettono rapidamente. Se l'indirizzo risponde correttamente, viene spostato nella tabella tried. Questo impedisce alla tabella tried di riempirsi con indirizzi non raggiungibili.

### Privacy e trasporto

Bitcoin Core supporta Tor (servizi onion v2 e v3), I2P e CJDNS per la privacy dei trasporti. Gli indirizzi onion e I2P sono auto-autenticanti — l'indirizzo stesso codifica il punto di rendezvous e la chiave pubblica della destinazione. CJDNS fornisce una mesh IPv6 crittografata. I nodi possono connettersi tramite clearnet, Tor, I2P o qualsiasi combinazione. Bitcoin Core isola le connessioni per tipo di rete per prevenire il collegamento di attività attraverso trasporti diversi.

I client leggeri (portafogli SPV) non inoltrano blocchi o transazioni. Si connettono a nodi in ascolto, richiedono transazioni rilevanti e si affidano al nodo per la connettività. Non contribuiscono alla propagazione della rete e non sono conteggiati come parte della maglia peer-to-peer allo stesso modo dei full node.

## advanced

### Formato del protocollo wire

Ogni messaggio P2P Bitcoin sulla rete (prima del trasporto v2 BIP-324) inizia con un header fisso:

| Campo | Dimensione | Descrizione |
|-------|------------|-------------|
| Magic | 4 byte | Identificatore di rete (0xD9B4BEF9 per mainnet) |
| Command | 12 byte | Nome del comando ASCII, riempito con byte nulli |
| Payload length | 4 byte | Intero senza segno little-endian |
| Checksum | 4 byte | Primi 4 byte del doppio SHA-256 del payload |
| Payload | Variabile | Dati specifici del comando |

L'header del messaggio è di 24 byte. Il payload viene interpretato secondo il campo command. I comandi includono: version, verack, addr, inv (inventario), getdata, tx, block, headers, getheaders, ping, pong, sendheaders, sendcmpct, feefilter, getaddr, mempool, reject, filterload, filteradd, filterclear (BIP-37) e altri.

### BIP-324: Trasporto P2P versione 2

BIP-324 introduce la crittografia opportunistica per le connessioni P2P di Bitcoin. Il livello di trasporto aggiunge un handshake versione 1 (usato per retrocompatibilità) e un handshake crittografato versione 2 basato sul framework del protocollo Noise. Una volta stabilita, la connessione è crittografata e autenticata. Il trasporto v2 impedisce la sorveglianza passiva del relay di transazioni e blocchi e rende più difficile per gli osservatori di rete identificare quale nodo ha inviato quale messaggio. Bitcoin Core supporta completamente il trasporto v2 dalla versione 26.0.

### Address manager: tried e new

L'address manager di Bitcoin Core (CAddrMan) organizza gli indirizzi dei peer conosciuti in due gruppi:

- **Tabella tried**: Fino a 64 bucket con 64 voci ciascuno (4096 indirizzi totali). Qui vengono memorizzati solo indirizzi a cui il nodo si è connesso con successo e ha completato un handshake.
- **Tabella new**: Fino a 256 bucket con 64 voci ciascuno (16384 indirizzi totali). Qui vanno gli indirizzi appresi dai peer ma non ancora testati.

Quando arriva un nuovo indirizzo, il nodo seleziona un bucket deterministicamente in base all'indirizzo sorgente e al gruppo di rete dell'indirizzo stesso. Questo garantisce che un singolo peer ostile non possa riempire l'address manager con le proprie voci. Quando un bucket è pieno, il nodo applica una politica di rimozione randomizzata pesata per tempo dell'ultima connessione e tasso di successo.

Il design a due tabelle è un meccanismo anti-DoS. Senza di esso, un attaccante potrebbe inondare un nodo con indirizzi falsi, isolandolo dalla rete o sprecando i suoi tentativi di connessione.

### Rimozione connessioni in entrata

Bitcoin Core ha un massimo fisso per le connessioni in entrata. Quando arriva una nuova connessione in entrata e il limite è stato raggiunto, il nodo seleziona un candidato per la rimozione in base a: versione più bassa, tempo di inattività più lungo, nessun indirizzo conosciuto, ping più basso o minore diversità di gruppo di indirizzi. L'algoritmo di rimozione cerca di proteggere un insieme diversificato di peer ed evita di disconnettere nodi con buon comportamento.

### Feeler connection

Le feeler connection sono connessioni in uscita aperte specificamente per testare un indirizzo dalla tabella new. Durano circa 100 secondi. Se il peer remoto risponde e completa un handshake version, l'indirizzo viene promosso alla tabella tried. Altrimenti, l'indirizzo rimane nella tabella new o viene scartato. Bitcoin Core apre al massimo una feeler connection ogni 90 secondi per evitare scansioni aggressive.

### Misure anti-DoS

Bitcoin Core limita la velocità di elaborazione dei messaggi per peer:

- **Controllo flood inv/addr**: Un peer che invia troppi messaggi di inventario o indirizzi viene penalizzato e infine disconnesso.
- **Controlli versione**: Se la versione del protocollo pubblicizzata da un peer è troppo bassa, la connessione viene rifiutata.
- **Comportamento temporale**: Un peer il cui timestamp sul messaggio version è troppo lontano dal tempo del nodo viene trattato con sospetto.
- **Punteggi di ban**: I peer con comportamento scorretto accumulano un punteggio. Quando il punteggio supera una soglia, il peer viene bannato per un periodo configurabile.
- **Resistenza DoS sul relay addr**: La struttura a bucket dell'address manager impedisce a un singolo peer malintenzionato di iniettare indirizzi falsi che soffocano quelli onesti.

### Erlay (BIP-330)

Erlay sostituisce l'attuale relay di transazioni basato su flooding con un protocollo di riconciliazione di insiemi. Invece di trasmettere ogni nuova transazione a tutti i peer, un nodo invia annunci a un piccolo sottoinsieme e periodicamente riconcilia il suo insieme di transazioni annunciate con ciascun peer. Questo riduce la larghezza di banda di circa il 40% per il relay di transazioni senza aumentare la latenza per la propagazione dei blocchi.

Il protocollo usa uno sketch di riconciliazione basato su Minisketch. Ogni peer mantiene uno sketch degli hash delle transazioni annunciate di recente. Quando due peer si riconciliano, scambiano sketch e calcolano la differenza simmetrica. Solo le transazioni mancanti vengono inviate individualmente. Erlay è stato distribuito sulla rete Bitcoin a partire dal 2022.

### Tor, I2P e CJDNS

Bitcoin Core supporta:

- **Servizi onion Tor v3** (BIP-155): Gli indirizzi onion sono di 56 caratteri e terminano in .onion. Il nodo può sia ascoltare come servizio nascosto Tor sia effettuare connessioni in uscita attraverso Tor. Tor v2 è stato deprecato e rimosso.
- **I2P**: Simile a Tor, I2P fornisce connessioni anonime e crittografate. Bitcoin Core può connettersi a peer I2P e ascoltare come destinazione I2P. Gli indirizzi I2P sono stringhe base32 che terminano in .b32.i2p.
- **CJDNS**: Una mesh IPv6 crittografata. Gli indirizzi CJDNS iniziano sempre con fc. Bitcoin Core tratta CJDNS come un tipo di rete separato.

Le connessioni sono isolate per tipo di rete. Il traffico clearnet, Tor, I2P e CJDNS non viene mescolato, prevenendo il collegamento tra insiemi di anonimato. Il nodo risolve gli indirizzi .onion, .b32.i2p e fc00:: e li instrada attraverso il proxy corretto.

![Handshake di connessione peer-to-peer](media/wiki/peer-to-peer-network/p2p-message-flow.svg "Due nodi stabiliscono una connessione tramite handshake version/verack, poi scambiano messaggi di inventario e dati.")
