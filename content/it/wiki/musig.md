---
id: wiki.musig
slug: musig
language: it
category: cryptography
title: MuSig2
description: Un protocollo di multifirma Schnorr in cui più firmatari producono una sola firma sotto un'unica chiave pubblica aggregata, così una spesa condivisa appare come una spesa a firmatario singolo.
coverImage: media/wiki/musig/musig-hero.svg
difficulty: advanced
readTimeMinutes: 5
tags:
  - MuSig2
  - Schnorr
  - Multifirma
  - Taproot
  - Aggregazione delle chiavi
related:
  - wiki.schnorr-signatures
  - wiki.multisig
  - wiki.taproot
  - wiki.digital-signatures
  - wiki.secp256k1
sources:
  - title: "BIP 327: MuSig2 for BIP340-compatible Multi-Signatures"
    url: https://github.com/bitcoin/bips/blob/master/bip-0327.mediawiki
    author: Jonas Nick, Tim Ruffing, Elliott Jin
  - title: "BIP 340: Schnorr Signatures for secp256k1"
    url: https://github.com/bitcoin/bips/blob/master/bip-0340.mediawiki
    author: Pieter Wuille, Jonas Nick, Tim Ruffing
  - title: "MuSig: Simple Schnorr Multi-Signatures with Applications to Bitcoin"
    url: https://eprint.iacr.org/2018/068
    author: Gregory Maxwell, Andrew Poelstra, Yannick Seurin, Pieter Wuille
  - title: "FROST: Flexible Round-Optimized Schnorr Threshold Signatures"
    url: https://eprint.iacr.org/2020/852
    author: Chelsea Komlo, Ian Goldberg
  - title: Bitcoin Optech - MuSig
    url: https://bitcoinops.org/en/topics/musig/
    author: Bitcoin Optech
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

La multifirma è un modo di bloccare i fondi perché più persone debbano concordare prima che possano essere spesi. La multisig con script lo fa collocando in chiaro sulla chain tutte le chiavi pubbliche e richiedendo un numero fissato di firme. MuSig2 raggiunge lo stesso obiettivo con una struttura diversa. I firmatari combinano le proprie chiavi pubbliche in un'unica chiave aggregata, e insieme producono una sola firma Schnorr ordinaria per quella chiave. La spesa appare come un pagamento di una singola chiave.

La differenza conta per dimensioni e privacy. Una spesa cooperativa di un output MuSig2 usa una sola firma, e un osservatore non può dire quante persone abbiano firmato né quante chiavi esistessero. Una spesa multisig con script rivela la struttura dell'accordo, perché lo script elenca le chiavi e le firme stanno accanto a esse.

MuSig2 è uno schema n-di-n: ogni firmatario deve partecipare. Non permette a un sottoinsieme di firmatari di spendere da solo. Schemi a soglia come FROST coprono quel caso, ma sono un disegno separato, e questa voce non li descrive oltre.

La firma richiede anche coordinamento. I firmatari si scambiano valori in più round prima che una firma possa essere prodotta, quindi il protocollo è meno comodo di una multisig con script, in cui ciascun firmatario firma da solo.

## medium

Il primo passo è l'aggregazione. Un firmatario non può semplicemente sommare le chiavi pubbliche. Se l'ultimo firmatario potesse scegliere una chiave che annulla le altre, controllerebbe da solo la somma. Questo è l'attacco della rogue key, e MuSig2 è progettato per impedirlo. Ogni chiave viene moltiplicata per un coefficiente che deriva dall'hash dell'intero elenco di chiavi insieme a quella chiave. Nessun firmatario può scegliere una chiave che annulli le altre, perché ogni coefficiente dipende dall'insieme completo. Il risultato è una singola chiave pubblica nello stesso formato di una chiave BIP 340.

La firma usa due round. Nel primo, ciascun firmatario crea due nonce segreti, calcola i punti pubblici corrispondenti e invia i valori pubblici agli altri. Quando ogni firmatario ha tutti i nonce pubblici, calcola lo stesso nonce aggregato e produce una firma parziale con la propria quota di chiave. Le firme parziali vengono poi combinate in un'unica firma Schnorr che verifica sotto la chiave aggregata. Nella firma finale non compaiono le chiavi né i nonce dei singoli firmatari.

Il riuso di un nonce è fatale. Una firma Schnorr contiene un valore che dipende dalla chiave segreta, dal nonce e dal messaggio. Se lo stesso nonce viene usato per due messaggi diversi con la stessa chiave, due equazioni contengono la stessa incognita e può essere risolta, esponendo la quota di chiave del firmatario. Il BIP 327 stabilisce che il passo di firma non deve mai essere eseguito due volte con lo stesso nonce segreto, e suggerisce di azzerarlo dopo l'uso per evitare incidenti. Un riavvio, un backup o uno stato copiato di una sessione di firma sono quindi punti in cui un nonce potrebbe essere riusato.

Alcune implementazioni rifiutano le chiavi pubbliche duplicate prima dell'aggregazione. Il BIP 327 spiega che gli algoritmi le accettano, ma che i duplicati possono ridurre la sicurezza, e spesso è impossibile capire quale firmatario abbia copiato una chiave. Le applicazioni possono quindi rifiutare i duplicati e chiedere all'utente di verificare.

## advanced

Il BIP 327 definisce MuSig2 per le firme BIP 340. La sua aggregazione delle chiavi produce una chiave pubblica x-only che può stare in un output Taproot, e ai firmatari si possono applicare tweak alla chiave aggregata, per esempio per impegnare un albero di script. Il risultato on-chain è una singola spesa tramite key path. Un osservatore non può distinguerla da una spesa Taproot con un solo firmatario, anche se più persone controllano la chiave. Il paper originale di MuSig ha mostrato che lo schema è sicuro nel modello delle chiavi pubbliche semplici, il che significa che i firmatari non devono dimostrare a un'autorità di certificazione o ad altri firmatari la conoscenza della propria chiave privata prima di partecipare.

Rispetto a OP_CHECKMULTISIG, la spesa MuSig2 è più piccola e più privata. La multisig con script inserisce nello script le N chiavi pubbliche e include M firme nel witness, quindi dimensione e struttura crescono con l'accordo. Un output MuSig2 porta una sola chiave x-only di 32 byte, e la spesa porta una sola firma Schnorr di 64 byte. La differenza di privacy è altrettanto netta: la multisig con script rivela l'insieme delle chiavi e la soglia, mentre MuSig2 nasconde del tutto i firmatari.

La responsabilità è il compromesso. Nella multisig con script, lo script elenca ogni chiave e le firme mostrano quali chiavi hanno approvato una spesa. Questa traccia è utile per gli audit e per dimostrare chi ha firmato. MuSig2 rinuncia a quella traccia, perché la chain non mostra nulla sui singoli firmatari. Optech nota lo stesso equilibrio: MuSig usa meno spazio nei blocchi ed è più privata della multisig con script, ma richiede più interazione tra i partecipanti.

MuSig2 è uno schema n-di-n, quindi da solo non può esprimere una politica 2-di-3. Le sue sessioni di firma hanno uno stato, e quello stato va gestito con cura. Il BIP 327 indica che il protocollo di firma è pensato per due round di comunicazione e che i suoi nonce non sono derivati in modo deterministico dal messaggio, quindi l'implementazione deve conservare il nonce segreto in modo sicuro e poi scartarlo.

FROST, al contrario, è uno schema di firma a soglia. Richiede la cooperazione di un numero di firmatari pari alla soglia, ciascuno con una quota di una chiave privata, e il paper lo presenta come un modo per ridurre l'overhead di rete durante la firma. È un disegno separato da MuSig2 e va letto come argomento a sé.
