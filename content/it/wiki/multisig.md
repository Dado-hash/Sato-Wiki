---
id: wiki.multisig
slug: multisig
language: it
category: cryptography
title: Multifirma
description: Una funzionalità di Bitcoin Script che richiede firme multiple da possessori di chiavi indipendenti per autorizzare una transazione.
coverImage: media/wiki/multisig/multisig-m-of-n.svg
difficulty: advanced
readTimeMinutes: 8
tags:
  - Crittografia
  - Multifirma
  - Sicurezza
  - Script
related:
  - wiki.digital-signatures
  - wiki.ecdsa
  - wiki.schnorr-signatures
  - wiki.bitcoin-addresses
  - wiki.bitcoin-script
  - wiki.hashlocks
sources:
  - title: "BIP 11 — M-of-N Standard Transactions"
    url: https://github.com/bitcoin/bips/blob/master/bip-0011.mediawiki
    author: Gavin Andresen
    publishedAt: 2011-10-18
  - title: "BIP 16 — Pay to Script Hash"
    url: https://github.com/bitcoin/bips/blob/master/bip-0016.mediawiki
    author: Gavin Andresen
    publishedAt: 2012-01-03
  - title: "Mastering Bitcoin - Capitolo 4"
    url: https://github.com/bitcoinbook/bitcoinbook/blob/develop/ch04.asciidoc
    author: Andreas M. Antonopoulos
updatedAt: 2026-05-27T00:00:00Z
---

## base

La multifirma (multisig) è una funzionalità di Bitcoin che richiede firme indipendenti multiple per autorizzare un pagamento. Invece di un singolo che controlla i fondi, una configurazione M-of-N richiede che M su N possibili firmatari siano d'accordo. Un multisig 2-of-3, per esempio, richiede che 2 dei 3 possessori di chiave firmino prima che i fondi possano essere spostati.

Questo è utile in molti scenari: un'azienda potrebbe usare 2-of-3 con CEO, CFO e tesoriere che detengono ciascuno una chiave — due qualsiasi possono autorizzare pagamenti, ma nessun individuo può agire da solo. Le famiglie usano 2-of-3 tra genitori e un avvocato per la pianificazione ereditaria. Gli utenti tecnici usano multisig per distribuire il rischio su più dispositivi o luoghi.

La multifirma è implementata da Bitcoin Script usando l'opcode OP_CHECKMULTISIG. Lo script di blocco contiene tutte le N chiavi pubbliche e la soglia M richiesta. Ogni spenditore fornisce M firme. Lo script verifica che le firme corrispondano a un sottoinsieme delle chiavi pubbliche elencate.

![Setup di multifirma M-of-N](media/wiki/multisig/multisig-m-of-n.svg "Un multisig 2-of-3 richiede due dei tre partecipanti per firmare. Lo script di blocco elenca tutte e tre le chiavi pubbliche e la soglia.")

## medium

Il pattern base dello script multisig è:
```
OP_M <pubKey1> <pubKey2> ... <pubKeyN> OP_N OP_CHECKMULTISIG
```

Questo è chiamato "bare multisig" ed è raramente usato direttamente oggi a causa del wrapping P2SH e P2WSH. Invece, lo script viene hashato e l'hash viene usato come indirizzo:

**P2SH multisig.** Lo script di blocco è `OP_HASH160 <scriptHash> OP_EQUAL`. Il redeem script (lo script multisig completo) viene rivelato nella transazione di spesa. Questo nasconde i parametri multisig al mittente e riduce le commissioni per il creatore.

**P2WSH multisig.** Versione SegWit del multisig P2SH. Il witness script sostituisce il redeem script. I benefici includono commissioni più basse (sconto witness), risoluzione della malleabilità delle transazioni e maggiore capacità dello script (10.000 byte vs 520 byte per il redeem script).

**Taproot multisig.** Le firme Schnorr permettono l'aggregazione delle chiavi. Invece di elencare N chiavi pubbliche on-chain, Taproot le combina in una singola chiave pubblica usando MuSig2. Il risultato è indistinguibile da una transazione a firma singola, fornendo sia privacy che risparmio sui costi.

Il numero di firme verificate per input conta verso il limite di sigop del blocco: un OP_CHECKMULTISIG conta come N sigop (uno per chiave pubblica). Questo è significativo perché i blocchi sono limitati a 80.000 sigop prima di SegWit e 800.000 dopo SegWit (ponderati).

## advanced

**Bug di OP_CHECKMULTISIG.** L'opcode estrae un elemento extra (il primo elemento dello stack) e lo scarta a causa di un bug nell'implementazione originale. Gli script di sblocco devono quindi spingere un OP_0 (o qualsiasi valore dummy) prima delle firme reali:
```
OP_0 <sig1> <sig2> ... <sigM>
```

Questo bug è ora imposto dal consenso e non può essere corretto senza un hard fork. Tutti gli output multisig legacy richiedono l'elemento dummy.

**Aggregazione delle chiavi con MuSig.** BIP 327 (MuSig2) è uno schema multifirma che permette a N parti di produrre una singola firma Schnorr che viene verificata contro una singola chiave pubblica aggregata. Il protocollo richiede tre round di comunicazione:
- Round 1: Ogni parte invia un impegno nonce
- Round 2: Ogni parte invia il proprio nonce
- Round 3: Ogni parte invia la propria firma parziale

La firma aggregata è una singola firma Schnorr da 64 byte, indistinguibile da una normale firma a singolo firmatario. Questo fornisce:
- **Risparmio sui costi**: una firma invece di N nel witness
- **Privacy**: le condizioni di spesa sembrano una normale spesa via chiave
- **Efficienza**: singola operazione di verifica

**Firme di soglia (FROST).** Mentre MuSig richiede la partecipazione di tutti i firmatari (è N-of-N), FROST (Flexible Round-Optimized Schnorr Threshold Signatures) permette la firma Schnorr di soglia t-of-n con due round. FROST non è ancora implementato su mainnet Bitcoin ma è in fase attiva di ricerca e sviluppo.

**Modello di sicurezza.** La sicurezza del multisig dipende dall'indipendenza dei possessori delle chiavi. Minacce comuni:
- Dispositivo di firma condiviso: se due chiavi sono sullo stesso dispositivo, un compromesso di quel dispositivo rompe la protezione multisig
- Ingegneria sociale: un attaccante che convince M-1 possessori di chiavi a firmare una transazione malevola può avere successo
- Collusione: se M possessori di chiavi colludono, i rimanenti N-M possessori non possono impedire la spesa

**Implementazioni pratiche.** I wallet multisig moderni usano BIP 48 per definire i percorsi di derivazione per account multisig e BIP 174 (PSBT — Partially Signed Bitcoin Transactions) per coordinare la firma tra co-firmatari in un formato standardizzato. PSBT permette a ogni firmatario di rivedere e firmare indipendentemente la transazione prima di trasmetterla.
