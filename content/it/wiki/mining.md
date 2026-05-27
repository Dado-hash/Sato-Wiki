---
id: wiki.mining
slug: mining
language: it
category: protocol
title: Mining
description: Il processo di trovare blocchi validi tramite proof of work, assemblando blocchi candidati e coordinando la potenza di hash attraverso la rete.
coverImage: media/wiki/mining/mining-hero.svg
difficulty: advanced
readTimeMinutes: 10
tags:
  - Mining
  - Proof of Work
  - ASIC
  - Mining Pool
  - Consenso
related:
  - wiki.proof-of-work
  - wiki.blocks
  - wiki.sha-256
  - wiki.difficulty-adjustment
  - wiki.transactions
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: Bitcoin Developer Reference - Block Chain
    url: https://developer.bitcoin.org/reference/block_chain.html
    author: Bitcoin.org contributors
  - title: Bitcoin Core miner implementation
    url: https://github.com/bitcoin/bitcoin/blob/master/src/miner.cpp
    author: Bitcoin Core contributors
  - title: Stratum V2 Protocol Specification
    url: https://stratumprotocol.org/
    author: Braiins & Block
    publishedAt: 2022-06-01
updatedAt: 2026-05-27T00:00:00Z
---

## base

Il mining è il processo con cui nuovi blocchi vengono aggiunti alla blockchain di Bitcoin. I miner raccolgono le transazioni non confermate dal loro mempool, le assemblano in un blocco candidato e cercano una soluzione valida di proof of work. Il primo miner che trova un nonce valido trasmette il blocco completato alla rete, riscuote la ricompresa di blocco e le commissioni delle transazioni, e la rete continua a costruire sopra quel blocco.

![Schema delle operazioni di mining](media/wiki/mining/mining-operations.svg "I miner selezionano le transazioni dal mempool e assemblano blocchi candidati per la gara di proof of work.")

Ogni miner compete in una gara probabilistica: più tentativi di hash al secondo, maggiore la probabilità di trovare un blocco valido. Trovare un blocco non è mai garantito; è un processo casuale in cui ogni tentativo ha una probabilità di successo uguale e indipendente.

I miner possono lavorare da soli (solo mining) o combinare la loro potenza di hash tramite un pool di mining. In un pool, i miner condividono il lavoro e suddividono le ricompense proporzionalmente. I pool forniscono un reddito più prevedibile, specialmente per i miner con potenza di hash modesta.

## medium

I miner non costruiscono un blocco da zero a ogni tentativo. Costruiscono un template di blocco dal loro mempool locale, selezionando le transazioni in base al fee rate (satoshis per vbyte). Le transazioni con commissioni più alte vengono incluse per prime, fino al limite di dimensione o peso del blocco. Il template viene ricostruito periodicamente man mano che arrivano nuove transazioni o quelle esistenti scadono.

La prima transazione di ogni blocco è la transazione coinbase, creata dal miner. Questa raccoglie la ricompensa di blocco (6,25 BTC a partire dall'halving del 2024, dimezzamento ogni 210.000 blocchi) più tutte le commissioni delle transazioni incluse. La coinbase contiene anche l'impegno witness del miner (per la validazione SegWit) e opzionalmente un campo extranonce che offre al miner maggiore spazio di ricerca.

L'header del blocco è composto da sei campi:

- **version**: indica quali regole del blocco vengono seguite
- **previous block hash**: collega il blocco al suo parent
- **Merkle root**: un impegno verso ogni transazione nel blocco
- **timestamp**: l'ora locale del miner (soggetto a una finestra di validità)
- **nBits**: la rappresentazione compatta del target di difficoltà corrente
- **nonce**: un campo di 4 byte che il miner incrementa a ogni tentativo

Il miner calcola un doppio SHA-256 dell'header da 80 byte. Se l'hash è inferiore al target codificato in nBits, il blocco è valido. Altrimenti, il miner cambia nonce, timestamp o dati della coinbase e riprova.

Poiché il nonce è solo di 4 byte (2^32 valori possibili), un singolo miner può esaurirlo rapidamente. I moderni ASIC usano due tecniche aggiuntive per estendere lo spazio di ricerca:

1. **Coinbase extranonce**: il miner varia dati extra all'interno della transazione coinbase, cambiando la Merkle root e quindi l'hash dell'header.
2. **Timestamp rolling**: il miner incrementa il timestamp entro una finestra valida per produrre un header diverso.

Queste tecniche permettono al miner di provare trilioni di hash senza ricostruire il template del blocco.

L'hash viene calcolato solo sull'header del blocco, non sull'intero blocco. Questo è fondamentale per l'efficienza: l'header è di 80 byte contro un blocco che può essere di diversi megabyte. La Merkle root impegna l'intera lista di transazioni, quindi qualsiasi modifica a una transazione cambia l'hash dell'header.

### Pool di Mining

La maggior parte dei miner partecipa a un pool di mining per stabilizzare il proprio reddito. Il pool gestisce un server che distribuisce lavoro (jobs) ai miner collegati. Ogni miner riceve un template di blocco con una coinbase unica che identifica il suo contributo.

I miner inviano shares — header il cui hash è inferiore a un target definito dal pool (più facile del target di rete) ma non necessariamente valido per la rete. Le shares dimostrano che il miner stava lavorando sul template del pool. Quando un miner nel pool trova un blocco valido per la rete, il pool distribuisce la ricompensa tra i contributori in base al numero e alla difficoltà delle shares inviate.

Il solo mining è ancora possibile ma poco pratico per tutti tranne che per le operazioni più grandi. La varianza è estrema: un miner solitario con l'1% dell'hashrate di rete troverebbe un blocco in media ogni 16 ore, ma potrebbe facilmente aspettare giorni o settimane tra un blocco e l'altro.

## advanced

### Architettura ASIC

Il mining Bitcoin ha attraversato tre ere hardware:

- **CPU (2009–2010)**: processori generici, chiunque con un computer poteva minare
- **GPU (2010–2013)**: schede grafiche con miglioramento di 10–100x grazie al calcolo parallelo
- **ASIC (2013–presente)**: circuiti integrati specifici progettati solo per il doppio SHA-256

Un ASIC miner è composto da hash board popolate di chip personalizzati, ciascuno contenente centinaia di pipeline SHA-256 in parallelo. Un ASIC moderno (es. Antminer S21, serie MicroBT M60) opera a 100–300 TH/s con efficienza energetica inferiore a 20 J/TH. I chip sono progettati per il massimo hash rate per watt, usando logica a basso voltaggio e datapath strettamente pipeline.

Il passaggio da hardware generico agli ASIC ha sollevato preoccupazioni di centralizzazione del mining. La produzione di ASIC è concentrata tra poche aziende (Bitmain, MicroBT, Canaan), e il capitale iniziale richiesto per il mining su larga scala favorisce le operazioni industriali rispetto agli hobbisti.

### Difficoltà e Tempo Atteso di Blocco

Il mining è un processo di Bernoulli ripetuto all'hashrate del miner. Con difficoltà di rete $D$ e hashrate $H$, il tempo atteso per trovare un blocco è:

$$T = \frac{D \cdot 2^{32}}{H}$$

Il numero di blocchi trovati in un intervallo di tempo segue una distribuzione di Poisson. La probabilità di trovare esattamente $k$ blocchi nel tempo $t$ con tempo atteso $\lambda$ è:

$$P(k, t) = \frac{(\lambda t)^k e^{-\lambda t}}{k!}$$

L'hashrate di rete è stimato dall'intervallo di blocco osservato e dalla difficoltà corrente. Se i blocchi arrivano con intervallo medio $\bar{t}$, l'hashrate di rete $H_n$ è approssimativamente:

$$H_n \approx \frac{D \cdot 2^{32}}{\bar{t}}$$

### Schemi di Ricompensa dei Pool

Pool diversi usano metodi diversi per distribuire le ricompense:

- **Pay Per Share (PPS)**: i miner vengono pagati un importo fisso per ogni share, indipendentemente dal fatto che il pool trovi un blocco. Il pool si assume il rischio di varianza e applica una commissione più alta (tipicamente 2–4%).
- **Pay Per Last N Shares (PPLNS)**: solo le shares di una finestra mobile delle ultime $N$ shares vengono ricompensate quando viene trovato un blocco. Questo scoraggia il pool hopping e allinea gli incentivi del miner con quelli del pool.
- **Full Pay Per Share (FPPS)**: detto anche PPS+, paga sia la ricompensa di blocco sia una stima delle commissioni di transazione per ogni share. È lo schema più comune tra i grandi pool a partire dal 2024–2026.

Il pool deduce anche una commissione (0–4%) per coprire i costi operativi e il profitto.

### Protocollo Stratum

Il protocollo Stratum (V1 e V2) è lo standard per la comunicazione tra pool e miner. Il server del pool invia job contenenti:

- Il prefisso dell'header del blocco (version, prev hash, Merkle root fino alla posizione della coinbase)
- Il prefisso e suffisso della coinbase (il miner riempie l'extranonce in mezzo)
- Il target di difficoltà di rete (nBits) e un target di difficoltà share assegnato dal pool
- Un ID job per il tracciamento dei risultati

Il miner calcola gli hash degli header derivati da ogni job, variando nonce ed extranonce. Quando un hash soddisfa il target share, il miner invia la share (l'header e l'extranonce della coinbase) al pool. Quando un hash soddisfa il target di rete, il miner ha trovato un blocco valido — il pool lo trasmette e riscuote la ricompensa.

Stratum V2 aggiunge crittografia, migliore efficienza tramite job negoziati, e permette ai miner di contribuire alla costruzione del template del blocco, affrontando parzialmente le preoccupazioni di centralizzazione.

### Hashrate e Sicurezza

L'hashrate di rete è la somma di tutta la potenza di hash rivolta alla rete Bitcoin. Non è direttamente osservabile; viene inferito dalla difficoltà e dagli intervalli di blocco. Il modello di sicurezza presuppone che più del 50% dell'hashrate sia onesto. Un attaccante con la maggioranza dell'hashrate potrebbe riorganizzare blocchi recenti (attacco del 51%), spendere due volte le transazioni o censurare blocchi.

La teoria dei giochi del mining crea un forte incentivo all'onestà: costruire su blocchi validi frutta la ricompensa di blocco, mentre tentare di riorganizzare blocchi confermati rischia di sprecare potenza di hash su un ramo che non sarà accettato dalla rete.

### Preoccupazioni di Centralizzazione

Esistono due principali vettori di centralizzazione nel mining Bitcoin:

1. **Produzione di ASIC**: tre aziende controllano la stragrande maggioranza della produzione di ASIC. Le limitazioni della catena di fornitura, la concentrazione geografica e l'alto costo della fabbricazione dei chip creano barriere all'ingresso.

2. **Dominanza dei pool**: a partire dal 2026, i primi tre pool di mining spesso controllano più del 50% dell'hashrate di rete. Sebbene i miner possano cambiare pool liberamente, l'operatore del pool decide quali transazioni includere e ha teoricamente il potere di censurare o riorganizzare.

Le soluzioni in fase di esplorazione includono Stratum V2 (che dà ai miner un certo controllo sulla costruzione del template), una migliore diversità dei pool attraverso schemi di pagamento migliori e la diversificazione geografica delle operazioni di mining guidata dai mercati energetici economici in tutto il mondo.
