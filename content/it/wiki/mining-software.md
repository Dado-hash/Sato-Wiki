---
id: wiki.mining-software
slug: mining-software
language: it
category: software
subcategory: mining-software
title: Software di mining
description: I livelli software usati nel mining Bitcoin, dal firmware dei miner e dal software dei pool fino ai protocolli che trasportano lavoro e template di blocco tra loro.
difficulty: advanced
readTimeMinutes: 5
tags:
  - Mining
  - Firmware
  - Stratum
  - Template di blocco
  - Mining Pool
related:
  - wiki.mining
  - wiki.mining-hardware
  - wiki.proof-of-work
  - wiki.miner-incentives
  - wiki.blocks
sources:
  - title: Stratum V2 project website
    url: https://stratumprotocol.org/
    author: Stratum V2 project
  - title: Stratum V2 Specification - Job Declaration Protocol
    url: https://github.com/stratum-mining/sv2-spec/blob/main/06-Job-Declaration-Protocol.md
    author: Stratum V2 contributors
  - title: Bitcoin Optech - Pooled mining
    url: https://bitcoinops.org/en/topics/pooled-mining/
    author: Bitcoin Optech
  - title: DATUM Gateway README
    url: https://github.com/OCEAN-xyz/datum_gateway
    author: Bitcoin Ocean, LLC
  - title: "BIP 22: getblocktemplate - Fundamentals"
    url: https://github.com/bitcoin/bips/blob/master/bip-0022.mediawiki
    author: Luke Dashjr
  - title: Braiins OS - Installation on S21 and S19 series
    url: https://academy.braiins.com/en/braiins-os/installation/install
    author: Braiins
updatedAt: 2026-10-13T00:00:00Z
reviewedAt: 2026-10-13
---

## base

Il software di mining è l'insieme dei programmi che sta tra l'hardware di mining e la rete Bitcoin. Ha tre livelli principali. Il primo è il firmware che gira sul miner stesso. Il firmware di serie arriva con il dispositivo, mentre firmware alternativi come Braiins OS possono essere installati su schede di controllo delle serie Antminer S19 e S21 supportate. Il secondo livello è il software del pool, che distribuisce il lavoro, accetta le share e tiene il conto del contributo di ciascun miner. Il terzo è il protocollo che collega miner e pool.

In un pool, i miner di solito non scelgono quali transazioni entrano nel blocco. Il pool fornisce il template di blocco, e il miner calcola l'hash degli header derivati da esso. Chi costruisce quel template decide quali transazioni vengono incluse, quindi la scelta di chi lo costruisce conta anche oltre l'efficienza.

Il protocollo storico per il lavoro di pool è Stratum, introdotto nel 2012. Stratum V2 ne è il successore, con connessioni cifrate e un disegno che permette ai miner di partecipare alla costruzione del template. Approcci più recenti, come DATUM, fanno costruire il template al nodo del miner.

Le regole di pagamento sono una scelta separata. I pool dividono le ricompense in modi diversi, e questa scelta cambia come il reddito di ogni miner varia da un giorno all'altro.

## medium

Un pool Stratum V1 invia a ogni miner un job. Il job contiene le parti dell'header del blocco che non cambiano, il prefisso e il suffisso della coinbase, il target di rete e un target per le share più facile di quello di rete. Il miner varia nonce ed extranonce della coinbase, calcola l'hash del risultato e invia qualunque header che soddisfi il target share. Un header che soddisfa anche il target di rete è un blocco completo, e il pool lo trasmette. Poiché il pool fornisce il job, il pool decide anche cosa va nella coinbase.

Stratum V2 mantiene questo ciclo di base ma cambia diverse cose. Il traffico tra miner e pool è cifrato e autenticato, il che blocca gli attacchi che sostituiscono le credenziali del pool per dirottare l'hashrate, e nasconde le share agli osservatori di rete che altrimenti potrebbero stimare la produzione di un miner. Il suo Job Declaration Protocol permette a un client lato miner di dichiarare un job personalizzato a un server lato pool, che gli assegna un token. La specifica descrive due modalità. In modalità coinbase-only, il pool vede la coinbase e le commissioni ma non le transazioni. In modalità full-template, il miner dichiara l'insieme delle transazioni.

Il template di blocco arriva da getblocktemplate, la RPC definita nel BIP 22. Un nodo restituisce i dati necessari a costruire un blocco candidato, e il software di mining costruisce l'header a partire da essi. Il BIP 23 estende la stessa chiamata per il mining in pool.

DATUM segue una strada diversa. Il DATUM Gateway chiede a un nodo locale i template di blocco, genera il lavoro per l'hardware di mining e invia i blocchi risolti alla rete. Un pool compatibile con DATUM coordina la divisione della ricompensa e non crea lavoro per il miner. Il gateway serve l'hardware tramite Stratum V1 con version rolling, e richiede un nodo che supporti getblocktemplate. Il suo README segnala che, nella versione attuale del protocollo, il pool valida ancora i blocchi.

## advanced

La costruzione del template è il punto in cui il software di mining tocca la resistenza alla censura. Il progetto Stratum V2 descrive alcuni grandi pool che oggi dominano lo spazio dei blocchi, a volte fungendo da proxy per altri pool, e nota che un pool può includere o escludere selettivamente le transazioni. Spostare la costruzione del template verso i miner serve a ridurre questo unico punto di controllo. La sua efficacia dipende da quanti miner costruiscono davvero i propri template.

Il Job Declaration Protocol divide il lavoro tra due ruoli. Il Job Declarator Client gira lato miner e dichiara job personalizzati. Il Job Declarator Server gira lato pool, assegna token, conferma le dichiarazioni e mantiene un proprio mempool tramite un nodo. La specifica afferma che un pool in modalità coinbase-only non può vedere quali transazioni sono nel template del miner, il che tutela la privacy del mempool del miner. Aggiunge anche che questa modalità espone il pool al caso in cui il miner dichiari una coinbase con commissioni diverse da quelle del template reale. La specifica paragona questo rischio al block withholding e indica mitigazioni, come prove che le commissioni appartengano a un template valido senza rivelarlo.

DATUM mostra la stessa tensione da un altro lato. Il suo README afferma che il vero miner è chi gestisce il nodo Bitcoin, non il pool, e che il pool coordina i pagamenti. Il progetto dichiara anche che il pool attuale valida i blocchi come misura di sicurezza durante i test, e che una versione futura del protocollo lo renderebbe quasi cieco al contenuto del template. Il README afferma inoltre che Bitcoin Core offre opzioni limitate di controllo sul template, che il progetto considera un fattore di centralizzazione.

Il firmware è un rischio a parte. Gira sulla scheda di controllo del miner, dove governa l'hashing e la connessione di rete verso il pool. URL del pool, credenziali e aggiornamenti del firmware arrivano al dispositivo lungo questo percorso. Il traffico Stratum V1 può essere letto da intermediari di rete, e il progetto Stratum V2 sostiene che cifratura e autenticazione impediscono di dirottare l'hashrate scambiando le credenziali. La cifratura protegge il collegamento, ma non rende affidabili né il pool né il firmware.

Le regole di pagamento aggiungono un ulteriore livello. Con il pay-per-share, il pool paga un importo fissato per ogni share e la varianza nel trovare blocchi passa al pool. Altri schemi pagano solo quando viene trovato un blocco.
