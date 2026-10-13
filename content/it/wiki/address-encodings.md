---
id: wiki.address-encodings
slug: address-encodings
language: it
category: cryptography
title: Base58Check, bech32 e bech32m
description: Le codifiche con checksum alla base degli indirizzi Bitcoin, come ciascuna individua gli errori di digitazione e quale tipo di indirizzo usa quale codifica.
coverImage: media/wiki/address-encodings/address-encodings-hero.svg
difficulty: advanced
readTimeMinutes: 6
tags:
  - Base58Check
  - Bech32
  - Bech32m
  - Indirizzi
  - Checksum
related:
  - wiki.bitcoin-addresses
  - wiki.segregated-witness
  - wiki.taproot
  - wiki.hash-functions
  - wiki.public-keys
sources:
  - title: "BIP 13: Address Format for pay-to-script-hash"
    url: https://github.com/bitcoin/bips/blob/master/bip-0013.mediawiki
  - title: "BIP 173: Base32 address format for native v0-16 witness outputs"
    url: https://github.com/bitcoin/bips/blob/master/bip-0173.mediawiki
  - title: "BIP 350: Bech32m format for v1+ witness addresses"
    url: https://github.com/bitcoin/bips/blob/master/bip-0350.mediawiki
  - title: Base58Check encoding
    url: https://en.bitcoin.it/wiki/Base58Check_encoding
    author: Bitcoin Wiki contributors
  - title: Bech32(m)
    url: https://bitcoinops.org/en/topics/bech32/
    author: Bitcoin Optech
  - title: Bitcoin Core chain parameters (src/kernel/chainparams.cpp)
    url: https://github.com/bitcoin/bitcoin/blob/master/src/kernel/chainparams.cpp
    author: Bitcoin Core contributors
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

Un indirizzo è una breve stringa che codifica un hash, un prefisso di tipo o di rete e un checksum. Il checksum serve a far notare un carattere sbagliato prima che i soldi vengano inviati a un destinatario sbagliato. Bitcoin usa tre codifiche: Base58Check per gli indirizzi legacy, bech32 per SegWit versione 0 e bech32m per Taproot e per le versioni witness successive.

Base58Check usa 58 caratteri e lascia fuori 0, O, I e l, che in molti font si assomigliano. Un byte di versione precede il payload, e un checksum di quattro byte, ricavato da un hash SHA-256 doppio, lo segue. Gli indirizzi pay-to-public-key-hash della rete principale iniziano con 1, e quelli pay-to-script-hash con 3.

Bech32 usa 32 lettere minuscole e cifre, e non mescola le maiuscole con le minuscole. Una stringa ha tre parti: una human-readable part come bc, un separatore che è sempre la cifra 1, e una data part i cui ultimi sei caratteri sono il checksum. Essendo alfanumerico, bech32 si adatta meglio ai QR code.

Il checksum di bech32 rileva qualsiasi errore che coinvolga al massimo quattro caratteri. Bech32m usa la stessa struttura con una costante di checksum diversa, ed è richiesto per la versione witness 1 e successive. Una stringa valida in una codifica non è valida nell'altra.

## medium

Base58Check inizia con un byte di versione, per esempio 0x00 per il pay-to-public-key-hash della rete principale. Al payload si aggiunge un checksum formato dai primi quattro byte di un hash SHA-256 doppio della versione e del payload, e il risultato viene scritto in base 58. Ogni byte zero iniziale diventa un 1 iniziale, quindi gli zeri iniziali sopravvivono alla conversione. Il BIP 13 ha specificato in questo formato gli indirizzi pay-to-script-hash, che usano la versione 0x05 e iniziano con 3.

Bech32 ha una human-readable part da uno a 83 caratteri, un separatore 1 e una data part di almeno sei caratteri. L'intera stringa non supera i 90 caratteri. L'alfabeto è qpzry9x8gf2tvdw0s3jn54khce6mua7l, che ha 32 simboli, e la data part esclude 1, b, i e o. Il checksum è di sei caratteri ed è calcolato sulla human-readable part espansa e sui valori dei dati.

Anche il caso ha regole. Chi codifica deve produrre una stringa tutta minuscola, e chi decodifica deve rifiutare le stringhe che mescolano maiuscole e minuscole. Le maiuscole sono ammesse per la presentazione o per i QR code, ma si ottengono convertendo la stringa minuscola già completa, non mescolando i caratteri.

Bech32m sostituisce la costante del checksum con 0x2bc830a3 al posto di 1, e il resto della codifica resta invariato. La versione 0 usa bech32 e le versioni da 1 a 16 usano bech32m. Gli indirizzi di versione 0 mantengono bech32 per compatibilità con gli output P2WPKH e P2WSH esistenti. Un decoder accetta una stringa solo se il checksum corrisponde alla costante della sua versione witness.

Quale codifica usa un indirizzo dipende dal suo tipo. Gli indirizzi pay-to-public-key-hash e pay-to-script-hash, inclusi gli indirizzi SegWit annidati che incapsulano un programma SegWit in un output P2SH, usano Base58Check. Gli indirizzi nativi P2WPKH e P2WSH usano bech32. Gli indirizzi pay-to-taproot usano bech32m, perché sono di versione witness 1. La codifica incapsula solo il payload; le regole di spesa derivano dallo script dell'output.

## advanced

Il checksum di bech32 ha una garanzia dichiarata. Il BIP 173 dice che il codice BCH rileva qualsiasi errore che coinvolga al massimo quattro caratteri, e che può anche correggere alcuni errori. La correzione trasforma alcune stringhe non valide in stringhe valide, quindi indebolisce il rilevamento quando gli errori sono molti. L'obiettivo di progetto era rilevare il piccolo numero di errori che la digitazione e la lettura producono.

Bech32 ha una debolezza di inserzione, che il BIP 350 documenta. Quando l'ultimo carattere della stringa è p, inserire o cancellare un numero qualsiasi di caratteri q immediatamente prima di esso non invalida il checksum. Il BIP 350 afferma che questo non riguarda gli indirizzi di versione 0 già esistenti, e introduce bech32m per mitigare questa debolezza e i problemi collegati per la versione 1 e successive.

Il BIP 350 spiega anche perché la versione 0 non accetta entrambe le codifiche. Accettarle entrambe ridurrebbe la forza effettiva del checksum a un equivalente di circa 29 bit, perché una stringa potrebbe essere letta con una delle due costanti. Un decoder quindi prova entrambe le costanti e poi applica la regola della versione, così una stringa non viene mai accettata con la codifica sbagliata.

Gli indirizzi witness hanno altre regole, che si applicano dopo il superamento del checksum. La versione witness deve andare da 0 a 16, e il programma deve avere tra 2 e 40 byte. I programmi di versione 0 devono essere esattamente di 20 o 32 byte, il che distingue P2WPKH da P2WSH. Questi controlli impediscono che un checksum valido incapsuli un programma non ammesso per la sua versione.

Base58Check è più debole rispetto agli errori di trascrizione. Secondo il BIP 173, il suo checksum basato su SHA-256 doppio non offre alcuna garanzia di rilevamento degli errori. Il suo alfabeto evita alcuni caratteri confondibili, ma è sensibile alle maiuscole e non può usare la modalità alfanumerica dei QR code.

I wallet che accettano input dall'utente dovrebbero verificare il checksum e le regole witness prima di considerare corretto un indirizzo. Dovrebbero rifiutare le maiuscole e minuscole mescolate invece di normalizzarle in silenzio.

La codifica non cambia ciò che un indirizzo controlla. Il payload resta un hash, una chiave o un programma witness. La codifica cambia solo il modo in cui il payload viene scritto e verificato, quindi le stesse regole di spesa valgono qualunque codifica usi l'output. Un wallet può accettare formati vecchi e nuovi fianco a fianco, mentre la chain valida ogni output tramite il suo script.
