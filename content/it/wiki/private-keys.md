---
id: wiki.private-keys
slug: private-keys
language: it
category: cryptography
title: Chiavi Private
description: I numeri segreti a 256 bit che autorizzano la spesa in Bitcoin e sono la radice della proprietà nel sistema.
coverImage: media/wiki/private-keys/private-key-generation.svg
difficulty: advanced
readTimeMinutes: 8
tags:
  - Crittografia
  - Chiavi Private
  - Sicurezza
  - Wallet
related:
  - wiki.public-keys
  - wiki.digital-signatures
  - wiki.ecdsa
  - wiki.bitcoin-addresses
  - wiki.wallet-seeds
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: "Mastering Bitcoin - Capitolo 4"
    url: https://github.com/bitcoinbook/bitcoinbook/blob/develop/ch04.asciidoc
    author: Andreas M. Antonopoulos
  - title: "Standard secp256k1"
    url: https://www.secg.org/sec2-v2.pdf
    author: SECG
updatedAt: 2026-05-27T00:00:00Z
---

## base

Una chiave privata è un numero segreto a 256 bit che prova la proprietà dei bitcoin. Chiunque conosca la chiave può spendere le monete associate. Viene generata casualmente e deve essere tenuta segreta in ogni momento.

Dalla chiave privata si deriva la chiave pubblica usando la moltiplicazione su curva ellittica, e dalla chiave pubblica si generano gli indirizzi. Questo processo è unidirezionale: non esiste operazione matematica in grado di invertirlo. Data una chiave pubblica, non è possibile calcolare la chiave privata.

Pensa a una chiave privata come alla chiave di una cassetta postale. Chiunque abbia la chiave può aprire la cassetta e prendere ciò che è dentro. La cassetta stessa — l'indirizzo — è pubblica e visibile a tutti, ma la chiave è nota solo a te. La differenza è che in Bitcoin la cassetta può essere creata dalla chiave, ma la chiave non può mai essere recuperata dalla cassetta.

![Generazione e validazione della chiave privata](media/wiki/private-keys/private-key-generation.svg "Una chiave privata ha origine dall'entropia, passa attraverso un RNG crittografico e viene validata rispetto all'ordine della curva secp256k1.")

## medium

Una chiave privata Bitcoin è un qualsiasi numero compreso tra 0x1 e 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 inclusi. Questo limite superiore è l'ordine n della curva ellittica secp256k1, circa 2^256 — un numero così grande da superare il numero stimato di atomi nell'universo osservabile.

Le chiavi private devono essere generate utilizzando un generatore di numeri casuali crittograficamente sicuro (CSPRNG). I normali generatori pseudo-casuali non sono adatti perché producono output prevedibile se il seed è noto. I sistemi operativi forniscono CSPRNG attraverso interfacce come `/dev/urandom` su Unix o `CryptGenRandom` su Windows.

Nella maggior parte dei wallet, la chiave privata è memorizzata in uno dei seguenti formati:

- **Byte grezzi**: 32 byte di dati binari, la rappresentazione nativa usata internamente dal codice di firma.
- **WIF (Wallet Import Format)**: Una stringa codificata in Base58Check che include un prefisso di versione e un checksum. WIF è il metodo standard per esportare e importare una singola chiave privata tra wallet. Una chiave privata mainnet in WIF inizia con `5` (non compressa) o `K`/`L` (compressa).
- **Formato mini private key**: Un formato compatto usato in situazioni dove lo spazio è limitato, come token fisici Bitcoin o paper wallet. Le mini chiavi sono tipicamente lunghe 22 o 30 caratteri.

La relazione tra una chiave privata e la sua chiave pubblica è definita dalla moltiplicazione su curva ellittica sul campo di secp256k1. Data una chiave privata k, la chiave pubblica K è calcolata come K = k * G, dove G è il punto generatore della curva e la moltiplicazione significa addizione ripetuta di punti sulla curva ellittica. Questa operazione è computazionalmente facile in una direzione ma irrealizzabile da invertire — una proprietà chiamata problema del logaritmo discreto.

La lunghezza della chiave a 256 bit fornisce margini di sicurezza enormi. Una ricerca brute force dello spazio delle chiavi private è completamente irrealizzabile con qualsiasi tecnologia conosciuta o prevedibile. Anche se tutti i computer sulla Terra lavorassero in parallelo, trovare una singola chiave richiederebbe molti ordini di grandezza in più dell'età dell'universo.

## advanced

**Sicurezza della generazione delle chiavi.** La qualità di una chiave privata dipende interamente dalla fonte di entropia. La maggior parte dei wallet software si affida al CSPRNG del sistema operativo, che raccoglie entropia da fonti hardware, temporizzazione degli interrupt ed eventi di sistema. I wallet hardware utilizzano elementi sicuri dedicati o veri generatori di numeri casuali (TRNG) integrati nel chip.

I fallimenti degli RNG hanno causato perdite reali di Bitcoin. Nel 2013, un bug nella classe `SecureRandom` di Android su dispositivi basati su Java produceva chiavi private deboli a causa di entropia insufficiente. Gli aggressori hanno scansionato la blockchain alla ricerca di indirizzi le cui chiavi pubbliche potevano essere derivate dallo stato prevedibile dell'RNG e hanno rubato bitcoin per un valore di milioni di dollari. Questo incidente ha dimostrato che il modello di sicurezza dipende non solo dall'algoritmo ma dalla qualità dell'entropia al momento della generazione.

**Dettagli del formato WIF.** Il Wallet Import Format codifica una chiave privata in Base58Check con la seguente struttura:

1. Un byte di versione: 0x80 per mainnet, 0xEF per testnet.
2. I 32 byte della chiave privata.
3. Un byte suffisso opzionale 0x01 che indica che la corrispondente chiave pubblica deve essere derivata in forma compressa.
4. Un checksum di 4 byte: i primi quattro byte di SHA256(SHA256(versione || chiave || suffisso)).
5. L'intera stringa di byte viene codificata in Base58.

La presenza o assenza del suffisso 0x01 determina se la stringa WIF inizia con `5` (non compressa, senza suffisso) o `K`/`L` (compressa, con suffisso). Entrambe rappresentano la stessa chiave privata, ma il formato compresso produce transazioni più piccole perché la chiave pubblica è espressa solo come coordinata x più un bit di parità (33 byte) invece di entrambe le coordinate (65 byte).

**Chiavi crittografate BIP 38.** BIP 38 definisce un metodo per crittografare una chiave privata con una passphrase, producendo una stringa codificata in Base58Check che inizia con `6P`. Questo permette di memorizzare chiavi private in un formato portabile che rimane sicuro anche se il supporto viene compromesso. La decrittazione richiede sia la chiave crittografata che la passphrase. La crittografia utilizza AES-256-CBC con una chiave derivata dalla passphrase attraverso la derivazione di chiave scrypt.

**Wallet HD e derivazione delle chiavi.** In pratica, la maggior parte dei wallet moderni non gestisce singole chiavi private direttamente. Invece, implementano wallet deterministici gerarchici (HD) BIP 32. Un wallet HD parte da una singola seed phrase (tipicamente 12 o 24 parole dalla wordlist BIP 39) e deriva un intero albero di coppie di chiavi utilizzando una funzione di hash crittografico. Il percorso di derivazione determina quale chiave viene usata, permettendo ai wallet di generare migliaia di indirizzi da un seed senza memorizzare ogni chiave privata separatamente.

La chiave privata master è calcolata dal seed usando HMAC-SHA512, poi le chiavi private figlie sono derivate attraverso un processo chiamato CKD (Child Key Derivation). La derivazione non indurita permette a una chiave pubblica e a un chain code di derivare chiavi pubbliche figlie senza accesso a chiavi private — una proprietà usata dai wallet watch-only e dai wallet hardware.

**Limiti dello spazio delle chiavi.** Il numero di chiavi private valide non è esattamente 2^256 ma piuttosto n − 1, dove n è l'ordine della curva secp256k1: 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141. Lo zero è escluso perché il punto all'infinito moltiplicato per zero non è una chiave pubblica valida. La differenza tra n e 2^256 è di circa 1,57 × 10^21, che è irrilevante per la sicurezza: lo spazio delle chiavi è effettivamente infinito per qualsiasi attaccante pratico.
