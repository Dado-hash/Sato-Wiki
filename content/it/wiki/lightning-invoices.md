---
id: wiki.lightning-invoices
slug: lightning-invoices
language: it
category: lightning network
title: Fatture Lightning (BOLT 11)
description: Richieste di pagamento standardizzate sulla Lightning Network, codificate come stringhe bech32, contenenti l'hash di pagamento, l'importo, la descrizione e una prova crittografica.
coverImage: media/wiki/lightning-invoices/invoice-creation.svg
difficulty: advanced
readTimeMinutes: 8
tags:
  - Lightning Network
  - Fatture
  - BOLT 11
  - Pagamenti
  - Bech32
related:
  - wiki.lightning-network
  - wiki.htlcs
  - wiki.onion-routing
  - wiki.multipath-payments
  - wiki.routing-fees
sources:
  - title: "BOLT #11 — Invoice Protocol for Lightning Payments"
    url: https://github.com/lightning/bolts/blob/master/11-payment-encoding.md
    author: Lightning Network Specifications
    publishedAt: 2017-05-01
  - title: "Mastering the Lightning Network — Chapter 10: Invoices"
    url: https://github.com/lnbook/lnbook
    author: Andreas M. Antonopoulos, Olaoluwa Osuntokun, Rene Pickhardt
updatedAt: 2026-05-27T00:00:00Z
---

## base

Una fattura Lightning (Lightning invoice) è una richiesta di pagamento che dice al pagatore cosa pagare e dove inviare i fondi. Come una fattura di un idraulico — descrive il servizio, l'importo dovuto e dove effettuare il pagamento.

Una fattura contiene un hash di pagamento (l'hash SHA256 di un preimmagine segreto scelto dal ricevente), l'importo richiesto, una descrizione del commerciante e un tempo di scadenza. Viene codificata come stringa bech32 che inizia con `lnbc` per la rete principale. La fattura può essere condivisa come testo, codice QR o tramite NFC.

Quando il pagatore riceve la fattura, il suo wallet la decodifica, trova l'hash di pagamento, costruisce una route attraverso la Lightning Network fino al ricevente e invia HTLC (Hash Time Locked Contracts) lungo quella route. Il ricevente riscuote il pagamento rivelando il preimmagine, che il pagatore può verificare corrisponda all'hash di pagamento.

![Ciclo di vita della fattura Lightning](media/wiki/lightning-invoices/invoice-creation.svg "Il ricevente crea una fattura con un hash di pagamento; il pagatore la decodifica e instrada un pagamento attraverso la rete.")

## medium

**Formato BOLT 11.** Una fattura Lightning ha tre parti: un prefisso leggibile (HRP), una parte dati e una firma. Il prefisso inizia con `ln` (Lightning), seguito da `bc` (Bitcoin mainnet) e dall'importo. Ad esempio, `lnbc10u` significa 10 microBTC (10.000 satoshi). Gli importi usano suffissi SI: `p` (pico), `n` (nano), `u` (micro), `m` (milli).

**Campi taggati.** La parte dati codifica i campi come tuple tipo-lunghezza-valore. Ogni campo inizia con un carattere che ne indica il tipo, seguito da una lunghezza di 2 caratteri e dal valore:

- `p` — Hash di pagamento (SHA256 a 256 bit del preimmagine)
- `d` — Descrizione, una stringa di testo breve
- `h` — Hash della descrizione, SHA256 di una descrizione lunga
- `x` — Scadenza in secondi (default 3600)
- `n` — ID del pagatore (node ID del creatore)
- `r` — Suggerimenti di routing per canali privati
- `9` — Feature bits per estensioni del protocollo

**Firma.** Gli ultimi 520 bit (65 byte) sono una firma ECDSA recuperabile. Copre l'intera parte dati e permette a chiunque di verificare che la fattura sia stata creata dal possessore della chiave privata del nodo. L'id di recupero permette di estrarre la chiave pubblica dalla sola firma.

**Come l'hash di pagamento si collega agli HTLC.** Il pagatore usa l'hash di pagamento dalla fattura come hash lock in ogni HTLC lungo la route. Solo il ricevente conosce il preimmagine, quindi solo lui può riscuotere il pagamento rivelandolo. Quando il preimmagine si propaga all'indietro, ogni nodo intermedio viene rimborsato e il pagatore ha una prova crittografica che il ricevente ha ricevuto i fondi.

**Scadenza e CLTV.** Il campo `x` imposta la scadenza della fattura (default 1 ora). Il `min_final_cltv_expiry` dice al pagatore il delta timelock minimo da impostare sull'HTLC finale, proteggendo il ricevente da fondi bloccati se la route di pagamento è lenta.

![Struttura della fattura BOLT 11](media/wiki/lightning-invoices/invoice-anatomy.svg "Una stringa bech32 segmentata in HRP, importo, timestamp, campi taggati e firma.")

## advanced

**Dettagli della codifica Bech32.** BOLT 11 utilizza la stessa codifica bech32 degli indirizzi SegWit (BIP 173). I dati sono suddivisi in parole da 5 bit, rendendo efficiente la codifica per codici QR e la trascrizione manuale. Bech32 include un checksum BCH (6 caratteri) che rileva fino a 4 errori e ne corregge 1. La codifica usa un set di caratteri limitato (32 caratteri: alfanumerici esclusi `1`, `b`, `i`, `o`) per minimizzare le ambiguità.

**Struttura della parte dati.** La parte dati inizia con un timestamp a 35 bit (epoch Unix in secondi). Dopo il timestamp seguono uno o più campi taggati, ciascuno con un tipo di 1 carattere, una lunghezza di 2 caratteri e un valore a lunghezza variabile. La firma occupa gli ultimi 520 bit: `r` a 256 bit, `s` a 256 bit e un recovery id a 8 bit.

**Hash della descrizione vs testo semplice.** Quando la descrizione è breve (sotto i 639 byte), i wallet usano il campo `d` con il testo letterale. Per descrizioni lunghe, il campo `h` memorizza SHA256(descrizione) e la descrizione deve essere comunicata fuori banda. Il wallet del pagatore calcola l'hash della descrizione fornita e lo confronta con il campo `h` della fattura per assicurarsi che corrisponda a quanto inteso dal ricevente.

**Suggerimenti di routing (campo `r`).** Se il ricevente è dietro uno o più canali privati (non annunciati), include suggerimenti di routing. Ogni suggerimento contiene un hop con: `short_channel_id`, `node_id`, `fee_base_msat`, `fee_proportional_millionths`, `cltv_expiry_delta`. Il pagatore incorpora questi suggerimenti nella ricerca della route. Più suggerimenti per percorsi diversi aumentano la probabilità che il pagatore raggiunga il ricevente.

**Feature bits (campo `9`).** I feature bits pubblicizzano le capacità del protocollo:
- Bit 8/9 — MPP (Multi-Path Payments): suddividere un pagamento su più route
- Bit 9/9 — Keysend: pagamenti spontanei senza fattura
- Bit 15 — Trampoline: routing delegato attraverso nodi trampolino
- Bit 17/19 — Offerte BOLT 12

Le future assegnazioni di feature sono tracciate nel repository dei BOLT.

**Offerte BOLT 12.** Il protocollo Offers è la sostituta di nuova generazione per BOLT 11. A differenza delle fatture, le offerte non sono monouso: una singola offerta può generare molte fatture, permettendo pagamenti ricorrenti e ricezione asincrona. Le offerte usano blinded path (route blinding) invece di routing hints, migliorando la privacy. Il preimmagine è derivato deterministicamente da un segreto statico, evitando i problemi di riutilizzo del preimmagine. Le offerte supportano anche i rimborsi (il ricevente diventa pagatore) e sono più adatte all'automazione.

**Keysend / Pagamenti Spontanei.** Keysend bypassa completamente il flusso della fattura. Il mittente genera un hash di pagamento da un preimmagine che sceglie lui, invia il pagamento e include il preimmagine nel payload onion usando il record TLV `key_send`. Il ricevente estrae il preimmagine, riscuote il pagamento e apprende il preimmagine dall'onion. Poiché il pagatore sceglie il preimmagine, Keysend non fornisce prova di pagamento — solo il pagatore, non il ricevente, può provare che il pagamento è avvenuto.
