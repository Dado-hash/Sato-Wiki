---
id: wiki.splicing
slug: splicing
language: it
category: lightning network
title: Splicing
description: Un'estensione del protocollo che consente di aggiungere o rimuovere fondi da un canale Lightning aperto senza doverlo chiudere e riaprire, utilizzando una singola transazione on-chain.
coverImage: media/wiki/splicing/splicing-flow.svg
difficulty: advanced
readTimeMinutes: 8
tags:
  - Lightning Network
  - Splicing
  - Gestione del Canale
  - BOLT 2
related:
  - wiki.lightning-network
  - wiki.payment-channels
  - wiki.channel-funding-transactions
  - wiki.commitment-transactions
  - wiki.channel-liquidity
sources:
  - title: "BOLT #2 — Peer Protocol for Channel Management (sezione Splicing)"
    url: https://github.com/lightning/bolts/blob/master/02-peer-protocol.md
    author: Lightning Network Specifications
  - title: "Proposta Splicing — Lightning Network"
    url: https://github.com/lightning/bolts/pull/863
    author: Lightning Network Contributors
  - title: "Mastering the Lightning Network — Splicing"
    url: https://github.com/lnbook/lnbook
    author: Andreas M. Antonopoulos, Olaoluwa Osuntokun, Rene Pickhardt
updatedAt: 2026-05-27T00:00:00Z
---

## base

Lo splicing consente di modificare la capacità di un canale Lightning senza doverlo chiudere.

Un canale Lightning viene normalmente creato con una capacità fissa. Se Alice apre un canale verso Bob con 1,0 BTC, quella capacità rimane bloccata per tutta la durata del canale. Per modificarla, l'approccio tradizionale richiede di chiudere il canale (una transazione on-chain), attendere le conferme, e poi aprire un nuovo canale (una seconda transazione on-chain). Il canale non è disponibile durante l'intero processo.

Lo splicing elimina questo overhead. Con lo splicing, Alice può aggiungere più bitcoin al canale (splice-in) o rimuovere bitcoin dal canale (splice-out) usando una singola transazione on-chain. Il canale rimane aperto e operativo durante tutto il processo — i pagamenti continuano a fluire mentre la transazione di splice viene confermata on-chain.

**Splice-in.** Alice aggiunge fondi per aumentare la capacità del canale. La transazione di splice crea un nuovo output di funding che sostituisce il precedente. Se il canale era di 1,0 BTC, uno splice-in di 0,5 BTC lo porta a 1,5 BTC. La distribuzione del saldo esistente tra Alice e Bob viene preservata e il canale rimane aperto.

**Splice-out.** Alice rimuove fondi dal canale, riducendone la capacità. Uno splice-out di 0,3 BTC da un canale da 1,0 BTC risulta in una capacità di 0,7 BTC. I fondi rimossi vanno a un indirizzo on-chain controllato da Alice.

![Flusso dello Splicing del Canale](media/wiki/splicing/splicing-flow.svg "Lo splicing consente di aggiungere (splice-in) o rimuovere (splice-out) fondi da un canale aperto senza chiuderlo. Senza splicing, il ridimensionamento richiede due transazioni on-chain.")

## medium

**Come funziona lo splicing.** Lo splicing si basa su un'idea semplice: la transazione di funding di un canale può essere sostituita da una nuova transazione di funding concordata da entrambe le parti. La nuova transazione spende il vecchio output multisig 2-of-2 e ne crea uno nuovo con un importo modificato. Lo stato del canale — inclusi tutti gli HTLC in sospeso e la distribuzione corrente del saldo — viene trasferito al nuovo output di funding.

**Flusso del protocollo.** Quando Alice avvia uno splice, entrambe le parti costruiscono una nuova transazione di funding con gli importi modificati. Alice firma la sua parte della nuova transazione di funding e Bob firma la sua. Una volta scambiate le firme, la nuova transazione di funding può essere trasmessa. Mentre viene confermata, il vecchio canale rimane pienamente operativo — i pagamenti possono ancora essere instradati attraverso di esso. Questa è una proprietà di sicurezza fondamentale: non c'è interruzione del servizio.

**Atomicità.** Se la transazione di splice non viene confermata (ad esempio, perché le fee erano troppo basse e viene rimossa dalla mempool), il vecchio canale continua invariato. Lo splice è atomico — o la nuova transazione di funding viene confermata e la capacità del canale viene aggiornata, o non cambia nulla. Entrambe le parti possono riprovare in sicurezza con fee rate modificate.

**Gestione delle fee.** La parte che avvia lo splice paga tipicamente la fee della transazione on-chain. La fee viene dedotta dai fondi del canale o pagata da un wallet esterno, a seconda dell'implementazione. Entrambe le parti devono concordare il fee rate prima di firmare la transazione di splice, poiché uno splice bloccato a causa di fee basse ritarderebbe l'aggiornamento della capacità.

**Casi d'uso.**
- Ricaricare un canale di routing: un operatore aggiunge capacità a un canale trafficato per aumentare le entrate di routing
- Prelevare profitti: un operatore rimuove i guadagni di routing senza chiudere il canale e interrompere i percorsi di pagamento attivi
- Ribilanciamento: regolare la capacità tra più canali per adattarsi ai cambiamenti nei modelli di pagamento

![Splicing vs Ridimensionamento Tradizionale del Canale](media/wiki/splicing/splicing-vs-closed.svg "Lo splicing richiede una transazione on-chain e nessun tempo di inattività del canale, rispetto all'approccio tradizionale che richiede chiusura, attesa, riapertura e ulteriore attesa.")

## advanced

**Il protocollo di splicing interattivo.** Il protocollo di splicing è definito in BOLT #2 e utilizza un insieme dedicato di messaggi scambiati tra i peer del canale:

1. `splice_init`: L'iniziatore propone uno splicing con la variazione di importo desiderata, i dettagli della nuova transazione di funding e il fee rate. Questo messaggio include una firma parziale per la nuova transazione di funding.
2. `splice_ack`: Il responder accetta la proposta di splicing, accetta il fee rate e fornisce la propria firma per la nuova transazione di funding.
3. `splice_locked`: Una volta che la nuova transazione di funding raggiunge la profondità di conferma richiesta (tipicamente 3 blocchi), entrambe le parti si scambiano `splice_locked` per segnalare che il canale può riprendere le operazioni normali con la nuova capacità.

Durante questo scambio, il canale rimane in uno stato speciale in cui sia la vecchia che la nuova transazione di funding sono valide. Il protocollo garantisce che in qualsiasi momento entrambe le parti abbiano una transazione di commitment di backup a cui possono ricorrere.

**Interazione con le transazioni di commitment durante uno splice.** Quando uno splice è in corso, il sistema dei numeri di commitment del canale viene influenzato. Ogni operazione di splice incrementa il numero di commitment e la nuova serie di transazioni di commitment fa riferimento al nuovo output di funding. Eventuali HTLC in sospeso al momento dello splice devono essere trasferiti alle nuove transazioni di commitment. Questo richiede che entrambe le parti concordino sull'insieme di HTLC non risolti prima che lo splice possa procedere.

Il protocollo gestisce questo richiedendo che tutti gli HTLC in volo vengano risolti o incorporati nelle nuove transazioni di commitment. Se ci sono HTLC non risolti che non possono essere trasferiti, lo splice deve attendere la loro risoluzione. Questo garantisce che nessun fondo venga perso durante la transizione tra gli output di funding.

**Splicing e dual-funding.** Lo splicing può essere combinato con il dual-funding, dove entrambe le parti contribuiscono con fondi al canale. In uno splice con dual-funding, sia Alice che Bob possono aggiungere o rimuovere fondi nella stessa transazione di splice. Questo è particolarmente utile per il ribilanciamento del canale tra peer — invece di inviare pagamenti avanti e indietro per spostare il saldo, entrambe le parti possono regolare i propri contributi in una singola operazione atomica.

In uno scenario di dual-funding, il protocollo di splice viene esteso per permettere a entrambe le parti di specificare i propri contributi. La transazione di funding include input da entrambi i lati e gli importi degli output riflettono il nuovo saldo desiderato. Questo richiede una negoziazione più complessa ma riduce il numero di transazioni rispetto a operazioni di splice separate.

**Relazione con i numeri di commitment.** Ogni operazione di splice reimposta il numero di commitment del canale. Il numero di commitment è un contatore monotonicamente crescente che traccia lo stato del canale. Dopo uno splice, il numero di commitment continua da dove era rimasto, assicurando che il meccanismo di revoca funzioni ancora correttamente. Le vecchie transazioni di commitment (pre-splice) vengono revocate usando lo schema di revoca standard Poon-Dryja.

**Considerazioni sulla sicurezza.** La transazione di splice deve essere firmata da entrambe le parti, proprio come la transazione di funding originale. Questo significa che nessuna delle due parti può forzare unilateralmente uno splice — è sempre un'operazione cooperativa. Se un peer diventa non reattivo durante il protocollo di splice, la parte iniziatrice può interrompere in sicurezza e continuare a usare il vecchio canale.

Tuttavia, lo splicing introduce una nuova superficie d'attacco: un peer malevolo potrebbe proporre uno splice con termini sfavorevoli (ad esempio, assegnando a sé stesso più saldo del canale). Il protocollo mitiga questo richiedendo a entrambe le parti di convalidare e concordare gli output esatti della nuova transazione di funding prima di firmare. Ogni parte verifica che il proprio saldo sia correttamente rappresentato e che la fee sia ragionevole.

**Splicing vs submarine swap.** Sia lo splicing che i submarine swap modificano il saldo on-chain di un nodo Lightning, ma funzionano diversamente:

- **Splicing** è peer-to-peer: solo i due partecipanti al canale sono coinvolti. I fondi rimangono all'interno della relazione di canale esistente.
- **Submarine swap** coinvolge un fornitore di servizi terzo che funge da intermediario tra la Lightning Network e la blockchain Bitcoin. Un submarine swap converte bitcoin on-chain in fondi Lightning (o viceversa) attraverso un meccanismo di escrow basato su HTLC.

Lo splicing è più privato (solo i peer del canale conoscono l'operazione) e non ha rischio di controparte oltre al peer del canale. I submarine swap introducono fiducia nel fornitore di swap (a meno che non si utilizzi un protocollo trustless).

**Integrazione LSP.** I Lightning Service Provider offrono sempre più spesso lo splicing come funzionalità premium. Un LSP può eseguire automaticamente uno splice-in quando il canale di un utente ha poca liquidità in uscita, o uno splice-out per trasferire le fee di routing al wallet on-chain dell'utente. Questo offre un'esperienza fluida in cui l'utente non deve mai gestire manualmente la capacità del canale. Gli LSP tipicamente applicano una piccola commissione per il costo della transazione on-chain più un margine di servizio.
