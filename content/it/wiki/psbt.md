---
id: wiki.psbt
slug: psbt
language: it
category: protocol
title: Transazioni parzialmente firmate (PSBT)
description: Un contenitore standard che trasporta una transazione non firmata e i dati di cui ogni firmatario ha bisogno, così dispositivi e programmi separati possono firmarla a turno.
difficulty: base
readTimeMinutes: 5
tags:
  - PSBT
  - Firma
  - Hardware wallet
  - Multisig
related:
  - wiki.transactions
  - wiki.multisig
  - wiki.hardware-wallets
  - wiki.software-wallets
  - wiki.sighash
sources:
  - title: "BIP 174: Partially Signed Bitcoin Transaction Format"
    url: https://github.com/bitcoin/bips/blob/master/bip-0174.mediawiki
    author: Ava Chow
    publishedAt: 2017-07-12
  - title: "BIP 370: PSBT Version 2"
    url: https://github.com/bitcoin/bips/blob/master/bip-0370.mediawiki
    author: Ava Chow
    publishedAt: 2021-01-14
  - title: Partially signed bitcoin transactions
    url: https://bitcoinops.org/en/topics/psbt/
    author: Bitcoin Optech
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

Una PSBT, cioè una partially signed Bitcoin transaction, è un formato di file che trasporta una transazione non firmata insieme alle informazioni di cui ogni firmatario ha bisogno per aggiungere la propria firma. Il formato è definito dal BIP 174. Una PSBT non è una transazione finita e non può essere trasmessa finché tutti gli input non sono firmati e assemblati.

Il formato esiste perché la firma spesso avviene altrove. Un wallet può costruire una transazione su un computer connesso a internet, mentre le chiavi stanno su un dispositivo air-gapped o su un hardware wallet. Senza un formato condiviso, ogni coppia wallet-firmatario avrebbe un proprio modo di scambiare i dati. Una PSBT permette a un programma di creare la transazione, a un firmatario compatibile di aggiungere la firma e a un altro programma di completarla.

Il BIP 174 è progettato perché un firmatario offline possa firmare senza accedere all'insieme UTXO completo e senza essere ingannato su ciò che la transazione fa. La PSBT porta i dati dell'output precedente, così il firmatario può verificare importi e destinazioni prima di firmare.

Ogni firmatario aggiunge solo le proprie firme. Usano questo flusso sia i setup multisig, in cui devono firmare più chiavi, sia le transazioni i cui input sono detenuti da wallet diversi. Una PSBT può viaggiare come file binario o come stringa Base64.

## medium

Il BIP 174 divide il lavoro in sei ruoli. Il creator costruisce la transazione non firmata con i campi di input e output vuoti. L'updater aggiunge i dati noti, come l'output che viene speso, gli script di riscatto e i witness script e i percorsi di derivazione BIP 32. Il signer aggiunge le firme parziali per gli input che controlla, e può solo aggiungere dati. Il combiner unisce più PSBT che contengono firme diverse in una sola, e rifiuta di unire due transazioni diverse. L'input finalizer costruisce lo scriptSig e lo scriptWitness finali di ogni input. Il transaction extractor trasforma una PSBT completamente finalizzata in una transazione serializzata per la rete. Un solo programma spesso svolge più ruoli, e un flusso multisig ripete di solito il ruolo di signer su dispositivi diversi.

Poiché il formato è standard, un software di un produttore può preparare una transazione che il dispositivo di un altro produttore firma. L'interoperabilità richiede che entrambe le parti leggano gli stessi campi. Il BIP 174 prevede che un signer faccia passare le coppie chiave-valore che non comprende, così strumenti più recenti possono aggiungere dati senza rompere quelli più vecchi.

Gli hardware wallet sono un esempio tipico di signer. Il dispositivo riceve la PSBT, legge output e fee, e restituisce le firme. Il dispositivo non ha bisogno di una connessione di rete, e la transazione non deve essere digitata a mano. Lo stesso flusso può usare un portatile, un telefono o un altro wallet come firmatario.

Il multisig è l'altro caso comune. Ogni cofirmatario riceve una copia della PSBT, vi aggiunge la propria firma parziale e la restituisce. Il combiner unisce le copie, e il finalizer completa l'input quando sono presenti abbastanza firme valide. Ogni cofirmatario può verificare la transazione con la propria copia dei dati.

Bitcoin Optech osserva che una PSBT può passare tra più partecipanti e che, nei wallet multisig, il passo di firma può essere ripetuto su copie diverse da programmi diversi.

## advanced

Il formato originale, la versione 0, fissa la transazione non firmata nella mappa globale. Input e output non possono quindi essere aggiunti dopo la creazione della PSBT. Il BIP 370 definisce la PSBT versione 2, che rimuove la transazione globale non firmata e colloca i dati di ogni input e output nella propria mappa. Il numero 2 è stato scelto per evitare confusione, perché la versione 0 viene spesso chiamata informalmente versione 1. Non esistono PSBT versione 1.

Un firmatario deve verificare diverse cose prima di firmare. Se è fornito un UTXO non segwit, il suo hash deve corrispondere al txid indicato dall'output precedente dell'input. Se è fornito un UTXO segwit, il firmatario non deve produrre una firma non segwit. Un redeem script deve corrispondere allo scriptPubKey dell'output, e un witness script deve corrispondere all'hash presente nell'output o nel redeem script. Se è presente un tipo di sighash, il firmatario deve accettarlo oppure fallire. Il BIP 174 suggerisce anche che il firmatario calcoli indirizzi, importi e fee, e li mostri all'utente prima di firmare.

Il controllo della fee conta perché il metodo di firma segwit del BIP 143 non copre gli importi degli altri input. Il BIP 174 registra che un attaccante potrebbe modificare quegli importi e così ingannare un utente, facendogli firmare transazioni dannose che inviano bitcoin alle fee. Molti wallet richiedono quindi la transazione precedente completa per ogni input. Bitcoin Optech elenca questo come l'attacco di overpayment della fee che ha portato a modifiche nella specifica.

Il firmatario può anche riconoscere gli output di resto confrontando i percorsi di derivazione e le chiavi pubbliche estese presenti nella PSBT con le proprie chiavi. Così un dispositivo può nascondere l'output di resto nella schermata di conferma, e l'utente controlla solo i pagamenti.

Una PSBT non protegge da tutto. È un contenitore e non una politica di sicurezza, quindi non può dire al firmatario quale fosse l'intenzione dell'utente. Un creator o un updater malevolo può inserire nella transazione un output fuorviante, e un firmatario che non verifica i dati lo firmerà. Il formato non è nemmeno privato: per progetto può contenere chiavi pubbliche estese e percorsi di derivazione, che rivelano la struttura del wallet a chiunque legga il file.
