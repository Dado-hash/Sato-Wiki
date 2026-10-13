---
id: wiki.test-networks
slug: test-networks
language: it
category: protocol
title: Testnet, signet e regtest
description: Le reti che gli sviluppatori usano per testare il software Bitcoin con monete senza valore, e il compromesso tra realismo e prevedibilità di ciascuna.
coverImage: media/wiki/test-networks/test-networks-hero.svg
difficulty: base
readTimeMinutes: 5
tags:
  - Testnet
  - Signet
  - Regtest
  - Sviluppo
  - Reti di test
related:
  - wiki.developer-tools
  - wiki.node-software
  - wiki.bitcoin-addresses
  - wiki.blockchain
  - wiki.consensus-rules
sources:
  - title: "BIP 94: Testnet 4"
    url: https://github.com/bitcoin/bips/blob/master/bip-0094.mediawiki
    author: Fabian Jahr
    publishedAt: 2024-05-27
  - title: "BIP 325: Signet"
    url: https://github.com/bitcoin/bips/blob/master/bip-0325.mediawiki
    author: Karl-Johan Alm, Anthony Towns
  - title: Bitcoin Core 28.0 release notes
    url: https://github.com/bitcoin/bitcoin/blob/master/doc/release-notes/release-notes-28.0.md
    author: Bitcoin Core contributors
  - title: Bitcoin Core chain parameters (src/kernel/chainparams.cpp)
    url: https://github.com/bitcoin/bitcoin/blob/master/src/kernel/chainparams.cpp
    author: Bitcoin Core contributors
  - title: Testnet
    url: https://en.bitcoin.it/wiki/Testnet
    author: Bitcoin Wiki contributors
  - title: Signet
    url: https://bitcoinops.org/en/topics/signet/
    author: Bitcoin Optech
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

Gli sviluppatori devono testare wallet, nodi e software di pagamento senza rischiare denaro. Le reti di test rendono possibile tutto questo. Funzionano come la rete principale, con blocchi, transazioni e indirizzi, ma le loro monete non hanno valore di mercato. Ogni rete scambia un po' di realismo con un po' di prevedibilità.

La testnet è una rete pubblica a cui chiunque può unirsi. I suoi blocchi si trovano con proof of work, come sulla rete principale, ma è meno stabile. La sua storia include diversi reset, e la sua difficoltà può calare bruscamente, il che ha permesso raffiche di blocchi molto veloci. La testnet4 è l'attuale successore della testnet3.

La signet è una rete di test in cui ogni blocco deve portare anche una firma di una chiave scelta dal creatore della rete. La produzione dei blocchi è quindi prevedibile. La regtest è una chain privata su una sola macchina, dove l'utente crea blocchi quando serve, e questo la rende adatta ai test automatici.

Ogni rete ha i propri prefissi di indirizzo. Gli indirizzi bech32 su testnet e signet iniziano con tb1, e su regtest con bcrt1. Un wallet accurato verifica la rete di un indirizzo e rifiuta quello che appartiene a un'altra.

Le monete di test di solito arrivano dai faucet, cioè servizi che inviano piccole quantità a chi le chiede. Le monete di test non hanno valore.

## medium

La testnet3 mostra i limiti di una rete di test pubblica basata su proof of work. I suoi blocchi possono essere prodotti a basso costo, e il BIP 94 mira a rendere impraticabili gli attacchi che usano solo il mining su CPU, il che implica che lì fossero possibili. La regola della difficoltà minima permette di minare un blocco alla difficoltà più bassa quando per venti minuti non è apparso nessun blocco. Insieme, questi effetti producono block storm, raffiche di centinaia di blocchi, e lunghi intervalli.

Il BIP 94 specifica la testnet4 come sostituta della testnet3. Mantiene l'eccezione della difficoltà minima di 20 minuti, ma cambia l'aggiustamento della difficoltà. La base dell'aggiustamento viene dal primo blocco del periodo precedente, non dall'ultimo, e il primo blocco di ogni periodo deve usare la difficoltà effettiva della rete. Il BIP aggiunge anche una regola sul timestamp per il primo blocco di un periodo. La testnet4 segue le regole di consenso della rete principale in vigore a maggio 2024, con quei soft fork applicati dal blocco genesis.

Bitcoin Core 28.0 ha aggiunto il supporto alla testnet4. L'utente la seleziona con l'opzione testnet4, e il file di configurazione usa una sezione separata testnet4.

La signet, specificata nel BIP 325, funziona diversamente. La sua challenge script è impostata dal creatore e di solito è una chiave pubblica o un multisig. Ogni blocco deve soddisfarla oltre alla proof of work, e la soluzione è riportata in un commitment dentro la transazione coinbase. Il creatore decide quindi quando compaiono i blocchi. L'obiettivo del BIP è una quantità prevedibile di inaffidabilità, non l'assenza totale di problemi.

La regtest è una chain locale con un proprio blocco genesis e propri parametri, usata da un solo sviluppatore o da una sola suite di test. Non comunica con la rete pubblica.

I faucet sono il modo più comune per ottenere monete di test. Sono gestiti da singoli e progetti al di fuori del protocollo, e possono sparire o cambiare le proprie regole, quindi uno sviluppatore non dovrebbe dipenderne.

## advanced

I parametri di chain di Bitcoin Core mostrano come differiscono le reti. La rete principale usa 0 e 5 come byte di versione per gli indirizzi pay-to-public-key-hash e pay-to-script-hash. Testnet, testnet4, signet e regtest usano tutti 111 (0x6f) e 196 (0xc4), e 239 per le chiavi private. La human-readable part bech32 è bc sulla rete principale, tb su testnet, testnet4 e signet, e bcrt su regtest. Un indirizzo di testnet non è valido sulla rete principale, anche quando codifica lo stesso hash.

Il BIP 94 elenca tre eccezioni alle regole della rete principale. L'eccezione della difficoltà minima di 20 minuti resta, con il valore minimo di nBits 0x1d00ffff per i blocchi non iniziali di un periodo. La base dell'aggiustamento viene dal primo blocco del periodo precedente, il che elimina il reset che portava la difficoltà al minimo alla fine di un periodo. La regola sul timestamp del primo blocco di un periodo impedisce ai miner di manipolare i timestamp per abbassare la difficoltà.

La signet aggiunge un vincolo a livello di blocco. Un blocco supera i controlli normali e porta anche una soluzione alla challenge script. La soluzione è impegnata tramite il witness commitment della coinbase, quindi fa parte del blocco stesso. Il BIP costruisce la soluzione a partire da una transazione virtuale che spende un output il cui script è la challenge. Una signet personalizzata può usare una soluzione vuota quando la challenge è banalmente soddisfatta.

Poiché la challenge è uno script, una signet può richiedere un multisig k-di-n a un gruppo di operatori. Così più parti possono concordare quando compaiono i blocchi, il che è utile per i test di integrazione e per verificare i soft fork. Il compromesso è che i detentori delle chiavi controllano l'avanzamento della chain, quindi la signet è un ambiente fidato.

La regtest usa lo stesso motore di consenso con parametri di chain diversi. Il suo blocco genesis e i suoi parametri differiscono dalle reti pubbliche, quindi la produzione dei blocchi è sotto il controllo dello sviluppatore. I suoi risultati non possono essere letti come prova di come si comporterebbe la rete pubblica, e i test dovrebbero registrare quale rete ha prodotto ogni risultato.

Il software dovrebbe verificare la rete prima di inviare. La checksum protegge dagli errori di digitazione ma non rivela la rete, quindi il prefisso va letto. I wallet di test dovrebbero essere collegati alla rete per cui sono configurati e rifiutare destinazioni che appartengono a un'altra rete.
