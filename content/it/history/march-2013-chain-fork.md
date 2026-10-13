---
id: history.march-2013-chain-fork
slug: march-2013-chain-fork
language: it
date: 2013-03-11
title: Fork della catena del marzo 2013
category: security
summary: Nel marzo 2013 nodi precedenti alla versione 0.8 rifiutarono un blocco valido con molti input a causa di un limite sui lock del database, e la rete si divise in due catene.
tags:
  - Fork
  - Berkeley DB
  - Consenso
  - Mining pool
sources:
  - title: "BIP 50: March 2013 Chain Fork Post-Mortem"
    url: https://github.com/bitcoin/bips/blob/master/bip-0050.mediawiki
    author: Gavin Andresen
    publishedAt: 2013-03-20
  - title: "Common Vulnerabilities and Exposures (CVE-2013-3220 entry)"
    url: https://en.bitcoin.it/wiki/Common_Vulnerabilities_and_Exposures
    author: Bitcoin Wiki contributors
    publishedAt: 2013-03-11
related:
  - wiki.forks-and-soft-forks
  - wiki.mining-pools
  - wiki.reorganizations
  - wiki.full-nodes
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## Cosa successe

L'11 marzo 2013 fu minato e diffuso un blocco con più input di transazione di quanti ne avesse mai avuti un blocco precedente. I nodi con Bitcoin 0.8 riuscirono a elaborarlo, ma alcuni nodi con versioni precedenti lo rifiutarono, e la rete si divise in due catene. La catena che includeva il blocco, che la BIP 50 chiama catena 0.8, aveva circa il 60% della potenza di hash del mining. Questa quota significava che la divisione non si risolveva da sola.

## Perché accadde

Le versioni precedenti alla 0.8 usavano Berkeley DB ed erano configurate con troppo pochi lock per elaborare blocchi grandi ma validi. Il limite sui lock era diventato di fatto una regola di consenso, anche se variava da nodo a nodo. Bitcoin 0.8 usava invece LevelDB, che non aveva lo stesso limite. La BIP 50 aggiunge che la stessa debolezza avrebbe potuto colpire anche i nodi 0.7.2, anche se tutta la rete avesse girato su quella versione.

## Come si risolse

Per ripristinare rapidamente una sola catena, BTCGuild e Slush riportarono i loro nodi 0.8 alla versione 0.7, così i propri pool rifiutarono il blocco più grande. In questo modo la maggioranza dell'hash passò alla catena senza quel blocco, e i nodi 0.8 si riorganizzarono su di essa. La divisione fu rilevata rapidamente e i depositi presso i principali exchange furono sospesi per un breve periodo. Durante la divisione un double spend riuscì. Secondo la BIP 50 fu compiuto da qualcuno che stava verificando se fosse possibile, senza intenti malevoli.

## Cosa cambiò in seguito

Gli sviluppatori rilasciarono la versione 0.8.1, derivata dalla 0.8.0. Per due mesi rifiutò i blocchi che probabilmente avrebbero richiesto più di 10.000 lock, e limitò a 500.000 byte la dimensione dei blocchi creati. Il piano prevedeva anche una patch per le versioni precedenti, che portava il limite a 537.000 lock, ma la BIP 50 non segna questo punto come completato. Il sistema di alert ricevette un'opzione che esegue un comando quando un alert riguarda un nodo, e alert di prova furono programmati ogni settimana su testnet.
