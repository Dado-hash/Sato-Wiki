---
id: wiki.seed-backups
slug: seed-backups
language: it
category: hardware
subcategory: seed-backups
title: Backup del seed
description: Come si salva una frase seed BIP 39 su carta, metallo o in quote condivise, e dove questi backup di solito falliscono.
difficulty: base
readTimeMinutes: 5
tags:
  - Backup Seed
  - BIP 39
  - SLIP 39
  - Multifirma
  - Recupero
related:
  - wiki.wallet-seeds
  - wiki.hd-wallets
  - wiki.multisig
  - wiki.private-keys
  - wiki.hardware-wallets
sources:
  - title: "BIP 39 - Mnemonic code for generating deterministic keys"
    url: https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki
    author: Marek Palatinus, Pavol Rusnak, Aaron Voisine, Sean Bowe
  - title: "SLIP-0039 - Shamir's Secret-Sharing for Mnemonic Codes"
    url: https://github.com/satoshilabs/slips/blob/master/slip-0039.md
    author: SatoshiLabs
  - title: Codex32
    url: https://bitcoinops.org/en/topics/codex32/
    author: Bitcoin Optech contributors
  - title: Bitcoin.org - Proteggi il tuo wallet
    url: https://bitcoin.org/en/secure-your-wallet
    author: Bitcoin.org contributors
  - title: "Mastering Bitcoin - Capitolo 5, Wallet"
    url: https://github.com/bitcoinbook/bitcoinbook/blob/develop/ch05_wallets.adoc
    author: Andreas M. Antonopoulos
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

Un backup del seed è la copia scritta delle parole che possono ricostruire un wallet. Per la maggior parte dei wallet è una lista di 12 o 24 parole della wordlist BIP 39. Chiunque abbia quelle parole, e la passphrase se ne è stata usata una, può ripristinare ogni chiave creata dal wallet, quindi il backup è sensibile quanto i fondi che protegge.

La maggior parte delle persone inizia dalla carta. La carta è economica e facile da leggere, ma può bruciare, bagnarsi, sbiadire o perdersi durante un trasloco. Le piastre di metallo sono un passo successivo comune, perché resistono al fuoco, all'acqua e alla corrosione meglio della carta. In entrambi i casi il backup deve stare in un luogo riservato e asciutto, ed è utile controllarlo ogni tanto, perché un backup mai verificato potrebbe essere illeggibile quando serve.

Non conservare mai un seed in forma digitale. Un file di testo, una foto, un'app di note, una bozza di email o un cloud possono essere copiati, sincronizzati o letti da altri. Il seed deve esistere solo come parole fisiche che scrivi tu stesso e tieni offline. Il livello medium spiega come dividere un backup e perché alcuni metodi sono più deboli di quanto sembrino.

## medium

La prima scelta riguarda il supporto: carta, metallo inciso, o entrambi. I fogli di carta sono semplici, ma si deteriorano. Le piastre di metallo sono progettate per resistere a calore, acqua e corrosione, ma servono comunque in un luogo sicuro, perché chiunque veda le parole può usarle. Molte persone conservano due copie in luoghi diversi, così che un evento come un'alluvione o un incendio non distrugga tutte le copie.

La seconda scelta riguarda la divisione del segreto. Scrivere le parole su biglietti separati, per esempio la prima metà su un biglietto e la seconda su un altro, non offre una protezione a soglia. Ogni pezzo è una parte utilizzabile del segreto, quindi chi trova un pezzo parte già avvantaggiato. Lo Shamir's Secret Sharing funziona diversamente. Divide il segreto in quote, e un numero di quote inferiore alla soglia non rivela nulla. Lo standard SLIP-0039 definisce questo approccio per i backup dei wallet. Le quote sono scritte come liste di parole con un checksum che rileva gli errori. In uno schema 2-of-3, due quote qualsiasi su tre bastano per recuperare il segreto.

La multifirma è una terza opzione. Invece di un unico seed da proteggere, il wallet richiede firme da più chiavi, ognuna su un proprio dispositivo o seed. Perdere un seed non fa perdere i fondi se la soglia può ancora essere raggiunta. La multifirma aggiunge però complessità. La configurazione del wallet va registrata, e il recupero dipende dal fatto che ogni titolare di chiave conservi la propria parte.

La passphrase aggiunge un secondo segreto. Deve essere difficile da indovinare e richiede un backup proprio, conservato separatamente dal seed. Una passphrase persa rende i fondi irrecuperabili, e una passphrase scritta accanto al seed non offre alcuna protezione contro chi trova entrambi.

I backup falliscono in modi ordinari: una copia si perde durante un trasloco, un familiare non riesce a trovarla quando serve, una foto si sincronizza con un account cloud, oppure una parola viene letta male per una grafia poco chiara.

## advanced

Un backup del seed è un punto singolo di guasto, quindi il suo progetto deve bilanciare tre rischi: perdere il segreto, lasciare che altri lo trovino e rendere il recupero troppo difficile da eseguire. Ogni metodo sposta il peso da un rischio all'altro.

La durabilità fisica è il primo livello. La carta può cedere per acqua, calore, luce e manipolazione, e chiunque la trovi può leggerla. Il metallo resiste meglio al calore e all'acqua, ma le parole incise o punzonate rivelano comunque il seed a chi le vede. Bitcoin.org consiglia di conservare i backup in più luoghi, così che nessun singolo evento possa eliminare l'accesso, e avverte che qualsiasi backup conservato online è molto esposto al furto.

Gli schemi a soglia affrontano il punto singolo di guasto in modo diverso. Lo Shamir's Secret Sharing divide un segreto in modo che serva una soglia di quote per ricostruirlo. SLIP-0039 definisce una struttura a due livelli: il segreto master viene diviso in quote di gruppo, e ogni quota di gruppo viene divisa di nuovo tra i membri. Questo permette una fiducia non uniforme, per esempio un familiare che custodisce una quota e un avvocato che ne custodisce un'altra. Le quote sono scritte con 20 o 33 parole tratte da una lista di 1.024 parole, e le ultime tre parole sono un checksum che rileva errori fino a tre parole. Codex32 è una codifica correlata per i seed BIP 32, che Bitcoin Optech descrive come comoda da conservare su carta. Entrambi gli schemi scambiano semplicità con resilienza. La procedura è più lunga, e un errore in una quota può rendere il recupero più difficile, quindi il processo va provato prima che serva.

La multifirma sposta il problema del backup a livello di wallet. Ogni chiave è custodita su un proprio dispositivo o seed, e spendere richiede una soglia di firme. Una chiave compromessa non rivela le altre. Il costo è che le informazioni di configurazione del wallet vanno conservate, e che il recupero dipende da software compatibile.

La passphrase è un secondo segreto, non un checksum. Una passphrase sbagliata durante il ripristino produce un altro wallet valido, e il software non può dire che la passphrase è errata. Deve essere robusta e va salvata separatamente, perché perderla rende i fondi irrecuperabili. Conservarla insieme al seed elimina la sua protezione contro chi trova il backup.

Il checksum di BIP 39 individua molti errori di trascrizione, ma non tutti, quindi vale la pena controllare con cura le parole scritte.
