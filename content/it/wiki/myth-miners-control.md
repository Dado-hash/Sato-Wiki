---
id: wiki.myth-miners-control
slug: myth-miners-control
language: it
category: myths
title: '"I miner controllano Bitcoin"'
description: "In parte vero: i miner scelgono quali transazioni valide entrano in un blocco e in che ordine, ma non possono cambiare le regole che i nodi applicano."
difficulty: base
readTimeMinutes: 5
tags:
  - Miti
  - Mining
  - Consenso
  - Governance
related:
  - wiki.mining
  - wiki.mining-pools
  - wiki.full-nodes
  - wiki.consensus-rules
  - wiki.soft-fork-signalling
  - history.segwit-activation
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: "BIP 148: Mandatory activation of segwit deployment"
    url: https://github.com/bitcoin/bips/blob/master/bip-0148.mediawiki
    author: Shaolin Fry
  - title: "BIP 91: Reduced threshold Segwit MASF"
    url: https://github.com/bitcoin/bips/blob/master/bip-0091.mediawiki
    author: James Hilliard
  - title: Bitcoin Optech - Pooled mining
    url: https://bitcoinops.org/en/topics/pooled-mining/
    author: Bitcoin Optech
  - title: Stratum V2 specification
    url: https://github.com/stratum-mining/sv2-spec
    author: Stratum V2 contributors
  - title: Bitcoin Wiki - Segregated Witness
    url: https://en.bitcoin.it/wiki/Segregated_Witness
    author: Bitcoin Wiki contributors
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

In parte vero. I miner scelgono quali transazioni valide entrano in ogni blocco e in che ordine, quindi influenzano cosa viene confermato e quando. Non stabiliscono però le regole. Ogni full node controlla ogni blocco rispetto alle regole di consenso, e un blocco che le viola viene rifiutato, qualunque sia l'hashrate che lo ha prodotto.

Pensa ai miner come a chi riempie un sacco della posta. Possono lasciare fuori una lettera, mettere alcune lettere per prime o trattenere il sacco per un po'. Non possono stampare nuovi francobolli, cambiare le regole postali o aprire la busta di qualcun altro. Ogni ufficio postale controlla il sacco prima di inoltrarlo. La maggioranza dei miner può riscrivere gli ultimi sacchi, quindi un pagamento appena inviato può essere annullato, e può rifiutarsi di trasportare certe lettere finché mantiene la maggioranza. Questi poteri sono reali, ma sono limitati e temporanei. Creare monete o spendere monete altrui non rientra in ciò che i miner possono fare. I limiti contano quanto i poteri, quindi entrambi sono trattati qui sotto. In breve: scelgono il contenuto dei blocchi, non le regole.

## medium

I miner costruiscono i template dei blocchi a partire dalle transazioni nella mempool, di solito ordinandole per fee rate. I pool spesso decidono il template per i propri membri. Con il design Stratum v1, usato dalla maggior parte dei pool, un membro riceve dal pool un template di header e coinbase e può non avere il permesso di cambiare le transazioni, quindi chi costruisce il template decide cosa viene incluso. Stratum V2 aggiunge un Job Declaration Protocol che permette a un miner di dichiarare il proprio insieme di transazioni.

I full node fanno l'altra metà del lavoro. Controllano proof of work, struttura dei blocchi, firme, regole degli script e il limite di ricompensa della coinbase, e rifiutano qualsiasi blocco che non supera i controlli. Un miner che trova un blocco che viola una regola ha speso elettricità per un blocco che nessun nodo onesto accetterà.

Una maggioranza di hashrate può comunque riorganizzare la storia recente. Il whitepaper di Bitcoin mostra che un attaccante che supera la chain onesta può cambiare solo le proprie transazioni, per riprendersi denaro speso di recente, e che la probabilità che un attaccante più lento recuperi cala in modo esponenziale man mano che si aggiungono blocchi. Lo stesso documento osserva che i nodi non accettano transazioni invalide, quindi un attaccante non può creare valore dal nulla né prendere denaro che non gli apparteneva.

L'attivazione di SegWit nel 2017 mostra la differenza tra segnalare e decidere. BIP 148 è stata scritta perché il deployment esistente di SegWit non era ancora entrato in lock-in entro il 1 agosto 2017. Proponeva che da quella data i nodi che la eseguivano rifiutassero ogni blocco che non segnalasse SegWit. BIP 91, scritta anch'essa nel 2017, proponeva una soglia di segnalazione dell'80 percento su una finestra di 336 blocchi. Il Bitcoin Wiki riferisce che SegWit si è attivata poco dopo il 1 agosto 2017. I segnali erano il meccanismo, ma la minaccia credibile di rifiuto è venuta dagli operatori dei nodi.

## advanced

La versione più forte dell'affermazione è la seguente. La sicurezza di Bitcoin si basa sulla proof of work, e la proof of work è controllata da chi ha più hashrate. L'ordinamento è potere: un operatore di pool che controlla il template può escludere transazioni, favorire le proprie e scegliere quale punta estendere.

La risposta ha argomenti seri, ma non è completa. L'obiezione più netta riguarda la censura. La voce Optech sul mining in pool descrive la disposizione comune di Stratum v1, in cui i membri non scelgono le transazioni di un template e il pool può rifiutare i loro tentativi di modificarlo. Stratum V2 offre una full-template mode, ma se i pool la adotteranno è una questione separata che la specifica non può risolvere. Una maggioranza può anche escludere transazioni per tutto il tempo in cui mantiene la maggioranza. La risposta equa è che l'esclusione è visibile, che le transazioni escluse possono essere minate da altri e che il costo ricade sul censore.

Una seconda obiezione riguarda gli utenti che non eseguono un full node. Il whitepaper nota che un verificatore semplificato può essere ingannato da transazioni fabbricate da un attaccante, finché l'attaccante domina la rete. Per questi utenti l'ipotesi di maggioranza onesta è l'unica difesa, e la chain che accettano è quella che il loro provider mostra loro. La risposta è che chiunque può eseguire un full node, il che è vero, ma non aiuta chi non lo fa mai.

L'episodio del 2017 sostiene la risposta e la complica. I miner hanno ritardato la segnalazione, e gli operatori dei nodi hanno usato BIP 148 per minacciare il rifiuto dei blocchi che non segnalavano. Quando la minaccia è diventata credibile, i miner hanno segnalato tramite BIP 91 e SegWit è entrata in lock-in. I critici possono sostenere con ragione che i miner erano il meccanismo di attivazione mentre la maggioranza economica era la leva. Entrambe le letture si adattano ai fatti.

L'affermazione diventerebbe vera se i miner potessero imporre cambiamenti di regole contro la scelta degli operatori dei nodi, cosa che richiederebbe che i nodi smettessero di validare o accettassero qualsiasi chain presentata da pochi pool. Sarebbe falsa se una maggioranza di hashrate tentasse di imporre una regola che i nodi rifiutano, e la rete seguisse i nodi. Se la concentrazione dei pool renda la censura praticabile per periodi lunghi è una questione aperta, che le misurazioni attuali non hanno chiarito.
