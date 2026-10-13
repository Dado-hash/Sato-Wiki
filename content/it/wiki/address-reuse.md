---
id: wiki.address-reuse
slug: address-reuse
language: it
category: privacy-security
title: Riuso degli indirizzi
description: Ricevere più pagamenti su un solo indirizzo li collega tra loro nel registro pubblico, e i wallet moderni evitano il problema derivando un indirizzo nuovo per ogni pagamento.
difficulty: base
readTimeMinutes: 5
tags:
  - Privacy
  - Indirizzi
  - Wallet
  - Sicurezza
related:
  - wiki.bitcoin-addresses
  - wiki.hd-wallets
  - wiki.public-keys
  - wiki.common-input-ownership
  - wiki.threat-model
sources:
  - title: Protect your privacy
    url: https://bitcoin.org/en/protect-your-privacy
    author: Bitcoin.org contributors
  - title: "BIP 44: Multi-Account Hierarchy for Deterministic Wallets"
    url: https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki
    author: Marek Palatinus, Pavol Rusnak
    publishedAt: 2014-04-24
  - title: "BIP 352: Silent Payments"
    url: https://github.com/bitcoin/bips/blob/master/bip-0352.mediawiki
    author: josibake, Ruben Somsen, Sebastian Falbesoner
  - title: Silent payments - Bitcoin Optech topic
    url: https://bitcoinops.org/en/topics/silent-payments/
    author: Bitcoin Optech
  - title: Bitcoin Developer Guide - Transactions reference
    url: https://developer.bitcoin.org/reference/transactions.html
    author: Bitcoin.org contributors
  - title: Quantum resistance - Bitcoin Optech topic
    url: https://bitcoinops.org/en/topics/quantum-resistance/
    author: Bitcoin Optech
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

Un indirizzo che riceve più pagamenti li collega tra loro. Chiunque può vedere che lo stesso indirizzo ha ricevuto monete in momenti diversi, da mittenti diversi, e che quelle monete sono state spese in seguito. Il registro è permanente, quindi il collegamento non scade. Anche chi ti paga può vedere gli altri pagamenti allo stesso indirizzo, e così chiunque apprenda l'indirizzo da un sito, da una fattura o da un post sui social.

Il riuso ha anche un lato di sicurezza. Quando una moneta viene spesa, la transazione rivela la chiave pubblica che la controlla. Riusare un indirizzo mantiene i fondi sotto una chiave già pubblica. Oggi si tratta di un rischio teorico, perché spezzare quella chiave richiederebbe un computer quantistico, e nessuna macchina del genere ha dimostrato di riuscirci.

I wallet moderni evitano il riuso in automatico. Derivano un nuovo indirizzo di ricezione per ogni pagamento dallo stesso seed, quindi non devi tenere traccia di quali indirizzi hai usato. Pubblicare un indirizzo di proposito, ad esempio per le donazioni, è un caso comune in cui il riuso è difficile da evitare, ed è un compromesso che scegli consapevolmente.

## medium

Bitcoin.org consiglia di usare un nuovo indirizzo ogni volta che si riceve un pagamento, in modo che le transazioni non possano essere associate tra loro. Il consiglio è semplice, ma presuppone che sia il wallet a creare gli indirizzi per te.

I wallet deterministici gerarchici rendono questo pratico. Un solo seed genera un albero di chiavi, e il wallet consegna il prossimo indirizzo di ricezione non ancora usato ogni volta che serve. BIP 44 definisce la struttura degli account usata da molti wallet. Il suo address gap limit è fissato a 20: quando un wallet trova 20 indirizzi non usati di seguito, smette di cercare nella chain quelli usati. Questo conta quando un wallet viene ripristinato da un seed. Se sono stati consegnati molti indirizzi di fila senza ricevere pagamenti, il ripristino può fermarsi prima di arrivare a un indirizzo successivo che contiene fondi.

Alcuni casi restano difficili. Un indirizzo per le donazioni pubblicato su un sito o su un social network è pensato per ricevere molti pagamenti da persone a cui non si può chiedere un indirizzo nuovo. Bitcoin.org fa notare che pubblicare un indirizzo è una scelta poco privata, a meno che tu non voglia ricevere donazioni pubbliche con piena trasparenza.

BIP 352 descrive i silent payment, un'alternativa per gli indirizzi statici. Il ricevente pubblica un solo indirizzo. Ogni mittente deriva un output unico per il proprio pagamento da uno dei suoi input e dall'indirizzo del ricevente, e il ricevente scansiona la blockchain per trovare gli output che gli appartengono. Il BIP afferma che i pagamenti allo stesso indirizzo non sono collegabili da un osservatore esterno e che non serve pubblicare notifiche on-chain. Il compromesso è il costo della scansione. Bitcoin Optech nota che la scansione è più onerosa dal punto di vista computazionale rispetto alla ricerca di script nell'insieme UTXO, cioè il modo in cui i wallet normali trovano i propri output. Il supporto dipende dal software del wallet, quindi verificalo prima di affidartici.

## advanced

Il riuso non unisce solo pochi pagamenti. Collega ogni output inviato alla stessa chiave con ogni input speso da quella chiave, quindi il grafo delle transazioni intorno a quell'indirizzo diventa un unico registro connesso. Gli analisti parlano di identity collapse: una volta noto un indirizzo collegato, il registro collega gli altri a esso.

La questione della sicurezza discende dagli stessi dati. Un output basato su chiave rivela la sua chiave pubblica quando viene speso. Il transaction reference della Bitcoin Developer Guide descrive OP_CHECKSIG come un'operazione che consuma una firma e una chiave pubblica completa, e gli script di firma inseriscono entrambe nello stack. Dopo, un indirizzo da cui si è già speso e che contiene ancora fondi è controllato da una chiave pubblica. Bitcoin Optech afferma che le chiavi pubbliche usate da ECDSA sono vulnerabili all'algoritmo di Shor su un computer quantistico idealizzato, e che lo stesso vale per le chiavi pubbliche delle firme Schnorr. Esistono alternative resistenti al quantum, ma usano chiavi e firme molto più grandi. Il riuso mantiene quindi i fondi esposti più a lungo, ed è per questo che un indirizzo nuovo per ogni pagamento è un'abitudine più sicura.

I silent payment, specificati in BIP 352, affrontano il lato della privacy senza interazione. Il ricevente pubblica un indirizzo statico composto da una chiave di scansione e una chiave di spesa. Un mittente che possiede un input con una chiave utilizzabile deriva un segreto condiviso tramite un'operazione su curva ellittica e crea un output per una chiave unica. Il ricevente calcola lo stesso segreto a partire dalle chiavi pubbliche sommate degli input e dalla sua chiave di scansione, e individua gli output corrispondenti. Gli obiettivi di sicurezza del BIP includono che osservatori esterni non possano collegare i pagamenti all'indirizzo, che non serva interazione tra mittente e ricevente, e che le transazioni siano indistinguibili da quelle ordinarie.

I silent payment non sono gratuiti. La scansione richiede lavoro per ogni transazione che potrebbe pagare l'indirizzo, e l'uso in contesti collaborativi come il coinjoin è stato lasciato a lavori futuri nella sintesi di Optech. I wallet devono implementare sia il lato di invio sia quello di scansione. Un nuovo indirizzo generato da un wallet standard resta la forma di protezione più semplice per la maggior parte degli utenti.

Il riuso interagisce anche con altre euristiche. Un indirizzo che riceve più pagamenti rende il raggruppamento degli input e il riconoscimento del resto più affidabili per un analista.
