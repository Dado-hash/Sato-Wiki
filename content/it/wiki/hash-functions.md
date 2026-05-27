---
id: wiki.hash-functions
slug: hash-functions
language: it
category: cryptography
title: Funzioni di Hash
description: I mattoni matematici che Bitcoin usa per comprimere dati, impegnarsi su valori e proteggere le transazioni senza rivelare segreti.
coverImage: media/wiki/hash-functions/hash-function-diagram.svg
difficulty: advanced
readTimeMinutes: 8
tags:
  - Crittografia
  - Funzioni di Hash
  - Sicurezza
  - Fondamentali
related:
  - wiki.sha-256
  - wiki.merkle-trees
  - wiki.digital-signatures
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: "Handbook of Applied Cryptography"
    url: https://cacr.uwaterloo.ca/hac/
    author: Menezes, van Oorschot, Vanstone
  - title: "Mastering Bitcoin - Chapter 4"
    url: https://github.com/bitcoinbook/bitcoinbook/blob/develop/ch04.asciidoc
    author: Andreas M. Antonopoulos
updatedAt: 2026-05-27T00:00:00Z
---

## base

Una funzione di hash e un'operazione matematica che prende una quantità arbitraria di dati e produce un risultato di dimensione fissa, chiamato digest o hash. Non importa se si fa l'hash di un byte o di un gigabyte: l'output ha sempre la stessa lunghezza. Per SHA-256, la funzione di hash che Bitcoin usa ovunque, l'output e sempre di 256 bit, ovvero 32 byte.

![Schema della funzione di hash](media/wiki/hash-functions/hash-function-diagram.svg "Una funzione di hash mappa qualsiasi quantità di dati a un'impronta digitale di dimensione fissa.")

Le funzioni di hash hanno quattro proprietà che le rendono utili in Bitcoin. Prima di tutto sono deterministiche: lo stesso input produce sempre lo stesso output. Secondo, sono unidirezionali: dato un hash, non esiste una scorciatoia per trovare l'input originale. Terzo, hanno l'effetto valanga: un singolo bit cambiato nell'input produce un output completamente diverso che non sembra correlato all'originale. Quarto, producono un output di dimensione fissa indipendentemente dalla dimensione dell'input.

Bitcoin usa le funzioni di hash in ogni parte del protocollo. Il mining le usa come cuore della Proof of Work: i miner cercano un hash dell'header del blocco inferiore a un target, il che richiede trilioni di tentativi al secondo su tutta la rete. Ogni transazione ottiene un identificativo che e l'hash dei suoi dati serializzati. I blocchi si concatenano includendo l'hash del blocco precedente nell'header di ogni nuovo blocco. Gli indirizzi dei portafogli sono derivati da hash di chiavi pubbliche.

Un buon modo per pensare a un hash e come a un'impronta digitale. Un'impronta identifica in modo univoco una persona senza rivelarne l'identità. Un hash identifica in modo univoco dei dati senza rivelare i dati stessi. Se si fa l'hash di una transazione e si pubblica l'hash, chiunque veda in seguito la transazione può confermare che corrisponde, ma nessuno può ricostruire la transazione dall'hash da solo.

## medium

La sicurezza di una funzione di hash si basa su tre proprietà che i crittografi formalizzano come modelli di attacco.

**Resistenza alla preimmagine** significa che, dato un hash, e impraticabile trovare un qualsiasi input che lo produca. Bitcoin si affida a questa proprietà per la sicurezza degli indirizzi. Un indirizzo Bitcoin e derivato dall'hash di una chiave pubblica. Un attaccante che vede un indirizzo non può invertire l'hash per recuperare la chiave pubblica (prima che l'output venga speso) e certamente non può recuperare la chiave privata. La resistenza alla preimmagine e ciò che mantiene al sicuro i bitcoin bloccati, anche se lo script di blocco rivela l'hash.

**Resistenza alla seconda preimmagine** significa che, dato un input e il suo hash, e impraticabile trovare un input diverso con lo stesso hash. Bitcoin si affida a questa proprietà per gli ID delle transazioni. Una transazione firmata e trasmessa ha un txid che si impegna sulla sua serializzazione esatta. Se un attaccante potesse trovare una seconda preimmagine, potrebbe creare una transazione diversa che produce lo stesso txid, rompendo la catena esplicita input-output. La stessa proprietà protegge il concatenamento dei blocchi: un blocco si impegna sul suo padre memorizzando l'hash del blocco precedente.

**Resistenza alle collisioni** significa che e impraticabile trovare due input distinti qualsiasi che producano lo stesso hash. Bitcoin si affida a questa proprietà per gli alberi di Merkle, che impegnano l'intera lista di transazioni di un blocco in una singola Merkle root di 32 byte. Se le collisioni fossero fattibili, un attaccante potrebbe costruire un blocco con due insiemi di transazioni diversi che condividono la stessa Merkle root, rompendo l'impegno di consenso.

Bitcoin applica SHA-256 due volte per la maggior parte delle operazioni di hash, una costruzione chiamata doppio SHA-256 o SHA-256d. L'header del blocco viene hashato con doppio SHA-256 durante il mining. Anche l'hashing delle transazioni per il txid legacy usa doppio SHA-256. La ragione e in parte difensiva: il doppio hash previene gli attacchi di length-extension che colpiscono SHA-256 semplice, e fornisce un margine extra di sicurezza contro futuri avanzamenti crittoanalitici. Il costo e trascurabile perché SHA-256 e estremamente veloce sia in hardware che in software.

Gli hash in Bitcoin sono sempre interpretati come interi little-endian per i confronti. Il controllo di Proof of Work confronta l'hash dell'header del blocco con il target come intero. Questo significa che gli stessi byte dell'hash possono essere scritti come stringa esadecimale, come `0000000000000000000a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e`, o confrontati numericamente.

## advanced

La scelta di SHA-256 per Bitcoin non e stata casuale. Nel 2008, SHA-256 era la funzione di hash crittografica più ampiamente analizzata e affidabile disponibile. Era stata standardizzata dal NIST nel 2001 e aveva resistito ad anni di scrutinio crittoanalitico. SHA-1 aveva debolezze note e gli attacchi di collisione sono diventati pratici entro il 2017. MD5 era completamente rotto. Whirlpool e altre alternative mancavano dello stesso livello di analisi e adozione hardware.

SHA-256 appartiene alla famiglia SHA-2, progettata dalla NSA. Elabora i messaggi in blocchi di 512 bit usando una funzione di compressione che itera 64 round. Lo stato interno e di 256 bit, organizzato in otto parole da 32 bit. Ogni round applica operazioni bitwise, addizione modulare e funzioni logiche che mescolano a fondo l'input. Il design segue la costruzione Merkle-Damgard, dove il messaggio viene paddingato fino a un multiplo della dimensione del blocco e ogni blocco aggiorna lo stato interno.

La costruzione Merkle-Damgard rende SHA-256 vulnerabile agli attacchi di length-extension. Dato `H(M)`, un attaccante può calcolare `H(M || padding || extra)` senza conoscere `M`. Questo e il motivo per cui Bitcoin non usa SHA-256 grezzo per impegni in cui la length-extension sarebbe rilevante. L'esempio più notevole e l'impegno witness della coinbase in SegWit, che usa uno schema di hash con tag simile a HMAC invece del doppio SHA-256 grezzo. Gli hash con tag prefissano i dati con un tag specifico del dominio prima dell'hashing, separando di fatto il dominio dell'hash da tutti gli altri.

Il margine di sicurezza di SHA-256 e sostanziale. L'output e di 256 bit, il che significa che la resistenza alle collisioni offre 128 bit di sicurezza a causa del limite del compleanno. La resistenza alla preimmagine offre i 256 bit completi. Al 2026, nessun attacco pratico riduce questi margini per SHA-256. I migliori attacchi riguardano varianti con round ridotti e non hanno impatto sulla versione completa a 64 round. La costruzione a doppio SHA-256 di Bitcoin aumenta ulteriormente la sicurezza effettiva della preimmagine perché un attaccante deve invertire due round di hash invece di uno.

Il modello dell'oracolo casuale fornisce un quadro teorico per ragionare sulle funzioni di hash. In questo modello, la funzione di hash viene trattata come una funzione veramente casuale che restituisce un output uniformemente casuale per ogni nuovo input. Nessuna funzione di hash reale e un oracolo casuale, ma i protocolli progettati in questo modello spesso resistono ad attacchi che sfruttano debolezze strutturali. L'uso del doppio hash e della separazione dei domini tramite hash con tag in Bitcoin avvicina il protocollo all'ideale, compensando il divario tra SHA-256 e un oracolo casuale.

L'accelerazione hardware ha plasmato il panorama delle funzioni di hash in Bitcoin. I circuiti integrati specifici per applicazioni (ASIC) per SHA-256 superano l'hardware generico di ordini di grandezza. Questa specializzazione era prevedibile perché SHA-256 e semplice, simmetrico e parallelizzabile. Una funzione di hash con indirizzamento più complesso, come Scrypt usata in Litecoin, resiste all'ottimizzazione ASIC in modo diverso, ma scambia velocità di verifica. La scelta di SHA-256 da parte di Bitcoin favorisce la verifica veloce: qualsiasi nodo può controllare un header di blocco con due compressioni SHA-256, impiegando microsecondi, mentre il mining richiede trilioni di hash per blocco.

Gli hash sono anche alla base delle operazioni di impegno in Bitcoin Script. L'opcode `OP_HASH160` calcola RIPEMD-160 dopo SHA-256, producendo hash da 160 bit usati negli indirizzi P2PKH e P2SH. `OP_SHA256` calcola SHA-256 singolo per impegni generici negli script. Questi opcode permettono agli utenti di costruire condizioni di spesa personalizzate che si impegnano su segreti senza rivelarli, abilitando canali di pagamento, atomic swap e altri protocolli di secondo livello senza modifiche al livello base.
