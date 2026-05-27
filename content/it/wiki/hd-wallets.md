---
id: wiki.hd-wallets
slug: hd-wallets
language: it
category: cryptography
title: Wallet HD Gerarchici Deterministici
description: Un sistema per derivare un albero di coppie di chiavi da un singolo seed, permettendo una gestione del wallet organizzata e facile da salvare.
coverImage: media/wiki/hd-wallets/hd-wallet-tree.svg
difficulty: advanced
readTimeMinutes: 8
tags:
  - Crittografia
  - Wallet
  - HD Wallet
  - BIP 32
  - Derivazione Chiavi
related:
  - wiki.wallet-seeds
  - wiki.private-keys
  - wiki.public-keys
  - wiki.bitcoin-addresses
sources:
  - title: "BIP 32 — Hierarchical Deterministic Wallets"
    url: https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki
    author: Pieter Wuille
    publishedAt: 2012-02-11
  - title: "BIP 44 — Multi-Account Hierarchy for Deterministic Wallets"
    url: https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki
    author: Marek Palatinus, Pavol Rusnak
    publishedAt: 2014-04-24
  - title: "Mastering Bitcoin - Capitolo 4"
    url: https://github.com/bitcoinbook/bitcoinbook/blob/develop/ch04.asciidoc
    author: Andreas M. Antonopoulos
updatedAt: 2026-05-27T00:00:00Z
---

## base

Un wallet HD (Hierarchical Deterministic wallet) è un sistema che genera tutte le tue chiavi Bitcoin da un singolo punto di partenza — una frase seed. Invece di creare ogni chiave indipendentemente e doverle salvare tutte, un wallet HD crea un albero di chiavi, dove ogni chiave è derivata matematicamente dal seed.

Questo è il motivo per cui puoi salvare una frase seed di 12 parole e ripristinare l'intero wallet — ogni indirizzo che hai mai usato, su qualsiasi dispositivo, attraverso tutte le criptovalute. Il seed agisce come la radice di un albero. Ogni ramo è un account o criptovaluta diverso, e ogni foglia è un indirizzo specifico.

I wallet HD sono definiti da BIP 32 ed estesi da BIP 44, BIP 49, BIP 84 e BIP 86 per diversi tipi di indirizzo. Il sistema usa un percorso di derivazione per descrivere esattamente quale chiave nell'albero usare, per esempio `m/44'/0'/0'/0/0` descrive il primo indirizzo di ricezione in un account Bitcoin legacy.

![Albero di derivazione delle chiavi HD wallet](media/wiki/hd-wallets/hd-wallet-tree.svg "Il seed master genera una gerarchia di chiavi con livelli di scopo, tipo di moneta, account, catena e indice di indirizzo.")

## medium

BIP 32 definisce due tipi di derivazione delle chiavi figlie:

**Derivazione normale.** Una chiave pubblica genitore può derivare chiavi pubbliche figlie senza bisogno della chiave privata genitore. Questa proprietà permette wallet "watch-only" e setup di audit dove le chiavi pubbliche sono generate su un dispositivo online mentre le chiavi private restano offline:
```
ChildPublicKey = ParentPublicKey + (HMAC-SHA512(chain_code, pubkey || index) right 32 bytes) × G
```

**Derivazione hardenizzata.** Usa la chiave privata genitore nell'HMAC, impedendo a un attaccante che conosce una chiave privata figlia di risalire al genitore. I percorsi hardenizzati usano indici ≥ 2³¹ (denotati con un simbolo primo, es. `44'`):
```
ChildPrivateKey = ParentPrivateKey + HMAC-SHA512(chain_code, privkey || index) right 32 bytes
```

La struttura del percorso di derivazione standard (BIP 44) è:
```
m / scopo' / tipo_moneta' / account' / cambio / indice_indirizzo
```

Dove:
- **scopo**: 44' per legacy, 49' per SegWit wrapped, 84' per SegWit nativo, 86' per Taproot
- **tipo_moneta**: 0' per Bitcoin, 1' per Testnet
- **account'**: numero account definito dall'utente (hardenizzato)
- **cambio**: 0 per esterno (ricezione), 1 per interno (resto)
- **indice_indirizzo**: indice sequenziale che parte da 0

I formati di chiave estesa (xprv/xpub) codificano il chain code, la profondità, l'impronta del genitore, l'indice della chiave e la chiave stessa. Questo permette di condividere in sicurezza l'intero albero di chiavi pubbliche di un account.

## advanced

**Serializzazione delle chiavi estese.** Le chiavi estese BIP 32 codificano un chain code e una chiave con metadati. La chiave pubblica estesa (xpub) permette di derivare tutte le chiavi pubbliche discendenti senza esporre le chiavi private. Il formato:
- 4 byte: versione (0x0488B21E per xpub, 0x0488ADE4 per xprv)
- 1 byte: profondità (0 per master, 1 per figlio, ecc.)
- 4 byte: impronta del genitore (primi 32 bit dell'Hash160 del genitore)
- 4 byte: numero figlio (indice tra i figli del genitore)
- 32 byte: chain code
- 33 byte: dati della chiave pubblica o privata

Totale: 78 byte, tipicamente codificati in Base58 in una stringa che inizia con "xpub" o "xprv".

**Considerazioni sulla sicurezza.** La derivazione hardenizzata esiste proprio per contenere l'esposizione. Se un attaccante ottiene una chiave privata figlia normale e il suo chain code, può calcolare il chain code genitore e derivare tutte le chiavi sorelle. Con la derivazione hardenizzata questo è impossibile perché la chiave privata genitore viene mescolata nell'input HMAC. Questo è il motivo per cui i primi tre livelli del percorso BIP 44 (scopo, tipo moneta, account) usano la derivazione hardenizzata.

**Debolezze note.** Diverse proprietà di BIP 32 richiedono implementazione attenta:
- Riutilizzo xpub: condividere più xpub derivati dallo stesso seed permette di collegare account — ogni xpub rilascia il chain code e l'analisi cross-account è possibile
- Entropia debole: un seed compromesso compromette tutte le chiavi discendenti, non solo un ramo
- Perdita di chiave figlia non hardenizzata: se una chiave privata figlia non hardenizzata viene esposta, il chain code genitore può ricostruire la chiave privata genitore usando HMAC-SHA512

**Standard alternativi.** Diversi miglioramenti affrontano i limiti di BIP 32:
- **BIP 43**: definisce il campo scopo nel percorso di derivazione
- **BIP 44**: struttura wallet multi-account
- **BIP 48**: struttura HD wallet per multisig
- **SLIP 0010**: derivazione seed universale per multiple criptovalute
- **Output Script Descriptor (BIP 380-383)**: i descrittori di script forniscono un linguaggio per descrivere output HD wallet, inclusi percorsi di derivazione e tipi di script

**Wallet watch-only.** La derivazione normale permette di creare un wallet watch-only: un xpub viene importato in un dispositivo che può generare indirizzi di ricezione e rilevare pagamenti in arrivo, ma non può firmare transazioni. Le chiavi private rimangono sul dispositivo di cold storage. Questa è l'architettura usata dagli hardware wallet: il dispositivo tiene il seed e firma, mentre un'app telefonica o un wallet desktop tiene l'xpub e costruisce le transazioni.
