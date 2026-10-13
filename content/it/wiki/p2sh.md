---
id: wiki.p2sh
slug: p2sh
language: it
category: protocol
title: Pay to Script Hash (P2SH)
description: Il tipo di output che impegna l'hash di uno script, così chi spende rivela le condizioni e un indirizzo semplice può bloccare fondi dietro uno script complesso.
coverImage: media/wiki/p2sh/p2sh-hero.svg
difficulty: advanced
readTimeMinutes: 5
tags:
  - P2SH
  - Script
  - Indirizzi
  - BIP 16
  - SegWit
related:
  - wiki.bitcoin-script
  - wiki.bitcoin-addresses
  - wiki.multisig
  - wiki.segregated-witness
  - wiki.taproot
sources:
  - title: "BIP 16: Pay to Script Hash"
    url: https://github.com/bitcoin/bips/blob/master/bip-0016.mediawiki
    author: Gavin Andresen
    publishedAt: 2012-01-03
  - title: "BIP 13: Address Format for pay-to-script-hash"
    url: https://github.com/bitcoin/bips/blob/master/bip-0013.mediawiki
    author: Gavin Andresen
  - title: "BIP 141: Segregated Witness (Consensus layer)"
    url: https://github.com/bitcoin/bips/blob/master/bip-0141.mediawiki
    author: Eric Lombrozo, Johnson Lau, Pieter Wuille
  - title: Bitcoin Developer Guide - Transactions
    url: https://developer.bitcoin.org/devguide/transactions.html
    author: Bitcoin.org contributors
  - title: "BIP 341: Taproot - SegWit version 1 spending rules"
    url: https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki
    author: Pieter Wuille, Jonas Nick, Anthony Towns
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

Un output pay-to-script-hash (P2SH) non dichiara per intero le proprie condizioni di spesa. Dichiara l'hash di 20 byte di uno script. Chi spenderà le monete in seguito deve mostrare lo script completo, detto redeem script, insieme ai dati che lo soddisfano. Il nodo calcola l'hash dello script rivelato e lo confronta con l'output. Se gli hash coincidono, lo script viene eseguito normalmente. Il redeem script deve coincidere esattamente con l'hash, quindi un solo byte di differenza rende le monete non spendibili. Lo script fa parte quindi della spesa, non dell'output, e diventa visibile solo quando le monete si muovono.

Questo disegno permette a chi paga di finanziare condizioni che non ha scritto. Un accordo multisig, per esempio, può essere bloccato dietro un unico hash breve che sta in una richiesta di pagamento o in un codice QR. Chi paga non deve conoscere lo script completo. La responsabilità di fornire le condizioni ricade su chi spende le monete, non su chi le paga.

Gli indirizzi P2SH usano Base58Check con byte di versione 5, quindi iniziano con il carattere 3 sulla mainnet. L'indirizzo non mostra quali condizioni richiede lo script. Chi vuole conoscere le condizioni deve vedere il redeem script, che viene rivelato solo quando le monete vengono spese.

## medium

Sulla blockchain, lo script di lock è OP_HASH160, un push di 20 byte con l'hash del redeem script, e OP_EQUAL. Per spendere, lo scriptSig dell'input inserisce le firme e i dati che il redeem script richiede, seguiti dal redeem script stesso. Il nodo verifica l'hash, poi esegue il redeem script con i dati inseriti. I nodi vecchi eseguono lo stesso controllo dell'hash, ed è per questo che la modifica è stata introdotta come soft fork.

Il redeem script è soggetto anche alla regola sui dati inseriti nello stack. Il BIP 16 stabilisce che nessun elemento inserito può superare i 520 byte, quindi un output P2SH non può essere speso se il suo redeem script supera i 520 byte. Questo limite conta per gli accordi multisig grandi. Per gli script più lunghi la soluzione è P2WSH, dove il witness script può arrivare a 10.000 byte.

SegWit ha aggiunto un modo per annidare un programma di witness dentro P2SH. Il BIP 141 descrive un programma P2WPKH avvolto in un output BIP 16, dove il redeem script è soltanto il byte di versione del witness e l'hash di 20 byte della chiave, mentre firma e chiave pubblica stanno nel witness. Questa forma annidata, spesso scritta P2SH-P2WPKH, appare all'esterno come un normale output P2SH, quindi può essere pagata dai wallet che non comprendono ancora gli indirizzi segwit. Anche il suo indirizzo inizia con 3.

Lo stesso schema, impegnare un hash e rivelare il contenuto al momento della spesa, compare nei tipi di output successivi, e chi spende porta sempre l'onere di dimostrare le condizioni. Un output P2SH può quindi nascondere un accordo complesso al prezzo di rivelarlo più tardi. P2WSH impegna il SHA-256 di un witness script, mentre gli output Taproot impegnano una chiave e un albero di script, così che la maggior parte delle spese non rivela nulla sui rami inutilizzati.

## advanced

Il BIP 16 descrive lo scopo di P2SH come lo spostamento della responsabilità di fornire le condizioni di riscatto da chi paga a chi spende. Chi paga finanzia qualunque transazione con un hash fisso di 20 byte, e chi spende fornisce in seguito lo script completo. Il BIP spiega che questo è utile per i codici QR e per il copia-incolla, e che evita di obbligare ogni mittente a conoscere ogni tipo di script.

L'attivazione fa parte del disegno. Il BIP stabilisce che le nuove regole di validazione si applicano ai blocchi con timestamp dal 1 aprile 2012 in poi. Le transazioni create prima di quella data possono non soddisfare le nuove regole, quindi vengono validate con le regole vecchie. Poiché i nodi vecchi controllano l'hash ma non lo script in sé, una transazione può risultare valida per il software vecchio e invalida per quello nuovo. Il BIP discute questo rischio, e la regola sul timestamp è parte della risposta.

Chi riceve le monete deve conservare anche il redeem script, perché l'hash da solo non sblocca nulla. Il limite di 520 byte per i push ha una conseguenza diretta. Uno script multisig con molte chiavi può essere troppo grande per essere un redeem script, quindi gli accordi grandi usano altri schemi. Il BIP nota che, per questo limite, un output P2SH può essere speso con al massimo 15 chiavi pubbliche compresse in un redeem script multisig. È una delle ragioni per cui i disegni successivi hanno spostato lo script nel witness, dove P2WSH permette script fino a 10.000 byte.

Il nesting segwit è un ponte di compatibilità. L'output esterno è un normale output P2SH con un indirizzo che inizia con 3, quindi il software che conosce solo P2SH può pagarlo. Il programma di witness dentro il redeem script è ciò che controlla il software compatibile con segwit. In quel caso l'hash esterno impegna un redeem script che è solo un byte di versione del witness e un hash di chiave. Gli output segwit nativi eliminano del tutto lo strato di hash esterno.

P2WSH mantiene lo stesso impegno tramite hash in un output segwit nativo, senza lo strato esterno. Taproot compie il passo successivo. La sua chiave di output impegna un albero di Merkle di script, e la spesa tramite key path rivela una sola firma. Il BIP 341 è il riferimento per come quell'output viene costruito e speso.
