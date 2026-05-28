---
id: history.mtgox-collapse
slug: mtgox-collapse
language: it
date: 2014-02-01
title: Crollo di Mt. Gox
category: security
summary: Mt. Gox, il più grande exchange Bitcoin del mondo, dichiara bancarotta dopo aver perso circa 850.000 BTC a causa di violazioni della sicurezza e cattiva gestione.
tags:
  - Bitcoin
  - Mt. Gox
  - Exchange
  - Sicurezza
  - Bancarotta
related:
  - id: wiki.private-keys
    title: Chiavi Private
  - id: wiki.transactions
    title: Transazioni Bitcoin
  - id: wiki.volatility
    title: Volatilità
  - id: wiki.full-nodes
    title: Full Node
sources:
  - title: La storia interna di Mt. Gox — Wired
    url: https://www.wired.com/2014/03/bitcoin-exchange/
    author: Robert McMillan
    publishedAt: 2014-03-03
  - title: Mt. Gox dichiara bancarotta — BBC
    url: https://www.bbc.com/news/technology-26400932
    author: BBC News
    publishedAt: 2014-02-28
  - title: Il crollo di Mt. Gox — The New York Times
    url: https://www.nytimes.com/2014/02/28/technology/mt-gox-files-for-bankruptcy.html
    author: Nathaniel Popper
    publishedAt: 2014-02-28
updatedAt: 2026-05-28T00:00:00Z
---

Nel febbraio 2014, Mt. Gox — un tempo gestiva oltre il 70% di tutti gli scambi di Bitcoin a livello mondiale — crollò in modo spettacolare. L'exchange rivelò di aver perso circa 850.000 bitcoin, per un valore di oltre $450 milioni all'epoca, a causa di una combinazione di violazioni della sicurezza, bug software e grave cattiva gestione. Il crollo fu l'evento più catastrofico nella storia di Bitcoin fino a quel momento e rimane una delle più grandi frodi finanziarie mai registrate.

## Anni di Incuria

I semi del fallimento di Mt. Gox furono piantati molto prima del crollo. Dopo che Mark Karpelès acquisì l'exchange nel 2011, fece fatica a mantenere e migliorare la sicurezza della piattaforma. Il codebase dell'exchange era un insieme di modifiche non documentate, la gestione dei wallet era primitiva e mancava un audit di sicurezza di base.

Il problema tecnico centrale era la malleabilità delle transazioni. Le firme ECDSA di Bitcoin potevano essere mutate da una terza parte senza invalidarle, producendo un ID di transazione diverso. Il sistema di prelievo di Mt. Gox verificava se una transazione fosse stata confermata monitorando il suo TXID. Quando un attaccante mutava una transazione di prelievo, il nuovo TXID non corrispondeva a ciò che Mt. Gox stava monitorando, e i sistemi automatizzati dell'exchange interpretavano questo come un prelievo fallito — emettendo un nuovo pagamento. Questo permetteva agli attaccanti di drenare fondi dall'exchange ripetutamente.

## La Perdita

Nel corso di diversi anni, gli attaccanti sfruttarono queste vulnerabilità per rubare circa 850.000 BTC da Mt. Gox. Circa 200.000 di quelle monete furono eventualmente recuperate, ma 650.000 — per un valore di miliardi di dollari ai prezzi correnti — non furono mai recuperate. Il furto passò inosservato alla dirigenza di Mt. Gox per anni, in parte a causa della loro mancata riconciliazione dei saldi dei hot wallet con le passività dell'exchange.

Alla fine del 2013, quando Mt. Gox tentò finalmente di riconciliare i suoi conti, scoprì discrepanze enormi. L'exchange sospese i prelievi nel febbraio 2014, citando "problemi tecnici". Il 28 febbraio, Mt. Gox presentò istanza di bancarotta in Giappone e negli Stati Uniti, rivelando l'intera portata delle perdite.

## Le Conseguenze

Il crollo di Mt. Gox ebbe effetti devastanti sull'ecosistema Bitcoin. Il prezzo di bitcoin scese da circa $800 a $400 nelle settimane successive all'annuncio. Molti utenti persero i risparmi di una vita. La fiducia negli exchange di criptovalute fu gravemente danneggiata e l'evento innescò richieste di regolamentazione del settore.

Per la comunità Bitcoin, il crollo fu una dolorosa lezione sull'importanza della sicurezza e sui rischi dei servizi centralizzati. La frase "non le tue chiavi, non le tue monete" divenne centrale nella filosofia Bitcoin. L'evento accelerò anche lo sviluppo di tecnologie migliori per i wallet, inclusi hardware wallet, schemi multisignature e pratiche di sicurezza migliorate per gli exchange.

## Procedimenti Legali

Mark Karpelès fu arrestato in Giappone nel 2015 con l'accusa di appropriazione indebita e manipolazione di dati. Dopo un lungo processo, fu giudicato colpevole nel 2019 per manipolazione di dati informatici ma assolto dall'accusa di appropriazione indebita. Ricevette una pena sospesa.

Le procedure di bancarotta per Mt. Gox sono continuate per oltre un decennio. Nel 2024, il trustee iniziò a distribuire i beni recuperati ai creditori, che ricevettero circa il 15-20% delle loro richieste originali in bitcoin e bitcoin cash. Il capitolo finale della saga di Mt. Gox era ancora in fase di scrittura più di dieci anni dopo il crollo.

## Impatto a Lungo Termine

Nonostante la devastazione, la rete Bitcoin stessa non fu mai compromessa. Il crollo di Mt. Gox fu il fallimento di un servizio centralizzato, non del protocollo sottostante. Questa distinzione era cruciale: la blockchain di Bitcoin continuò a funzionare normalmente durante tutta la crisi, elaborando transazioni ogni 10 minuti senza interruzioni.

Il crollo portò a miglioramenti significativi nell'ecosistema delle criptovalute. Gli exchange implementarono cold storage, wallet multi-firma, audit regolari e assicurazioni. Gli sviluppatori implementarono Segregated Witness nel 2017, che risolse il problema della malleabilità delle transazioni a livello di protocollo. Le lezioni di Mt. Gox hanno plasmato lo sviluppo dell'intero settore.

![Logo Mt. Gox](media/history/mtgox-collapse/mtgox-collapse-logo.webp "Il logo di Mt. Gox, un tempo exchange Bitcoin dominante, ora monito per il settore.")
