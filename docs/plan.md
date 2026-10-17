# Piano di espansione SatoWiki

Stato al 2026-10-13, branch `develop`, commit `3b6e7f8`.

Questo piano sostituisce il "Piano di ripresa" del 2026-10-12. Il piano precedente resta leggibile con `git show 3b6e7f8:docs/plan.md`. Le sue voci ancora aperte sono state ricontrollate e spostate in `docs/roadmap.md`, sezione "Lavoro aperto ereditato".

Il piano dice **cosa** costruire e **perché**. L'elenco dei task in ordine è in `docs/roadmap.md`. L'elenco delle voci da scrivere è in `docs/content-todo.md`.

## Punto di partenza

- Seed EN e IT allineati: 61 voci wiki, 35 eventi history, 213 BIP, 12 release Bitcoin Core, 1 articolo news.
- La wiki ha 4 categorie: `protocol` (16), `cryptography` (15), `lightning network` (15), `economics` (15).
- La timeline parte dal whitepaper del 2008. Non ci sono eventi precedenti né incidenti tecnici.
- L'app non ha backend. L'unica chiamata di rete è il download dei bundle da GitHub Pages.
- `dart run tool/validate_content.dart` su entrambi i seed: 0 errori, 0 avvisi.

## Da dove vengono le idee

Tre siti sono stati esplorati il 2026-10-13.

| Sito | Copertura | Licenza dei contenuti |
| --- | --- | --- |
| nakamotoinstitute.org | Buona, circa 22 pagine | CC BY-SA 4.0. Il footer avverte che alcune opere hanno altre licenze. Saggi e opere della Library restano dei singoli autori. Email e post di Satoshi non hanno una licenza indicata. |
| en.bitcoin.it | Buona, 23 pagine | CC BY 3.0 secondo il footer. La pagina sul copyright restituisce 404. |
| learnmeabitcoin.com | Scarsa, 1 pagina | Non confermata. Il sito è protetto da una verifica anti-bot che non è stata aggirata. |

Regole di riuso valide per tutto il piano:

- Scrivere testo nostro a partire dai fatti e citare la fonte in `sources`.
- Non copiare passaggi interi da nessuno dei tre siti.
- Per le parole di Satoshi: citazioni brevi, con data, titolo della fonte e link all'originale.
- Da learnmeabitcoin.com si prendono solo idee di formato, non testo né immagini.

Cosa si è visto e si vuole evitare:

- en.bitcoin.it riporta numeri senza data (cita ancora un premio di 6,25 BTC), elenca software non più mantenuto e mescola categorie tematiche con etichette di manutenzione.
- nakamotoinstitute.org mostra circa 140 opere in un solo elenco alfabetico senza filtri, e non segnala quando una traduzione manca.

## Decisioni prese

Confermate da Davide il 2026-10-13.

1. Gli strumenti si fanno tutti e tre: strumenti offline (E1), explorer con dati dalla rete (E2), demo interattive (E3), compresa "Mina un blocco".
2. Strumenti ed explorer stanno dentro la tab **Code**. La barra resta a 5 tab.
3. La wiki riceve due categorie nuove, **Software** e **Hardware**. Ciascuna ha delle sottocategorie (mining, hardware wallet, software wallet e così via). Le schede dei singoli prodotti arrivano dopo le voci di sottocategoria.
4. Le sottocategorie sono quelle elencate in A1: 7 per Software e 4 per Hardware.
5. Il server predefinito dell'explorer è mempool.space. L'utente può sostituirlo con il proprio.
6. Le demo interattive comprendono un laboratorio sulla blockchain in più passi, sul modello di `anders94/blockchain-demo`.
7. RIPEMD-160, Base58Check e bech32/bech32m si scrivono in Dart nel repository, senza dipendenze nuove. Sono algoritmi piccoli e stabili, e i vettori di test ufficiali li verificano.
8. Le schede prodotto seguono il criterio di inclusione scritto in A1.
9. learnmeabitcoin.com esce dal piano: non è stato letto e non verrà approfondito.

## Regole comuni

- **Mockup prima del codice.** Ogni schermata nuova ha un mockup HTML approvato prima dell'implementazione.
- **Offline-first.** Tutto funziona senza rete, tranne l'explorer (E2).
- **Compatibilità del bundle.** I tipi di record nuovi sono collezioni nuove alla radice del bundle. Il parser ignora già i campi che non conosce, quindi `schemaVersion` resta `1` e le versioni dell'app già installate continuano a leggere i bundle nuovi.
- **Modello dati e documentazione insieme.** Ogni tipo di record nuovo aggiorna `docs/content-model.md`, il parser, `tool/validate_content.dart` e i test nella stessa PR.
- **Due lingue.** Ogni contenuto esce in inglese e in italiano nello stesso cambio.
- **Ricerca.** Ogni tipo di record nuovo entra in `SearchIndex` con titolo e metadati.

## A. Contenuti

### A1. Categorie Software e Hardware

Tre livelli: categoria, sottocategoria, scheda prodotto.

Sottocategorie di **Software**:

- nodi (implementazioni di full node);
- software wallet (desktop e mobile);
- Lightning (implementazioni di nodo e wallet);
- server e infrastruttura (server Electrum, BTCPay Server, indicizzatori);
- sistemi per nodo domestico;
- software di mining (firmware, pool, Stratum);
- librerie e strumenti per sviluppatori.

Sottocategorie di **Hardware**:

- hardware wallet;
- backup del seed;
- mining (ASIC e dispositivi domestici);
- hardware per nodi.

Ogni sottocategoria ha una **voce wiki** normale, a tre livelli di lettura, che spiega il tipo di strumento: a cosa serve, come funziona, quali rischi ha, come si sceglie. Queste voci invecchiano poco e si scrivono per prime.

Le **schede prodotto** sono un tipo di record diverso dalle voci wiki. Un prodotto non ha bisogno di tre livelli di lettura, ma ha bisogno di dati strutturati. Collezione nuova `products`:

| Campo | Note |
| --- | --- |
| `id` | `product.slug` |
| `name`, `summary`, `bodyMarkdown` | testo breve e neutro |
| `category`, `subcategory` | le stesse stringhe usate dalle voci wiki |
| `maker`, `website`, `sourceUrl` | il sito si apre solo su tap, con `url_launcher` |
| `openSource`, `license` | |
| `platforms` | lista |
| `status` | `active` oppure `discontinued` |
| `reviewedAt` | data dell'ultima verifica, obbligatoria |
| `sources`, `related` | come negli altri record |

Regole di neutralità per le schede:

- nessun link di affiliazione, nessuna classifica, nessun prezzo;
- ogni affermazione ha una fonte;
- un prodotto non più mantenuto resta, con `status: discontinued`;
- il validatore segnala con un avviso le schede con `reviewedAt` più vecchio di 12 mesi.

Criterio di inclusione. Un prodotto entra se rispetta tutte le condizioni:

1. appartiene a una delle sottocategorie;
2. ha un sito ufficiale e una documentazione pubblica da citare come fonte;
3. è mantenuto (una versione o un aggiornamento negli ultimi 12 mesi) oppure ha un peso storico, e in quel caso entra come `discontinued`;
4. è open source, oppure è closed source ma molto diffuso: in questo secondo caso la scheda lo dice nella prima riga;
5. non è un servizio che custodisce i fondi dell'utente e non è un exchange.

All'inizio non più di 5 schede per sottocategoria. Le sottocategorie "backup del seed" e "hardware per nodi" partono senza schede: la voce di sottocategoria basta.

Primo elenco. Stato e licenza di ogni prodotto si verificano quando si scrive la scheda, non prima.

| Sottocategoria | Prodotti |
| --- | --- |
| Nodi | Bitcoin Core, Bitcoin Knots, btcd |
| Software wallet | Sparrow, Electrum, BlueWallet, Nunchuk |
| Lightning | LND, Core Lightning, Eclair, LDK, Phoenix |
| Server e infrastruttura | electrs, Fulcrum, BTCPay Server |
| Sistemi per nodo domestico | Umbrel, StartOS, RaspiBlitz |
| Software di mining | Braiins OS, Stratum V2 Reference Implementation, DATUM |
| Librerie e strumenti | BDK, rust-bitcoin, bitcoinjs-lib |
| Hardware wallet | Trezor, Ledger, Coldcard, BitBox02, Jade |
| Hardware di mining | Antminer serie S, Whatsminer serie M, Bitaxe |

Modifiche al codice per le categorie: campo opzionale `subcategory` su `WikiEntry`, ordine e icone in `lib/src/features/wiki/presentation/wiki_overview_screen.dart`, etichette in `lib/src/core/localization/content_labels.dart`, chiavi nei due file ARB. La schermata Wiki oggi mostra le categorie su un solo livello: serve un mockup per il livello delle sottocategorie.

### A2. Categoria Privacy e sicurezza

Voci: modello di minaccia, euristica common-input-ownership, riuso degli indirizzi, CoinJoin, Tor, Dandelion, custodia e self-custody, cold storage, attacco fisico ("5 dollar wrench"), passphrase.

### A3. Categoria Miti

en.bitcoin.it elenca 34 miti con confutazioni brevi e quasi senza fonti. Qui ogni mito è una voce wiki: il livello base risponde in poche frasi, il medio porta i dati, l'avanzato porta le fonti e le obiezioni serie. Nessuna modifica al codice oltre alla categoria.

### A4. Voci di protocollo mancanti

Transazione coinbase e maturità, header del blocco e codifica bits/target, sighash, RBF e CPFP, output di resto e coin selection, limite dust e OP_RETURN, PSBT e output descriptor, riorganizzazioni e blocchi orfani, SPV e pruning, segnalazione dei soft fork (BIP9), mining pool e Stratum, P2SH, MuSig, weight unit e vbyte, malleabilità delle transazioni, testnet e signet, codifiche Base58Check e bech32.

Prima di scrivere una voce, controllare se una voce esistente copre già l'argomento (per esempio `wiki.bitcoin-addresses` per le codifiche).

### A5. History

- Prima del 2008: Hashcash, b-money, bit gold, RPOW, manifesto cypherpunk.
- Incidenti tecnici: value overflow del 15 agosto 2010 (blocco 74638), più gli altri incidenti di consenso documentati.

Usa il modello `HistoryEvent` esistente. Nessuna modifica al codice.

### A6. Diagrammi byte per byte

SVG di una transazione e di un header di blocco con un colore per campo e la legenda. Vanno nei livelli medio e avanzato delle voci esistenti. Seguono `docs/image-generation-guidelines.md`. Il colore non è l'unico segnale: ogni campo ha anche l'etichetta.

## B. Funzioni dell'app

### B1. Percorso guidato "Inizia qui"

Una lista ordinata di voci con una riga che spiega perché leggere ciascuna e il tempo totale stimato. Card in Today. Lo stato di avanzamento usa il reading progress che `AppSettingsController` salva già. Collezione nuova `paths` con `id` (`path.slug`), `title`, `description`, `steps` (id della voce più nota), `estimatedMinutes`.

### B2. Glossario

Collezione nuova `glossary`: `id` (`glossary.slug`), `term`, `definition`, `aliases`, `related`. Schermata elenco alfabetico raggiungibile dalla Wiki, risultati nella ricerca, termini cliccabili nel Markdown delle voci tramite link a `glossary.slug`.

### B3. Tabelle di riferimento

Collezione nuova `references`: tabelle come dati, non come prosa. Prime tabelle: opcode di Script, campi della transazione, campi dell'header, messaggi del protocollo P2P, unità di misura. Schermata in Code con filtro di testo. Le demo di E3 leggono la tabella degli opcode da qui.

### B4. Citazioni di Satoshi

Collezione nuova `quotes`: `id`, `text`, `author`, `date`, `sourceTitle`, `sourceUrl`, `topics`, `related`. Nel bundle italiano la citazione ha la traduzione e il testo originale. Card "citazione del giorno" in Today, scelta in modo deterministico dalla data, e citazioni collegate in fondo alle voci wiki.

### B5. Biblioteca

Collezione nuova `library`: fonti primarie e testi cypherpunk. Ogni voce ha titolo, autore, anno, una nostra introduzione breve, lingua dell'originale e link. L'elenco ha filtri per autore e per tema. Il testo integrale si include solo quando la licenza lo permette ed è stata verificata per quella singola opera.

### B6. Data di verifica

Campo opzionale `reviewedAt` su tutti i record. La schermata di lettura mostra "Verificato il …" accanto ai metadati. Serve per i numeri che invecchiano: premio per blocco, difficulty, stato dei prodotti.

## C. Strumenti ed explorer

Nuova sezione "Strumenti" nella dashboard Code. Codice in `lib/src/features/tools/`, con la logica in funzioni Dart pure sotto `domain/`, così i test non hanno bisogno di widget.

### C1. Strumenti offline (E1)

| Strumento | Cosa fa |
| --- | --- |
| Hash | SHA-256, doppio SHA-256 e HASH160 di un testo o di un valore esadecimale |
| Target e difficulty | converte `bits` in target e in difficulty, e mostra gli hash attesi per blocco |
| Unità | sat e BTC, weight unit e vbyte, fee rate |
| Indirizzo | riconosce il tipo di indirizzo, controlla il checksum e spiega ogni parte |
| Transazione raw | prende l'esadecimale e mostra i campi, ognuno collegato alla voce wiki |

Note tecniche:

- `package:crypto` copre SHA-256 ma non RIPEMD-160, che serve per HASH160. RIPEMD-160 si scrive in Dart nel repository e si verifica con i vettori di test della specifica.
- Anche Base58Check e bech32/bech32m si scrivono nel repository. Si verificano con i vettori di test di BIP173 e BIP350.
- Nessuno strumento genera o chiede chiavi private. Derivare chiavi richiede secp256k1 ed è fuori da questo piano.

### C2. Demo interattive (E3)

- **Laboratorio blockchain.** Sei passi in sequenza, ognuno costruito sul precedente. Il modello è `anders94/blockchain-demo` (licenza MIT), un sito dimostrativo con le stesse sei schermate. Il codice si riscrive in Dart: l'originale è JavaScript con template Pug e non si può riusare così com'è. Se si riprendono testi o struttura in modo riconoscibile, l'attribuzione va nei crediti.

  | Passo | Cosa fa l'utente | Cosa impara |
  | --- | --- | --- |
  | 1. Hash | scrive un testo e vede l'hash cambiare a ogni carattere | impronta digitale dei dati |
  | 2. Blocco | modifica i dati di un blocco e poi preme "Mina" | nonce e proof of work |
  | 3. Catena | modifica un blocco vecchio e vede diventare non validi tutti i successivi | perché la storia è difficile da riscrivere |
  | 4. Rete | confronta tre copie della stessa catena, una delle quali manomessa | come i nodi riconoscono la copia sbagliata |
  | 5. Transazioni | sostituisce i dati liberi con una lista di pagamenti | il blocco come registro |
  | 6. Coinbase | aggiunge la transazione che crea le monete nuove | da dove vengono i bitcoin |

  "Mina un blocco" è il passo 2 e resta apribile anche da solo dalle voci wiki.

  Differenze volute rispetto al modello:

  - la ricerca del nonce gira in un isolate, così l'interfaccia non si blocca, e mostra tentativi e hash al secondo;
  - lo stato valido o non valido di un blocco ha un'etichetta di testo oltre al colore, come chiede `docs/design-system.md`;
  - il modello usa un blocco semplificato (numero, nonce, dati, hash precedente) e una regola di difficulty a zeri iniziali. Ogni passo dice in cosa Bitcoin è diverso (header di 80 byte, doppio SHA-256, target numerico, UTXO al posto dei saldi) e porta alla voce wiki;
  - un ultimo passo facoltativo ripete il mining su un header reale di Bitcoin con un target reso facile, e confronta il risultato con la difficulty reale.
- **Script passo per passo.** Mostra lo stack dopo ogni opcode su script di esempio. La prima versione copre gli opcode di stack, aritmetica, hash e timelock. La verifica delle firme è simulata e lo dichiara sullo schermo.

### C3. Explorer (E2)

Ricerca per altezza o hash di blocco, txid e indirizzo. I dati arrivano da un server con API Esplora, lo schema REST usato da mempool.space e da Blockstream.

Regole di privacy, da scrivere in `docs/privacy-policy.md` prima del rilascio:

- spento all'installazione; si accende dalle Impostazioni dopo un avviso che spiega cosa vede il server (indirizzo IP e ogni ricerca);
- nessuna chiamata parte senza un'azione dell'utente: aprire la schermata dell'explorer conta come azione e avvia la dashboard live (decisione del 2026-10-17, vedi sotto);
- il server è configurabile, così chi ha un nodo proprio usa quello;
- l'app non salva le ricerche fatte nell'explorer;
- nessun prezzo e nessun dato di mercato, come previsto dal PRD;
- l'app non offre Tor: l'avviso lo dice in modo esplicito.

Note tecniche:

- il server predefinito è l'API pubblica di mempool.space, con base `https://mempool.space/api`. Non serve una chiave;
- endpoint usati: `/blocks`, `/mempool`, `/mempool/recent`, `/fee-estimates`, `/blocks/tip/height`, `/block-height/:height`, `/block/:hash`, `/block/:hash/txids`, `/tx/:txid`, `/tx/:txid/hex`, `/address/:address`, `/address/:address/txs`. Sono gli stessi dello schema Esplora, quindi un server dell'utente con quello schema funziona senza modifiche;
- il client HTTP è `HttpClient` di `dart:io`, già usato da `content_bundle_repository.dart`, con gli stessi limiti di tempo di `content_http_deadline.dart`;
- la vista della transazione riusa il decoder di C1;
- ogni campo mostrato (input, output, witness, fee rate, tipo di script) porta alla voce wiki al livello di lettura scelto: è questo che distingue l'explorer da quelli esistenti;
- senza rete o con server irraggiungibile la schermata mostra un messaggio e gli strumenti offline restano disponibili.

Limiti d'uso di mempool.space, letti sulla documentazione dell'API il 2026-10-13:

- la documentazione dice che i limiti esistono ma non dà numeri;
- chi li supera riceve HTTP 429, e chi li supera più volte può essere escluso dal servizio;
- limiti più alti sono riservati agli sponsor enterprise.

Regole per il client, che seguono da questi limiti:

- una ricerca dell'utente produce il minimo di chiamate;
- l'unico aggiornamento automatico è la dashboard live della schermata explorer (decisione del 2026-10-17, prima il polling era escluso): 4 chiamate (`/blocks`, `/mempool`, `/fee-estimates`, `/mempool/recent`) all'apertura e poi ogni 60 secondi, solo mentre la schermata è visibile e l'app in primo piano, con un pulsante pausa. Le risposte valgono 15 secondi in cache. Il blocco di inizio del periodo di difficoltà si chiede una volta per periodo;
- le risposte restano in memoria per la sessione, così tornare indietro non ripete la chiamata. I dati di un blocco confermato non cambiano;
- le transazioni di un indirizzo si caricano una pagina alla volta, su richiesta;
- con HTTP 429 l'app mostra un messaggio, non riprova da sola, mette in pausa la dashboard finché l'utente non la riprende e blocca nuove ricerche per un tempo crescente;
- l'app nomina mempool.space solo come testo e non ne usa il logo: "Mempool" è un marchio registrato.

I termini di servizio di mempool.space sono stati letti da Davide in un browser il 2026-10-13.

## Ordine di lavoro

| Fase | Contenuto | Dipende da |
| --- | --- | --- |
| 1 | A1 (categorie, sottocategorie, voci di sottocategoria), B1, B6, A5 | mockup della Wiki a due livelli |
| 2 | B2, B3, B4, A3, A2 | — |
| 3 | C1 | B3 per i link ai campi |
| 4 | C2 | C1, B3 |
| 5 | C3 | C1, aggiornamento della privacy policy |
| 6 | Schede prodotto di A1, B5 | Fase 1 |
| In parallelo | A4, A6 | solo contenuto |

B2, B3 e B4 seguono lo stesso schema tecnico (collezione nuova, modello, parser, validatore, indice di ricerca, schermata elenco). Farle di seguito costa meno che farle separate.

## Scartato

- Feed di podcast e link a newsletter: chiamate a terzi senza un vantaggio chiaro.
- Serie numerate per le news: oggi c'è un solo articolo.
- Elenco di exchange: invecchia in fretta e somiglia a pubblicità.
- Explorer sempre attivo: contrario alla privacy by default.

## Documentazione da aggiornare durante il lavoro

| Documento | Quando |
| --- | --- |
| `docs/content-model.md` | a ogni tipo di record o campo nuovo (`subcategory`, `reviewedAt`, `products`, `glossary`, `references`, `quotes`, `paths`, `library`) |
| `docs/privacy-policy.md` | prima del rilascio dell'explorer; la regola prevista è già scritta |
| `docs/app-architecture.md` | quando nascono `lib/src/features/tools/` e le nuove rotte |
| `docs/contributing-content.md` e `content/templates/` | un template per ogni tipo di record nuovo |
| `docs/design-system.md` | componenti nuovi: tabella di riferimento, campo colorato, card di percorso |
| `README.md`, `CLAUDE.md`, `AGENTS.md` | quando una funzione è rilasciata, non prima |

## Domande aperte

Nessuna.
