---
id: wiki.halving
slug: halving
language: it
category: economics
title: Halving
description: La riduzione programmata del block subsidy di Bitcoin del 50% ogni 210.000 blocchi, che controlla il tasso di creazione di nuova offerta.
coverImage: media/wiki/halving/halving-timeline.svg
difficulty: base
readTimeMinutes: 7
tags:
  - Economia
  - Halving
  - Offerta
  - Politica Monetaria
  - Mining
related:
  - wiki.fixed-supply
  - wiki.twenty-one-million-cap
  - wiki.issuance-schedule
  - wiki.block-subsidy
  - wiki.miner-incentives
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: Eventi di Halving di Bitcoin
    url: https://en.bitcoin.it/wiki/Halving
    author: Bitcoin Wiki contributors
  - title: Programma del Block Subsidy di Bitcoin
    url: https://bitcoin.stackexchange.com/questions/2456/bitcoin-block-subsidy-schedule
    author: Bitcoin Stack Exchange
updatedAt: 2026-05-28T00:00:00Z
---

## base

Un halving è un evento programmato nel codice di Bitcoin in cui la ricompensa che i miner ricevono per aver trovato un nuovo blocco viene permanentemente dimezzata. Questo avviene ogni 210.000 blocchi, o approssimativamente ogni quattro anni.

Quando Bitcoin è stato lanciato nel 2009, i miner ricevevano 50 BTC per ogni blocco trovato. Nel novembre 2012, il primo halving ha ridotto questa cifra a 25 BTC. Il secondo halving nel luglio 2016 l'ha portata a 12,5 BTC. Il terzo nel maggio 2020 l'ha ridotta a 6,25 BTC. Il quarto nell'aprile 2024 l'ha fissata a 3,125 BTC.

L'halving continua finché il block subsidy diventa così piccolo da arrotondarsi a zero. Questo avverrà dopo 64 halving, intorno all'anno 2140. A quel punto, non verranno mai più creati nuovi bitcoin.

![Cronologia degli halving](media/wiki/halving/halving-timeline.svg "La cronologia completa degli halving di Bitcoin dal 2009 al 2140, che mostra come il block subsidy diminuisce a ogni epoca di 4 anni.")

L'halving è il meccanismo che rende l'offerta di Bitcoin prevedibile e scarsa. Riducendo la ricompensa nel tempo, imita i rendimenti decrescenti dell'estrazione dell'oro — senza richiedere a nessuno di decidere quando ridurla.

## medium

L'halving avviene a un'altezza di blocco specifica, non a una data specifica. Il primo halving è avvenuto al blocco 210.000, il secondo al 420.000, il terzo al 630.000 e il quarto all'840.000. La data approssimativa dipende dalla velocità con cui vengono minati i blocchi. Poiché Bitcoin mira a blocchi di 10 minuti, 210.000 blocchi richiedono circa 3,99 anni in media, ma le date effettive possono variare di settimane a causa delle fluttuazioni del tasso di hash tra gli aggiustamenti di difficoltà.

Ogni halving riduce del 50% il tasso di nuovi bitcoin che entrano in circolazione. Questo ha un effetto diretto sul tasso di inflazione:
- Prima del primo halving: ~100.000 BTC al mese in circolazione
- Dopo il quarto halving (2024): ~13.125 BTC al mese in circolazione
- Dopo l'ottavo halving (~2040): ~820 BTC al mese

L'halving è stato storicamente associato a eventi di mercato significativi. Mentre la risposta del mercato a ogni halving è variata, la riduzione della nuova offerta crea un cambiamento strutturale nell'equilibrio tra pressione di vendita dei miner e domanda di acquisto del mercato:

**Halving storici:**
- **2012 (25 BTC)**: Bitcoin veniva scambiato a circa $12. Nell'anno successivo, è salito a oltre $1.000
- **2016 (12,5 BTC)**: Il prezzo era circa $650. I 18 mesi successivi hanno visto un rally a quasi $20.000
- **2020 (6,25 BTC)**: Il prezzo era circa $8.600. L'anno successivo ha visto un picco sopra $68.000
- **2024 (3,125 BTC)**: Il prezzo era circa $63.000

Questi pattern sono spesso citati come prova dell'impatto dell'halving sul prezzo, ma la correlazione non implica causalità. Molteplici fattori — inclusi i cicli di politica monetaria, gli sviluppi normativi e i progressi tecnologici — hanno anche contribuito ai movimenti di prezzo di Bitcoin.

Dal punto di vista del miner, l'halving crea una pressione immediata sulle entrate. I miner che operavano con margini ridotti prima di un halving potrebbero diventare non redditizi e chiudere. Questo è voluto: l'halving forza miglioramenti nell'efficienza del mining e assicura che solo i miner più efficienti sopravvivano, rafforzando la sicurezza a lungo termine della rete.

## advanced

Il meccanismo di halving è implementato nella funzione `GetBlockSubsidy` di Bitcoin Core:

```cpp
CAmount GetBlockSubsidy(int nHeight, const Consensus::Params& consensusParams)
{
    int halvings = nHeight / consensusParams.nSubsidyHalvingInterval;
    if (halvings >= 64)
        return 0;
    CAmount nSubsidy = 50 * COIN;
    nSubsidy >>= halvings;
    return nSubsidy;
}
```

L'operatore di shift a destra (`>>= halvings`) implementa la divisione per 2 per ogni halving. Dopo 64 halving, shiftando un intero a 64 bit 64 volte si produce zero, il che termina il subsidy per sempre. Il `consensusParams.nSubsidyHalvingInterval` è impostato a 210.000 su mainnet.

L'economia del mining cambia drasticamente intorno a ogni halving. Considera un miner con 1 EH/s di tasso di hash (~1% del tasso di hash totale della rete):

| Metrica | Prima halving 2024 | Dopo halving 2024 |
|---------|-------------------|-------------------|
| BTC guadagnati al giorno | ~0,6 BTC | ~0,3 BTC |
| Entrate giornaliere (a $60k) | ~$36.000 | ~$18.000 |
| Costo elettricità di pareggio | ~$0,08/kWh | ~$0,04/kWh |

Ecco perché ogni halving innesca un "rifiuto dei miner." I miner meno efficienti devono aggiornare l'hardware, assicurarsi elettricità più economica o uscire. Il tasso di hash della rete spesso scende temporaneamente dopo un halving prima di riprendersi mentre i miner efficienti si espandono.

L'halving ha anche profonde implicazioni per il budget di sicurezza di Bitcoin. Nel 2024, il subsidy annuale era di circa 164.000 BTC, per un valore di circa $10 miliardi a $60.000 per BTC. Entro l'halving del 2032, questo scenderà a circa 41.000 BTC all'anno. Perché la sicurezza rimanga ai livelli attuali, il prezzo del bitcoin deve aumentare di circa 4x per mantenere lo stesso budget di sicurezza in termini fiat, oppure la rete deve fare sempre più affidamento sulle commissioni di transazione per integrare le entrate dei miner.

La teoria dei giochi dell'halving è spesso fraintesa. Poiché il subsidy viene dimezzato, ci si potrebbe aspettare che i miner colludano per aumentare le commissioni. Tuttavia, i miner sono price-taker in un mercato competitivo. La mempool e il mercato delle commissioni sono guidati dalla domanda degli utenti per lo spazio nei blocchi, non dal coordinamento dei miner. Se un miner richiede commissioni più alte, un altro miner includerà semplicemente la transazione a un tasso inferiore.

L'impatto dell'halving sul prezzo è molto dibattuto. Il modello "stock-to-flow" reso popolare da PlanB postula una forte correlazione tra la scarsità di Bitcoin (misurata dal rapporto stock-to-flow) e il suo valore di mercato. Ogni halving raddoppia il rapporto stock-to-flow di Bitcoin, e il modello prevede un corrispondente aumento di prezzo. I critici sostengono che le performance passate non sono predittive e che il modello si basa su un campione di dimensioni ridotte (solo 4 eventi di halving). Al 2026, non è stato raggiunto un consenso accademico rigoroso sull'impatto dell'halving sul prezzo.
