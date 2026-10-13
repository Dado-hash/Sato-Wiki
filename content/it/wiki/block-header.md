---
id: wiki.block-header
slug: block-header
language: it
category: protocol
title: Header del blocco
description: L'header di 80 byte che ogni blocco porta con sé, i suoi sei campi, il modo in cui il suo hash double SHA-256 viene confrontato con il target e perché il solo nonce non basta più.
difficulty: advanced
readTimeMinutes: 4
tags:
  - Header
  - Proof of Work
  - Difficoltà
  - Timestamp
related:
  - wiki.blocks
  - wiki.proof-of-work
  - wiki.difficulty-adjustment
  - wiki.merkle-trees
  - wiki.coinbase-transaction
  - wiki.mining
sources:
  - title: Bitcoin Developer Reference - Block Chain
    url: https://developer.bitcoin.org/reference/block_chain.html
    author: Bitcoin.org contributors
  - title: Bitcoin Wiki - Block hashing algorithm
    url: https://en.bitcoin.it/wiki/Block_hashing_algorithm
    author: Bitcoin Wiki contributors
  - title: Bitcoin Wiki - Difficulty
    url: https://en.bitcoin.it/wiki/Difficulty
    author: Bitcoin Wiki contributors
  - title: "BIP 113: Median time-past as endpoint for lock-time calculations"
    url: https://github.com/bitcoin/bips/blob/master/bip-0113.mediawiki
    author: Thomas Kerin
  - title: "BIP 320: nVersion bits for general purpose use"
    url: https://github.com/bitcoin/bips/blob/master/bip-0320.mediawiki
    author: BtcDrak
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

L'header del blocco è la parte del blocco su cui si calcola la proof of work. Misura sempre 80 byte e contiene sei campi: una version, l'hash dell'header del blocco precedente, la Merkle root delle transazioni del blocco, un timestamp, il target in forma compatta chiamata nBits e un nonce. Poiché l'header è così piccolo, un miner può provare molti hash candidati senza spostare i dati delle transazioni.

Il miner cambia il nonce e gli altri campi flessibili finché l'hash dell'header non scende sotto il target. I nodi non ripetono la ricerca. Calcolano l'hash dell'header una sola volta e lo confrontano con il target codificato in nBits. L'hash si ottiene applicando SHA-256 due volte, ed è per questo che si chiama double SHA-256.

L'header contiene anche i collegamenti che rendono la chain difficile da riscrivere. L'hash del blocco precedente lega ogni header al suo genitore, e la Merkle root lega l'header a ogni transazione del blocco. Cambiare una transazione cambia la root e quindi l'hash dell'header, quindi un blocco riscritto richiederebbe una propria proof of work, e così ogni blocco successivo.

## medium

Dimensioni dei campi e ordine dei byte contano. Version, timestamp, nBits e nonce sono interi di 4 byte memorizzati in little-endian. L'hash del blocco precedente e la Merkle root sono valori di 32 byte memorizzati nell'ordine interno dei byte. Gli esploratori di blocchi di solito mostrano gli hash al contrario, quindi la stringa esadecimale che si vede per l'hash di un blocco è l'inverso dei byte effettivamente sottoposti ad hash.

![Diagramma dei byte dell'header di blocco](media/wiki/block-header/block-header-bytes.svg "L'header di blocco di 80 byte è il dato che i miner sottopongono due volte a SHA-256, e il nonce è il campo che cambiano più spesso.")

Il campo nBits è una forma compatta del target a 256 bit. Il suo primo byte è un esponente, e i tre byte successivi sono una mantissa. Il target è uguale alla mantissa moltiplicata per 256 elevato all'esponente meno tre. La difficoltà 1, cioè 0x1d00ffff, ha la mantissa 0x00ffff e l'esponente 0x1d sulla mainnet. La difficoltà è il rapporto tra il target della difficoltà 1 e il target corrente, quindi un target più piccolo significa una difficoltà più alta. Bitcoin Core rifiuta un valore nBits che codifica un target negativo (bit di segno impostato con mantissa diversa da zero).

Sulla mainnet il valore nBits cambia solo con gli aggiustamenti di difficoltà, che avvengono ogni 2.016 blocchi.

I timestamp seguono due regole. L'orario di un blocco deve essere strettamente maggiore della mediana dei tempi degli ultimi 11 blocchi, cioè la median time past. L'orario di un blocco non può inoltre superare di più di due ore l'orologio del nodo che lo verifica. La prima regola fa avanzare il tempo anche quando gli orologi dei miner non concordano. La seconda limita quanto un miner può spingere il timestamp nel futuro. BIP 113 usa la stessa mediana per i controlli sul locktime.

Il nonce non è l'unico campo che un miner può variare. Il timestamp può avanzare entro la finestra consentita, e la coinbase può essere modificata per cambiare la Merkle root. Ogni cambiamento produce un nuovo header da sottoporre ad hash.

## advanced

La Developer Reference descrive l'header come la struttura sottoposta ad hash per la proof of work, quindi le transazioni entrano in quell'hash solo attraverso la Merkle root. Il loro contenuto completo non serve per verificare il lavoro.

![Diagramma dei byte dell'header di blocco](media/wiki/block-header/block-header-bytes.svg "L'header di blocco di 80 byte è il dato che i miner sottopongono due volte a SHA-256, e il nonce è il campo che cambiano più spesso.")

Il nonce è di quattro byte, troppo poco per l'hardware di mining attuale. BIP 320 osserva che l'hardware di mining può esaurire il nonce a 32 bit in meno di 200 millisecondi, il che costringe il controller a inviare nuovo lavoro a ogni chip molto spesso. I miner quindi fanno il roll di altri campi. L'extra nonce della coinbase modifica la coinbase, la Merkle root e quindi l'header. Il timestamp può essere fatto avanzare entro la sua finestra, anche se BIP 320 avverte che far scorrere troppi bit del timestamp distorce il tempo su un periodo lungo.

La version è la terza fonte di variazione. BIP 320 riserva 16 bit di nVersion per usi generali, così i miner possono farli scorrere senza far scattare falsi avvisi su segnali di soft fork sconosciute. BIP 320 dice che questi bit possono essere concordati con i pool tramite l'estensione Stratum version-rolling. Il BIP è ancora una bozza, quindi la riserva non va letta come una regola di consenso già stabilita.

Le regole sul timestamp limitano in entrambe le direzioni quanto l'orario di un blocco può spostarsi. La regola della mediana impedisce a un singolo blocco di riportare il tempo indietro oltre la storia recente, e il limite di due ore impedisce che corra avanti rispetto al tempo reale. Entrambe sono applicate da ogni full node, quindi un blocco che le viola viene rifiutato anche se il suo hash soddisfa il target.

Il confronto con il target tratta l'hash dell'header come un intero senza segno a 256 bit. La codifica compatta perde precisione, quindi il target esatto è il valore decodificato da nBits, non una cifra di difficoltà arrotondata. I pool usano spesso un target meno troncato per le proprie share, come nota la Bitcoin Wiki, ma si tratta di una scelta del pool. Non cambia ciò che la rete accetta come blocco.

L'header è quindi un impegno piccolo e di dimensione fissa che unisce proof of work, collegamento al genitore, impegno verso le transazioni e contesto temporale e di difficoltà. Ogni campo ha un compito preciso, e le regole di consenso verificano ciascuno di essi.
