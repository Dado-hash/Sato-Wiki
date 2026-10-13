---
id: wiki.sighash
slug: sighash
language: it
category: protocol
title: Tipi di sighash
description: I flag sighash che decidono quali parti di una transazione una firma impegna, e come segwit e taproot hanno cambiato il digest che viene firmato.
coverImage: media/wiki/sighash/sighash-hero.svg
difficulty: advanced
readTimeMinutes: 4
tags:
  - Sighash
  - Firme
  - Transazioni
  - Taproot
related:
  - wiki.digital-signatures
  - wiki.transactions
  - wiki.segregated-witness
  - wiki.taproot
  - wiki.schnorr-signatures
  - wiki.ecdsa
sources:
  - title: Bitcoin Developer Guide - Transactions
    url: https://developer.bitcoin.org/devguide/transactions.html
    author: Bitcoin.org contributors
  - title: "BIP 143: Transaction Signature Verification for Version 0 Witness Program"
    url: https://github.com/bitcoin/bips/blob/master/bip-0143.mediawiki
    author: Johnson Lau
  - title: "BIP 341: Taproot: SegWit version 1 spending rules"
    url: https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki
    author: Pieter Wuille
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

Una firma in Bitcoin non copre sempre l'intera transazione. Ogni firma termina con un byte sighash che indica al verificatore quali parti sono state firmate. Il valore più comune, SIGHASH_ALL, impegna ogni input e ogni output. Se qualcuno cambia un importo, un indirizzo o un input dopo la firma, la firma non verifica più.

Gli altri flag lasciano spazio ad altri di proposito. SIGHASH_NONE firma gli input ma nessun output, quindi le destinazioni possono essere completate in seguito. SIGHASH_SINGLE firma gli input e solo l'output nella stessa posizione dell'input firmato. Il modificatore ANYONECANPAY restringe uno qualsiasi di questi flag al solo input firmato, così altre persone possono aggiungere input alla transazione.

In pratica chi firma decide quale parte della transazione resta bloccata e quale può essere completata da altri. La scelta dipende da quanto il firmatario si fida che il resto della transazione resti com'è. I wallet usano quasi sempre SIGHASH_ALL. Un normale pagamento da una persona a un'altra non ha motivo di permettere ad altri di modificarlo. Gli altri flag sono utili soprattutto quando più parti costruiscono insieme una transazione, firmando ciascuna solo la propria parte e lasciando che le altre aggiungano la loro.

## medium

Consideriamo una transazione in cui Alice spende un input e paga Carol. Con SIGHASH_ALL, la firma di Alice fissa il suo input e entrambi gli output. Bob non può cambiare l'importo che riceve Carol né aggiungere un output senza invalidare la firma di Alice.

Con SIGHASH_NONE, la firma di Alice fissa solo il suo input. Chi tiene l'input firmato può aggiungere gli output che preferisce. La Developer Guide descrive questo caso come una situazione in cui chiunque può cambiare dove vanno i satoshi, quindi è sicuro solo quando chi firma non si preoccupa della destinazione.

Con SIGHASH_SINGLE, la firma di Alice fissa il suo input e l'output con lo stesso indice. Gli altri output, come un output di resto aggiunto da un'altra parte, possono essere cambiati senza influire sulla sua firma. ANYONECANPAY aggiunge un'ulteriore libertà: la firma di Alice non fissa più gli altri input, quindi un estraneo può contribuire con un input. La Developer Guide osserva che SIGHASH_ALL con ANYONECANPAY permette a chiunque di aggiungere satoshi, ma non di cambiare quanti satoshi vengono inviati né dove.

Il SIGHASH_SINGLE legacy ha un bug. Se la transazione non ha un output con lo stesso indice dell'input firmato, il valore firmato è il numero 1 e non un hash della transazione. La Developer Guide dice che questo rompe lo schema di sicurezza. Poiché il valore firmato non dipende più dalla transazione, la firma non è legata alla transazione per cui è stata creata.

Il byte sighash fa parte della firma di ciascun input, quindi gli input della stessa transazione possono usare flag diversi. Un input può, per esempio, firmare con ALL mentre un altro firma con NONE. Ogni input protegge solo ciò che il proprio flag copre, quindi un flag forte su un input non protegge le parti che un altro input lascia aperte.

## advanced

Segwit versione 0 ha cambiato il digest con BIP 143. Nel digest legacy la quantità di dati sottoposta ad hash per ogni firma cresceva con la dimensione della transazione, quindi la verifica di tutte le firme cresceva con il quadrato del numero di firme. BIP 143 calcola tre hash condivisi, uno per gli outpoint, uno per i numeri di sequenza e uno per gli output, e li riusa tra gli input, rendendo il lavoro complessivo lineare. Il nuovo digest include anche l'importo dell'input speso. Un firmatario offline a cui viene fornito un importo sbagliato produce una firma non valida, anziché una firma valida per un altro valore.

Taproot ha cambiato di nuovo il digest, con BIP 341. Il messaggio ora impegna gli importi di tutti gli input e gli scriptPubKey di tutti gli output spesi, a meno che non sia impostato ANYONECANPAY. Il BIP spiega che così non si può ingannare chi firma sul valore speso o sulla fee. Il messaggio usa un solo SHA-256 dentro un tagged hash, invece del double SHA-256 precedente, e include un prefisso epoch di un byte che lascia spazio ad algoritmi di firma futuri.

Taproot definisce anche SIGHASH_DEFAULT, il valore 0x00. Firma l'intera transazione esattamente come SIGHASH_ALL, ma la firma è di 64 byte perché il byte sighash viene omesso. Una firma Schnorr di 65 byte che termina con 0x00 è invalida, perché consentirla permetterebbe a un terzo di trasformare una firma di 64 byte in una di 65 byte con un wtxid e una feerate diversi. Taproot rifiuta i tipi di hash non definiti, quindi sono validi solo 0x00, 0x01, 0x02, 0x03, 0x81, 0x82 e 0x83.

I flag legacy restano nel digest Taproot, quindi i quattro tipi base e il modificatore ANYONECANPAY mantengono il loro significato. Con SIGHASH_NONE o SIGHASH_SINGLE, i valori nSequence di tutti gli input vengono impegnati a meno che non sia impostato ANYONECANPAY, il che mantiene coerente la semantica delle sequenze con il resto del messaggio.

La ragione pratica principale per scegliere un flag più stretto è il coordinamento: chi firma cede il controllo di una parte della transazione perché un'altra persona possa completarla, e nello stesso gesto cede la protezione di quella parte. La Developer Guide indica SIGHASH_ALL come default. Gli impegni più rigorosi di BIP 143 e BIP 341 rendono quel default più sicuro, perché una firma copre gli importi e gli script di tutti gli input, a meno che non sia impostato ANYONECANPAY, e non solo dell'input che spende.
