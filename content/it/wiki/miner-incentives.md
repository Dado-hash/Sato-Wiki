---
id: wiki.miner-incentives
slug: miner-incentives
language: it
category: economics
title: Incentivi ai Miner
description: Le ricompense economiche — block subsidy e commissioni di transazione — che motivano i miner a proteggere la rete attraverso la partecipazione onesta.
coverImage: media/wiki/miner-incentives/miner-incentives-hero.svg
difficulty: base
readTimeMinutes: 7
tags:
  - Economia
  - Mining
  - Incentivi
  - Sicurezza
related:
  - wiki.block-subsidy
  - wiki.fee-market
  - wiki.halving
  - wiki.game-theory
  - wiki.proof-of-work
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: Mastering Bitcoin - Capitolo 8
    url: https://github.com/bitcoinbook/bitcoinbook/blob/develop/ch08.asciidoc
    author: Andreas M. Antonopoulos
  - title: Bitcoin e la Fallacia dell'Economista
    url: https://medium.com/@nic__carter/bitcoin-and-the-economists-fallacy-4f087d3d7ad2
    author: Nic Carter
updatedAt: 2026-05-28T00:00:00Z
---

## base

I miner sono i partecipanti che creano nuovi blocchi sulla rete Bitcoin. Sono motivati da ricompense economiche — in particolare, la possibilità di guadagnare bitcoin trovando un blocco valido. Questo è l'incentivo che fa funzionare l'intero sistema.

Quando un miner aggiunge con successo un blocco alla blockchain, riceve due tipi di compensazione:

1. **Block subsidy**: Una quantità fissa di bitcoin appena creati. Dal 2024, è di 3,125 BTC per blocco.
2. **Commissioni di transazione**: Le fee allegate alle transazioni incluse nel blocco.

La ricompensa totale — subsidy più commissioni — viene raccolta attraverso la transazione coinbase, che è la prima transazione in ogni blocco.

![Fonti di ricavo dei miner](media/wiki/miner-incentives/miner-incentives-hero.svg "I miner guadagnano da due fonti: il block subsidy (nuovi bitcoin) e le commissioni di transazione pagate dagli utenti.")

Il mining è competitivo. Più potenza di calcolo ha un miner, maggiore è la sua probabilità di trovare il prossimo blocco. Questa competizione costringe i miner a operare in modo efficiente — spendendo il meno possibile in elettricità e hardware — per rimanere redditizi.

Il punto chiave è che i miner sono motivati finanziariamente a seguire le regole. Un miner che tenta di includere transazioni non valide o violare le regole di consenso vedrà il proprio blocco rifiutato dai full node, sprecando elettricità e sforzo. Il mining onesto è la strategia più redditizia.

## medium

La struttura degli incentivi di Bitcoin è progettata per allineare l'interesse personale dei miner con la sicurezza della rete. Ci sono due flussi di entrata distinti, con proprietà diverse.

**Il block subsidy** è l'incentivo primario nei primi decenni di Bitcoin. È prevedibile, noto con decenni di anticipo, e diminuisce nel tempo attraverso il meccanismo dell'halving. Nel 2009, il subsidy era di 50 BTC per blocco, creando forti incentivi per i primi miner. Entro il 2024, il subsidy era sceso a 3,125 BTC.

**Le commissioni di transazione** sono l'incentivo secondario che diventa sempre più importante man mano che il subsidy diminuisce. Le fee sono stabilite dagli utenti che competono per lo spazio nei blocchi. Quando il mempool è congestionato, gli utenti offrono commissioni più alte, aumentando le entrate dei miner. Quando il mempool è vuoto, le fee scendono quasi a zero.

Le entrate giornaliere totali dei miner possono essere calcolate come:
```
Entrate giornaliere = (subsidy + fee_medie_per_blocco) × 144 blocchi al giorno
```

Con un subsidy di 3,125 BTC e una media di 0,5 BTC di fee per blocco (condizioni congestionate), le entrate giornaliere sono circa 522 BTC. A un prezzo di $60.000, siamo a circa $31 milioni al giorno di compensazione totale per i miner.

Gli incentivi ai miner creano un ciclo di feedback positivo per la sicurezza:

1. Prezzo del bitcoin più alto → il mining diventa più redditizio
2. Mining più redditizio → più miner si uniscono
3. Più miner → hash rate più alto
4. Hash rate più alto → rete più sicura
5. Rete più sicura → più fiducia degli utenti → prezzo del bitcoin più alto

Questo ciclo non è garantito, ma ha operato per gran parte della storia di Bitcoin. Crea una relazione auto-rinforzante tra prezzo, sicurezza e adozione.

Criticamente, i miner hanno costi irrecuperabili in hardware e impianti. Una volta acquistato e installato un ASIC, l'operatore deve fare mining per recuperare l'investimento. Questo crea un impegno a lungo termine verso la rete che allinea gli interessi dei miner con il successo di Bitcoin.

## advanced

La teoria dei giochi degli incentivi ai miner è più sfumata della semplice massimizzazione del profitto. Diversi fattori strategici influenzano il comportamento dei miner:

**Massimizzazione delle entrate vs sabotaggio.** Un miner con una percentuale significativa di hash rate potrebbe in teoria tentare di perturbare la rete (ad esempio minando blocchi vuoti o eseguendo un attacco del 51% per double-spend). Tuttavia, tali attacchi sono autolimitanti: un attacco riuscito distruggerebbe la fiducia degli utenti, farebbe crollare il prezzo e svaluterebbe le proprie attrezzature di mining e le proprie riserve di bitcoin. I miner razionali hanno quindi un interesse finanziario nel preservare l'integrità della rete.

**Orfanizzazione e gare di propagazione.** I miner devono decidere quali transazioni includere e quanto velocemente propagare i blocchi. Includere troppe transazioni a bassa fee rende un blocco più grande e più lento da propagare, aumentando il rischio di orfanizzazione. I miner bilanciano le entrate da fee contro il costo atteso delle gare di orfanizzazione, ottimizzando tipicamente per il fee rate piuttosto che per la fee totale.

**La funzione di ricompensa del mining** in Bitcoin è un processo di Poisson senza memoria: ogni tentativo di hash ha una probabilità indipendente uguale di successo. Ciò significa che le entrate attese sono proporzionali alla quota di hash rate totale. Un miner che controlla l'1% dell'hash rate globale si aspetta di trovare circa l'1% dei blocchi.

Il valore atteso del mining può essere espresso come:
```
E[entrate] = (hash_rate / hash_rate_totale) × (subsidy + fee_medie) × blocchi_al_giorno × prezzo_BTC
```

**La tragedia dei commons nel mining.** I singoli miner hanno un incentivo ad aumentare il proprio hash rate per catturare una quota maggiore delle ricompense. Ma quando tutti i miner fanno lo stesso, la difficoltà si aggiusta verso l'alto e la quota di ciascuno rimane più o meno la stessa — mentre i costi energetici di tutti aumentano. Questa è una classica dinamica di corsa agli armamenti.

**Incentivi forward-looking.** Il programma degli halving significa che i miner razionali devono pianificare un declino delle entrate da subsidy. Questo crea pressione per:
- Investimenti in tecnologia ASIC più efficiente
- Rilocalizzazione in regioni con elettricità più economica
- Integrazione verticale con la produzione di energia
- Ottimizzazione delle entrate da fee attraverso la selezione delle transazioni

**La questione del security budget.** Un importante dibattito nell'economia di Bitcoin riguarda se le entrate da commissioni possano da sole sostenere la sicurezza del mining dopo che i subsidy diventano trascurabili. Alcuni sostengono che le soluzioni di Layer 2 (Lightning Network) e il valore della finalità di regolamento genereranno una domanda sufficiente di fee. Altri temono che budget di sicurezza in declino potrebbero rendere gli attacchi economicamente vantaggiosi.
