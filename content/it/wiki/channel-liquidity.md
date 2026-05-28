---
id: wiki.channel-liquidity
slug: channel-liquidity
language: it
category: lightning network
title: Liquidità del Canale
description: La distribuzione dei fondi all'interno di un canale di pagamento che determina quanto può essere inviato o ricevuto e come i pagamenti vengono instradati attraverso la rete.
coverImage: media/wiki/channel-liquidity/liquidity-balance.svg
difficulty: advanced
readTimeMinutes: 8
tags:
  - Lightning Network
  - Liquidità
  - Saldo del Canale
  - Routing
  - Liquidità in Entrata
related:
  - wiki.lightning-network
  - wiki.payment-channels
  - wiki.routing-fees
  - wiki.lightning-service-providers
  - wiki.multipath-payments
sources:
  - title: "Mastering the Lightning Network — Chapter 6: Node Operations"
    url: https://github.com/lnbook/lnbook
    author: Andreas M. Antonopoulos, Olaoluwa Osuntokun, Rene Pickhardt
  - title: "BOLT #7 — P2P Node and Channel Discovery"
    url: https://github.com/lightning/bolts/blob/master/07-routing-gossip.md
    author: Lightning Network Specifications
  - title: "Lightning Network Routing and Liquidity"
    url: https://lightning.network/docs/
    author: Lightning Network Documentation
updatedAt: 2026-05-27T00:00:00Z
---

## base

La liquidità del canale si riferisce a quanto bitcoin si trova su ciascun lato di un canale di pagamento in un dato momento. Ogni canale ha una capacità totale fissa, stabilita all'apertura quando i fondi vengono bloccati in un output multisig 2-of-2 sulla blockchain Bitcoin. La capacità non cambia mai per l'intera vita del canale — solo la distribuzione si sposta.

**Capacità fissa, saldo variabile.** La somma dei saldi di entrambe le parti è sempre uguale alla capacità del canale. Quando Alice invia 0,1 BTC a Bob attraverso il loro canale da 1 BTC, il saldo di Alice diminuisce di 0,1 BTC e quello di Bob aumenta della stessa quantità. Il canale contiene ancora 1 BTC totale, ma il saldo si è spostato.

**Liquidità in uscita vs in entrata.** La liquidità in uscita è l'importo che puoi inviare — è il tuo lato del saldo del canale. La liquidità in entrata è l'importo che puoi ricevere — è il lato della controparte. Sono immagini speculari: se hai 0,7 BTC in un canale, puoi inviare fino a 0,7 BTC e ricevere fino a 0,3 BTC.

**L'analogia dell'altalena.** Immagina un'altalena con una tavola di lunghezza fissa. Quando un lato sale, l'altro scende della stessa identica quantità. La liquidità del canale funziona allo stesso modo: ogni satoshi che si sposta da Alice a Bob riduce la capacità di invio di Alice e aumenta quella di Bob. Il totale rimane costante.

![Distribuzione della Liquidità del Canale](media/wiki/channel-liquidity/liquidity-balance.svg "Due canali che mostrano come la stessa capacità totale sia suddivisa diversamente tra coppie di nodi. Alice può inviare 0,7 BTC a Bob ma Bob può inviare solo 0,3 BTC attraverso lo stesso canale.")

## medium

**Il vincolo della capacità fissa.** L'invariante di ogni canale di pagamento è: `saldo_A + saldo_B = capacità_canale`. Questo significa che la liquidità è un gioco a somma zero all'interno di un canale. Ogni pagamento in una direzione riduce la capacità in uscita del mittente dell'importo del pagamento e aumenta la capacità in uscita del ricevente.

**La direzione del pagamento cambia il saldo.** Se Alice invia 0,2 BTC a Bob in un canale da 1 BTC, il saldo passa da (0,7, 0,3) a (0,5, 0,5). Ora entrambi possono inviare 0,5 BTC. Se Alice invia altri 0,4 BTC, passa a (0,1, 0,9). Ora Alice può inviare solo 0,1 BTC, mentre Bob può inviare 0,9 BTC. Il canale è sbilanciato — favorisce una direzione rispetto all'altra.

**Il problema della liquidità in entrata.** Ricevere non è automatico su Lightning. Per ricevere un pagamento, hai bisogno di capacità in entrata — qualcun altro deve avere un canale verso di te con fondi sul suo lato. Questo è il problema più comune per i nuovi nodi Lightning.

**Perché la liquidità in entrata è difficile.** Quando apri un canale, lo finanzi interamente dal tuo wallet. Questo ti dà liquidità in uscita (puoi inviare), ma ti dà zero liquidità in entrata (nessuno può inviarti pagamenti attraverso quel canale finché l'altra parte non ha saldo sul suo lato). Non puoi semplicemente comprare o creare liquidità in entrata on-chain — deve arrivare da altri nodi che instradano pagamenti attraverso il tuo canale nella direzione opposta.

**Implicazioni per la topologia della rete.** I nodi ben connessi, o hub, accumulano naturalmente liquidità in entrata nel tempo perché i pagamenti li attraversano in entrambe le direzioni. Un nodo con molti canali bilanciati diventa un nodo di routing utile. I nodi piccoli o nuovi con pochi canali e tutto il saldo dalla loro parte faticano a ricevere perché nessun pagamento può entrare.

![Il Problema della Liquidità in Entrata](media/wiki/channel-liquidity/liquidity-problem.svg "Tre scenari che mostrano come la liquidità in entrata determini se un pagamento riesce o fallisce. Senza capacità in entrata, Bob non può ricevere nonostante abbia un canale aperto.")

## advanced

**La liquidità sul grafo della rete.** La Lightning Network è un grafo diretto dove ogni canale ha una capacità nota (pubblica negli annunci di canale secondo BOLT 7) ma la distribuzione esatta del saldo è privata — solo i due partner del canale la conoscono. Questo crea un problema fondamentale di incertezza per gli algoritmi di routing: devono indovinare quali canali hanno abbastanza liquidità in uscita per un dato pagamento.

**Pathfinding probabilistico.** Le implementazioni moderne di Lightning usano il pathfinding probabilistico per stimare la liquidità dei canali. Invece di assumere un saldo particolare, modellano il saldo di ogni canale come una distribuzione di probabilità. Quando un tentativo di pagamento riesce o fallisce, il nodo aggiorna le sue convinzioni sulla liquidità di ogni canale lungo il percorso. Più informazioni ha un nodo (da tentativi passati, gossip o probing), migliori diventano le sue stime di probabilità.

**L'insieme di incertezza.** Ogni nodo conosce esattamente due cose: i propri saldi dei canali (in uscita e in entrata per ogni canale diretto) e la capacità totale di ogni canale pubblico (dal protocollo gossip). Tutto il resto — la distribuzione del saldo dei canali tra altri nodi — è sconosciuto. Il pathfinding richiede di navigare questa incertezza: scegliere rotte dove la probabilità di liquidità in uscita sufficiente supera una certa soglia.

**Ribilanciamento circolare.** Quando un canale diventa troppo sbilanciato (tutto il saldo da un lato), un nodo può eseguire un ribilanciamento circolare. Il nodo invia un pagamento che fa un ciclo attraverso la rete e torna a sé stesso attraverso il canale sbilanciato, spostando il saldo nella direzione desiderata. Questo consuma commissioni di routing (ogni salto nel ciclo addebita la sua commissione) ma evita di chiudere e riaprire il canale. Il ribilanciamento circolare è un'area attiva di sviluppo di strumenti, con molte implementazioni di nodi che offrono strategie di ribilanciamento automatico.

**Splice-in e splice-out (BOLT 2).** Lo splice-in aggiunge più fondi a un canale esistente senza chiuderlo, aumentando la capacità del canale. Lo splice-out rimuove fondi da un canale, diminuendone la capacità. Entrambe le operazioni usano una nuova transazione di funding che sostituisce la precedente preservando lo stato del canale e gli HTLC. Lo splice-in è utile quando un canale ha bisogno di più capacità totale; lo splice-out è utile quando i fondi servono altrove. Nessuna delle due operazioni risolve direttamente il problema della liquidità in entrata — cambiano solo la capacità totale, non la distribuzione del saldo.

**Dual-funding (BOLT 2). L'apertura standard di un canale richiede che una parte finanzi l'intero canale. Il dual-funding permette a entrambe le parti di contribuire alla creazione del canale. Se Alice e Bob aprono un canale da 1 BTC con dual-funding, Alice può contribuire 0,6 BTC e Bob 0,4 BTC. Bob ora ha 0,4 BTC di liquidità in uscita e 0,6 BTC di liquidità in entrata dal momento in cui il canale si apre. Il dual-funding risolve metà del problema della liquidità in entrata alla creazione del canale, ma il saldo può ancora diventare sbilanciato nel tempo con i pagamenti.**

**LSP e liquidità in entrata come servizio.** I Lightning Service Provider (LSP) affrontano il problema della liquidità in entrata vendendola. Un LSP apre un canale verso di te, finanziandolo dal suo lato, dandoti capacità in entrata immediata. Paghi una commissione (tipicamente una commissione di setup una tantum più commissioni di routing) per questo servizio. Gli LSP sono essenziali per i wallet mobili e i nodi non di routing, che non possono acquisire facilmente liquidità in entrata attraverso la partecipazione organica alla rete.

**Canali JIT (Just-In-Time).** Un canale JIT viene aperto da un LSP su richiesta quando arriva un pagamento per un utente che non ha un canale diretto con il mittente. L'LSP rileva un pagamento in arrivo, apre un canale verso il destinatario, inoltra il pagamento e raccoglie le commissioni di routing. L'utente non deve gestire canali o liquidità — l'LSP lo gestisce in modo trasparente. I canali JIT sono un miglioramento chiave dell'esperienza utente per l'onboarding su Lightning.

**Annunci di liquidità e il mercato della liquidità.** Una proposta BOLT per gli annunci di liquidità permetterebbe ai nodi di pubblicizzare pubblicamente che vogliono comprare o vendere liquidità in entrata. Un mercato della liquidità permetterebbe ai nodi di scoprirsi reciprocamente, negoziare termini (commissione, durata, dimensione del canale) e aprire canali programmaticamente. Questa è un'area attiva di sviluppo che potrebbe ridurre significativamente l'attrito nell'acquisizione di liquidità in entrata.

**La riserva del canale (limite di polvere dell'1%).** Ogni canale ha una riserva, tipicamente l'1% della capacità del canale, che non può essere spesa. Questa riserva esiste per imporre un costo alla chiusura del canale: se una delle parti tenta di imbrogliare trasmettendo uno stato vecchio, perde l'intero saldo, inclusa la riserva. La riserva non è disponibile come liquidità in uscita o in entrata — è bloccata fino alla chiusura del canale. Per un canale da 1 BTC, 0,01 BTC sono riservati e 0,99 BTC sono utilizzabili. Gli algoritmi di routing e i calcoli del saldo devono tenere conto di questa riserva per evitare fallimenti di routing dovuti a liquidità utilizzabile insufficiente.
