---
id: wiki.transactions
slug: transactions
language: it
category: protocol
title: Transazioni Bitcoin
description: La struttura dati che Bitcoin usa per spendere output precedenti, creare nuovi output ed esprimere autorizzazione.
coverImage: media/wiki/transactions/transaction-flow.svg
difficulty: advanced
readTimeMinutes: 8
tags:
  - Transazioni
  - Pagamenti
  - UTXO
  - Script
  - Mempool
related:
  - wiki.utxo-model
  - wiki.bitcoin-script
  - wiki.transaction-fees
  - wiki.mempool
  - wiki.blocks
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: Bitcoin Developer Reference - Transactions
    url: https://developer.bitcoin.org/reference/transactions.html
    author: Bitcoin.org contributors
  - title: Bitcoin Developer Guide - Transactions
    url: https://developer.bitcoin.org/devguide/transactions.html
    author: Bitcoin.org contributors
  - title: BIP 141 - Segregated Witness
    url: https://github.com/bitcoin/bips/blob/master/bip-0141.mediawiki
    author: Eric Lombrozo, Johnson Lau, Pieter Wuille
updatedAt: 2026-05-27T00:00:00Z
---

## base

Una transazione Bitcoin è un'istruzione firmata che spende bitcoin esistenti e crea nuovi punti da cui potranno essere spesi in futuro. Non sposta saldi tra account. Consuma output di transazioni precedenti e crea nuovi output con condizioni di spesa proprie.

![Flusso di input e output di una transazione](media/wiki/transactions/transaction-flow.svg "Una transazione consuma output precedenti come input, crea nuovi output e lascia la differenza come fee per il miner.")

La maggior parte dei pagamenti ha almeno un input e due output: un output paga il destinatario e un altro rimanda il resto al wallet di chi spende. Il wallet firma gli input per dimostrare di poter soddisfare le condizioni degli output che vengono spesi.

I nodi controllano le transazioni prima di inoltrarle e di nuovo quando un blocco le include. Verificano che gli input esistano, non siano già stati spesi, soddisfino gli script e non creino più satoshi di quanti ne spendono. Una transazione diventa più difficile da sostituire man mano che vengono aggiunti blocchi sopra quello che la contiene.

## medium

A livello di dati grezzi, una transazione contiene una versione, una lista di input, una lista di output e un locktime. Ogni input punta a un output precedente tramite un outpoint: l'ID della transazione precedente più l'indice dell'output. Ogni output contiene un valore in satoshi e uno script di blocco, spesso chiamato `scriptPubKey`.

La fee non è scritta in un campo separato. I nodi la calcolano come valore totale degli input spesi meno valore totale dei nuovi output. Se gli input valgono 100.000 sat e gli output sommano 98.500 sat, la fee è 1.500 sat.

I dati di sblocco dipendono dal tipo di output speso. Gli input legacy usano `scriptSig`; gli input SegWit mettono firme e altri dati nella struttura witness separata. Questa separazione cambia il calcolo del peso e degli identificatori, ma l'idea di base resta la stessa: gli input provano autorità, gli output definiscono autorità futura.

Una transazione può essere valida per consenso ma non essere inoltrata dalla policy mempool predefinita. Le regole di consenso decidono se una transazione può stare in un blocco. Le regole di policy decidono se un nodo vuole tenere o inoltrare una transazione non confermata prima che venga minata.

## advanced

La validazione di una transazione è una transizione di stato sull'insieme UTXO. Per ogni input non coinbase, un full node cerca l'outpoint referenziato, verifica che sia non speso, esegue i controlli di script richiesti e poi marca quella coin come spesa se la transazione viene collegata in un blocco valido. Gli output della transazione diventano nuovi UTXO.

Alcuni campi hanno senso solo nel contesto. `nLockTime` può impedire che una transazione sia finale fino a una certa altezza o soglia temporale. I valori di sequence degli input possono attivare timelock relativi e policy di sostituzione. Questi meccanismi non aggirano le firme; aggiungono vincoli temporali a quando una spesa altrimenti valida può essere accettata.

Anche gli identificatori sono sottili. Il `txid` tradizionale impegna la serializzazione senza witness. Le transazioni SegWit hanno anche un `wtxid` che impegna i dati witness. Questa distinzione riduce la malleabilità non desiderata per le spese SegWit preservando la compatibilità con i vecchi impegni delle transazioni.

Le transazioni coinbase sono l'eccezione alle normali regole sugli input. Creano il subsidy del blocco più le fee raccolte e hanno un input coinbase speciale invece di spendere un outpoint precedente. I loro output non possono essere spesi finché non maturano, così una reorg breve non invalida subito ricompense di mining appena create e già spese.

Il modello mentale importante è che le transazioni non sono messaggi d'intenzione. Sono rivendicazioni eseguibili su output precedenti. Se la rivendicazione è valida secondo le regole correnti ed entra nella chain valida con abbastanza lavoro dietro, l'insieme UTXO cambia di conseguenza.
