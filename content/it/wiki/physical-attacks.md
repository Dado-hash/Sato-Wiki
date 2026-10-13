---
id: wiki.physical-attacks
slug: physical-attacks
language: it
category: privacy-security
title: Attacchi fisici
description: Come la coercizione fisica può aggirare la protezione crittografica, quali fattori aumentano il rischio e quali idee di progetto lo riducono, con i loro limiti.
difficulty: base
readTimeMinutes: 5
tags:
  - Sicurezza fisica
  - Coercizione
  - Multisig
  - Timelock
related:
  - wiki.multisig
  - wiki.self-custody
  - wiki.passphrase
  - wiki.timelocks
sources:
  - title: "xkcd 538: Security"
    url: https://xkcd.com/538/
    author: Randall Munroe
  - title: Securing your wallet
    url: https://en.bitcoin.it/wiki/Securing_your_wallet
    author: Bitcoin Wiki contributors
  - title: Secure your wallet
    url: https://bitcoin.org/en/secure-your-wallet
    author: Bitcoin.org contributors
  - title: Timelocks
    url: https://bitcoinops.org/en/topics/timelocks/
    author: Bitcoin Optech
  - title: "BIP 39: Mnemonic code for generating deterministic keys"
    url: https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki
  - title: "BIP 65: OP_CHECKLOCKTIMEVERIFY"
    url: https://github.com/bitcoin/bips/blob/master/bip-0065.mediawiki
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

La crittografia protegge una chiave dall'essere indovinata o copiata. Non protegge il proprietario dall'essere costretto a usarla. Un attacco fisico colpisce la persona, il dispositivo o il luogo in cui sono conservati i segreti, e può riuscire anche quando la matematica regge. L'espressione "$5 wrench attack" è un modo breve per indicare questa situazione. Viene da un fumetto xkcd in cui gli attaccanti rinunciano alla matematica e usano invece un attrezzo economico.

Il rischio dipende in parte da chi sa cosa possiedi. La Bitcoin Wiki consiglia di tenere private le proprie disponibilità, perché una persona il cui patrimonio è noto è un bersaglio più evidente. Anche le registrazioni tenute da altri possono esporre le disponibilità. Una lista di clienti o di titolari di conti rivela chi possiede cosa se trapela, e lo stesso vale per qualsiasi documento che collega un nome a un insieme di chiavi.

La sicurezza dipende quindi dalle persone oltre che dalla tecnologia. La Bitcoin Wiki osserva che le disponibilità sono protette dalle persone e non dalla sola tecnologia, e che anche i dispositivi hardware possono essere aggirati con la coercizione. Le difese dei livelli successivi sono idee di progetto. Ciascuna riduce un rischio e ne lascia altri in piedi, e ciascuna ha limiti che conviene conoscere prima di affidarsi a essa.

## medium

Diverse idee di progetto affrontano gli attacchi fisici, e ciascuna ha un limite.

Non dichiarare le proprie disponibilità riduce il numero di persone che sanno che c'è qualcosa da prendere. Funziona solo finché il segreto regge. Eredi, consulenti e fornitori di servizi possono aver bisogno di conoscere parti dell'organizzazione, e ciascuno è una possibile fonte di divulgazione.

Il multisig distribuisce la possibilità di spendere su più chiavi. Bitcoin.org osserva che una configurazione multisig può impedire a un ladro di prendere i fondi quando un dispositivo o un luogo è compromesso. Chiavi custodite in luoghi separati e affidate a persone diverse fanno sì che nessuna persona da sola possa spendere. Il limite è che una persona costretta a firmare può essere solo una dei vari firmatari, e in un'emergenza può essere difficile raccogliere in tempo le firme richieste.

I ritardi temporali usano i timelock. Bitcoin Optech descrive un timelock come una condizione che impedisce a una spesa di essere confermata prima di una certa altezza di blocco o di un certo momento. Il BIP 65 definisce un timelock assoluto di questo tipo. Un progetto in stile vault può far sì che una spesa abbia effetto solo dopo un ritardo, dando al proprietario la possibilità di accorgersene e annullarla. Il ritardo aiuta solo se il proprietario può vedere cosa succede durante l'attesa. Chi viene tenuto sotto pressione per tutta la durata del ritardo non ne trae alcun vantaggio.

Un wallet con passphrase usato come esca si basa sul BIP 39. Ogni passphrase produce un seed valido, quindi può esistere un secondo wallet dietro una passphrase diversa, con un saldo più piccolo. Il valore di questa idea è discusso. L'esca funziona solo se chi esercita la pressione accetta che il wallet mostrato sia l'intera disponibilità. Una passphrase digitata male apre inoltre un wallet vuoto senza alcun errore, e perdere la passphrase rende irrecuperabili i fondi. Il livello advanced riprende questi punti.

## advanced

La questione centrale è quale segreto una persona può essere costretta a rivelare, e quante persone o dispositivi una minaccia può raggiungere. Ogni segreto, firmatario o luogo in più rende l'attacco più costoso, ma aumenta anche il peso del recupero. Il progetto dovrebbe partire dalle minacce realistiche e dalle persone che devono poter agire in un'emergenza.

Un PIN o una passphrase proteggono da chi ha solo il dispositivo, non da chi può far digitare il codice al proprietario. La Bitcoin Wiki osserva che gli hardware wallet possono essere aggirati con la coercizione. Distribuire le chiavi su dispositivi e luoghi diversi significa che un attaccante deve raggiungere ciascuno di essi, ma anche il proprietario deve poterli raggiungere tutti.

La soglia di un multisig bilancia la portata dell'attaccante con la capacità del proprietario di agire. In una configurazione 2-di-3, un attaccante deve raggiungere due luoghi, mentre la perdita di una chiave non blocca le spese. Una configurazione 3-di-3 è più difficile da attaccare, ma blocca ogni spesa quando una chiave non è raggiungibile. Una soglia più alta non è automaticamente più sicura.

Un timelock può creare un percorso di recupero che si apre dopo un ritardo, oppure una finestra di annullamento in cui una chiave separata può bloccare una spesa inattesa. Bitcoin Optech descrive i timelock come vincoli sugli output, e il BIP 65 fornisce il meccanismo per una scadenza assoluta. L'annullamento funziona solo se la chiave che annulla è disponibile durante la finestra, e il ritardo rallenta anche il recupero del proprietario.

La passphrase esca si basa sul fatto che il BIP 39 accetta ogni passphrase e ricava da ciascuna un seed valido, cosa che la specifica descrive come negazione plausibile. Ne derivano tre limiti. Un'esca deve sembrare una disponibilità reale. Una digitazione sbagliata apre un wallet vuoto senza avvisi, quindi il proprietario non può distinguere un errore di battitura da un'esca. Chi possiede il seed può verificare le passphrase senza il dispositivo, quindi la passphrase deve essere difficile da indovinare. Se un'esca protegga davvero il proprietario sotto una pressione reale non ha una risposta definitiva, perché dipende dal comportamento dell'attaccante.

Anche le registrazioni che collegano una persona alle proprie chiavi sono un rischio. Tenerle al minimo e in luoghi separati limita il danno di una fuga di dati. Nessuna configurazione elimina il rischio fisico. Lo scopo è rendere un attacco più lento, più costoso e più visibile, mantenendo un piano di recupero che il proprietario possa davvero attuare.
