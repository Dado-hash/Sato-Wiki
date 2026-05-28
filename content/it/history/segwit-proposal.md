---
id: history.segwit-proposal
slug: segwit-proposal
language: it
date: 2015-12-01
title: Proposta SegWit
category: protocol
summary: Pieter Wuille propone Segregated Witness (BIP 141, 143, 144) per risolvere malleabilità e scalabilità.
coverImage: media/wiki/history-segwit-proposal/history-segwit-proposal-hero.svg
sources:
  - title: BIP 141
    url: https://github.com/bitcoin/bips/blob/master/bip-0141.mediawiki
  - title: BIP 143
    url: https://github.com/bitcoin/bips/blob/master/bip-0143.mediawiki
  - title: BIP 144
    url: https://github.com/bitcoin/bips/blob/master/bip-0144.mediawiki
related:
  - wiki.segregated-witness
updatedAt: 2026-05-28T00:00:00Z
---

Nel dicembre 2015, Pieter Wuille introdusse Segregated Witness (SegWit) attraverso tre Bitcoin Improvement Proposals: BIP 141, BIP 143 e BIP 144. SegWit proponeva un soft fork che avrebbe separato (segregato) i dati witness (firme e script) dai dati della transazione, ristrutturando efficacemente il modo in cui i blocchi memorizzano le informazioni.
![Diagramma che illustra la struttura di una transazione SegWit che mostra la separazione dei dati witness dal corpo della transazione.](media/history/segwit-proposal/segwit-structure-diagram.webp "Diagramma struttura SegWit")


Gli obiettivi principali di SegWit erano due. Primo, risolveva la malleabilità delle transazioni, un bug di lunga data che permetteva a terze parti di alterare gli identificatori delle transazioni prima della conferma. Questo era un requisito fondamentale per protocolli di secondo livello come la Lightning Network. Secondo, spostando i dati witness fuori dalla struttura principale del blocco, SegWit aumentava effettivamente il limite di dimensione del blocco da 1 MB a circa 4 MB, fornendo un miglioramento della scalabilità.

SegWit introdusse anche un nuovo sistema di misurazione basato sul peso del blocco, sostituendo il rigido limite di 1 MB. Ogni byte nella sezione witness contava come 1 unità di peso, mentre ogni byte nel blocco base contava come 4 unità di peso, con un limite totale di peso del blocco di 4 milioni di unità.

La proposta scatenò un acceso dibattito nella comunità Bitcoin, con alcuni che sostenevano aumenti della dimensione del blocco tramite hard fork. Questo dibattito avrebbe infine portato al fork Bitcoin Cash nel 2017.
