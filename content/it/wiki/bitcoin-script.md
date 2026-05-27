---
id: wiki.bitcoin-script
slug: bitcoin-script
language: it
category: protocol
title: Bitcoin Script
description: Il linguaggio di programmazione basato su stack che definisce le condizioni di spesa e le regole di autorizzazione per ogni UTXO sulla rete Bitcoin.
coverImage: media/wiki/bitcoin-script/script-hero.svg
difficulty: advanced
readTimeMinutes: 10
tags:
  - Script
  - Transazioni
  - UTXO
  - Opcode
  - SegWit
  - Taproot
related:
  - wiki.transactions
  - wiki.utxo-model
  - wiki.blocks
  - wiki.consensus-rules
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: Bitcoin Developer Reference - Transactions
    url: https://developer.bitcoin.org/reference/transactions.html
    author: Bitcoin.org contributors
  - title: "BIP 141 - Segregated Witness"
    url: https://github.com/bitcoin/bips/blob/master/bip-0141.mediawiki
    author: Eric Lombrozo, Johnson Lau, Pieter Wuille
  - title: "BIP 341 - Taproot: regole di spesa SegWit versione 1"
    url: https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki
    author: Pieter Wuille, Jonas Nick, Anthony Towns
  - title: "BIP 342 - Validazione degli script Taproot"
    url: https://github.com/bitcoin/bips/blob/master/bip-0342.mediawiki
    author: Pieter Wuille, Jonas Nick, Anthony Towns
updatedAt: 2026-05-27T00:00:00Z
---

## base

Bitcoin Script è il linguaggio di programmazione che Bitcoin usa per stabilire le condizioni di spesa sulle transazioni. Ogni UTXO ha uno script di blocco, chiamato `scriptPubKey`, che definisce chi può spenderlo. Per spendere quell'UTXO bisogna fornire uno script di sblocco — lo `scriptSig` nelle transazioni legacy o il witness in quelle SegWit — che soddisfi le condizioni dello script di blocco.

Script è basato su stack: tutte le operazioni lavorano su una pila last-in-first-out. Non ci sono variabili, cicli o chiamate a funzione. Il linguaggio è volutamente semplice e non Turing-completo. Non può eseguire calcoli illimitati perché non ha costrutti di iterazione e il numero totale di operazioni per script è strettamente limitato.

L'idea centrale è diretta: lo script di blocco descrive un enigma e lo script di sblocco fornisce la soluzione. I due script vengono concatenati ed eseguiti insieme. Se l'esecuzione combinata lascia un valore vero sulla cima dello stack, la spesa è valida.

![Script di blocco e sblocco](media/wiki/bitcoin-script/script-hero.svg "Lo script di blocco (scriptPubKey) protegge ogni UTXO. Chi spende fornisce uno script di sblocco che ne soddisfa le condizioni.")

## medium

L'esecuzione dello script combina script di sblocco e script di blocco in un'unica sequenza. Nelle transazioni legacy, lo scriptSig viene spinto per primo, poi viene eseguito lo scriptPubKey. In P2PKH il risultato è:

`<sig> <pubKey> OP_DUP OP_HASH160 <pubKeyHash> OP_EQUALVERIFY OP_CHECKSIG`

Lo stack parte vuoto. La firma e la chiave pubblica vengono spinte, poi ogni opcode consuma, trasforma o spinge nuovi dati. Lo script combinato deve terminare con un valore vero sullo stack perché la transazione sia valida.

### Tipi di script comuni

| Tipo | Script di blocco (approx.) | Descrizione |
|------|----------------------------|-------------|
| P2PK | `<pubKey> OP_CHECKSIG` | Paga direttamente a una chiave pubblica. Raro oggi. |
| P2PKH | `OP_DUP OP_HASH160 <hash> OP_EQUALVERIFY OP_CHECKSIG` | Paga a un hash di chiave pubblica. Standard per indirizzi legacy. |
| P2SH | `OP_HASH160 <scriptHash> OP_EQUAL` | Paga a un hash di script. Chi spende rivela il redeem script. |
| P2WPKH | `OP_0 <hash>` | Paga a un hash di chiave pubblica via witness. Versione SegWit di P2PKH. |
| P2WSH | `OP_0 <scriptHash>` | Paga a un hash di script via witness. Versione SegWit di P2SH. |
| P2TR | `OP_1 <x-only-pubkey>` | Paga a Taproot. Supporta spesa via chiave e via script. |

### Esecuzione combinata

I nodi Bitcoin non valutano scriptSig e scriptPubKey separatamente. Li concatenano e li eseguono come un unico programma. Questa scelta permette allo script di blocco di validare i dati forniti dallo script di sblocco all'interno dello stesso ambiente di esecuzione.

### ScriptSig vs. Witness

Prima di SegWit, tutti i dati di sblocco stavano nel campo `scriptSig` dentro l'input della transazione. Questo significava che la firma stessa faceva parte dei dati a cui il `txid` faceva commitment — rendendo l'ID della transazione malleabile: terze parti potevano cambiare la rappresentazione della firma e alterare il txid senza invalidare la spesa.

SegWit ha spostato i dati di sblocco in una struttura witness separata. Il witness non è incluso nel calcolo del `txid`. Questo ha eliminato il vettore di malleabilità e ha permesso ai nodi di validare gli script senza trasmettere i dati witness ai peer non SegWit.

## advanced

### Categorie di opcode

Gli opcode di Bitcoin Script sono divisi in gruppi funzionali. Solo un sottoinsieme è abilitato nelle regole di consenso attuali.

**Operazioni sullo stack.** `OP_DUP` duplica l'elemento in cima. `OP_SWAP` scambia i primi due elementi. `OP_DROP` rimuove l'elemento in cima. `OP_PICK` e `OP_ROLL` copiano o spostano un elemento da più in profondità nello stack.

**Aritmetica.** `OP_ADD`, `OP_SUB`, `OP_NEGATE`, `OP_ABS`, `OP_WITHIN`. I numeri sono codificati come interi signed little-endian fino a 4 byte. Gli opcode aritmetici spingono risultati numerici sullo stack.

**Bitwise.** `OP_EQUAL` e `OP_EQUALVERIFY` confrontano due elementi per uguaglianza esatta di byte. Diversi opcode bitwise come `OP_AND`, `OP_OR`, `OP_XOR`, `OP_LSHIFT` e `OP_RSHIFT` esistono nella specifica originale ma sono disabilitati in Bitcoin Core.

**Crypto.** `OP_RIPEMD160`, `OP_SHA1`, `OP_SHA256`, `OP_HASH160` (SHA256 seguito da RIPEMD160) e `OP_HASH256` (doppio SHA256) calcolano hash. `OP_CHECKSIG` verifica una firma ECDSA contro una chiave pubblica e un messaggio. `OP_CHECKMULTISIG` verifica firme M-of-N multisignature. Taproot ha introdotto `OP_CHECKSIGADD` per la verifica Schnorr aggregata.

**Timelock.** `OP_CHECKLOCKTIMEVERIFY` (BIP-65) rifiuta una spesa finché non viene raggiunta una certa altezza di blocco o timestamp UNIX. `OP_CHECKSEQUENCEVERIFY` (BIP-112) rifiuta una spesa finché non è trascorso un numero relativo di blocchi o di tempo.

### Limiti dello script

Le regole di consenso impongono limiti severi alla valutazione degli script:

- **Limite di 201 opcode.** Nessuno script può contenere più di 201 opcode non di push. Le operazioni di push (inserimento dati) non sono contate.
- **10.000 operazioni di firma.** Il numero totale di operazioni di verifica firma tra tutti gli input in un blocco non può superare 10.000. Questo limita il tempo CPU di validazione del blocco.
- **Dimensione elementi stack.** Ogni elemento sullo stack può essere al massimo di 520 byte negli script legacy. SegWit ha aumentato questo limite in certi contesti.
- **Dimensione script.** Gli script non SegWit sono limitati a 10.000 byte. Gli script SegWit hanno un limite di 10.000 byte per la parte script del witness.
- **Profondità stack.** Lo stack combinato può contenere al massimo 1.000 elementi.

### Cambiamenti di script con SegWit

SegWit (BIP 141) ha cambiato radicalmente la validazione degli script. In un input SegWit, lo `scriptSig` viene sostituito con un push del witness program, e i dati witness veri e propri vengono messi in un campo `witness` separato fuori dal corpo della transazione.

La conseguenza critica: il witness non è oggetto del commitment del `txid`, ma solo del `wtxid`. Questo significa che:
- La malleabilità delle transazioni non si applica più alle spese SegWit.
- I nodi possono eliminare i dati witness dopo la validazione senza rompere i riferimenti a transazioni future.
- Il versionamento degli script è diventato possibile: il byte di versione del witness (attualmente 0 o 1) seleziona le regole di validazione.

P2WPKH è l'equivalente SegWit di P2PKH ma usa una prova più piccola e sposta la chiave pubblica e la firma nel witness. Lo `scriptPubKey` è semplicemente `OP_0 <hash-da-20-byte>` — solo 22 byte contro i 25 byte di uno `scriptPubKey` P2PKH.

### Taproot e MAST

Taproot (BIP 341, attivato nel 2021) ha introdotto i cambiamenti più significativi agli script dopo SegWit. L'innovazione centrale è il Merkelized Abstract Syntax Tree (MAST).

In una spesa basata su MAST, lo script di blocco fa commitment a un albero di Merkle di foglie di script. Chi spende rivela solo lo script che effettivamente esegue e il percorso Merkle che prova che è nell'albero. Questo significa che:

- Le condizioni di spesa inutilizzate rimangono nascoste al momento della spesa.
- Grandi firme multisignature o contratti complessi appaiono come una singola chiave pubblica sulla chain.
- La privacy migliora perché la maggior parte delle spese sembra identica.

Taproot aggiunge due percorsi di spesa:

**Spesa via chiave (key-path).** Il caso più semplice e comune. Chi spende fornisce una firma Schnorr per la chiave pubblica impegnata nello `scriptPubKey`. Non viene rivelato alcuno script. Questo è il default per i wallet a singolo firmatario.

**Spesa via script (script-path).** Chi spende rivela quale foglia di script sta eseguendo più il percorso Merkle fino a quella foglia. Lo script viene poi valutato normalmente. Questo percorso viene usato quando il firmatario key-path non è disponibile o quando la spesa deve soddisfare una condizione multisignature o di timelock.

### OP_CHECKSIGADD e Schnorr

Taproot ha sostituito il vecchio `OP_CHECKMULTISIG` con un nuovo opcode, `OP_CHECKSIGADD` (BIP 342). Invece del complesso design M-of-N con il suo famoso bug off-by-one (dove un elemento fittizio deve essere spinto prima delle firme), `OP_CHECKSIGADD` usa un accumulatore:

Si parte con un contatore a 0. Per ogni chiave pubblica, si esegue `OP_CHECKSIGADD`. Se la firma corrisponde a quella chiave, il contatore aumenta di 1. Alla fine, si verifica che il contatore sia almeno uguale alla soglia richiesta.

Le firme Schnorr (BIP 340) permettono questo design perché supportano la verifica batch: più firme possono essere validate insieme più velocemente che validandole singolarmente. Schnorr permette anche l'aggregazione delle firme, dove più firmatari producono una singola firma per una singola chiave pubblica.

### Opcode disabilitati e sicurezza

Diversi opcode della specifica originale sono disabilitati in Bitcoin Core. Rimangono disabilitati perché ritenuti pericolosi o mal specificati:

- **OP_CAT.** Concatena due elementi dello stack. Disabilitato perché poteva essere usato per costruire strutture ricorsive e abilitare attacchi denial-of-service.
- **OP_LSHIFT, OP_RSHIFT.** Shift bitwise. Disabilitati dopo problemi di overflow di interi.
- **OP_OR, OP_AND, OP_XOR.** Logica bitwise. Disabilitati per limitare l'espressività degli script ed evitare comportamenti imprevisti.
- **OP_VERIF, OP_VERNOTIF.** Opcode condizionali che potevano creare condizioni di spesa opache.
- **OP_MUL, OP_DIV, OP_MOD.** Aritmetica disabilitata dopo l'incidente di overflow del 2010.

Il principio generale è conservativo: se un opcode abilita calcoli che non possono essere limitati o introduce ambiguità sul suo effetto, rimane disabilitato. La comunità Bitcoin ha sempre dato priorità a prevedibilità e sicurezza rispetto all'espressività. I nuovi opcode richiedono un BIP, analisi attenta e ampio consenso prima dell'attivazione.

![Flusso di esecuzione script P2PKH](media/wiki/bitcoin-script/script-execution.svg "Ogni passo dell'esecuzione di uno script P2PKH, che mostra lo stack prima e dopo ogni opcode.")
