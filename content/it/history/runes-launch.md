---
id: history.runes-launch
slug: runes-launch
language: it
date: 2024-04-01
title: Lancio del Protocollo Runes
category: protocol
summary: Casey Rodarmor lancia il protocollo Runes, permettendo la creazione di token fungibili su Bitcoin utilizzando il modello UTXO.
sources:
  - title: Runes Documentation
    url: https://docs.ordinals.com/runes.html
  - title: Runes Specification
    url: https://github.com/ordinals/ord/blob/master/src/runes.rs
related:
  - wiki.utxo-model
  - wiki.taproot
updatedAt: 2026-05-28T00:00:00Z
---

Nell'aprile 2024, Casey Rodarmor lanciò il protocollo Runes, un nuovo standard per creare token fungibili sulla blockchain di Bitcoin. Runes fu lanciato contemporaneamente al quarto halving al blocco 840.000, in un evento coordinato che generò notevole attenzione e attività.
![Esempio di transazione del protocollo Runes che mostra la codifica delle operazioni token in OP_RETURN.](media/history/runes-launch/runes-transaction-example.webp "Esempio transazione Runes")


Runes affrontava le limitazioni dei precedenti protocolli di token su Bitcoin. A differenza di BRC-20, che si basava sulle iscrizioni Ordinals e creava un significativo ingombro della blockchain attraverso il suo modello di stato off-chain, Runes utilizzava direttamente il modello UTXO nativo di Bitcoin. Ogni saldo di token Rune era impegnato in un output di transazione Bitcoin, consentendo un'integrazione pulita con l'infrastruttura esistente di Bitcoin.

Il design del protocollo dava priorità alla semplicità e all'efficienza. Le transazioni Runes utilizzavano output OP_RETURN per codificare le operazioni sui token — incisione di nuovi token, conio e trasferimento — con un'impronta on-chain minima. Questo approccio riduceva il carico di dati sulla blockchain rispetto ai protocolli di token basati su iscrizioni.

Runes fu lanciato con un'enorme hype iniziale. Diversi progetti importanti condussero coniazioni e airdrop il primo giorno, generando milioni di dollari in commissioni di transazione. Sebbene l'entusiasmo iniziale si sia moderato nel tempo, Runes stabilì una base per l'attività di token fungibili su Bitcoin, completando i casi d'uso non fungibili abilitati da Ordinals.
