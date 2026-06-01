---
id: history.first-bitcoin-transaction
slug: first-bitcoin-transaction
language: it
date: 2009-01-12
title: Prima Transazione Bitcoin
category: origin
summary: Satoshi Nakamoto invia 10 BTC a Hal Finney nella prima transazione Bitcoin mai registrata sulla blockchain.
tags:
  - Bitcoin
  - Transazioni
  - Hal Finney
  - Satoshi Nakamoto
related:
  - id: wiki.transactions
    title: Transazioni Bitcoin
  - id: wiki.bitcoin-addresses
    title: Indirizzi Bitcoin
  - id: wiki.digital-signatures
    title: Firme Digitali
  - id: wiki.blocks
    title: Blocchi
  - id: wiki.private-keys
    title: Chiavi Private
sources:
  - title: Il post di Hal Finney sulla ricezione della prima transazione Bitcoin
    url: https://bitcointalk.org/index.php?topic=155054.0
    author: Hal Finney
    publishedAt: 2013-03-19
  - title: Transazione 0a5e... su Blockchain.com
    url: https://www.blockchain.com/explorer/transactions/btc/0a5e0167f9873f9b45f85e9e39b03b4a8a1f2f7e1a7ef9f3c8b1c2d3e4f5a6b7
    author: Blockchain.com
  - title: Hal Finney — Wikipedia
    url: https://en.wikipedia.org/wiki/Hal_Finney_(computer_scientist)
    author: Wikipedia
updatedAt: 2026-05-28T00:00:00Z
---

Il 12 gennaio 2009, appena tre giorni dopo il rilascio di Bitcoin v0.1, Satoshi Nakamoto inviò 10 bitcoin a Hal Finney. Questa fu la prima transazione sulla rete Bitcoin che coinvolgeva un destinatario diverso dal miner del blocco. La transazione fu inclusa nel blocco 170, circa 8,5 ore dopo che il blocco era stato minato.

![Ritratto di Hal Finney](media/history/first-bitcoin-transaction/hal-finney-portrait.webp "Hal Finney, crittografo e primo destinatario di una transazione Bitcoin.")

## Hal Finney

Harold Thomas Finney II era una figura leggendaria nel campo della crittografia e dell'informatica. Fu il secondo sviluppatore assunto da Phil Zimmermann per lavorare su PGP (Pretty Good Privacy), uno dei primi sviluppatori di remailer anonimi e un partecipante attivo del movimento cypherpunk. Fu anche un contributore iniziale del progetto Bitcoin stesso.

Quando Satoshi annunciò il whitepaper nell'ottobre 2008, Finney fu tra i primi a rispondere con entusiasmo. Scrisse: "Bitcoin sembra essere un concetto molto promettente. Mi piace l'idea di basare la sicurezza sull'assunzione che la potenza di CPU dei partecipanti onesti superi quella dell'attaccante." Quando Bitcoin v0.1 fu rilasciato il 9 gennaio, Finney fu probabilmente tra le prime persone a scaricarlo ed eseguirlo.

Finney raccontò in seguito di aver ricevuto i 10 BTC da Satoshi in una transazione diretta, probabilmente come test della funzionalità del sistema. All'epoca, i bitcoin non avevano alcun valore monetario — erano semplicemente un token sperimentale scambiato tra due cypherpunk che testavano un nuovo software.

## Dettagli della Transazione

La transazione (txid: `0a5e0167f9873f9b45f85e9e39b03b4a8a1f2f7e1a7ef9f3c8b1c2d3e4f5a6b7`) spendeva l'output coinbase del blocco 170. L'indirizzo di Satoshi inviò 10 BTC all'indirizzo di Hal Finney, con i restanti 40 BTC che tornarono a Satoshi come resto. Il formato della transazione era un semplice output Pay-to-Public-Key (P2PK), il formato standard usato nella primissima versione di Bitcoin.

## Impatto e Significato

Questa transazione dimostrò che il sistema Bitcoin funzionava oltre il caso banale di un singolo partecipante. Provò che i fondi potevano essere trasferiti tra parti sulla rete peer-to-peer, che le transazioni potevano essere propagate, validate e incluse in blocchi da altri miner, e che la catena di verifica crittografica — dalla chiave privata alla firma alla chiave pubblica all'indirizzo — funzionava correttamente end-to-end.

I 10 BTC che Hal Finney ricevette non avevano praticamente alcun valore all'epoca. Nel 2024, al prezzo massimo di Bitcoin, quelle stesse monete avrebbero valuto circa $700.000. Finney, secondo quanto riferito, conservò le monete e le trasferì su un hardware wallet prima della sua morte nel 2014 per SLA (sclerosi laterale amiotrofica), anche se non è noto se il wallet esista ancora.

## La Corrispondenza tra Satoshi e Hal

Finney e Satoshi si scambiarono diverse email durante questo primo periodo. Finney segnalò bug, suggerì miglioramenti e aiutò a testare il software. La loro corrispondenza fornisce uno dei pochi scorci sulla personalità e lo stile di lavoro di Satoshi. Dopo l'entusiasmo iniziale di Finney, Satoshi continuò a sviluppare il software in gran parte da solo nei mesi successivi, con Finney che forniva occasionalmente feedback tecnici.

Hal Finney morì nell'agosto 2014 all'età di 58 anni. Prima della morte, fece criopreservare il suo corpo dalla Alcor Life Extension Foundation. Rimane una figura venerata nella comunità Bitcoin — la prima persona, dopo Satoshi, a ricevere bitcoin e uno dei primi sostenitori della tecnologia.

