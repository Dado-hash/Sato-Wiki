---
id: wiki.timelocks
slug: timelocks
language: it
category: cryptography
title: Time Lock
description: Primitivi di Bitcoin che impediscono la spesa di un output fino al raggiungimento di una specifica altezza di blocco o tempo.
coverImage: media/wiki/timelocks/timelock-cltv-csv.svg
difficulty: advanced
readTimeMinutes: 8
tags:
  - Crittografia
  - Time Lock
  - Script
  - Lightning Network
  - CLTV
  - CSV
related:
  - wiki.hashlocks
  - wiki.bitcoin-script
  - wiki.lightning-network
  - wiki.payment-channels
  - wiki.commitment-transactions
sources:
  - title: "BIP 65 — OP_CHECKLOCKTIMEVERIFY"
    url: https://github.com/bitcoin/bips/blob/master/bip-0065.mediawiki
    author: Peter Todd
    publishedAt: 2014-10-10
  - title: "BIP 68 — Relative lock-time using consensus-enforced sequence numbers"
    url: https://github.com/bitcoin/bips/blob/master/bip-0068.mediawiki
    author: Mark Friedenbach, BtcDrak, Nicolas Dorier, kinoshitajona
    publishedAt: 2015-05-28
  - title: "BIP 112 — CHECKSEQUENCEVERIFY"
    url: https://github.com/bitcoin/bips/blob/master/bip-0112.mediawiki
    author: BtcDrak, Mark Friedenbach, Eric Lombrozo
    publishedAt: 2015-08-10
updatedAt: 2026-05-27T00:00:00Z
---

## base

I time lock sono condizioni che impediscono a una transazione Bitcoin di essere confermata fino a un certo punto nel tempo. Sono il meccanismo che permette contratti basati sul tempo su Bitcoin, formando la base dei canali di pagamento, della Lightning Network e di molti altri pattern di smart contract.

Ci sono due tipi di time lock in Bitcoin:

**Time lock assoluti.** Bloccano una transazione o output fino a una specifica altezza di blocco (es. blocco 800.000) o un timestamp UNIX specifico (es. 1 gennaio 2027). La transazione non può essere minata prima di quel punto, indipendentemente dalla commissione.

**Time lock relativi.** Bloccano una transazione o output per una durata specifica misurata da quando l'output è stato incluso in un blocco. Per esempio, se un output è stato minato nel blocco 800.000 con un time lock relativo di 100 blocchi, non può essere speso fino al blocco 800.100.

Entrambi i tipi sono imposti a livello di consenso — ogni full node verifica le condizioni di time lock prima di accettare un blocco. Questo è ciò che rende i time lock affidabili senza intermediari.

![Confronto tra CLTV e CSV](media/wiki/timelocks/timelock-cltv-csv.svg "I time lock assoluti (CLTV) bloccano fino a un'altezza o tempo specifici. I time lock relativi (CSV) bloccano per una durata dopo che l'output è minato.")

## medium

I time lock esistono a due livelli separati: a livello di transazione e a livello di script.

**Livello transazione: locktime e sequence.**

Ogni transazione ha un campo locktime (4 byte) che imposta una condizione di tempo assoluto. Se locktime è diverso da zero e minore di 500 milioni, è interpretato come altezza di blocco. Se è 500 milioni o maggiore, è un timestamp UNIX. Una transazione con locktime > 0 non è considerata finale fino al raggiungimento del suo locktime.

Il campo nSequence in ogni input permette time lock relativi a livello di transazione. BIP 68 ha ridefinito la semantica del numero di sequenza: se il bit più significativo di nSequence è zero (bit 31 = 0), i bit rimanenti codificano un time lock relativo. La codifica usa il secondo bit più significativo per distinguere tra blocchi (bit 30 = 0) e tempo (bit 30 = 1, in granularità di 512 secondi).

**Livello script: OP_CHECKLOCKTIMEVERIFY e OP_CHECKSEQUENCEVERIFY.**

CLTV (BIP 65) spinge un valore sullo stack. Se quel valore è maggiore del locktime della transazione, lo script fallisce. Questo collega le condizioni basate su script al locktime a livello di transazione. Un uso tipico:
```
<locktime> OP_CHECKLOCKTIMEVERIFY OP_DROP OP_CHECKSIG
```

CSV (BIP 112) funziona similmente ma verifica contro il numero di sequenza dell'input (BIP 68) invece del locktime della transazione:
```
<blocchi_relativi> OP_CHECKSEQUENCEVERIFY OP_DROP OP_CHECKSIG
```

## advanced

**Dettagli del locktime di transazione.** Il campo locktime usa regole di codifica multiple:
- Valore 0: immediatamente finale
- Valori 1-499.999.999: altezza di blocco
- Valori ≥ 500.000.000: timestamp UNIX
- La regola median-time-past (MTP) richiede che il locktime sia confrontato con la mediana degli ultimi 11 blocchi, non con il timestamp del blocco stesso. Questo impedisce ai miner di manipolare i timestamp per spendere output con time lock prematuramente.

**Codifica della sequenza BIP 68.** Quando bit 31 = 0, i 16 bit inferiori codificano:
- Se bit 30 = 0: blocchi relativi (valore 16 bit, max 65535 blocchi ≈ 455 giorni)
- Se bit 30 = 1: tempo relativo in intervalli di 512 secondi (max 65535 × 512 secondi ≈ 388 giorni)

Questa granularità è stata scelta in modo che un'unità di tempo relativo corrisponda approssimativamente all'intervallo di blocco target (10 minuti × 512/600 ≈ 0,85).

**Utilizzo nella Lightning Network.** I time lock sono la spina dorsale della sicurezza della Lightning Network. Ogni transazione di commitment usa sia CLTV che CSV:
- L'output to_local ha un time lock CSV (tipicamente 144 blocchi ≈ 24 ore) che impedisce al finanziatore del canale di spendere immediatamente il proprio saldo dopo una chiusura unilaterale
- Gli output HTLC usano CLTV per impostare il timeout assoluto per il pagamento, dopo il quale il mittente può reclamare i fondi se il destinatario non riesce a riscuotere
- La combinazione garantisce che le parti oneste possano sempre recuperare i propri fondi, anche se l'altra parte va offline o tenta di pubblicare uno stato obsoleto

**Vault e transazioni con time lock.** Costruzioni più avanzate usano time lock per vault — output che impongono un time lock prima che i fondi possano muoversi verso la loro destinazione finale. Un vault tipico usa:
1. Una chiave "hot" che può attivare un trasferimento a un indirizzo con time lock
2. L'indirizzo con time lock impone un ritardo
3. Durante il ritardo, una chiave "cold" (conservata offline) può annullare la transazione o reindirizzare i fondi

**Considerazioni sulla sicurezza.** I time lock sono imposti dal consenso, ma ci sono sfumature:
- I miner controllano quali transazioni entrano nei blocchi, nei limiti dei vincoli di time lock
- Un miner potrebbe teoricamente trattenere una transazione con time lock fino al blocco successivo, ma non può includerla prima
- Le riorganizzazioni possono resettare i time lock relativi se l'output non è più nella chain
- La regola MTP per CLTV significa che i valori di time lock possono essere ±2 ore dal tempo reale, il che è accettabile per la maggior parte dei casi d'uso
