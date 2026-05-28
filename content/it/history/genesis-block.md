---
id: history.genesis-block
slug: genesis-block
language: it
date: 2009-01-03
title: Minato il Blocco Genesis
category: origin
summary: Il blocco 0 della blockchain Bitcoin viene minato da Satoshi Nakamoto, contenente il messaggio "The Times 03/Jan/2009 Chancellor on brink of second bailout for banks."
tags:
  - Bitcoin
  - Blocco Genesis
  - Blockchain
  - Satoshi Nakamoto
related:
  - id: wiki.blocks
    title: Blocchi
  - id: wiki.blockchain
    title: Blockchain
  - id: wiki.mining
    title: Mining
  - id: wiki.proof-of-work
    title: Proof of Work
  - id: wiki.transactions
    title: Transazioni Bitcoin
sources:
  - title: Blocco Genesis di Bitcoin — Blockchain.com
    url: https://www.blockchain.com/explorer/blocks/0
    author: Blockchain.com
  - title: The Times — Chancellor on brink of second bailout for banks
    url: https://www.thetimes.co.uk/article/chancellor-alistair-darling-on-brink-of-second-bailout-for-banks-n9l382mn62h
    author: The Times
    publishedAt: 2009-01-03
  - title: Blocco Genesis — Bitcoin Wiki
    url: https://en.bitcoin.it/wiki/Genesis_block
    author: Bitcoin Wiki contributors
updatedAt: 2026-05-28T00:00:00Z
---

Il 3 gennaio 2009, Satoshi Nakamoto minò il blocco 0 della blockchain Bitcoin — il blocco genesis. Questo fu il primo blocco in assoluto, la radice dell'intera catena da cui tutti i blocchi successivi sarebbero discesi. Il blocco conteneva un messaggio speciale incorporato nella transazione coinbase: "The Times 03/Jan/2009 Chancellor on brink of second bailout for banks."

## Il Significato del Messaggio

Il messaggio serviva a molteplici scopi. Dimostrava che il blocco non poteva essere stato minato prima del 3 gennaio 2009, stabilendo un timestamp verificabile. Forniva anche una dichiarazione politica e filosofica: il sistema bancario tradizionale stava fallendo e un'alternativa decentralizzata veniva ora lanciata. Il riferimento al salvataggio bancario britannico non era casuale — era la crisi stessa che aveva motivato la creazione di Bitcoin.

Il titolo del The Times descriveva la considerazione del Cancelliere Alistair Darling di un secondo pacchetto di salvataggio per le banche britanniche, gravemente colpite dalla crisi finanziaria del 2008. Incorporando questo titolo nel blocco genesis, Nakamoto legò permanentemente l'origine di Bitcoin al fallimento della fiducia nella finanza tradizionale.

## Dettagli Tecnici

Il blocco genesis è unico sotto diversi aspetti. A differenza di tutti i blocchi successivi, non ha un blocco precedente a cui riferirsi — il suo campo `prev_block` è composto da tutti zeri. L'output di 50 BTC della transazione coinbase non può essere speso perché il blocco genesis è hardcodato in ogni client Bitcoin come caso speciale. Il timestamp del blocco è 1231006505 (tempo UNIX) e il target di difficoltà era impostato al valore iniziale di 1.

Lo script di input della transazione coinbase contiene il famoso titolo del Times come stringa ASCII. Questo rende il blocco genesis non solo un artefatto tecnico ma anche un documento storico, che registra permanentemente le circostanze economiche della sua creazione.

## Il Processo di Mining

Minare il blocco genesis richiese di trovare un nonce che, hashato con il resto dell'header del blocco, producesse un hash inferiore al target. Il nonce trovato da Satoshi fu 2083236893. Questo processo, sebbene banale per gli standard odierni (la difficoltà era 1), rappresentò la prima proof of work sulla rete Bitcoin.

Il blocco genesis conteneva solo la transazione coinbase — non esistevano ancora altre transazioni. La rete non era ancora operativa in alcun senso significativo: non c'erano altri nodi, né peer, né modo di trasmettere dati. Il blocco genesis fu creato in isolamento, il primo passo per avviare un nuovo sistema finanziario.

## Significato Simbolico

Per la comunità Bitcoin, il blocco genesis è diventato un simbolo delle origini e degli ideali del progetto. Il titolo di giornale incorporato è frequentemente citato come prova dello scopo di Bitcoin: una risposta all'instabilità monetaria e al fallimento del sistema bancario a riserva frazionaria. Ogni blocco Bitcoin successivo — centinaia di migliaia — traccia la propria discendenza da questo singolo blocco. Gli block explorer lo mostrano con riverenza speciale e gli appassionati di criptovalute spesso lo visitano come un pellegrinaggio.

![Pietra miliare del blocco genesis](media/history/genesis-block/genesis-block-landmark.webp "Il blocco genesis come appare su un block explorer, con zero conferme e nessun hash di blocco precedente.")
