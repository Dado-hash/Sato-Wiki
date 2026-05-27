---
id: wiki.public-keys
slug: public-keys
language: it
category: cryptography
title: Chiavi Pubbliche
description: Le coordinate crittografiche derivate dalle chiavi private che altri usano per verificare le firme e inviare bitcoin.
coverImage: media/wiki/public-keys/public-key-derivation.svg
difficulty: advanced
readTimeMinutes: 8
tags:
  - Crittografia
  - Chiavi Pubbliche
  - Curva Ellittica
  - Indirizzi
related:
  - wiki.private-keys
  - wiki.digital-signatures
  - wiki.ecdsa
  - wiki.bitcoin-addresses
  - wiki.secp256k1
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

Una chiave pubblica è derivata da una chiave privata usando la moltiplicazione su curva ellittica. La chiave privata è un numero segreto a 256 bit, e la chiave pubblica è il risultato della sua moltiplicazione per un punto generatore fisso sulla curva secp256k1. Questa operazione è unidirezionale: data una chiave pubblica, non esiste metodo matematico noto per recuperare la chiave privata.

Una chiave pubblica è sicura da condividere. Chiunque conosca la tua chiave pubblica può verificare le firme che crei e può inviare bitcoin all'indirizzo associato. L'indirizzo stesso viene calcolato applicando un hash alla chiave pubblica, aggiungendo un ulteriore livello di protezione.

Pensa a una chiave pubblica come a una cassetta postale. La cassetta è visibile a tutti — chiunque può lasciare della posta al suo interno. Ma solo la persona con la chiave privata — la chiave della cassetta — può aprirla e recuperare ciò che contiene. L'indirizzo è un'etichetta che dice alle persone quale cassetta usare.

![Derivazione della chiave pubblica dalla chiave privata](media/wiki/public-keys/public-key-derivation.svg "Lo scalare k della chiave privata è moltiplicato per il punto generatore G per produrre il punto K = k * G della chiave pubblica sulla curva secp256k1.")

## medium

Una chiave pubblica Bitcoin è un punto sulla curva ellittica secp256k1. Consiste in due coordinate (x, y) che soddisfano l'equazione della curva y^2 = x^3 + 7 sul campo finito definito dal modulo primo p.

Data una chiave privata k (uno scalare intero nell'intervallo [1, n-1], dove n è l'ordine della curva), la chiave pubblica K viene calcolata come:

```
K = k * G
```

Qui G è il punto generatore della curva secp256k1, un punto base fisso le cui coordinate sono definite dallo standard. Il simbolo * denota la moltiplicazione scalare su curva ellittica — l'addizione ripetuta di G a se stesso k volte. Questa operazione è computazionalmente efficiente in una direzione ma irrealizzabile da invertire, una proprietà nota come problema del logaritmo discreto.

Le chiavi pubbliche appaiono in due formati di serializzazione:

- **Compressa (33 byte)**: Memorizza la coordinata x e un byte di prefisso che indica la parità (segno) della coordinata y. Il prefisso è 0x02 se y è pari, 0x03 se y è dispari. Poiché l'equazione della curva determina y a meno del segno dato x, il punto completo può essere ricostruito dalla sola x e dal bit di parità.

- **Non compressa (65 byte)**: Memorizza entrambe le coordinate per intero, con prefisso 0x04. Questo formato è più grande ma era il predefinito nei primi software Bitcoin. È ancora valido ma raramente usato nelle nuove transazioni a causa del costo aggiuntivo in spazio del blocco.

Il formato compresso è diventato lo standard perché risparmia 32 byte per chiave pubblica in ogni input di transazione. In una transazione con più input, il risparmio si accumula in modo significativo. La transizione alle chiavi compresse è stata incentivata dalle commissioni di transazione più basse che dimensioni dei dati inferiori producono.

Poiché le chiavi pubbliche sono derivate deterministicamente dalle chiavi private, la stessa chiave privata produce sempre la stessa chiave pubblica. Questo determinismo è ciò che rende verificabili le coppie di chiavi: chiunque può controllare che una chiave pubblica corrisponda a una data chiave privata eseguendo la stessa moltiplicazione.

Dalla chiave pubblica si produce un indirizzo Bitcoin attraverso una catena di hash. Prima la chiave pubblica viene hashata con SHA-256, poi il risultato viene hashato con RIPEMD-160. L'hash risultante di 20 byte viene codificato in Base58Check (indirizzi legacy) o Bech32 (indirizzi SegWit). Questo hashing aggiunge resistenza alle collisioni e riduce la lunghezza dell'indirizzo, ma significa che la chiave pubblica non viene rivelata fino a quando i fondi non vengono spesi.

## advanced

**Moltiplicazione scalare su curva ellittica.** L'operazione K = k * G non è una moltiplicazione ordinaria. È definita come l'applicazione ripetuta della legge di gruppo della curva ellittica: addizione di punti e raddoppio di punti.

L'addizione di punti prende due punti distinti P e Q sulla curva e produce un terzo punto R = P + Q. Geometricamente, R è la riflessione attraverso l'asse x del terzo punto di intersezione della linea attraverso P e Q con la curva.

Il raddoppio di punti prende un singolo punto P e produce R = 2*P. Usa la linea tangente in P invece di una linea secante attraverso due punti.

La moltiplicazione scalare combina addizione e raddoppio usando l'algoritmo double-and-add. Per calcolare k*G, scansiona i bit di k dal più significativo al meno significativo: parti da G, poi per ogni bit, raddoppia il risultato corrente, e se il bit è 1, aggiungi G. Questo richiede al massimo 256 raddoppi e 256 addizioni — circa 512 operazioni sulla curva per qualsiasi scalare a 256 bit.

**Punto generatore G.** Il punto generatore della curva secp256k1 ha queste coordinate:

```
G_x = 0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798
G_y = 0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8
```

Ogni chiave pubblica sulla curva è un multiplo di G. L'ordine n di G è il più piccolo intero positivo tale che n * G = O (il punto all'infinito). Per secp256k1, n è circa 1,1579 * 10^77.

**Byte di prefisso e formati delle chiavi.** Il primo byte di una chiave pubblica serializzata dice al parser quale formato è in uso:

- 0x04 — non compressa, seguito da 32 byte di x e 32 byte di y (65 byte totali).
- 0x02 — compressa, y è pari (33 byte).
- 0x03 — compressa, y è dispari (33 byte).
- 0x06 — ibrida, y è pari (65 byte, raramente usata).
- 0x07 — ibrida, y è dispari (65 byte, raramente usata).

I formati ibridi (0x06, 0x07) includono entrambe le coordinate come la non compressa ma codificano anche la parità di y come la compressa. Forniscono un controllo di sicurezza: il parser può verificare che la y inclusa corrisponda alla parità indicata dal prefisso. In pratica, le chiaviibride non si vedono quasi mai sulla rete Bitcoin.

**Recupero della chiave pubblica dalle firme.** Una proprietà unica di ECDSA è che la chiave pubblica può essere recuperata da una firma e dal messaggio che è stato firmato. Dati (r, s) e l'hash del messaggio, ci sono solitamente due o quattro possibili chiavi pubbliche candidate. La firma include un ID di recupero (v) che identifica quella corretta.

Questa caratteristica significa: se hai un messaggio firmato e la firma, non hai bisogno che ti venga comunicata separatamente la chiave pubblica — puoi calcolarla. Questa proprietà è stata ampiamente usata nei primi giorni per protocolli di pagamento offline ed è ancora usata da Ethereum per l'origine delle transazioni (dove il mittente viene recuperato dalla firma invece di essere incluso esplicitamente).

Le transazioni Bitcoin P2PKH (Pay-to-Public-Key-Hash) non si basano su questo per la spesa standard, ma è usato internamente da alcune implementazioni di wallet e per firmare messaggi al di fuori delle transazioni.

**Le firme Schnorr rimuovono il recupero.** Le firme Schnorr (attivate con Taproot, novembre 2021) non supportano il recupero della chiave pubblica dalle firme. Questa è una scelta di design intenzionale. Schnorr usa una struttura di firma diversa in cui la chiave pubblica è impegnata all'interno del nonce della firma, rendendo il recupero impossibile senza dati aggiuntivi.

Il compromesso è pratico: le firme Schnorr sono più piccole, supportano l'aggregazione delle firme (più firmatari producono una sola firma) e forniscono una migliore privacy attraverso lo spending tramite key path. Il recupero della chiave pubblica era una caratteristica di nicchia di ECDSA che è stata sacrificata per questi vantaggi.

**Sicurezza e problema del logaritmo discreto.** La sicurezza di tutta la crittografia a chiave pubblica di Bitcoin si basa sul presupposto che risolvere il problema del logaritmo discreto sulla curva secp256k1 sia computazionalmente irrealizzabile. Dato un punto K della chiave pubblica, trovare la chiave privata k tale che K = k * G richiede che un attaccante determini quante volte G è stato aggiunto a se stesso.

Il miglior algoritmo noto per questo è Pollard's rho, che ha un tempo di esecuzione di O(sqrt(n)) operazioni sulla curva. Per n ~ 2^256, sqrt(n) ~ 2^128 operazioni. Questo è ben oltre qualsiasi capacità pratica. Anche con hardware ottimizzato, 2^128 operazioni sulla curva consumerebbero più energia di quanta disponibile da tutte le stelle nell'universo osservabile.

Il calcolo quantistico cambia questo scenario. L'algoritmo di Shor può risolvere il problema del logaritmo discreto in tempo polinomiale, il che romperebbe ECDSA e Schnorr. Tuttavia, un computer quantistico abbastanza grande da attaccare le chiavi Bitcoin — che richiede milioni di qubit fisici — non esiste e non è previsto entro il prossimo decennio. La comunità Bitcoin sta attivamente ricercando schemi di firma post-quantistici come mitigazione a lungo termine.
