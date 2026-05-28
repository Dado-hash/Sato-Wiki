---
id: wiki.block-subsidy
slug: block-subsidy
language: it
category: economics
title: Block Subsidy
description: I nuovi bitcoin creati e assegnati al miner di ogni blocco valido, che insieme alle commissioni di transazione forma l'output della coinbase.
coverImage: media/wiki/block-subsidy/block-subsidy-hero.svg
difficulty: base
readTimeMinutes: 6
tags:
  - Economia
  - Mining
  - Subsidy
  - Offerta
related:
  - wiki.miner-incentives
  - wiki.halving
  - wiki.issuance-schedule
  - wiki.transaction-fees
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: Riferimento per Sviluppatori Bitcoin - Transazioni
    url: https://developer.bitcoin.org/reference/transactions.html
    author: Bitcoin.org contributors
  - title: Mastering Bitcoin - Capitolo 10
    url: https://github.com/bitcoinbook/bitcoinbook/blob/develop/ch10.asciidoc
    author: Andreas M. Antonopoulos
updatedAt: 2026-05-28T00:00:00Z
---

## base

Il block subsidy è la quantità di nuovi bitcoin creata in ogni blocco. È l'unico modo in cui nuovi bitcoin entrano in circolazione. Quando un minermina un blocco valido, gli è permesso creare una transazione speciale chiamata coinbase che gli assegna il subsidy più le commissioni di transazione delle transazioni incluse.

Il subsidy è iniziato a 50 BTC per blocco nel 2009. Ogni 210.000 blocchi (circa quattro anni), il subsidy viene dimezzato — questo si chiama halving. Dopo l'halving del 2024, il subsidy è di 3,125 BTC per blocco.

Il subsidy segue una regola semplice: inizia con 50 BTC e dividi per due ogni 210.000 blocchi. Dopo 64 halving, il subsidy diventa meno di 1 satoshi e si arrotonda a zero. Questo avverrà intorno all'anno 2140.

![Anatomia del block subsidy](media/wiki/block-subsidy/block-subsidy-hero.svg "La transazione coinbase contiene il block subsidy più le commissioni di transazione. Questo è l'unico modo in cui nuovi bitcoin entrano nel sistema.")

Il block subsidy è ciò che rende il mining redditizio anche quando le commissioni di transazione sono basse. Nei primi anni di Bitcoin, il subsidy era l'incentivo dominante. Con il suo declino nei decenni, ci si aspetta che le commissioni di transazione diventino la principale fonte di entrata per i miner.

L'output della coinbase ha una regola speciale: non può essere speso fino a quando non ha 100 conferme (circa 16 ore). Questo impedisce ai miner di spendere monete del subsidy che potrebbero essere invalidate da una riorganizzazione dei blocchi.

## medium

Il block subsidy è imposto dalle regole di consenso che ogni full node valida. La funzione `GetBlockSubsidy` in Bitcoin Core calcola il subsidy corretto per qualsiasi altezza di blocco:

```cpp
CAmount GetBlockSubsidy(int nHeight, const Consensus::Params& consensusParams)
{
    int halvings = nHeight / consensusParams.nSubsidyHalvingInterval;
    if (halvings >= 64)
        return 0;
    CAmount nSubsidy = 50 * COIN;
    nSubsidy >>= halvings;
    return nSubsidy;
}
```

Il subsidy si dimezza ogni 210.000 blocchi. L'aritmetica è un semplice right-shift: dopo un halving, 50 diventa 25; dopo due, 25 diventa 12,5; e così via. Dopo 64 halving, il risultato è zero.

La transazione coinbase è unica in quanto non ha input. Tutte le altre transazioni devono consumare UTXO precedenti come input. La coinbase crea valore dal nulla, ma solo entro i rigidi limiti definiti dal programma del subsidy. Il valore totale dell'output della coinbase non deve superare il block subsidy più la somma delle commissioni di tutte le transazioni nel blocco.

Poiché il subsidy viene pagato nella coinbase, l'offerta monetaria effettiva cresce solo quando vengono trovati blocchi. A 144 blocchi al giorno (media di 10 minuti), l'emissione giornaliera può essere calcolata come:
```
Emissione giornaliera = subsidy × 144
```
A 3,125 BTC, questo significa 450 BTC al giorno, o circa 164.000 BTC all'anno.

Il subsidy ha rappresentato la stragrande maggioranza dell'offerta totale di bitcoin:
- 2009-2012: 10.500.000 BTC dal subsidy (100% della nuova offerta)
- 2012-2016: 5.250.000 BTC dal subsidy (~98% con fee basse)
- 2016-2020: 2.625.000 BTC dal subsidy (~95%)
- 2020-2024: 1.312.500 BTC dal subsidy (~90%)

## advanced

Il block subsidy serve un duplice scopo economico: distribuisce nuove monete e protegge la rete simultaneamente. Questo design risolve elegantemente il problema di bootstrap che affligge i nuovi sistemi monetari.

**La regola di maturità della coinbase.** Gli output della coinbase devono maturare per 100 blocchi prima di poter essere spesi (imposto dai controlli di `IsCoinBase()` in `CheckTxInputs`). Questo impedisce il seguente attacco: un miner trova un blocco, spende la coinbase immediatamente, e poi una riorganizzazione orfana quel blocco. Senza la regola di maturità, le monete spese scomparirebbero da uno stato della catena ma rimarrebbero in un altro, creando un'opportunità di double-spend.

**Interazione tra subsidy e difficoltà.** Il block subsidy influenza indirettamente la difficoltà di mining attraverso la redditività. Quando il subsidy è alto, il mining è più redditizio, attirando più hash rate, che aumenta la difficoltà. Con il declino del subsidy, l'hash rate di equilibrio per un dato prezzo del bitcoin diminuisce anch'esso, a meno che non sia compensato da entrate da commissioni o apprezzamento del prezzo.

**Subsidy minimo teoricamente sostenibile.** Gli economisti dibattono sul subsidy minimo (o entrate da commissioni) necessario per sostenere la rete. Un modello comune assume che i miner spendano la maggior parte delle loro entrate in elettricità. Se le entrate totali del mining scendono sotto i costi totali di elettricità, i miner chiudono, l'hash rate cala e la rete diventa meno sicura. L'aggiustamento è autocorrettivo: un hash rate più basso significa una difficoltà più bassa, che riduce i costi di elettricità per i miner rimanenti, ripristinando l'equilibrio.

**Confronto con l'estrazione dell'oro.** Il block subsidy di Bitcoin è analogo all'estrazione dell'oro: entrambi richiedono risorse del mondo reale (energia, attrezzature) per produrre nuove unità. Tuttavia, il programma del subsidy di Bitcoin è completamente prevedibile, mentre l'offerta d'oro dipende dalla scoperta geologica e dalla tecnologia di estrazione. Il tasso del subsidy di Bitcoin si dimezza secondo un programma fisso indipendentemente dal prezzo; le miniere d'oro si aprono o chiudono in base al prezzo dell'oro rispetto al costo di estrazione.
