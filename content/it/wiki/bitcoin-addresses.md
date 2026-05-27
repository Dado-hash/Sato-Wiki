---
id: wiki.bitcoin-addresses
slug: bitcoin-addresses
language: it
category: cryptography
title: Indirizzi Bitcoin
description: Gli identificatori alfanumerici che rappresentano destinazioni per pagamenti in bitcoin, derivati dalle chiavi pubbliche tramite hashing e codifica.
coverImage: media/wiki/bitcoin-addresses/address-derivation.svg
difficulty: advanced
readTimeMinutes: 8
tags:
  - Crittografia
  - Indirizzi
  - Wallet
  - Codifica
related:
  - wiki.public-keys
  - wiki.private-keys
  - wiki.segregated-witness
  - wiki.taproot
  - wiki.ecdsa
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: "Mastering Bitcoin - Chapter 4"
    url: https://github.com/bitcoinbook/bitcoinbook/blob/develop/ch04.asciidoc
    author: Andreas M. Antonopoulos
  - title: "BIP 173 — Bech32 Address Format"
    url: https://github.com/bitcoin/bips/blob/master/bip-0173.mediawiki
    author: Pieter Wuille, Greg Maxwell
  - title: "BIP 350 — Bech32m Address Format"
    url: https://github.com/bitcoin/bips/blob/master/bip-0350.mediawiki
    author: Pieter Wuille
updatedAt: 2026-05-27T00:00:00Z
---

## base

Un indirizzo Bitcoin è un identificatore che dice alla rete dove inviare bitcoin. È derivato da una chiave pubblica attraverso una serie di operazioni crittografiche, ma non è la chiave pubblica stessa. Gli indirizzi sono più corti, più facili da condividere e includono codici di rilevamento errori per evitare che i fondi vadano persi a causa di errori di battitura.

L'analogia più semplice è un indirizzo email: condividi il tuo indirizzo email con altri così che possano inviarti messaggi, ma nessuno può leggere le tue email solo con l'indirizzo. Similmente, un indirizzo Bitcoin permette ad altri di inviarti bitcoin, ma non possono spenderli solo con l'indirizzo.

Un indirizzo viene creato prendendo una chiave pubblica, applicando due hash (SHA-256 poi RIPEMD-160), aggiungendo un prefisso di rete e un checksum, e codificando il risultato. La codifica specifica determina il formato dell'indirizzo: gli indirizzi legacy iniziano con "1" (Base58Check), gli indirizzi SegWit iniziano con "bc1" (Bech32) e gli indirizzi Taproot iniziano con "bc1p" (Bech32m).

![Pipeline di derivazione dell'indirizzo Bitcoin](media/wiki/bitcoin-addresses/address-derivation.svg "Dalla chiave privata, attraverso la moltiplicazione a curva ellittica, hashing e codifica, fino all'indirizzo finale.")

## medium

Gli indirizzi Bitcoin si sono evoluti attraverso diversi formati, ciascuno migliorando il precedente:

**Legacy (P2PKH).** Gli indirizzi Pay to Public Key Hash iniziano con "1" e usano la codifica Base58Check. L'hash è RIPEMD-160 di SHA-256 della chiave pubblica. Un byte di versione (0x00 per mainnet) viene preposto e un checksum di 4 byte (doppio SHA-256) viene appeso. Base58 omette caratteri simili (0, O, I, l) per ridurre errori di trascrizione.

**P2SH (Pay to Script Hash).** Indirizzi che iniziano con "3" usano la stessa codifica Base58Check ma hashano uno script di redeem invece di una chiave pubblica. Questo permette multisig e altre condizioni di spesa complesse dietro un semplice indirizzo. P2SH è stato introdotto con BIP 16 (2012).

**SegWit nativo (P2WPKH / P2WSH).** Gli indirizzi Bech32 che iniziano con "bc1" usano uno schema di codifica diverso: una parte leggibile dall'umano (hrp = "bc" per mainnet, "tb" per testnet), un separatore "1", una parte dati che codifica il witness program e un checksum BCH di 6 caratteri. Bech32 è più efficiente (commissioni più basse), case-insensitive e in grado di correggere errori.

**Taproot (P2TR).** Gli indirizzi Bech32m che iniziano con "bc1p" sono il formato più recente. Usano chiavi pubbliche x-only da 32 byte e supportano spesa via chiave e via script. Bech32m (BIP 350) corregge una debolezza di Bech32 che permetteva l'inserimento di caratteri estranei.

I passaggi di derivazione dalla chiave pubblica all'indirizzo:

1. Calcola H = RIPEMD160(SHA256(K)) dove K è la chiave pubblica (33 o 65 byte)
2. Aggiungi il byte di versione: prefisso di rete (0x00 per mainnet P2PKH, 0x05 per P2SH)
3. Calcola il checksum: primi 4 byte del doppio SHA-256 di (versione || H)
4. Codifica in Base58: versione || H || checksum, convertito nell'alfabeto Base58

Per gli indirizzi Bech32, il passo 4 è sostituito dalla codifica Bech32 usando il witness program (versione witness + byte del programma witness).

## advanced

**Probabilità di collisione degli indirizzi.** Un indirizzo Bitcoin è di 160 bit. La probabilità che due chiavi pubbliche diverse producano lo stesso indirizzo è circa 2⁻¹⁶⁰, ovvero circa 1 su 10⁴⁸. Anche se ogni persona sulla Terra generasse un miliardo di indirizzi al secondo per un secolo, la probabilità di collisione rimarrebbe trascurabile. Questo è il motivo per cui gli indirizzi sono considerati identificativi unici.

**Dettagli della codifica Base58Check.** L'alfabeto Base58 è: `123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz`. L'assenza di 0, O, I, l riduce l'ambiguità visiva. Il processo di codifica tratta i byte come un numero big-endian e lo converte in base-58, poi prepone caratteri "1" per ogni byte zero iniziale nei dati originali.

**Correzione errori Bech32.** Bech32 usa un codice BCH (Bose-Chaudhuri-Hocquenghem) su GF(32) che può rilevare fino a 4 errori e correggerne fino a 3 nella parte dati. Il checksum garantisce che ogni errore di sostituzione venga rilevato con probabilità schiacciante. Tuttavia, Bech32 ha una debolezza: inserire o eliminare caratteri "q" può passare inosservato. Bech32m (BIP 350) corregge questo usando una costante di checksum diversa (0x2BC830A3 invece di 0x1).

**Riutilizzo degli indirizzi.** Gli strumenti di analisi della blockchain tracciano gli indirizzi. Associare pubblicamente più transazioni allo stesso indirizzo rivela il cluster di proprietà. I wallet moderni generano un nuovo indirizzo per ogni pagamento usando la derivazione deterministica delle chiavi (BIP 32). Questa non è una regola del protocollo ma una raccomandazione per la privacy. Il riutilizzo degli indirizzi è tecnicamente valido ma collega le transazioni sul registro pubblico.

**Chiavi pubbliche x-only in Taproot.** BIP 341 ha introdotto chiavi pubbliche x-only per gli indirizzi Taproot: solo la coordinata x del punto della curva ellittica viene usata (32 byte). La coordinata y è assunta pari. Questo riduce la dimensione dell'indirizzo e migliora l'efficienza. La chiave pubblica corrispondente non può essere recuperata da una firma Schnorr (a differenza di ECDSA), che è un compromesso deliberato per l'efficienza.

**Indirizzi invoice (BIP 21).** Gli indirizzi Bitcoin sono spesso incorporati in un formato URI: `bitcoin:indirizzo?amount=valore&label=testo`. Questo standard permette ai wallet di generare richieste di pagamento con importi e descrizioni. Il formato BIP 21 è ampiamente supportato da wallet e processori di pagamento.
