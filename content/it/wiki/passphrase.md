---
id: wiki.passphrase
slug: passphrase
language: it
category: privacy-security
title: Passphrase (BIP 39)
description: La passphrase opzionale del BIP 39, che entra nella derivazione del seed in modo che ogni passphrase dia un wallet diverso e valido, con ciò che protegge, ciò che non protegge e le insidie.
difficulty: advanced
readTimeMinutes: 5
tags:
  - Passphrase
  - BIP 39
  - Seed
  - Backup
related:
  - wiki.wallet-seeds
  - wiki.seed-backups
  - wiki.hardware-wallets
  - wiki.physical-attacks
sources:
  - title: "BIP 39: Mnemonic code for generating deterministic keys"
    url: https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki
  - title: Seed phrase
    url: https://en.bitcoin.it/wiki/Seed_phrase
    author: Bitcoin Wiki contributors
  - title: Securing your wallet
    url: https://en.bitcoin.it/wiki/Securing_your_wallet
    author: Bitcoin Wiki contributors
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

La passphrase BIP 39 è un testo facoltativo che aggiungi alle parole del seed. Viene spesso chiamata 25esima parola, anche se non è una parola della lista. Può essere qualsiasi testo scelto dall'utente. In pratica fa parte del segreto che serve per ripristinare il wallet. Quando si usa una passphrase, il wallet deriva le proprie chiavi sia dal seed sia dalla passphrase. Le stesse parole del seed, senza passphrase o con una passphrase diversa, portano a chiavi diverse, e il wallet che ne deriva può risultare vuoto.

La protezione è semplice da descrivere. Chi trova un backup del seed non ottiene automaticamente i fondi, perché serve anche la passphrase. La Bitcoin Wiki dà lo stesso avvertimento: un seed che non è protetto anche da una passphrase segreta permette a chiunque lo trovi di prendere i bitcoin.

La passphrase ha un costo. Va ricordata o salvata separatamente, e va registrata esattamente. Se viene persa, i fondi dietro di essa non si possono recuperare, neppure con il seed. Il wallet non segnala quando la passphrase è sbagliata. I livelli successivi spiegano come funziona la derivazione e perché questo conta.

## medium

La derivazione è definita nel BIP 39. Le parole del mnemonic sono la password di una PBKDF2 con HMAC-SHA512, e il salt è la stringa "mnemonic" seguita dalla passphrase. La funzione esegue 2048 iterazioni e produce 512 bit. La passphrase cambia quindi l'intero seed, e con esso ogni chiave che il wallet deriva.

La passphrase non ha un checksum. Qualsiasi passphrase produce un seed valido, quindi una passphrase sbagliata dà un wallet valido che risulta vuoto, e il software non può dire che la passphrase è errata. La specifica chiama questo negazione plausibile. Significa che una passphrase può nascondere una disponibilità, e anche che un errore di digitazione sembra esattamente un wallet vuoto.

La passphrase protegge il seed da solo. Un backup trovato o rubato dà a chi lo trova le parole, ma non le chiavi dietro la passphrase. Rende anche più difficile indovinare, perché ogni tentativo richiede una derivazione completa e il controllo del risultato. Non protegge dalla perdita della passphrase, da un malware che la vede mentre viene digitata, né da chi costringe il proprietario a rivelarla. Inoltre non può sostituire il seed. Senza le parole, la sola passphrase non recupera nulla.

La passphrase non è un PIN del dispositivo. Il PIN è un codice di accesso che il dispositivo verifica. La passphrase è un ingresso della derivazione delle chiavi. Gli eventuali limiti sui tentativi valgono solo per i tentativi fatti tramite il dispositivo, non per chi possiede il seed e prova le passphrase sul proprio computer. La passphrase è anche separata dalla password che cifra il file del wallet su disco. La Bitcoin Wiki osserva che alcuni wallet la chiamano per questo extension word.

Tenere al sicuro la passphrase richiede un piano a parte. Scriverla accanto al seed vanifica il motivo per cui la si usa. Conservarla in un luogo separato tiene distinti i due segreti, ma per un ripristino vanno entrambi custoditi e ritrovati insieme.

## advanced

La derivazione usa la normalizzazione NFKD. Il BIP 39 richiede che il mnemonic e la passphrase siano convertiti in UTF-8 nella forma NFKD prima dell'uso. Ne deriva che stringhe che sembrano uguali ma sono codificate in modo diverso producono lo stesso seed. Un carattere accentato scritto come un solo carattere o come lettera base seguita da un segno combinante è un esempio. Alcuni caratteri vengono anche riscritti dalla normalizzazione, quindi una passphrase digitata con forme di compatibilità può coincidere con una versione ASCII dello stesso testo. La normalizzazione non cambia le maiuscole, quindi "Abc" e "abc" sono passphrase diverse. Anche gli spazi contano come caratteri.

La normalizzazione è un'insidia sia per chi sviluppa sia per chi usa il wallet. Un wallet che non applica la NFKD come richiede la specifica può derivare un seed diverso dallo stesso testo, e un ripristino su quel wallet mostra un saldo vuoto senza avvisi. Anche un utente che cambia layout della tastiera o copia la passphrase da un documento può produrre caratteri diversi dall'originale. In entrambi i casi il ripristino fallisce in silenzio, quindi conviene verificarlo con lo stesso software che si userà in seguito.

La robustezza conta per chi può verificare le ipotesi. Chi possiede le parole del seed può derivare le chiavi per qualsiasi passphrase candidata sul proprio hardware, senza il dispositivo originale, e controllare se gli indirizzi derivati contengono fondi. Le 2048 iterazioni di PBKDF2 sono un costo fisso stabilito dalla specifica e aggiungono solo una spesa modesta a ogni tentativo. Il punto debole è quindi una passphrase corta o comune. Il consiglio della Bitcoin Wiki presuppone una passphrase segreta e difficile da indovinare.

La memoria è un limite pratico. La Bitcoin Wiki avverte di non sopravvalutare la propria memoria per una passphrase, soprattutto se viene usata di rado. Una passphrase scritta va conservata altrove rispetto al seed e verificata con un ripristino di prova. Una passphrase digitata su un dispositivo è anche esposta al software che legge quel dispositivo, quindi il luogo in cui viene inserita fa parte del modello di minaccia.

La passphrase non aggiunge un checksum al seed. Il checksum del BIP 39 copre solo le parole, quindi una parola digitata male può essere rilevata, mentre una passphrase digitata male no. Un ripristino che usa una passphrase va quindi verificato confrontando gli indirizzi con quelli noti in anticipo, prima di qualsiasi trasferimento importante. La passphrase è uno strumento efficace solo quando chi la usa conosce questi limiti.
