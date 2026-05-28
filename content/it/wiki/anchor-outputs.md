---
id: wiki.anchor-outputs
slug: anchor-outputs
language: it
category: lightning network
title: Anchor Outputs
description: Piccoli output da 1 satoshi nelle transazioni di commitment Lightning che permettono a entrambe le parti del canale di aumentare la commissione della transazione usando Child-Pays-For-Parent (CPFP), garantendo conferma tempestiva anche durante picchi di fee.
coverImage: media/wiki/anchor-outputs/anchor-output-structure.svg
difficulty: advanced
readTimeMinutes: 8
tags:
  - Lightning Network
  - Anchor Output
  - CPFP
  - Gestione Commissioni
  - Transazioni di Commitment
related:
  - wiki.commitment-transactions
  - wiki.payment-channels
  - wiki.channel-funding-transactions
  - wiki.lightning-network
  - wiki.transaction-fees
sources:
  - title: "BOLT #3 — Bitcoin Transaction and Script Formats (Anchor Outputs)"
    url: https://github.com/lightning/bolts/blob/master/03-transactions.md
    author: Lightning Network Specifications
  - title: "Anchor Outputs Specification"
    url: https://github.com/lightning/bolts/pull/688
    author: Lightning Network Contributors
  - title: "CPFP Fee Bumping — Bitcoin Developer Guide"
    url: https://developer.bitcoin.org/techguide/transactions.html#fee-bumping
    author: Bitcoin.org
updatedAt: 2026-05-27T00:00:00Z
---

## base

Gli anchor output sono piccoli output da 1 satoshi aggiunti alle transazioni di commitment. Il loro unico scopo è permettere a entrambe le parti di aumentare la commissione della transazione dopo che il commitment è già stato firmato.

Il problema che gli anchor output risolvono: le transazioni di commitment sono pre-firmate con una commissione fissa. Se il mercato delle fee di Bitcoin subisce un picco tra il momento in cui il commitment viene firmato e quello in cui deve essere trasmesso, la commissione pre-firmata potrebbe essere troppo bassa per essere confermata. Poiché il commitment è già completamente firmato, nessuna delle due parti può modificarne la commissione.

La soluzione: chiunque può spendere un anchor output con una transazione figlia a commissione elevata. Questa tecnica si chiama Child-Pays-For-Parent (CPFP). L'anchor funge da maniglia di emergenza — entrambe le parti possono tirarla per accelerare la conferma creando una transazione figlia che paga una commissione più alta.

![Struttura degli anchor output](media/wiki/anchor-outputs/anchor-output-structure.svg "Una transazione di commitment con due anchor output (1 sat ciascuno) che permettono il fee bumping tramite CPFP.")

## medium

Le transazioni di commitment sono le transazioni più critiche della Lightning Network — rappresentano lo stato più recente del canale e devono essere confermate rapidamente quando vengono trasmesse. Tuttavia, vengono negoziate e firmate in anticipo, il che significa che la loro commissione è bloccata al momento della firma. Se il tasso di commissione prevalente aumenta significativamente prima della trasmissione, la transazione potrebbe rimanere bloccata nel mempool indefinitamente.

Prima degli anchor output, solo la parte che creava la transazione di commitment poteva aumentarne la commissione, usando Replace-by-Fee (RBF). Questo era asimmetrico: una parte aveva il controllo della commissione, l'altra no. Gli anchor output risolvono questo problema dando a entrambe le parti la possibilità di eseguire CPFP sulla transazione di commitment.

Una transazione figlia CPFP spende uno degli anchor output. I miner che valutano la transazione figlia vedono la sua commissione alta e calcolano la commissione combinata del pacchetto genitore-figlia. Se il tasso combinato è competitivo, includono entrambe le transazioni. Questo funziona perché l'output anchor è tipicamente protetto da uno script semplice spendibile da chiunque (`OP_TRUE`) negli anchor v1, o da un percorso spendibile con chiave negli anchor v2.

L'output anchor ha un valore di 1 satoshi — l'importo più piccolo possibile che sia ancora economicamente sensato come output non-dust. Spenderlo richiede l'aggiunta di almeno altrettanto in commissioni, che è esattamente lo scopo: il valore dell'anchor forza la transazione di fee bumping a includere commissioni sufficienti.

![Fee bumping CPFP con anchor](media/wiki/anchor-outputs/anchor-cpfp.svg "Una transazione di commitment bloccata con fee bassa viene sbloccata tramite CPFP usando una transazione figlia che spende l'output anchor.")

## advanced

### Due Versioni di Anchor Output

Gli anchor output esistono in due versioni, che riflettono l'evoluzione del modello di sicurezza di Lightning:

**v1 (OP_TRUE anchor):** Il primo script per anchor output era semplicemente `OP_TRUE`, il che significava che chiunque poteva spenderlo — non solo le due parti del canale. Questa è stata la prima proposta ed è stata implementata nelle prime versioni di c-lightning ed Eclair. La condizione di spesa era banale, rendendo il CPFP semplice per entrambe le parti.

**v2 (key-spendable anchor):** La specifica v2 (definita in BOLT #3) ha sostituito `OP_TRUE` con uno script che richiede una firma da una delle due parti. Questa è stata una risposta diretta agli **attacchi di pinning**.

### Attacchi di Pinning

Con gli anchor v1, un terzo malintenzionato poteva monitorare il mempool per transazioni di commitment, prendere l'output anchor con `OP_TRUE` e spenderlo con una propria transazione a commissione bassa. Questa transazione figlia a bassa commissione "bloccherebbe" l'anchor, impedendo alla parte legittima del canale di eseguire efficacemente il CPFP. La transazione dell'attaccante dovrebbe essere inclusa prima, oppure la parte legittima dovrebbe superare l'offerta — una condizione di competizione che mina l'affidabilità degli anchor output.

Gli anchor v2 risolvono il pinning richiedendo una firma valida da una delle due parti del canale. Un terzo non può creare una transazione di spesa perché non possiede le chiavi di firma. Questo garantisce che solo i due partecipanti legittimi del canale possano creare transazioni figlie CPFP.

### Interazione con il Calcolo delle Commissioni

Gli anchor output aggiungono due output extra alla transazione di commitment. Ogni anchor è da 1 satoshi, quindi il valore totale degli output aumenta di 2 satoshi. Il calcolo della commissione della transazione di commitment deve tenere conto di questi output — non fanno parte della distribuzione del saldo tra le parti. Gli anchor output vengono creati dal budget delle commissioni della transazione o dalla polvere che altrimenti sarebbe considerata non economica.

### Considerazioni Temporali: to_self_delay e CPFP

Il CPFP ha un vincolo temporale quando l'output anchor viene speso dalla parte il cui saldo è nell'output `to_local` (che ha un timelock CSV). Se Alice trasmette una transazione di commitment e vuole fare CPFP tramite il suo anchor, deve farlo prima che il timelock scada o rischiare una condizione di competizione. In pratica, il CPFP funziona meglio quando chi spende l'anchor è la parte che riceve l'output `to_remote`, poiché quell'output non ha timelock e può essere confermato immediatamente insieme alla transazione figlia.

### Anchor Output in Splicing e Dual-Funding

Gli anchor output sono particolarmente utili in costruzioni di canali più avanzate:

- **Splicing:** Quando un canale viene sottoposto a splicing (aggiunta o rimozione di fondi in-flight), la vecchia transazione di commitment potrebbe dover essere confermata on-chain. Gli anchor garantiscono che entrambe le parti possano aumentare la commissione della vecchia transazione se rimane bloccata.
- **Dual-funding:** Con entrambe le parti che contribuiscono al finanziamento iniziale del canale, il problema del controllo asimmetrico delle commissioni è ancora più pronunciato. Gli anchor danno a entrambi i contributori la stessa capacità di garantire la conferma della transazione di finanziamento.

### Stato delle Implementazioni

| Implementazione | Supporto v1 | Supporto v2 |
|---|---|---|
| **LND** | Sperimentale | Default (da v0.15) |
| **Core Lightning (CLN)** | Legacy | Default (da v23.05) |
| **Eclair** | Legacy | Default |
| **LDK** | N/D | Supportato |

La rete sta migrando verso gli anchor v2 come standard. La maggior parte dei canali Lightning moderni utilizza il formato anchor v2, e i canali più vecchi che usano anchor v1 vengono gradualmente chiusi e riaperti nel formato v2.

### Riepilogo

Gli anchor output sono un meccanismo apparentemente semplice che risolve un problema fondamentale nel design del protocollo Lightning Network: come permettere a due parti che non si fidano reciprocamente di pre-firmare una transazione mantenendo la capacità di rispondere a condizioni on-chain mutevoli? Aggiungendo un piccolo output spendibile, entrambe le parti ottengono la flessibilità di eseguire CPFP sulla transazione di commitment senza bisogno di coordinarsi o rifirmare. Questo piccolo cambiamento migliora significativamente l'affidabilità e la sicurezza delle operazioni di canale.
