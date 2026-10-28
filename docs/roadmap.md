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

1. [x] Mockup HTML della Wiki con categorie e sottocategorie. Approvato il 2026-10-13.
2. [x] Aggiungere il campo opzionale `subcategory` a `WikiEntry`: modello, parser, validatore, `docs/content-model.md`.
3. [x] Aggiungere le categorie `software` e `hardware`: ordine, icone, etichette EN e IT.
4. [x] Mostrare le sottocategorie nella schermata Wiki.
5. [x] Confermare l'elenco delle sottocategorie (2026-10-13: quelle di `docs/plan.md`, sezione A1).
6. [x] Scrivere le voci di sottocategoria di Software, EN e IT, tre livelli.
7. [x] Scrivere le voci di sottocategoria di Hardware, EN e IT, tre livelli.

## 2. Percorso guidato e data di verifica

1. [x] Mockup della card "Inizia qui" e della schermata del percorso. Card approvata il 2026-10-13.
2. [x] Aggiungere la collezione `paths`: modello, parser, validatore, documentazione.
3. [x] Mostrare il percorso in Today, con avanzamento dal reading progress.
4. [x] Scrivere il primo percorso per principianti, EN e IT.
5. [x] Aggiungere il campo opzionale `reviewedAt` a tutti i record e mostrarlo nelle schermate di lettura. Mostrato nel lettore wiki e nelle schede prodotto.

## 3. History estesa

1. [x] Eventi prima del 2008: Hashcash, b-money, bit gold, RPOW, manifesto cypherpunk.
2. [x] Incidenti tecnici: value overflow del 2010, fork di marzo 2013, fork BIP 66 di luglio 2015, CVE-2018-17144.
3. [ ] Verificare che i filtri e l'ordinamento della timeline reggano le date prima del 2008. L'ordinamento è coperto dai test; manca il controllo a schermo.

## 4. Glossario, riferimenti e citazioni

1. [ ] Mockup di glossario, tabella di riferimento e card citazione. Glossario e citazione sono nel mockup approvato il 2026-10-13. La tabella è stata costruita senza mockup dedicato: da rivedere a schermo.
2. [x] Collezione `glossary`: modello, parser, validatore, ricerca, schermata.
3. [ ] Link ai termini del glossario dal Markdown delle voci.
4. [x] Collezione `references`: modello, parser, validatore, schermata con filtro in Code.
5. [x] Prime tabelle: opcode, campi di transazione, campi di header, messaggi P2P, unità.
6. [x] Collezione `quotes`: modello, parser, validatore, card in Today, citazioni collegate nelle voci.
7. [x] Prima raccolta di citazioni con fonte e data, EN e IT.

## 5. Nuove categorie di contenuto

1. [x] Categoria Miti: struttura e prime 12 voci.
2. [x] Categoria Privacy e sicurezza: struttura e prime voci.
3. [x] Voci di protocollo mancanti (elenco in `docs/content-todo.md`).
4. [x] Diagrammi SVG byte per byte di transazione e header.

## 6. Strumenti offline

1. [x] Mockup della sezione Strumenti in Code. Approvato il 2026-10-13.
2. [x] Creare `lib/src/features/tools/` con logica pura in `domain/` e aggiornare `docs/app-architecture.md`.
3. [x] Decidere dipendenza o codice nostro per RIPEMD-160, Base58Check e bech32 (2026-10-13: codice nostro, verificato con i vettori di test ufficiali).
4. [x] Scrivere RIPEMD-160, Base58Check e bech32/bech32m con i loro test.
5. [x] Strumento hash.
6. [x] Convertitore bits, target e difficulty.
7. [x] Convertitore di unità.
8. [x] Analisi di un indirizzo.
9. [x] Decoder di transazione raw, con link alle voci wiki.
10. [x] Dadi → Seed: sandbox offline con schermata, controller solo in memoria, velo, cancellazione e canale nativo di Android e iOS.
11. [x] Dadi → Seed: BIP39 ed entropia da dadi come SeedSigner e Coldcard, con vettori di test (compatibilità confermata sui vettori ufficiali di SeedSigner e sul campione Coldcard).
12. [x] Dadi → Seed: tastiera a 6 facce, correzione dei lanci e controllo della distribuzione.
13. [x] Dadi → Seed: codice del riconoscimento (interfaccia, decoder YOLOX-Nano, NMS in Dart, auto-capture).
14. [ ] Dadi → Seed: verificare la licenza del dataset pubblico, scegliere il dataset e scaricarlo (vedi `tool/dice_model/README.md`). Scelto e scaricato D6DiceSideRecognition v2 (CC BY 4.0 secondo l'export); manca la conferma sulla pagina del dataset.
15. [x] Dadi → Seed: addestrare il modello, esportarlo e copiare `assets/models/dice_detector.tflite` con lo SHA-256 nel model card (2026-10-27: beta, value accuracy 0.774, sotto la soglia 0.99; 2026-10-28: secondo modello a 640 px con scene sintetiche, 0.959 sul test pubblico e 0.776 sui dadi del maintainer).
    - [ ] Migliorare la lettura dei pallini fino alla soglia 0.99: fine-tuning con foto dei dadi del maintainer (tutti i dadi di una foto sulla stessa faccia, così i box li mette il modello e il valore è il nome della cartella). Oggi il 2 viene letto spesso come 3.
16. [ ] Dadi → Seed: test set di foto proprie, con accuratezza per valore di almeno 99% (2026-10-28: primo set di 17 lanci, 85 dadi, misurato con `evaluate_throws.py`: 77,6%).
17. [ ] Dadi → Seed: prova su dispositivi fisici iOS e Android (screenshot, velo, auto-capture, seed confrontata con SeedSigner; facoltativo, non bloccante, perché la compatibilità è già confermata dai vettori).

## 7. Demo interattive

1. [ ] Mockup del laboratorio blockchain e di "Script passo per passo". Passi 2 e 3 approvati il 2026-10-13. Passi 1, 4, 5, 6, 7 e Script sono stati costruiti senza mockup dedicato: da rivedere a schermo.
2. [x] Logica pura del laboratorio: blocco semplificato, validità della catena, ricerca del nonce a lotti.
3. [x] Passi 1 e 2: hash e blocco, con "Mina un blocco" apribile anche da solo.
4. [x] Passi 3 e 4: catena e rete con tre copie.
5. [x] Passi 5 e 6: transazioni e coinbase.
6. [x] Passo facoltativo: header reale del blocco genesi, decodificato campo per campo.
7. [x] Testi EN e IT di ogni passo, con il confronto con Bitcoin reale e i link alle voci wiki.
8. [x] "Script passo per passo": opcode di stack, aritmetica, hash e timelock, con firma simulata dichiarata.
9. [x] Collegare le demo dalle voci wiki: sezione "Prova" in 16 voci.

## 8. Explorer

1. [x] Scegliere il server predefinito (2026-10-13: mempool.space, sostituibile dall'utente).
2. [x] Leggere in un browser i termini di servizio di mempool.space. Letti da Davide il 2026-10-13.
3. [x] Aggiornare `docs/privacy-policy.md` con il testo definitivo.
4. [ ] Mockup di ricerca, blocco, transazione, indirizzo e dell'avviso di attivazione. Avviso e transazione approvati il 2026-10-13. Ricerca, blocco e indirizzo sono stati costruiti senza mockup dedicato: da rivedere a schermo.
5. [x] Impostazioni: interruttore spento all'installazione e server configurabile.
6. [x] Client Esplora con limiti di tempo, cache in memoria e gestione di HTTP 429.
7. [x] Schermate blocco, transazione e indirizzo, con link alle voci wiki.
8. [x] Test con server finto: rete assente, risposta malformata, timeout, HTTP 429.
9. [x] Dashboard live in stile mempool.space sulla schermata di ricerca (mockup approvato il 2026-10-17): aggiornamento ogni 60 secondi con pausa. Da provare su simulatore con il server vero.

## 9. Schede prodotto e Biblioteca

1. [x] Collezione `products`: modello, parser, validatore (avviso oltre 12 mesi da `reviewedAt`), template, documentazione.
2. [x] Mockup della scheda prodotto e dell'elenco per sottocategoria. Nel mockup della Wiki approvato il 2026-10-13.
3. [x] Definire il criterio di inclusione e i primi prodotti (2026-10-13: `docs/plan.md`, sezione A1).
4. [x] Scrivere le prime schede, EN e IT. 32 schede.
5. [x] Collezione `library`: modello, parser, validatore, schermata con filtri per autore e tema.
6. [x] Prime voci della Biblioteca, con licenza verificata opera per opera. 16 opere.

## Da verificare a mano

- [ ] Nessuna schermata nuova è stata provata su simulatore o dispositivo: sono coperte solo da test di widget.
- [ ] La schermata Biblioteca non aveva un mockup: da rivedere a schermo.
- [ ] I testi italiani scritti dai subagent vanno riletti da una persona madrelingua.

## Lavoro aperto ereditato

Voci della roadmap e del piano precedenti, ricontrollate sul repository il 2026-10-13.

### Ancora aperte

- [ ] Pass con screen reader su dispositivi iOS e Android fisici, e verifica con testo ingrandito.
- [ ] Pass di performance su Android di fascia bassa.
- [ ] Test di integrazione: la cartella `integration_test/` non esiste.
- [x] Aggiornare Flutter: i workflow usano la 3.47.7.
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
