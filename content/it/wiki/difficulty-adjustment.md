---
id: wiki.difficulty-adjustment
slug: difficulty-adjustment
language: it
category: economics
title: Aggiustamento della Difficoltà
description: L'algoritmo che ricalibra il target della proof of work di Bitcoin ogni 2.016 blocchi per mantenere intervalli di 10 minuti indipendentemente dal tasso di hash totale.
coverImage: media/wiki/difficulty-adjustment/difficulty-loop.svg
difficulty: base
readTimeMinutes: 7
tags:
  - Economia
  - Mining
  - Difficoltà
  - Consenso
related:
  - wiki.proof-of-work
  - wiki.mining
  - wiki.halving
  - wiki.blocks
  - wiki.consensus-rules
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: Bitcoin Developer Reference - Block Chain
    url: https://developer.bitcoin.org/reference/block_chain.html
    author: Bitcoin.org contributors
  - title: Implementazione dell'aggiustamento di difficoltà in Bitcoin Core
    url: https://github.com/bitcoin/bitcoin/blob/master/src/pow.cpp
    author: Bitcoin Core contributors
updatedAt: 2026-05-28T00:00:00Z
---

## base

L'aggiustamento della difficoltà di Bitcoin è il meccanismo che mantiene stabile il tasso di produzione dei blocchi. Senza di esso, l'aggiunta di più miner farebbe trovare i blocchi sempre più velocemente, compromettendo il prevedibile ritmo di 10 minuti della rete.

L'aggiustamento funziona come un circuito di feedback. Ogni 2.016 blocchi — circa due settimane — ogni full node verifica quanto tempo è effettivamente servito per minare quei blocchi. Se ci è voluto meno di due settimane (blocchi trovati troppo velocemente), la difficoltà aumenta. Se ci è voluto più di due settimane (blocchi trovati troppo lentamente), la difficoltà diminuisce. L'aggiustamento è limitato a un fattore massimo di 4 per periodo.

Questo significa che Bitcoin si adatta automaticamente ai cambiamenti nella potenza di mining totale. Quando nuovi miner si uniscono, inizialmente i blocchi arrivano più velocemente, ma il successivo aggiustamento aumenta la difficoltà e riporta il ritmo a 10 minuti. Quando i miner se ne vanno, l'aggiustamento riduce la difficoltà, mantenendo la rete accessibile anche con meno potenza di hash totale.

![Circuito di feedback dell'aggiustamento di difficoltà](media/wiki/difficulty-adjustment/difficulty-loop.svg "Un circuito di feedback negativo: i cambiamenti nel tasso di hash alterano la tempistica dei blocchi, che innesca un aggiustamento di difficoltà ogni 2.016 blocchi per ripristinare l'obiettivo di 10 minuti.")

La difficoltà è espressa come un target: i miner devono trovare un hash dell'header del blocco che sia inferiore a questo valore target. Un target più basso significa meno hash validi, rendendo il mining più difficile. Un target più alto significa più hash validi, rendendo il mining più facile.

## medium

L'algoritmo di aggiustamento della difficoltà è matematicamente semplice. Dopo ogni periodo di 2.016 blocchi, ogni full node calcola indipendentemente:

```
nuovo_target = vecchio_target × (tempo_effettivo / tempo_previsto)
```

Dove `tempo_effettivo` è il tempo impiegato per minare gli ultimi 2.016 blocchi, e `tempo_previsto` è 2.016 × 10 minuti = 20.160 minuti (esattamente due settimane).

L'aggiustamento è limitato in modo che `tempo_effettivo` non possa essere inferiore a 3,5 giorni (un quarto del target) o superiore a 8 settimane (quattro volte il target). Questo previene aggiustamenti estremi da un singolo periodo anomalo.

La difficoltà è memorizzata nell'header del blocco come campo `nBits` — una codifica compatta a 4 byte del target a 256 bit. Bitcoin Core implementa il ricalcolo in `CalculateNextWorkRequired()` in `pow.cpp`:

```cpp
unsigned int CalculateNextWorkRequired(const CBlockIndex* pindexLast,
                                       int64_t nFirstBlockTime,
                                       const Consensus::Params& params)
{
    if (params.fPowNoRetargeting)
        return pindexLast->nBits;

    int64_t nActualTimespan = pindexLast->GetBlockTime() - nFirstBlockTime;
    nActualTimespan = std::max(nActualTimespan, params.DifficultyAdjustmentInterval() / 4);
    nActualTimespan = std::min(nActualTimespan, params.DifficultyAdjustmentInterval() * 4);

    const arith_uint256 bnPowLimit = UintToArith256(params.powLimit);
    arith_uint256 bnNew;
    bnNew.SetCompact(pindexLast->nBits);
    bnNew *= nActualTimespan;
    bnNew /= params.DifficultyAdjustmentInterval();

    if (bnNew > bnPowLimit)
        bnNew = bnPowLimit;
    return bnNew.GetCompact();
}
```

La difficoltà è cresciuta enormemente dal lancio di Bitcoin. I primi blocchi avevano una difficoltà di 1, il che significa che il target era il massimo valore possibile (2²²⁴ - 1 per Bitcoin). Entro il 2026, la difficoltà supera i 100 trilioni — un aumento di 100.000.000.000.000x. Questo riflette la crescita dell'industria del mining di Bitcoin da hobbisti su CPU a operazioni industriali con ASIC.

![Storia della difficoltà](media/wiki/difficulty-adjustment/difficulty-history-chart.svg "La difficoltà del mining di Bitcoin è cresciuta da 1 a oltre 100 trilioni, riflettendo l'enorme crescita del tasso di hash globale dal mining su CPU a GPU fino agli ASIC.")

I timestamp nei blocchi non sono fidati ciecamente. I nodi impongono regole per impedire ai miner di manipolare la difficoltà mentendo sui timestamp: il timestamp del blocco deve essere maggiore del timestamp mediano degli ultimi 11 blocchi (Median-Time-Past) e non può superare di più di 2 ore il tempo regolato dalla rete del nodo.

## advanced

L'aggiustamento della difficoltà si è evoluto nella storia di Bitcoin. Originariamente, Satoshi Nakamoto implementò un semplice ricalcolo basato sul rapporto tra tempo effettivo e previsto. L'algoritmo attuale è stato perfezionato per prevenire diversi vettori d'attacco.

**Attacchi di manipolazione dei timestamp.** Un miner disonesto potrebbe dichiarare blocchi trovati più velocemente della realtà per abbassare la difficoltà durante il periodo successivo. Bitcoin si difende con due regole:
1. **Median-Time-Past**: Il timestamp di un blocco deve superare la mediana degli ultimi 11 timestamp dei blocchi. Questo impedisce a un singolo miner di spostare l'orologio molto nel futuro.
2. **Limite futuro**: Il timestamp di un blocco non può superare il tempo locale del nodo di più di 2 ore.

Queste regole impediscono ai miner di creare blocchi con timestamp che distorcerebbero significativamente il calcolo della difficoltà.

**Aggiustamento di emergenza della difficoltà (EDA).** Bitcoin Cash, un fork di Bitcoin, ha subito forti oscillazioni a causa del suo meccanismo di aggiustamento di emergenza della difficoltà. Il design più conservativo di Bitcoin (aggiustamento solo ogni 2.016 blocchi con un limite di 4x) evita questa instabilità.

**Caso speciale del testnet.** La rete di test di Bitcoin (testnet) usa una regola speciale: se un blocco non viene trovato in 20 minuti, la difficoltà viene dimezzata per il blocco successivo. Questo assicura che testnet rimanga utilizzabile anche quando c'è poca attività di test. Mainnet non ha questa regola.

**L'economia della difficoltà.** L'aggiustamento della difficoltà collega la sicurezza di Bitcoin al suo prezzo. Quando il prezzo sale, il mining diventa più redditizio, attirando più miner, aumentando la difficoltà e rendendo la rete più sicura. Quando il prezzo scende, i miner non redditizi escono, la difficoltà diminuisce e i miner rimanenti operano con costi inferiori. Questo equilibrio automatico crea un sistema autostabilizzante che non richiede interventi esterni.

L'aggiustamento della difficoltà influisce anche sulla variabilità dei tempi di conferma. Mentre l'obiettivo è di 10 minuti per blocco, i tempi dei singoli blocchi seguono una distribuzione esponenziale (un processo di Poisson). Questo significa che i singoli blocchi possono arrivare in secondi o richiedere ore. L'aggiustamento della difficoltà corregge la media ma non può prevenire la varianza a breve termine. Dal punto di vista dell'utente, ecco perché potresti vedere un blocco arrivare 30 secondi dopo il precedente, seguito da un'attesa di 45 minuti. Il sistema funziona correttamente sulla finestra di 2.016 blocchi, non blocco per blocco.

Al 2025-2026, l'algoritmo di difficoltà è oggetto di ricerca continua. Proposte come **Difficulty Adjustment Algorithm v2** e **ASERT** (Absolutely Scheduled Exponentially Rising Targets) sono state discusse per potenziali aggiornamenti futuri, anche se nessuna è stata adottata da Bitcoin Core al 2026. Queste proposte mirano a rendere l'aggiustamento più fluido e reattivo preservando l'approccio conservativo di Bitcoin ai cambiamenti del consenso.
