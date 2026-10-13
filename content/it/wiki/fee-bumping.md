---
id: wiki.fee-bumping
slug: fee-bumping
language: it
category: protocol
title: "Aumentare la fee: RBF e CPFP"
description: Due modi per alzare la fee effettiva di una transazione non confermata e bloccata, il replace-by-fee con una nuova versione in conflitto e il child-pays-for-parent con un figlio a fee alta.
coverImage: media/wiki/fee-bumping/fee-bumping-hero.svg
difficulty: base
readTimeMinutes: 5
tags:
  - Fee
  - RBF
  - CPFP
  - Mempool
related:
  - wiki.transaction-fees
  - wiki.fee-market
  - wiki.mempool
  - wiki.transactions
  - wiki.utxo-model
sources:
  - title: "BIP 125: Opt-in Full Replace-by-Fee Signaling"
    url: https://github.com/bitcoin/bips/blob/master/bip-0125.mediawiki
    author: David A. Harding
  - title: Bitcoin Core policy - mempool replacements
    url: https://github.com/bitcoin/bitcoin/blob/master/doc/policy/mempool-replacements.md
    author: Bitcoin Core contributors
  - title: Bitcoin Core 28.0 release notes
    url: https://github.com/bitcoin/bitcoin/blob/master/doc/release-notes/release-notes-28.0.md
    author: Bitcoin Core contributors
  - title: Bitcoin Core policy - packages
    url: https://github.com/bitcoin/bitcoin/blob/master/doc/policy/packages.md
    author: Bitcoin Core contributors
  - title: Bitcoin Optech - Child pays for parent (CPFP)
    url: https://bitcoinops.org/en/topics/cpfp/
    author: Bitcoin Optech
  - title: Bitcoin Optech - Package relay
    url: https://bitcoinops.org/en/topics/package-relay/
    author: Bitcoin Optech
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

Una transazione può bloccarsi quando la sua feerate è troppo bassa rispetto allo spazio nei blocchi che i miner stanno riempiendo. Resta nelle mempool in attesa di un blocco, e il mittente ha bisogno di un modo per alzare la fee senza ricominciare da capo. Ci sono due metodi comuni. Funzionano entrambi solo finché la transazione non è confermata.

Il replace-by-fee (RBF) invia una nuova transazione che spende almeno uno degli stessi input e paga una fee totale più alta. I nodi che accettano la sostituzione eliminano l'originale. Il mittente può farlo da solo, perché controlla i propri input e può ridurre l'output di resto per pagare la fee in più.

Il child-pays-for-parent (CPFP) procede dall'altro lato. Chi detiene un output della transazione bloccata lo spende in una nuova transazione figlia con una fee alta. Può farlo il destinatario di un pagamento, e può farlo anche il mittente se ha un resto da spendere. Un miner che valuta genitore e figlio insieme vede una feerate combinata più alta, quindi includere entrambi conviene.

Entrambi i metodi sono policy dei nodi, non regole di consenso. Un miner può includere qualsiasi transazione valida secondo le regole di consenso, indipendentemente da ciò che preferiscono i nodi che la inoltrano. I commercianti che accettano pagamenti non confermati devono tenere presente che il mittente potrebbe sostituire il pagamento, quindi attendere una conferma è la scelta sicura.

## medium

BIP 125 descrive la forma originale e opt-in di RBF. Una transazione segnala di poter essere sostituita impostando nSequence sotto 0xfffffffe su almeno un input. Una transazione può anche ereditare il segnale da un antenato non confermato che lo segnala. Una sostituzione deve spendere almeno un input dell'originale, può aggiungere un input non confermato solo se quell'input proviene da una delle transazioni originali, deve pagare una fee assoluta più alta della somma delle originali e deve pagare per la propria dimensione alla feerate incrementale di relay del nodo. Il numero di transazioni eliminate, inclusi i discendenti, è limitato a 100.

La policy attuale di Bitcoin Core mantiene l'idea ma non richiede più il segnale. Full RBF è disponibile come opzione dalla versione 24.0, e le release notes della 28.0 indicano che il default dell'impostazione mempoolfullrbf è passato da 0 a 1. Su un nodo con impostazioni predefinite, dalla versione 28.0 in poi vengono accettate sostituzioni per qualsiasi transazione non confermata, che sia segnalata o no. I nodi con mempoolfullrbf a 0 restano basati sul segnale. Il documento di policy elenca anche una regola sul feerate diagram, che si applica dalla versione 31.0 e richiede che la sostituzione migliori il feerate diagram della mempool.

Il CPFP dipende da come i miner valutano le transazioni: insieme ai loro antenati non confermati. Quindi un figlio con feerate alta può trascinare in un blocco un genitore a feerate bassa. La fee del figlio deve essere sufficiente a coprire il deficit del genitore oltre alla propria. La panoramica di Optech chiama questo ancestor feerate mining e osserva che il CPFP funziona solo finché una quota sufficiente di miner si comporta così.

I pacchetti sono il ponte tecnico. La policy dei pacchetti di Bitcoin Core valuta un figlio insieme ai suoi genitori, quindi un genitore che da solo paga troppo poco può essere accettato insieme a un figlio che paga abbastanza. Le regole richiedono pacchetti ordinati topologicamente. Optech descrive il package relay tra peer come proposta, quindi le due metà sono a stadi diversi.

## advanced

Le regole di sostituzione riguardano gli incentivi. Richiedere una fee assoluta più alta fa sì che un miner non guadagni meno includendo la sostituzione rispetto all'originale. Richiedere che la fee in più copra la dimensione della sostituzione alla feerate incrementale di relay impedisce a un attaccante di far trasmettere ai nodi molte sostituzioni minime, ciascuna con un solo satoshi in più. Il documento di policy registra queste motivazioni e aggiunge un limite sui cluster, così che una singola sostituzione non possa costringere un nodo a ricalcolare simultaneamente un insieme molto grande di transazioni in conflitto.

La regola sul feerate diagram va oltre. Una sostituzione deve migliorare in modo stretto il feerate diagram della mempool. Il documento di policy ne indica lo scopo: garantire che le fee dei blocchi futuri salgano dopo una sostituzione invece di scendere.

Il replacement ha anche una debolezza nota, il transaction pinning, in cui una catena di discendenti a basso valore viene usata per rendere costoso sostituire un originale. Il conteggio delle transazioni eliminate, discendenti inclusi, è ciò che i limiti vincolano. I wallet che costruiscono più transazioni non confermate concatenate devono tenerne conto.

Il CPFP lavora sulla feerate del pacchetto: la fee combinata di genitore e figlio divisa per la loro dimensione virtuale combinata. Il figlio deve pagare abbastanza da portare quella media al livello richiesto dai miner, e il costo ricade sul mittente. La formulazione di Optech è che un figlio con feerate alta rende i miner interessati a includere anche il genitore a feerate bassa.

Il fatto che entrambi i metodi siano policy è importante per i commercianti. Una sostituzione valida secondo le regole del nodo che la inoltra non viola il consenso, quindi la rete non ha alcuna regola che impedisca al mittente di cambiare il pagamento. Il rischio è pratico: un pagamento visto solo in mempool può essere sostituito o scartato. Full RBF elimina la protezione che il segnale offriva un tempo al destinatario. BIP 125 dice che un destinatario può scegliere di non considerare un pagamento come tale finché la transazione segnalata non è confermata. Lo stesso ragionamento vale per qualsiasi transazione non confermata, ora che la policy predefinita accetta le sostituzioni.

Poiché si tratta di policy dei nodi, i nodi possono differire. Un nodo può accettare una sostituzione che un altro rifiuta, e le mempool di nodi diversi non sono identiche. Nulla di questo cambia ciò che è un blocco valido. Influisce solo su quali transazioni arrivano a un blocco.
