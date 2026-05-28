---
id: wiki.commitment-transactions
slug: commitment-transactions
language: it
category: lightning network
title: Transazioni di Commitment
description: Le transazioni asimmetriche off-chain che rappresentano il saldo più recente del canale, progettate con un meccanismo di penalità per scoraggiare chiusure disoneste del canale.
coverImage: media/wiki/commitment-transactions/commitment-tx-structure.svg
difficulty: advanced
readTimeMinutes: 10
tags:
  - Lightning Network
  - Transazioni di Commitment
  - Meccanismo di Penalità
  - Off-Chain
related:
  - wiki.payment-channels
  - wiki.channel-funding-transactions
  - wiki.htlcs
  - wiki.timelocks
  - wiki.bitcoin-script
  - wiki.lightning-network
sources:
  - title: "Poon-Dryja LN paper"
    url: https://lightning.network/lightning-network-paper.pdf
    author: Joseph Poon, Thaddeus Dryja
    publishedAt: 2016-01-14
  - title: "BOLT #3 — Bitcoin Transaction and Script Formats"
    url: https://github.com/lightning/bolts/blob/master/03-transactions.md
    author: Lightning Network Specifications
    publishedAt: 2016-07-11
  - title: "Mastering the Lightning Network"
    url: https://github.com/lnbook/lnbook
    author: Andreas M. Antonopoulos, Olaoluwa Osuntokun, Rene Pickhardt
    publishedAt: 2021-12-01
updatedAt: 2026-05-27T00:00:00Z
---

## base

Le transazioni di commitment sono il cuore del protocollo Lightning Network. Ogni volta che due parti effettuano o inoltrano un pagamento in un canale, creano una nuova transazione di commitment che riflette il saldo aggiornato. In condizioni normali, questa transazione non viene mai trasmessa alla blockchain di Bitcoin — esiste solo come accordo firmato off-chain tra i due partecipanti al canale.

Ogni transazione di commitment spende l'output di funding 2-of-2 multisig della transazione di funding del canale. Paga a ciascuna parte il saldo corrente secondo l'ultimo stato del canale. Se una delle due parti scompare o tenta di imbrogliare, l'altra può trasmettere l'ultima transazione di commitment per recuperare i propri fondi on-chain.

La proprietà di sicurezza fondamentale: solo la transazione di commitment più recente è valida. Gli stati precedenti, se trasmessi, attivano una penalità che assegna tutti i fondi del canale alla parte onesta.

![Struttura della transazione di commitment](media/wiki/commitment-transactions/commitment-tx-structure.svg "Transazione di commitment per il finanziatore del canale che mostra l'input UTXO di funding, gli output to_local e to_remote, e gli output HTLC.")

## medium

Il design della transazione di commitment è deliberatamente asimmetrico. Nella versione di Alice della transazione di commitment, l'output di Alice (chiamato to_local) ha un time lock relativo tramite OP_CHECKSEQUENCEVERIFY, tipicamente 144 blocchi (circa 24 ore). L'output di Bob (chiamato to_remote) non ha time lock ed è immediatamente spendibile da Bob. Nella transazione di commitment di Bob, i ruoli sono invertiti: l'output di Bob ha il time lock e quello di Alice è immediato.

Questa asimmetria è ciò che rende funzionante il meccanismo di penalità. Quando viene negoziato un nuovo stato del canale, entrambe le parti si scambiano i segreti di revoca per lo stato precedente. Se una delle due parti tenta di trasmettere una vecchia transazione di commitment, l'altra parte può:

1. Spendere immediatamente il proprio output to_remote (non ha time lock)
2. Usare la chiave di revoca per spendere l'output to_local della parte disonesta, bypassando completamente il time lock CSV

Lo script dell'output revocato contiene sia la chiave pubblica di revoca della parte onesta che il percorso di spesa ritardata. Poiché il segreto di revoca per il vecchio stato è ora noto, la parte onesta può costruire una firma usando la chiave di revoca e reclamare i fondi della parte disonesta come penalità.

![Meccanismo di penalità](media/wiki/commitment-transactions/penalty-mechanism.svg "Se Alice trasmette un vecchio stato, Bob può reclamare tutti i fondi del canale usando la chiave di revoca, bypassando il time lock CSV.")

## advanced

### Derivazione del segreto per-commitment

Ogni stato di commitment è legato a un segreto per-commitment unico. BOLT #3 specifica l'uso di una shachain o di una catena di hash indicizzata per derivare questi segreti in modo efficiente. Il nodo finanziatore genera un segreto base e deriva una sequenza di segreti usando una funzione hash unidirezionale:

```
secret_n = SHA256(secret_{n+1})
```

Dato secret_n, chiunque può derivare tutti i segreti precedenti nella catena, ma non può derivare segreti futuri. Ciò permette uno storage efficiente: i nodi devono solo memorizzare il segreto più recente e possono rigenerare quelli più vecchi quando necessario.

### Processo di revoca

Dopo che entrambe le parti hanno firmato una nuova transazione di commitment (stato N), si scambiano immediatamente i segreti di revoca per lo stato precedente (stato N-1). Ciò significa che dopo aver concordato lo stato N, entrambe le parti hanno la capacità di penalizzare lo stato N-1. Il protocollo garantisce che nessuno stato precedente al più recente possa essere trasmesso in sicurezza.

### Dettagli della struttura della transazione

La transazione di commitment usa valori specifici dei campi per abilitare il meccanismo di penalità:

**nLocktime.** Impostato a 0 per il funzionamento normale. Il time lock relativo è imposto attraverso il numero di sequenza sull'input di funding e il CSV nello script di output.

**Sequence.** L'input di funding ha il numero di sequenza impostato al valore di ritardo CSV (es. 144). Questo, combinato con OP_CSV nello script to_local, impedisce che l'output ritardato venga speso fino al passaggio del numero richiesto di blocchi.

**Script dell'output to_local:**
```
OP_IF
    <remote_revocation_pubkey>
OP_ELSE
    <csv_delay> OP_CHECKSEQUENCEVERIFY OP_DROP
    <local_delayed_pubkey>
OP_ENDIF
OP_CHECKSIG
```

Se la parte remota conosce la chiave privata di revoca (dal segreto di revoca del vecchio stato), può spendere usando il primo ramo immediatamente. Altrimenti, la parte locale deve attendere il ritardo CSV per spendere tramite il secondo ramo.

**Script dell'output to_remote:**
```
<remote_pubkey> OP_CHECKSIG
```

Semplice pay-to-pubkey. La parte remota può spenderlo immediatamente.

### Output HTLC nelle transazioni di commitment

Ogni HTLC in sospeso genera due output nella transazione di commitment:

- **HTLC offerto:** L'HTLC offerto dal nodo locale al nodo remoto. Il remoto lo riscatta fornendo il preimage entro il timeout CLTV.
- **HTLC ricevuto:** L'HTLC offerto dal nodo remoto al nodo locale. Il locale lo riscatta fornendo il preimage, o il remoto lo reclama dopo il timeout.

Ogni output HTLC usa uno script con due percorsi di spesa (simile allo script to_local): un percorso richiede il preimage e l'altro richiede un timeout.

### Gestione delle commissioni

Ogni transazione di commitment include una commissione che viene dedotta dal saldo del canale. La commissione è calcolata dal peso della transazione e da un tasso di commissione negoziato tra le parti. La commissione è sempre pagata dal finanziatore del canale. Se la commissione è troppo bassa per essere attraente per i miner, entrambe le parti possono rifiutarsi di firmare un nuovo commitment e richiedere un aggiornamento della commissione.

### HTLC dust

Gli HTLC il cui valore è inferiore al limite dust (attualmente 546 satoshi per un output P2WPKH) non sono inclusi nella transazione di commitment. Invece, il valore viene aggiunto alla commissione. Questo impedisce che la blockchain venga inquinata con output antieconomici e mantiene limitata la dimensione della transazione di commitment.
