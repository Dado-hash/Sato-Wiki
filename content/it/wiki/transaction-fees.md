---
id: wiki.transaction-fees
slug: transaction-fees
language: it
category: protocol
title: Commissioni di Transazione
description: La differenza tra input e output che compensa i miner per la sicurezza della rete, formando un mercato competitivo per lo spazio nei blocchi.
coverImage: media/wiki/transaction-fees/fees-hero.svg
difficulty: advanced
readTimeMinutes: 10
tags:
  - Commissioni
  - Mempool
  - Mining
  - Economia
  - SegWit
related:
  - wiki.transactions
  - wiki.mempool
  - wiki.blocks
  - wiki.proof-of-work
  - wiki.utxo-model
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: Bitcoin Developer Guide - Transaction Fees
    url: https://developer.bitcoin.org/devguide/transactions.html#transaction-fees
    author: Bitcoin.org contributors
  - title: BIP 125 - Opt-In Full Replace-by-Fee
    url: https://github.com/bitcoin/bips/blob/master/bip-0125.mediawiki
    author: David A. Harding, Peter Todd
  - title: Fee Estimation in Bitcoin Core
    url: https://bitcoincore.org/en/2017/01/24/zero-confirmation-transaction-fee-estimation/
    author: Alex Morcos
updatedAt: 2026-05-27T00:00:00Z
---

## base

Una commissione di transazione è la differenza tra il valore totale degli input di una transazione e il valore totale dei suoi output. Questa differenza non è scritta da nessuna parte nella transazione stessa: sono i nodi a calcolarla al volo. La commissione spetta al miner che include la transazione in un blocco.

Le commissioni hanno due scopi. Compensano i miner per il lavoro di validazione e l'energia spesa per proteggere la rete, e impediscono agli attaccanti di inondare la rete con transazioni gratuite. Ogni transazione deve pagare almeno una commissione minima per essere inoltrata dai nodi.

![Commissione come differenza tra input e output](media/wiki/transaction-fees/fees-hero.svg "Una transazione con tre input per un totale di 200.000 sat fornisce 190.000 sat agli output. La differenza di 10.000 sat è la commissione per il miner.")

Le commissioni si misurano in satoshi per byte virtuale, scritte come sat/vB. Questo tasso — non la commissione assoluta — determina la velocità con cui una transazione viene confermata. Una transazione che paga 1.000 sat totali ma occupa 200 vbyte ha un tasso di 5 sat/vB. Una transazione che paga 500 sat ma occupa solo 50 vbyte ha un tasso di 10 sat/vB e sarà probabilmente confermata prima.

I wallet stimano il tasso giusto in base alle condizioni correnti della rete. Nei periodi tranquilli basta un tasso basso. Quando molte persone inviano transazioni, il mempool si riempie e diventano necessari tassi più alti.

## medium

La commissione si calcola come `commissione = somma(input) - somma(output)`. Se una transazione spende output per 1.000.000 sat e crea nuovi output per 995.000 sat, la commissione è 5.000 sat. Non esiste un campo esplicito per la commissione: è implicita per progetto.

Ciò che conta per la velocità di conferma è il tasso, non la commissione assoluta. Il tasso è la commissione divisa per il peso della transazione in byte virtuali. I byte virtuali normalizzano il costo di diversi tipi di transazione. Una transazione legacy con 1.400 byte di dati grezzi contribuisce 1.400 vbyte. Una transazione SegWit dello stesso formato grezzo può contribuire meno vbyte perché i dati SegWit sono scontati di un fattore quattro. Questo significa che le transazioni SegWit sono più economiche da includere rispetto a transazioni legacy con lo stesso schema di spesa, riflettendo l'incentivo del protocollo ad adottare SegWit.

Il mempool è un mercato di commissioni. I nodi tengono le transazioni non confermate nel loro mempool e le inoltrano ai pari. I miner (o pool di mining) selezionano le transazioni dal loro mempool per costruire un blocco candidato. La strategia di selezione greedy è semplice: ordinare per tasso decrescente e scegliere prima le transazioni che pagano di più. Una transazione che offre 50 sat/vB sarà selezionata prima di una che offre 10 sat/vB, indipendentemente dalla commissione assoluta.

La stima delle commissioni è il compito critico del wallet. Bitcoin Core fornisce `estimatesmartfee` che restituisce il tasso necessario per un dato obiettivo di conferma (es. 2 blocchi, 6 blocchi, 25 blocchi). I wallet interrogano regolarmente questa funzione e aggiustano il tasso in base alla pressione del mempool. Impostare un tasso troppo basso rischia ore o giorni di attesa; impostarlo troppo alto significa pagare più del necessario.

Con il dimezzamento del sussidio di blocco ogni quattro anni, le commissioni diventano proporzionalmente più importanti per il ricavo dei miner. All'attuale sussidio di 3,125 BTC per blocco più le commissioni, queste ultime costituiscono una frazione significativa della ricompensa totale. Nei decenni futuri, dopo molti dimezzamenti, il sussidio si avvicinerà a zero e i miner dipenderanno quasi interamente dalle commissioni. Il budget di sicurezza deve transitare da basato sull'inflazione a basato sulle commissioni senza compromettere l'integrità della rete.

![Offerta e domanda di spazio nei blocchi](media/wiki/transaction-fees/fee-market.svg "Il mercato delle commissioni: le transazioni competono per lo spazio limitato nei blocchi. Solo quelle con il tasso più alto entrano in ogni blocco.")

## advanced

Il mercato delle commissioni è un'asta continua per lo spazio nei blocchi. Ogni blocco fornisce circa 1 milione di byte virtuali per le transazioni. Quando la domanda totale (la somma dei vbyte di tutte le transazioni candidate) supera l'offerta, il mercato si regola per tasso: le transazioni con il tasso più alto vengono incluse, le altre aspettano.

Il mempool non è una coda globale unica. Ogni nodo completo mantiene il proprio mempool, anche se in pratica convergono su contenuti simili. Le transazioni vengono accettate nel mempool solo se soddisfano le regole di policy: il tasso deve superare la commissione minima di relay (1 sat/vB di default), la transazione deve essere standard (solo tipi di script standard), e la dimensione totale del mempool non deve superare il limite configurato dal nodo (default 300 MB di memoria). Quando il mempool è pieno, il nodo espelle le transazioni con il tasso più basso, partendo dal fondo. Questa politica di espulsione crea un pavimento naturale del mempool durante la congestione.

**Fee bumping** permette a un mittente di aumentare il tasso di una transazione dopo che è stata trasmessa ma prima che sia confermata. Esistono tre meccanismi:

- **Replace-by-Fee (RBF)**: definito in BIP-125, l'RBF permette a un mittente di trasmettere una nuova versione di una transazione che paga un tasso più alto, sostituendo l'originale. La sostituzione deve pagare una commissione più alta dell'originale e soddisfare diverse regole anti-abuso (es. la sostituzione non deve invalidare discendenti non confermati dell'originale). L'opt-in RBF segnala una transazione come sostituibile tramite il numero di sequence; l'full-RBF considera sostituibile qualsiasi transazione.

- **Child Pays for Parent (CPFP)**: il destinatario di una transazione non confermata può spendere il suo output in una transazione figlia con un tasso alto. I miner che vedono padre e figlia insieme includeranno entrambi se il tasso combinato è competitivo. CPFP non richiede la cooperazione del mittente originale.

- **Package relay** (recentemente distribuito in Bitcoin Core): permette a un nodo di annunciare e inoltrare un pacchetto di più transazioni correlate come unità, migliorando la propagazione CPFP.

Gli output dust si intersecano con le commissioni in modo sottile. Un output dust è talmente piccolo che spenderlo costerebbe più in commissioni del valore dell'output stesso. I nodi rifiutano di inoltrare transazioni che producono output dust (la soglia varia per tipo di output). Questo impedisce a transazioni economicamente irrazionali di occupare spazio nei blocchi.

L'assemblaggio dei blocchi di mining è più sofisticato di un semplice ordinamento greedy per tasso. I miner usano la selezione consapevole dell'antenato-feerate: la priorità effettiva di una transazione include i suoi antenati non confermati. Se una transazione a basso tasso ha un discendente ad alto tasso, la coppia può essere selezionata insieme anche se il padre da solo non lo sarebbe. Questa selezione consapevole degli antenati tiene conto delle dinamiche CPFP e produce template di blocco migliori.

La transazione coinbase raccoglie tutte le commissioni dalle transazioni incluse. La somma di tutte le commissioni più il sussidio di blocco diventa la ricompensa del miner. I miner possono anche includere i propri output coinbase prima di tutte le altre transazioni.

Guardando al futuro, un modello di sicurezza basato puramente sulle commissioni solleva domande aperte. Se le commissioni dovessero calare dopo l'era del sussidio, un attacco di simulazione senza costo o una riorganizzazione persistente diventerebbero fattibili? La ricerca attuale suggerisce che se le commissioni sono troppo basse, l'equilibrio potrebbe spostarsi verso un tasso di orfani più alto o una centralizzazione del mining. Garantire un mercato delle commissioni robusto potrebbe richiedere traffico di secondo livello (Lightning Network e altri protocolli) per creare domanda continua di spazio nei blocchi, anche quando la domanda transazionale di primo livello è bassa.

La distribuzione delle commissioni in un mempool sano mostra una lunga coda: migliaia di transazioni a tassi bassi e un forte calo al tasso minimo di inclusione corrente. Osservare questa distribuzione in tempo reale aiuta a stimare il tasso ottimale e a prevedere quando la congestione si ridurrà.
