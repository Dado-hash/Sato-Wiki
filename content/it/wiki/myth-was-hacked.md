---
id: wiki.myth-was-hacked
slug: myth-was-hacked
language: it
category: myths
title: '"Bitcoin è stato hackerato"'
description: "In parte vero: exchange e wallet sono stati violati e il software ha avuto bug seri, ma nessun difetto noto ha permesso di spendere monete senza le loro chiavi."
difficulty: base
readTimeMinutes: 5
tags:
  - Miti
  - Sicurezza
  - Exchange
  - Bug software
related:
  - wiki.consensus-rules
  - wiki.forks-and-soft-forks
  - wiki.self-custody
  - wiki.threat-model
  - history.mtgox-collapse
  - history.value-overflow-incident
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: "BIP 50: March 2013 Chain Fork Post-Mortem"
    url: https://github.com/bitcoin/bips/blob/master/bip-0050.mediawiki
    author: Gavin Andresen
    publishedAt: 2013-03-20
  - title: Bitcoin Core - Disclosure of CVE-2018-17144
    url: https://bitcoincore.org/en/2018/09/20/notice/
    author: Bitcoin Core contributors
    publishedAt: 2018-09-20
  - title: Bitcoin Wiki - Value overflow incident
    url: https://en.bitcoin.it/wiki/Value_overflow_incident
    author: Bitcoin Wiki contributors
  - title: Bitcoin Wiki - Mt. Gox
    url: https://en.bitcoin.it/wiki/Mt._Gox
    author: Bitcoin Wiki contributors
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

In parte vero, e la domanda utile è quale parte. Il protocollo non è stato hackerato nel senso che qualcuno abbia falsificato firme o speso monete senza le loro chiavi. Ma il software ha avuto bug seri, e i servizi costruiti intorno a bitcoin, come exchange e wallet online, sono stati violati molte volte, con clienti che hanno perso fondi.

Pensa a tre livelli. Il protocollo è l'insieme delle regole. Il software è il programma che le implementa. I servizi sono gli exchange e le società di wallet che custodiscono chiavi o saldi di altre persone. Un'intrusione in un servizio è un furto ai danni dei suoi clienti e non cambia il protocollo. Un bug nel software può essere più grave. Nel 2010 un difetto ha permesso a una transazione di creare molte più monete di quelle consentite dalle regole, e la rete è stata corretta in fretta. Bug del genere sono stati trovati e risolti tramite segnalazione responsabile e aggiornamenti. L'affermazione corretta è che software e servizi possono fallire e che i fallimenti sono costati denaro alle persone. L'affermazione sbagliata è che un estraneo possa prendere bitcoin a un detentore che custodisce le proprie chiavi.

## medium

I tre livelli richiedono risposte separate. Il protocollo è ciò che i full node applicano: struttura dei blocchi, proof of work, firme, script e limite di emissione. Una transazione con una firma falsificata viene rifiutata, e nel protocollo nulla sposta monete senza la presentazione delle chiavi. Exchange e wallet custodiali sono diversi. Quando una società detiene le chiavi, un attaccante che compromette la società può prenderle, e il cliente ha un diritto solo verso la società. Mt. Gox è un caso noto. Nel giugno 2011 un attaccante ha usato credenziali sottratte dal computer compromesso di un revisore e ha usato il software stesso dell'exchange per vendere bitcoin che non possedeva, facendo scendere per un certo tempo il prezzo visualizzato. L'exchange è poi collassato nel febbraio 2014.

Il secondo livello è quello dei bug software. Nel marzo 2013 un blocco con più input di transazione di quanti alcuni nodi più vecchi sapessero gestire ha causato uno split della chain. I nodi con software precedente alla 0.8 hanno rifiutato il blocco, mentre i nodi 0.8 lo hanno accettato. BIP 50, scritta in seguito, spiega che la causa era un limite di lock di un database che era diventato di fatto una regola di consenso. Miner e pool sono tornati a versioni precedenti e lo split si è risolto.

Nel settembre 2018 Bitcoin Core ha reso pubblica la CVE-2018-17144, un difetto nel controllo che impedisce a una transazione di spendere due volte lo stesso input. La comunicazione dichiara che si trattava di una vulnerabilità critica di inflazione, cioè un miner avrebbe potuto aumentare l'offerta. La correzione è stata rilasciata in Bitcoin Core 0.16.3 e 0.17.0rc4 il 18 settembre 2018.

Il value overflow del 2010 appartiene alla stessa famiglia: un blocco ha creato monete tramite una somma che ha superato il limite numerico, e una correzione è stata rilasciata in poche ore.

La lezione pratica riguarda la custodia. Dove il detentore controlla le chiavi, le protezioni del protocollo valgono per quelle monete. Dove una società detiene le chiavi, conta la sicurezza della società.

## advanced

La versione più forte dell'affermazione è che bitcoin è sicuro solo quanto il software e il servizio più debole intorno a esso. Se un exchange detiene gran parte del denaro che le persone usano, una sola intrusione sposta un valore elevato. Se il software può inflazionare l'offerta tramite un bug, la garanzia sull'offerta dipende da codice che può sbagliare.

La risposta seria concede gran parte di questo e lo restringe. Un guasto del protocollo è un guasto delle regole che ogni nodo applica. Nessuno dei casi noti ha permesso di spendere le monete di un detentore senza la sua chiave. Il whitepaper fonda la proprietà sulle firme digitali: ogni trasferimento è autorizzato da una firma sulla transazione e sulla chiave pubblica del nuovo proprietario. Una firma falsificata fallisce la validazione in ogni full node.

L'obiezione a questa risposta è che "nessuno ha speso monete senza chiavi" è un test ristretto. Un bug che crea monete diluisce tutti i detentori, il che è una perdita anche se nessuna chiave viene toccata. Uno split della chain può lasciare valida per un po' una doppia spesa da un lato. BIP 50 registra una grande doppia spesa durante lo split del 2013, compiuta da qualcuno che stava sperimentando se fosse possibile. La risposta replica che la diluizione richiede comunque un bug, e che i bug vengono intercettati da test e segnalazioni. Il critico risponde che l'intercettazione è dipesa da persone che si trovavano a guardare nel momento giusto.

I servizi sono un discorso a parte. Gli exchange custodiali e i wallet non fanno parte del protocollo, e le loro perdite non sono una prova che il protocollo sia stato hackerato. Resta però la domanda pratica di quanto denaro detenuto dalle persone si trovi sotto chiavi altrui. Quella quota dipende dalle scelte degli utenti e varia da persona a persona e da periodo a periodo, quindi qui non si può dare alcuna cifra generale.

L'affermazione diventerebbe vera in senso stretto se un attaccante potesse spendere le monete di un detentore senza la sua chiave, per esempio tramite la rottura dello schema di firma o un bug di consenso che salti i controlli sulle firme. In quel senso resta falsa finché la verifica delle firme regge. Diventa ampiamente vera nella pratica se la maggior parte dei fondi si trova presso custodi la cui sicurezza cede spesso. Come affermazione sul disegno del protocollo è falsa, perché i guasti noti sono stati bug nel codice, non un difetto nel modello di proprietà.
