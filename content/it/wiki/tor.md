---
id: wiki.tor
slug: tor
language: it
category: privacy-security
title: Tor e Bitcoin
description: Tor nasconde l'indirizzo di rete di un nodo o di un wallet ai peer e agli osservatori con cui comunica, ma non nasconde le transazioni stesse.
difficulty: base
readTimeMinutes: 5
tags:
  - Privacy
  - Tor
  - Rete
  - Onion Service
related:
  - wiki.peer-to-peer-network
  - wiki.full-nodes
  - wiki.onion-routing
  - wiki.threat-model
  - wiki.software-wallets
sources:
  - title: Bitcoin Core documentation - Tor support
    url: https://github.com/bitcoin/bitcoin/blob/master/doc/tor.md
    author: Bitcoin Core contributors
  - title: Bitcoin Core documentation - I2P support
    url: https://github.com/bitcoin/bitcoin/blob/master/doc/i2p.md
    author: Bitcoin Core contributors
  - title: "Deanonymisation of clients in Bitcoin P2P network"
    url: https://arxiv.org/abs/1405.7418
    author: Alex Biryukov, Dmitry Khovratovich, Ivan Pustogarov
  - title: Tor - Bitcoin Wiki
    url: https://en.bitcoin.it/wiki/Tor
    author: Bitcoin Wiki contributors
  - title: Protect your privacy
    url: https://bitcoin.org/en/protect-your-privacy
    author: Bitcoin.org contributors
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

Tor è una rete di anonimato che fa passare il traffico attraverso diversi relay, così il peer a cui ti connetti vede l'indirizzo di un relay di uscita invece del tuo. Per Bitcoin la domanda utile è che cosa Tor nasconde e che cosa resta visibile.

Tor nasconde l'indirizzo di rete del tuo nodo o wallet ai peer a cui ti connetti e a chiunque osservi la rete vicino a te. Conta perché un peer che registra le connessioni può associare una transazione a un indirizzo IP. Bitcoin.org suggerisce Tor per questo motivo.

Tor non nasconde le transazioni. Il registro è pubblico, quindi input, output, importi e tempi di una transazione possono essere letti da chiunque, qualunque rete l'abbia trasportata. Se il tuo wallet chiede a un server remoto dei tuoi indirizzi, quel server vede comunque gli indirizzi anche quando la connessione passa da Tor. Tor nasconde da dove arriva una connessione, non che cosa contiene il registro.

Bitcoin Core può inviare le connessioni in uscita attraverso un proxy Tor, e può mettersi in ascolto come onion service, così altri nodi lo raggiungono senza conoscere il suo indirizzo IP. Il routing a cipolla usato dai pagamenti Lightning è un meccanismo diverso, descritto nella sua voce: cifra le istruzioni di pagamento a strati e non instrada il traffico peer-to-peer di Bitcoin.

## medium

Bitcoin Core ha tre modi principali per usare Tor. Primo, quando il nodo è indirizzato a un proxy SOCKS locale, di solito sulla porta 9050, le connessioni in uscita passano da Tor e gli indirizzi onion possono essere usati come peer. Secondo, Bitcoin Core può creare automaticamente un onion service attraverso la control port di Tor. Terzo, l'opzione onlynet=onion limita le connessioni automatiche in uscita ai peer onion, mentre quelle in entrata e manuali non sono toccate.

Il DNS è una falla comune. La documentazione di Bitcoin Core dice che le richieste DNS passano dal proxy solo quando un proxy è configurato per esse. Altrimenti il sistema operativo risolve i nomi, e le ricerche possono andare in chiaro verso i resolver del provider internet, anche se le connessioni ai peer passano da Tor. Il proxy per il DNS si configura separatamente dal proxy per gli indirizzi onion, quindi i due vanno impostati in modo coerente.

Un nodo che gestisce anche un onion service dovrebbe limitare quel servizio alla porta di Bitcoin Core. La documentazione dice che aggiungere un altro servizio, come un server web, allo stesso onion service rende banale collegare i due, con possibile perdita di privacy. Gli onion service creati automaticamente espongono sempre una sola porta.

La documentazione osserva anche che un nodo che ascolta su tutte le interfacce può comunque ricevere connessioni in chiaro da un peer che ne conosce l'indirizzo, e suggerisce di associare l'indirizzo in ascolto al proxy Tor. Avverte inoltre che un nodo raggiungibile su più reti può essere correlato da un avversario che osserva caratteristiche di esecuzione condivise.

Per i wallet la situazione è diversa. Un wallet che si connette al proprio nodo non consegna i propri indirizzi a terzi. Un wallet che si connette a un server remoto deve inviare a quel server gli indirizzi che gli interessano, qualunque percorso di rete usi. Tor può nascondere l'indirizzo IP del wallet a quel server, ma non gli indirizzi stessi.

## advanced

Operare solo tramite Tor scambia un'esposizione con un'altra. La documentazione di Bitcoin Core dice che un nodo che ascolta su più reti rende gli attacchi di eclisse e di partizione più costosi, perché dispone di più connessioni indipendenti, e che questi nodi bridge aiutano la rete. Un nodo che dipende solo dai peer onion perde quei percorsi e dipende di più dalla disponibilità di Tor. Il compromesso è tra nascondere l'identità del nodo e mantenere una connettività varia.

La ricerca ha mostrato che Tor non protegge automaticamente il client. Biryukov, Khovratovich e Pustogarov (arXiv:1405.7418, 2014) hanno descritto come il meccanismo anti-DoS della rete Bitcoin potesse essere abusato per tagliare fuori gli utenti Tor. Molti utenti Tor appaiono provenire dallo stesso relay di uscita, quindi un comportamento attribuito a un indirizzo di uscita poteva portarne il punteggio oltre la soglia di ban. Il ban disconnetteva così ogni utente Tor dietro quell'uscita. L'articolo descrive il software del 2014, quindi l'attacco specifico potrebbe non valere per le versioni attuali, ma la lezione resta: un indirizzo condiviso fa sì che le regole anti-abuso colpiscano molti utenti insieme.

La documentazione indica anche che da Bitcoin Core 22.0 sono supportati solo gli onion service Tor v3, e che Tor ha rimosso il supporto v2 a partire dalla versione 0.4.6. L'onion service automatico richiede la control port di Tor e funziona solo se l'autenticazione è configurata correttamente.

Bitcoin Core supporta anche I2P tramite un proxy SAM, una rete di anonimato simile con un disegno diverso. La sua documentazione nota che I2P ha meno peer di Tor o delle reti IP, quindi un nodo che usa solo I2P può essere più esposto agli attacchi Sybil.

Tor non protegge il registro e non rende privato il server a cui un wallet si collega. L'indirizzo di rete che Tor nasconde è solo un segnale tra altri. Tempi, grafo delle transazioni e indirizzi interrogati dal wallet restano visibili, a meno che non si adottino altre misure. Un disegno completo abbina quindi il livello di rete alle pratiche di privacy trattate altrove in questa categoria, invece di affidarsi a Tor come soluzione completa.

Se far girare un nodo solo tramite Tor sia la scelta giusta dipende da ciò che deve restare non collegabile. La risposta cambia con il modello di minaccia, ed è per questo che quella voce va letta per prima.
