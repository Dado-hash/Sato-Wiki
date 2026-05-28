---
id: wiki.multipath-payments
slug: multipath-payments
language: it
category: lightning network
title: Pagamenti Multipath
description: Una tecnica che suddivide un singolo pagamento Lightning in pagamenti parziali instradati attraverso percorsi diversi, migliorando affidabilità, privacy e utilizzo della liquidità.
coverImage: media/wiki/multipath-payments/mpp-flow.svg
difficulty: advanced
readTimeMinutes: 8
tags:
  - Lightning Network
  - MPP
  - Pagamenti Multipath
  - Routing
  - Affidabilità
related:
  - wiki.lightning-network
  - wiki.htlcs
  - wiki.onion-routing
  - wiki.channel-liquidity
  - wiki.routing-fees
sources:
  - title: "BOLT #4 — Onion Routing (sezione MPP)"
    url: https://github.com/lightning/bolts/blob/master/04-onion-routing.md
    author: Lightning Network Specifications
  - title: "BOLT #11 — Invoice Protocol (feature bit MPP)"
    url: https://github.com/lightning/bolts/blob/master/11-payment-encoding.md
    author: Lightning Network Specifications
  - title: "Mastering the Lightning Network — Multipath Payments"
    url: https://github.com/lnbook/lnbook
    author: Andreas M. Antonopoulos, Olaoluwa Osuntokun, Rene Pickhardt
updatedAt: 2026-05-27T00:00:00Z
---

## base

**Cosa sono i Pagamenti Multipath?** I Pagamenti Multipath (MPP) sono una tecnica della Lightning Network che suddivide un singolo pagamento in pagamenti parziali più piccoli, ciascuno instradato attraverso un percorso diverso verso lo stesso destinatario. Invece di inviare l'intero importo attraverso una singola rotta, il mittente lo divide in parti che viaggiano indipendentemente attraverso la rete.

**Il problema risolto da MPP.** I pagamenti Lightning sono vincolati dalla liquidità dei canali: un pagamento può attraversare un canale solo se questo dispone di capacità sufficiente nella direzione corretta. I pagamenti di importo elevato spesso falliscono perché nessun singolo percorso ha liquidità sufficiente dall'inizio alla fine. MPP risolve questo problema utilizzando percorsi multipli, ciascuno dei quali contribuisce con una parte dell'importo totale.

**Come funziona.** Il mittente seleziona un insieme di rotte la cui capacità combinata copra l'importo del pagamento. Ogni pagamento parziale è avvolto nel proprio HTLC (Hash Time Locked Contract), ma tutti condividono lo stesso hash di pagamento H(x). Il destinatario accumula gli HTLC parziali e considera il pagamento completato solo quando la somma di tutte le parti ricevute eguaglia l'importo atteso. Poiché tutte le parti condividono lo stesso preimmagine x, il destinatario rilascia il preimmagine una sola volta — quando l'importo totale è arrivato.

**Vantaggi principali.**

- **Affidabilità.** Se un percorso ha liquidità insufficiente, il mittente può ritentare quella porzione attraverso una rotta diversa senza dover riavviare l'intero pagamento.
- **Privacy.** Suddividere un pagamento su percorsi multipli rende più difficile per gli osservatori determinare l'importo totale inviato o la destinazione finale.
- **Utilizzo della liquidità.** MPP utilizza la liquidità disponibile attraverso la rete in modo più efficiente, consentendo pagamenti più grandi di quanto un singolo canale permetterebbe.

**Analogia.** Immagina di portare 200.000 satoshi in contanti lungo una singola strada per raggiungere la tua destinazione. Se un blocco stradale ti ferma, l'intera consegna fallisce. MPP è come dividere il contante in tre buste inviate attraverso strade diverse. Anche se una strada è bloccata, le altre due arrivano a destinazione. Il destinatario conferma la consegna solo quando tutte le buste sono state ricevute.

![Flusso dei Pagamenti Multi-Path](media/wiki/multipath-payments/mpp-flow.svg "Un pagamento di 200.000 satoshi suddiviso su tre percorsi: Alice a Bob a Carol (80.000), Alice a Dave a Carol (70.000) e Alice a Eve a Frank a Carol (50.000). Carol accumula tutti gli HTLC parziali e completa il pagamento solo quando la somma raggiunge 200.000.")

## medium

**Il vincolo dello stesso hash di pagamento.** Tutti i pagamenti parziali in un insieme MPP devono utilizzare lo stesso hash H(x). Questo vincolo è fondamentale per il modello di sicurezza: poiché tutte le parti condividono lo stesso preimmagine x, il destinatario può riscuotere qualsiasi HTLC parziale solo rivelando x. Una volta ricevuto l'importo completo, il destinatario rivela x una sola volta e tutti gli HTLC parziali si risolvono atomicamente.

**Come viene segnalato il supporto MPP.** Sia il mittente che il destinatario devono pubblicizzare il supporto MPP attraverso i feature bit del protocollo Lightning. Il feature bit `basic_mpp` (bit 14 in BOLT 9) viene negoziato durante la connessione. Se una delle due parti non supporta MPP, il mittente torna al pagamento a percorso singolo.

**Il meccanismo payment_secret.** Le fatture BOLT 11 includono un campo `payment_secret` — un valore casuale di 32 byte generato dal destinatario. Questo segreto serve a due scopi:

1. **Legare insieme i pagamenti parziali.** Il payment_secret è incluso nel payload onion di ogni pagamento parziale. Il destinatario verifica che tutti gli HTLC parziali in arrivo portino lo stesso payment_secret, confermando che appartengono allo stesso pagamento.

2. **Prevenire attacchi di riutilizzo del preimmagine.** Senza payment_secret, un nodo malevolo potrebbe intercettare un hash di pagamento H(x) e creare una nuova fattura fingendosi il destinatario originale.

**Selezione del percorso per pagamenti parziali.** Ogni pagamento parziale viene instradato indipendentemente, potenzialmente attraverso nodi intermedi completamente diversi. L'algoritmo di pathfinding del mittente:

1. Determina l'importo totale da inviare e il numero di percorsi da utilizzare
2. Seleziona rotte che non si sovrappongono nei nodi intermedi (per evitare fallimenti correlati)
3. Alloca importi a ciascun percorso in base alla liquidità disponibile
4. Costruisce un pacchetto onion separato per ogni pagamento parziale

**MPP vs AMP (Atomic Multipath Payments).** MPP e AMP sono due approcci ai pagamenti multipath con diversi compromessi:

- **MPP (Base MPP).** Tutte le parti condividono un hash di pagamento. Il destinatario attende tutte le parti. Più semplice ma richiede che il destinatario conosca l'importo totale in anticipo.
- **AMP (Atomic Multipath Payments).** Ogni pagamento parziale ha il proprio preimmagine. Il destinatario ricostruisce la prova di pagamento combinando tutti i preimmagine. Vantaggio: non richiede che l'importo totale sia noto in anticipo.

**Il ruolo degli onion in MPP.** Ogni pagamento parziale viaggia nel proprio pacchetto onion cifrato. Il mittente costruisce N onion separati (uno per percorso), ciascuno contenente l'importo parziale e il `payment_secret` nel payload per il destinatario finale. I nodi intermedi non possono distinguere un pagamento parziale MPP da un pagamento normale.

![Confronto MPP vs percorso singolo](media/wiki/multipath-payments/mpp-vs-single.svg "In alto: un pagamento a percorso singolo fallisce quando Bob ha liquidità insufficiente. In basso: MPP suddivide il pagamento in tre percorsi; anche quando un percorso fallisce, gli altri riescono e la porzione fallita può essere ritentata.")

## advanced

**Il payment_secret in dettaglio.** Il campo `payment_secret` è un impegno crittografico che lega insieme tutti i pagamenti parziali di un insieme MPP. Quando viene generata una fattura, il destinatario crea un `payment_secret` casuale e lo memorizza. Per ogni HTLC in entrata, il destinatario verifica:

- Il payload onion dell'HTLC contiene un `payment_secret`
- Il `payment_secret` corrisponde a quello della fattura
- L'importo accumulato per quel `payment_secret` non supera l'importo della fattura

**Onion routing con MPP.** Ogni pagamento parziale riceve il proprio pacchetto onion completo, costruito esattamente come un pagamento a percorso singolo. Il mittente costruisce un payload cifrato separato per ogni hop su ogni percorso. Gli unici dati specifici MPP si trovano nel payload dell'ultimo hop:

- `amt_to_forward`: l'importo parziale (non il totale)
- `outgoing_cltv_value`: il CLTV per questo pagamento parziale
- `payment_secret`: lega questo pagamento parziale all'insieme MPP

**Ottimizzazione del pathfinding per MPP.** L'algoritmo di pathfinding del mittente per MPP è più complesso che per pagamenti a percorso singolo:

1. **Dimensione massima di suddivisione.** Le implementazioni tipicamente limitano MPP a un numero massimo di pagamenti parziali (comunemente 5-10) per evitare commissioni di routing eccessive.
2. **Importo parziale minimo.** Pagamenti parziali molto piccoli sprecano commissioni. La maggior parte delle implementazioni imposta un minimo (es. 1.000 satoshi).
3. **Disgiunzione dei nodi.** Percorsi sovrapposti creano rischio di fallimento correlato.
4. **Suddivisione consapevole della liquidità.** Il mittente stima la liquidità disponibile sui canali candidati e dimensiona i pagamenti parziali di conseguenza.

**Implicazioni sulle commissioni.** Suddividere un pagamento aumenta le commissioni totali di routing perché sono coinvolti più hop. Tuttavia, l'importo per percorso è minore, il che può ridurre le commissioni proporzionali sui canali con commissioni elevate. L'effetto netto dipende dalla commissione base per HTLC, dal tasso di commissione di ciascun canale e dal numero di hop aggiuntivi.

**La prospettiva del destinatario.** Dal punto di vista del destinatario, MPP introduce diverse considerazioni:

1. **Accumulo di HTLC.** Il nodo del destinatario deve tracciare gli HTLC parziali in arrivo raggruppati per `payment_secret`.
2. **Gestione dei timeout.** Gli HTLC parziali hanno scadenze CLTV individuali.
3. **Recupero da fallimenti parziali.** Se alcune parti falliscono, il mittente può ritentare quegli importi specifici lungo percorsi diversi.

**AMP (Atomic Multipath Payments) in dettaglio.** AMP estende il concetto MPP dando a ogni pagamento parziale il proprio preimmagine:

1. Il mittente genera N preimmagini casuali: x₁, x₂, ..., xₙ
2. Ogni preimmagine ha il proprio hash: H(x₁), H(x₂), ..., H(xₙ)
3. Un "payment point" — un segreto di ricostruzione — viene suddiviso usando Shamir's Secret Sharing
4. Il destinatario riscuote ogni HTLC parziale indipendentemente usando il preimmagine corrispondente

**MPP nella pratica.** Le implementazioni reali dei nodi Lightning gestiscono MPP automaticamente:

- **LND.** MPP è abilitato per impostazione predefinita. LND sonda automaticamente i percorsi e suddivide i pagamenti che superano la capacità del percorso singolo.
- **CLN (Core Lightning).** Supporta Base MPP con comportamento di suddivisione configurabile.
- **Eclair (Scala).** Supporta MPP con suddivisione dinamica controllata dal flag `multipart`.

**MPP e liquidità.** MPP migliora fondamentalmente il modo in cui la Lightning Network utilizza la liquidità disponibile. La capacità di pagamento effettiva della rete scala con la somma di tutte le capacità dei canali nel grafo di routing, non solo con il percorso individuale più grande.

**Considerazioni sul scaling.** Man mano che la Lightning Network cresce, MPP diventa sempre più importante per due ragioni:

1. La maggior parte dei canali sulla rete è inferiore a 0,1 BTC. I pagamenti grandi (>0,01 BTC) sono quasi impossibili da instradare attraverso un singolo percorso.
2. La suddivisione in molte piccole parti rende le tecniche di analisi statistica significativamente più difficili.

Il compromesso è un aumento del numero di HTLC sulla rete. Le implementazioni bilanciano la probabilità di successo rispetto all'overhead degli HTLC quando decidono quante suddivisioni utilizzare.
