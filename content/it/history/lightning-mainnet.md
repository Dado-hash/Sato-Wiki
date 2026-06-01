---
id: history.lightning-mainnet
slug: lightning-mainnet
language: it
date: 2018-03-01
title: Lightning Network Entra in Produzione su Mainnet
category: protocol
summary: La Lightning Network viene lanciata sulla mainnet di Bitcoin con LND 0.4, abilitando pagamenti istantanei a basso costo tramite un protocollo di secondo livello.
sources:
  - title: LND Release v0.4
    url: https://github.com/lightningnetwork/lnd/releases/tag/v0.4-beta
  - title: Lightning Network Overview
    url: https://lightning.network/
related:
  - wiki.lightning-network
updatedAt: 2026-05-28T00:00:00Z
---

Nel marzo 2018, la Lightning Network (LN) divenne operativa sulla mainnet di Bitcoin con il rilascio di LND 0.4-beta, la prima implementazione della rete in grado di competere su scala produttiva. Sviluppato da Lightning Labs, LND forniva un nodo completo con gestione dei canali, routing ed elaborazione dei pagamenti.

![Grafico che mostra la crescita del numero di nodi e canali della Lightning Network dal 2018 in poi.](media/history/lightning-mainnet/ln-network-growth.webp "Grafico crescita Lightning Network")

La Lightning Network affrontava i limiti di scalabilità di Bitcoin abilitando canali di pagamento off-chain. Gli utenti potevano aprire canali bidirezionali vincolando fondi a un indirizzo multi-firma sulla blockchain di Bitcoin, quindi condurre transazioni illimitate off-chain con regolamento istantaneo. Solo lo stato finale del canale veniva trasmesso alla catena principale.

L'adozione iniziale fu graduale ma costante. Entro la fine del 2018, la rete contava circa 2.500 nodi e 6.000 canali con una capacità totale di circa 100 BTC. Gli sviluppatori crearono wallet come Zap, applicazioni mobili e sistemi point-of-sale, dimostrando casi d'uso reali per i micropagamenti.

Il lancio su mainnet segnò il passaggio dalla teoria alla pratica per la più attesa soluzione di scaling di Bitcoin, dimostrando che il Layer 2 poteva funzionare in modo sicuro sul livello base esistente.
