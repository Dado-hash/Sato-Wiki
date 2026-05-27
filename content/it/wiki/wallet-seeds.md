---
id: wiki.wallet-seeds
slug: wallet-seeds
language: it
category: cryptography
title: Seed di Wallet
description: Le frasi mnemoniche leggibili che codificano l'entropia necessaria per generare deterministicamente tutte le chiavi di un wallet Bitcoin.
coverImage: media/wiki/wallet-seeds/wallet-seed-flow.svg
difficulty: advanced
readTimeMinutes: 8
tags:
  - Crittografia
  - Seed
  - Wallet
  - BIP 39
related:
  - wiki.hd-wallets
  - wiki.private-keys
  - wiki.bitcoin-addresses
  - wiki.public-keys
sources:
  - title: "BIP 39 — Mnemonic code for generating deterministic keys"
    url: https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki
    author: Marek Palatinus, Pavol Rusnak, Aaron Voisine, Sean Bowe
  - title: "BIP 32 — Hierarchical Deterministic Wallets"
    url: https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki
    author: Pieter Wuille
  - title: "Mastering Bitcoin - Capitolo 4"
    url: https://github.com/bitcoinbook/bitcoinbook/blob/develop/ch04.asciidoc
    author: Andreas M. Antonopoulos
updatedAt: 2026-05-27T00:00:00Z
---

## base

Un seed di wallet è una sequenza di parole — tipicamente 12 o 24 — che può generare ogni chiave in un wallet Bitcoin. Questa è la "chiave maestra" che annoti quando configuri un wallet. Se perdi il telefono o il computer, le parole seed sono tutto ciò che ti serve per ripristinare l'accesso ai tuoi bitcoin.

Il seed viene generato una volta dal tuo wallet usando una fonte di casualità (entropia). Questi bit casuali vengono divisi in gruppi e mappati a parole dalla wordlist BIP 39 — un elenco accuratamente curato di 2048 parole inglesi comuni. La sequenza di parole viene poi processata attraverso una funzione di key-stretching chiamata PBKDF2 per produrre un seed master di 512 bit.

Il sistema è gerarchico e deterministico. "Deterministico" significa che lo stesso seed produce sempre la stessa sequenza di chiavi. "Gerarchico" significa che le chiavi sono organizzate in una struttura ad albero, con diversi rami per diversi scopi (ricezione, resto, diverse criptovalute). Questa relazione uno-a-molti tra un seed e tutte le sue chiavi discendenti è ciò che rende il backup del wallet così semplice.

![Generazione del seed di wallet dall'entropia al seed master](media/wiki/wallet-seeds/wallet-seed-flow.svg "L'entropia casuale viene codificata in una frase mnemonica tramite BIP 39, poi trasformata in un seed master di 512 bit tramite PBKDF2.")

## medium

BIP 39 definisce lo standard del codice mnemonico. Il processo ha tre passaggi:

**Step 1: Genera entropia.** Il wallet genera ENT bit casuali usando un generatore di numeri casuali crittograficamente sicuro (CSPRNG). Dimensioni di entropia standard:
- 128 bit → frase di 12 parole
- 192 bit → frase di 18 parole
- 256 bit → frase di 24 parole

**Step 2: Calcola checksum.** Un hash SHA-256 dell'entropia fornisce CS = ENT/32 bit di checksum. Questi bit vengono aggiunti all'entropia.

**Step 3: Codifica in parole.** La stringa di bit combinata (ENT + CS) viene divisa in segmenti da 11 bit. Ogni segmento è un indice nella wordlist BIP 39 (0-2047). Ogni indice corrisponde a una parola dell'elenco.

La frase mnemonica viene poi processata da PBKDF2 con HMAC-SHA512:
```
seed = PBKDF2(mnemonico, "mnemonic" + passphrase, iterazioni = 2048, dklen = 512)
```

La passphrase opzionale aggiunge un ulteriore livello di sicurezza. Lo stesso mnemonico con una passphrase diversa produce un seed completamente diverso. Questa è talvolta chiamata "tredicesima parola" o "venticinquesima parola."

## advanced

**Entropia e sicurezza.** Un seed con entropia di 128 bit fornisce 128 bit di sicurezza contro attacchi di brute-force. Questo è considerato sufficiente per tutti gli scopi pratici: 2¹²⁸ operazioni è astronomicamente grande, superando la potenza di calcolo combinata di tutti i dispositivi umani. Anche 2⁸⁰ operazioni è attualmente considerato irrealizzabile per un avversario ben finanziato. La sicurezza effettiva è leggermente inferiore perché le frasi mnemoniche rappresentano una struttura nota, ma con 2048¹² ≈ 2¹³² possibili frasi di 12 parole, il margine rimane generoso.

**Proprietà della wordlist.** La wordlist BIP 39 (disponibile in inglese, giapponese, coreano, spagnolo, francese, italiano, ceco, portoghese e cinese) è stata scelta con proprietà specifiche:
- Ogni parola è lunga 4-8 caratteri
- I primi 4 caratteri identificano univocamente ogni parola (codice prefisso)
- Le parole sono selezionate per facilità di pronuncia e resistenza a errori di trascrizione
- L'elenco evita coppie di parole con suono o aspetto simile

**Vulnerabilità dei seed fisici.** Poiché il seed è il singolo punto di guasto per un wallet, la sua conservazione è critica. Approcci comuni:
- **Backup cartacei**: scritti e conservati in una cassaforte
- **Backup metallici**: incisi su acciaio inossidabile (ignifughi, impermeabili)
- **Shamir's Secret Sharing (SLIP 39)**: dividi il seed in più parti. Il recupero M-of-N richiede M parti, fornendo ridondanza e separazione della sicurezza
- **Multifirma**: distribuisci le chiavi su più dispositivi, ognuno con il proprio seed

**SLIP 39 (Shamir's Secret Sharing).** Un'alternativa a BIP 39 che usa Shamir's Secret Sharing per dividere il segreto master in più parti. Per esempio, uno schema 2-of-3 richiede 2 parti su 3 per recuperare il wallet. Questo elimina il problema del singolo punto di guasto dei seed BIP 39. SLIP 39 include anche una struttura di gruppi di backup: le parti possono essere organizzate in gruppi, ognuno con la propria soglia.

**Attacchi alla passphrase BIP 39.** La passphrase non viene verificata per correttezza durante il ripristino del wallet. Una passphrase errata produce chiavi valide — che però accedono a un wallet vuoto. Attaccanti che scoprono un mnemonico devono fare brute-force sulla passphrase se una è stata usata. Il costo di PBKDF2 (2048 iterazioni) aggiunge una protezione marginale contro questo, ma le implementazioni hardware wallet impongono limiti di velocità sui tentativi di passphrase.

**Confronto con i seed BIP 32 grezzi.** Prima di BIP 39, alcuni wallet salvavano semplicemente la chiave privata master grezza da 256 bit in formato esadecimale o WIF. BIP 39 ha migliorato l'usabilità codificando l'entropia in parole memorabili con verifica del checksum incorporata, riducendo il rischio di errori di trascrizione durante il backup.
