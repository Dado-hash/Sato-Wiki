---
id: wiki.dust-and-op-return
slug: dust-and-op-return
language: it
category: protocol
title: Limite dust e OP_RETURN
description: La regola di policy che rende non conveniente inoltrare output minuscoli, e gli output OP_RETURN non spendibili usati per i dati, con le regole di standardness cambiate nel tempo.
difficulty: advanced
readTimeMinutes: 5
tags:
  - Dust
  - OP_RETURN
  - Policy
  - UTXO
related:
  - wiki.utxo-model
  - wiki.bitcoin-script
  - wiki.mempool
  - wiki.transaction-fees
  - wiki.consensus-rules
  - wiki.coin-selection
sources:
  - title: Bitcoin Core policy implementation
    url: https://github.com/bitcoin/bitcoin/blob/master/src/policy/policy.cpp
    author: Bitcoin Core contributors
  - title: Bitcoin Core 0.9.0 release notes
    url: https://github.com/bitcoin/bitcoin/blob/master/doc/release-notes/release-notes-0.9.0.md
    author: Bitcoin Core contributors
  - title: Bitcoin Core 0.12.0 release notes
    url: https://github.com/bitcoin/bitcoin/blob/master/doc/release-notes/release-notes-0.12.0.md
    author: Bitcoin Core contributors
  - title: Bitcoin Core 30.0 release notes
    url: https://github.com/bitcoin/bitcoin/blob/master/doc/release-notes/release-notes-30.0.md
    author: Bitcoin Core contributors
  - title: Bitcoin Wiki - Dust
    url: https://en.bitcoin.it/wiki/Dust
    author: Bitcoin Wiki contributors
  - title: "BIP 141: Segregated Witness (Consensus layer)"
    url: https://github.com/bitcoin/bips/blob/master/bip-0141.mediawiki
    author: Eric Lombrozo, Johnson Lau, Pieter Wuille
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

Il dust è un output così piccolo che spenderlo costerebbe in fee più di quanto l'output vale. La parola descrive una situazione economica, ma in Bitcoin Core indica anche una regola precisa di relay. Una transazione che crea output dust non viene inoltrata né inclusa in un blocco per impostazione predefinita. Poiché la regola è di policy, ogni nodo la applica da sé, e un miner può comunque includere un output dust contenuto in una transazione.

La ragione della regola è l'insieme UTXO. Ogni output non speso resta nell'insieme finché non viene speso, e ogni full node conserva quell'insieme nel proprio database. Un output che nessuno può permettersi di spendere impone il costo di archiviazione alla rete per tutto il tempo in cui resta lì. I limiti dust scoraggiano la creazione di questi output.

OP_RETURN è un tipo diverso di output. Il suo script lo marca come non spendibile, quindi nessuna transazione successiva potrà mai usarlo. Questo lo rende adatto ad allegare un piccolo dato a una transazione senza creare una moneta da tracciare. Poiché l'output non può essere speso, un nodo non deve conservarlo nell'insieme UTXO spendibile. Questi output sono soggetti a un limite di dimensione, che appartiene alla policy e che nel tempo è cambiato.

## medium

La soglia dust di Bitcoin Core dipende da un feerate, non è fissa in satoshi. Il feerate predefinito per il relay dust è 3.000 sat/kvB, cioè 3 sat/vB. Un output è dust quando il suo valore è inferiore al costo di spenderlo a quel feerate, cioè la sua dimensione serializzata più la dimensione tipica di un input che lo spenderebbe. I commenti nel codice sorgente indicano 546 satoshi per un tipico output P2PKH non segwit e 294 satoshi per un output P2WPKH, a questo feerate. Per i witness program, la dimensione stimata dell'input riceve lo sconto del SegWit.

Gli output con script non spendibile hanno soglia zero e non sono mai dust.

Il feerate dust è separato dal feerate minimo di relay. Bitcoin Core 30.0 ha abbassato quest'ultimo e il feerate incrementale, ma le sue note dicono che il feerate dust resta invariato.

OP_RETURN ha una storia di cambiamenti nella policy. Bitcoin Core 0.9, rilasciato nel 2014, ha iniziato a inoltrare gli output OP_RETURN come tipo di transazione standard. Le note di rilascio descrivono la modifica come la creazione di un output provabilmente eliminabile dall'insieme UTXO, pensato per impedire di archiviare dati arbitrari, come immagini, in output non spendibili che gonfiano il database UTXO. Le note precisano che la modifica non approva l'archiviazione di dati nella blockchain.

Bitcoin Core 0.12, rilasciato nel 2016, ha allentato ciò che può seguire OP_RETURN. Le versioni precedenti inoltravano un output solo se conteneva un singolo push di dati. La versione 0.12 ha permesso qualunque sequenza di push di dati e piccole costanti numeriche, e ha applicato il limite di dimensione all'intero scriptPubKey serializzato, che di default era di 83 byte. È il limite precedente di 80 byte più 3 byte di overhead.

Bitcoin Core 30.0, rilasciato nel 2025, ha alzato il valore predefinito di `-datacarriersize` a 100.000 byte, quindi il limite effettivo è la dimensione massima della transazione. Ha inoltre permesso più output OP_RETURN per transazione, con il limite sulla loro dimensione complessiva. Chi vuole il comportamento precedente può riportare l'opzione a 83.

## advanced

La distinzione tra consenso e policy conta soprattutto per i dati negli output. Le regole di consenso decidono se un blocco è valido, e il limite di dimensione dei blocchi è espresso come block weight, limitato a 4.000.000 di weight unit secondo BIP 141. In consenso, gli output OP_RETURN non sono trattati in modo speciale: contano per il block weight come qualunque altro output. Il limite di dimensione per singolo output, il numero di output OP_RETURN e la soglia dust sono tutti policy, che un nodo può mantenere o cambiare senza un fork.

Bitcoin Core 0.12 ha anche esentato gli output non spendibili dai controlli dust. Questo segue dalla regola della soglia: un output che non potrà mai essere speso non ha un costo di spesa con cui confrontare il suo valore. Lo stesso ragionamento spiega perché, nel codice attuale, la soglia dust per un output non spendibile è zero.

Le differenze di policy hanno effetti pratici. Una transazione con un output dust o con un output dati troppo grande viene rifiutata dai nodi che applicano la regola, quindi non si diffonde nella mempool. Un miner che la accetta può comunque includerla in un blocco, e il blocco sarà valido se sono rispettate le altre regole. I valori di policy determinano quindi quali transazioni raggiungono la maggior parte dei miner, non quali blocchi sono validi.

Il dust ha anche una dimensione legata al wallet. Gli attacchi dust inviano importi minuscoli a molti indirizzi, nella speranza che una spesa successiva li colleghi tra loro. I wallet possono nascondere o congelare gli output dust, così che la selezione automatica delle coin non li includa in una transazione in cui la fee potrebbe superare il loro valore. Anche la coin selection, descritta nella voce sugli output di resto, tratta diversamente un resto sotto la soglia dust, aggiungendolo alla fee invece di creare un nuovo output.

Il dibattito su OP_RETURN riflette una tensione del design di Bitcoin. Consentire output dati offre alle applicazioni un modo per allegare informazioni a una transazione, e rendere questi output provabilmente non spendibili li tiene fuori dall'insieme UTXO. Limitarne dimensione e numero impedisce che diventino un costo elevato per ogni nodo. Ciascuno di questi limiti è una scelta fatta nel software, ed è per questo che i limiti sono cambiati tra le release di Bitcoin Core mentre le regole di consenso per la validità dei blocchi sono rimaste le stesse.
