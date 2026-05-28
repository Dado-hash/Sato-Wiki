---
id: wiki.lightning-service-providers
slug: lightning-service-providers
language: it
category: lightning network
title: Lightning Service Provider
description: Servizi di terze parti che connettono gli utenti finali alla Lightning Network offrendo liquidità in entrata, routing affidabile, gestione dei canali e operatività del nodo sempre attiva.
coverImage: media/wiki/lightning-service-providers/lsp-architecture.svg
difficulty: advanced
readTimeMinutes: 8
tags:
  - Lightning Network
  - LSP
  - Fornitore di Servizi
  - Liquidità in Entrata
  - Gestione del Nodo
related:
  - wiki.lightning-network
  - wiki.channel-liquidity
  - wiki.routing-fees
  - wiki.watchtowers
  - wiki.splicing
  - wiki.payment-channels
sources:
  - title: "LSP Specification (LSPS)"
    url: https://github.com/lightning/bolts/issues/818
    author: Lightning Network Community
  - title: "LSP — Lightning Service Provider Overview"
    url: https://docs.lightning.engineering/lightning-network-tools/lsp
    author: Lightning Labs
  - title: "Mastering the Lightning Network — Node Operations"
    url: https://github.com/lnbook/lnbook
    author: Andreas M. Antonopoulos, Olaoluwa Osuntokun, Rene Pickhardt
updatedAt: 2026-05-27T00:00:00Z
---

## base

Un LSP (Lightning Service Provider, Fornitore di Servizi Lightning) è un servizio che gestisce la connettività Lightning per gli utenti, fungendo da ponte tra un portafoglio mobile e la più ampia Lightning Network. Senza un LSP, un nodo appena creato parte con zero canali e nessuna capacità di ricevere pagamenti — può solo inviare fondi attraverso canali che apre autonomamente.

**Il problema principale che gli LSP risolvono è la liquidità in entrata.** Quando un utente apre un canale verso un peer, i fondi risiedono sul lato dell'utente, il che significa che il peer ha capacità in entrata ma l'utente no. Per ricevere pagamenti, qualcun altro deve aprire un canale verso l'utente — ed è esattamente ciò che fa un LSP. L'LSP apre un canale *verso* l'utente, fornendo capacità in uscita dal punto di vista dell'LSP e capacità in entrata dal punto di vista dell'utente.

**Cosa fornisce un LSP:** un canale diretto dall'LSP all'utente con capacità iniziale in uscita (dando all'utente la capacità immediata di ricevere), routing sempre attivo in modo che i pagamenti da e verso l'utente raggiungano la destinazione, monitoraggio watchtower che protegge il canale dell'utente mentre il portafoglio è offline, e backup dei canali che prevengono la perdita di fondi in caso di ripristino del dispositivo mobile.

**Analogia.** Un LSP è come un ISP (Fornitore di Servizi Internet) per la Lightning Network. Quando ti abboni a internet a casa, l'ISP fornisce il modem e il cavo — non devi costruire la tua infrastruttura. Analogamente, un LSP fornisce la connettività Lightning così puoi inviare e ricevere pagamenti senza dover gestire un nodo full-time con molti canali.

![Architettura LSP](media/wiki/lightning-service-providers/lsp-architecture.svg "Un LSP collega gli utenti finali alla Lightning Network, fornendo liquidità, routing e disponibilità sempre attiva.")

## medium

**Come funzionano gli LSP.** L'LSP opera un nodo ben connesso con molti canali verso altri nodi ben connessi sulla rete. Quando un utente si connette a un LSP, l'LSP apre un canale verso l'utente, finanziandolo con bitcoin dalle proprie riserve. Dal punto di vista dell'utente, questo canale ha capacità in entrata — può immediatamente ricevere pagamenti senza prima spendere i propri fondi per spingere liquidità dall'altra parte.

**Canali Just-In-Time (JIT).** Un modello più sofisticato è il canale JIT. In questa configurazione, l'LSP non apre un canale verso l'utente in anticipo. Invece, quando un pagamento arriva per l'utente, l'LSP apre un canale al volo, inoltra il pagamento attraverso di esso, e mantiene il canale aperto per pagamenti futuri. I canali JIT riducono i costi iniziali per l'utente e permettono agli LSP di allocare capitale solo quando genera commissioni di routing.

**Modelli di tariffazione degli LSP.** Gli LSP tipicamente applicano una o più delle seguenti strutture:

- **Canone di lease del canale:** una tariffa una tantum o ricorrente per aprire e mantenere un canale di una dimensione specifica (es. canale da 0,01 BTC per 30 giorni).
- **Percentuale per pagamento:** una piccola percentuale di ogni pagamento instradato attraverso l'LSP.
- **Abbonamento mensile fisso:** una tariffa fissa per un pacchetto di servizi che include liquidità in entrata, routing e copertura watchtower.

**Il mercato della liquidità in entrata.** Gli LSP competono su prezzo, affidabilità, dimensione del canale e prossimità geografica (latenza minore significa routing più veloce). Gli utenti possono confrontare le offerte di lease e scegliere LSP che offrono le migliori tariffe per la dimensione e durata del canale desiderate. Alcuni LSP offrono anche tier gratuiti con dimensioni di canale limitate per attrarre nuovi utenti.

**Lease di canali.** Un lease di canale è un accordo a tempo determinato in cui l'LSP impegna fondi in un canale con l'utente. Dopo la scadenza del lease, l'LSP può chiudere il canale o l'utente può rinnovarlo. I lease sono denominati in importo di bitcoin e durata, tipicamente da 0,01 BTC a 0,5 BTC per 30-365 giorni.

![Servizi LSP](media/wiki/lightning-service-providers/lsp-services.svg "Gli LSP offrono liquidità in entrata, routing affidabile e servizi di gestione dei canali, ciascuno con diversi modelli di prezzo.")

## advanced

**LSPS (LSP Specification).** Con la crescita dell'ecosistema LSP, è emersa la necessità di un protocollo standard per la comunicazione tra LSP e client. LSPS (LSP Specification) è uno sforzo in corso nella comunità Lightning Network per definire come LSP e client interagiscono. È organizzato come un insieme di sottoprotocolli, ciascuno identificato da un numero LSPS:

**LSPS0 — Livello di trasporto.** Definisce i protocolli di trasporto che LSP e client usano per comunicare. I due trasporti principali sono WebSocket (raccomandato per client mobili) e gRPC (raccomandato per comunicazione server-to-server). LSPS0 gestisce anche autenticazione, segnalazione errori e negoziazione delle capacità.

**LSPS1 — Acquisto di canali in entrata.** Il servizio più fondamentale: il client richiede un canale in entrata di una dimensione specifica dall'LSP, paga una commissione di lease (on-chain o tramite Lightning), e l'LSP apre il canale. Il protocollo gestisce la negoziazione delle commissioni, la durata del canale e il flusso di finanziamento. È l'equivalente LSP dell'acquisto di una SIM prepagata.

**LSPS2 — Canali Just-In-Time.** Invece di acquistare un canale in anticipo, il client si registra presso l'LSP e fornisce una fattura o un identificatore di pagamento. Quando un pagamento arriva per il client, l'LSP apre un canale, inoltra il pagamento e fattura al client il servizio. Questo modello è ideale per utenti che ricevono pagamenti poco frequentemente e non vogliono prepagare per capacità del canale.

**Connettività watchtower.** Molti LSP includono servizi watchtower con la loro offerta di canali. Poiché l'LSP è già sempre attivo e monitora la blockchain, estendere la copertura watchtower al canale dell'utente è un'aggiunta naturale. L'utente delega all'LSP la responsabilità di monitorare le transazioni di commitment revocate, o a una watchtower dedicata gestita dall'LSP.

**Splicing come servizio LSP.** Lo splicing permette di regolare la capacità di un canale senza chiuderlo e riaprirlo. Un LSP può offrire lo splicing come servizio gestito: quando un utente vuole aggiungere o rimuovere fondi dal proprio canale, l'LSP coordina la transazione di splice. Dal punto di vista dell'utente, il canale rimane attivo per tutto il tempo — non c'è interruzione. Questo è particolarmente utile per portafogli mobili che devono regolare la dimensione dei canali in base ai cambiamenti nelle loro abitudini di spesa e ricezione.

**Canali zero-conf.** Un canale zero-conf (zero conferma) è un canale che l'LSP apre e che l'utente inizia a usare immediatamente, prima che la transazione di funding sia confermata sulla blockchain Bitcoin. L'LSP si assume il rischio che la transazione di funding possa non essere confermata (a causa di double-spend o commissioni basse), ma in pratica questo rischio è minimo con una corretta stima delle commissioni. I canali zero-conf offrono un'esperienza utente istantanea: l'utente può ricevere pagamenti secondi dopo aver installato un portafoglio, senza attendere conferme on-chain.

**Considerazioni normative.** Poiché gli LSP gestiscono bitcoin e fanno pagare per i servizi, potrebbero essere soggetti a normative sul trasferimento di denaro in alcune giurisdizioni. Mentre gestire un nodo Lightning è generalmente considerato un'attività software, operare un LSP come attività commerciale che facilita pagamenti e applica commissioni può attivare requisiti KYC/AML. Questo crea tensione tra l'etica self-custodial e permissionless di Bitcoin e gli obblighi normativi che gli LSP possono affrontare. Alcuni LSP operano senza KYC come puri servizi software, mentre altri implementano programmi di conformità.

**Il futuro degli LSP.** Il panorama degli LSP si sta evolvendo verso modelli più decentralizzati:

- **Mercati LSP decentralizzati:** piattaforme in cui più LSP competono per i canali degli utenti, permettendo agli utenti di confrontare le tariffe e cambiare fornitore senza problemi.
- **Aste di liquidità:** gli utenti richiedono capacità del canale e gli LSP fanno offerte per fornirla, abbassando i prezzi attraverso la concorrenza.
- **LSP federati:** gruppi di nodi mettono in comune la liquidità e condividono i ricavi del routing, riducendo i requisiti di capitale per ogni singolo partecipante.

**LSP vs submarine swap.** Sia gli LSP che i submarine swap forniscono liquidità in entrata, ma funzionano diversamente. Un submarine swap converte bitcoin on-chain in bitcoin Lightning (o viceversa) attraverso un terzo fidato, solitamente in una singola transazione atomica. Un LSP, al contrario, fornisce una relazione di canale duratura con servizi continui di routing e gestione. I submarine swap sono una soluzione di liquidità una tantum; gli LSP sono una relazione di servizio continuativa. Molti utenti combinano entrambi: usando submarine swap per regolazioni occasionali e un LSP per la connettività quotidiana.
