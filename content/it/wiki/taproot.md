---
id: wiki.taproot
slug: taproot
language: it
category: protocol
title: Taproot
description: Un aggiornamento di Bitcoin che rende complesse condizioni di spesa indistinguibili da quelle semplici sulla chain, migliorando la privacy e riducendo le commissioni.
coverImage: media/wiki/taproot/taproot-hero.svg
difficulty: advanced
readTimeMinutes: 10
tags:
  - Taproot
  - Schnorr
  - MAST
  - BIP
  - Privacy
  - Smart Contract
related:
  - wiki.transactions
  - wiki.bitcoin-script
  - wiki.segwit
sources:
  - title: "BIP 341 - Taproot: SegWit version 1 spending rules"
    url: https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki
    author: Pieter Wuille, Jonas Nick, Anthony Towns
    publishedAt: 2021-01-21
  - title: "BIP 342 - Validation of Taproot scripts"
    url: https://github.com/bitcoin/bips/blob/master/bip-0342.mediawiki
    author: Pieter Wuille, Jonas Nick, Anthony Towns
    publishedAt: 2021-01-21
  - title: "BIP 343 - Bech32m format"
    url: https://github.com/bitcoin/bips/blob/master/bip-0343.mediawiki
    author: Pieter Wuille
    publishedAt: 2021-01-21
  - title: "BIP 340 - Schnorr Signatures"
    url: https://github.com/bitcoin/bips/blob/master/bip-0340.mediawiki
    author: Pieter Wuille, Jonas Nick, Tim Ruffing
    publishedAt: 2021-01-21
  - title: "Taproot — Bitcoin Optech"
    url: https://bitcoinops.org/en/topics/taproot/
    author: Bitcoin Optech contributors
updatedAt: 2026-05-27T00:00:00Z
---

## base

Taproot è un aggiornamento di Bitcoin attivato nel novembre 2021 che cambia il modo in cui gli output possono essere spesi. Prima di Taproot, se creavi un output con più condizioni di spesa — per esempio "Alice può spendere da sola OPPURE due persone su tre devono essere d'accordo" — la blockchain doveva mostrare ogni possibile condizione nel momento in cui l'output veniva creato.

Taproot ribalta questo concetto. Tutte le possibili condizioni di spesa sono impegnate off-chain usando una struttura dati chiamata Merkle tree. L'output sulla chain sembra un semplice pagamento a firma singola per chiunque lo osservi. Le condizioni reali vengono rivelate solo quando vengono effettivamente usate.

Questo porta due vantaggi: la privacy migliora perché la maggior parte delle transazioni sono indistinguibili, e le commissioni diminuiscono perché gli script complessi restano off-chain finché non servono.

![Struttura di commitment Taproot](media/wiki/taproot/taproot-hero.svg "Un output Taproot impegna una chiave interna e un Merkle tree di script. La spesa più semplice usa solo il key path.")

Gli output Taproot usano il formato di indirizzo che inizia con `bc1p` e sono il terzo tipo principale di output dopo legacy e SegWit.

## medium

Taproot introduce un nuovo tipo di output chiamato Pay-to-Taproot (P2TR) che è SegWit versione 1. Si basa su due primitive crittografiche: le firme Schnorr e MAST (Merkelized Abstract Syntax Tree).

Il concetto chiave è la distinzione tra una spesa tramite key path e una tramite script path. Ogni output Taproot contiene una chiave pubblica interna P e impegna un Merkle tree di percorsi di script. La chiave di output effettiva che finisce sulla chain è Q = P + t*G, dove t è un hash derivato dalla radice del Merkle tree. Chiunque veda questo output non può distinguere se si tratta di un semplice pagamento a firma singola o di un output con dozzine di condizioni di spesa complesse.

Nel caso cooperativo — il key path — chi spende produce una singola firma Schnorr con la chiave P. Questa è sempre la spesa più economica e privata: 64 byte più un input, indistinguibile da qualsiasi altra spesa Taproot.

Se il percorso cooperativo non è possibile — per esempio una delle parti rifiuta di firmare — chi spende può rivelare uno degli script path. Questo richiede di rivelare lo script stesso e la prova Merkle che dimostra che appartiene all'albero. La prova consiste negli hash fratelli lungo il percorso dalla foglia dello script alla radice del Merkle tree. Questa spesa è più grande di un key path spend e rende visibili le condizioni di spesa sulla chain.

Le firme Schnorr portano un ulteriore beneficio: l'aggregazione delle firme. In un accordo multisignature tramite key path, più firmatari possono produrre un'unica firma aggregata identica a una firma singola. Questo è molto più compatto dell'approccio CHECKMULTISIG delle transazioni legacy.

Gli indirizzi Taproot usano la codifica Bech32m, una modifica del formato Bech32 usato per gli indirizzi SegWit. Bech32m corregge un problema subdolo per cui Bech32 non poteva rilevare affidabilmente errori in indirizzi con dati di lunghezza variabile.

## advanced

Taproot è specificato attraverso tre BIP che lavorano insieme: BIP 341 (regole di spesa), BIP 342 (validazione script) e BIP 343 (codifica indirizzi). Un quarto BIP, il 340, specifica l'algoritmo di firma Schnorr usato dal key path.

**BIP 341 — Costruzione della chiave di output.** La chiave di output Q è calcolata come Q = P + t*G, dove P è la chiave pubblica interna e t è l'hash TapTweak. Il tweak è definito come t = H_tag("TapTweak", P || m), dove m è la radice del Merkle tree degli script. Se non ci sono script path, m è sostituito da una stringa vuota e l'output è chiamato output a *chiave interna grezza* — un output puro key path senza script nascosti.

Il Merkle tree è un albero binario dove ogni foglia è un tag di versione script concatenato con lo script. I nodi interni sono hash della concatenazione degli hash dei figli sinistro e destro. L'albero non deve essere bilanciato; BIP 341 definisce una codifica di control block che permette al verificatore della spesa di ricostruire il percorso nell'albero.

**BIP 342 — Modifiche a Script.** Taproot usa una nuova versione di Script che include miglioramenti significativi:

- L'opcode OP_CHECKSIGADD sostituisce il vecchio pattern CHECKMULTISIG. Nello Script legacy, la verifica multisignature richiedeva di contare il numero di firme valide e confrontarlo con la soglia richiesta. OP_CHECKSIGADD semplifica questo processo incrementando un contatore direttamente. Questo elimina anche il bug off-by-one che affliggeva CHECKMULTISIG, dove il numero di chiavi pubbliche doveva essere posto prima del numero di firme.

- Il conteggio delle operazioni di firma è rimosso. Le regole legacy di consenso limitavano il numero di controlli di firma per transazione. BIP 342 sostituisce questo con un modello di costo di esecuzione basato sul lavoro effettivo svolto durante la valutazione dello script.

- L'algoritmo di firma Schnorr sostituisce ECDSA per gli input Taproot. Schnorr è dimostrabilmente sicuro nel modello dell'oracolo casuale, supporta l'aggregazione delle firme, è non malleabile per design ed è più veloce da verificare in batch.

**BIP 343 — Bech32m.** Il formato nativo di indirizzo SegWit Bech32 aveva un limite di design: quando la porzione di dati si estendeva oltre una certa lunghezza, la rilevazione degli errori degradava significativamente. Bech32m modifica il modulo costante usato nel checksum da 1 a 0x3bc6a, ripristinando una robusta rilevazione errori per tutte le lunghezze di indirizzo. Gli indirizzi Taproot usano sempre Bech32m, non Bech32.

**Attivazione.** Taproot è stato attivato tramite un meccanismo Speedy Trial (signalling stile BIP 9 con soglia del 90% in un periodo di difficoltà di mining di 2 settimane). I minatori segnalavano la disponibilità impostando il bit 2 nel version byte del blocco. Dopo aver raggiunto la soglia al blocco 687.408, le regole si sono bloccate e attivate al blocco 709.632 nel novembre 2021.

**Contratti avanzati abilitati da Taproot.**

- Discreet Log Contracts (DLC) usano Taproot per creare pagamenti condizionali basati su attestazioni di un oracolo. L'oracolo firma un messaggio su un evento del mondo reale, e la parte vincente può spendere usando solo il key path se entrambi cooperano, o risolvere sulla chain usando uno script path se una delle parti è inadempiente.

- Point Time Locked Contracts (PTLC) sostituiscono gli Hash Time Locked Contracts (HTLC) usando firme Schnorr adattatore e punti sulla curva ellittica invece di preimmagini di hash. I PTLC offrono maggiore privacy perché la condizione di pagamento non è identificabile come un contratto sulla chain, e permettono pagamenti multi-path più flessibili.

- Aggregazione cross-input delle firme. Le firme Schnorr permettono a input multipli nella stessa transazione di condividere una singola firma. Questo non è ancora standardizzato ma è un'area di ricerca attiva resa possibile da Taproot.

![Spesa key path vs script path](media/wiki/taproot/taproot-spending.svg "La spesa key path usa una singola firma Schnorr. La spesa script path rivela uno script dal Merkle tree con la sua prova.")

Il principio di design di Taproot è che il caso comune dovrebbe essere economico e privato, mentre il caso eccezionale rimane possibile ma più costoso. Impegnando l'albero degli script off-chain e rivelando solo il ramo usato, Taproot sposta il modello di scripting di Bitcoin verso un futuro in cui la maggior parte delle transazioni sono identiche indipendentemente dalle condizioni che impongono.
