---
id: wiki.onion-routing
slug: onion-routing
language: it
category: lightning network
title: Onion Routing
description: Il protocollo di comunicazione che preserva la privacy nella Lightning Network, crittografando i dati di pagamento a strati in modo che nessun nodo intermedio conosca l'intero percorso.
coverImage: media/wiki/onion-routing/onion-routing-layers.svg
difficulty: advanced
readTimeMinutes: 9
tags:
  - Lightning Network
  - Onion Routing
  - Privacy
  - Sphinx
  - Routing
related:
  - wiki.lightning-network
  - wiki.htlcs
  - wiki.payment-channels
  - wiki.lightning-invoices
  - wiki.routing-fees
  - wiki.multipath-payments
sources:
  - title: "BOLT #4 — Onion Routing"
    url: https://github.com/lightning/bolts/blob/master/04-onion-routing.md
    author: Lightning Network Specifications
    publishedAt: 2016-04-01
  - title: "The Sphinx Mix Network Protocol"
    url: https://www.cypherpunks.ca/~iang/pubs/Sphinx_Oakland09.pdf
    author: George Danezis, Ian Goldberg
    publishedAt: 2009-05-01
  - title: "Mastering the Lightning Network — Chapter 8: Onion Routing"
    url: https://github.com/lnbook/lnbook
    author: Andreas M. Antonopoulos, Olaoluwa Osuntokun, Rene Pickhardt
updatedAt: 2026-05-27T00:00:00Z
---

## base

L'onion routing è una tecnica di privacy che avvolge i dati di pagamento in molteplici strati di crittografia, come gli strati di una cipolla. Quando Alice paga Carol attraverso nodi intermedi, costruisce un pacchetto in cui ogni strato può essere aperto solo da un nodo specifico. Ogni nodo intermedio rimuove uno strato, apprende solo l'identità del salto successivo e inoltra il payload crittografato rimanente.

**Analogia.** Immagina di passare una lettera sigillata dentro una serie di buste concentriche. Alice mette una lettera (il pagamento) dentro una busta indirizzata a Carol. Colloca quella dentro un'altra busta indirizzata a Diana, che a sua volta va dentro una busta indirizzata a Bob. Bob riceve il plico, apre solo la busta esterna, legge "inoltra a Diana" e passa il resto. Diana apre la sua busta, vede "inoltra a Carol" e inoltra la busta interna. Carol apre l'ultima busta e legge i dettagli del pagamento. Nessun corriere vede mai il percorso completo.

**Proprietà di privacy.** Solo il mittente conosce la route completa. Ogni intermediario vede esattamente due nodi: il nodo che gli ha inviato il pacchetto e il nodo a cui deve inoltrarlo. Questa proprietà protegge la privacy sia del mittente che del destinatario — un nodo intermedio non può determinare chi ha originato un pagamento né chi lo riceve definitivamente.

![Strati dell'onion routing](media/wiki/onion-routing/onion-routing-layers.svg "Alice costruisce una cipolla con tre strati. Bob rimuove lo strato esterno, Diana quello intermedio e Carol riceve i dati di pagamento interni. Ogni nodo vede solo il proprio salto.")

## medium

**Source routing.** Nella Lightning Network, il mittente sceglie l'intero percorso. Prima di costruire la cipolla, Alice esegue un algoritmo di pathfinding sul grafo della rete (scoperto tramite il protocollo gossip) per selezionare una route di canali collegati con liquidità sufficiente. Il percorso selezionato viene codificato nella cipolla, stratificato in ordine inverso — lo strato più esterno è crittografato per il primo salto, il successivo per il secondo, e così via. Lo strato più interno è per il destinatario finale.

**Costruzione della cipolla.** Alice genera una serie di chiavi ECDH effimere (Elliptic Curve Diffie-Hellman), una per ogni salto. Per ogni salto, deriva un segreto condiviso usando la sua chiave privata effimera e la chiave pubblica del nodo. Questo segreto condiviso genera una chiave di crittografia simmetrica (usando ChaCha20-Poly1305, in precedenza AES-256 nelle prime versioni di BOLT 4) e una chiave MAC. Alice crittografa ogni strato partendo dal più interno: il payload per Carol è crittografato con la chiave di Carol, avvolto dentro il payload di Diana crittografato con la chiave di Diana, avvolto dentro il payload di Bob crittografato con la chiave di Bob. Il risultato è un pacchetto cipolla di dimensione fissa.

**Il protocollo Sphinx.** L'onion routing di Lightning è costruito sul protocollo Sphinx, progettato da George Danezis e Ian Goldberg nel 2009. Sphinx fornisce tre garanzie:
- **Compattezza:** la dimensione del pacchetto rimane costante indipendentemente dalla lunghezza del percorso.
- **Protezione dal replay:** ogni pacchetto include un tag univoco che impedisce ai nodi di vedere lo stesso pacchetto due volte e di collegarlo allo stesso mittente.
- **Integrità:** ogni strato include un MAC (Message Authentication Code) che il nodo verifica prima di accettare il pacchetto. Qualsiasi manomissione di un byte causa il fallimento del controllo MAC.

**Payload per salto.** Quando un nodo rimuove il suo strato, trova:
- La chiave pubblica del nodo o l'ID del canale breve del salto successivo.
- I parametri HTLC: importo da inoltrare, scadenza CLTV.
- Padding opzionale o dati TLV aggiuntivi.
- Il resto della cipolla (strati interni) da inoltrare.

Il nodo non vede l'importo del pagamento per il destinatario finale, la lunghezza totale del percorso o le identità dei nodi oltre i suoi vicini immediati.

**Struttura del pacchetto.** BOLT 4 definisce il pacchetto cipolla come esattamente 1300 byte: una dimensione fissa indipendentemente dalla lunghezza del percorso. Questo impedisce l'analisi del traffico basata sulla dimensione del pacchetto. Il pacchetto contiene:
- Un campo versione di 1 byte.
- Una chiave pubblica effimera di 33 byte.
- Un tag di protezione dal replay di 32 byte.
- Un HMAC di 32 byte per l'intero pacchetto.
- 1300 byte di dati di salto crittografati (nelle implementazioni moderne, payload TLV da 1300 byte; nelle legacy, 20 campi a lunghezza fissa di 65 byte con filler).

La dimensione fissa impedisce a un attaccante di determinare se un pacchetto sta attraversando 2 o 20 salti.

![Percorso di pagamento multi-hop](media/wiki/onion-routing/payment-path.svg "Alice seleziona un percorso attraverso Charlie, Bob e Diana fino a Carol. Gli HTLC fluiscono in avanti lungo il percorso; il preimmagine ritorna in direzione inversa. Ogni nodo conosce solo il suo predecessore e successore.")

## advanced

**Costruzione Sphinx: derivazione del segreto condiviso.** Per ogni salto lungo il percorso, Alice calcola un segreto condiviso usando l'accordo di chiave Diffie-Hellman. Sia la sequenza di nodi N₀ (Alice), N₁, N₂, ..., Nₙ (Carol). Per il salto i, Alice genera una coppia di chiavi effimere (eᵢ, Eᵢ) dove Eᵢ = eᵢ × G. Il segreto condiviso con il nodo Nᵢ è:

```
ssᵢ = SHA256(eᵢ × pubkeyᵢ)
```

In pratica, viene generata una singola coppia di chiavi effimere (e, E) e i segreti condivisi vengono derivati usando un fattore di blinding che ri-randomizza la chiave effimera a ogni salto:

```
ss₁ = SHA256(e × pubkey₁)
E₁ = E
ss₂ = SHA256(e₁ × pubkey₂)  dove e₁ = SHA256(ss₁) × e
E₂ = SHA256(ss₁) × E₁
...
ssᵢ = SHA256(eᵢ₋₁ × pubkeyᵢ)
Eᵢ = SHA256(ssᵢ₋₁) × Eᵢ₋₁
```

Questo blinding garantisce che ogni salto veda una chiave pubblica effimera diversa, impedendo a qualsiasi nodo di correlare il pacchetto cipolla attraverso salti multipli. Un nodo intermedio vede Eᵢ e deriva ssᵢ usando la propria chiave privata, ma non può collegare Eᵢ a Eᵢ₋₁ o Eᵢ₊₁ senza i fattori di blinding.

**Fattori di blinding.** La ri-randomizzazione della chiave effimera usando SHA256(ssᵢ) come fattore di blinding è critica per la non-collegabilità. Senza blinding, un nodo che vede la stessa chiave effimera in due posizioni diverse sulla rete potrebbe dedurre che appartengono allo stesso pagamento. Il fattore di blinding rompe completamente questa correlazione — la chiave effimera è diversa a ogni salto, e solo il mittente può ricalcolare la catena.

**Verifica MAC.** Ogni strato della cipolla include un MAC di 32 byte calcolato sul payload crittografato. La chiave MAC è derivata dal segreto condiviso:

```
mac_keyᵢ = HMAC-SHA256(ssᵢ, "mac_key")
```

Quando un nodo riceve il pacchetto cipolla, calcola il MAC usando la sua chiave derivata e lo confronta con il MAC nel pacchetto. Se il MAC non corrisponde, il pacchetto non è valido e il nodo DEVE rifiutarlo. Questo rileva qualsiasi manomissione — se Bob modifica un byte della cipolla prima di inoltrarla, il controllo MAC di Diana fallirà e lei rifiuterà il pacchetto.

**Algoritmo di generazione del filler.** La dimensione fissa di 1300 byte crea una sfida: man mano che la cipolla viene rimossa a ogni salto, il payload grezzo rimanente si riduce. Per mantenere la dimensione del pacchetto costante, il mittente riempie gli strati interni con una stringa di filler. Il filler è generato usando un cifrario a flusso keyato con una chiave di filler derivata dal segreto condiviso di ogni salto. Il mittente genera il filler per tutti i salti e lo impacchetta attorno ai dati rimanenti della cipolla, in modo che dopo ogni rimozione il payload visibile sia sempre esattamente 1300 byte. Un attaccante non può distinguere tra dati di salto reali e filler, nascondendo la lunghezza rimanente del percorso.

**Payload legacy BOLT 4 vs TLV.** Le prime implementazioni BOLT 4 usavano un payload per salto in formato fisso di 65 byte con campi specifici a offset fissi (importo, scadenza CLTV, salto successivo, padding). Questo formato legacy era rigido e richiedeva aggiornamenti del protocollo per cambiare la struttura del payload. Le implementazioni moderne usano la codifica TLV (Type-Length-Value) all'interno della cipolla, permettendo un'estensibilità flessibile:

- **Cipolla TLV:** ogni payload per salto è una sequenza di record TLV. Nuovi tipi possono essere aggiunti senza cambiare il formato della cipolla, abilitando funzionalità come route blinding, KeySend e Trampoline routing.
- **Compatibilità all'indietro:** i nodi segnalano il supporto TLV nei loro feature bit. Un nodo con capacità TLV può ricevere cipolle legacy e viceversa, anche se l'insieme completo delle funzionalità moderne richiede che entrambe le parti supportino TLV.

**KeySend e pagamenti spontanei.** KeySend è un'estensione che permette pagamenti senza una fattura pre-generata. In un pagamento normale, il destinatario genera il preimage, calcola l'hash di pagamento H(x) e lo fornisce al mittente in una fattura. Con KeySend, il mittente genera il preimage e l'hash di pagamento da solo, quindi incorpora il preimage nel payload della cipolla crittografato per il destinatario finale. Il destinatario decritta il payload, apprende il preimage e riscuote l'HTLC. Questo elimina lo scambio di fatture, abilitando pagamenti spontanei come mance e donazioni dove il mittente inizia senza coordinamento preventivo.

**Trampoline routing.** Nel source routing, il mittente deve conoscere l'intera topologia della rete per selezionare un percorso. Questo è impraticabile per wallet mobili con larghezza di banda e batteria limitate. Il Trampoline routing delega la scelta del percorso a nodi Trampoline designati. Il mittente specifica il destinatario finale e i dettagli del pagamento in una cipolla interna, e il nodo Trampoline gestisce la selezione del percorso rimanente. Il mittente costruisce una cipolla multi-strato dove gli strati esterni instradano verso il nodo Trampoline, e lo strato interno (crittografato per il destinatario) è opaco per il Trampoline. Salti Trampoline multipli possono essere concatenati, ognuno facendo pathfinding locale per il proprio segmento. Questo riduce i requisiti di banda del mittente al costo di rivelare il destinatario finale al nodo Trampoline.

**Route blinding (BOLT 4).** Il route blinding nasconde il destinatario finale da tutti i nodi intermedi, incluso l'ultimo nodo pubblico prima del destinatario. Il destinatario genera una route nascosta: una sequenza di ID di nodo offuscati e istruzioni di inoltro crittografate che il mittente usa come coda del percorso di pagamento. Ogni salto nel segmento nascosto può essere decrittato solo dal nodo specifico, e il salto finale rivela solo l'ID offuscato del destinatario — non la sua chiave pubblica reale. Il destinatario genera più route nascoste in anticipo e le distribuisce tramite fatture o altri canali. Il route blinding è specificato in BOLT 4 come estensione TLV ed è critico per la privacy contro avversari che operano nodi di routing sulla rete.
