---
id: wiki.lightning-network
slug: lightning-network
language: it
category: lightning network
title: Lightning Network
description: La soluzione di scaling di secondo livello di Bitcoin che permette pagamenti istantanei e a basso costo attraverso una rete di canali di pagamento bidirezionali.
coverImage: media/wiki/lightning-network/ln-overview-hero.svg
difficulty: advanced
readTimeMinutes: 10
tags:
  - Lightning Network
  - Layer 2
  - Canali di Pagamento
  - Scalabilità
related:
  - wiki.payment-channels
  - wiki.commitment-transactions
  - wiki.htlcs
  - wiki.onion-routing
  - wiki.lightning-invoices
sources:
  - title: "The Bitcoin Lightning Network: Scalable Off-Chain Instant Payments"
    url: https://lightning.network/lightning-network-paper.pdf
    author: Joseph Poon, Thaddeus Dryja
    publishedAt: 2016-01-14
  - title: "Mastering the Lightning Network"
    url: https://github.com/lnbook/lnbook
    author: Andreas M. Antonopoulos, Olaoluwa Osuntokun, Rene Pickhardt
  - title: "BOLT #1: Base Protocol"
    url: https://github.com/lightning/bolts/blob/master/01-protocol.md
    author: Lightning Network Specifications (BOLTs)
updatedAt: 2026-05-27T00:00:00Z
---

## base

Cos'è la Lightning Network? È un protocollo di secondo livello costruito sopra Bitcoin che permette pagamenti istantanei tra nodi partecipanti. Invece di trasmettere ogni transazione alla blockchain, la Lightning Network usa canali di pagamento — registri privati tra due parti che possono essere transati senza conferma di blocco.

**Il problema che risolve.** Il livello base di Bitcoin può processare circa 7 transazioni al secondo (limitato dalla dimensione di 1 MB del blocco e dall'intervallo di 10 minuti). Per pagamenti piccoli come comprare un caffè o streaming di satoshi, attendere 10-60 minuti e pagare commissioni di diversi dollari rende le transazioni on-chain impraticabili. La Lightning Network risolve questo problema spostando la stragrande maggioranza dei pagamenti off-chain.

**Come aiuta.** I pagamenti su Lightning sono quasi istantanei (millisecondi o secondi), costano frazioni di centesimo indipendentemente dall'importo inviato, e possono scalare a milioni di transazioni al secondo attraverso la rete. Il modello di sicurezza si basa ancora su Bitcoin — i fondi sono protetti dal livello base e possono essere saldati on-chain in qualsiasi momento.

**Analogia.** Immagina un conto al bar. Invece di strisciare una carta di credito per ogni caffè da 5€, apri un conto all'inizio: il barista prende nota del tuo nome ed esegue un'autorizzazione iniziale. Ogni caffè aggiunge un importo al totale corrente. Alla fine della giornata, saldi l'importo finale in un unico pagamento. La Lightning Network funziona in modo simile: apri un canale (il conto), fai molti micropagamenti off-chain, e chiudi il canale per saldare il saldo finale su Bitcoin.

![Panoramica della Lightning Network](media/wiki/lightning-network/ln-overview-hero.svg "La Lightning Network si trova sopra Bitcoin, permettendo pagamenti istantanei tra utenti attraverso canali di pagamento.")

## medium

**I canali di pagamento come mattoni fondamentali.** Un canale di pagamento è una relazione finanziaria tra due parti, garantita da un output multisig 2-of-2 su Bitcoin. Il ciclo di vita del canale ha tre fasi:

**Apertura di un canale (transazione di funding).** Alice crea una transazione di funding che blocca una certa quantità di bitcoin in un output multisig 2-of-2. La trasmette alla rete Bitcoin. Una volta confermata, il canale esiste con un saldo iniziale: Alice possiede l'intero importo, Bob possiede zero. Alice può ora inviare fondi a Bob aggiornando lo stato del canale.

**Aggiornamento dello stato del canale (transazioni di commitment).** Alice e Bob detengono ciascuno una transazione di commitment che riflette la distribuzione corrente dei fondi. Quando Alice vuole inviare 0,01 BTC a Bob, negoziano nuove transazioni di commitment: il commitment di Alice dà 0,01 BTC a Bob e il resto ad Alice. Fondamentalmente, ogni nuova versione invalida la precedente usando un meccanismo di revoca — se una delle parti tenta di trasmettere uno stato vecchio, la controparte può reclamare tutti i fondi come penale.

**Chiusura di un canale.** Qualsiasi delle due parti può chiudere il canale in qualsiasi momento trasmettendo l'ultima transazione di commitment alla rete Bitcoin. La transazione di chiusura spende l'output multisig 2-of-2, distribuendo i saldi finali a ciascuna parte. Il canale viene saldato on-chain in una singola transazione, indipendentemente da quanti pagamenti sono avvenuti all'interno del canale.

**Pagamenti multi-hop.** Non serve un canale diretto con ogni persona a cui vuoi pagare. La Lightning Network instrada i pagamenti attraverso nodi intermedi usando onion routing. Ogni nodo nel percorso conosce solo il suo predecessore e successore immediato — nessun singolo nodo conosce l'intero percorso. Questo preserva la privacy e permette pagamenti tra qualsiasi coppia di nodi sulla rete.

**HTLC (Hashed Timelock Contracts).** L'unità atomica di un pagamento Lightning è l'HTLC. Un HTLC è un pagamento condizionale che può essere riscosso dal destinatario se rivela il preimage di un dato hash entro un time lock, o rimborsato al mittente dopo la scadenza del time lock. Gli HTLC si concatenano attraverso il percorso di pagamento, garantendo che o tutti i nodi vengono pagati o nessuno lo è — il pagamento è atomico.

**Fatture Lightning (BOLT 11).** Per ricevere un pagamento, un nodo genera una fattura contenente un hash di pagamento, l'importo, una descrizione e un tempo di scadenza. La fattura è codificata come stringa bech32 e può essere condivisa tramite QR code o qualsiasi canale di comunicazione. Il pagatore usa la fattura per costruire un percorso HTLC verso il destinatario.

**Routing vs canali diretti.** I canali diretti offrono la migliore esperienza utente (nessuna commissione di routing, nessuna dipendenza da nodi intermedi) ma richiedono di bloccare capitale in anticipo. Il routing permette di pagare chiunque attraverso la rete ma comporta piccole commissioni per ogni salto e dipende dalla topologia della rete e dalla liquidità.

![Confronto on-chain vs Lightning](media/wiki/lightning-network/ln-vs-onchain.svg "Le transazioni on-chain si saldano sul livello base. Le transazioni Lightning avvengono off-chain con solo l'apertura e la chiusura del canale registrate su Bitcoin.")

## advanced

**La costruzione del canale Poon-Dryja.** La costruzione originale del canale Lightning, introdotta nel white paper del 2016 da Joseph Poon e Thaddeus Dryja, stabilisce una coppia di transazioni di commitment asimmetriche. Ogni parte detiene una transazione di commitment che spende l'output di funding 2-of-2. L'innovazione chiave è l'uso di chiavi di revoca: quando viene negoziato un nuovo stato, la chiave di revoca dello stato precedente viene rivelata alla controparte. Se una parte trasmette uno stato vecchio, la controparte può usare la chiave di revoca per reclamare tutti i fondi nel canale. Questo disincentivo economico garantisce che entrambe le parti trasmettano sempre lo stato più recente.

**Il meccanismo di penale in dettaglio.** Ogni transazione di commitment include un output `to_local` (per la parte che ha trasmesso) e un output `to_remote` (per l'altra parte). L'output `to_local` ha un time lock CSV (tipicamente 144 blocchi) e un percorso di revoca. Se colui che ha trasmesso tradisce, la controparte può spendere immediatamente l'output `to_local` usando la chiave di revoca, bypassando il time lock. La penale è totale — l'imbroglione perde l'intero saldo del canale a favore della controparte.

**Protocollo gossip per la scoperta della rete.** I nodi Lightning si scoprono reciprocamente e scoprono la topologia della rete attraverso un protocollo gossip definito in BOLT 7. Tre tipi di messaggi gestiscono questo processo:

- `node_announcement`: Contiene la chiave pubblica del nodo, l'indirizzo IP o servizio onion Tor, le funzionalità supportate e un alias colore RGB. I nodi trasmettono questo quando diventano online.
- `channel_announcement`: Creato quando un nuovo canale viene confermato on-chain. Contiene l'ID del canale, le chiavi pubbliche dei due nodi e l'output della transazione Bitcoin che lo finanzia.
- `channel_update`: Aggiornato da ciascun nodo indipendentemente. Contiene la politica di commissioni (commissione base e proporzionale), i valori HTLC minimi e massimi, il delta di time lock e un flag di disabilitazione. I nodi aggiornano questo quando la loro politica di routing cambia.

Il protocollo gossip usa la freschezza basata su timestamp e previene lo spam attraverso proof-of-work sugli ID dei nodi.

**Economia delle commissioni.** Ogni nodo di routing applica due commissioni per ogni pagamento inoltrato:

- **Commissione base** (`fee_base_msat`): Un importo fisso per HTLC, tipicamente 1-1000 millisatoshi (~0,001-1 sat). Copre il costo dell'inoltro, incluso il rischio on-chain di avere un canale chiuso forzatamente mentre un HTLC è in sospeso.
- **Commissione proporzionale** (`fee_proportional_millionths`): Una frazione dell'importo del pagamento, tipicamente 1-1000 ppm (0,0001%-0,1%). Scala con il valore a rischio.

Commissione totale = commissione_base + (importo × commissione_proporzionale / 1.000.000). Per un pagamento di 100.000 sat con 1000 ppm e 10 msat base, la commissione = 10 + (100.000 × 1000 / 1.000.000) = 10 + 100 = 110 msat.

**Valore HTLC massimo e vincoli di time lock.** Ogni canale ha due parametri critici:
- `htlc_maximum_msat`: Il più grande HTLC che il canale può inoltrare. Impedisce ai nodi di instradare pagamenti che superano la capacità del canale.
- `htlc_minimum_msat`: Il più piccolo HTLC che il canale inoltrerà. Previene HTLC di polvere che costerebbero più in commissioni di quanto valgano.

Il **delta di time lock** (`cltv_expiry_delta`) specifica quanti blocchi ogni salto sottrae dal CLTV. Un valore tipico è 40-144 blocchi per salto. Questo protegge ogni nodo intermedio garantendo che abbia tempo per reclamare i propri fondi a monte prima che l'HTLC a valle scada.

**Attacchi di griefing.** Un attacco di griefing si verifica quando un nodo malintenzionato inoltra un HTLC con un time lock molto lungo ma non lo rivendica né lo fallisce mai. I fondi lungo il percorso vengono bloccati fino alla scadenza del time lock. Le mitigazioni includono:
- Limitare il valore totale degli HTLC in sospeso per canale (`max_concurrent_htlcs`, tipicamente 30)
- Impostare valori HTLC minimi e massimi ragionevoli
- Monitorare la durata degli HTLC in sospeso e chiudere canali con peer non reattivi
- Usare delta CLTV più brevi dove possibile

Il griefing è un rischio di denial-of-service, non un rischio di furto — i fondi non vengono mai persi, solo temporaneamente bloccati.

**Watchtower.** Un watchtower è un servizio di terze parti che monitora la blockchain Bitcoin per le transazioni di chiusura del canale per conto di un nodo Lightning. Se la controparte trasmette una transazione di commitment revocata, il watchtower pubblica la transazione di penale per reclamare i fondi del canale. I watchtower operano in modo trust-minimized — apprendono solo i dati necessari per rilevare e rispondere a tentativi di imbroglio (la chiave di revoca e la transazione incriminata), non il saldo del canale o i dettagli del pagamento. Questo permette ai nodi mobili (che possono essere offline per periodi prolungati) di mantenere la sicurezza del canale senza eseguire un nodo di monitoraggio 24/7.

**Limitazioni attuali.**

- **Liquidità in entrata.** Per ricevere pagamenti, un nodo deve avere capacità in entrata — altri nodi devono aver aperto canali verso di esso. Avviare la liquidità in entrata è uno dei problemi più difficili per i nuovi nodi. Le soluzioni includono: acquistare liquidità in entrata da fornitori, aprire canali dal lato opposto (dual-funding) e bilanciare i canali attraverso ribilanciamento circolare.
- **Fallimenti di routing.** I tassi di successo dei pagamenti sono tipicamente del 90-98%, a seconda della topologia della rete e della distribuzione della liquidità. I fallimenti si verificano quando un nodo lungo il percorso ha liquidità insufficiente, è offline o applica commissioni inaspettate. La maggior parte delle implementazioni implementa il re-try automatico con euristiche di pathfinding.
- **Ribilanciamento dei canali.** Col tempo, i pagamenti in una direzione possono esaurire il saldo locale di un canale. Il ribilanciamento sposta la liquidità attraverso pagamenti circolari o chiudendo e riaprendo canali. Il processo è manuale o semi-automatizzato nelle implementazioni attuali e consuma commissioni di routing.

**Miglioramenti del protocollo.** Due notevoli miglioramenti nella pipeline di specifica BOLT:

- **Wumbo (canali grandi) — BOLT 2.** Le prime implementazioni Lightning limitavano le dimensioni dei canali a circa 16,7 milioni di satoshi (0,167 BTC) per limitare il rischio. Wumbo rimuove questo limite, permettendo canali con capacità maggiori per instradare pagamenti di alto valore. I nodi devono segnalare il supporto wumbo e aderire esplicitamente.

- **Dual-funding — BOLT 2.** La costruzione originale Poon-Dryja richiede che una sola parte finanzi l'intero canale. Il dual-funding permette a entrambe le parti di contribuire con fondi al saldo iniziale del canale, risolvendo metà del problema di liquidità in entrata alla creazione del canale. Utilizza un protocollo di costruzione collaborativa delle transazioni chiamato interactive funding.
