# Development Roadmap

Aggiornata il 2026-10-13. Le motivazioni e le scelte di progetto sono in `docs/plan.md`. L'elenco delle voci da scrivere è in `docs/content-todo.md`.

Ogni area contiene task da completare in sequenza. Le aree seguono l'ordine di lavoro del piano.

## Già completato

La prima roadmap è chiusa, tranne le voci riportate in "Lavoro aperto ereditato". Il dettaglio storico resta in `git show 3b6e7f8:docs/roadmap.md`.

- [x] Foundation: licenze, tema, font locali, rotte, persistenza delle preferenze, CI.
- [x] Design system e componenti condivisi, con golden test.
- [x] Content domain: modelli, repository, parser, validazione, migrazione dei bundle.
- [x] Offline e search: seed, storage locale, manifest remoto, aggiornamento in background, indice di ricerca.
- [x] Vertical slice di Wiki, History, Code e News.
- [x] Content pipeline: template, validatore, generatore, pubblicazione su GitHub Pages, sync automatico di BIP e release.
- [x] Redesign 2026: tema dark e light, Today, Settings, Bookmarks, reading progress.

## 1. Wiki a due livelli, Software e Hardware

1. [ ] Mockup HTML della Wiki con categorie e sottocategorie. Pubblicato il 2026-10-13, in attesa di approvazione.
2. [x] Aggiungere il campo opzionale `subcategory` a `WikiEntry`: modello, parser, validatore, `docs/content-model.md`.
3. [x] Aggiungere le categorie `software` e `hardware`: ordine, icone, etichette EN e IT.
4. [ ] Mostrare le sottocategorie nella schermata Wiki.
5. [x] Confermare l'elenco delle sottocategorie (2026-10-13: quelle di `docs/plan.md`, sezione A1).
6. [x] Scrivere le voci di sottocategoria di Software, EN e IT, tre livelli.
7. [x] Scrivere le voci di sottocategoria di Hardware, EN e IT, tre livelli.

## 2. Percorso guidato e data di verifica

1. [ ] Mockup della card "Inizia qui" e della schermata del percorso. Card pubblicata il 2026-10-13, in attesa di approvazione.
2. [x] Aggiungere la collezione `paths`: modello, parser, validatore, documentazione.
3. [ ] Mostrare il percorso in Today, con avanzamento dal reading progress.
4. [x] Scrivere il primo percorso per principianti, EN e IT.
5. [ ] Aggiungere il campo opzionale `reviewedAt` a tutti i record e mostrarlo nelle schermate di lettura. Il campo esiste in modello, parser e validatore; manca la riga nelle schermate.

## 3. History estesa

1. [x] Eventi prima del 2008: Hashcash, b-money, bit gold, RPOW, manifesto cypherpunk.
2. [ ] Incidenti tecnici, a partire dal value overflow del 2010. Il value overflow è scritto; mancano gli altri incidenti.
3. [ ] Verificare che i filtri e l'ordinamento della timeline reggano le date prima del 2008. L'ordinamento è coperto dai test; manca il controllo a schermo.

## 4. Glossario, riferimenti e citazioni

1. [ ] Mockup di glossario, tabella di riferimento e card citazione. Glossario e citazione sono nel mockup del 2026-10-13, in attesa di approvazione; manca la tabella.
2. [ ] Collezione `glossary`: modello, parser, validatore, ricerca, schermata. Fatti modello, parser, validatore e 93 termini; mancano ricerca e schermata.
3. [ ] Link ai termini del glossario dal Markdown delle voci.
4. [ ] Collezione `references`: modello, parser, validatore, schermata con filtro in Code. Fatti modello, parser e validatore; manca la schermata.
5. [x] Prime tabelle: opcode, campi di transazione, campi di header, messaggi P2P, unità.
6. [ ] Collezione `quotes`: modello, parser, validatore, card in Today, citazioni collegate nelle voci. Fatti modello, parser e validatore; mancano card e collegamenti.
7. [x] Prima raccolta di citazioni con fonte e data, EN e IT.

## 5. Nuove categorie di contenuto

1. [ ] Categoria Miti: struttura e prime voci.
2. [x] Categoria Privacy e sicurezza: struttura e prime voci.
3. [x] Voci di protocollo mancanti (elenco in `docs/content-todo.md`).
4. [ ] Diagrammi SVG byte per byte di transazione e header.

## 6. Strumenti offline

1. [ ] Mockup della sezione Strumenti in Code. Pubblicato il 2026-10-13, in attesa di approvazione.
2. [ ] Creare `lib/src/features/tools/` con logica pura in `domain/` e aggiornare `docs/app-architecture.md`. La cartella esiste; la documentazione si aggiorna con le prime schermate.
3. [x] Decidere dipendenza o codice nostro per RIPEMD-160, Base58Check e bech32 (2026-10-13: codice nostro, verificato con i vettori di test ufficiali).
4. [x] Scrivere RIPEMD-160, Base58Check e bech32/bech32m con i loro test.
5. [ ] Strumento hash. La logica di tutti e cinque gli strumenti è in `lib/src/features/tools/domain/`; mancano le schermate.
6. [ ] Convertitore bits, target e difficulty.
7. [ ] Convertitore di unità.
8. [ ] Analisi di un indirizzo.
9. [ ] Decoder di transazione raw, con link alle voci wiki.

## 7. Demo interattive

1. [ ] Mockup del laboratorio blockchain (sei passi) e di "Script passo per passo". Passi 2 e 3 del laboratorio pubblicati il 2026-10-13, in attesa di approvazione; manca "Script passo per passo".
2. [x] Logica pura del laboratorio: blocco semplificato, validità della catena, ricerca del nonce in un isolate.
3. [ ] Passi 1 e 2: hash e blocco, con "Mina un blocco" apribile anche da solo.
4. [ ] Passi 3 e 4: catena e rete con tre copie.
5. [ ] Passi 5 e 6: transazioni e coinbase.
6. [ ] Passo facoltativo: mining su un header reale di Bitcoin con target facile.
7. [ ] Testi EN e IT di ogni passo, con il confronto con Bitcoin reale e i link alle voci wiki.
8. [ ] "Script passo per passo": opcode di stack, aritmetica, hash e timelock, con firma simulata dichiarata.
9. [ ] Collegare le demo dalle voci `wiki.hash-functions`, `wiki.blockchain`, `wiki.proof-of-work`, `wiki.mining` e `wiki.bitcoin-script`.

## 8. Explorer

1. [x] Scegliere il server predefinito (2026-10-13: mempool.space, sostituibile dall'utente).
2. [ ] Leggere in un browser i termini di servizio di mempool.space.
3. [ ] Aggiornare `docs/privacy-policy.md` con il testo definitivo.
4. [ ] Mockup di ricerca, blocco, transazione, indirizzo e dell'avviso di attivazione. Avviso e transazione pubblicati il 2026-10-13, in attesa di approvazione.
5. [ ] Impostazioni: interruttore spento all'installazione e server configurabile.
6. [ ] Client Esplora con limiti di tempo, cache in memoria e gestione di HTTP 429.
7. [ ] Schermate blocco, transazione e indirizzo, con link alle voci wiki.
8. [ ] Test con server finto: rete assente, risposta malformata, timeout, HTTP 429.

## 9. Schede prodotto e Biblioteca

1. [x] Collezione `products`: modello, parser, validatore (avviso oltre 12 mesi da `reviewedAt`), template, documentazione.
2. [ ] Mockup della scheda prodotto e dell'elenco per sottocategoria.
3. [x] Definire il criterio di inclusione e i primi prodotti (2026-10-13: `docs/plan.md`, sezione A1).
4. [ ] Scrivere le prime schede, EN e IT.
5. [ ] Collezione `library`: modello, parser, validatore, schermata con filtri per autore e tema.
6. [ ] Prime voci della Biblioteca, con licenza verificata opera per opera.

## Lavoro aperto ereditato

Voci della roadmap e del piano precedenti, ricontrollate sul repository il 2026-10-13.

### Ancora aperte

- [ ] Pass con screen reader su dispositivi iOS e Android fisici, e verifica con testo ingrandito.
- [ ] Pass di performance su Android di fascia bassa.
- [ ] Test di integrazione: la cartella `integration_test/` non esiste.
- [ ] Aggiornare Flutter: i workflow fissano ancora la 3.32.6.
- [ ] Android: `applicationId` è `org.satowiki.sato_wiki` con il TODO del template, diverso dal bundle id iOS `org.satowiki.satoWiki`.
- [ ] iOS: `IPHONEOS_DEPLOYMENT_TARGET` è `12.0`.
- [ ] News: un solo articolo, con un indirizzo `example.com` nel seed.
- [ ] Due fonti di verità per wiki e history: `tool/build_seed_bundle.dart` non va eseguito finché seed e Markdown non sono riallineati. Tocca tutte le voci nuove di questo piano, che vanno aggiunte ai seed a mano.
- [ ] Follow dei BIP e notifiche.
- [ ] Donazioni BTCPay o Lightning.
- [ ] Changelog di LND, Core Lightning ed Eclair.
- [ ] Beta su TestFlight e Play Internal.
- [ ] `CONTRIBUTING.md`.

### Non ricontrollate oggi

- Golden `core_editorial_components`: il 2026-10-12 falliva per 4 pixel. `flutter test` non è stato rieseguito.
- Firma della release Android: `android/app/build.gradle.kts` ora contiene un blocco `signingConfigs`. Non è stato verificato che la release usi una chiave di produzione.
- Versioni delle azioni GitHub e dipendenze da aggiornare.
- Le "Segnalazioni non confermate" del piano precedente.

### Chiuse rispetto al piano precedente

- Le 12 release non mostrano più il segnaposto: il validatore dà 0 avvisi.
- Nessuna PR aperta sul repository.
- Nessun `// ignore: deprecated_member_use` in `lib/`.
