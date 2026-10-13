---
id: wiki.coin-selection
slug: coin-selection
language: it
category: protocol
title: Output di resto e coin selection
description: Come un wallet sceglie quali UTXO spendere, dove va il resto e quali costi comportano queste scelte in fee e privacy.
coverImage: media/wiki/coin-selection/coin-selection-hero.svg
difficulty: base
readTimeMinutes: 5
tags:
  - Coin selection
  - Resto
  - UTXO
  - Privacy
related:
  - wiki.utxo-model
  - wiki.transactions
  - wiki.transaction-fees
  - wiki.common-input-ownership
  - wiki.address-reuse
sources:
  - title: Bitcoin Core coin selection implementation
    url: https://github.com/bitcoin/bitcoin/blob/master/src/wallet/coinselection.cpp
    author: Bitcoin Core contributors
  - title: "An Evaluation of Coin Selection Strategies"
    url: https://murch.one/erhardt2016coinselection.pdf
    author: Mark Erhardt
  - title: Coin selection
    url: https://bitcoinops.org/en/topics/coin-selection/
    author: Bitcoin Optech
  - title: Bitcoin Developer Reference - Transactions
    url: https://developer.bitcoin.org/reference/transactions.html
    author: Bitcoin.org contributors
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

Un UTXO non può essere diviso. Se un wallet possiede una moneta da 50.000 sat e vuole pagarne 20.000, la moneta viene spesa per intero. La differenza va in un nuovo output che il wallet controlla, detto resto o change. Il resto è un output come gli altri: aumenta la dimensione della transazione e crea una moneta in più, che dovrà essere spesa in seguito.

La coin selection è il passaggio in cui il wallet sceglie quali dei suoi UTXO spendere. L'insieme scelto deve coprire il pagamento e la fee. Una buona selezione bilancia più obiettivi: tenere bassa la fee, evitare di creare output troppo piccoli per essere spesi in modo conveniente, non rivelare informazioni sul wallet e mantenere ragionevole il numero di input.

Nessun metodo raggiunge tutti gli obiettivi. Alcuni wallet spendono per primi gli UTXO più vecchi, il che è semplice ma può costare di più in fee. Altri cercano una combinazione che corrisponda esattamente al pagamento, così non serve alcun resto, e ricorrono ad altri metodi quando una corrispondenza esatta non esiste.

Il consolidamento significa spendere molte monete piccole in un unico nuovo output. Ha senso quando le fee sono basse, perché aggiungere quegli input adesso costa meno di quanto costerebbe più tardi. Ha anche dei costi per la privacy, per questo i wallet non consolidano sempre.

## medium

Uno dei metodi di Bitcoin Core è il Branch and Bound. Cerca un insieme di input il cui totale cade in un intervallo: dal pagamento più la fee fino a quella cifra più il costo di creare e spendere in seguito un output di resto. Se un insieme cade in questo intervallo, la transazione può essere costruita senza resto. La ricerca percorre le combinazioni in profondità, si ferma presto quando un ramo non può migliorare il risultato migliore e si arrende dopo un numero fisso di tentativi.

Quando non si trova una corrispondenza senza resto, il wallet ha bisogno di un altro metodo. Bitcoin Core ha usato il Single Random Draw, che aggiunge monete in ordine casuale finché non raggiunge l'obiettivo. La tesi di Erhardt descrive il ripiego del Branch and Bound come equivalente a questo metodo. Le versioni più recenti di Bitcoin Core includono anche CoinGrinder, una strategia che cerca soluzioni con un output di resto.

La candidata migliore viene scelta con un punteggio di spreco. Il codice sorgente di Bitcoin Core lo definisce come gli input moltiplicati per la differenza tra il feerate attuale e un feerate di lungo periodo, più l'eccedenza rispetto al target. Quando il feerate attuale è sopra la stima di lungo periodo, ogni input in più costa più adesso di quanto costerà poi, quindi il punteggio favorisce meno input. Quando il feerate attuale è sotto, gli input extra costano poco e un insieme più grande diventa una scelta sensata.

Un importo di resto sotto il limite dust di solito non vale un nuovo output. La tesi di Erhardt descrive un metodo basato su un mescolamento casuale in cui un resto più piccolo del limite dust viene aggiunto alla fee invece di essere pagato al mittente. La transazione evita così un output che costerebbe più di quanto vale.

I wallet differiscono anche nelle preferenze. Bitcoin Core privilegia, per la privacy, insiemi di input fatti di un solo tipo di output, secondo Bitcoin Optech.

## advanced

La coin selection è un compromesso tra obiettivi che tirano in direzioni diverse. Lopp, come riassunto da Erhardt, elenca quattro obiettivi: evitare il gonfiamento della blockchain, sostenere un alto volume di transazioni, proteggere la privacy e minimizzare i costi. Spendere un UTXO grande riduce al minimo le fee ma lascia un piccolo resto. Spendere molte monete piccole riduce l'insieme degli UTXO e il numero di monete da tracciare, ma aumenta fee e numero di input. Nessun algoritmo soddisfa tutti e quattro gli obiettivi.

La privacy è l'obiettivo che dipende di più dalle scelte del wallet. Ogni input di una transazione è un indizio che tutti gli input appartengono allo stesso soggetto, ed è la base delle euristiche di common-input-ownership. Erhardt osserva che pagare un biglietto combinando più di cinquanta UTXO è un rischio per la privacy, mentre usare una moneta molto grande per un acquisto piccolo rivela più del necessario sulle disponibilità del wallet.

Il resto è la seconda fonte di perdita. Un output di resto spesso si distingue dal pagamento quando importi, tipi di script o riuso degli indirizzi rendono evidente la struttura. Lopp ha proposto di rendere il resto di dimensione uguale al pagamento, così un osservatore non può distinguerli dal valore. Erhardt nota che è il mittente a controllare la dimensione del resto, quindi questa può servire a plasmare l'insieme degli UTXO del wallet.

La coin selection deve anche evitare di riutilizzare, in pagamenti successivi e non correlati, monete create da transazioni precedenti. Bitcoin Optech descrive questo come un uso della coin selection a favore della privacy: tenere separati i gruppi di monete, così che un pagamento successivo non li unisca. Le regole deterministiche, come il primo entrato primo uscito o il più grande per primo, sono facili da prevedere, e Erhardt nota che i loro schemi possono rivelare il tipo di wallet e qualcosa sull'età o sulla dimensione delle sue monete.

La corrispondenza esatta è il risultato più forte per la privacy all'interno di una singola transazione. Se un insieme di input è uguale al pagamento più la fee, non esiste un output di resto che possa ricondurre al wallet. Contano quindi i metodi di ripiego, perché sono quelli che producono le transazioni con resto. Chi vuole un controllo più stretto può tenere separate le monete e scegliere gli input da sé con il coin control, invece di affidarsi all'algoritmo predefinito.
