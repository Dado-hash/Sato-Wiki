---
id: wiki.threat-model
slug: threat-model
language: it
category: privacy-security
title: Modello di minaccia
description: La sicurezza e la privacy in Bitcoin dipendono da chi si vuole proteggere, quindi ogni difesa copre alcune minacce e ne lascia aperte altre.
coverImage: media/wiki/threat-model/threat-model-hero.svg
difficulty: base
readTimeMinutes: 5
tags:
  - Privacy
  - Sicurezza
  - Modello di minaccia
  - Opsec
related:
  - wiki.private-keys
  - wiki.common-input-ownership
  - wiki.address-reuse
  - wiki.tor
  - wiki.coinjoin
sources:
  - title: Secure your wallet
    url: https://bitcoin.org/en/secure-your-wallet
    author: Bitcoin.org contributors
  - title: Protect your privacy
    url: https://bitcoin.org/en/protect-your-privacy
    author: Bitcoin.org contributors
  - title: Privacy - Bitcoin Wiki
    url: https://en.bitcoin.it/wiki/Privacy
    author: Bitcoin Wiki contributors
  - title: CoinJoin - Bitcoin Optech topic
    url: https://bitcoinops.org/en/topics/coinjoin/
    author: Bitcoin Optech
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

Sicurezza e privacy in Bitcoin iniziano da una domanda che si tende a saltare: protezione da chi? Ogni difesa copre alcune minacce e ne lascia aperte altre. Un wallet che tiene le chiavi offline le protegge dal malware su un computer, ma non fa nulla contro un indirizzo pubblico che collega tutti i tuoi pagamenti. Nascondere il tuo indirizzo IP impedisce ai peer di registrare le tue connessioni, ma non nasconde il contenuto delle transazioni.

Due tipi di asset vanno protetti. Il primo sono le chiavi che possono firmare una spesa. Il secondo è la privacy di saldi e pagamenti, perché il registro è pubblico e permanente. Perdere la privacy non si può annullare, anche se nessuna moneta viene rubata.

Diverse parti possono fare da avversari: chi entra nel tuo computer, un ladro che trova il dispositivo, un servizio che custodisce le tue chiavi o vede le tue richieste, un osservatore della rete, un analista che raggruppa indirizzi sulla chain e chi ti conosce.

Tre esempi mostrano come cambiano le esigenze. Una freelance che pubblica un indirizzo per le donazioni vuole che estranei non vedano il reddito dell'intero indirizzo. Chi risparmia con un saldo importante ha soprattutto bisogno di chiavi che non stanno mai su un dispositivo connesso. Chi gestisce un nodo da casa vuole che i peer non conoscano l'indirizzo IP di casa. Ogni difesa ha un costo.

## medium

Un modello di minaccia è una descrizione breve ed esplicita di che cosa proteggi, da chi e a quale costo. La pagina sulla privacy della Bitcoin Wiki pone la domanda in modo diretto: pensa da che cosa ti stai nascondendo. Senza questo passaggio è facile adottare uno strumento che risolve un problema che non hai, oppure non vedere quello che hai davvero.

Gli asset sono di solito di due tipi. Prima vengono le chiavi. Chiunque scopra una chiave privata o un seed può spendere i fondi che controlla. Poi viene la privacy di saldi e pagamenti. Chiunque può vedere il saldo e la storia di qualsiasi indirizzo, e bitcoin.org fa notare che informazioni difficili da tracciare oggi possono diventare facili da tracciare in futuro, perché il registro è permanente.

Gli avversari differiscono per ciò che possono vedere. Il malware sul tuo computer può leggere file e tastiera. Un osservatore della rete può vedere quali indirizzi inviano transazioni alla rete peer-to-peer. Un servizio interrogato dal tuo wallet scopre quali indirizzi ti interessano. Un analista della chain lavora solo con dati pubblici, quindi si basa su ipotesi su come si comportano i wallet. Chi ti conosce può collegare il tuo indirizzo pubblicato alla tua identità attraverso una conversazione o altri registri. Ognuno vede una parte diversa della tua attività.

Anche le difese sono specifiche. Un backup del seed protegge dalla perdita del dispositivo, ma non da chi trova il dispositivo con il contenuto sbloccato. La cifratura del wallet protegge dal ladro, ma non può proteggere da keylogger hardware o software. Tor nasconde un indirizzo IP, ma non la transazione. Usare indirizzi nuovi rende più difficile collegare i pagamenti, ma non nasconde gli importi.

Le perdite si combinano. La Bitcoin Wiki descrive la data fusion: ogni perdita elimina alcuni candidati, e due perdite insieme ne possono eliminare molti più di una sola.

La buona pratica parte dal modello. Scrivi gli asset, gli avversari che ti interessano e il costo che accetti, poi scegli le voci che affrontano quelle minacce.

## advanced

Un modello di minaccia deve anche considerare quanto costa una difesa e chi può vedere i tuoi dati dopo che l'hai applicata. Un wallet che interroga un server remoto invia a quel server gli indirizzi di cui ha bisogno, quindi il server apprende parte della tua attività perché il wallet funzioni. Un nodo che si collega tramite Tor evita che i peer vedano il suo indirizzo IP, ma quei peer ricevono comunque le transazioni che inoltra. Una difesa contro un avversario può quindi rafforzarne un altro.

Gli avversari possono essere passivi o attivi. Un osservatore passivo legge dati pubblici e traffico di rete. Un avversario attivo può anche inviarti monete, far girare peer o controllare una controparte. La Bitcoin Wiki offre un esempio in cui un avversario gestisce sia il servizio dove si comprano le monete sia la destinazione che le riceve, così il solo registro collega i due. Una difesa pensata per osservatori passivi può non reggere contro uno attivo.

L'analisi della chain si basa su euristiche, cioè ipotesi su come le persone e i software di solito si comportano. L'ipotesi di common-input-ownership è una di queste. La Bitcoin Wiki nota che queste ipotesi possono essere sbagliate, e una sola ipotesi errata può unire persone non collegate in un unico cluster. Bitcoin Optech descrive il coinjoin come un modo per rendere difficile a parti esterne usare la storia delle transazioni per stabilire chi possiede quale moneta, cioè proprio la minaccia dell'analisi della chain. Un risultato dell'analisi è quindi una probabilità, non una prova, e può sbagliare in entrambe le direzioni.

Il tempo conta. Poiché il registro è permanente, un pagamento difficile da collegare oggi può diventare più facile da collegare quando saranno disponibili più dati o metodi migliori. Un modello di minaccia dovrebbe chiedersi per quanto tempo un'informazione deve restare privata, non solo se lo è adesso.

Il modello vale per entrambi i lati di un pagamento. Chi pubblica un indirizzo crea un collegamento con ogni futuro mittente che lo vede. Chi paga usando monete con una storia visibile può rivelare quella storia al destinatario. La Bitcoin Wiki osserva che la privacy richiede un cambiamento di comportamento, e che una rete perfettamente privata non aiuta chi pubblica il proprio nome reale accanto a un indirizzo di pagamento.

Un modello utile indica l'avversario, l'asset, l'orizzonte temporale e il costo accettato. Ogni voce successiva di questa categoria cambia almeno una di queste variabili.
