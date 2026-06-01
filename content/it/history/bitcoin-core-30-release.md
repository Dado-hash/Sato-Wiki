---
id: history.bitcoin-core-30-release
slug: bitcoin-core-30-release
language: it
date: 2025-10-10
title: Rilasciato Bitcoin Core 30.0
category: protocol
summary: Bitcoin Core 30.0 viene rilasciato, introducendo modifiche alle policy di relay e accendendo il dibattito su OP_RETURN, limiti datacarrier e comportamento operativo dei nodi.
sources:
  - title: Bitcoin Core 30.0 Release Announcement
    url: https://bitcoincore.org/en/2025/10/10/release-30.0/
  - title: Bitcoin Core 30.0 Release Notes
    url: https://bitcoincore.org/en/releases/30.0/
related:
  - wiki.full-nodes
  - wiki.mempool
  - wiki.bitcoin-script
updatedAt: 2026-05-28T00:00:00Z
---

Il 10 ottobre 2025 è stato rilasciato Bitcoin Core 30.0, segnando un aggiornamento significativo all'implementazione software di riferimento di Bitcoin. Pur non essendo un cambiamento a livello di consenso — non alterava cioè le regole fondamentali della blockchain — il rilascio ha introdotto modifiche notevoli alla policy di relay e al comportamento dei nodi che hanno generato discussioni in tutta la comunità di sviluppo Bitcoin.

![Terminale Bitcoin Core 30.0 durante la compilazione o l'operatività del nodo.](media/history/bitcoin-core-30-release/bitcoin-core-terminal.webp "Terminale Bitcoin Core 30.0")

I dibattiti chiave del rilascio riguardavano le policy OP_RETURN e datacarrier — i meccanismi con cui i dati possono essere incorporati nelle transazioni Bitcoin. Dall'introduzione di OP_RETURN in Bitcoin Core 0.9 (2014), gli output di transazione che utilizzano questo opcode sono stati usati per tutto, dalle colored coins e l'emissione di asset (Omni, Counterparty) alle inscription Ordinals e all'archiviazione generale di dati. Bitcoin Core 30.0 ha rivisto i limiti predefiniti della dimensione datacarrier e il comportamento di relay, stimolando discussioni su quali tipi di transazioni dati la rete dovrebbe ritrasmettere per impostazione predefinita.

Per gli operatori di nodi, il rilascio includeva miglioramenti delle prestazioni e perfezionamenti alla policy del mempool — le regole che determinano quali transazioni un nodo accetterà e ritrasmetterà. Questi cambiamenti hanno influenzato il modo in cui i nodi gestiscono la sostituzione delle transazioni (BIP 125), la stima delle fee e la gestione delle risorse del mempool. Il rilascio ha anche continuato il lavoro in corso di Bitcoin Core sul package relay e altri miglioramenti del mempool che beneficiano l'efficienza complessiva dell'elaborazione delle transazioni della rete.

Il significato di Bitcoin Core 30.0 per la timeline storica era duplice. In primo luogo, ha dimostrato la continua vitalità del processo di sviluppo di Bitcoin, con contributori che iterano sulla policy di rete anni dopo la creazione del protocollo. In secondo luogo, i dibattiti sulle policy di relay e sui limiti datacarrier hanno evidenziato le tensioni all'interno della comunità Bitcoin sull'uso appropriato dello spazio della blockchain — un tema ricorrente nella governance di Bitcoin, dalla block size war a Ordinals fino a ogni parametro policy che modella quali transazioni sono economicamente sostenibili.
