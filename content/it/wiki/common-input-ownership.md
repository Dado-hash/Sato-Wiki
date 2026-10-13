---
id: wiki.common-input-ownership
slug: common-input-ownership
language: it
category: privacy-security
title: Euristica common-input-ownership
description: L'ipotesi che tutti gli input di una transazione appartengano allo stesso proprietario, e il modo in cui l'analisi della chain la usa per raggruppare gli indirizzi.
coverImage: media/wiki/common-input-ownership/common-input-ownership-hero.svg
difficulty: advanced
readTimeMinutes: 4
tags:
  - Privacy
  - Analisi della chain
  - Transazioni
  - Euristiche
related:
  - wiki.utxo-model
  - wiki.transactions
  - wiki.address-reuse
  - wiki.coinjoin
  - wiki.threat-model
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: "A Fistful of Bitcoins: Characterizing Payments Among Men with No Names"
    url: https://cseweb.ucsd.edu/~smeiklejohn/files/imc13.pdf
    author: Sarah Meiklejohn, Marjori Pomarole, Grant Jordan, Kirill Levchenko, Damon McCoy, Geoffrey M. Voelker, Stefan Savage
    publishedAt: 2013-10-23
  - title: "BIP 78: Receiver-initiated PayJoin"
    url: https://github.com/bitcoin/bips/blob/master/bip-0078.mediawiki
    author: Nicolas Dorier
  - title: Common-input-ownership heuristic - Bitcoin Wiki
    url: https://en.bitcoin.it/wiki/Common-input-ownership_heuristic
    author: Bitcoin Wiki contributors
  - title: Payjoin - Bitcoin Optech topic
    url: https://bitcoinops.org/en/topics/payjoin/
    author: Bitcoin Optech
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

Una transazione può spendere più monete insieme. Ogni moneta è un output precedente controllato da una chiave. L'euristica common-input-ownership è l'ipotesi che tutti gli input di una transazione appartengano alla stessa persona o entità. È un'ipotesi ragionevole, perché un wallet di solito spende insieme più monete proprie quando nessuna moneta è abbastanza grande da coprire un pagamento.

Il whitepaper originale segnala già questo legame. Nella sezione sulla privacy, Satoshi Nakamoto osserva che le transazioni con più input rivelano necessariamente che quegli input avevano lo stesso proprietario, e che se un proprietario viene identificato, anche altre transazioni possono essere collegate a lui.

Il software di analisi della chain usa l'ipotesi per raggruppare gli indirizzi in cluster che probabilmente appartengono allo stesso utente. Un cluster non è una prova di proprietà, ma spesso è abbastanza forte da contare. La lezione pratica è semplice: quando spendi più monete in un solo pagamento, dici a osservatori esterni che quelle monete appartengono insieme.

Unire le monete può essere utile per ragioni pratiche, ma scambia privacy con comodità. Decidi quali monete sei disposto a mostrare come gruppo prima di spenderle insieme.

## medium

L'euristica diventa uno strumento quando si combina con il riconoscimento del resto. Un pagamento di solito ha un output di resto che restituisce il valore residuo al mittente. In uno studio del 2013 sui pagamenti, Meiklejohn e colleghi hanno prima raggruppato gli indirizzi che compaiono insieme come input, che chiamano Euristica 1. Poi hanno individuato gli indirizzi di resto monouso, cioè output che ricevono il resto e non vengono mai più usati, e li hanno collegati agli input (Euristica 2). Gli autori descrivono la seconda euristica come più complessa e molto meno sicura della prima.

Le due euristiche si rafforzano a vicenda. Il raggruppamento degli input collega gli indirizzi spesi insieme. Il riconoscimento del resto aggancia un nuovo output allo stesso cluster. Quando un cluster è grande, ogni nuova transazione che lo tocca aggiunge dettagli, quindi l'analisi tende a crescere nel tempo.

Gli autori hanno scelto deliberatamente un disegno prudente. Hanno preferito l'euristica più sicura che riuscivano a progettare, accettando un alto tasso di falsi negativi, cioè molti collegamenti veri vengono persi. Il motivo è che un singolo collegamento falso può unire utenti non collegati in un cluster molto grande. La Bitcoin Wiki riporta esempi di cluster errati prodotti dall'ipotesi. Le conclusioni tratte da essa sono quindi probabilistiche e possono sbagliare in entrambe le direzioni.

Per gli utenti comuni l'euristica spiega alcune pratiche. Pagare con monete provenienti da fonti diverse può collegare quelle fonti. Spendere una moneta piccola insieme a una grande le lega tra loro. Tenere separati i gruppi di monete limita quanto ogni pagamento rivela. Più spesso due gruppi vengono uniti, più è probabile che un osservatore li colleghi. Gli analisti quindi confrontano ogni cluster con altre prove, e un cluster che sembra solido può comunque contenere un errore.

## advanced

Alcuni disegni rompono l'ipotesi per costruzione. In un CoinJoin, più utenti concordano una transazione i cui input provengono da proprietari diversi. Ogni utente firma solo i propri input, e la transazione è valida solo quando sono presenti tutte le firme. In questo caso il cluster degli input è sbagliato per progetto, ed è proprio lo scopo della costruzione.

PayJoin, specificato in BIP 78, rompe l'ipotesi in un contesto a due parti. Il ricevente aggiunge uno dei propri input al pagamento del mittente e regola il proprio output, quindi la transazione contiene input di due parti. Il BIP elenca l'euristica common-input, insieme al riconoscimento del resto per tipo di script e per importi tondi, come euristiche che questo approccio invalida per il mittente. Osserva anche che un ricevente che partecipa può far sì che le euristiche inducano in errore un analista di proposito.

Transazioni con input di più parti compaiono anche in altre costruzioni collaborative. Se una transazione del genere viene raggruppata con l'ipotesi common-input, il risultato unisce persone che non hanno alcun legame reale. Questo è il lato dei falsi positivi dell'euristica. La Bitcoin Wiki raccoglie esempi reali in cui l'ipotesi ha prodotto cluster sbagliati, e gli analisti trattano i cluster come prove da valutare, non come fatti certi.

L'ipotesi descrive un comportamento, non una regola del protocollo. Le regole di consenso non richiedono che gli input abbiano lo stesso proprietario, quindi l'ipotesi è un'inferenza tratta dall'uso. Il whitepaper prevedeva che un certo collegamento sarebbe rimasto inevitabile per le transazioni con più input.

Per il mittente la questione riguarda il momento in cui spende. Se un pagamento spende monete provenienti da due fonti precedentemente separate, il registro pubblico registra che sono state spese insieme. Unire monete tenute separate, o combinare monete già mescolate, può annullare una misura di privacy presa in precedenza. La scelta di quali monete spendere insieme conta quindi quanto la scelta degli indirizzi. I wallet che permettono di selezionare le monete danno controllo su questa decisione.

Considera ogni cluster come una probabilità che dipende da come ogni wallet spende davvero le sue monete.
