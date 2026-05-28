---
id: wiki.routing-fees
slug: routing-fees
language: it
category: lightning network
title: Commissioni di Routing
description: I costi applicati dai nodi intermedi della Lightning Network per l'inoltro dei pagamenti, composti da una commissione di base e una commissione proporzionale per HTLC.
coverImage: media/wiki/routing-fees/fee-breakdown.svg
difficulty: advanced
readTimeMinutes: 8
tags:
  - Lightning Network
  - Commissioni di Routing
  - Economia
  - Gestione del Nodo
related:
  - wiki.lightning-network
  - wiki.channel-liquidity
  - wiki.onion-routing
  - wiki.payment-channels
  - wiki.lightning-invoices
sources:
  - title: "BOLT #7 — P2P Node and Channel Discovery"
    url: https://github.com/lightning/bolts/blob/master/07-routing-gossip.md
    author: Lightning Network Specifications
  - title: "Mastering the Lightning Network — Chapter 11: Pathfinding"
    url: https://github.com/lnbook/lnbook
    author: Andreas M. Antonopoulos, Olaoluwa Osuntokun, Rene Pickhardt
  - title: "Pickhardt Payments — Fee-Aware Pathfinding"
    url: https://arxiv.org/abs/2107.05322
    author: Rene Pickhardt, Stefan Richter
    publishedAt: 2021-07-12
updatedAt: 2026-05-27T00:00:00Z
---

## base

**Cosa sono le commissioni di routing?** Quando un pagamento attraversa la Lightning Network, non viaggia direttamente dal mittente al destinatario — passa attraverso molteplici nodi intermedi. Ogni nodo che inoltra il pagamento applica una piccola commissione per il suo servizio.

**Due componenti.** Ogni commissione di routing è composta da due parti:
- **Commissione di base** (*fee_base_msat*): un importo fisso in millisatoshi applicato per ogni pagamento inoltrato, indipendentemente dal suo valore.
- **Commissione proporzionale** (*fee_proportional_millionths*): un importo variabile proporzionale al valore del pagamento, espresso in parti per milione (ppm).

Il mittente paga le commissioni cumulative di tutti i salti. Il destinatario riceve l'importo totale del pagamento meno le commissioni dedotte lungo il percorso.

**Perché esistono le commissioni.** I nodi di routing forniscono infrastruttura essenziale — bloccano liquidità nei canali, si assumono il rischio degli HTLC (congelamento temporaneo dei fondi durante l'inoltro) e mantengono una connettività costante. Le commissioni compensano questi costi e rischi.

**Analogia.** Pensa alle commissioni di routing come ai pedaggi autostradali. Ogni segmento tra due uscite ha il proprio pedaggio. Paghi a ogni casello e il pedaggio totale è la somma di tutti i segmenti. Un percorso più lungo con più salti significa più commissioni, proprio come un viaggio più lungo con più caselli costa di più.

![Accumulo delle Commissioni di Routing](media/wiki/routing-fees/fee-breakdown.svg "Un pagamento a 3 salti da Alice a Diana: Bob e Carol applicano ciascuno una commissione di base e una proporzionale, riducendo l'importo inoltrato a ogni passo.")

## medium

**Commissione di base in dettaglio.** La commissione di base (*fee_base_msat*) è un addebito fisso per ogni HTLC inoltrato, tipicamente compreso tra 1 e 1.000 millisatoshi (0,001–1 satoshi). Compensa il nodo per i costi operativi dell'inoltro: elaborazione dell'HTLC, gestione dello stato del canale e assunzione del rischio di controparte che l'HTLC debba essere risolto on-chain. La commissione di base è più rilevante per i pagamenti piccoli — può rappresentare una percentuale significativa per un pagamento da 1.000 satoshi ma è trascurabile per uno da 1.000.000 di satoshi.

**Commissione proporzionale in dettaglio.** La commissione proporzionale (*fee_proportional_millionths*) è espressa in parti per milione (ppm). Per esempio, 100 ppm significa lo 0,01% dell'importo inoltrato. I valori tipici vanno da 1 ppm (0,0001%) a 1.000 ppm (0,1%). La commissione proporzionale scala con la dimensione del pagamento, diventando il costo dominante per i pagamenti grandi.

**Calcolo della commissione.** La commissione per un singolo salto è:

```
commissione = fee_base_msat + (importo_msat × fee_proportional_millionths / 1.000.000)
```

Per un pagamento di 100.000 satoshi attraverso un nodo che addebita 10 msat di base e 100 ppm:
```
commissione = 10 + (100.000.000 × 100 / 1.000.000)
commissione = 10 + 10.000 = 10.010 msat = 10,01 satoshi
```

**Offuscamento delle commissioni nell'onion.** Il protocollo di onion routing garantisce che nessun nodo intermedio conosca l'intero percorso o la commissione totale. Ogni nodo vede solo l'HTLC che deve inoltrare e la commissione che guadagnerà. Il mittente costruisce payload crittografati annidati, con le istruzioni di ogni salto sigillate all'interno di strati che solo quel salto può decrittare. Questo preserva la privacy — Bob non sa se Alice è il mittente originale né se Carol è il destinatario finale.

**Impatto sul pathfinding.** Gli algoritmi di pathfinding come l'algoritmo di Dijkstra trattano la commissione totale come un peso degli archi e cercano il percorso a costo minimo dal mittente al destinatario. I nodi con commissioni alte vengono deprioritizzati; i nodi con commissioni basse attraggono più traffico di routing. Il nodo che esegue il pathfinding calcola la commissione cumulativa attraverso i percorsi candidati e seleziona il più economico. Questo crea un mercato competitivo in cui i nodi devono impostare le commissioni strategicamente per attrarre flusso.

**Aggiornamento delle commissioni.** I nodi modificano le commissioni dinamicamente tramite messaggi gossip `channel_update`. Gli operatori aggiustano le commissioni in base a:
- Bilanciamento della liquidità del canale (aumentando le commissioni quando la liquidità in uscita è scarsa)
- Congestione della rete (aumentando le commissioni in periodi di alta domanda)
- Posizionamento competitivo (riducendo le commissioni per attrarre volume di routing)
- Costi operativi (uptime del server, costi di ribilanciamento)

![Strategie di Commissione di Routing](media/wiki/routing-fees/fee-strategies.svg "Un confronto tra strategie di commissione economica, bilanciata e premium che mostra il compromesso tra volume e guadagno per pagamento.")

## advanced

**Il dilemma del nodo.** Ogni nodo di routing affronta una scelta economica fondamentale: commissioni basse attirano alto volume di routing ma potrebbero non coprire i costi; commissioni alte generano più guadagno per pagamento ma respingono il traffico. Questo rispecchia il classico modello di competizione Bertrand in economia, dove i nodi si sottocotano a vicenda sul prezzo finché le commissioni si avvicinano al costo marginale. Tuttavia, la qualità eterogenea dei nodi di Lightning — differenze in affidabilità, profondità di liquidità e connettività dei canali — impedisce una corsa al ribasso pura.

**Costo opportunità della liquidità.** Il capitale bloccato nei canali Lightning potrebbe essere impiegato altrove (prestiti, trading, guadagni on-chain). Un operatore di nodo deve considerare questo costo opportunità quando imposta le commissioni. Per esempio, se 1 BTC bloccato in canali potesse guadagnare un 5% APR in DeFi, il costo opportunità mensile sarebbe di circa 4.167 satoshi. Se il nodo instrada 1.000 pagamenti al mese, ha bisogno di almeno ~4,2 satoshi per pagamento solo per pareggiare con l'uso alternativo del capitale.

**Costo del rischio HTLC.** Quando inoltra un HTLC, il nodo blocca temporaneamente i fondi per la durata del pagamento (tipicamente secondi o minuti, ma potenzialmente ore per pagamenti falliti o contestati). Durante questa finestra, la liquidità non è disponibile per altri routing. Se un canale viene chiuso forzatamente mentre un HTLC è in sospeso, risolverlo richiede transazioni on-chain, che aggiungono costo e complessità. La commissione di base compensa principalmente questo rischio specifico degli HTLC.

**Pickhardt payments e grafi di incertezza.** René Pickhardt e Stefan Richter hanno proposto un approccio al pathfinding sensibile alle commissioni utilizzando grafi di incertezza (2021). Invece di trattare la liquidità del canale come binaria (sufficiente / insufficiente), il modello assegna probabilità ai bilanci dei canali. L'algoritmo di pathfinding minimizza quindi una funzione di costo combinato che include sia le commissioni che la probabilità di fallimento del pagamento. Questo approccio riduce la necessità di tentativi di pagamento per prova ed errore e migliora i tassi di successo al primo tentativo. Il costo totale minimizzato è:

```
costo = commissioni_totali - λ × log(p_successo)
```

Dove λ è un parametro regolabile che bilancia la minimizzazione delle commissioni con la probabilità di successo.

**MPP e aritmetica delle commissioni.** I pagamenti multi-percorso (MPP) suddividono un pagamento attraverso più rotte, ciascuna con le proprie commissioni. La commissione totale è la somma delle commissioni su tutti i frammenti. L'MPP può talvolta ridurre le commissioni totali quando si può evitare un singolo salto costoso suddividendo il pagamento. Tuttavia, l'MPP aumenta anche il numero di HTLC in volo, potenzialmente aumentando i costi delle commissioni di base. La suddivisione ottimale dipende dalle strutture delle commissioni dei percorsi disponibili e dalla distribuzione della liquidità attraverso i canali.

**Discriminazione delle commissioni.** Sebbene la maggior parte dei nodi applichi commissioni uniformi a tutti i peer, nulla impedisce a un nodo di impostare commissioni diverse per canali diversi. Questa pratica, chiamata discriminazione delle commissioni, è rara perché aggiunge complessità operativa e riduce la prevedibilità della rete. In pratica, i nodi tipicamente impostano una singola politica di commissioni e la applicano a tutti i canali, o raggruppano i canali per allineamento di liquidità.

**Routing a commissione zero.** Alcuni nodi, particolarmente hub grandi e nodi ben capitalizzati, instradano pagamenti con commissioni zero o vicine allo zero. Questa è una strategia deliberata per avviare il volume di routing e stabilire una posizione centrale nel grafo della rete. Questi nodi tipicamente generano entrate attraverso altri mezzi (integrazione con exchange, operazioni di Lightning Service Provider) e trattano il routing come uno strumento di acquisizione o fidelizzazione dei clienti. Il routing a commissione zero è stato criticato per centralizzare la topologia della rete, ma abbassa anche la barriera d'ingresso per i nuovi utenti.

**Entrate da commissioni vs. costi di ribilanciamento.** I nodi di routing guadagnano commissioni sui pagamenti in uscita ma devono mantenere bilanciata la liquidità dei canali per continuare a instradare. Il ribilanciamento — spostare i fondi nei canali impoveriti — ha un costo (commissioni di transazione on-chain o ribilanciamento circolare attraverso la stessa Lightning Network). Il profitto netto di routing è:

```
profitto_netto = entrate_da_commissioni - costi_di_ribilanciamento - costi_operativi
```

Un nodo potrebbe guadagnare 10.000 satoshi in commissioni ma spenderne 3.000 per il ribilanciamento e 1.000 per l'infrastruttura del nodo, per un profitto netto di 6.000 satoshi. Molti nodi operano con margini ridotti o in perdita, trattando il routing come un bene pubblico o un investimento strategico.

**Stima delle commissioni nel pathfinding.** Le implementazioni moderne di Lightning utilizzano una stima sofisticata delle commissioni che considera non solo la politica dichiarata ma anche:
- Affidabilità storica del canale (uptime, tasso di inoltro riuscito)
- Età e profondità del canale
- Probabilità che il saldo in uscita di un canale possa effettivamente ospitare il pagamento
- Il sovrapprezzo di congestione (i nodi possono aumentare le commissioni durante i periodi di alto carico)

Questi fattori sono combinati in una stima di costo "canonica" che gli algoritmi di pathfinding utilizzano al posto dei valori grezzi delle commissioni.

**Canali Wumbo ed economia delle commissioni.** I canali grandi (oltre 0,167 BTC, il limite pre-Wumbo) cambiano significativamente l'economia delle commissioni. Un canale Wumbo può instradare molti pagamenti grandi senza ribilanciamento, riducendo i costi di ribilanciamento. Tuttavia, concentra anche il rischio di liquidità e aumenta il costo opportunità del capitale. Con la diffusione dei canali Wumbo, la componente proporzionale della commissione potrebbe diminuire (poiché il volume è maggiore) mentre la commissione di base potrebbe aumentare (poiché il rischio HTLC per canale è più grande).
