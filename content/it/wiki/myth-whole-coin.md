---
id: wiki.myth-whole-coin
slug: myth-whole-coin
language: it
category: myths
title: '"Bisogna comprare un bitcoin intero"'
description: "Falso: un bitcoin si divide in 100.000.000 di satoshi, e il software registra ogni importo in satoshi."
difficulty: base
readTimeMinutes: 5
tags:
  - Miti
  - Unità
  - Satoshi
  - Commissioni
related:
  - wiki.transactions
  - wiki.dust-and-op-return
  - wiki.weight-units
  - wiki.transaction-fees
  - wiki.lightning-network
sources:
  - title: Bitcoin Core consensus amounts
    url: https://github.com/bitcoin/bitcoin/blob/master/src/consensus/amount.h
    author: Bitcoin Core contributors
  - title: "BIP 176: Bits Denomination"
    url: https://github.com/bitcoin/bips/blob/master/bip-0176.mediawiki
    author: Jimmy Song
    publishedAt: 2017-12-12
  - title: Bitcoin Wiki - Units
    url: https://en.bitcoin.it/wiki/Units
    author: Bitcoin Wiki contributors
  - title: Lightning BOLT 00 - Introduction
    url: https://github.com/lightning/bolts/blob/master/00-introduction.md
    author: Lightning Network contributors
  - title: Developer Guide - Transactions
    url: https://developer.bitcoin.org/devguide/transactions.html
    author: Bitcoin.org contributors
  - title: Bitcoin Core policy implementation
    url: https://github.com/bitcoin/bitcoin/blob/master/src/policy/policy.cpp
    author: Bitcoin Core contributors
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

Falso. Non serve comprare un bitcoin intero. Un bitcoin si divide in 100.000.000 di satoshi, e il software registra ogni importo in satoshi. Chiunque può detenere, inviare o ricevere una frazione di moneta, fino a un singolo satoshi. Il prezzo di una moneta intera non dice nulla, da solo, sul costo di un importo piccolo.

La divisione nasce nel software. Bitcoin Core definisce una moneta come 100.000.000 unità di base, quindi otto cifre decimali separano una moneta dalla sua unità più piccola. Gli output di una transazione dichiarano il loro valore in satoshi. Un wallet può mostrare un importo come BTC, millibitcoin, bit o satoshi, ma il valore sottostante è un numero intero di satoshi. I nomi delle unità sono convenzioni di visualizzazione. Non sono valute diverse.

Esistono limiti pratici. Un output molto piccolo può costare più di quanto vale per essere speso, e i nodi che applicano le regole di relay predefinite non lo inoltrano. Anche le commissioni fissano una soglia minima di convenienza sulla chain principale. Questi limiti riguardano quali pagamenti hanno senso in un dato momento. Non impediscono di possedere una frazione di moneta. Una moneta intera è semplicemente un punto di riferimento, come un euro lo è con i centesimi sotto di esso.

## medium

I nomi principali delle unità sono BTC per un bitcoin, mBTC per un millesimo di bitcoin, bit per un milionesimo di bitcoin e satoshi per un centomilionesimo. Il Bitcoin Wiki elenca questi nomi e i simboli collegati, e osserva che satoshi e sat indicano l'unità più piccola. BIP 176 formalizza il bit come 100 satoshi, ed è stata scritta in parte per ridurre la tendenza a ragionare in monete intere e per rendere più leggibili gli importi piccoli.

La rete Lightning usa internamente un'unità più piccola. Le specifiche BOLT definiscono il millisatoshi, cioè un millesimo di satoshi, e lo usano in campi di messaggio come amount_msat. Questo permette di esprimere saldi di canale e importi di pagamento con più precisione del satoshi del livello base. Il livello base regola ancora in satoshi interi, e l'apertura e la chiusura dei canali avvengono on chain.

Sul livello base il minimo pratico dipende da due cose. La prima è il limite di dust. Il codice di policy di Bitcoin Core calcola una soglia di dust a partire da un feerate, quindi un output è dust quando il suo valore è inferiore al costo di spenderlo a quella tariffa. Quella tariffa è un'impostazione di relay di ogni nodo, non la fee di mercato del giorno: la soglia è quindi una scelta di policy che chi gestisce un nodo può cambiare. La seconda è la commissione stessa, misurata in satoshi per virtual byte. Un pagamento la cui commissione supererebbe il suo valore non è conveniente. La fee cambia con il mercato e la tariffa di dust è un'impostazione, quindi nessun numero fisso vale per sempre.

La guida per sviluppatori descrive il protocollo in satoshi, con ogni output che dichiara il proprio importo in satoshi.

Il prezzo unitario di una moneta intera è una quotazione di mercato in una certa valuta. Il costo in valuta fiat di un satoshi è quel prezzo diviso per 100.000.000, e il costo di un pagamento piccolo dipende da quanti satoshi sposta e dal feerate di quel giorno. Chi guarda solo il prezzo di una moneta sbaglia la valutazione dei piccoli importi, che è il problema di usabilità descritto da BIP 176.

## advanced

La versione più forte di questa affermazione non riguarda il software, ma l'accesso. Molte persone non possono acquistare facilmente una moneta intera, e la percezione di doverla comprare può scoraggiare la partecipazione. Secondo questa lettura il sistema delle unità è una barriera, anche se il protocollo è divisibile. BIP 176 indica la stessa preoccupazione, elencando tra le sue motivazioni la riduzione del "unit bias" per chi vuole un bitcoin intero e il rischio di errore quando importi piccoli vengono mostrati in unità grandi. La preoccupazione è reale sul piano della presentazione.

La risposta separa tre cose che l'affermazione mescola. La divisibilità è una proprietà del protocollo, che conta satoshi interi. La visualizzazione è una scelta di ogni wallet e di ogni interfaccia. La dimensione economica minima di un pagamento on chain dipende da commissioni e policy in un dato momento. Un output espresso in satoshi è valido per il consenso, ma un nodo può rifiutarsi di inoltrare un output troppo piccolo per essere speso con convenienza secondo la sua policy. La policy può cambiare senza un fork, quindi il minimo pratico non è una proprietà fissa del sistema.

L'obiezione seria a questa risposta è che la distinzione è tecnicamente netta ma socialmente debole. L'utente non vede il protocollo direttamente. Vede l'interfaccia, e se l'interfaccia mostra otto cifre decimali l'utente può leggere male l'importo. La risposta è che un wallet può mostrare satoshi o bit senza cambiare il protocollo.

Una seconda obiezione sostiene che le commissioni on chain possono rendere poco pratici i pagamenti piccoli, anche se il protocollo li consente. La risposta è che si tratta di un fatto del mercato delle commissioni, che dipende dalle condizioni del momento, e che livelli come Lightning permettono importi più fini dentro i canali, con regolamento on chain solo all'apertura e alla chiusura. L'obiezione replica che anche i canali richiedono fondi on chain, quindi la soglia si sposta senza sparire.

L'affermazione diventerebbe vera in senso protocollare se il consenso non ammettesse importi inferiori a una moneta, per esempio se gli output dovessero essere numeri interi di bitcoin. Diventerebbe vera in senso economico se le commissioni rendessero per lunghi periodi non spendibili tutti gli output on chain sotto una certa dimensione, senza un altro livello in grado di trasportare pagamenti più piccoli. Con le regole attuali e il software citato, l'affermazione è falsa: gli importi sono numeri interi in satoshi, e la dimensione minima di un pagamento dipende da policy e commissioni che cambiano nel tempo.
