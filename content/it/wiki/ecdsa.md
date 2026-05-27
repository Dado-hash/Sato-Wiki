---
id: wiki.ecdsa
slug: ecdsa
language: it
category: cryptography
title: ECDSA
description: L'algoritmo di firma digitale a curva ellittica che Bitcoin usa dal suo inizio per autorizzare transazioni attraverso la proprietà della chiave privata.
coverImage: media/wiki/ecdsa/ecdsa-sign-verify.svg
difficulty: advanced
readTimeMinutes: 9
tags:
  - Crittografia
  - ECDSA
  - Firme
  - Curva Ellittica
related:
  - wiki.digital-signatures
  - wiki.schnorr-signatures
  - wiki.private-keys
  - wiki.public-keys
  - wiki.secp256k1
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: "ANSI X9.62 - Standard ECDSA"
    url: https://www.secg.org/sec1-v2.pdf
    author: SECG
  - title: "BIP 340 - Schnorr Signatures for secp256k1"
    url: https://github.com/bitcoin/bips/blob/master/bip-0340.mediawiki
    author: Pieter Wuille, Jonas Nick, Tim Ruffing
updatedAt: 2026-05-27T00:00:00Z
---

## base

ECDSA è l'algoritmo di firma originale che Bitcoin usa per autorizzare le transazioni. Una firma prova la conoscenza di una chiave privata senza rivelarla. Ogni input di transazione Bitcoin contiene una firma ECDSA che sblocca i fondi dimostrando la proprietà della chiave privata corrispondente alla chiave pubblica bloccata nell'output.

Per firmare un messaggio `z` (l'hash della transazione) con la chiave privata `d`:

1. Scegli un nonce casuale `k` tra 1 e `n-1`, dove `n` è l'ordine della curva.
2. Calcola il punto della curva ellittica `R = k * G`, dove `G` è il punto generatore. Sia `r = R.x`.
3. Calcola `s = k⁻¹(z + r * d) mod n`.
4. La firma è `(r, s)`.

Per verificare una firma `(r, s)` rispetto a un messaggio `z` e una chiave pubblica `Q`:

1. Calcola `u₁ = z * s⁻¹ mod n` e `u₂ = r * s⁻¹ mod n`.
2. Calcola il punto `R' = u₁ * G + u₂ * Q`.
3. Verifica che `R'.x == r`. Se sono uguali, la firma è valida.

![Firma e Verifica ECDSA](media/wiki/ecdsa/ecdsa-sign-verify.svg "La formula di firma ECDSA a sinistra produce (r, s) dalla chiave privata, dall'hash del messaggio e dal nonce casuale k. La formula di verifica a destra calcola u1 e u2, ricostruisce il punto R' e controlla che la sua coordinata x sia uguale a r.")

L'intuizione semplice: il firmatario dimostra di conoscere la chiave privata `d` creando una relazione matematica che solo chi possiede `d` potrebbe produrre. L'equazione di verifica `R' = u₁ * G + u₂ * Q` si espande in `(z * s⁻¹) * G + (r * s⁻¹) * Q`. Sostituendo `Q = d * G` e `s = k⁻¹(z + r * d)` si dimostra che `R'` ricostruisce l'`R` originale, confermando che il firmatario conosceva `d`.

## medium

**Il nonce è critico.** Il valore casuale `k` deve soddisfare due proprietà: deve essere unico per ogni firma della stessa chiave privata e deve rimanere segreto. Se `k` viene mai riutilizzato con la stessa chiave privata, chiunque veda entrambe le firme può calcolare direttamente la chiave privata:

- Date due firme `(r, s₁)` e `(r, s₂)` con lo stesso `k` e lo stesso `r`, un attaccante calcola `k = (z₁ - z₂) / (s₁ - s₂)` e poi `d = (s₁ * k - z₁) / r`.

Non è un rischio teorico. Nel 2010, Sony PlayStation 3 usava un nonce `k` fisso per le firme ECDSA, permettendo agli attaccanti di derivare la chiave privata usata per firmare gli aggiornamenti del firmware. Nel 2013, un bug nell'implementazione di `SecureRandom` su Android produceva nonce deboli, permettendo agli attaccanti di svuotare wallet scansionando la blockchain per firme con lo stesso valore `r`.

Per eliminare il rischio di casualità debole, RFC 6979 definisce un modo deterministico per generare `k` hashando insieme la chiave privata e il messaggio. Questo garantisce che lo stesso messaggio produca sempre lo stesso nonce — sicuro perché la chiave privata è segreta — mentre messaggi o chiavi diversi producono nonce non correlati. La maggior parte dei wallet Bitcoin moderni usa RFC 6979.

**Formato della firma.** Una firma ECDSA è tipicamente codificata in formato DER (Distinguished Encoding Rules). Una firma tipica occupa 70-72 byte:

```
30 [lunghezza-totale] 02 [lunghezza-r] [byte di r] 02 [lunghezza-s] [byte di s]
```

La lunghezza variabile deriva dal fatto che DER usa codifica big-endian minima senza byte zero iniziali, e antepone un byte `0x00` quando il bit più significativo è impostato (per evitare che l'intero sia interpretato come negativo).

**Recupero della chiave pubblica.** Le firme ECDSA hanno una proprietà utile: dati `(r, s)` e il messaggio `z`, è possibile recuperare la chiave pubblica `Q` senza conoscerla in anticipo. Questa è chiamata recovery della chiave pubblica o key recovery. Tipicamente ci sono quattro possibili chiavi recuperabili (due possibili punti `R` dalla coordinata x `r`, e per ciascuno, due possibili valori basati sul recovery ID o byte "v"). Ethereum usa estensivamente questa proprietà: le transazioni includono solo la firma e l'indirizzo del mittente è derivato dalla chiave pubblica recuperata.

In Bitcoin, il recupero della chiave pubblica è usato nell'algoritmo di hash della firma. L'ID di recovery (v) è codificato insieme alla firma per distinguere quale dei quattro candidati è corretto. Gli indirizzi SegWit v0 (P2WPKH) e gli indirizzi legacy P2PKH si basano entrambi su questo meccanismo.

**Generazione del nonce in dettaglio.** RFC 6979 genera `k` in modo deterministico e resistente ad attacchi side-channel:

1. Hasha la chiave privata e il messaggio per produrre un seed iniziale.
2. Usa HMAC-DRBG (un generatore di bit casuali deterministico basato su HMAC-SHA256) per produrre `k`.
3. Se `k` è zero o maggiore di `n`, rigenera usando il meccanismo di reseed del DRBG.

Questo approccio garantisce unicità senza affidarsi all'entropia di sistema, rendendolo adatto a dispositivi embedded, wallet hardware e qualsiasi ambiente in cui la casualità potrebbe essere compromessa.

## advanced

**Dettagli della codifica DER.** La codifica DER completa di una firma ECDSA segue la struttura ASN.1:

- Un tag SEQUENCE (`0x30`) seguito dalla lunghezza totale dei dati rimanenti.
- Un tag INTEGER (`0x02`) per `r`, la sua lunghezza e il valore stesso di `r`, codificato come intero big-endian con segno senza zero iniziali. Se il bit più alto di `r` è impostato, viene anteposto un byte di padding `0x00`.
- Un tag INTEGER (`0x02`) per `s`, con le stesse convenzioni di codifica.

Questa codifica è ciò che rende la dimensione della firma ECDSA variabile. BIP 66 ha standardizzato la codifica DER stretta per Bitcoin, richiedendo esattamente questo formato e rifiutando qualsiasi deviazione. Prima di BIP 66, i nodi accettavano codifiche non strette, creando vettori di malleabilità.

**Malleabilità della firma.** Le firme ECDSA sono malleabili in diversi modi:

- **Malleabilità di `s` (BIP 62).** Se `(r, s)` è una firma valida, allora `(r, n-s)` è valida per lo stesso messaggio e chiave, poiché `s` e `n-s` sono inversi modulari l'uno dell'altro. BIP 146 (requisito low-s) ha fatto sì che Bitcoin rifiuti le firme dove `s > n/2`, eliminando questo vettore.
- **Malleabilità del padding DER.** Prima di BIP 66, byte di padding extra negli interi DER potevano essere aggiunti o rimossi senza cambiare la validità matematica di `(r, s)`. Un attaccante poteva modificare la codifica per produrre un identificatore di transazione (txid) diverso per la stessa transazione logica.
- **Malleabilità da terze parti.** Prima di SegWit, chiunque poteva prendere una transazione non confermata, modificare la codifica DER della sua firma e trasmettere la versione mutata. Poiché il txid cambiava, la transazione mutata poteva essere confermata al posto dell'originale, invalidando di fatto l'originale. SegWit ha risolto questo problema spostando le firme nella struttura witness, che è esclusa dal calcolo del txid.

BIP 66 (DER stretto) e BIP 62 (requisito low-s) hanno ridotto significativamente la malleabilità. SegWit l'ha eliminata completamente per gli input SegWit.

**ECDSA vs Schnorr.** ECDSA ha diversi svantaggi strutturali rispetto alle firme Schnorr (BIP 340):

- **Non-linearità.** ECDSA non è lineare: l'equazione di firma `s = k⁻¹(z + r * d)` coinvolge l'inversione modulare e mescola l'hash del messaggio sia con la chiave privata che con il nonce in un modo che non supporta combinazioni algebriche. Le firme Schnorr sono lineari: `s = k + e * d`, che abilita aggregazione delle firme, verifica batch e firme adattatore.
- **Verifica batch.** Le firme Schnorr possono essere verificate in batch: verificare `n` firme costa meno di `n` volte il costo di una singola verifica, usando combinazioni lineari casuali. ECDSA non supporta affatto la verifica batch — ogni firma deve essere controllata individualmente.
- **Aggregazione delle firme.** Multiple firme Schnorr di firmatari diversi su messaggi diversi possono essere aggregate in una singola firma, riducendo l'uso di spazio nei blocchi. MuSig e MuSig2 (BIP 327) costruiscono schemi di multi-firma su questa proprietà.
- **Dimensione.** Le firme Schnorr sono fisse a 64 byte. Le firme ECDSA sono 70-72 byte in codifica DER.

**Dimostrazione di sicurezza.** ECDSA è dimostrato esistenzialmente infalsificabile sotto attacco a messaggio scelto (EUF-CMA) nel modello dell'oracolo casuale, assumendo che il problema del logaritmo discreto su curva ellittica sia difficile. La dimostrazione modella la funzione hash come un oracolo casuale e mostra che un avversario in grado di falsificare firme può essere usato per risolvere il problema del logaritmo discreto.

La riduzione di sicurezza è stretta: un falsificatore di successo implica un risolutore del logaritmo discreto con approssimativamente lo stesso vantaggio. Questo significa che ECDSA su secp256k1 fornisce circa 128 bit di sicurezza (metà della dimensione della chiave, a causa dell'algoritmo rho di Pollard per il logaritmo discreto).

**Perché BIP 340 Schnorr sta sostituendo ECDSA.** L'aggiornamento Taproot di Bitcoin (2021) ha introdotto le firme Schnorr come opzione nativa tramite BIP 340. Mentre ECDSA rimane in uso esteso per transazioni legacy e SegWit v0, i nuovi sviluppi di protocollo favoriscono Schnorr:

- **Gli output Taproot** usano Schnorr di default, offrendo dimensioni delle transazioni ridotte e migliore privacy.
- **L'aggregazione delle firme tra input** (proposta) aggregherebbe le firme attraverso input multipli in una singola transazione, riducendo significativamente la dimensione delle transazioni con molti input.
- **I protocolli di smart contract** come Lightning Network e Discreet Log Contracts beneficiano della linearità di Schnorr per firme adattatore e atomic swap.

ECDSA rimarrà parte delle regole di consenso di Bitcoin indefinitamente — gli output legacy non possono essere spesi senza — ma tutte le nuove funzionalità basate su firme vengono costruite su Schnorr.
