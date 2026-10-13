---
id: wiki.transaction-malleability
slug: transaction-malleability
language: it
category: protocol
title: Malleabilità delle transazioni
description: Come l'identificatore di una transazione poteva essere cambiato da un terzo senza invalidarla, e come SegWit ha eliminato il problema per le nuove spese.
difficulty: advanced
readTimeMinutes: 5
tags:
  - Malleabilità
  - Txid
  - Firme
  - SegWit
  - Payment channel
related:
  - wiki.transactions
  - wiki.segregated-witness
  - wiki.ecdsa
  - wiki.payment-channels
  - wiki.digital-signatures
sources:
  - title: "BIP 62: Dealing with malleability"
    url: https://github.com/bitcoin/bips/blob/master/bip-0062.mediawiki
    author: Pieter Wuille
  - title: "BIP 66: Strict DER signatures"
    url: https://github.com/bitcoin/bips/blob/master/bip-0066.mediawiki
    author: Pieter Wuille
  - title: "BIP 146: Dealing with signature encoding malleability"
    url: https://github.com/bitcoin/bips/blob/master/bip-0146.mediawiki
    author: Johnson Lau, Pieter Wuille
  - title: "BIP 141: Segregated Witness (Consensus layer)"
    url: https://github.com/bitcoin/bips/blob/master/bip-0141.mediawiki
    author: Eric Lombrozo, Johnson Lau, Pieter Wuille
    publishedAt: 2015-12-21
  - title: Transaction malleability
    url: https://en.bitcoin.it/wiki/Transaction_malleability
    author: Bitcoin Wiki contributors
  - title: Mt. Gox
    url: https://en.wikipedia.org/wiki/Mt._Gox
    author: Wikipedia contributors
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

Il txid di una transazione, cioè l'identificatore, è l'hash SHA-256 doppio dei suoi dati serializzati. La malleabilità significa che chi può vedere una transazione può cambiarne una parte, senza alcuna chiave privata, in modo che la transazione resti valida ma abbia un txid diverso. Le stesse monete si muovono, ma il software che segue il pagamento tramite il txid non trova più la transazione che si aspettava.

Questo conta perché i mittenti spesso seguono un pagamento tramite il suo txid. Se a essere confermata è la versione modificata, il software del mittente può cercare una transazione che non esiste e concludere che il pagamento è fallito. Alcuni sistemi costruiscono anche una seconda transazione che spende un output della prima, e quella seconda transazione si rompe quando cambia il txid della prima.

Prima di SegWit, la fonte principale del problema era la firma. I dati della firma facevano parte del calcolo del txid, e una firma poteva essere codificata in più di un modo valido. La finestra di rischio è il tempo prima della conferma, perché una volta confermata la transazione conta la versione presente nella chain.

SegWit ha eliminato il problema per le spese di output SegWit. Le loro firme stanno fuori dal calcolo del txid. Le transazioni legacy possono ancora essere modificate in questo modo.

## medium

Le fonti principali di malleabilità stanno nella firma e nello script. Una firma ECDSA ha una coppia di valori, r e s, e per ogni firma valida (r, s) anche la coppia (r, -s modulo l'ordine della curva) è valida per lo stesso messaggio. Chiunque può passare dall'una all'altra senza conoscere la chiave. Il software di riferimento di Bitcoin accettava inoltre firme non codificate in DER stretto, quindi la stessa firma poteva comparire in più forme di byte. Il BIP 66 ha reso il DER stretto una regola di consenso.

Anche i dati dello script offrono più modi per variare una transazione. Push di dati extra o altre operazioni in uno scriptSig possono essere aggiunti senza cambiare il significato dello script. Un elemento extra dello stack consumato da OP_CHECKMULTISIG può avere valori diversi. Il BIP 62 elencava sette fonti di malleabilità e proponeva sette regole per eliminarle, tra cui una regola low-S per le firme e una regola secondo cui l'elemento dummy deve essere vuoto.

Il BIP 62 non è stato adottato, e il suo stato è chiuso. Il BIP stesso riconosce che alcune forme di malleabilità non si possono eliminare con le sole regole di consenso. Il BIP 141 sostenne poi che spostare le firme fuori dal txid fosse una soluzione migliore dell'approccio delle firme canoniche del BIP 62.

Il BIP 141 ha risolto il problema spostando il witness fuori dal txid. Il txid è ora calcolato sulla transazione senza dati witness, quindi le modifiche alle firme non lo cambiano. Il witness resta comunque impegnato da un wtxid separato, che permette ai full node di verificare che i dati witness non siano stati alterati. Il risultato è che una spesa SegWit ha un txid stabile anche quando i byte della firma cambiano. Il txid copre quindi versione, outpoint, output e locktime, cioè le parti che determinano cosa fa la transazione.

## advanced

La malleabilità era costosa a causa delle catene di transazioni non confermate. Il BIP 146 lo descrive direttamente: per le transazioni non SegWit, la malleabilità della firma cambia il txid e invalida ogni transazione figlia non confermata che spende l'output modificato. Un pagamento che dipende da un altro pagamento non confermato può quindi fallire anche se nessuno ha perso le chiavi.

I payment channel rendevano il problema più serio. Il BIP 141 descrive un output di funding 2-di-2, con una transazione di spesa con timelock firmata prima della trasmissione della transazione di funding. Se la spesa è malleabile, una parte può non poter contare su di essa. Il BIP afferma che tali configurazioni non sono possibili con il BIP 62 come correzione, perché la transazione di spesa non potrebbe essere creata senza che entrambe le parti abbiano firmato prima quella di funding, e così una parte potrebbe bloccare i fondi a tempo indeterminato. La segregated witness ha eliminato questa dipendenza per gli input SegWit.

Il BIP 146 definisce altre due regole per le firme negli script. LOW_S richiede che il valore s stia nella metà inferiore dell'intervallo. NULLFAIL richiede che una firma fallita sia un array di byte vuoto. Il BIP osserva che il software di riferimento applica LOW_S come policy di relay alle transazioni legacy dalla versione 0.11.1, e descrive le regole come applicabili agli script pre-segregated witness e segregated witness. Policy di relay e consenso non coincidono: per le transazioni legacy, a fermare una transazione che viola la regola low-S è il comportamento di relay predefinito, non la validità del blocco.

Chi può modificare una transazione dipende dalla spesa. Un nodo di relay senza chiavi può cambiare una firma legacy, passando ad esempio all'altra forma valida del valore s. Con il BIP 141, il txid di una spesa SegWit non include affatto i dati della firma, quindi cambiare le firme lascia invariato il txid. Per gli script CHECKMULTISIG m-di-n, il BIP 141 osserva che la malleabilità richiede l'accordo di m detentori di chiavi, mentre con l'approccio del BIP 62 bastava un solo detentore.

Mt. Gox sospese tutti i prelievi di bitcoin nel febbraio 2014. In un comunicato del 10 febbraio 2014, la società attribuì il problema alla malleabilità delle transazioni, secondo Wikipedia. È la spiegazione della società stessa, riportata qui senza verifica indipendente.

Il software che segue i pagamenti non dovrebbe considerare definitivo un txid prima della conferma. Per le spese che usano solo output SegWit, il txid è stabile rispetto alle modifiche delle firme.
