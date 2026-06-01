---
id: history.lightning-whitepaper
slug: lightning-whitepaper
language: it
date: 2017-08-01
title: Whitepaper Lightning Network
category: protocol
summary: Joseph Poon e Thaddeus Dryja pubblicano il whitepaper della Lightning Network, proponendo una soluzione di scaling di secondo livello per Bitcoin.
coverImage: media/wiki/history-lightning-whitepaper/history-lightning-whitepaper-hero.svg
sources:
  - title: Lightning Network Whitepaper
    url: https://lightning.network/lightning-network-paper.pdf
  - title: BOLT Specifications
    url: https://github.com/lightning/bolts
related:
  - wiki.lightning-network
updatedAt: 2026-05-28T00:00:00Z
---

Nell'agosto 2017, Joseph Poon e Thaddeus Dryja pubblicarono "The Bitcoin Lightning Network: Scalable Off-Chain Instant Payments," introducendo un protocollo di secondo livello progettato per affrontare le sfide di scalabilità di Bitcoin. Sebbene bozze iniziali circolassero già alla fine del 2015 e all'inizio del 2016, il whitepaper canonico è datato a questo periodo.

![Diagramma di una rete di canali di pagamento Lightning Network che instrada un pagamento attraverso più partecipanti.](media/history/lightning-whitepaper/lightning-network-diagram.webp "Diagramma routing Lightning Network")

Il whitepaper proponeva una rete di canali di pagamento bidirezionali in grado di instradare pagamenti attraverso più partecipanti senza regolare ogni transazione sulla blockchain di Bitcoin. Spostando la maggior parte delle transazioni off-chain e regolando solo il saldo finale, la Lightning Network poteva teoricamente elaborare milioni di transazioni al secondo con finalità quasi immediata e commissioni minime.

Le innovazioni chiave includevano gli Hashed Timelock Contracts (HTLC) per il routing atomico, le transazioni di commitment per la gestione dello stato del canale e l'onion routing per la privacy dei pagamenti. Il protocollo richiedeva che SegWit fosse attivo su Bitcoin, creando una relazione simbiotica tra le due tecnologie.

Il whitepaper della Lightning Network divenne uno dei documenti più influenti nella storia di Bitcoin, dando origine a molteplici implementazioni interoperabili (LND, c-lightning, Eclair) e a un ecosistema crescente di applicazioni costruite sul layer di pagamento.
