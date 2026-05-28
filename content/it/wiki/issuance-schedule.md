---
id: wiki.issuance-schedule
slug: issuance-schedule
language: it
category: economics
title: Programma di Emissione
description: Il tasso prevedibile con cui vengono creati nuovi bitcoin attraverso i block subsidy, seguendo una curva disinflazionistica nota dal 2009 al 2140.
coverImage: media/wiki/issuance-schedule/issuance-curve.svg
difficulty: base
readTimeMinutes: 7
tags:
  - Economia
  - Offerta
  - Emissione
  - Politica Monetaria
related:
  - wiki.fixed-supply
  - wiki.twenty-one-million-cap
  - wiki.halving
  - wiki.block-subsidy
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: L'Offerta Controllata di Bitcoin
    url: https://en.bitcoin.it/wiki/Controlled_supply
    author: Bitcoin Wiki contributors
  - title: Programma del Block Subsidy di Bitcoin
    url: https://bitcoin.stackexchange.com/questions/2456/bitcoin-block-subsidy-schedule
    author: Bitcoin Stack Exchange
updatedAt: 2026-05-28T00:00:00Z
---

## base

Il programma di emissione di Bitcoin è il tasso prevedibile, garantito algoritmicamente, a cui vengono creati nuovi bitcoin. Le regole sono semplici: ogni blocco crea un numero fisso di nuovi bitcoin (il block subsidy), e quel numero viene dimezzato ogni 210.000 blocchi — approssimativamente ogni quattro anni.

Questo programma è stato stabilito quando Bitcoin è stato lanciato nel 2009 e non può essere modificato senza un ampio consenso. Significa che tutti nel mondo sanno esattamente quanti nuovi bitcoin verranno creati in qualsiasi momento futuro, con decenni di anticipo.

Il subsidy iniziale era di 50 BTC per blocco. Dopo il primo halving nel 2012 è diventato 25 BTC. Nel 2016 è diventato 12,5 BTC. Nel 2020 è diventato 6,25 BTC. Il più recente halving nel 2024 lo ha fissato a 3,125 BTC. Questa tendenza continua finché il subsidy diventa così piccolo da raggiungere effettivamente lo zero.

![Curva di emissione di Bitcoin](media/wiki/issuance-schedule/issuance-curve.svg "Il block subsidy si riduce ogni quattro anni, mentre l'offerta cumulativa si avvicina asintoticamente a 21 milioni.")

Il grafico mostra due curve importanti. La funzione a gradini (barre arancioni) mostra il subsidy per blocco a ogni epoca — dimezzandosi ogni volta. La curva S verde mostra l'offerta cumulativa che si avvicina a 21 milioni, con la maggior parte dei bitcoin già minata nei primi anni.

Poiché il programma è fisso e noto, Bitcoin è disinflazionistico: il tasso di inflazione (nuove monete come percentuale dell'offerta esistente) diminuisce prevedibilmente nel tempo e si avvicina a zero.

## medium

Il programma di emissione segue una progressione matematica precisa. Ogni epoca di halving dura esattamente 210.000 blocchi. Con il normale intervallo di 10 minuti per blocco di Bitcoin, ciò corrisponde a circa 3,99 anni per epoca. Il block subsidy per una data epoca è:

```
subsidy(altezza) = 50 × 2^(-floor(altezza / 210000)) BTC
```

Questo produce una funzione a gradini in cui il subsidy rimane costante all'interno di ogni epoca e scende in modo discontinuo a ogni confine di halving.

Il tasso di inflazione può essere calcolato in qualsiasi momento. Nella prima epoca (2009-2012), il tasso di inflazione annualizzato era approssimativamente:
```
10.500.000 BTC creati / da 0 a 10,5M ≈ effettivamente infinito all'inizio, ~100% alla fine
```
Alla quarta epoca (2020-2024), l'inflazione è scesa a circa l'1,8% annuo. Dopo l'halving del 2024, il tasso di inflazione è sceso sotto l'1% — inferiore al tasso di crescita dell'offerta d'oro a lungo termine di circa l'1,5-2% annuo.

| Epoca | Anni | Subsidy | Emissione annua | Inflazione (approx.) |
|-------|------|---------|-----------------|----------------------|
| 1 | 2009-2012 | 50 BTC | 2.625.000 BTC | ~∞ → 100% |
| 2 | 2012-2016 | 25 BTC | 1.312.500 BTC | ~50% → 12,5% |
| 3 | 2016-2020 | 12,5 BTC | 656.250 BTC | ~8% → 5% |
| 4 | 2020-2024 | 6,25 BTC | 328.125 BTC | ~3,6% → 1,8% |
| 5 | 2024-2028 | 3,125 BTC | 164.062 BTC | ~0,9% → 0,8% |

Al decimo halving (~2052), il tasso di inflazione annuale sarà inferiore allo 0,1% — trascurabile per scopi pratici. Quando il subsidy raggiungerà 1 satoshi per blocco (circa 64° halving), la nuova emissione sarà zero.

La natura deterministica di questo programma è senza precedenti nella storia monetaria. Nessun governo, banca centrale o organizzazione può accelerare, rallentare o modificare il tasso di creazione di nuovi bitcoin. Questa prevedibilità permette agli attori economici di prendere decisioni con piena conoscenza delle future condizioni dell'offerta.

## advanced

Il programma di emissione crea regimi economici distinti nel corso della vita di Bitcoin. Ci sono tre fasi:

**Fase 1 — Distribuzione (2009-2024):** Il 93% di tutti i bitcoin sono stati minati nei primi 15 anni. L'elevata emissione ha ricompensato i primi miner e distribuito ampiamente le monete. Questa fase ha visto l'emergere del mining come industria, con il tasso di hash cresciuto dal mining basato su CPU agli ASIC specializzati.

**Fase 2 — Maturità (2024-2140):** Il restante 7% dei bitcoin viene emesso a un tasso decrescente per circa 116 anni. Durante questa fase, il block subsidy passa dall'essere la principale fonte di reddito per i miner a una secondaria, poiché le commissioni di transazione diventano sempre più importanti. I miner devono diventare più efficienti man mano che il reddito da subsidy per blocco diminuisce.

**Fase 3 — Solo commissioni (2140+):** Non vengono creati nuovi bitcoin. I miner guadagnano esclusivamente dalle commissioni di transazione. Il modello di sicurezza passa da basato sul subsidy a basato sulle commissioni, una transizione che deve essere economicamente sostenibile per preservare la sicurezza proof of work della rete.

La transizione tra le fasi solleva importanti domande di teoria dei giochi. Nella Fase 1, l'alto subsidy ha creato forti incentivi per la partecipazione al mining, costruendo rapidamente la sicurezza della rete. Nella Fase 2, la riduzione del reddito da subsidy deve essere compensata da un aumento del prezzo del bitcoin, dalla riduzione dei costi di mining o dall'aumento delle entrate da commissioni. Se nessuno di questi si verifica, il budget per la sicurezza potrebbe diminuire.

Tuttavia, diversi fattori suggeriscono che la transizione è gestibile:

1. **Efficienza tecnologica**: L'efficienza degli ASIC è migliorata di ordini di grandezza e sono previsti ulteriori miglioramenti
2. **Maturità del mercato delle commissioni**: Con la crescita dell'adozione di Bitcoin, la competizione per lo spazio nei blocchi crea una domanda organica di commissioni
3. **Crescita del secondo livello**: La Lightning Network e altre soluzioni di secondo livello possono generare traffico regolare di commissioni mentre gli utenti aprono e chiudono canali
4. **Apprezzamento del prezzo**: Se il valore di Bitcoin cresce con l'adozione, anche un piccolo subsidy in termini di BTC può essere significativo in termini fiat — e eventualmente le entrate da commissioni possono sostenere la rete

Il programma ha anche implicazioni distributive. I primi adottanti hanno ricevuto grandi ricompense a bassa difficoltà e bassi prezzi del bitcoin. I nuovi arrivati devono acquisire monete attraverso l'acquisto sul mercato o il mining a difficoltà molto più alta. Questo crea un vantaggio intrinseco per la partecipazione precoce, ma che diminuisce man mano che il mercato matura e diventa più liquido.
