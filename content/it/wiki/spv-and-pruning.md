---
id: wiki.spv-and-pruning
slug: spv-and-pruning
language: it
category: protocol
title: SPV e nodi pruned
description: Due modi per usare Bitcoin senza conservare l'intera chain, un light client che verifica gli header e un full node pruned che valida tutto ma conserva solo i file dei blocchi recenti.
coverImage: media/wiki/spv-and-pruning/spv-and-pruning-hero.svg
difficulty: base
readTimeMinutes: 5
tags:
  - SPV
  - Pruning
  - Light Client
  - Prove di Merkle
related:
  - wiki.full-nodes
  - wiki.merkle-trees
  - wiki.proof-of-work
  - wiki.software-wallets
  - wiki.peer-to-peer-network
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: Bitcoin Developer Guide - Operating Modes
    url: https://developer.bitcoin.org/devguide/operating_modes.html
    author: Bitcoin.org contributors
  - title: "BIP 37: Connection Bloom filtering"
    url: https://github.com/bitcoin/bips/blob/master/bip-0037.mediawiki
    author: Mike Hearn, Matt Corallo
  - title: "BIP 157: Client Side Block Filtering"
    url: https://github.com/bitcoin/bips/blob/master/bip-0157.mediawiki
    author: Olaoluwa Osuntokun, Alex Akselrod, Jim Posen
  - title: "BIP 159: NODE_NETWORK_LIMITED service bit"
    url: https://github.com/bitcoin/bips/blob/master/bip-0159.mediawiki
    author: Jonas Schnelli
  - title: Bitcoin.org - Running a full node (pruning)
    url: https://bitcoin.org/en/full-node
    author: Bitcoin.org contributors
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

Un full node scarica ogni blocco e controlla da sé ogni regola. Esistono due modi più leggeri di usare Bitcoin, e spesso vengono confusi: un client SPV conserva solo gli header dei blocchi, mentre un nodo pruned controlla tutto ma elimina i vecchi dati dei blocchi. Risolvono problemi diversi e si fidano di cose diverse.

Un client SPV, descritto nella sezione 8 del whitepaper di Bitcoin, conserva gli header della chain con più proof of work. Ogni header occupa 80 byte e impegna le transazioni del blocco tramite una Merkle root. Per verificare un pagamento, il client chiede a un peer il ramo di Merkle che collega la transazione a un header che già possiede. Se il ramo torna, la transazione è in quel blocco, e i blocchi costruiti sopra mostrano quanto lavoro la protegge.

Un nodo pruned valida la chain nello stesso modo di un nodo archival. Scarica ogni blocco, controlla ciascuno, e poi elimina i vecchi file dei blocchi per liberare spazio su disco. Conserva abbastanza dati recenti per seguire la chain, ma non può mostrarti i blocchi che ha cancellato.

In breve:

- Un client SPV conserva gli header, verifica l'inclusione delle transazioni e confida che la chain con più lavoro sia valida.
- Un nodo pruned conserva i blocchi recenti, controlla ogni regola, non si fida di nessuno sulla validità e ha meno storia da offrire.

## medium

Un client SPV è onesto solo quanto i peer a cui chiede. Un ramo di Merkle prova che una transazione è in un blocco, ma non può provare che non manchi nulla. Un peer può omettere una transazione importante per il client, e il client non se ne accorgerà. La Developer Guide suggerisce perciò di inviare le richieste a più peer, così un peer disonesto non può nascondere tutto.

La privacy è la seconda debolezza. Se un client SPV chiede le transazioni che corrispondono ai propri indirizzi, ogni peer scopre quali indirizzi appartengono allo stesso utente. Il BIP 37 ha cercato di ridurre il problema con i bloom filter. Il client invia un filtro e il peer restituisce le transazioni che probabilmente corrispondono. Il tasso di falsi positivi è scelto dal client: un tasso più alto rivela meno, ma costa banda. I BIP 157 e BIP 158 usano un disegno diverso. Il full node pubblica un filtro compatto per ogni blocco, il client scarica quei filtri, li verifica localmente e richiede solo i blocchi completi che possono contenere le sue transazioni. Il BIP 157 descrive il BIP 37 come affetto da difetti noti che indeboliscono privacy e sicurezza e permettono attacchi di denial of service contro i full node.

Un nodo pruned evita il problema della fiducia perché valida tutto da sé. Il suo costo è non poter servire tutto. In Bitcoin Core il pruning si attiva con l'opzione prune, che imposta una dimensione obiettivo in MiB per i dati grezzi dei blocchi e per i dati di undo. Un nodo pruned continua a inoltrare nuovi blocchi e transazioni, ma non può servire blocchi storici qualsiasi. Il BIP 159 definisce il flag di servizio NODE_NETWORK_LIMITED, che comunica agli altri peer che il nodo conserva solo i blocchi recenti. Tale nodo garantisce di servire almeno gli ultimi 288 blocchi, circa due giorni. Un peer che cerca blocchi più vecchi deve trovare un nodo che dichiari la storia completa. Il pruning esclude anche il transaction index e i rescan del wallet.

## advanced

Il whitepaper presenta la SPV come un compromesso. Un client che conserva solo gli header può verificare che una transazione sia sepolta sotto proof of work, ma non che la transazione rispetti le regole. La Developer Guide dice la stessa cosa: il ramo di Merkle dimostra la quantità di lavoro necessaria per riscrivere la chain, non la validità di ciò che è incluso. Un client SPV quindi non può verificare un pagamento in conflitto non ancora confermato, e non può distinguere una transazione invalida da una valida che si trova in un blocco. L'ipotesi della chain con più lavoro sostiene l'intera sicurezza.

I controlli sugli header danno al client più di quanto sembri. Ogni header deve avere un hash sotto un target che segue la regola di aggiustamento della difficoltà, quindi costruire una falsa catena di header costa lavoro reale. Un ramo di Merkle contiene un hash per ogni livello dell'albero, quindi la sua lunghezza cresce con il logaritmo del numero di transazioni, non con la dimensione del blocco. Il costo è una dipendenza: la visione del client è aggiornata solo quanto i peer che gli forniscono gli header.

Un nodo pruned ha il profilo opposto. Applica ogni regola di consenso, comprese firme e script dei vecchi blocchi, perché li ha controllati quando sono arrivati. Conserva anche i dati di undo per i blocchi recenti, che gli permettono di annullarli durante una riorganizzazione. Un nodo con un prune target piccolo può essere costretto a fermarsi quando una riorganizzazione richiede blocchi che ha già cancellato, quindi il target dovrebbe coprire una profondità di riorganizzazione realistica. La documentazione di Bitcoin Core dice che il wallet è sicuro allo stesso modo con valori di prune alti o bassi, e che valori più alti servono solo a far restare il nodo in funzione durante riorganizzazioni più profonde.

Nel complesso, i due modelli separano ciò che viene verificato da ciò che viene conservato. La SPV verifica a basso costo l'inclusione e accetta il lavoro della chain come prova di validità. Il pruning controlla tutto e conserva meno. Nessuno dei due offre la stessa garanzia di un nodo archival completo, che valida la chain e può anche servire tutta la sua storia agli altri. In pratica, un client che vuole maggiore sicurezza dovrebbe confrontare ciò che riferiscono più peer, invece di affidarsi a un'unica risposta.
