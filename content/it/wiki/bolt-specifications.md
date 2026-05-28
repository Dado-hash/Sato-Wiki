---
id: wiki.bolt-specifications
slug: bolt-specifications
language: it
category: lightning network
title: Specifiche BOLT
description: The Basis of Lightning Technology — un insieme di specifiche che definiscono il protocollo Lightning Network, coprendo comunicazione tra peer, gestione dei canali, formati delle transazioni e routing.
coverImage: media/wiki/bolt-specifications/bolt-architecture.svg
difficulty: advanced
readTimeMinutes: 9
tags:
  - Lightning Network
  - BOLT
  - Specifiche
  - Standard
  - Protocollo
related:
  - wiki.lightning-network
  - wiki.payment-channels
  - wiki.onion-routing
  - wiki.lightning-invoices
  - wiki.commitment-transactions
  - wiki.splicing
sources:
  - title: "Lightning Network BOLTs Repository"
    url: https://github.com/lightning/bolts
    author: Lightning Network Community
  - title: "BOLT #1 — Base Protocol"
    url: https://github.com/lightning/bolts/blob/master/01-protocol.md
    author: Lightning Network Specifications
  - title: "Mastering the Lightning Network — Appendix: BOLT Reference"
    url: https://github.com/lnbook/lnbook
    author: Andreas M. Antonopoulos, Olaoluwa Osuntokun, Rene Pickhardt
updatedAt: 2026-05-27T00:00:00Z
---

## base

BOLT sta per **Basis of Lightning Technology**. I BOLT sono le specifiche ufficiali del protocollo che definiscono il funzionamento della Lightning Network — ogni implementazione che vuole essere interoperabile deve seguirle.

Esistono nove documenti BOLT attivi, ciascuno dedicato a un diverso aspetto del protocollo. Sono ospitati su GitHub all'indirizzo `github.com/lightning/bolts`, dove chiunque può leggere il codice sorgente, seguire le modifiche e proporre miglioramenti.

Le specifiche garantiscono che diverse implementazioni di Lightning — LND, Core Lightning, Eclair, LDK — parlino lo stesso linguaggio. Senza i BOLT, ogni implementazione definirebbe il proprio formato di rete, la propria logica di canale e il proprio schema di routing, rendendo l'interoperabilità impossibile.

![Pila del protocollo BOLT](media/wiki/bolt-specifications/bolt-architecture.svg "Le nove specifiche BOLT attive organizzate come una pila di protocollo, dal trasporto al livello applicativo.")

## medium

I documenti BOLT sono numerati individualmente. Ciascuno affronta uno specifico layer o funzione del protocollo:

**BOLT #1 — Protocollo di Base.** Definisce il trasporto crittografato, l'handshake crittografico iniziale, il formato dei messaggi (tipo a 2 byte + payload con prefisso di lunghezza) e la gestione degli errori. Ogni messaggio scambiato tra nodi Lightning utilizza il framing definito qui.

**BOLT #2 — Protocollo Peer.** Specifica l'intero ciclo di vita di un canale di pagamento: apertura, accettazione, finanziamento, aggiornamento della transazione di commitment e chiusura. Definisce come gli HTLC vengono aggiunti e rimossi, come vengono scambiate le firme di commitment e come funzionano le chiusure cooperative e unilaterali.

**BOLT #3 — Formati delle Transazioni Bitcoin e Script.** Descrive la struttura esatta delle transazioni di commitment, gli script degli output HTLC e il meccanismo di penale che garantisce la sicurezza del canale. Include dettagli su `to_local`, `to_remote` e gli output HTLC di timeout/successo.

**BOLT #4 — Onion Routing.** Copre la costruzione di pacchetti di pagamento crittografati a cipolla usando il protocollo Sphinx. Specifica come il pagatore costruisce strati di crittografia annidati, come ogni hop decifra il suo payload e come gli errori risalgono.

**BOLT #5 — Raccomandazioni per la Gestione delle Transazioni On-Chain.** Fornisce linee guida sulla gestione delle fee, la selezione UTXO e come le implementazioni dovrebbero gestire la chiusura on-chain dei canali quando il peer non risponde.

**BOLT #7 — Scoperta di Nodi e Canali P2P.** Definisce il protocollo gossip che permette ai nodi di scoprirsi reciprocamente e conoscere i canali pubblici. Copre i messaggi `node_announcement`, `channel_announcement` e `channel_update` che costruiscono il grafo della rete.

**BOLT #8 — Trasporto Crittografato e Autenticato.** Specifica il framework Noise protocol utilizzato per il trasporto crittografato. Definisce il pattern di handshake esatto (`Noise_XK`) e i primitivi crittografici (Secp256k1, ChaCha20-Poly1305, SHA256).

**BOLT #9 — Feature Bits.** Un registro di feature bit che i nodi usano per segnalare le estensioni di protocollo supportate. Ogni feature ha una coppia pari/dispari: i bit pari sono obbligatori (il nodo deve supportarli o disconnettersi), i bit dispari sono opzionali.

**BOLT #11 — Protocollo di Fatturazione.** Definisce il formato di fattura codificato in bech32 usato per richiedere pagamenti. Specifica il prefisso leggibile, il timestamp, i campi taggati (hash di pagamento, descrizione, scadenza, suggerimenti di routing) e la firma ECDSA recuperabile.

## advanced

**BOLT #12 — Offers.** Il protocollo di fatturazione di nuova generazione destinato a sostituire BOLT 11. Le offerte risolvono le limitazioni chiave delle fatture statiche: supportano pagamenti ricorrenti senza riutilizzo del preimmagine, abilitano la ricezione asincrona, usano route blinding per la privacy e permettono rimborsi (il ricevente diventa pagatore). Un'offerta è una stringa statica che può generare molte fatture, eliminando la necessità che il ricevente sia online.

**Estensioni di BOLT #2.** Il protocollo peer è stato esteso oltre il ciclo di vita originale del canale:
- Dual-funding (BOLTs + `dual-fund`): entrambe le parti contribuiscono alla transazione di apertura del canale.
- Splicing: modifica della capacità del canale in corso, aggiungendo o rimuovendo fondi senza chiudere.
- Canali Wumbo: rimozione del limite massimo di 0,167 BTC sulla dimensione del canale, permettendo capacità maggiori.

**Il processo BOLT.** Il ciclo di vita di un BOLT segue un percorso ben definito:
1. **Proposta** — un'idea viene formalizzata come modifica alla specifica.
2. **Bozza** — la proposta viene scritta come documento markdown BOLT.
3. **Pull Request** — la bozza viene inviata a `github.com/lightning/bolts`.
4. **Revisione** — gli implementatori discutono, commentano e richiedono modifiche.
5. **Accettazione** — si raggiunge il consenso e la PR viene integrata.
6. **Attivazione** — le implementazioni distribuiscono e supportano la nuova specifica.
7. **Modifiche** — PR successive perfezionano e aggiornano la specifica.

![Ciclo di vita delle specifiche BOLT](media/wiki/bolt-specifications/bolt-lifecycle.svg "Dalla proposta all'attivazione: come le specifiche BOLT attraversano il processo di standardizzazione.")

**Negoziazione dei feature bit.** Quando due nodi si connettono, scambiano messaggi `init` che includono i loro vettori di feature bit. Ogni bit segnala il supporto per una specifica estensione:
- Bit pari: obbligatori — se un nodo non supporta un bit pari, il peer deve disconnettersi.
- Bit dispari: opzionali — i nodi possono ignorare i bit dispari non supportati e continuare a operare.
Questa negoziazione permette al protocollo di evolversi senza rompere la compatibilità con i nodi più vecchi.

**Differenze tra implementazioni.** Sebbene i BOLT definiscano una specifica unica, le implementazioni interpretano la specifica con variazioni minori:
- **LND** (Go): la più diffusa, enfatizza la stabilità in produzione.
- **Core Lightning** (C): dà priorità alla conformità alle specifiche e all'architettura modulare.
- **Eclair** (Scala): implementazione di riferimento con audit di sicurezza rigorosi.
- **LDK** (Rust): una libreria anziché un nodo completo, usata per incorporare Lightning in altre applicazioni.
Le discrepanze tra le implementazioni vengono discusse nel repository dei BOLT e risolte tramite modifiche alle specifiche.

**Specifica vivente.** Il repository BOLT non è un insieme di documenti statici. Nuovi BOLT vengono aggiunti man mano che il protocollo si evolve, e quelli esistenti ricevono modifiche attraverso lo stesso processo di PR. Il repository traccia l'intera storia — ogni discussione, ogni decisione, ogni modifica — rendendolo la fonte autorevole per gli standard della Lightning Network.
