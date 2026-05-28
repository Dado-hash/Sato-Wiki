---
id: wiki.payment-channels
slug: payment-channels
language: it
category: lightning network
title: Canali di Pagamento
description: Una connessione bidirezionale tra due wallet Bitcoin che permette di transare off-chain senza trasmettere ogni pagamento alla rete.
coverImage: media/wiki/payment-channels/payment-channel-lifecycle.svg
difficulty: advanced
readTimeMinutes: 9
tags:
  - Lightning Network
  - Canali di Pagamento
  - Layer 2
  - Off-Chain
related:
  - wiki.lightning-network
  - wiki.channel-funding-transactions
  - wiki.commitment-transactions
  - wiki.htlcs
  - wiki.timelocks
  - wiki.multisig
sources:
  - title: "The Bitcoin Lightning Network: Scalable Off-Chain Instant Payments"
    url: https://lightning.network/lightning-network-paper.pdf
    author: Joseph Poon and Thaddeus Dryja
    publishedAt: 2016-01-14
  - title: "Mastering the Lightning Network — Chapter 5: Payment Channels"
    url: https://github.com/lnbook/lnbook
    author: Andreas M. Antonopoulos, Olaoluwa Osuntokun, Rene Pickhardt
    publishedAt: 2021-11-01
  - title: "BOLT #2 — Peer Protocol for Channel Management"
    url: https://github.com/lightning/bolts/blob/master/02-peer-protocol.md
    author: Lightning Network Specifications
    publishedAt: 2020-01-01
updatedAt: 2026-05-27T00:00:00Z
---

## base

Un canale di pagamento è un percorso privato diretto tra due parti sulla Lightning Network. Permette di scambiare pagamenti istantaneamente senza registrare ogni singola transazione sulla blockchain di Bitcoin.

Immagina una carta caffè prepagata. Carichi denaro sulla carta una volta, poi fai molti acquisti detraendo dal saldo. Solo due eventi toccano la blockchain: il caricamento della carta (apertura) e lo scarto della carta con il saldo rimanente (chiusura). Tutto il resto avviene off-chain tra te e il bar.

Aprire un canale richiede una singola transazione on-chain su Bitcoin. Alice crea una transazione di funding che blocca i suoi bitcoin in un output multisig 2-of-2 — un indirizzo speciale che richiede la firma sia di Alice che di Bob prima che i fondi possano essere spostati. Questa transazione viene trasmessa e confermata sulla blockchain.

Una volta confermata la transazione di funding, Alice e Bob possono scambiarsi tutti i pagamenti che desiderano. Ogni pagamento aggiorna l'allocazione del saldo del canale. Entrambe le parti firmano nuove transazioni di commitment che riflettono il saldo aggiornato, e lo stato precedente viene revocato. Non sono necessarie ulteriori transazioni on-chain.

Il canale può rimanere aperto finché entrambe le parti concordano sul saldo. Quando decidono di chiudere, l'ultima transazione di commitment viene trasmessa alla blockchain. Ogni parte riceve il saldo concordato come un normale output on-chain.

I vantaggi principali sono pagamenti istantanei tra le due parti, commissioni di transazione vicine allo zero per i pagamenti all'interno del canale, e la possibilità di instradare pagamenti attraverso più canali attraverso la Lightning Network.

![Ciclo di vita di un canale di pagamento](media/wiki/payment-channels/payment-channel-lifecycle.svg "Un canale di pagamento attraversa tre fasi: apertura con una transazione di funding on-chain, aggiornamento con scambi di commitment off-chain, e chiusura con la trasmissione dello stato finale sulla blockchain.")

## medium

Un canale di pagamento è costruito su un output multisig 2-of-2 in Bitcoin Script. La transazione di funding crea un UTXO condiviso che può essere speso solo quando entrambe le parti firmano. Questo vincolo multisig è il fondamento che rende sicuro il canale — nessuna delle due parti può spostare unilateralmente i fondi senza il consenso dell'altra.

**Transazioni di commitment.** Una volta finanziato il canale, ogni parte detiene una versione dell'ultimo stato del canale sotto forma di una transazione di commitment firmata ma non confermata. Ogni transazione di commitment spende l'output multisig 2-of-2 e alloca il saldo secondo lo stato corrente. Alice detiene una transazione di commitment che invia il suo saldo a un output che controlla e invia il saldo di Bob a un output che Bob controlla — ma questa transazione non viene trasmessa. Viene tenuta off-chain come garanzia.

**Design asimmetrico del commitment (Poon-Dryja).** La transazione di commitment di Alice è diversa da quella di Bob. Nella versione di Alice, il suo output include un to_self_delay imposto da `OP_CHECKSEQUENCEVERIFY` (CSV) — tipicamente 144 blocchi (circa 24 ore). L'output di Bob nella transazione di commitment di Alice è immediatamente spendibile da Bob. Questa asimmetria è intenzionale: dà ad Alice il tempo di reagire se Bob tenta di trasmettere uno stato vecchio e revocato.

**Meccanismo di revoca.** Quando Alice e Bob concordano di aggiornare il saldo del canale, non si limitano a firmare una nuova transazione di commitment. Scambiano anche segreti di revoca che rendono la transazione di commitment precedente non spendibile. Se Alice successivamente tenta di imbrogliare trasmettendo un vecchio commitment a lei favorevole, Bob può usare il segreto di revoca per reclamare tutti i fondi del canale come penale.

**Chiusura cooperativa vs unilaterale.** Una chiusura cooperativa avviene quando entrambe le parti concordano di chiudere il canale. Firma e trasmettono una transazione di settlement concordata senza time lock — entrambe le parti ricevono i loro fondi immediatamente. Una chiusura unilaterale avviene quando una parte trasmette la propria ultima transazione di commitment senza la cooperazione dell'altra. La parte che trasmette deve attendere il to_self_delay (time lock CSV) prima di poter accedere ai propri fondi, mentre l'altra parte può reclamare i propri fondi immediatamente.

![Aggiornamenti del saldo del canale](media/wiki/payment-channels/channel-update.svg "Ogni pagamento in un canale crea una nuova transazione di commitment che aggiorna l'allocazione del saldo tra Alice e Bob. Le vecchie transazioni di commitment vengono revocate.")

## advanced

**Struttura della transazione di commitment.** Ogni transazione di commitment contiene due output primari: l'output to_local e l'output to_remote. L'output to_local restituisce i fondi alla parte che ha creato la transazione di commitment, gravati da un time lock CSV (il to_self_delay). L'output to_remote invia i fondi della controparte a un indirizzo che controlla, spendibile immediatamente.

Inoltre, le transazioni di commitment possono contenere output HTLC per pagamenti in transito instradati attraverso il canale. Ogni output HTLC è gravato sia da un time lock CLTV (la scadenza) che da un hashlock (il preimage del pagamento). La struttura garantisce che i fondi siano o reclamati dal destinatario previsto con il preimage, o restituiti al mittente dopo la scadenza del time lock.

**Derivazione del segreto di revoca.** La costruzione Poon-Dryja usa uno schema di revoca gerarchico. Ogni parte genera un segreto per-commitment usando un percorso di derivazione HD. Il segreto di revoca per il commitment N può essere memorizzato come il segreto per il commitment N-1 dopo che lo stato è stato aggiornato. Questo permette una finestra scorrevole di sicurezza: in qualsiasi momento, entrambe le parti possono revocare lo stato precedente rivelando il suo segreto di revoca.

La derivazione segue una gerarchia deterministica:
1. Il finanziatore genera un segreto di revoca base dal seed del canale
2. Ogni punto di commitment è derivato usando SHA256
3. Il segreto di revoca per lo stato N viene rivelato quando si passa allo stato N+1
4. La controparte memorizza questo segreto per costruire una transazione di penalità se necessario

**Flusso della transazione di penalità.** Se Alice trasmette una vecchia transazione di commitment (stato N invece dello stato corrente N+2), Bob lo rileva monitorando la blockchain. Bob ha 144 blocchi (la finestra to_self_delay) per rispondere. Costruisce una transazione di penalità che spende l'output to_local usando il segreto di revoca che Alice ha rivelato quando sono passati dallo stato N a N+1. La transazione di penalità invia tutti i fondi del canale — sia il saldo di Alice che quello di Bob — a Bob. Questo è il deterrente economico che rende l'imbroglio irrazionale.

**Limiti di dust.** Gli output HTLC al di sotto del limite di dust (tipicamente 546 satoshi per output standard) non sono inclusi nelle transazioni di commitment. Questo previene attacchi economici denial-of-service dove un HTLC minuscolo costerebbe più in commissioni per essere riscosso del suo valore. Il limite di dust viene negoziato tra i peer nell'handshake di apertura del canale.

**Riserva del canale.** Ogni peer mantiene una riserva del canale — un saldo minimo che non può essere speso. La riserva è tipicamente l'1% della capacità del canale. Questo garantisce che ogni transazione di commitment abbia valore sufficiente sia nell'output to_local che to_remote per rendere il meccanismo di penalità economicamente sostenibile. Se il saldo di una parte scende alla riserva, non può inviare ulteriori pagamenti finché il canale non viene rifornito.

**Costruzione interattiva del commitment.** Costruire una nuova transazione di commitment segue un flusso di messaggi preciso:
1. `update_add_htlc` / `update_fulfill_htlc` / `update_fail_htlc`: Modificano l'insieme di HTLC in sospeso
2. `commitment_signed`: L'iniziatore invia la propria firma per la nuova transazione di commitment, insieme al segreto di revoca per lo stato precedente
3. `revoke_and_ack`: Il risponditore accusa ricevuta inviando il proprio segreto di revoca per lo stato precedente e la propria firma per il nuovo commitment
4. Entrambe le parti ora detengono una transazione di commitment firmata valida per il nuovo stato

Questo ciclo sign-revoke-commit garantisce che in qualsiasi momento entrambe le parti abbiano una transazione di commitment valida per lo stato corrente e la capacità di penalizzare un imbroglio usando lo stato precedente.

**Flusso di messaggi per l'apertura del canale (BOLT 2).** Aprire un canale segue un protocollo strutturato:
1. `open_channel`: Il finanziatore invia i parametri del canale inclusi capacità, dust limit, to_self_delay e la funding pubkey
2. `accept_channel`: Il risponditore conferma con i propri parametri
3. `funding_created`: Il finanziatore fornisce i dettagli della transazione di funding e la propria firma per la prima transazione di commitment
4. `funding_signed`: Il risponditore fornisce la propria firma per la transazione di funding e la propria firma per la prima transazione di commitment
5. Entrambe le parti trasmettono la transazione di funding e attendono le conferme
6. `funding_locked`: Una volta che la transazione di funding raggiunge la profondità richiesta (tipicamente 3 conferme), entrambe le parti si scambiano `funding_locked` per segnalare che il canale è pronto per i pagamenti

Dopo `funding_locked`, il canale passa allo stato ready e può iniziare a instradare pagamenti.
