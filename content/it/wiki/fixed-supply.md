---
id: wiki.fixed-supply
slug: fixed-supply
language: it
category: economics
title: Offerta Fissa
description: L'offerta di Bitcoin è limitata algoritmicamente a 21 milioni di monete. Nessuna entità può crearne altre, rendendolo il primo bene digitalmente scarso.
coverImage: media/wiki/fixed-supply/fixed-supply-hero.svg
difficulty: base
readTimeMinutes: 6
tags:
  - Economia
  - Offerta
  - Scarsità
  - Politica Monetaria
related:
  - wiki.twenty-one-million-cap
  - wiki.issuance-schedule
  - wiki.halving
  - wiki.scarcity
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: Mastering Bitcoin - Capitolo 8
    url: https://github.com/bitcoinbook/bitcoinbook/blob/develop/ch08.asciidoc
    author: Andreas M. Antonopoulos
  - title: La Politica Monetaria di Bitcoin
    url: https://en.bitcoin.it/wiki/Controlled_supply
    author: Bitcoin Wiki contributors
updatedAt: 2026-05-28T00:00:00Z
---

## base

Bitcoin ha un'offerta fissa. Le regole del protocollo impongono che non possano mai esistere più di 21 milioni di bitcoin. Questo è garantito dal codice eseguito su ogni full node, non da una promessa di una banca centrale o di un'azienda.

La moneta tradizionale può essere stampata dalle banche centrali quando decidono che serve più denaro. Questa si chiama inflazione monetaria. Le regole sull'offerta di Bitcoin non possono essere modificate a meno che quasi tutti i partecipanti non accettino di eseguire nuovo software — e modificare il limite di 21 milioni è considerato impensabile dalla community.

Poiché l'offerta è fissa e nota in anticipo, Bitcoin è il primo esempio di vera scarsità digitale. Prima di Bitcoin, i file digitali potevano essere copiati all'infinito. Bitcoin ha risolto questo problema rendendo ogni unità provatamente rara attraverso la combinazione di proof of work e regole di consenso.

![Confronto offerta fissa](media/wiki/fixed-supply/fixed-supply-hero.svg "L'offerta fissa di Bitcoin di 21 milioni di monete confrontata con la moneta fiat tradizionale, che non ha un limite massimo e può essere inflazionata dalle banche centrali.")

Un'offerta fissa significa che se la domanda di Bitcoin cresce, il prezzo deve aumentare — non c'è modo di creare più monete per soddisfare la domanda. Questo è fondamentalmente diverso dalle valute fiat, dove le banche centrali possono creare nuova moneta e diluire il valore delle disponibilità esistenti.

## medium

L'offerta fissa è garantita dalle regole di consenso che ogni full node valida. La costante chiave nel codice di Bitcoin Core è `MAX_MONEY = 21,000,000 * COIN`, dove `COIN` rappresenta 100.000.000 satoshi (l'unità più piccola). Nessun output di transazione può essere creato che farebbe superare questo limite all'offerta totale di moneta.

Concettualmente, l'offerta fissa emerge da due regole del protocollo che lavorano insieme:

1. **Il programma del block subsidy**: Ogni blocco crea una quantità fissa di nuovo bitcoin (il subsidy), che si dimezza ogni 210.000 blocchi
2. **Nessuna creazione fuori dalla coinbase**: Nessuna transazione tranne la coinbase può creare nuovo bitcoin. Ogni altra transazione deve consumare input la cui somma è almeno pari ai suoi output

La serie geometrica dei block subsidy converge esattamente a 21 milioni:
```
Totale = 50 + 25 + 12,5 + 6,25 + 3,125 + ... = 50 × 2 = 100 × 210.000 = 21.000.000
```

Questa convergenza matematica è elegante: anche se gli halving continuano per sempre, la quantità di bitcoin che può essere creata è limitata e precisamente calcolabile. Dopo circa 64 halving, il subsidy si arrotonda a zero satoshi a causa dell'aritmetica degli interi, e non verranno mai più creati bitcoin.

L'offerta fissa di Bitcoin contrasta nettamente con i sistemi monetari tradizionali:

- **Oro**: L'offerta cresce dell'1-2% all'anno man mano che vengono scoperte nuove miniere e la tecnologia di estrazione migliora
- **Valuta fiat**: Le banche centrali possono creare quantità illimitate, e la maggior parte delle valute principali ha subito un'inflazione persistente
- **Moneta merce**: Monete storiche come conchiglie o bestiame avevano un'offerta variabile a seconda della raccolta o dell'allevamento

L'offerta fissa rende Bitcoin disinflazionistico per progettazione. Il tasso di inflazione (nuove monete come percentuale dell'offerta circolante) è noto con precisione decenni in anticipo e si avvicina a zero nel tempo. Questa prevedibilità permette a risparmiatori e investitori di prendere decisioni a lungo termine con fiducia riguardo all'offerta futura.

## advanced

La regola dell'offerta fissa è profondamente incorporata nella logica di validazione di Bitcoin a più livelli. A livello di transazione, la somma degli output per qualsiasi transazione non coinbase non deve superare la somma degli input. A livello di blocco, il valore dell'output della transazione coinbase non deve superare il block subsidy più le commissioni. A livello di catena, l'offerta monetaria è implicitamente limitata da queste regole — nessuna singola parte di codice controlla un totale corrente contro MAX_MONEY durante il normale funzionamento.

La costante `MAX_MONEY` ha un ruolo difensivo. Previene attacchi di overflow in cui una transazione manipolata potrebbe creare un output che supera il limite massimo. Bitcoin Core controlla questa costante nella funzione `CheckTxInputs`: se il valore totale dell'output della transazione supera MAX_MONEY, la transazione viene rifiutata. Questo protegge da scenari in cui overflow di interi o valori di input manipolati potrebbero creare monete dal nulla.

La convergenza della serie geometrica merita un'analisi più approfondita. Il subsidy iniziale di 50 BTC per blocco produce:
- 210.000 blocchi per epoca di halving
- L'emissione totale di ogni epoca = subsidy_iniziale × 210.000
- Emissione per epoca: Epoca 0 = 10.500.000 BTC (50%), Epoca 1 = 5.250.000 (25%), Epoca 2 = 2.625.000 (12,5%)

Entro la fine del quarto halving (2024), circa il 93% di tutti i bitcoin era stato minato. Questo significa che la stragrande maggioranza della base monetaria di Bitcoin è stata creata nei suoi primi 15 anni, con il restante 7% distribuito nel secolo successivo.

| Epoca | Anni | Subsidy | BTC creati | % del totale |
|-------|------|---------|------------|--------------|
| 1 | 2009-2012 | 50 BTC | 10.500.000 | 50,00% |
| 2 | 2012-2016 | 25 BTC | 5.250.000 | 25,00% |
| 3 | 2016-2020 | 12,5 BTC | 2.625.000 | 12,50% |
| 4 | 2020-2024 | 6,25 BTC | 1.312.500 | 6,25% |
| 5 | 2024-2028 | 3,125 BTC | 656.250 | 3,125% |

Un'implicazione sottile ma importante: l'offerta fissa combinata con le monete perse significa che l'offerta circolante è permanentemente inferiore a 21 milioni. Le stime dei bitcoin persi — per chiavi private dimenticate, hardware distrutto e ricompense di minatione iniziali inviate a indirizzi non spendibili — vanno da 3 a 6 milioni di monete. Questo rende la scarsità effettiva ancora maggiore del limite nominale.

Le proprietà economiche di un'offerta fissa sono state dibattute fin dai primi giorni di Bitcoin. I critici sostengono che un'offerta fissa è deflazionistica e potrebbe scoraggiare la spesa, portando potenzialmente a stagnazione economica. I sostenitori ribattono che la deflazione in un'economia in crescita è naturale e che la divisibilità di bitcoin (8 decimali, che permettono 2,1 quadrilioni di unità) fornisce una granularità sufficiente per qualsiasi livello di attività economica.
