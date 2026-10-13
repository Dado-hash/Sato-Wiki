---
id: wiki.coinbase-transaction
slug: coinbase-transaction
language: it
category: protocol
title: Transazione coinbase
description: La prima transazione di ogni blocco, che crea i nuovi bitcoin della subsidy del blocco e raccoglie le fee del blocco.
coverImage: media/wiki/coinbase-transaction/coinbase-transaction-hero.svg
difficulty: base
readTimeMinutes: 4
tags:
  - Coinbase
  - Mining
  - Ricompensa di blocco
  - Consenso
related:
  - wiki.blocks
  - wiki.block-subsidy
  - wiki.mining
  - wiki.segregated-witness
  - wiki.utxo-model
  - wiki.block-header
sources:
  - title: Bitcoin Developer Guide - Block Chain
    url: https://developer.bitcoin.org/devguide/block_chain.html
    author: Bitcoin.org contributors
  - title: Bitcoin Developer Reference - Block Chain
    url: https://developer.bitcoin.org/reference/block_chain.html
    author: Bitcoin.org contributors
  - title: "BIP 34: Block v2, Height in Coinbase"
    url: https://github.com/bitcoin/bips/blob/master/bip-0034.mediawiki
    author: Gavin Andresen
  - title: "BIP 141: Segregated Witness (Consensus layer)"
    url: https://github.com/bitcoin/bips/blob/master/bip-0141.mediawiki
    author: Eric Lombrozo
  - title: Bitcoin Core transaction primitives
    url: https://github.com/bitcoin/bitcoin/blob/master/src/primitives/transaction.h
    author: Bitcoin Core contributors
  - title: Bitcoin Wiki - Coinbase
    url: https://en.bitcoin.it/wiki/Coinbase
    author: Bitcoin Wiki contributors
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

Ogni blocco inizia con una transazione speciale chiamata transazione coinbase. Il miner la crea mentre compone il blocco, ed è l'unica transazione che non spende output esistenti. Il suo unico input ha un outpoint nullo, un segnaposto con hash tutto a zero e l'indice più grande possibile, quindi non punta a nulla. È così che la coinbase crea nuovi bitcoin.

La coinbase incassa la ricompensa del blocco: la subsidy del blocco più le fee pagate dalle altre transazioni del blocco. I nodi rifiutano il blocco se la coinbase reclama più di questo totale. Un miner può reclamare di meno, e la differenza va semplicemente perduta.

Gli output della coinbase non possono essere spesi finché non sono sepolti da 100 blocchi. La regola protegge la rete dalle riorganizzazioni. Se il blocco che ha pagato il miner viene sostituito da un ramo concorrente, i nuovi coin che ha creato scompaiono con esso, quindi spenderli subito potrebbe invalidare altre transazioni.

Il campo dati dell'input della coinbase è per il resto libero. Dal 2013 l'altezza del blocco deve comparire al suo inizio, e questo rende ogni coinbase unica. I miner possono inserirvi anche byte arbitrari, ed è per questo che il blocco genesis contiene il titolo di un giornale.

## medium

L'input della coinbase è insolito nella struttura oltre che nello scopo. Il suo outpoint è nullo: l'hash è composto da 32 byte a zero e l'indice è 0xffffffff. Poiché non c'è un output precedente, non c'è nulla da cercare nell'insieme UTXO e nessuna firma da verificare.

La regola sull'altezza deriva da BIP 34. Il primo elemento dello script della coinbase deve essere l'altezza del blocco, codificata come numero di script serializzato nella forma minima, in ordine little-endian. BIP 34 è stata una soft fork: dopo la sua attivazione, i blocchi che non seguivano la regola sono stati rifiutati. Poiché due blocchi a altezze diverse non possono avere lo stesso contenuto nella coinbase, ogni transazione coinbase è unica.

Il resto dello script della coinbase è spazio che il miner può usare. I miner lo usano come extra nonce: il nonce dell'header è di soli 32 bit, quindi il miner modifica i dati della coinbase, il che cambia la Merkle root e quindi l'hash dell'header. La Developer Reference descrive questo metodo per esplorare l'intero intervallo del nonce. La coinbase può contenere anche byte arbitrari, come mostra il titolo nel blocco genesis.

Il witness commitment deriva da BIP 141. Quando un blocco contiene transazioni segwit, la coinbase deve includere un output il cui script inizia con 0x6a24aa21a9ed. Sono l'opcode OP_RETURN, un push di 36 byte e l'intestazione del commitment a 4 byte 0xaa21a9ed. Segue un hash di 32 byte della radice dei witness e di un valore riservato. Il valore riservato è composto da 32 byte che si trovano nel witness dell'input della coinbase. I nodi verificano questo commitment, quindi i dati dei witness sono vincolati alla proof of work del blocco.

Una coinbase che paga troppo è invalida, e lo è anche un blocco con un witness commitment non corretto. Una coinbase che paga troppo poco è valida, ma il valore non reclamato viene distrutto.

## advanced

La validazione tratta la coinbase come un caso speciale. Non ha input da confrontare con l'insieme UTXO, e il suo controllo sul valore, a differenza di quello di qualsiasi transazione ordinaria, dipende dal resto del blocco. Ogni full node ripete da sé questo calcolo, quindi nessun miner può ottenere più di quanto consente la regola affermando un totale più alto.

La maturazione viene applicata quando una transazione successiva spende un output della coinbase. L'output non può essere usato finché non sono stati costruiti almeno 100 blocchi sopra quello che lo ha creato. Ciò significa che una riorganizzazione breve non può invalidare una transazione che ha già speso coin della coinbase.

BIP 34 serve anche all'unicità. Poiché l'altezza cambia da un blocco all'altro, cambia anche il contenuto della coinbase, quindi il txid di ogni coinbase è diverso. Il txid della coinbase è sempre la prima foglia dell'albero di Merkle del blocco, quindi la coinbase è anche il primo elemento che l'header impegna.

Il witness commitment è un hash di due valori: la radice dei witness, cioè la Merkle root di tutti i wtxid, e il valore riservato. BIP 141 definisce il wtxid della coinbase stessa come 32 byte a zero, il che evita una dipendenza circolare. Il commitment è inserito nella coinbase anziché nell'header, e questo rende la modifica una soft fork: i nodi vecchi vedono soltanto un output in più che non verificano. Il valore riservato è lasciato libero per future soft fork. BIP 141 stabilisce che i commitment non necessari al consenso, come i dati del merge-mining, non devono usarlo, così che gli aggiornamenti futuri restino possibili.

Modificare la coinbase cambia la Merkle root e quindi l'hash dell'header. Per questo il rolling dell'extra nonce funziona senza alcuna modifica alle regole di consenso.

La coinbase rende i miner l'unica fonte di nuovi coin. Le regole di consenso fissano quanto possono prendere, ma non quanto scelgono di prendere. In questo modo il calendario della subsidy resta applicabile: ogni blocco che crea troppi bitcoin è invalido, e ogni full node lo verifica in modo indipendente.
