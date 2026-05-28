---
id: wiki.fee-market
slug: fee-market
language: it
category: economics
title: Mercato delle Commissioni
description: Il mercato competitivo per lo spazio nei blocchi dove gli utenti fanno offerte per la conferma delle transazioni e i miner selezionano quelle più redditizie.
coverImage: media/wiki/fee-market/fee-market-hero.svg
difficulty: base
readTimeMinutes: 7
tags:
  - Economia
  - Commissioni
  - Mempool
  - Mining
related:
  - wiki.transaction-fees
  - wiki.miner-incentives
  - wiki.block-subsidy
  - wiki.mempool
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: "Mastering Bitcoin - Mempool e Stima delle Commissioni"
    url: https://github.com/bitcoinbook/bitcoinbook/blob/develop/ch05.asciidoc
    author: Andreas M. Antonopoulos
  - title: Analisi del Mercato delle Commissioni Bitcoin
    url: https://bitcoinfees.earn.com/
    author: Earn.com
updatedAt: 2026-05-28T00:00:00Z
---

## base

Il mercato delle commissioni di Bitcoin è il sistema economico che determina quanto gli utenti pagano per far confermare le proprie transazioni. Poiché ogni blocco ha una dimensione limitata (circa 4 milioni di unità di peso), non tutte le transazioni possono essere incluse immediatamente. Gli utenti competono per questo spazio scarso offrendo commissioni.

Quando invii una transazione Bitcoin, puoi allegare una commissione. Commissioni più alte significano che i miner hanno più probabilità di includere la tua transazione nel prossimo blocco. Commissioni più basse significano che la tua transazione potrebbe attendere più a lungo nel mempool.

Pensala come una coda di taxi all'aeroporto. Ci sono solo un certo numero di taxi (spazio nel blocco). Le persone che hanno bisogno urgente di un passaggio sono disposte a pagare di più. Chi può aspettare prende un'opzione più economica o aspetta il prossimo taxi. Il prezzo si aggiusta in base a quante persone hanno bisogno di un passaggio e quanti taxi sono disponibili.

La commissione è calcolata come differenza tra il valore totale degli input della transazione e il valore totale degli output:
```
commissione = somma(input) - somma(output)
```

Le commissioni sono tipicamente misurate in satoshi per byte virtuale (sat/vB). Una transazione standard potrebbe costare 10-50 sat/vB in condizioni normali, ma può salire a centinaia durante la congestione.

![Domanda e offerta nel mercato delle fee](media/wiki/fee-market/fee-market-hero.svg "Lo spazio nei blocchi è fisso. Quando la domanda di transazioni supera l'offerta, gli utenti alzano le commissioni fino a quando il mercato si equilibra.")

Il mercato delle commissioni garantisce che le transazioni economicamente più preziose vengano confermate per prime. Non è controllato da alcuna autorità centrale — emerge naturalmente dall'interazione di migliaia di utenti e miner.

## medium

Il mercato delle commissioni è guidato dal vincolo fondamentale dello spazio nei blocchi. Ogni blocco ha un peso massimo di 4.000.000 di unità di peso (WU). Dopo aver considerato l'intestazione del blocco e la transazione coinbase, circa 3.990.000 WU sono disponibili per le transazioni degli utenti. Una transazione tipica potrebbe consumare 140-200 WU per un pagamento semplice (SegWit) o più per script complessi.

I miner selezionano le transazioni dal loro mempool per costruire un template di blocco. L'algoritmo di selezione standard è ordinare le transazioni per fee rate (sat/vWU o sat/vB) e includere quelle con la paga più alta per prime, fino al limite di peso del blocco. Questo è noto come selezione "greedy" delle transazioni.

**Stima delle commissioni.** I portafogli usano algoritmi di stima delle commissioni per raccomandare fee appropriate. Questi algoritmi analizzano i blocchi recenti per determinare quale fee rate è stato sufficiente per la conferma entro un numero target di blocchi. Bitcoin Core fornisce stime attraverso l'RPC `estimatesmartfee`, che restituisce un fee rate per un dato obiettivo di conferma (es. 2 blocchi, 6 blocchi, 25 blocchi).

**Pattern storici delle commissioni.** Il mercato delle fee di Bitcoin ha attraversato diverse fasi distinte:

- **2009-2012**: La maggior parte delle transazioni includeva commissioni zero o minime. I miner le processavano comunque, poiché il block subsidy era la ricompensa principale.
- **2013-2016**: Con l'aumento dell'uso e il riempimento dei blocchi, le commissioni sono diventate necessarie. I primi significativi picchi di fee si sono verificati.
- **2017**: L'apice della prima grande crisi delle commissioni. Le fee medie hanno raggiunto oltre $50 per transazione durante la mania del dicembre 2017, poiché l'adozione di SegWit era ancora bassa.
- **2021-2024**: Le iscrizioni Ordinals e BRC-20 hanno creato nuova domanda di spazio nei blocchi, portando le entrate da commissioni a livelli mai visti.
- **In corso**: Le entrate da commissioni come percentuale della ricompensa totale dei miner sono cresciute, da quasi zero a occasionalmente superare il block subsidy durante periodi di alta domanda.

**Replace-by-Fee (RBF).** L'RBF permette a un mittente di sostituire una transazione non confermata con una nuova che paga una commissione più alta. BIP 125 definisce l'RBF opt-in: la transazione originale deve segnalare la sostituibilità impostando il numero di sequenza sotto 0xFFFFFFFE. Quando viene rilevata una sostituzione, i nodi verificano che la nuova transazione paghi un fee rate strettamente più alto e non sia in conflitto con altre transazioni nel mempool.

**Child-Pays-For-Parent (CPFP).** Se una transazione è bloccata con una commissione bassa, il destinatario può creare una nuova transazione che spende uno dei suoi output e offre una commissione alta. I miner valutano il pacchetto combinato: se il genitore + figlio insieme offrono un fee rate competitivo, entrambi vengono inclusi. Questo dà al destinatario un modo per accelerare la conferma anche se il mittente non ha pagato abbastanza.

## advanced

Il mercato delle commissioni è un problema di meccanismo di design: come allocare una risorsa scarsa (lo spazio nei blocchi) tra utenti in competizione senza un pianificatore centrale. La soluzione di Bitcoin — asta al primo prezzo con offerta fissa — ha implicazioni significative.

**Lo spazio nei blocchi come bene da congestione.** Lo spazio nei blocchi è un bene di club: è non rivale fino al limite di dimensione del blocco, ma diventa rivale quando la domanda supera quel limite. A differenza di un mercato tipico, l'offerta di spazio nei blocchi non risponde ai segnali di prezzo — il limite di peso del blocco è fissato dal consenso. Questa offerta anelastica crea un'estrema volatilità dei prezzi quando la domanda fluttua.

**La distribuzione delle commissioni sotto diversi regimi di domanda:**

| Regime | Stato mempool | Fee rate tipico | Tempo di conferma |
|--------|--------------|-----------------|-------------------|
| Vuoto | 0-1 blocchi di tx | 1-5 sat/vB | Prossimo blocco |
| Normale | 1-5 blocchi | 5-30 sat/vB | 1-6 blocchi |
| Congestionato | 10-50+ blocchi | 50-300+ sat/vB | Ore o giorni |
| Estremo | 100+ blocchi | 300-1000+ sat/vB | Giorni |

**Efficienza economica del mercato delle commissioni.** L'asta al primo prezzo crea diverse inefficienze:

1. **Pagamento eccessivo delle fee**: Gli utenti devono indovinare la commissione appropriata, spesso pagando più del necessario a causa dell'incertezza sulle offerte altrui.
2. **Guerre di offerte**: Durante la congestione, gli utenti possono sostituire ripetutamente le transazioni con commissioni più alte (RBF), creando un'asta crescente.
3. **Inquinamento strategico del mempool**: Un attaccante può riempire i blocchi con transazioni a bassa fee a costo minimo per congestionare la rete.

Miglioramenti proposti includono:

- **Package relay (BIP 331)**: Permette a un insieme di transazioni correlate di essere valutato come pacchetto anziché individualmente, migliorando l'efficacia del CPFP.
- **v3 transaction relay**: Una nuova versione di transazione con regole di sostituzione più rigorose, progettata per rendere più affidabile l'aumento delle commissioni.
- **Polvere effimera**: UTXO di breve durata che possono essere spesi prima di essere inclusi in un blocco, riducendo il costo di certe interazioni del protocollo.

**La tesi della sostenibilità delle commissioni.** Alcuni economisti sostengono che il mercato delle fee potrebbe non riuscire a sostenere la sicurezza del mining dopo il declino dei subsidy, perché pagare le commissioni è un problema di bene pubblico: gli utenti hanno un incentivo a fare free-riding sulle fee altrui. Tuttavia, i dati empirici mostrano che le entrate da commissioni sono cresciute significativamente nel tempo, e l'ondata di Ordinals/inscriptions ha dimostrato che la domanda organica di spazio nei blocchi può generare commissioni sostanziali anche senza utilizzo tradizionale di pagamenti.
