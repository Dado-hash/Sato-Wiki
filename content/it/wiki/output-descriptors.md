---
id: wiki.output-descriptors
slug: output-descriptors
language: it
category: protocol
title: Output descriptor
description: Un linguaggio testuale compatto che indica con precisione quali script di output usa un wallet, con le chiavi, i percorsi di derivazione e il checksum necessari per ricostruirli.
difficulty: advanced
readTimeMinutes: 5
tags:
  - Descriptor
  - Wallet
  - Backup
  - Miniscript
related:
  - wiki.hd-wallets
  - wiki.wallet-seeds
  - wiki.multisig
  - wiki.bitcoin-addresses
  - wiki.taproot
sources:
  - title: "BIP 380: Output Script Descriptors General Operations"
    url: https://github.com/bitcoin/bips/blob/master/bip-0380.mediawiki
    author: Pieter Wuille
  - title: "BIP 383: Multisig Output Script Descriptors"
    url: https://github.com/bitcoin/bips/blob/master/bip-0383.mediawiki
    author: Pieter Wuille
  - title: "BIP 386: tr() Output Script Descriptors"
    url: https://github.com/bitcoin/bips/blob/master/bip-0386.mediawiki
    author: Pieter Wuille
  - title: Support for Output Descriptors in Bitcoin Core
    url: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md
    author: Bitcoin Core contributors
  - title: Output script descriptors
    url: https://bitcoinops.org/en/topics/output-script-descriptors/
    author: Bitcoin Optech
  - title: "BIP 379: Miniscript"
    url: https://github.com/bitcoin/bips/blob/master/bip-0379.md
    author: Pieter Wuille, Andrew Poelstra, Sanket Kanjalkar, Antoine Poinsot, Ava Chow
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

Un output descriptor è una stringa di testo breve che descrive un insieme di script di output che un wallet può usare. Indica il tipo di script, le chiavi pubbliche e la provenienza di quelle chiavi. Per esempio, un descriptor wpkh() con una sola chiave descrive un output segwit nativo a chiave singola, e dice al software esattamente come trasformare quella chiave in uno script.

I descriptor contano per i backup. Gli indirizzi di un wallet derivano dalle sue chiavi e da un modello di script. Un backup che contiene solo chiavi private costringe il programma di ripristino a indovinare quali tipi di script e percorsi di derivazione il wallet usasse. Il BIP 380 osserva che questi backup sono insufficienti, soprattutto da quando il segwit ha introdotto nuovi tipi di output, e che causano incompatibilità tra wallet.

Un descriptor registra il modello insieme alle chiavi, quindi un wallet ripristinato o un wallet watch-only può produrre gli stessi indirizzi. Molti descriptor terminano con un cancelletto e un checksum di 8 caratteri, che rileva gli errori di battitura. Un descriptor che contiene chiavi private è sensibile quanto le chiavi stesse, mentre la versione con sole chiavi pubbliche è quella che serve a un wallet watch-only.

## medium

I descriptor sono costruiti con funzioni di script. Il nome della funzione stabilisce il tipo di output. pkh(KEY) descrive un output P2PKH, e wpkh(KEY) descrive un output P2WPKH. Racchiudere una funzione segwit in sh(), come in sh(wpkh(KEY)), descrive un output P2SH-P2WPKH annidato. Un descriptor multisig come wsh(multi(2,KEY1,KEY2,KEY3)) descrive un output P2WSH 2-di-3, con le chiavi nell'ordine indicato. Un descriptor tr(KEY) descrive un output Taproot spendibile tramite key path, mentre tr(KEY,TREE) aggiunge un albero di script path.

Ogni espressione di chiave può includere, tra parentesi quadre, informazioni sulla provenienza. Inizia con l'impronta digitale della chiave master, di 8 caratteri esadecimali, seguita dai passaggi di derivazione, per esempio [d34db33f/84h/0h/0h]. I passaggi hardened si indicano con h o con un apostrofo. Questo dice a un dispositivo di firma da quale ramo del proprio albero di chiavi deriva la chiave, così il dispositivo riconosce le chiavi che controlla senza avere l'intero wallet.

Il checksum segue il cancelletto finale. Il BIP 380 lo definisce su un insieme di caratteri ordinato in modo che il checksum individui più tipi di errore. I parser possono accettare un descriptor senza checksum, ma le applicazioni possono scegliere di rifiutarlo. Il checksum protegge dagli errori di copia, ma non protegge il significato del descriptor da modifiche deliberate, perché chiunque può calcolarne uno nuovo.

Bitcoin Core usa internamente i descriptor. La sua documentazione elenca le funzioni supportate, tra cui wpkh e sh(wpkh) al livello superiore, multi e sortedmulti per il multisig, e tr per Taproot. Le differenze su dove ogni funzione può comparire, per esempio il fatto che multi non è ammesso dentro tr, fanno parte del linguaggio e sono verificate dal parser.

Un descriptor è quindi una ricetta completa. Risponde alle tre domande di cui un wallet ha bisogno: quale script costruire, quali chiavi inserirvi e da quale percorso di derivazione proviene ciascuna chiave.

## advanced

Il BIP 380 definisce la sintassi generale, le espressioni di chiave e il checksum. I BIP successivi definiscono le singole funzioni. Il BIP 381 copre pk, pkh e sh. Il BIP 382 copre wpkh e wsh. Il BIP 383 copre multi e sortedmulti, dove sortedmulti ordina le chiavi in ordine lessicografico nello script risultante. Il BIP 384 definisce combo, che copre i tipi di output applicabili a una chiave, e il BIP 385 definisce raw e addr. Il BIP 386 definisce tr. Il multisig Taproot usa multi_a e sortedmulti_a dentro tr, specificati nel BIP 387.

La frase seed non è un backup completo per ogni wallet. Un seed ripristina le chiavi, ma il wallet deve anche sapere quali script di output costruire con esse e quali percorsi di derivazione usare. Per un wallet a chiave singola con percorsi standard, il software di ripristino può spesso dedurlo. Nel multisig, il seed di un solo cofirmatario fornisce solo le sue chiavi. Il wallet che ripristina ha bisogno anche delle chiavi pubbliche estese degli altri cofirmatari, della soglia e dell'ordine delle chiavi, che il descriptor registra. Percorsi di derivazione non standard e tipi di script misti seguono la stessa regola: senza il descriptor, il wallet che ripristina può generare indirizzi sbagliati.

Miniscript descrive un sottoinsieme limitato di script Bitcoin in una forma strutturata che il software può analizzare. La bozza BIP 379 la specifica. Bitcoin Optech spiega che miniscript permette al software di determinare i dati di witness necessari per spendere uno script, così un wallet non ha bisogno di nuovo codice per ogni modello di script. Bitcoin Core usa espressioni miniscript dentro i descriptor wsh e tr. Le miniscript possono anche essere scritte in un linguaggio di policy, e le policy possono essere composte a partire da parti più piccole e valide.

I descriptor funzionano anche con le PSBT. Poiché un descriptor indica chiavi e script, un wallet può stabilire quali chiavi di uno script multisig controlla. Il descriptor descrive ciò che il wallet detiene, mentre la PSBT descrive ciò che una particolare transazione fa.

I descriptor sono un formato di backup e di interoperabilità, non un formato per le chiavi. Contengono chiavi pubbliche e percorsi di derivazione, quindi un backup può rivelare la struttura di un wallet a chiunque lo legga, anche se non contiene chiavi private. Tratta i backup dei descriptor come informazioni sensibili, e prova il ripristino su un secondo dispositivo prima di farvi affidamento, come con una frase seed.
