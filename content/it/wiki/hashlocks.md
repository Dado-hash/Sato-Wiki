---
id: wiki.hashlocks
slug: hashlocks
language: it
category: cryptography
title: Hash Lock
description: Una condizione crittografica che richiede di rivelare la preimmagine di un hash per spendere un output, permettendo pagamenti atomici e condizionali.
coverImage: media/wiki/hashlocks/hashlock-mechanism.svg
difficulty: advanced
readTimeMinutes: 8
tags:
  - Crittografia
  - Hash Lock
  - Script
  - HTLC
  - Lightning Network
  - Atomic Swap
related:
  - wiki.hash-functions
  - wiki.timelocks
  - wiki.bitcoin-script
  - wiki.lightning-network
  - wiki.htlcs
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: "BIP 199 — Hashed Time-Locked Contract improvements"
    url: https://github.com/bitcoin/bips/blob/master/bip-0199.mediawiki
    author: Sean Bowe, Daira Hopwood
  - title: "The Bitcoin Lightning Network — Poon-Dryja"
    url: https://lightning.network/lightning-network-paper.pdf
    author: Joseph Poon, Thaddeus Dryja
    publishedAt: 2016-01-14
updatedAt: 2026-05-27T00:00:00Z
---

## base

Un hash lock è una condizione di spesa che richiede un valore segreto (chiamato "preimmagine") per sbloccare i fondi. La condizione funziona impegnando l'hash del segreto nello script di blocco. Per spendere l'output, lo spenditore deve rivelare il segreto originale che produce quell'hash.

Il meccanismo è semplice: Alice blocca bitcoin con l'hash di un segreto R. Solo chi conosce R può spenderlo. Poiché l'hashing è unidirezionale, pubblicare l'hash non rivela nulla su R. Ma una volta che R viene rivelato per riscuotere i fondi, chiunque può vederlo. Questa proprietà — che rivelare R è una prova pubblica della conoscenza del segreto — è ciò che rende gli hash lock così utili.

Quando combinati con i time lock, un hash lock crea un Hashed TimeLock Contract (HTLC). Questo è il blocco fondamentale della Lightning Network, degli atomic swap e di molti pattern di smart contract Bitcoin. L'hash lock assicura che il pagamento vada alla persona giusta se conosce il segreto; il time lock assicura che il mittente possa recuperare i fondi se il segreto non viene mai rivelato.

![Meccanismo dell'hash lock](media/wiki/hashlocks/hashlock-mechanism.svg "Una preimmagine segreta viene hashata con SHA-256. L'hash blocca l'output. Per spendere bisogna rivelare la preimmagine. Combinato con un time lock, forma un HTLC.")

## medium

Un hash lock in Bitcoin Script si presenta così:
```
OP_SHA256 <hash> OP_EQUALVERIFY OP_CHECKSIG
```

Lo spenditore deve fornire un valore che, quando hashato con SHA-256, sia uguale all'hash di blocco. Dopo che l'uguaglianza dell'hash è verificata, OP_EQUALVERIFY passa e lo script procede alla verifica della firma. Questo è il "percorso di successo" di un HTLC.

L'HTLC completo ha due percorsi:

**Percorso 1 — Riscatta con preimmagine (successo):**
```
OP_SHA256 <hash> OP_EQUALVERIFY OP_CHECKSIG
```
Lo spenditore fornisce: `<sig> <preimage>`

**Percorso 2 — Rimborso dopo timeout (timeout):**
```
<locktime> OP_CHECKLOCKTIMEVERIFY OP_DROP OP_CHECKSIG
```
Il mittente fornisce: `<sig>` (dopo il locktime)

Lo script è tipicamente avvolto in P2SH o P2WSH per nascondere le condizioni di blocco complesse al mittente. Lo script combinato è un pagamento condizionale: il destinatario può riscuotere immediatamente rivelando R, o il mittente può reclamare dopo il locktime.

**Meccanica degli atomic swap.** Gli hash lock permettono atomic swap cross-chain. Alice (su Bitcoin) e Bob (su Litecoin) vogliono scambiare senza fidarsi:

1. Bob genera R, invia H = SHA256(R) ad Alice
2. Alice crea un HTLC Bitcoin bloccato con H: se Bob rivela R entro 48 ore, Bob riceve i bitcoin di Alice; altrimenti Alice li riprende
3. Bob crea un HTLC Litecoin bloccato con lo stesso H: se Alice rivela R entro 24 ore, Alice riceve i litecoin di Bob; altrimenti Bob li riprende
4. Alice riscuote l'HTLC Litecoin, rivelando R
5. Bob usa l'R ora pubblico per riscuotere l'HTLC Bitcoin

L'asimmetria dei time lock (48h vs 24h) garantisce che Alice non possa riscuotere entrambi e Bob non possa tirarsi indietro, rendendo lo swap atomico.

## advanced

**HTLC nella Lightning Network.** I canali di pagamento usano HTLC per il routing multi-hop. Quando Alice paga Dave attraverso Bob e Carol:

1. Ogni hop crea un HTLC con lo stesso H ma time lock decrescenti
2. Alice→Bob: HTLC con hash H, time lock 144 blocchi
3. Bob→Carol: HTLC con hash H, time lock 138 blocchi
4. Carol→Dave: HTLC con hash H, time lock 132 blocchi

Se Dave conosce R, riscuote da Carol, rivelando R. Carol poi riscuote da Bob, Bob da Alice. R si propaga all'indietro lungo il percorso. Se un hop fallisce, i time lock scadono e ogni hop recupera i propri fondi indipendentemente.

I time lock decrescenti (132 < 138 < 144) sono critici: ogni nodo intermedio ha tempo per riscuotere il proprio HTLC prima che il proprio time lock scada dopo aver inoltrato la preimmagine.

**Proprietà di sicurezza.** Gli hash lock forniscono atomicità senza terze parti fidate:

- **Atomicità**: entrambe le parti completano lo scambio, o nessuna delle due. Il completamento parziale è impossibile perché riscuotere l'HTLC della parte ricevente rivela automaticamente R, che permette di riscuotere l'HTLC della parte mittente.
- **Non-custodial**: i fondi sono sempre controllati da uno script, mai da una controparte
- **Trustless**: nessun intermediario può rubare fondi e nessuna parte può imbrogliare rifiutandosi di rivelare R (il time lock protegge la parte onesta)

**Riutilizzo della preimmagine e privacy.** Usare la stessa R per HTLC multipli crea una perdita di privacy: chiunque veda una riscossione può collegare tutte le transazioni che usano quella R. Le implementazioni moderne della Lightning Network usano preimmagini diverse per ogni pagamento. Ogni HTLC dovrebbe usare una preimmagine unica e crittograficamente casuale.

**Point Timelock (PTLC).** Un'alternativa avanzata agli HTLC che usa firme adattatore invece di hash lock. Invece di bloccare con un hash, un PTLC blocca con un punto della curva ellittica. La preimmagine non è un valore grezzo R ma uno scalare che, moltiplicato per G, produce il punto. Questo permette:
- Stesse proprietà di privacy degli hash lock
- Potenziale per scriptless script (la condizione di blocco sembra una normale spesa via chiave)
- Impronta on-chain ridotta
- Aggregazione basata su Schnorr

I PTLC non sono ancora implementati su mainnet Bitcoin ma sono un'estensione nota per futuri aggiornamenti del protocollo, particolarmente nel contesto di Taproot e firme Schnorr.

**OP_SHA256 vs OP_HASH256.** Gli hash lock possono usare entrambi gli opcode. OP_SHA256 hash con singolo SHA-256, producendo 32 byte. OP_HASH256 produce doppio SHA-256. SHA-256 singolo è preferito per HTLC perché è standard nelle specifiche del protocollo Lightning Network e compatibile con le specifiche BOLT.
