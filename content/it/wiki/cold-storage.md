---
id: wiki.cold-storage
slug: cold-storage
language: it
category: privacy-security
title: Cold storage
description: Tenere le chiavi private su un dispositivo che non si collega mai a internet, e come un cold wallet riceve pagamenti e firma le spese tramite un wallet watch-only e una transazione non firmata.
difficulty: base
readTimeMinutes: 5
tags:
  - Cold storage
  - Air-gap
  - Firma offline
  - PSBT
related:
  - wiki.hardware-wallets
  - wiki.seed-backups
  - wiki.psbt
  - wiki.private-keys
sources:
  - title: Cold storage
    url: https://en.bitcoin.it/wiki/Cold_storage
    author: Bitcoin Wiki contributors
  - title: Secure your wallet
    url: https://bitcoin.org/en/secure-your-wallet
    author: Bitcoin.org contributors
  - title: "BIP 174: Partially Signed Bitcoin Transaction Format"
    url: https://github.com/bitcoin/bips/blob/master/bip-0174.mediawiki
    author: Ava Chow
  - title: Developer Guide - Wallets
    url: https://developer.bitcoin.org/devguide/wallets.html
    author: Bitcoin.org contributors
  - title: Partially signed bitcoin transactions (PSBT)
    url: https://bitcoinops.org/en/topics/psbt/
    author: Bitcoin Optech
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

Il cold storage tiene le chiavi private su un dispositivo che non si collega mai a internet. Il dispositivo che custodisce le chiavi è il lato freddo. Il computer o il telefono che mostra i saldi e trasmette le transazioni è il lato caldo. L'idea è che malware o un attaccante in rete non possano leggere le chiavi, perché non raggiungono mai una macchina online. La Bitcoin Wiki descrive il cold storage come un modo per resistere al furto da parte di hacker e malware, e per questo si usa spesso per grandi somme.

Un cold wallet può comunque ricevere bitcoin. Un wallet watch-only su un computer online contiene solo chiavi pubbliche. Genera gli indirizzi di ricezione e tiene traccia dei pagamenti in arrivo, e il dispositivo offline non deve mai essere collegato per questo.

Spendere è la parte più difficile. Il computer online costruisce una transazione non firmata. Quella transazione passa al dispositivo offline tramite chiavetta USB, codice QR o trascrizione manuale. Il dispositivo offline la firma, il risultato firmato torna al computer online, e il computer online la trasmette. Per questo scambio il formato standard è la PSBT.

Il dispositivo offline è sicuro quanto la sua configurazione e quanto attente sono le verifiche. I livelli successivi descrivono i rischi che restano e confrontano il cold storage con un hardware wallet usato ogni giorno.

## medium

La configurazione è il primo rischio. La Bitcoin Wiki suggerisce un portatile o un telefono usato di un produttore affidabile, cancellato, tenuto lontano da internet e caricato solo con un sistema operativo e un software wallet da una chiavetta USB. Cancellare il dispositivo potrebbe non rimuovere minacce di firmware o BIOS, e un sistema operativo live potrebbe non fermare un malware sofisticato. Le chiavi andrebbero generate sul dispositivo offline, e il loro backup scritto su carta o metallo, come descrive la voce sui backup del seed.

Un air gap è una separazione fisica, non una garanzia. La Bitcoin Wiki osserva che i dati possono attraversare un air gap tramite canali laterali come segnali radio, audio, luce, magnetici o termici. Tenere le due macchine separate e far funzionare quella offline a batteria riduce questa esposizione. Anche le chiavette USB sono una superficie di attacco, quindi non dovrebbero trasportare dati avanti e indietro senza cautela.

Anche lo scambio di firma richiede attenzione. Il firmatario offline non dovrebbe fidarsi del computer online per i fatti sul pagamento. Il formato PSBT porta i dati di cui il firmatario ha bisogno, e il BIP 174 chiede che il firmatario verifichi che i dati corrispondano agli output che sta spendendo prima di firmare. La Developer Guide descrive wallet di sola firma che lavorano insieme a un wallet collegato, e un wallet offline è pensato per un dispositivo che non si collega a nessuna rete.

Il controllo finale riguarda l'indirizzo. Un malware sul computer online potrebbe sostituire l'indirizzo di destinazione, quindi la Bitcoin Wiki consiglia di controllare l'intero indirizzo prima di firmare. Il dispositivo di firma può mostrare i dettagli del pagamento sul proprio schermo, ed è il posto giusto per confrontarli con l'indirizzo che intendevi pagare.

Il cold storage è quindi un flusso di lavoro, non solo un dispositivo. Funziona meglio quando configurazione, backup e passi di firma seguono la stessa disciplina. La voce sugli hardware wallet descrive l'alternativa per l'uso quotidiano.

## advanced

Cold storage e hardware wallet risolvono un problema simile in modi diversi. Un hardware wallet è un firmatario che conserva le chiavi su un dispositivo e mostra ciò che gli viene chiesto di firmare. Alcuni hardware wallet sono air-gapped e scambiano dati tramite codice QR o scheda microSD, e questo modello coincide con il flusso offline descritto sopra. La differenza pratica sta nella frequenza d'uso e nella quantità di processo automatizzato. Bitcoin.org definisce gli hardware wallet il miglior equilibrio tra sicurezza e facilità d'uso, il che spiega perché sono diffusi per l'uso quotidiano, mentre un dispositivo conservato in un cassetto si adatta ai risparmi che si muovono di rado.

Il lato watch-only ha un problema di fiducia. Il wallet che segue la chain apprende gli indirizzi che controlla, quindi la sua privacy dipende dal nodo o dal server che usa, come spiega la voce sui software wallet. Se il computer online è compromesso, può mostrare indirizzi falsi o costruire una transazione che paga qualcun altro. Il firmatario offline è l'ultima linea di difesa, quindi il controllo sullo schermo del dispositivo conta. Il BIP 174 è scritto perché il firmatario non abbia bisogno di altre fonti di dati oltre alla PSBT stessa.

Il rischio della filiera vale anche qui. Un dispositivo acquistato usato o da un venditore non ufficiale ha una storia sconosciuta. Il suggerimento della Bitcoin Wiki di un produttore affidabile mostra il compromesso: cancellare un dispositivo è un passo, non una prova. Il firmware aperto con build riproducibili permette di confrontare il codice installato con il sorgente pubblicato. Il firmware chiuso richiede fiducia nel processo del produttore, e per questo il canale di aggiornamento e la verifica degli aggiornamenti contano quanto la configurazione iniziale.

Il cold storage non protegge dagli errori del proprietario, come firmare senza leggere lo schermo o conservare un backup mai verificato. Il multisig si può combinare con il cold storage. Chiavi custodite su più dispositivi offline, in luoghi separati, fanno sì che nessun singolo dispositivo, seed o luogo basti per spendere, e Bitcoin.org lo descrive come un modo per ridurre un singolo punto di guasto.

Il flusso di lavoro ha dei costi. Ogni spesa richiede di spostare dati tra due macchine, e un errore in questo processo può lasciare un pagamento non firmato o una transazione incompleta. Per monete che cambiano spesso di mano, i passi in più possono pesare più del beneficio. Per fondi che si muovono di rado, i passi in più fanno parte della protezione, perché il dispositivo è raramente esposto.
