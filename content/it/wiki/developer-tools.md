---
id: wiki.developer-tools
slug: developer-tools
language: it
category: software
subcategory: developer-tools
title: Librerie e strumenti per sviluppatori
description: Le librerie, le interfacce del nodo e le reti di test usate dagli sviluppatori per costruire software Bitcoin, e i rischi di dipenderne.
difficulty: base
readTimeMinutes: 5
tags:
  - Sviluppatori
  - Librerie
  - Testing
  - Supply chain
related:
  - wiki.secp256k1
  - wiki.bitcoin-script
  - wiki.consensus-rules
  - wiki.software-wallets
  - wiki.transactions
sources:
  - title: Bitcoin Dev Kit - repository README
    url: https://github.com/bitcoindevkit/bdk
    author: Bitcoin Dev Kit contributors
  - title: rust-bitcoin - repository README
    url: https://github.com/rust-bitcoin/rust-bitcoin
    author: rust-bitcoin contributors
  - title: libsecp256k1 - repository README
    url: https://github.com/bitcoin-core/secp256k1
    author: Bitcoin Core contributors
  - title: bitcoinjs-lib - repository README
    url: https://github.com/bitcoinjs/bitcoinjs-lib
    author: bitcoinjs contributors
  - title: "BIP 174: Partially Signed Bitcoin Transaction Format"
    url: https://github.com/bitcoin/bips/blob/master/bip-0174.mediawiki
    author: Ava Chow
  - title: Bitcoin Developer Examples - Testing Applications
    url: https://developer.bitcoin.org/examples/testing.html
    author: Bitcoin.org contributors
updatedAt: 2026-10-13T00:00:00Z
reviewedAt: 2026-10-13
---

## base

Le librerie e gli strumenti per sviluppatori sono i mattoni usati per scrivere software Bitcoin. Una libreria è codice che importi nel tuo programma, così non devi scrivere da zero la verifica delle firme, il parsing delle transazioni o la codifica degli indirizzi. La maggior parte di wallet, explorer e strumenti di pagamento dipende da uno o più di questi componenti, anche quando i loro utenti non li vedono mai.

Alcune librerie coprono una parte specifica del lavoro. Il Bitcoin Dev Kit fornisce i mattoni per wallet basati su descrittori ed è costruito su rust-bitcoin, che gestisce codifica, script, chiavi e transazioni. libsecp256k1 è la libreria C che esegue firma e verifica sulla curva secp256k1. bitcoinjs-lib offre mattoni simili per il codice JavaScript.

Gli sviluppatori hanno bisogno anche di un luogo sicuro per i test. Bitcoin Core può girare su testnet, dove le monete non hanno valore reale, oppure in regtest, una chain privata in cui crei blocchi quando vuoi. Il comando bitcoin-cli invia richieste RPC a un nodo in esecuzione, quindi uno script può leggere saldi o creare blocchi senza un'interfaccia grafica.

Scegliere una libreria è un compromesso tra funzionalità, linguaggio di programmazione e quanta revisione ha ricevuto il codice. Leggi cosa dichiara di essere ogni progetto, e non dare per scontato che una libreria per wallet sia adatta a validare la chain Bitcoin.

## medium

Una libreria tipica copre diversi livelli. La gestione delle chiavi include la derivazione gerarchica deterministica secondo il BIP 32, che rust-bitcoin supporta in modo completo. Il codice di script e transazioni gestisce serializzazione, parsing e script. I descrittori descrivono gli script che un wallet deve tracciare e firmare, e BDK costruisce attorno a essi la logica del wallet. I dati della chain arrivano al wallet tramite un backend, e BDK può recuperarli da un server Esplora o da un server Electrum.

Bitcoin Core espone le proprie funzioni tramite RPC, e bitcoin-cli è il client a riga di comando per quell'interfaccia. Un programma può chiamare gli stessi metodi RPC, quindi un'applicazione può essere testata contro un nodo reale invece che contro una reimplementazione. Fissare la versione del nodo usata dall'applicazione fa parte di questa configurazione, perché metodi RPC e output possono cambiare tra una release e l'altra.

Le transazioni parzialmente firmate sono il modo in cui il software passa una transazione tra più firmatari. Il BIP 174 definisce un formato binario che contiene le informazioni necessarie a un firmatario, e ciascuno aggiunge le proprie firme finché la transazione è completa. Il formato permette a un firmatario di lavorare offline, perché tutti i dati necessari viaggiano dentro la transazione.

I test occupano gran parte del lavoro degli sviluppatori. La documentazione per sviluppatori di bitcoin.org descrive la testnet come una rete pubblica in cui le monete non hanno valore reale, e segnala che la testnet allenta alcuni controlli sulle transazioni standard, quindi il comportamento può differire dal mainnet. La regtest è una chain privata pensata per le situazioni in cui l'interazione con peer casuali non serve, e lo sviluppatore genera blocchi con comandi come generatetoaddress. La stessa documentazione nota che molti sviluppatori considerano la regtest il modo preferito per costruire nuove applicazioni.

Tieni i test separati dai fondi reali. Esegui gli esperimenti su regtest o testnet, e fai un backup di qualsiasi wallet mainnet prima di un'operazione pericolosa come cancellare dati, come consiglia la documentazione.

## advanced

Il limite più importante di una libreria generica è il consenso. Il README di rust-bitcoin dice che la libreria non deve essere usata per il codice di consenso, cioè per il codice che valida completamente i dati della blockchain. Afferma che la libreria supporta tecnicamente questa validazione, ma che si discosta dall'implementazione di riferimento di Bitcoin Core in modi noti e ignoti, e che non riprodurrà le regole di Core. Il consenso deve essere identico su tutti i nodi, quindi una reimplementazione indipendente può accettare o rifiutare blocchi in modo diverso dalla rete. Per questo compito usa Bitcoin Core, o valida tramite un nodo di cui ti fidi.

Costruire transazioni è un lavoro diverso dal validarle. Una libreria può costruire una transazione valida secondo il consenso ma non inoltrata dai nodi predefiniti perché non rispetta la policy. Una transazione non standard per policy può comunque essere valida se un miner la include in un blocco valido. Gli sviluppatori dovrebbero separare i due controlli nel codice e non usare il rifiuto locale come prova di invalidità.

Il codice crittografico richiede la stessa cautela. libsecp256k1 punta a essere una libreria ad alta garanzia per secp256k1, con firma a tempo costante e ECDSA derandomizzato, e include moduli opzionali per le firme Schnorr del BIP 340, per ElligatorSwift del BIP 324 e per MuSig2. Il progetto afferma inoltre che un uso corretto richiede attenzione e che usi diversi da quelli di Bitcoin possono essere testati meno. Usare correttamente una primitiva ben revisionata conta più della scelta della libreria.

I backend della chain sono un punto di fiducia. Un wallet che chiede a un server remoto lo storico delle transazioni dipende da ciò che quel server restituisce. Se la libreria verifica la risposta o si limita a fidarsene dipende dal backend e dalla configurazione. Gli sviluppatori dovrebbero documentare quale backend usano e cosa verifica.

Il rischio di supply chain nasce da ogni dipendenza. Il README di bitcoinjs-lib dice che solo le release taggate sono stabili, che il ramo master è un ramo di sviluppo e che gli utenti dovrebbero verificare il codice e le proprie dipendenze. Il README di rust-bitcoin raccomanda di verificare le dipendenze con cargo-crev. Ogni crate o pacchetto aggiunto è codice che gira con accesso alle chiavi, quindi il numero di dipendenze è una decisione di sicurezza. Fissa le versioni, rivedi gli aggiornamenti e preferisci alberi di dipendenze piccoli quando il progetto lo consente.
