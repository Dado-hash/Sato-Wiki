---
id: wiki.watchtowers
slug: watchtowers
language: it
category: lightning network
title: Watchtower
description: Servizi di terze parti che monitorano la blockchain di Bitcoin alla ricerca di transazioni di commitment revocate, permettendo ai nodi Lightning di rimanere sicuri mentre sono offline.
coverImage: media/wiki/watchtowers/watchtower-flow.svg
difficulty: advanced
readTimeMinutes: 8
tags:
  - Lightning Network
  - Watchtower
  - Sicurezza
  - Meccanismo di Penalità
  - Protezione Offline
related:
  - wiki.lightning-network
  - wiki.commitment-transactions
  - wiki.payment-channels
  - wiki.lightning-service-providers
sources:
  - title: "BOLT #2 — Peer Protocol for Channel Management"
    url: https://github.com/lightning/bolts/blob/master/02-peer-protocol.md
    author: Lightning Network Specifications
  - title: "Watchtower Overview — Lightning Labs"
    url: https://docs.lightning.engineering/lightning-network-tools/lnd/watchtower
    author: Lightning Labs
  - title: "Theoretical and Practical Approaches to Watchtowers"
    url: https://github.com/lightningnetwork/lnd/blob/master/docs/watchtower.md
    author: Conner Fromknecht
updatedAt: 2026-05-27T00:00:00Z
---

## base

Un **watchtower** (torre di vigilanza) è un servizio di terze parti che osserva la blockchain di Bitcoin per conto tuo mentre il tuo nodo Lightning è offline. Immaginalo come una guardia giurata che sorveglia la tua casa mentre sei in vacanza — se qualcuno tenta di entrare, la guardia allerta le autorità.

**Il problema.** I canali Lightning si basano sull'ultima transazione di commitment per determinare a chi appartengono i fondi. Se il tuo telefono è spento e il tuo peer di canale trasmette una vecchia transazione di commitment revocata che li favorisce, potrebbe rubare i tuoi fondi. Senza un watchtower, devi rimanere online costantemente per intercettare i tentativi di frode.

**Come aiuta.** Prima di andare offline, il tuo nodo condivide "transazioni di giustizia" crittografate con il watchtower. Il watchtower scansiona ogni nuovo blocco Bitcoin. Se rileva una transazione di commitment revocata sulla blockchain, trasmette la transazione di giustizia — una transazione di penalità che invia tutti i fondi del canale a te, la parte onesta. Rimani sicuro anche quando il tuo dispositivo è spento.

![Watchtower in Azione](media/wiki/watchtowers/watchtower-flow.svg "Un watchtower monitora la blockchain per conto di un nodo offline e pubblica una transazione di penalità se il peer del canale tradisce.")

## medium

**Come funzionano i watchtower.** Prima di andare offline, un nodo Lightning crea e carica una o più transazioni di giustizia crittografate (chiamate anche "blob") sul watchtower. Ogni blob contiene i dati minimi necessari per l'azione del watchtower:

- Il **txid della transazione di commitment revocata** (o un prefisso usato come indice)
- Il **percorso di spesa della penalità** — una firma che permette a chiunque di spendere l'output revocato verso il portafoglio del nodo onesto
- Una **chiave di offuscamento** per decrittare il blob

Il watchtower memorizza questi blob indicizzati dal suffisso del txid. Per ogni nuovo blocco, il watchtower verifica se qualche transazione nel blocco corrisponde a un indice memorizzato. In caso di corrispondenza, recupera il blob corrispondente, lo decritta usando la chiave di offuscamento, e trasmette la transazione di penalità.

**Modello di privacy.** Il blob è crittografato in modo che il watchtower non possa leggerne il contenuto. Il watchtower apprende:

- Il prefisso del txid (abbastanza per abbinare le transazioni on-chain)
- Che esiste un canale di pagamento (poiché riceve blob)
- L'altezza del blocco a cui attivare ogni indizio

Il watchtower **non** apprende:

- Saldi del canale o importi dei pagamenti
- Identità della controparte
- Capacità del canale o alias del nodo
- I dettagli completi della transazione di commitment

Questo garantisce che nemmeno un watchtower malintenzionato possa rubare fondi o spiare la tua attività nel canale. Il design crittografato rende i watchtower a fiducia minima — sono guardiani che non possono aprire la cassaforte.

![Design Trust-Minimized del Watchtower](media/wiki/watchtowers/watchtower-privacy.svg "La crittografia dei blob garantisce che il watchtower non apprenda nulla sullo stato del canale o sul saldo.")

**Limitazioni.** I watchtower proteggono solo da un attacco specifico: un peer del canale che trasmette una transazione di commitment revocata. Non proteggono da:

- **Attacchi di griefing** in cui un peer chiude forzatamente il canale onestamente ma in un momento scomodo
- **Attacchi legati alle commissioni** in cui un peer trasmette una transazione di commitment con commissioni insufficienti, rimanendo bloccata nel mempool
- **Tempo di inattività del nodo di routing** nei pagamenti multi-hop
- **Perdita di dati** — se perdi completamente lo stato del canale, un watchtower non può recuperare i tuoi fondi

## advanced

**Il protocollo watchtower.** La comunicazione watchtower è definita nelle specifiche BOLT (estensioni a BOLT #2). Il protocollo definisce due ruoli:

- **Client (tower client):** Il nodo Lightning che necessita di monitoraggio. Tipicamente un dispositivo mobile o a bassa disponibilità.
- **Torre (watchtower):** Il servizio sempre attivo che monitora la blockchain.

Il protocollo utilizza un'interfaccia in stile gRPC su tunnel Noise (trasporto crittografato). I messaggi chiave del protocollo includono:

- `SessionInit`: Il client si registra presso una torre, negoziando parametri come dimensione del blob, schema di ricompensa e policy
- `StateUpdate`: Il client carica nuovi blob crittografati man mano che lo stato del canale avanza
- `DeleteSession`: Il client rimuove una sessione quando un canale viene chiuso
- `TowerInfo`: Richieste di stato e riepiloghi di sessione

**Formato del blob crittografato.** Lo schema di crittografia del blob è fondamentale per la privacy. Il client deriva una chiave dallo stato del canale usando una funzione di hash con chiave. Il payload del blob contiene:

1. La **transazione di penalità crittografata** (la transazione di giustizia che spende l'output revocato)
2. Il **suggerimento del txid** — un hash troncato del txid di commitment revocato usato per l'indicizzazione
3. Un **suggerimento di altezza del blocco** — l'altezza minima alla quale il watchtower dovrebbe iniziare a scansionare

La crittografia garantisce che solo il client (che conosce il percorso di derivazione) possa decrittare il blob. Il watchtower esegue una semplice ricerca: dato un txid da un nuovo blocco, calcola il prefisso del suggerimento e verifica le corrispondenze nel suo database.

**Gestione delle sessioni.** Un client gestisce sessioni con una o più torri:

1. **Registrazione:** Il client sceglie una torre (per chiave pubblica e indirizzo) e avvia una sessione. La torre può richiedere autenticazione o pagamento anticipato.
2. **Caricamento batch di blob:** Il client può caricare più blob in un singolo batch, ciascuno corrispondente a uno stato revocato diverso. Il client filtra gli stati e carica solo quelli rilevanti — tipicamente gli ultimi stati, non l'intera cronologia.
3. **Heartbeat:** Il client invia messaggi di keep-alive periodici per confermare che la torre sia operativa.
4. **Chiusura della sessione:** Quando un canale si chiude in modo cooperativo, il client comunica alla torre di eliminare i blob corrispondenti.

**Filtro lato client.** Il client deve essere selettivo su quali stati caricare. Caricare ogni stato passato sprecherebbe storage e larghezza di banda della torre. Il client carica tipicamente solo:

- Gli **ultimi n stati** (ad esempio, le 3 transazioni di commitment più recenti)
- Stati **prossimi alla scadenza** (vicini al timelock CSV)
- Stati in cui la **distribuzione del saldo è cambiata significativamente**

La strategia di filtro dipende dalla tolleranza al rischio del client. Un client conservativo carica molti stati; uno aggressivo ne carica pochi, accettando una finestra di vulnerabilità più piccola.

**Meccanismo di ricompensa.** Alcuni watchtower fanno pagare commissioni per il loro servizio. Due modelli comuni:

- **Commissione fissa:** Il client paga un abbonamento ricorrente (ad esempio, satoshi mensili) indipendentemente dal fatto che una penalità venga mai attivata
- **Commissione di successo:** La torre prende una percentuale dei fondi recuperati quando una transazione di penalità viene trasmessa con successo

Il modello a commissione di successo allinea gli incentivi — la torre guadagna solo quando protegge con successo il client. Tuttavia, introduce complessità: la transazione di penalità deve includere un output per la torre, che il client deve pre-firmare.

**Implementazione LND.** LND (Lightning Network Daemon) è stata la prima implementazione importante a rilasciare un watchtower di produzione. Decisioni chiave di design:

- Il watchtower di LND utilizza un modello a **sessione singola per canale** — ogni canale ha la propria sessione con storage blob indipendente
- I blob sono crittografati usando **AEAD** (Authenticated Encryption with Associated Data) con una chiave derivata dall'elemento `shachain` del canale
- La torre memorizza i blob in un **database bolt-backed** su disco locale
- I client possono registrarsi con più torri simultaneamente per ridondanza
- LND supporta sia la modalità "torre" (esecuzione di un server watchtower) che la modalità "client" (connessione a torri remote)

**Approccio integrato BOLT 2.** La specifica BOLT adotta un approccio più integrato rispetto all'implementazione di LND:

- Le sessioni sono stabilite attraverso il trasporto crittografato peer-to-peer esistente (Noise), non connessioni separate
- Il protocollo è progettato per essere indipendente dall'implementazione — qualsiasi implementazione Lightning (c-lightning, Eclair, LDK) può supportare i watchtower
- I formati dei blob sono standardizzati tra le implementazioni, consentendo l'interoperabilità
- La specifica include disposizioni per la **ridondanza e il failover da torre a torre**

**Topologia della rete di watchtower.** In pratica, i watchtower sono gestiti da:

- **LSP (Lightning Service Providers):** Che offrono monitoraggio watchtower come parte di un pacchetto con gestione dei canali
- **Exchange:** Che gestiscono torri come valore aggiunto per i loro portafogli Lightning ospitati
- **Volontari della comunità:** Che gestiscono torri gratuitamente come bene pubblico
- **Servizi commerciali:** Fornitori specializzati di watchtower-as-a-service

Una topologia tipica prevede un client mobile registrato con 2–3 torri per ridondanza. Le torri sono distribuite geograficamente e gestite indipendentemente, in modo che nessuna singola torre sia un punto di errore o di fiducia.

**Limitazioni attuali.** Nonostante la loro efficacia, i watchtower hanno limitazioni pratiche:

- **Costo di storage:** Ogni stato del canale richiede un blob. Per nodi ad alto volume con molti canali, lo storage dei blob può raggiungere gigabyte
- **Latenza di scansione:** Le torri devono scansionare ogni blocco. Durante periodi di alto throughput, una torre potrebbe rimanere indietro
- **Rischio di front-running:** Un attaccante sofisticato potrebbe tentare di anticipare la transazione di penalità della torre, sebbene la struttura dell'output di penalità renda questa operazione difficile
- **Nessuna protezione contro le commissioni di force-close:** I watchtower non possono regolare i livelli di commissione sulla transazione di penalità — se le commissioni aumentano, la penalità potrebbe non essere confermata in tempo
- **Assunzioni di fiducia:** Sebbene a fiducia minima, il watchtower apprende comunque l'esistenza del tuo canale e la sua data di apertura approssimativa
