---
id: wiki.htlcs
slug: htlcs
language: it
category: lightning network
title: HTLC
description: Hash Time Locked Contracts — pagamenti condizionali che possono essere riscossi solo con il preimmagine corretto prima della scadenza di un timelock, consentendo il routing multi-hop sicuro sulla Lightning Network.
coverImage: media/wiki/htlcs/htlc-flow.svg
difficulty: advanced
readTimeMinutes: 9
tags:
  - Lightning Network
  - HTLC
  - Hashlock
  - Timelock
  - Routing Atomico
related:
  - wiki.lightning-network
  - wiki.payment-channels
  - wiki.commitment-transactions
  - wiki.onion-routing
  - wiki.timelocks
  - wiki.hashlocks
sources:
  - title: "Poon-Dryja Lightning Network paper"
    url: https://lightning.network/lightning-network-paper.pdf
    author: Joseph Poon, Thaddeus Dryja
    publishedAt: 2016-01-14
  - title: "BOLT #2 — Peer Protocol for Channel Management"
    url: https://github.com/lightning/bolts/blob/master/02-peer-protocol.md
    author: Lightning Network Specifications
    publishedAt: 2016-03-30
  - title: "BOLT #4 — Onion Routing"
    url: https://github.com/lightning/bolts/blob/master/04-onion-routing.md
    author: Lightning Network Specifications
    publishedAt: 2016-04-01
  - title: "Mastering the Lightning Network (Chapter 9)"
    url: https://github.com/lnbook/lnbook
    author: Andreas M. Antonopoulos, Olaoluwa Osuntokun, René Pickhardt
    publishedAt: 2021-11-01
updatedAt: 2026-05-27T00:00:00Z
---

## base

Un Hash Time Locked Contract (HTLC) è un pagamento Bitcoin condizionale che richiede al destinatario di dimostrare la conoscenza di un valore segreto (il preimage) prima della scadenza di un termine. Due condizioni devono essere soddisfatte:

**Hashlock.** Il mittente crea l'hash di un valore casuale segreto, H(x). Il destinatario può spendere l'output solo fornendo il valore originale x che produce lo stesso hash. Questo prova che il destinatario conosce il segreto.

**Timelock.** L'output HTLC include un limite di tempo assoluto usando CLTV (OP_CHECKLOCKTIMEVERIFY). Se il destinatario non rivela il preimage prima di questa scadenza, il mittente può recuperare i fondi.

Gli HTLC rendono possibili i pagamenti multi-hop sulla Lightning Network senza doversi fidare dei nodi intermedi. Alice può pagare Carol attraverso Bob senza che Bob possa rubare i fondi — Bob può riscuotere la sua commissione di routing solo se Carol rivela il preimage, cosa che permette anche ad Alice di confermare che il pagamento è avvenuto con successo.

![Flusso HTLC attraverso tre nodi](media/wiki/htlcs/htlc-flow.svg "Alice crea un HTLC con hashlock H(x) e timelock di 144 blocchi. Bob lo inoltra a Carol con un timelock più breve. Carol rivela il preimage x per riscuotere. Il preimage si propaga all'indietro, provando che il pagamento è completo.")

## medium

**Meccanica dell'hashlock.** Il mittente genera un valore casuale x di 32 byte e calcola il suo hash SHA256 H(x). L'hash è incorporato nello script HTLC. Per spendere l'output, il destinatario deve fornire x e una firma valida. L'hashlock garantisce che solo il party che conosce x possa riscuotere i fondi. SHA256 di Bitcoin è resistente al preimage — non c'è modo di derivare x da H(x) se non tramite forza bruta.

**Meccanica del timelock.** L'output HTLC usa CLTV con un'altezza di blocco assoluta. Nella Lightning Network, i valori CLTV sono espressi come altezze di blocco (non timestamp). Un HTLC tipico potrebbe avere un timelock di 144 blocchi (~24 ore) dalla punta corrente della chain. Se il preimage non viene rivelato prima della scadenza del timelock, il mittente può spendere tramite il ramo di timeout.

**Atomicità.** L'HTLC viene o interamente riscosso o interamente rimborsato. Quando Alice paga Carol attraverso Bob usando HTLC, la proprietà atomica garantisce:
- Se Carol rivela il preimage, tutti e tre gli HTLC si regolano: Alice paga Bob, Bob paga Carol
- Se Carol non rivela il preimage, tutti e tre gli HTLC scadono: Carol non può riscuotere, Bob recupera i fondi da Carol, Alice recupera i fondi da Bob
- Nessun regolamento parziale è possibile — non esiste uno stato in cui un hop ha successo e un altro fallisce

**Offer HTLC e Receive HTLC.** In una transazione di commitment del canale, ogni HTLC è rappresentato come due output: uno per il nodo che ha offerto l'HTLC (lato mittente) e uno per il nodo che lo ha ricevuto (lato destinatario). L'output offer HTLC è controllato dal mittente, mostrando i fondi che ha impegnato. L'output receive HTLC è controllato dal destinatario, mostrando i fondi che si aspetta di ricevere. Entrambi sono inclusi nella transazione di commitment e aggiornati quando un nuovo HTLC viene aggiunto o rimosso.

![Percorsi di successo e timeout HTLC](media/wiki/htlcs/htlc-timeout-vs-success.svg "Il percorso di successo: Carol rivela il preimage, Bob riscuote e lo inoltra, Alice riscuote. Il percorso di timeout: Carol non rivela il preimage, il timelock scade, e Bob e Alice recuperano i loro fondi.")

## advanced

**Script HTLC nella transazione di commitment.** Lo script dell'output HTLC in una transazione di commitment usa un ramo a due vie:

```
OP_IF
  <remote_pubkey> OP_CHECKSIG                (ramo di adempimento)
OP_ELSE
  <cltv_expiry> OP_CHECKLOCKTIMEVERIFY OP_DROP
  <local_pubkey> OP_CHECKSIG                 (ramo di timeout)
OP_ENDIF
```

Lo spenditore sceglie quale ramo eseguire spingendo un valore true (1) o false (0) prima che lo script venga eseguito.

**Ramo di adempimento.** Il destinatario spende tramite il ramo IF fornendo:
1. Il preimage x (l'hashlock)
2. Una firma valida dalla propria chiave privata
3. Un valore 1 sullo stack per entrare nel ramo IF

La transazione usa il preimage come elemento hashlock witness. Il full node verifica che H(x) corrisponda all'hash impegnato nell'HTLC e che la firma sia valida per la pubkey remota. Una volta verificato, l'output HTLC viene speso a favore del destinatario.

**Ramo di timeout.** Il mittente spende tramite il ramo ELSE fornendo:
1. Una firma valida dalla propria chiave privata
2. Un valore 0 (o qualsiasi cosa falsy) sullo stack per entrare nel ramo ELSE
3. La transazione deve avere nLockTime >= cltv_expiry

OP_CHECKLOCKTIMEVERIFY verifica che il locktime della transazione sia maggiore o uguale a cltv_expiry. Se il controllo passa, l'esecuzione continua a OP_DROP (che rimuove il valore di scadenza) e poi a OP_CHECKSIG con la pubkey locale. Questo garantisce che il mittente non possa riscuotere il ramo di timeout prima della scadenza del timelock, nemmeno con la propria firma.

**Accettazione di un HTLC.** Prima di accettare un HTLC, un nodo di forwarding verifica diverse condizioni:
- Il cltv_expiry dell'HTLC in entrata è sufficientemente lontano nel futuro
- L'HTLC in uscita ha un cltv_expiry più breve, lasciando un margine di sicurezza (il cltv_expiry_delta da BOLT 2)
- L'importo dell'HTLC copre la commissione di routing più il pagamento in uscita

Il cltv_expiry_delta standard è di 144 blocchi (~24 ore) per il primo hop e 12 blocchi (~2 ore) per gli hop successivi nella configurazione predefinita di LND.

**Forwarding HTLC e cltv_expiry_delta.** Quando Bob inoltra un HTLC da Alice a Carol, deve garantire che:
- L'HTLC di Alice verso Bob: cltv_expiry = T1
- L'HTLC di Bob verso Carol: cltv_expiry = T2, dove T2 < T1

La differenza T1 - T2 (il cltv_expiry_delta) dà a Bob il tempo di riscuotere il ramo di timeout sul canale Alice-Bob se Carol non rivela il preimage prima di T2. BOLT 2 specifica valori minimi di cltv_expiry_delta basati sull'intervallo di blocco previsto e sulla tolleranza al rischio del nodo di forwarding.

**Propagazione del preimage.** Il preimage scorre all'indietro attraverso la route:
1. Carol rivela x a Bob spendendo l'output HTLC sul canale Bob-Carol
2. Bob vede x on-chain, il che prova che Carol ha riscosso l'HTLC
3. Bob ora conosce x e può spendere l'output HTLC sul canale Alice-Bob
4. Alice vede x on-chain, confermando che Carol ha ricevuto il pagamento

Ogni hop riscuote indipendentemente il suo HTLC in entrata usando il preimage.

**HTLC e gestione delle commissioni.** Ogni nodo di forwarding addebita una commissione di routing. Quando Bob inoltra un HTLC, l'importo che invia a Carol è inferiore a quello che riceve da Alice — la differenza è la sua commissione di routing. La struttura delle commissioni è:
- Commissione base: un importo fisso per HTLC (tipicamente 1-1000 millisatoshi)
- Tasso di commissione: una commissione proporzionale all'importo inoltrato (tipicamente 1-1000 parti per milione)

Sia la commissione base che il tasso sono codificati nell'annuncio del canale del nodo e possono essere regolati dinamicamente.

**Trimming.** Gli output HTLC al di sotto del limite di polvere (dust limit) non vengono aggiunti alla transazione di commitment. Invece, vengono tracciati off-chain e regolati alla chiusura del canale o quando una futura transazione di commitment li include. Il dust limit è tipicamente di 546 satoshi per output P2WSH. Il trimming riduce il peso della transazione e mantiene le transazioni di commitment più piccole, abbassando le commissioni on-chain in caso di chiusura unilaterale.

**Multi-Path Payments (MPP).** Un singolo pagamento può essere suddiviso in più HTLC parziali, ciascuno instradato attraverso un percorso diverso. MPP richiede:
- Tutti gli HTLC parziali usano lo stesso hash di pagamento H(x)
- Il destinatario attende che la somma di tutti i pagamenti parziali sia uguale all'importo totale prima di generare una fattura
- Ogni HTLC parziale è atomicamente indipendente, ma il pagamento complessivo si completa solo quando tutte le parti arrivano

MPP migliora l'affidabilità instradando attorno a canali congestionati o guasti, e migliora la privacy distribuendo il pagamento attraverso percorsi multipli.

**KeySend e pagamenti spontanei.** KeySend è un'estensione che elimina la necessità di una fattura. Il mittente genera il preimage da solo e deriva l'hash di pagamento da esso. L'hash di pagamento è incluso nel payload onion, permettendo al destinatario di derivare il preimage dall'hash di pagamento. Questo consente pagamenti spontanei dove il mittente non deve richiedere una fattura al destinatario.
