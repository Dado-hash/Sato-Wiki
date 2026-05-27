---
id: wiki.schnorr-signatures
slug: schnorr-signatures
language: it
category: cryptography
title: Firme Schnorr
description: Lo schema di firma lineare introdotto con Taproot che consente aggregazione delle firme, verifica in batch e multisignature piu efficienti.
coverImage: media/wiki/schnorr-signatures/schnorr-signing.svg
difficulty: advanced
readTimeMinutes: 9
tags:
  - Crittografia
  - Schnorr
  - Firme
  - Taproot
  - BIP 340
related:
  - wiki.ecdsa
  - wiki.digital-signatures
  - wiki.taproot
  - wiki.multisig
  - wiki.public-keys
sources:
  - title: "BIP 340 - Schnorr Signatures for secp256k1"
    url: https://github.com/bitcoin/bips/blob/master/bip-0340.mediawiki
    author: Pieter Wuille, Jonas Nick, Tim Ruffing
  - title: "BIP 341 - Taproot: SegWit version 1 spending rules"
    url: https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki
    author: Pieter Wuille, Jonas Nick, Anthony Towns
  - title: "BIP 342 - Taproot Script"
    url: https://github.com/bitcoin/bips/blob/master/bip-0342.mediawiki
    author: Pieter Wuille, Jonas Nick, Anthony Towns
updatedAt: 2026-05-27T00:00:00Z
---

## base

Le firme Schnorr sono un nuovo tipo di firma in Bitcoin, aggiunte nel 2021 con l'aggiornamento Taproot. Sono piu semplici, piu piccole e hanno una proprieta speciale chiamata linearita — le firme possono essere sommate tra loro.

Una firma Schnorr e sempre di 64 byte fissi, rispetto alle firme ECDSA che vanno da 70 a 72 byte in codifica DER. La dimensione fissa semplifica l'implementazione e rende prevedibile lo spazio consumato in ogni input.

La proprieta di linearita e cio che rende potenti le firme Schnorr. Poiche le firme possono essere sommate, un gruppo di firmatari puo produrre un'unica firma identica a quella di una singola persona. Questo offre tre vantaggi principali:

- **Multisignature che sembrano firme singole.** Un wallet multisignature 3-di-5 produce la stessa firma da 64 byte di un wallet a chiave singola. Un osservatore non puo sapere quante persone hanno firmato.
- **Verifica in batch.** Verificare 1000 firme tutte insieme e circa 2 volte piu veloce che verificarle singolarmente.
- **Privacy.** Gli output multisignature sulla chain sono indistinguibili da output a firma singola.

Immagina una penna di firma di gruppo. Quando un comitato deve firmare un documento, ogni membro tocca la stessa penna. La firma risultante e un unico segno coesivo che prova che l'intero gruppo ha approvato — non una collezione di firme individuali che rivela quante persone erano coinvolte.

![Schema delle firme Schnorr](media/wiki/schnorr-signatures/schnorr-signing.svg "La firma Schnorr usa un impegno nonce R e un hash challenge e. La firma (R, s) e di 64 byte. Firma multiple possono essere aggregate in una.")

## medium

La firma Schnorr funziona con tre componenti: una chiave privata d, una chiave pubblica Q = d*G e un messaggio m. Il firmatario sceglie un nonce casuale k, calcola un impegno R = k*G, poi deriva una challenge e = H(R || Q || m). Lo scalare della firma e s = k + e*d. La firma completa e la coppia (R, s), esattamente 64 byte.

La verifica e immediata. Il verificatore calcola la stessa challenge e = H(R || Q || m) e controlla che s*G = R + e*Q. Se l'equazione e soddisfatta, la firma e valida. A differenza di ECDSA, Schnorr non supporta il recupero della chiave pubblica — la chiave pubblica deve essere fornita separatamente.

La variante BIP 340 usata in Bitcoin specifica chiavi pubbliche x-only: solo la coordinata x della chiave pubblica viene trasmessa, e la coordinata y e implicitamente pari. Questo risparmia un byte per chiave pubblica e evita di calcolare una radice quadrata durante la verifica. Se la coordinata y effettiva e dispari, la chiave privata viene negata per renderla pari.

**Aggregazione delle chiavi con MuSig.** MuSig e un protocollo multisignature che permette a piu parti di produrre un'unica firma Schnorr. Ogni partecipante contribuisce con una quota di chiave e una quota di nonce. La chiave pubblica aggregata e una somma pesata delle chiavi pubbliche di tutti i partecipanti. Il nonce aggregato e la firma vengono calcolati attraverso un processo di firma interattivo:

1. Ogni partecipante genera un impegno nonce e lo trasmette.
2. Tutti calcolano il nonce aggregato R da tutti gli impegni.
3. Ogni partecipante calcola la propria firma parziale s_i.
4. Le firme parziali vengono sommate per produrre la s aggregata.

La firma finale (R, s) e identica nella struttura a una firma Schnorr singola. Nessuno che osserva la blockchain puo determinare che fossero coinvolti piu firmatari.

**Verifica in batch.** Le firme Schnorr supportano la verifica in batch grazie alla proprieta di linearita. Date n firme (R_i, s_i) su messaggi m_i con chiavi pubbliche Q_i, un verificatore puo controllare una combinazione lineare casuale invece di verificare ogni equazione individualmente. Questo riduce il numero di moltiplicazioni costose di punti sulla curva ellittica da 2n a circa n + 1, offrendo un'accelerazione di circa 2x. I coefficienti casuali impediscono a un firmatario malintenzionato di creare firme che superano la verifica in batch ma fallirebbero individualmente.

## advanced

**Scelte progettuali di BIP 340.** BIP 340 specifica la variante di firma Schnorr usata in Bitcoin. Differisce dalla Schnorr classica in diversi aspetti:

- **Chiavi pubbliche x-only.** Viene usata solo la coordinata x della chiave pubblica. Questo riduce la dimensione della chiave pubblica da 33 a 32 byte. Durante la verifica, l'implementazione assume che la coordinata y sia pari. Se una chiave ha coordinata y dispari, il possessore della chiave nega la propria chiave privata prima di firmare, invertendo la coordinata y a pari. Questo trucco evita la necessita di un controllo di residuo quadratico durante la verifica ed elimina un ramo condizionale.
- **La challenge include la chiave pubblica.** L'hash challenge e e = H(R || Q || m), non e = H(R || m). Includere Q nell'hash previene attacchi di cancellazione della chiave in contesti multisignature. Senza di esso, un attaccante in uno schema multisignature potrebbe scegliere una chiave pubblica che annulla la chiave di un altro partecipante, producendo una chiave aggregata che controllano interamente.
- **Generazione del nonce.** Il firmatario non deve mai riutilizzare o rivelare il nonce k. Se k viene riutilizzato con messaggi diversi, la chiave privata puo essere recuperata risolvendo due equazioni. Se k e noto, la chiave privata puo essere calcolata direttamente. BIP 340 raccomanda la generazione deterministica del nonce usando la chiave privata e il messaggio come input di una funzione pseudocasuale, eliminando il rischio di fallimento dell'RNG.

**MuSig, MuSig2 e FROST.** Tre protocolli multisignature si basano sulla linearita di Schnorr:

- MuSig (2018) richiede tre round di comunicazione: uno per l'aggregazione delle chiavi, uno per l'impegno del nonce, uno per le firme parziali. E sicuro nel modello a chiave pubblica semplice e non richiede prova di possesso per la registrazione della chiave.
- MuSig2 (2020) riduce il protocollo a due round inviando due impegni nonce per firmatario invece di uno. Questo lo rende pratico per ambienti con interattivita limitata, come i canali della Lightning Network.
- FROST (2020) e uno schema di firma a soglia. Invece di richiedere la partecipazione di tutti, qualsiasi sottoinsieme t-di-n puo produrre una firma valida. FROST usa un protocollo di generazione distribuita delle chiavi dove ogni partecipante detiene una quota della chiave privata. Le firme parziali di t partecipanti vengono combinate in un'unica firma Schnorr. Questa e la base per wallet a soglia e custodia distribuita.

**Firme adattatore.** Le firme Schnorr adattatore estendono lo schema con un valore nascosto chiamato adattatore. Dato un adattatore t, un firmatario puo produrre una pre-firma che sembra una firma regolare ma non e ancora valida. La pre-firma puo essere trasformata in una firma valida rivelando t. Questo permette:

- Scambi atomici: Due parti si scambiano firme adattatore su blockchain diverse. Quando una firma viene completata sulla chain, l'adattatore viene rivelato, permettendo all'altra parte di completare la propria firma.
- Discreet Log Contracts (DLC): Gli esiti firmati da un oracolo sono codificati come firme adattatore. La parte vincente completa la firma usando l'attestazione dell'oracolo.
- Payment pool: I partecipanti creano firme adattatore che impongono le condizioni di pagamento senza richiedere transazioni sulla chain a meno che qualcuno non tenti di imbrogliare.

**Aggregazione cross-input delle firme.** Le firme Schnorr possono potenzialmente essere aggregate tra diversi input della stessa transazione. Invece di avere ogni input con la propria firma da 64 byte, tutti gli input potrebbero condividere un'unica firma aggregata. Questo ridurrebbe significativamente la dimensione della transazione — una transazione con 10 input risparmierebbe oltre 500 byte. L'aggregazione cross-input non e ancora implementata in Bitcoin e richiede modifiche al consenso. E un'area di ricerca attiva, con proposte per la half-aggregation (aggregare le firme in un'unica prova da 32 byte) in fase di esplorazione.

**Modello di sicurezza.** Le firme Schnorr sono dimostrabilmente sicure sotto l'assunzione del logaritmo discreto nel modello dell'oracolo casuale (ECDLP). Cio significa che se un attaccante puo falsificare una firma Schnorr, puo anche calcolare logaritmi discreti — un problema considerato computazionalmente impossibile per la curva secp256k1. La dimostrazione richiede che la funzione hash si comporti come un oracolo casuale, che e una forte idealizzazione, ma il margine di sicurezza pratico e considerato sufficiente dalla comunita crittografica. Al contrario, ECDSA manca di una dimostrazione di sicurezza sotto le stesse assunzioni e si basa su diverse proprieta algebriche.

Schnorr fornisce anche l'impossibilita di falsificazione forte sotto attacchi a messaggio scelto (SUF-CMA). Anche se un attaccante ottiene firme su messaggi arbitrari a sua scelta, non puo produrre una firma su un nuovo messaggio. La non-malleabilita delle firme Schnorr e intrinseca: data una firma valida (R, s), un attaccante non puo produrre una firma valida diversa per lo stesso messaggio, a differenza di ECDSA dove le firme sono malleabili negando s o usando diverse codifiche DER.
