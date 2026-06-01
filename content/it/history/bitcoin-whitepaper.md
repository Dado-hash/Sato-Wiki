---
id: history.bitcoin-whitepaper
slug: bitcoin-whitepaper
language: it
date: 2008-10-31
title: Pubblicato il Whitepaper di Bitcoin
category: origin
summary: Satoshi Nakamoto pubblica il whitepaper "Bitcoin: A Peer-to-Peer Electronic Cash System" sulla mailing list cypherpunk.
tags:
  - Bitcoin
  - Whitepaper
  - Cypherpunk
  - Crittografia
related:
  - id: wiki.proof-of-work
    title: Proof of Work
  - id: wiki.blockchain
    title: Blockchain
  - id: wiki.transactions
    title: Transazioni Bitcoin
  - id: wiki.digital-signatures
    title: Firme Digitali
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: Annuncio originale del whitepaper sulla mailing list di crittografia
    url: https://www.metzdowd.com/pipermail/cryptography/2008-October/014660.html
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: Il movimento Cypherpunk — contesto del whitepaper Bitcoin
    url: https://nakamotoinstitute.org/literature/
    author: Nakamoto Institute
updatedAt: 2026-05-28T00:00:00Z
---

Il 31 ottobre 2008, un individuo o un gruppo sotto lo pseudonimo di Satoshi Nakamoto pubblicò un whitepaper di nove pagine sulla mailing list di crittografia di metzdowd.com. Il documento, intitolato "Bitcoin: A Peer-to-Peer Electronic Cash System", proponeva una valuta digitale decentralizzata che funzionasse senza alcuna autorità centrale o intermediari fidati.

![Copertina del whitepaper Bitcoin](media/history/bitcoin-whitepaper/whitepaper-cover.webp "La pagina del titolo del whitepaper originale di Bitcoin pubblicato da Satoshi Nakamoto nell'ottobre 2008.")

Il whitepaper risolveva un problema che aveva eluso i ricercatori per decenni: il problema della doppia spesa. I precedenti tentativi di creare moneta digitale — dall'eCash di David Chaum al Bit Gold di Nick Szabo e al b-money di Wei Dai — richiedevano tutti una terza parte fidata per impedire che lo stesso token digitale venisse speso due volte. L'intuizione di Nakamoto fu combinare diversi primitivi crittografici esistenti in un sistema innovativo: la proof of work per timestampare le transazioni, una rete peer-to-peer per propagarle e firme crittografiche per l'autorizzazione.

## Il Contesto Cypherpunk

Il whitepaper non apparve nel vuoto. Fu pubblicato su una mailing list di cypherpunk — crittografi, informatici e attivisti della privacy che lavoravano su strumenti crittografici per la privacy digitale sin dai primi anni '90. Il movimento cypherpunk produsse la crittografia PGP, i remailer anonimi e le prime proposte di moneta digitale. Il documento di Nakamoto rappresentava il culmine di oltre un decennio di ricerca sul consenso decentralizzato.

## Innovazioni Chiave

Il whitepaper introdusse diversi concetti che sarebbero diventati fondamentali:

- **Catena di proof of work**: I miner competono per trovare un hash di blocco valido; la catena con più proof of work accumulata è quella autorevole.
- **Verifica peer-to-peer**: Tutte le transazioni sono trasmesse alla rete e ogni nodo le valida indipendentemente.
- **Struttura ad albero di Merkle**: Le transazioni sono hashate in un Merkle tree, permettendo verifica leggera senza scaricare l'intera blockchain.
- **Allineamento degli incentivi**: I miner sono ricompensati con nuovi bitcoin e commissioni, allineando il loro interesse personale con la sicurezza della rete.

## La Prima Reazione

La reazione iniziale sulla mailing list fu cauta ma interessata. Hal Finney, rinomato crittografo e cypherpunk, fu tra i primi a rispondere positivamente. Sarebbe poi diventato il destinatario della prima transazione Bitcoin. Altri membri sollevarono domande sulla scalabilità, sulla fattibilità della proof of work e sulle assunzioni economiche alla base dell'offerta fissa.

Il whitepaper non conteneva codice, né implementazione, né impegno a costruire il sistema. Era una proposta teorica. Eppure la sua eleganza — il modo accurato in cui combinava idee esistenti in un insieme coerente — convinse un numero sufficiente di persone che qualcosa di importante era stato proposto.

## Impatto Duraturo

Il whitepaper di Bitcoin è stato citato decine di migliaia di volte in letteratura accademica, menzionato in documenti normativi in tutto il mondo e tradotto in dozzine di lingue. Rimane il documento più importante nella storia delle criptovalute. L'influenza del documento si estende oltre la finanza all'informatica, all'economia, alla filosofia politica e alla teoria giuridica. L'intuizione centrale — che il consenso può essere raggiunto senza fiducia — ha ispirato migliaia di progetti e cambiato fondamentalmente il modo in cui pensiamo al denaro e al coordinamento su internet.

