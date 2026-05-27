---
id: wiki.digital-signatures
slug: digital-signatures
language: it
category: cryptography
title: Firme Digitali
description: Il meccanismo crittografico che dimostra il possesso di una chiave privata senza rivelarla, proteggendo ogni transazione Bitcoin.
coverImage: media/wiki/digital-signatures/digital-signature-flow.svg
difficulty: advanced
readTimeMinutes: 8
tags:
  - Crittografia
  - Firma Digitale
  - Autenticazione
  - Transazioni
related:
  - wiki.private-keys
  - wiki.public-keys
  - wiki.ecdsa
  - wiki.schnorr-signatures
  - wiki.bitcoin-script
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: "Mastering Bitcoin - Chapter 4"
    url: https://github.com/bitcoinbook/bitcoinbook/blob/develop/ch04.asciidoc
    author: Andreas M. Antonopoulos
  - title: "BIP 340 - Schnorr Signatures for secp256k1"
    url: https://github.com/bitcoin/bips/blob/master/bip-0340.mediawiki
    author: Pieter Wuille, Jonas Nick, Tim Ruffing
updatedAt: 2026-05-27T00:00:00Z
---

## base

Una firma digitale dimostra che conosci una chiave privata senza rivelarla. In Bitcoin, firmi una transazione per autorizzare una spesa. Chiunque possieda la tua chiave pubblica può verificare che la firma sia stata creata dalla corrispondente chiave privata. Le firme sono uniche per ogni messaggio: non puoi riutilizzare una firma da una transazione su un'altra.

L'algoritmo di firma prende una chiave privata e un messaggio (la transazione) e produce una firma. L'algoritmo di verifica prende il messaggio, la firma e la chiave pubblica e restituisce valido o non valido. Una firma valida può essere stata creata solo da chi conosce la chiave privata, ma la verifica richiede solo la chiave pubblica — che è condivisa apertamente.

![Flusso della firma digitale: firma con chiave privata a sinistra, verifica con chiave pubblica a destra](media/wiki/digital-signatures/digital-signature-flow.svg "Diagramma a due colonne del processo di firma e verifica in Bitcoin: una chiave privata e una transazione producono una firma tramite ECDSA o Schnorr; la firma, la transazione e la chiave pubblica passano attraverso la verifica per restituire valido o non valido. La chiave privata non lascia mai il lato di firma.")

Pensala come un sigillo di cera personale. Premi il tuo anello unico (chiave privata) nella cera calda su un documento. Tutti sanno che aspetto ha il tuo sigillo (chiave pubblica), quindi possono verificare che sia autentico. Ma nessuno può contraffarlo perché non possiede il tuo anello.

## medium

Le firme digitali in Bitcoin forniscono tre proprietà fondamentali:

- **Autenticità del messaggio**: Il destinatario può confermare che il messaggio è stato creato dal mittente noto.
- **Non ripudio**: Il mittente non può successivamente negare di aver creato la firma, poiché solo la chiave privata potrebbe produrla.
- **Incontraffabilità**: Senza la chiave privata, creare una firma valida per un nuovo messaggio è computazionalmente impossibile.

Bitcoin utilizza l'Elliptic Curve Digital Signature Algorithm (ECDSA) sulla curva secp256k1 e, dall'aggiornamento Taproot, anche le firme Schnorr (BIP 340). Entrambi gli schemi si basano sulla difficoltà del problema del logaritmo discreto sulle curve ellittiche.

**Flag SIGHASH.** Una firma Bitcoin non impegna l'intera transazione. Il firmatario sceglie quali parti della transazione la firma copre tramite un flag SIGHASH, codificato come ultimo byte della firma:

- **SIGHASH_ALL (0x01)**: La firma impegna tutti gli input e tutti gli output. È il flag predefinito e più comune. Modificare qualsiasi parte della transazione invalida tutte le firme.
- **SIGHASH_NONE (0x02)**: La firma impegna tutti gli input ma nessun output. Al firmatario non importa dove vadano i fondi. Chiunque può riempire gli output successivamente.
- **SIGHASH_SINGLE (0x03)**: La firma impegna tutti gli input e esattamente un output allo stesso indice dell'input firmato. Altri output possono essere modificati.
- **SIGHASH_ANYONECANPAY (0x80)**: Può essere combinato con qualsiasi flag precedente tramite OR bitwise. La firma impegna esattamente un input (quello firmato) invece di tutti gli input. Ciò permette ad altri di aggiungere o rimuovere input dalla transazione.

**Posizione della firma.** Le firme sono inserite nel campo `scriptSig` di ogni input (transazioni legacy) o nei dati witness (transazioni SegWit). Firmano i dati della transazione che escludono la propria posizione — altrimenti la firma modificherebbe i dati che sta cercando di firmare. Questa dipendenza circolare è risolta sostituendo `scriptSig` con un segnaposto vuoto prima di firmare. In SegWit, i dati witness sono spostati fuori dall'hash della transazione, quindi la firma impegna una serializzazione che esclude il witness stesso (il "commitment" include `scriptCode`, importo e sequence).

**Tabella dei tipi SIGHASH:**

| Flag | Valore | Input firmati | Output firmati |
|------|-------|---------------|----------------|
| ALL | 0x01 | Tutti | Tutti |
| NONE | 0x02 | Tutti | Nessuno |
| SINGLE | 0x03 | Tutti | Uno (indice corrispondente) |
| ALL \| ANYONECANPAY | 0x81 | Uno | Tutti |
| NONE \| ANYONECANPAY | 0x82 | Uno | Nessuno |
| SINGLE \| ANYONECANPAY | 0x83 | Uno | Uno (indice corrispondente) |

## advanced

**Modello di sicurezza.** La nozione di sicurezza standard per le firme digitali è l'Existential Unforgeability under Chosen Message Attack (EUF-CMA). Un attaccante che può richiedere firme su messaggi arbitrari a sua scelta non deve comunque essere in grado di produrre una firma valida su un nuovo messaggio. Sia ECDSA che Schnorr soddisfano EUF-CMA nel modello dell'oracolo randomico e sotto l'assunzione che il problema del logaritmo discreto sulle curve ellittiche sia difficile su secp256k1.

**Codifica della firma.**

- **Firme ECDSA** usano la codifica DER (Distinguished Encoding Rules). Una firma tipica occupa 70-72 byte, strutturata come una sequenza di due interi `r` e `s`, ciascuno di 32 byte, avvolti in intestazioni ASN.1 con tag di tipo e prefissi di lunghezza. La lunghezza variabile deriva dal fatto che DER richiede una codifica big-endian minima senza byte zero iniziali e un byte di segno quando il bit più alto è impostato.
- **Firme Schnorr** (BIP 340) sono fisse a 64 byte: 32 byte per il valore `r` (la coordinata x di un nonce pubblico) e 32 byte per il valore `s` (una prova scalare). La dimensione fissa elimina il vettore di malleabilità che affligge ECDSA.

**Malleabilità delle transazioni.** Le firme ECDSA sono malleabili: un terzo può alterare la codifica DER di una firma valida senza cambiarne la validità. Ad esempio, il valore `s` può essere sostituito con il suo complemento `n - s` (low-s vs high-s), o i byte di padding possono essere regolati secondo le regole DER. Entrambe le codifiche producono la stessa firma matematica ma byte diversi, risultando in un identificatore di transazione (txid) diverso. Prima di SegWit, questo permetteva a un attaccante di invalidare transazioni non confermate trasmettendo una versione mutata con un txid diverso. BIP 66 (codifica DER rigorosa) e BIP 62 (requisito low-s) hanno ridotto la malleabilità, e SegWit l'ha eliminata per gli input SegWit spostando la firma nel witness, che è escluso dal calcolo del txid.

**Dettagli del commitment dell'hash della firma.** L'algoritmo di hash della firma (`SigHash`) nelle transazioni legacy serializza la transazione in un formato specifico che include:

- La versione della transazione (4 byte)
- L'hash degli output precedenti spesi (per tutti gli input, o uno dipendente da SIGHASH)
- L'hash dei numeri di sequence
- Per l'input firmato: l'outpoint completo (txid + vout), lo `scriptCode` (lo script dell'output speso) e l'importo
- L'hash dello script e dei valori degli output
- Il locktime (4 byte)
- Il tipo SIGHASH (4 byte, little-endian)

SegWit ha introdotto un nuovo algoritmo di hash della firma (BIP 143) che risolve diversi difetti di progettazione. Il cambiamento chiave è che l'importo di ogni output speso è impegnato direttamente, prevenendo una classe di attacchi in cui un terzo modifica l'importo dopo che un portafoglio hardware ha firmato. BIP 143 semplifica anche il calcolo dell'hash calcolando l'hash degli output e degli input una sola volta.

**Sviluppi futuri.** Le firme Schnorr abilitano diverse funzionalità avanzate:

- **Verifica batch**: Più firme Schnorr possono essere verificate insieme più velocemente che verificandole singolarmente. Per ECDSA, la verifica batch non è possibile. Questo riduce il tempo di validazione dei blocchi con l'aumentare dell'adozione di Schnorr.
- **Firme adattatore (adaptor signatures)**: Una tecnica crittografica in cui una firma rivela un segreto quando viene pubblicata. Alimenta gli atomic swap, i protocolli della Lightning Network e i Discreet Log Contracts (DLC) senza richiedere percorsi condizionali basati su script.
- **MuSig e MuSig2**: Schemi di multi-firma basati su Schnorr che aggregano più chiavi pubbliche in un'unica chiave e più firme in un'unica firma. Un MuSig 3-of-3 appare sulla blockchain identico a una transazione con un singolo firmatario, migliorando la privacy e riducendo le commissioni.
