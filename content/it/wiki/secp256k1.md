---
id: wiki.secp256k1
slug: secp256k1
language: it
category: cryptography
title: secp256k1
description: La curva ellittica standardizzata da SECG che Bitcoin usa per tutte le sue operazioni crittografiche.
coverImage: media/wiki/secp256k1/secp256k1-curve.svg
difficulty: advanced
readTimeMinutes: 8
tags:
  - Crittografia
  - secp256k1
  - Curva Ellittica
  - ECDSA
  - Schnorr
related:
  - wiki.private-keys
  - wiki.public-keys
  - wiki.ecdsa
  - wiki.schnorr-signatures
  - wiki.digital-signatures
sources:
  - title: "SEC 2 — Recommended Elliptic Curve Domain Parameters"
    url: https://www.secg.org/sec2-v2.pdf
    author: Standards for Efficient Cryptography Group
    publishedAt: 2010-01-27
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: "BIP 340 — Schnorr Signatures for secp256k1"
    url: https://github.com/bitcoin/bips/blob/master/bip-0340.mediawiki
    author: Pieter Wuille, Jonas Nick, Tim Ruffing
updatedAt: 2026-05-27T00:00:00Z
---

## base

secp256k1 è la curva ellittica che Bitcoin usa per tutte le sue operazioni crittografiche. Ogni chiave privata, chiave pubblica e firma digitale in Bitcoin è definita da questa curva. È una curva di Koblitz — un tipo speciale di curva ellittica progettata per calcoli efficienti — definita sul campo di ordine primo p.

L'equazione della curva è y² = x³ + 7. È un'equazione semplice, ma la sua struttura su un campo finito crea un terreno matematico dove certi problemi sono facili da calcolare in avanti ma impossibili da invertire, che è esattamente ciò di cui Bitcoin ha bisogno per la sua sicurezza.

Satoshi Nakamoto scelse secp256k1 per Bitcoin perché offre prestazioni migliori rispetto ad altre curve standard e non ha backdoor note. Il design Koblitz della curva permette una moltiplicazione di punto particolarmente efficiente, operazione necessaria in ogni transazione Bitcoin.

![Parametri della curva secp256k1 e derivazione della chiave](media/wiki/secp256k1/secp256k1-curve.svg "L'equazione della curva secp256k1 y² = x³ + 7, il suo ordine primo e la derivazione della chiave pubblica K = k × G.")

## medium

secp256k1 è definita sul campo F_p dove p = 2²⁵⁶ − 2³² − 2⁹ − 2⁸ − 2⁷ − 2⁶ − 2⁴ − 1. Questo primo è stato scelto perché molto vicino a una potenza di due, permettendo una riduzione modulare efficiente usando shift di bit e addizioni invece di divisioni generiche. Ogni implementazione beneficia automaticamente di questa scelta.

L'ordine della curva n — il numero di punti sulla curva — è circa 2²⁵⁶. Ogni chiave privata è uno scalare nell'intervallo [1, n-1]. Il punto generatore G è un punto fisso della curva usato nella formula di derivazione K = k × G, dove k è la chiave privata, G è il generatore e K è la chiave pubblica. Il generatore G è specificato in forma compressa come `0279BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798`.

Bitcoin ha scelto secp256k1 anche per i suoi parametri verificabilmente casuali. A differenza di altre curve dove certe costanti sono state scelte senza spiegazione pubblica, i parametri di secp256k1 derivano dai valori più piccoli possibili che soddisfano l'equazione della curva, senza lasciare spazio a debolezze nascoste. La curva ha cofattore 1, il che significa che il numero di punti è esattamente uguale all'ordine n.

Tipi di chiave che usano secp256k1:
- Firme ECDSA (Bitcoin dal 2009)
- Firme Schnorr (BIP 340, Taproot 2021)
- Recupero della chiave pubblica dalle firme
- Derivazione delle chiavi HD wallet (BIP 32)

## advanced

La curva secp256k1 appartiene alla famiglia Koblitz (K-256), progettata per le prestazioni usando l'endomorfismo di Frobenius. La mappa τ(x, y) = (x², y²) su F_p permette di sostituire le operazioni di punto doppio con elevamenti al quadrato molto più economici. Le implementazioni che usano espansioni τ-adiche possono ottenere un'accelerazione di 2-3× nella moltiplicazione scalare rispetto a curve generiche come P-256, con tecniche avanzate che si avvicinano a 4×.

Il primo di campo p = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F è un primo di Crandall (anche chiamato primo di Solinas della forma 2²⁵⁶ − 2³² − 937). La riduzione modulare può essere eseguita efficientemente usando l'identità:

```
c = 2²⁵⁶ mod p = 2³² + 937
```

Questa proprietà è critica per implementazioni ad alta velocità, riducendo un prodotto a 512 bit a 256 bit con poche addizioni. La maggior parte delle implementazioni di produzione (libsecp256k1, OpenSSL) usa questo per ottenere moltiplicazione scalare in sub-microsecondi su hardware moderno.

L'ordine della curva n = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 è un primo di 256 bit. La relazione tra p e n non è casuale: n ≈ p per le curve Koblitz a causa del limite di Hasse |n − (p + 1)| ≤ 2√p.

Sicurezza: il miglior attacco noto al logaritmo discreto di secp256k1 è l'algoritmo Pollard's rho, con complessità attesa circa (√(πn/2))/2 ≈ 2¹²⁸ operazioni usando varianti parallelizzate. Questo corrisponde al livello di sicurezza di 128 bit dichiarato per la curva. Tutti gli attacchi noti richiedono 2¹²⁸ operazioni di curva, ognuna delle quali è una moltiplicazione scalare completa.

La scelta di secp256k1 rispetto alle curve NIST (P-256) è stata deliberata. Satoshi la selezionò perché:
- Parametri verificabilmente casuali (nessuna costante inspiegabile)
- Nessuna relazione con le curve progettate dalla NSA
- Struttura di curva Koblitz per efficienza implementativa
- Forte analisi e adozione dalla comunità

Le implementazioni Bitcoin moderne (Bitcoin Core, libsecp256k1) usano moltiplicazione scalare a tempo costante per prevenire attacchi side-channel. La libreria libsecp256k1, mantenuta da Pieter Wuille e dal team di Bitcoin Core, implementa queste tecniche sia per ECDSA che per Schnorr ed è considerata un riferimento per la crittografia a curva ellittica di livello produzione.
