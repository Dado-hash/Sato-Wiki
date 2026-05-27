---
id: wiki.merkle-trees
slug: merkle-trees
language: it
category: cryptography
title: Merkle Trees
description: La struttura ad albero binario di hash che Bitcoin usa per impegnare le transazioni nei blocchi e consentire prove di appartenenza efficienti.
coverImage: media/wiki/merkle-trees/merkle-tree.svg
difficulty: advanced
readTimeMinutes: 8
tags:
  - Crittografia
  - Merkle Tree
  - Blocchi
  - Strutture Dati
related:
  - wiki.hash-functions
  - wiki.sha-256
  - wiki.blocks
  - wiki.segregated-witness
sources:
  - title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
    url: https://bitcoin.org/bitcoin.pdf
    author: Satoshi Nakamoto
    publishedAt: 2008-10-31
  - title: "Merkle, R. C. - Protocols for Public Key Cryptosystems"
    url: https://www.win.tue.nl/~berry/2WC15/Literature/Merkle-1980.pdf
    author: Ralph C. Merkle
    publishedAt: 1980
  - title: "Bitcoin Developer Reference - Merkle Trees"
    url: https://developer.bitcoin.org/reference/block_chain.html#merkle-trees
    author: Bitcoin.org contributors
updatedAt: 2026-05-27T00:00:00Z
---

## base

Un Merkle tree è un albero binario di hash. Ogni foglia è il doppio hash SHA-256 di una transazione; ogni nodo interno è il doppio hash SHA-256 dei suoi due figli concatenati. L'unico hash in cima si chiama Merkle root. Impegna ogni transazione del blocco -- cambiare un singolo byte in una qualsiasi transazione produce una radice completamente diversa.

![Diagramma Merkle tree](media/wiki/merkle-trees/merkle-tree.svg "Quattro transazioni hashate a coppie fino a una Merkle root. Una prova per Tx2 richiede solo Tx3 e H01.")

La Merkle root vive nell'header del blocco. Questo è ciò che rende possibili i client leggeri. Un portafoglio SPV (Simplified Payment Verification) può verificare che una transazione appartenga a un blocco scaricando solo l'header del blocco (80 byte) e una Merkle proof -- un percorso di hash dalla transazione fino alla radice -- invece dell'intero blocco. La dimensione della prova cresce come log2(n), quindi un blocco con migliaia di transazioni necessita solo di una manciata di hash.

Pensa alla Merkle root come a un checksum crittografico per una lista ordinata di transazioni. Come un hash identifica un singolo dato, la Merkle root identifica un intero insieme di transazioni.

## medium

Per costruire un Merkle tree, parti dalla lista degli hash delle transazioni. Accoppia hash adiacenti, concatenali e applica il doppio SHA-256. Questo produce una nuova lista grande la metà. Ripeti fino a quando rimane un solo hash: la Merkle root.

```
Livello 2:              Root = H(H01 || H23)
                        /                   \
Livello 1:        H01 = H(Tx0 || Tx1)     H23 = H(Tx2 || Tx3)
                  /           \             /           \
Livello 0:     Tx0           Tx1           Tx2           Tx3
```

Bitcoin usa il doppio SHA-256 per tutti gli hash Merkle: SHA-256 applicato due volte, indicato come SHA256d. Coincide con l'algoritmo di hashing usato per mining e indirizzi.

Quando un livello ha un numero dispari di hash, l'ultimo hash viene duplicato prima dell'accoppiamento. Un albero con cinque transazioni accoppia la quinta con se stessa. Questa regola garantisce che l'albero converga sempre a una singola radice. La stessa regola si applica a ogni livello, quindi un conteggio dispari al livello 1 produce anch'esso un hash interno duplicato.

Una Merkle proof fornisce gli hash fratelli lungo il percorso da una transazione alla radice. Per dimostrare che Tx2 è nell'albero sopra, un portafoglio ha bisogno di Tx3 e H01. Il verificatore calcola H23 = H(Tx2 || Tx3), poi Root = H(H01 || H23) e controlla che il risultato corrisponda alla Merkle root nell'header del blocco. Servono solo log2(n) hash, quindi una prova per una transazione in un blocco da 2000 transazioni è di 11 hash (circa 352 byte).

Un blocco vuoto ha comunque una Merkle root. Quando un blocco non ha transazioni (solo la coinbase), la Merkle root è il doppio SHA-256 di una stringa di byte vuota: SHA256(SHA256("")).

## advanced

Il semplice Merkle tree descritto sopra ha note debolezze crittografiche, e Bitcoin ha adottato diverse varianti per affrontarle.

**Attacco di second-preimage.** Un Merkle tree ingenuo è vulnerabile a un attacco di second-preimage. Se un attaccante riesce a far sembrare i dati di un nodo foglia un nodo interno valido, può produrre un albero diverso con la stessa radice. Bitcoin mitiga questo rischio anteponendo 0x00 agli hash delle foglie e 0x01 agli hash dei nodi interni prima dell'hashing. Questa separazione di dominio garantisce che foglie e nodi interni non possano mai collidere. Il Prefix-Merkle tree usato in BIP 341 formalizza questo concetto etichettando ogni hash con la sua posizione nell'albero.

**Transazioni duplicate.** Se la stessa transazione appare due volte in un blocco, l'albero ingenuo produce lo stesso hash due volte, il che può portare a sottoalberi bilanciati diversi da quanto atteso. L'hash duplicato a livello foglia si propaga verso l'alto, e con la regola del numero dispari il ramo duplicato può produrre un albero che non è collision-resistant nel senso standard. Le mitigazioni includono l'uso di insiemi ordinati di transazioni e, più fondamentalmente, lo schema di prefisso sopra descritto.

**Segregated Witness.** SegWit (BIP 141) introduce un witness Merkle tree separato. I dati witness vengono spostati dalla lista principale delle transazioni in una struttura witness impegnata da una Merkle root separata, incorporata nella transazione coinbase tramite il witness commitment. Questo permette ai nodi di validare le transazioni senza scaricare i dati witness e consente di potare i dati witness più vecchi. Il witness Merkle tree usa il doppio SHA-256, la regola del numero dispari e la stessa struttura dell'albero principale, ma la sua radice appare nell'output coinbase anziché nell'header del blocco.

**Taproot e BIP 341.** Taproot sostituisce il blocco tradizionale basato su script con un Merkle tree binario di percorsi script. Il TapTweak impegna una Merkle root (il TapLeaf hash tree) concatenata con la chiave pubblica interna. Questo permette agli utenti di spendere un UTXO usando il key path (firma diretta) o rivelando qualsiasi script foglia nell'albero. L'albero è un albero binario di hash TapLeaf o TapBranch, che usa un tagged hash (SHA256 con un tag specifico del dominio) invece del doppio SHA-256. Solo il percorso rivelato è visibile on-chain -- i rami script non eseguiti rimangono nascosti, migliorando la privacy e riducendo la dimensione delle transazioni.

**Relay di blocchi compatti.** BIP 152 (Compact Blocks) usa la struttura del Merkle tree per un relay efficiente dei blocchi. Invece di inviare transazioni complete, un nodo invia un header del blocco, la lista di short ID delle transazioni (calcolati dall'hash della transazione) e una Merkle proof per ogni transazione che il ricevente dovrebbe già avere. Il ricevente ricostruisce l'intero Merkle tree dalle transazioni nella propria mempool e richiede solo quelle mancanti. Questo riduce drasticamente la larghezza di banda durante la propagazione dei blocchi.

Il Merkle tree è una delle decisioni di design più eleganti di Bitcoin. Disaccoppia la dimensione del blocco dal costo di verifica, abilita i client leggeri e continua a evolversi con ogni aggiornamento del protocollo.
