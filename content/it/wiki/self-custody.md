---
id: wiki.self-custody
slug: self-custody
language: it
category: privacy-security
title: Custodia e self-custody
description: Chi detiene le chiavi dei bitcoin, un custode o il proprietario, e i compromessi di ciascun modello, con multisig e custodia collaborativa come vie di mezzo.
coverImage: media/wiki/self-custody/self-custody-hero.svg
difficulty: base
readTimeMinutes: 4
tags:
  - Custodia
  - Self-custody
  - Multisig
  - Sicurezza
related:
  - wiki.private-keys
  - wiki.multisig
  - wiki.wallet-seeds
  - wiki.seed-backups
sources:
  - title: Secure your wallet
    url: https://bitcoin.org/en/secure-your-wallet
    author: Bitcoin.org contributors
  - title: Securing your wallet
    url: https://en.bitcoin.it/wiki/Securing_your_wallet
    author: Bitcoin Wiki contributors
  - title: Mt. Gox
    url: https://en.bitcoin.it/wiki/Mt._Gox
    author: Bitcoin Wiki contributors
  - title: Multisignature
    url: https://bitcoinops.org/en/topics/multisignature/
    author: Bitcoin Optech
  - title: Threshold signatures
    url: https://bitcoinops.org/en/topics/threshold-signature/
    author: Bitcoin Optech
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

La custodia risponde a una domanda: chi può muovere i bitcoin? Nella custodia presso un custode, una società detiene le chiavi. Tu non controlli direttamente le monete. Hai un credito verso la società, e lei decide se e quando un prelievo avviene. Nella self-custody sei tu a detenere le chiavi, e per spendere non serve nessun terzo.

Ciascun modello ha rischi propri. Un custode porta con sé il rischio di controparte. La società può fallire, bloccare i prelievi o comunicare saldi sbagliati, e tu dipendi dalla sua sicurezza e dalla sua onestà. La self-custody elimina questa dipendenza, ma mette la responsabilità su di te. Se perdi le chiavi e il backup, nessuno può ripristinare i fondi. Se qualcun altro ottiene le chiavi, può muovere le monete senza chiedere a nessuno.

Nessuno dei due modelli è privo di rischi, e anche l'eredità pone la stessa domanda, perché gli eredi hanno bisogno di un modo per raggiungere il custode o le chiavi. La scelta dipende da quanta sicurezza riesci a mantenere, da quanto spesso devi muovere i fondi e da cosa succede ai fondi se non puoi agire tu. I livelli successivi descrivono i compromessi in dettaglio e le soluzioni intermedie.

## medium

Il rischio di controparte della custodia si è visto nella pratica. L'exchange Mt. Gox ha chiuso nel febbraio 2014 dopo che i bitcoin tenuti per i suoi clienti erano spariti, e in seguito ha chiesto la protezione fallimentare. I clienti che avevano un credito verso l'exchange, invece del controllo delle proprie chiavi, dipendevano dai suoi registri e dalla procedura fallimentare che è seguita. La sezione storia dell'app copre l'evento più nel dettaglio.

La self-custody ha modalità di guasto diverse, che riguardano soprattutto segretezza e backup. Un seed o una chiave trapelati permettono a chi li trova di prendere i fondi, e un seed perso o danneggiato non può essere sostituito. Un backup mai verificato può non funzionare quando serve. Sono i rischi descritti nelle voci su chiavi private, wallet seed e backup del seed.

Tra i due estremi, il multisig distribuisce il controllo su più chiavi. In una configurazione M-di-N, una spesa richiede M firme da N chiavi. Una configurazione 2-di-3 può restare spendibile se si perde una chiave, e può restare al sicuro se una chiave viene rubata, purché l'attaccante non ottenga anche una seconda chiave. Le chiavi possono stare su dispositivi separati o in luoghi separati, ed è per questo che il multisig è spesso descritto come una via di mezzo. La voce multisig descrive come lo script e le firme si incastrano tra loro.

Un'idea collegata è la custodia collaborativa. Una chiave è detenuta dall'utente e un'altra da un servizio, e per firmare servono entrambe. Il servizio non può muovere le monete da solo, e neppure l'utente. Questo sposta il rischio invece di eliminarlo. Un servizio che smette di collaborare può bloccare le spese, e se l'utente perde la sua chiave, il recupero dipende dal fatto che il servizio sia ancora disponibile.

## advanced

Un credito verso un custode è un credito su un registro. L'azienda registra i saldi ed esegue i prelievi sui propri sistemi, quindi la protezione del depositante dipende dalla sua contabilità, dai suoi controlli operativi e dalla sua solvibilità. La guida di Bitcoin.org dice il punto centrale in modo semplice: quando un terzo controlla le tue chiavi, dipendi interamente dalla sua sicurezza e onestà. I termini legali di un servizio specifico sono una questione diversa, e questa voce non li valuta.

La self-custody sposta questa fiducia sulle procedure del proprietario. Possedere il seed equivale a controllare i fondi. La Bitcoin Wiki raccomanda di tenere i backup in più di un luogo, di cifrare ogni copia che tocca una rete, di coprire l'intero wallet e di verificare i backup di tanto in tanto. Ogni passo richiede impegno, e ciascuno può fallire in modo diverso. Anche l'eredità dipende da queste procedure. Gli eredi devono sapere che i fondi esistono, dove si trova il backup e come usarlo, e un piano deve registrare queste informazioni.

Il multisig cambia il significato di un singolo guasto. Il multisig con script pubblica più chiavi pubbliche e la soglia sulla catena quando le monete vengono spese. Il multisig senza script e le firme a soglia pubblicano una chiave e una firma, quindi il pagamento sembra un normale pagamento a firma singola. Bitcoin Optech osserva che questo dà sia maggiore privacy sia costi più bassi. Nelle soluzioni a soglia, un sottoinsieme dei firmatari può firmare. Per esempio, in una configurazione 2-di-3 ciascun firmatario detiene una quota di un'unica chiave, e due firmatari qualsiasi possono produrre insieme una firma valida. Gli osservatori non possono sapere quali parti hanno firmato, il che rende più difficile l'audit da parte di terzi.

Questi schemi hanno compromessi propri. Ogni firmatario deve proteggere una chiave, e il gruppo deve concordare la configurazione, quindi il recupero può diventare più difficile se i partecipanti non conservano registrazioni. Anche il software dei firmatari deve essere compatibile con la configurazione. Una custodia collaborativa aggiunge un'altra parte al processo di firma. La sicurezza della sua chiave, la sua disponibilità e le sue politiche influiscono tutte sulla possibilità dell'utente di spendere, quindi la domanda su chi controlla i fondi non scompare. I percorsi di recupero con timelock possono ridurre alcuni di questi rischi, perché un timelock può impedire che un output venga speso prima di una certa altezza di blocco o di un certo orario, e così una via di recupero diventa disponibile solo dopo un ritardo.
