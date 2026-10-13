---
id: wiki.hardware-wallets
slug: hardware-wallets
language: it
category: hardware
subcategory: hardware-wallets
title: Hardware wallet
description: Dispositivi di firma che tengono le chiavi private lontane dal computer, cosa proteggono e cosa lasciano all'utente.
difficulty: base
readTimeMinutes: 5
tags:
  - Hardware Wallet
  - Firma
  - Sicurezza
  - PSBT
related:
  - wiki.private-keys
  - wiki.wallet-seeds
  - wiki.software-wallets
  - wiki.multisig
  - wiki.digital-signatures
sources:
  - title: "BIP 174 - Partially Signed Bitcoin Transaction Format"
    url: https://github.com/bitcoin/bips/blob/master/bip-0174.mediawiki
  - title: Exfiltration-resistant signing
    url: https://bitcoinops.org/en/topics/exfiltration-resistant-signing/
    author: Bitcoin Optech contributors
  - title: Jade firmware README
    url: https://github.com/Blockstream/Jade/blob/master/README.md
    author: Blockstream
  - title: Coldcard firmware README
    url: https://github.com/Coldcard/firmware/blob/master/README.md
    author: Coinkite
  - title: "Mastering Bitcoin - Capitolo 5, Wallet"
    url: https://github.com/bitcoinbook/bitcoinbook/blob/develop/ch05_wallets.adoc
    author: Andreas M. Antonopoulos
  - title: Bitcoin.org - Proteggi il tuo wallet
    url: https://bitcoin.org/en/secure-your-wallet
    author: Bitcoin.org contributors
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

Un hardware wallet è un piccolo dispositivo che custodisce le chiavi private di un wallet Bitcoin e firma le transazioni all'interno del proprio hardware. Il computer o il telefono che usi mostra i saldi e prepara i pagamenti, ma le chiavi restano sul dispositivo. Quando invii bitcoin, il dispositivo controlla ciò che gli viene chiesto di firmare e restituisce una firma, quindi le chiavi non devono mai essere copiate sul computer.

Lo scopo principale è proteggere le chiavi dal computer. Un malware su un laptop non può leggere una chiave che non è mai stata memorizzata lì, e non può falsificare facilmente una firma. Restano alcuni rischi. Il dispositivo può essere rubato, un'unità manomessa può arrivare da un venditore, e un utente può approvare un pagamento senza controllarlo. Un hardware wallet riduce una classe di rischi. Non rende sicuro il resto della configurazione.

Prima di fidarti di un dispositivo, leggi l'indirizzo di ricezione sul suo schermo e confrontalo con quello che intendevi pagare. Assicurati anche che il backup del seed permetta di recuperare i fondi se il dispositivo si perde o si rompe. I livelli successivi spiegano come cambiano i dispositivi e quali sono i loro limiti.

## medium

Gli hardware wallet si differenziano anzitutto per il chip che custodisce le chiavi. Alcuni dispositivi usano un secure element dedicato, un chip progettato per conservare segreti e resistere all'estrazione. Altri eseguono il wallet su un microcontrollore general-purpose e proteggono le chiavi con il design del software e della memoria. Un secure element può rendere più difficili alcuni attacchi fisici, ma di solito è un hardware chiuso che l'utente non può ispezionare. Un progetto basato su microcontrollore è più facile da esaminare, però la sua protezione dipende di più dal codice che vi gira.

Il firmware è la seconda scelta di progetto. Il firmware open source può essere letto da chiunque e, quando la build è riproducibile, l'utente può ricompilare il sorgente pubblicato e confrontare il risultato con il codice installato. Il firmware chiuso chiede di fidarsi del processo del produttore. Pubblicare il sorgente non dimostra che il binario installato corrisponda ad esso, ed è per questo che contano le build riproducibili e i controlli delle firme.

La connessione con il computer è la terza scelta. Un dispositivo collegato via USB o Bluetooth è comodo, ma il collegamento trasporta dati che l'host può vedere. I dispositivi air-gapped evitano un collegamento attivo. La transazione non firmata arriva al dispositivo come QR code o da una scheda microSD, e il risultato firmato torna indietro nello stesso modo. Il formato Partially Signed Bitcoin Transaction, definito in BIP 174, permette a wallet di produttori diversi di passare una transazione non firmata a un firmatario e riceverla di nuovo parzialmente firmata.

Qualunque sia la connessione, controlla l'indirizzo di ricezione e l'importo sullo schermo del dispositivo prima di approvare. Se il computer ha cambiato l'indirizzo, lo schermo mostra ciò che il dispositivo pagherà davvero. Alcuni dispositivi si affidano anche a un'app di supporto sul computer o sul telefono, e quell'app è un altro software da tenere aggiornato e da verificare. Controllare la firma di un aggiornamento del firmware prima di installarlo è un'abitudine semplice che chiude una lacuna comune.

## advanced

Gli hardware wallet sono firmatari, non full node. Un dispositivo che custodisce le chiavi può dimostrare di aver firmato qualcosa, ma non può dirti se la chain è valida. L'host, o un nodo che scegli tu, fornisce la transazione e i dati necessari per costruirla. Tenere separati il firmatario e la vista della chain fa parte del modello di sicurezza, e un host compromesso può comunque mostrare un quadro fuorviante dei pagamenti.

Una minaccia che alcuni dispositivi cercano di contrastare è l'exfiltration, in cui un software malevolo sull'host ricava la chiave attraverso la firma stessa, per esempio tramite un nonce sbilanciato. Bitcoin Optech segue questo tema e rimanda a tecniche anti-exfiltration usate in alcuni dispositivi, insieme a lavori su protocolli le cui firme possono essere verificate. Queste protezioni sono un'area di ricerca attiva e non sostituiscono una conservazione accurata delle chiavi.

Gli attacchi alla supply chain sono un rischio separato. Un dispositivo acquistato da un rivenditore non ufficiale, o lasciato incustodito, può essere sostituito o modificato prima di arrivare al proprietario. Il firmware open source con build riproducibili permette un controllo tecnico che il codice installato corrisponda al sorgente pubblicato, e il README del firmware Coldcard descrive la ricompilazione dal sorgente proprio per questo motivo. Il firmware chiuso richiede fiducia nel processo di firma del produttore. I produttori pubblicano anche avvisi di sicurezza quando vengono trovati bug nel firmware. Il repository Coldcard documenta un bug di questo tipo che ha riguardato l'entropia in alcune versioni, quindi gli utenti dovrebbero seguire gli avvisi e i canali di aggiornamento del produttore.

Gli attacchi fisici, come sondare un chip o forzare un involucro, dipendono dal progetto hardware. I secure element dedicati puntano a renderli più difficili, ma nessun dispositivo è immune con tempo e risorse sufficienti. Un utente costretto a rivelare un segreto o ad approvare un pagamento non può essere protetto dal solo dispositivo.

La passphrase BIP 39 aggiunge un secondo segreto al seed. Un seed rubato senza la passphrase non dà accesso ai fondi protetti da quella passphrase. Una passphrase errata in fase di ripristino produce un wallet valido ma vuoto, e il dispositivo non avvisa l'utente, perché non può verificarne la correttezza. Perdere la passphrase rende i fondi irrecuperabili, e scriverla accanto al seed ne annulla lo scopo.

Infine, l'errore umano resta una causa frequente di perdite: approvare una transazione senza leggerla, acquistare da una fonte non ufficiale o ignorare un avviso del firmware. Un buon progetto riduce la superficie di attacco, ma è sempre l'utente a decidere che cosa firmare.
