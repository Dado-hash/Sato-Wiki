---
id: history.first-halving
slug: first-halving
language: it
date: 2012-11-28
title: Primo Halving di Bitcoin
category: protocol
summary: Il primo halving di Bitcoin riduce il block subsidy da 50 a 25 BTC all'altezza blocco 210.000, dimezzando il tasso di emissione di nuovi bitcoin.
tags:
  - Bitcoin
  - Halving
  - Mining
  - Offerta
related:
  - id: wiki.halving
    title: Halving
  - id: wiki.block-subsidy
    title: Block Subsidy
  - id: wiki.issuance-schedule
    title: Schedule di Emissione
  - id: wiki.miner-incentives
    title: Incentivi per i Miner
sources:
  - title: Primo Halving — Blockchain.com
    url: https://www.blockchain.com/explorer/blocks/210000
    author: Blockchain.com
  - title: Storia degli Halving di Bitcoin — CoinDesk
    url: https://www.coindesk.com/bitcoin-halving-history
    author: CoinDesk
  - title: Blocco Bitcoin 210.000 — Bitcoin Explorer
    url: https://bitcoinexplorer.org/block/210000
    author: Bitcoin Explorer
updatedAt: 2026-05-28T00:00:00Z
---

Il 28 novembre 2012, Bitcoin raggiunse l'altezza blocco 210.000, attivando la prima riduzione programmata delle ricompense di mining. Il block subsidy passò da 50 a 25 bitcoin per blocco, dimezzando il tasso di immissione di nuovi bitcoin in circolazione. Questo evento, oggi noto come "halving", era stato hardcodato nelle regole di consenso di Bitcoin da Satoshi Nakamoto e si verifica ogni 210.000 blocchi — circa ogni quattro anni.

![Blocco del primo halving 210000](media/history/first-halving/first-halving-block.webp "Il blocco 210.000 su un block explorer, che segna il primo halving con subsidy a 25 BTC.")

## Il Meccanismo dell'Halving

Lo schedule di emissione di Bitcoin è una delle sue caratteristiche più distintive. A differenza delle valute fiat, dove le banche centrali possono stampare moneta a piacimento, l'offerta di Bitcoin segue una curva predeterminata e immutabile. Il block subsidy iniziò a 50 BTC nel gennaio 2009 e si dimezza ogni 210.000 blocchi. Il primo halving al blocco 210.000 portò il subsidy a 25 BTC. Questo decadimento geometrico significa che l'offerta totale si avvicina asintoticamente a 21 milioni, con ogni halving che rende i nuovi bitcoin sempre più scarsi.

L'halving è imposto dal consenso: ogni full node verifica che la transazione coinbase in ogni blocco non crei più bitcoin del subsidy corrente più le commissioni. Se un miner tentasse di richiedere la vecchia ricompensa di 50 BTC dopo il blocco 210.000, tutti i nodi rifiuterebbero il blocco come invalido.

## Risposta del Mercato

Al momento del primo halving, bitcoin scambiava a circa $12-$13. L'evento era stato anticipato dalla comunità, ma il suo impatto immediato sul mercato fu contenuto. Tuttavia, nei mesi successivi all'halving si verificò uno dei primi grandi bull run di Bitcoin. Nell'aprile 2013, il prezzo era salito a oltre $260 — un aumento di oltre 20x rispetto al prezzo dell'halving.

Gli economisti dibattono se gli aumenti di prezzo post-halving siano causali o coincidenze. Il modello "stock-to-flow" sostiene che la ridotta offerta di nuovi bitcoin, combinata con una domanda stabile o in crescita, spinga naturalmente i prezzi verso l'alto. I critici ribattono che si tratta di correlazione, non causalità, e che altri fattori — attenzione mediatica, sviluppo degli exchange, condizioni macroeconomiche — guidano il prezzo.

## Impatto sul Mining

Il primo halving ebbe un impatto significativo sui miner. Quelli con costi energetici elevati o hardware inefficiente videro le loro entrate improvvisamente dimezzate. Alcuni miner furono costretti a chiudere, riducendo temporaneamente l'hashrate della rete. Tuttavia, il declino fu di breve durata poiché hardware di mining più efficiente (FPGA e primi ASIC) stava entrando nel mercato e il prezzo crescente del bitcoin compensava la riduzione del block subsidy.

Il meccanismo di difficoltà variabile di Bitcoin garantì che i blocchi continuassero a essere trovati ogni 10 minuti in media. Quando alcuni miner abbandonarono, la difficoltà diminuì, rendendo più facile per i miner rimanenti trovare blocchi. Questa stabilizzazione automatica è una caratteristica fondamentale del design di Bitcoin.

## Significato Storico

Il primo halving fu un evento epocale che validò la politica monetaria di Bitcoin. Dimostrò che lo schedule di offerta fissa sarebbe stato imposto dalla rete, indipendentemente dal sentiment dei miner o dalle condizioni di mercato. L'evento introdusse anche il pubblico più ampio alle proprietà monetarie uniche di Bitcoin, innescando discussioni sul suo potenziale come riserva di valore e sulle sue differenze rispetto alle valute inflazionistiche tradizionali.

Ogni halving successivo ha attirato crescente attenzione, con gli halving del 2020 e 2024 che sono stati grandi eventi mediatici. Il primo halving, sebbene meno notato dal grande pubblico all'epoca, fu il test cruciale che dimostrò che la politica monetaria di Bitcoin non era solo teorica — era inevitabile.

