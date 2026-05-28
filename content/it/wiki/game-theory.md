---
id: wiki.game-theory
slug: game-theory
language: it
category: economics
title: Teoria dei Giochi
description: Lo studio delle decisioni strategiche che spiega perché i partecipanti razionali in Bitcoin seguono le regole, rendendo il sistema sicuro senza autorità centrale.
coverImage: media/wiki/game-theory/game-theory-hero.svg
difficulty: base
readTimeMinutes: 7
tags:
  - Economia
  - Teoria dei Giochi
  - Incentivi
  - Sicurezza
related:
  - wiki.miner-incentives
  - wiki.consensus-rules
  - wiki.proof-of-work
  - wiki.fee-market
  - wiki.network-effects
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: Il Problema dei Generali Bizantini
    url: https://lamport.azurewebsites.net/pubs/byz.pdf
    author: Leslie Lamport, Robert Shostak, Marshall Pease
    publishedAt: 1982-07-01
  - title: Teoria dei Giochi e Bitcoin
    url: https://www.bitcoinplaybook.org/chapters/game-theory/
    author: Hasu, James Prestwich
updatedAt: 2026-05-28T00:00:00Z
---

## base

La teoria dei giochi è lo studio di come le persone razionali prendono decisioni quando il risultato dipende da ciò che fanno gli altri. Bitcoin usa la teoria dei giochi per garantire che i partecipanti si comportino onestamente anche se nessuno ha il controllo.

In Bitcoin ci sono tre gruppi principali di partecipanti:
- **Miner**: Competono per creare blocchi e guadagnare ricompense
- **Full node**: Validano i blocchi e applicano le regole
- **Utenti**: Transano e decidono quale catena ha valore

Ogni gruppo ha i propri interessi, ma le regole di Bitcoin sono progettate in modo che la scelta più redditizia per tutti sia seguire le regole. Questo si chiama allineamento degli incentivi.

Per esempio, un miner potrebbe provare a spendere lo stesso bitcoin due volte (double-spend). Ma per farlo, dovrebbe minare una catena segreta che superi la catena onesta. Questo richiede una potenza di calcolo ed elettricità enormi. Se l'attacco riuscisse, distruggerebbe la fiducia in Bitcoin e farebbe crollare il prezzo — rendendo le sue attrezzature di mining senza valore. L'attacco non è quindi redditizio, e i miner razionali non lo tentano.

![Equilibrio della teoria dei giochi in Bitcoin](media/wiki/game-theory/game-theory-hero.svg "Tre gruppi — miner, full node e utenti — hanno incentivi allineati che rendono il comportamento onesto la strategia dominante per ciascuno.")

Pensa a Bitcoin come a un campionato sportivo. I giocatori potrebbero infrangere le regole per un guadagno a breve termine, ma gli arbitri (full node) applicano le regole, e i tifosi (utenti) abbandoneranno il campionato se diventa noto per i suoi imbrogli. Tutti lo capiscono, quindi la maggior parte dei giocatori segue le regole la maggior parte del tempo.

## medium

La teoria dei giochi di Bitcoin può essere compresa attraverso diversi concetti classici:

**L'equilibrio di Nash.** Un equilibrio di Nash si verifica quando nessun partecipante può trarre vantaggio cambiando la propria strategia mentre gli altri mantengono la propria invariata. Il protocollo di Bitcoin crea un equilibrio di Nash in cui il mining onesto è la strategia dominante. Un miner che considera un attacco di double-spend deve pesare la ricompensa contro il costo: l'attacco richiede il controllo di più potenza di hash della catena onesta, che è enormemente costoso. Anche se riuscito, la conseguente perdita di fiducia svaluterebbe qualsiasi bitcoin posseduto dall'attaccante, rendendo l'attacco autodistruttivo.

**Il problema dei generali bizantini.** Questo è un classico problema dell'informatica distribuita: come possono parti separate mettersi d'accordo su un piano quando alcune potrebbero essere traditrici? Satoshi ha risolto questo problema introducendo incentivi economici. In Bitcoin, i "traditori" (miner disonesti) non sono impediti di agire, ma le loro azioni sono rese economicamente irrazionali. Il costo dell'imbroglio supera il potenziale guadagno.

**Il problema principale-agente.** I miner (agenti) agiscono per conto della rete (principale). Il subsidy e le commissioni allineano i loro interessi: i miner guadagnano di più seguendo le regole che infrangendole. L'halving garantisce che questo allineamento persista con il declino del subsidy, costringendo i miner a competere sull'efficienza piuttosto che fare affidamento su un pagamento fisso.

**La tragedia dei commons.** Il mining è un'industria competitiva dove i singoli miner aumentano il proprio hash rate per catturare una quota maggiore delle ricompense. Quando tutti i miner fanno lo stesso, la difficoltà si aggiusta verso l'alto e la quota di ciascuno rimane simile mentre i costi aumentano. Questa è una classica "corsa agli armamenti" ma ha un effetto collaterale positivo: rende la rete estremamente sicura. L'alto costo di ingresso impedisce agli attaccanti di acquisire potenza di mining a buon mercato.

Proprietà chiave della teoria dei giochi di Bitcoin:

| Proprietà | Descrizione |
|-----------|-------------|
| Strategia dominante | Il mining onesto è sempre la strategia più redditizia |
| Costo dell'imbroglio | Richiede >50% dell'hash rate, senza garanzia di profitto |
| Resistenza Sybil | Il potere di voto è proporzionale all'hash rate, non all'identità |
| Minimizzazione della fiducia | Nessuna singola parte deve essere fiduciata; la fiducia è distribuita |
| Autoguarigione | L'aggiustamento della difficoltà ripristina l'equilibrio dopo gli shock |

## advanced

**Il gioco del double-spend in dettaglio.** Considera un miner con frazione di hash rate `p` che vuole fare un double-spend. Invia una transazione a un commerciante, aspetta le conferme, riceve la merce, poi prova a sostituire la transazione confermata con una in conflitto su una catena privata. L'attaccante deve minare privatamente una catena più lunga della rete onesta. La probabilità di successo dopo `z` conferme segue:

```
P(successo) = 1 - somma(k=0 a z) (λ^k × e^(-λ)) / k!   dove λ = z × p / (1-p)
```

Questa è la stessa formula che Satoshi ha derivato nella Sezione 11 del whitepaper. Per un miner con il 10% di hash rate che attacca una transazione con 6 conferme, la probabilità di successo è circa lo 0,02%. Con il 30% di hash rate, sale a circa l'11%. Ecco perché gli exchange e i commercianti tipicamente aspettano almeno 3-6 conferme.

**L'equilibrio di Nash del selfish mining.** L'attacco di "selfish mining" (Eyal e Sirer, 2013) mostra che il semplice equilibrio di Nash non è l'unica possibilità. Un miner con >33% di hash rate può trarre profitto trattenendo i blocchi trovati e rilasciandoli strategicamente per orfanizzare i blocchi onesti dei miner. Questa strategia è redditizia anche se il miner spreca parte del proprio lavoro, perché cattura una quota sproporzionata delle ricompense.

Tuttavia, il selfish mining non è mai stato osservato su Bitcoin mainnet su larga scala per diverse ragioni:
1. Il rilevamento è possibile attraverso l'analisi della propagazione dei blocchi
2. La strategia riduce la sicurezza complessiva della rete, potenzialmente svalutando le disponibilità dell'attaccante
3. La soglia di redditività (>33%) è alta e richiede coordinazione nascosta
4. Esistono contro-strategie (template di blocchi inosservabili, relay FIBRE)

**La scelta della fork come gioco.** La regola della "catena più lunga" di Bitcoin (in realtà: più lavoro accumulato) crea un punto di Schelling — un punto focale naturale su cui tutti i partecipanti razionali convergono. Se la rete si dovesse dividere in fork in competizione, utenti e miner hanno un forte incentivo a coordinarsi su una catena. La catena con più lavoro accumulato è il punto focale naturale perché rappresenta oggettivamente le maggiori risorse spese.

**L'ipotesi della maggioranza onesta.** La sicurezza di Bitcoin dipende dall'assunzione che la maggioranza dell'hash rate sia controllata da miner onesti. Questa non è una garanzia matematica ma una garanzia basata sulla teoria dei giochi: è più redditizio essere onesti che attaccare. L'assunzione è stata valida dall'inizio di Bitcoin, con l'hash rate che è cresciuto da pochi GH/s a oltre 700 EH/s, rendendo i costi di attacco astronomicamente alti.

**Incentivi nell'era delle sole commissioni.** Con il declino dei subsidy verso lo zero, la teoria dei giochi del mining cambia. I miner devono fare affidamento esclusivamente sulle entrate da commissioni. Questo crea un nuovo equilibrio dove:
- Le entrate da commissioni devono essere sufficienti a sostenere il livello di sicurezza desiderato
- I miner potrebbero avere incentivi a censurare o prioritizzare certe transazioni
- L'allineamento tra profitto del miner e sicurezza della rete diventa meno diretto

Le soluzioni proposte includono una tail emission (rifiutata da Bitcoin Core) e la dipendenza dal traffico di commissioni del Layer 2 per sostenere le fee del livello base.
