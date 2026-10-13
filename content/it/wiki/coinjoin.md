---
id: wiki.coinjoin
slug: coinjoin
language: it
category: privacy-security
title: CoinJoin
description: Un modo per far costruire insieme a più utenti una sola transazione, così che osservatori esterni non possano facilmente associare ogni input al proprio output.
difficulty: advanced
readTimeMinutes: 5
tags:
  - Privacy
  - CoinJoin
  - Transazioni
  - Set di anonimato
related:
  - wiki.common-input-ownership
  - wiki.address-reuse
  - wiki.transaction-fees
  - wiki.threat-model
  - wiki.transactions
sources:
  - title: "CoinJoin: Bitcoin privacy for the real world"
    url: https://bitcointalk.org/index.php?topic=279249.0
    author: Gregory Maxwell
    publishedAt: 2013-08-22
  - title: CoinJoin - Bitcoin Optech topic
    url: https://bitcoinops.org/en/topics/coinjoin/
    author: Bitcoin Optech
  - title: Payjoin - Bitcoin Optech topic
    url: https://bitcoinops.org/en/topics/payjoin/
    author: Bitcoin Optech
  - title: CoinJoin - Bitcoin Wiki
    url: https://en.bitcoin.it/wiki/CoinJoin
    author: Bitcoin Wiki contributors
  - title: "BIP 78: Receiver-initiated PayJoin"
    url: https://github.com/bitcoin/bips/blob/master/bip-0078.mediawiki
    author: Nicolas Dorier
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

Il CoinJoin è un modo per far costruire insieme a più persone una sola transazione Bitcoin, così che un osservatore esterno non possa facilmente capire quale input ha pagato quale output. Ogni partecipante apporta monete e riceve un nuovo output. Il risultato sembra una transazione con molti input e molti output, e il registro pubblico non mostra quale output appartenga a quale partecipante.

Gregory Maxwell ha proposto l'idea nel 2013 sul forum bitcointalk. L'osservazione chiave è che le firme sugli input sono indipendenti tra loro. I partecipanti possono concordare l'insieme di input e output, firmare separatamente i propri input e unire le firme. La transazione non è valida finché non ci sono tutte le firme, quindi nessun partecipante può prendere le monete degli altri.

La privacy nasce dall'ambiguità. Se più output hanno lo stesso importo, un osservatore può solo dire che uno qualsiasi di essi potrebbe provenire da un input di quell'importo. Più grande è il gruppo di output indistinguibili, più grande è il set di anonimato. Una transazione con due partecipanti offre poca protezione. Una con molti partecipanti, o più round uno dopo l'altro, ne offre molta di più.

Il CoinJoin non nasconde che la transazione è stata unita. Rende più difficile stabilire il collegamento tra un input e un output. Ha anche dei costi: fee, tempistiche e piccoli errori possono annullarne il beneficio.

## medium

Nella proposta di Maxwell, i partecipanti concordano una dimensione uniforme per gli output, e ognuno fornisce input che coprono almeno quella dimensione. La transazione ha quindi un output di quella dimensione per partecipante, più output di resto per chi ha apportato più del necessario. Ogni partecipante firma la stessa transazione. Maxwell sottolineava che nessuno rischia un furto in nessun momento, perché nessuno firmerà una transazione che non gli sta bene.

I partecipanti devono comunque trovarsi. Nella forma più semplice si collegano direttamente, per esempio su una rete anonima come Tor, e negoziano la transazione. In quel caso ogni partecipante conosce la corrispondenza tra input e output, perché tutti vedono gli stessi dati. Un disegno più comune usa un coordinatore, un server che raccoglie input e indirizzi di output, costruisce la transazione e chiede a ciascun partecipante di firmare. Il coordinatore conosce la corrispondenza tra input e output, ma non può spendere le monete, perché la firma di ogni partecipante copre solo una transazione che il partecipante ha accettato.

I coordinatori differiscono per ciò che vedono. Alcuni conoscono la corrispondenza e i dettagli di connessione di ogni partecipante. Alcuni disegni sono costruiti in modo che nemmeno il coordinatore conosca la corrispondenza. Maxwell descrisse come approccio di questo tipo gli indirizzi di output resi ciechi, in cui i partecipanti ricevono token firmati che possono poi scambiare con indirizzi senza che il server veda il collegamento.

Bitcoin Optech descrive l'obiettivo come rendere difficile a parti esterne usare la storia delle transazioni per stabilire chi possiede quale moneta. Il risultato è un insieme di possibili corrispondenze, non una certezza, ed è meno utile quando importi o tempi rendono alcune corrispondenze ovvie.

Il CoinJoin è una tecnica di privacy sul grafo delle transazioni. Non cambia le regole di consenso e non nasconde il tuo indirizzo IP, quindi di solito si combina con misure di privacy della rete come Tor. La voce su Tor spiega questa parte.

## advanced

Il set di anonimato di una singola transazione CoinJoin è limitato dal numero di partecipanti, perché un osservatore può restringere un output solo agli input dello stesso round. Maxwell ha notato che il set può crescere oltre questo limite. Se più round sono concatenati, così che gli output di un round alimentano il successivo, un collegamento lungo l'intera sequenza diventa molto più difficile da seguire. Come esempio ha descritto tre stadi di transazioni con 32 input ciascuna, che permetterebbero a uno qualsiasi dei 1024 output finali di provenire da uno qualsiasi dei 1024 input originali usando 96 transazioni.

Gli importi uguali degli output sono centrali nel disegno. Quando ogni output di un round ha la stessa dimensione, un output può essere confrontato solo con altri output di quella dimensione. Il resto e gli output di dimensioni diverse restringono l'insieme, quindi il disegno degli importi incide sulla privacy tanto quanto il numero di partecipanti.

La fiducia dipende dal disegno. Un coordinatore vede la corrispondenza nei disegni in cui costruisce la transazione, e decide quali input vengono accettati in un round. I protocolli che usano token ciechi riducono ciò che il coordinatore apprende, al prezzo di maggiore complessità. I disegni senza un coordinatore unico, come il modello maker e taker usato da Joinmarket, spostano il coordinamento sui partecipanti. In ogni caso un partecipante firma solo ciò che ha accettato, quindi nessuno cede il controllo delle proprie monete per partecipare.

I costi sono reali. Ogni partecipante paga una quota della fee, e alcuni servizi aggiungono una fee di coordinamento. Tutti gli input devono essere disponibili nello stesso momento, quindi un round può fallire se un partecipante si ritira, e ritentare crea schemi temporali che un osservatore può studiare. Un partecipante deve inoltre avere una moneta della dimensione giusta quando il round parte.

Gli errori dopo il mixing possono annullare il beneficio. Se un output mescolato viene speso in seguito insieme a una moneta non mescolata, l'ipotesi common-input li collega di nuovo.

PayJoin, specificato in BIP 78, è una variante a due parti. Il ricevente apporta uno dei propri input e regola il proprio output, quindi la transazione non ha più lo schema di input di un unico proprietario su cui fanno affidamento gli analisti. Il ricevente pubblica un endpoint PayJoin in un URI BIP 21, e il mittente dovrebbe contattarlo solo tramite un trasporto autenticato e cifrato. Il suo set di anonimato è limitato alle due parti.
