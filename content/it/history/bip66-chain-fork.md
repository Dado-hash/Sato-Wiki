---
id: history.bip66-chain-fork
slug: bip66-chain-fork
language: it
date: 2015-07-04
title: Fork del luglio 2015 legato alla BIP 66
category: security
summary: A luglio 2015, mentre la BIP 66 entrava in vigore, alcuni miner che non validavano completamente i blocchi costruirono su un blocco non valido, producendo fork brevi.
tags:
  - Fork
  - BIP 66
  - SPV mining
  - Soft fork
sources:
  - title: "BIP 66: Strict DER signatures"
    url: https://github.com/bitcoin/bips/blob/master/bip-0066.mediawiki
    author: Pieter Wuille
    publishedAt: 2015-01-10
  - title: Some Miners Generating Invalid Blocks
    url: https://bitcoin.org/en/alert/2015-07-04-spv-mining
    author: Bitcoin.org
    publishedAt: 2015-07-04
related:
  - wiki.consensus-rules
  - wiki.ecdsa
  - wiki.soft-fork-signalling
  - wiki.spv-and-pruning
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## Cosa successe

Quando 950 degli ultimi 1.000 blocchi avessero avuto versione 3, i miner aggiornati avrebbero rifiutato i blocchi di versione 2. Nelle prime ore del 4 luglio 2015 fu raggiunta quella soglia del 95%. Poco dopo un piccolo miner che non aveva aggiornato il software minò un blocco non valido. Circa metà della potenza di hash della rete praticava SPV mining, cioè il mining senza validare completamente i blocchi, e quella metà costruì nuovi blocchi sopra quello non valido.

## Perché accadde

La BIP 66 è un soft fork che richiede che le firme usino una codifica DER stretta. Alcuni miner avevano dichiarato che avrebbero applicato la regola, ma non controllavano i blocchi da sé e accettarono quindi quello non valido. Il software che presume che i blocchi siano validi, come i wallet SPV e le versioni più vecchie di Bitcoin Core, poteva mostrare transazioni come confermate quando non lo erano. Bitcoin Core 0.9.4 e versioni precedenti non conoscevano le regole della BIP 66 e non potevano quindi rifiutare questi blocchi, mentre la 0.9.5 e le successive sì.

## Come si risolse

La soluzione raccomandata era riportare i miner alla validazione completa, almeno per un periodo. L'avviso chiedeva ai miner di pool di passare a un pool che valida correttamente i blocchi, e a chi minava in proprio di usare Bitcoin Core 0.10.2. Agli utenti dei wallet era consigliato di attendere circa 30 conferme in più, e l'avviso indicava che bitcoin.org avrebbe ridotto questa raccomandazione una volta tornati alla validazione completa. Gli aggiornamenti successivi segnalarono un ulteriore fork a partire dal 5 luglio e dichiararono che la situazione non era risolta, quindi il consiglio di attendere restava valido.
