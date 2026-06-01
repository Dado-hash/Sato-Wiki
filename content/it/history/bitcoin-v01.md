---
id: history.bitcoin-v01
slug: bitcoin-v01
language: it
date: 2009-01-09
title: Rilasciato Bitcoin v0.1
category: origin
summary: Satoshi Nakamoto rilascia Bitcoin v0.1 su SourceForge, la prima implementazione open source del protocollo Bitcoin in C++.
tags:
  - Bitcoin
  - Software
  - Open Source
  - Satoshi Nakamoto
related:
  - id: wiki.transactions
    title: Transazioni Bitcoin
  - id: wiki.blocks
    title: Blocchi
  - id: wiki.mining
    title: Mining
  - id: wiki.full-nodes
    title: Full Node
  - id: wiki.peer-to-peer-network
    title: Rete Peer-to-Peer
  - id: wiki.bitcoin-script
    title: Bitcoin Script
sources:
  - title: Rilascio Bitcoin v0.1 su SourceForge
    url: https://sourceforge.net/projects/bitcoin/files/Bitcoin/bitcoin-0.1/
    author: Satoshi Nakamoto
    publishedAt: 2009-01-09
  - title: README di Bitcoin v0.1
    url: https://bitcointalk.org/index.php?topic=68121.0
    author: Satoshi Nakamoto
    publishedAt: 2009-01-09
  - title: Il primo annuncio del software Bitcoin
    url: https://www.metzdowd.com/pipermail/cryptography/2009-January/014994.html
    author: Satoshi Nakamoto
    publishedAt: 2009-01-09
updatedAt: 2026-05-28T00:00:00Z
---

Il 9 gennaio 2009, sei giorni dopo aver minato il blocco genesis, Satoshi Nakamoto rilasciò Bitcoin v0.1 su SourceForge. Questa fu la prima implementazione funzionante del protocollo Bitcoin, scritta in C++ e distribuita come software open source. L'annuncio fu fatto sulla stessa mailing list di crittografia dove il whitepaper era stato pubblicato due mesi prima.

![Screenshot di Bitcoin v0.1](media/history/bitcoin-v01/bitcoin-v01-screenshot.webp "L'interfaccia del client Windows Bitcoin v0.1, che mostra la UI semplice con un singolo indirizzo e controlli di base.")

## Il Software

Bitcoin v0.1 era un'implementazione completa e autonoma. Includeva un client full-node, un wallet, un miner e un livello di rete peer-to-peer. Il software era progettato per Windows, con il codice sorgente disponibile anche per la compilazione su altre piattaforme. L'installer era di circa 100 KB — un contrasto sorprendente con la blockchain multi-gigabyte che sarebbe stata necessaria in seguito.

La release consisteva nei seguenti componenti:

- **bitcoin.exe**: L'applicazione principale, che combinava full node, wallet e miner.
- **bitcoin.conf**: Il file di configurazione dove gli utenti potevano impostare parametri come la porta e il server di bootstrap IRC.
- **README.txt**: Documentazione che spiegava installazione, funzionamento e i principi crittografici alla base di Bitcoin.
- **Codice sorgente**: Il codice C++ completo, rilasciato sotto licenza MIT.

Il README includeva una nota profetica sull'offerta fissa: "I bitcoin sono generati a un ritmo di 50 BTC per blocco e l'offerta totale è di 21 milioni."

## Decisioni di Progetto in v0.1

La prima release conteneva già la maggior parte degli elementi di design fondamentali che Bitcoin usa ancora oggi:

- **Proof of work SHA-256**: Il mining utilizzava il doppio SHA-256 dell'header del blocco.
- **Indirizzi Base58**: Il formato degli indirizzi con Base58Check era presente fin dall'inizio.
- **Firme ECDSA**: Le transazioni erano protette con l'algoritmo di firma digitale a curva ellittica su secp256k1.
- **Sistema Script**: Il linguaggio Bitcoin Script era già implementato per bloccare e sbloccare le transazioni.
- **Scoperta peer tramite IRC**: I nodi si scoprivano attraverso un canale IRC, una scelta pragmatica per la rete iniziale.
- **Porta 8333**: La porta predefinita per la comunicazione peer-to-peer di Bitcoin.

## La Scelta Open Source

Rilasciando Bitcoin come software open source sotto licenza MIT, Satoshi garantì che il progetto potesse sopravvivere a qualsiasi singolo contributore. La decisione fu strategica: una valuta decentralizzata richiedeva sviluppo decentralizzato. Chiunque poteva ispezionare il codice, verificare la sicurezza e contribuire con miglioramenti. Questa trasparenza era essenziale per costruire la fiducia che un sistema finanziario distribuito richiede.

La scelta di SourceForge come piattaforma di distribuzione rifletteva le convenzioni open source dell'epoca. Il progetto si sarebbe successivamente trasferito su GitHub, dove lo sviluppo di Bitcoin Core continua oggi con centinaia di contributori.

## Usare Bitcoin v0.1

L'utilizzo della prima versione richiedeva competenze tecniche. Gli utenti dovevano scaricare l'installer, configurare il firewall per permettere connessioni in entrata sulla porta 8333 e attendere la sincronizzazione della blockchain — che all'epoca richiedeva solo pochi secondi. Il software generava una coppia di chiavi crittografiche localmente e mostrava l'indirizzo pubblico. Il mining era basato su CPU e integrato direttamente nel client — semplicemente eseguendo il software si contribuiva potenza di hash alla rete.

La rete iniziale era minuscola. Per le prime settimane, Satoshi era probabilmente l'unico a minare. La difficoltà era così bassa che i blocchi potevano essere trovati con una CPU desktop standard in poche ore. Questo periodo di mining CPU solitario sarebbe durato mesi prima che il mining GPU diventasse praticabile.

## Eredità

Bitcoin v0.1 rappresenta il momento in cui il Bitcoin teorico divenne reale. Sei giorni dopo il blocco genesis, il software che avrebbe operato la rete era nelle mani del pubblico. Ogni implementazione successiva di Bitcoin — da Bitcoin Core a btcd a libbitcoin — discende concettualmente da questa prima release. Il codice stesso è stato quasi interamente riscritto, ma il protocollo che implementava rimane il fondamento dell'intero ecosistema delle criptovalute.

