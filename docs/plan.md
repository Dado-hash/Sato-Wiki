# Piano di ripresa SatoWiki

Stato al 2026-10-12, commit `657af2b` su `main`.

Questo piano nasce da una code review completa del repository. Ogni voce è stata ricontrollata a mano sul codice, sui seed bundle, sul CDN o con un comando; il metodo di verifica è indicato accanto a ciascuna. Le voci che non è stato possibile confermare sono raccolte in fondo, separate, e non vanno trattate come fatti.

## Stato attuale

- `main` locale coincide con `origin/main`. Nessuno stash, nessun tag. Ultimo commit umano: 2026-09-08.
- Restano aperte quattro PR draft del bot di sync: #30, #31, #32, #33. Toccano solo i seed bundle. Non vanno mergiate prima della fase 1.
- `flutter analyze` è pulito e il codice è formattato. `flutter test`: 37 test passano, 1 fallisce (il golden `core_editorial_components`, riprodotto due volte).
- Toolchain: Flutter 3.32.6 / Dart 3.8.1, revisione dell'8 luglio 2025.
- Contenuti nei seed (EN e IT allineati): 61 voci wiki, 35 eventi history, 209 BIP, 12 release Bitcoin Core, 1 articolo news.
- `ios/Podfile` è presente ma non tracciato da git. Va deciso se committarlo o rimuoverlo.

## Avanzamento al 2026-10-12

Le correzioni sono nel working tree, non ancora committate. Verifiche eseguite dopo l'integrazione:

- `flutter analyze`: nessun problema. `dart format`: nessun file da formattare.
- `flutter test`: 121 test passano, 1 fallisce. È lo stesso golden `core_editorial_components` che falliva prima, con la stessa differenza di 4 pixel.
- `validate_content.dart` su entrambi i seed: 0 errori, 24 avvisi (i 12 changelog ancora da rivedere).
- `flutter build bundle`: 123 file media impacchettati su 123.

Le voci spuntate sotto sono coperte da un test o da uno di questi comandi. Non sono stati provati: i due workflow su GitHub, le chiamate reali a GitHub e Gemini, l'app su dispositivo.

Problemi emersi durante il lavoro e già corretti:

- Riparazione dei media a ogni avvio quando un file manca in modo permanente sul CDN: dopo una riparazione incompleta il tentativo successivo aspetta 24 ore (`ContentMediaStore.mediaRepairCooldown`), e la riparazione riusa i file già installati invece di riscaricarli tutti.
- Link nel Markdown verso un id di contenuto inesistente: ora non fanno nulla, come i link correlati.
- `code_dashboard_screen.dart` usa l'helper comune `openExternalUrl`.
- Ordine della ricerca: a parità di punteggio vince la sezione (wiki, news, history, code), poi titolo e id. Per `mining` la voce wiki torna prima del BIP.
- Cambio tab: lo shell non sostituisce più la rotta, quindi filtri e scroll di ogni tab si conservano. `setLastTab` in `_tabRouteFor` resta, ma ha effetto solo per un deep link verso un'altra tab. Non provato su dispositivo.
- Il sync chiede una bozza anche per i record che mostrano ancora il segnaposto.

Comportamento cambiato da sapere: con `--skip-ai` il sync conserva il testo esistente invece di sostituirlo con il segnaposto.

Restano da decidere o da fare a mano: merge della PR di sync e chiusura di #30, #31, #32; testi dei 12 changelog; scelta sul flusso wiki/history; articoli news; tutta la Fase 5 tranne la parte CI già fatta; `ios/Podfile`.

## Fase 1 — Sync dei contenuti Code

Da fare prima di mergiare qualsiasi PR del bot.

- [x] **Il sync sostituisce il testo esistente con il segnaposto.** In `tool/sync_code_content.dart:404-418`, `_preserveText` restituisce il testo di fallback ogni volta che il record è "AI-managed", cioè ha `needsReview: true` oppure un `aiModel` (`:1230-1233`). Quando l'upstream non è cambiato non viene generata nessuna bozza (`:263-269`), quindi il fallback è il segnaposto "Draft generated from…". Effetto: le bozze AI contenute nella PR #33 verrebbero cancellate dal sync successivo al merge. Correzione: non sostituire mai un testo esistente non vuoto con il fallback; usare il fallback solo se il campo manca. Aggiungere un test sulla logica di merge, che oggi non esiste. *Verificato leggendo il codice.*
- [x] **Ogni run riscrive tutti i record.** `updatedAt` viene impostato a `now` su ogni BIP e release (`:313`, `:388`), quindi il confronto `_jsonDeepEquals` (`:206`, `:224`, `:234-236`) risulta sempre diverso, la versione del bundle viene sempre incrementata e il controllo `git diff` del workflow non filtra nulla. Correzione: confrontare i record escludendo `updatedAt` e aggiornarlo solo quando il contenuto cambia. *Verificato leggendo il codice.*
- [x] **Nessun timeout e nessun retry.** `HttpClient()` è creato senza `connectionTimeout` (`:504`), le chiamate a GitHub e a Gemini non hanno scadenza (`:616-641`, `:909-944`) e un singolo errore di Gemini interrompe l'intero run. Il workflow non ha `timeout-minutes`. Degli ultimi 30 run schedulati solo 4 sono riusciti; 6 sono stati cancellati. Correzione: timeout per richiesta, retry con backoff su 429 e 5xx, fallback per singolo record, `timeout-minutes: 30`. *Verificato sul codice e con `gh run list`. La causa dei run cancellati non è stata accertata.* *Fatto nel codice; i percorsi reali verso GitHub e Gemini non sono stati provati.*
- [x] **Una PR nuova ogni settimana.** Il branch contiene la data (`sync-code-content.yml:63`), quindi il ramo "aggiorna la PR esistente" non scatta mai e le PR si accumulano. Correzione: un branch fisso e una sola PR aggiornata. *Verificato sul workflow e sulle quattro PR aperte.* *Fatto: branch fisso `automation/code-content-sync`. Workflow non ancora eseguito su GitHub.*
- [x] **Tag di stato accumulati.** `_mergeTags` (`:432-440`) aggiunge il nuovo stato senza togliere il vecchio. Nei seed i BIP 52, 127, 343 e 434 hanno due tag di stato. *Verificato sui seed.* *Corretti sia lo script sia i seed.*
- [x] **Tutte le release risultano "major".** `VersionParts.isMajor` (`:1064-1067`) considera major ogni versione a due componenti: 30.1, 29.3 e 28.4 sono marcate major. Nei seed tutte e 12 le release sono major. *Verificato sul codice e sui seed.* *Regola nuova: `X.0` major, `X.Y` minor, terzo componente non nullo patch. Nei seed 9 release sono passate a minor.*
- [x] **Uno stato BIP sconosciuto interrompe il run.** `normalizeBipStatus` (`:1167-1176`) lancia un'eccezione sugli stati non previsti. Meglio registrare un avviso e mantenere lo stato precedente. *Verificato leggendo il codice.*
- [ ] Dopo le correzioni: rigenerare la PR di sync, mergiarla e chiudere #30, #31, #32.

## Fase 2 — Contenuti pubblicati

- [ ] **Le 12 release mostrano il testo segnaposto.** Nei seed e nei bundle oggi serviti dal CDN (versioni `2026.07.19.170356` EN e `2026.07.19.170357` IT) tutti i changelog hanno `needsReview: true` e il testo "Draft generated from official release notes. Requires review." / "Bozza generata dalle note ufficiali. Richiede review.". Correzione: scrivere o rivedere i riassunti, e far fallire `validate_content.dart` sui record con `needsReview: true` o con il testo segnaposto. *Verificato sui seed e scaricando i bundle dal CDN.* *Parziale: il validatore avvisa (errore con `--strict`) e il sync ora chiede una bozza per i record che hanno ancora il segnaposto. I testi restano da generare e rivedere.*
- [x] **Link correlati verso id inesistenti.** `wiki.taproot` rimanda a `wiki.segwit`, che non esiste (la voce è `wiki.segregated-witness`). Nove BIP usano id nella forma `bip.N` invece di `code.bip.N`. Il validatore dovrebbe segnalare i riferimenti che non si risolvono. *Verificato sui seed: 10 riferimenti orfani per lingua.* *Seed e Markdown corretti; il validatore ora li segnala come errore.*
- [ ] **Due fonti di verità per wiki e history.** `tool/build_seed_bundle.dart` riscrive le sezioni `wiki` e `history` dei seed a partire da `content/{lang}/`, ma non è eseguito in CI né citato nella documentazione, e i seed sono stati poi modificati a mano. Rieseguendolo oggi cambierebbero 11 sommari history, le fonti di 15 voci wiki e diversi `related` e `tags` per lingua. Va scelto un solo flusso: o lo script diventa l'unico modo di scrivere i seed (riportando prima le modifiche nei Markdown), o va rimosso. *Verificato eseguendo lo script su una copia e confrontando.* *Solo documentato: fino alla riconciliazione i seed sono la fonte di verità e lo script non va eseguito. La scelta resta da fare.*
- [ ] **News quasi vuota.** Un solo articolo, categoria `protocol`, con indirizzo Lightning di esempio (`andreas@example.com`). I filtri in `news_feed_screen.dart:246-253` sono fissi nel codice e quattro su cinque aprono una lista vuota. *Verificato sui seed e sul codice.* *Parziale: i filtri ora derivano dai dati e c'è uno stato vuoto. Mancano gli articoli.*

## Fase 3 — Flusso offline e aggiornamenti nell'app

- [x] **Le immagini del seed non entrano nel build.** `pubspec.yaml:85-86` dichiara solo `assets/content/media/` e `assets/content/media/wiki/proof-of-work/`. Flutter non include le sottocartelle in modo ricorsivo: `flutter build bundle` impacchetta 2 file media su 123. L'errore è silenzioso, perché `content_media_store.dart:135` ignora gli asset mancanti. Con la rete disponibile il primo aggiornamento scarica tutte le immagini dal CDN; senza rete al primo avvio l'app resta senza immagini. Correzione: dichiarare tutte le cartelle (o generarne l'elenco) e aggiungere un test che controlli che ogni media citato dal seed sia un asset dichiarato. *Verificato con `flutter build bundle`.* *Fatto: `flutter build bundle` ora impacchetta 123 file su 123.*
- [x] **La riparazione dei media non può mai partire.** `AppContentController.checkForUpdates` esce se la versione remota non è più recente (`app_content_controller.dart:136-145`), prima di chiamare l'updater. Il ramo `canRepairCurrentMedia` in `content_bundle_repository.dart:354-372` resta quindi irraggiungibile. Correzione: lasciare la decisione all'updater e togliere il controllo duplicato. *Verificato leggendo il codice.*
- [x] **Dialog modale a ogni avvio.** `app.dart:68-72` apre il dialog già nello stato `checking`, con `barrierDismissible: false` (`:91`). Contraddice la regola per cui nessuna UI centrale blocca sulla rete. Correzione: nessun dialog durante il controllo; mostrarlo solo quando parte un download, oppure usare un indicatore non bloccante. *Verificato leggendo il codice.* *Fatto: il dialog compare solo quando parte un download. Manca un test widget su `app.dart`.*
- [x] **Manca un timeout sulla risposta.** I tre client HTTP impostano solo `connectionTimeout` (`content_bundle_repository.dart:278`, `:299`; `content_media_store.dart:22`). Se il server accetta la connessione e non risponde, la richiesta non scade e, insieme al punto precedente, il dialog resta aperto. Correzione: scadenza complessiva su richiesta e lettura del corpo. *Verificato leggendo il codice.*
- [x] **Un solo file media mancante blocca l'aggiornamento del testo.** In `content_bundle_repository.dart:387-393` il bundle viene salvato solo dopo `prefetchBundleMedia`, che rilancia l'errore al primo file fallito (`content_media_store.dart:203-208`). Con un 404 su un'immagine, a ogni avvio il bundle viene riscaricato e scartato. Correzione: salvare il bundle verificato e trattare i media mancanti come avviso. *Verificato leggendo il codice.*
- [x] **I media scaricati non sono verificati.** `_fetchMediaInto` (`content_media_store.dart:233-235`) scrive i byte scaricati senza confrontarli con l'hash del manifest, che serve solo a riusare i file in cache. Inoltre `bundleUrl` accetta qualsiasi URI assoluto, anche `http://` (`content_bundle_repository.dart:191-195`). Correzione: verificare l'hash di ogni file e accettare solo `https`. *Verificato leggendo il codice.*
- [x] **Lo spazio occupato cresce senza limite.** `prefetchBundleMedia` cancella solo la cartella della stessa versione e le `.tmp`; le cartelle delle versioni precedenti restano. Correzione: dopo uno swap riuscito, tenere solo la versione corrente. *Verificato leggendo il codice.*
- [x] **La versione è usata come nome di cartella senza validazione** (`content_media_store.dart:277-282`). Va accettato solo il formato numerico con punti. *Verificato leggendo il codice.*
- [x] **Un bundle salvato con media non validi può bloccare l'avvio.** `installBundleMediaFromAssets` lancia un'eccezione sui riferimenti non validi (`content_media_store.dart:108-111`); è chiamato senza `try` da `_loadContent` (`app_content_controller.dart:203`), che `main.dart` attende prima di `runApp`. Il fallback al seed in `LocalFirstContentBundleRepository.load` copre solo gli errori di parsing. Correzione: in quel caso tornare al seed e scartare il bundle salvato. *Percorso verificato leggendo il codice; lo scenario non è stato riprodotto.*
- [ ] **Il manifest pubblicato non contiene la mappa `media`.** È stato generato prima del commit `0a20504` e da allora Pages non è stato ripubblicato, quindi il riuso dei media in cache non è attivo. Si risolve con la prossima pubblicazione. *Verificato scaricando il manifest.* *Aperto: si chiude alla prossima pubblicazione su Pages.*
- [x] **Gli URL versionati non sono immutabili.** Ogni deploy sostituisce l'intero sito Pages (`flutter.yml:105-117`): `content/en/2026.06.20.071041/bundle.json` risponde 404. `docs/contributing-content.md:42` afferma il contrario. Correzione: conservare le versioni precedenti nel deploy, oppure correggere la documentazione. *Verificato con una richiesta HTTP.* *Corretta la documentazione; il deploy resta com'è e conserva solo l'ultima versione.*
- [x] Il confronto tra versioni è copiato tre volte (`app_content_controller.dart:227`, `content_bundle_repository.dart:95` e `:403`). Unificarlo. *Unificato in `content_version.dart`.*
- [x] `AppContent.warnings` viene assegnato e mai letto: i record scartati dal parser spariscono senza traccia. Almeno un log in debug.

## Fase 4 — Bug visibili nelle schermate

- [x] **20 BIP con stato `complete` non compaiono nei filtri né nel tracker.** `code_dashboard_screen.dart:239` elenca solo deployed, draft e closed; il conteggio a `:300-304` ignora `complete`. *Verificato su codice e seed.*
- [x] **I link nel Markdown non sono cliccabili.** `MarkdownBody` in `markdown_text.dart:22` non riceve `onTapLink`; in `lib/` non compare mai. Oggi i contenuti non hanno link testuali, ma il modello li ammette. *Verificato leggendo il codice.*
- [x] **Link correlati.** Nella voce wiki ogni link apre una rotta wiki qualunque sia il prefisso dell'id (`wiki_overview_screen.dart:734-738`). Nelle news i link sono senza `onTap` (`news_feed_screen.dart:176`) ma mostrano comunque la freccia (`related_links_grid.dart:32`). In history i prefissi diversi da `wiki.` e `history.` non fanno nulla (`history_timeline_screen.dart:337-349`). *Verificato leggendo il codice.* *Fatto con l'helper unico `routeForContentId`.*
- [x] **La schermata della release non è raggiungibile dalla dashboard.** `_ChangelogItem` (`code_dashboard_screen.dart:470`) non ha `onTap`; ci si arriva solo da ricerca o deep link. *Verificato leggendo il codice.*
- [x] **Le release patch sono mostrate come minor.** `code_dashboard_screen.dart:1105-1109`; `ContentStatus` non ha un valore `patch`. *Verificato leggendo il codice.*
- [x] **Il titolo del dettaglio BIP unisce titolo e sommario** in un unico `headlineMedium` (`code_dashboard_screen.dart:737-742`). *Verificato leggendo il codice.*
- [x] **Pulsanti indietro senza tooltip**, contro le linee guida: `wiki_overview_screen.dart:325`, `:639`; `code_dashboard_screen.dart:110`, `:713`, `:1095`. *Verificato leggendo il codice.*
- [x] **Il titolo della categoria wiki mostra la chiave grezza** (`wiki_overview_screen.dart:329`), non tradotta. *Verificato leggendo il codice.*
- [x] **Il pulsante "Send Tip" è un mock** visibile agli utenti (`news_feed_screen.dart:150-171`). Nasconderlo finché non c'è un'implementazione. *Rimosso.*
- [x] **Ricerca solo per sottostringa** su titolo, tag e sommario (`search_index.dart:87-100`): nessuna tokenizzazione, accenti non normalizzati, corpo del testo escluso, ordinamento senza spareggio stabile. *Fatto: token multipli, accenti normalizzati, ordinamento stabile. Il corpo del testo resta non indicizzato. L'ordine dei risultati è cambiato: per `mining` un BIP ora precede la voce wiki.*
- [x] Colori fuori dal tema: `Colors.green` in `update_progress_dialog.dart:96`, `Colors.black` e `Colors.white` in `markdown_text.dart:243-246`.
- [ ] Sei `// ignore: deprecated_member_use` in `sato_scaffold.dart:118-146` da ricontrollare dopo l'aggiornamento di Flutter.
- [ ] `setLastTab` è chiamato dentro `onGenerateRoute` (`app_router.dart:46`, `:83`): effetto collaterale durante la costruzione della rotta. `DeepLinkPlaceholderScreen` (`:155`, `:256`) è da rimuovere se confermato irraggiungibile. *Parziale: rimosso dal ramo dei deep link e `DeepLinkPlaceholderScreen` eliminata. Resta in `_tabRouteFor`, perché lo shell legge `lastTab` durante il `build`.*

## Fase 5 — Toolchain, piattaforme e CI

- [ ] Aggiornare Flutter all'ultima stable in un cambio separato e rigenerare il golden `test/goldens/core_editorial_components.png` solo dopo averne controllato la differenza.
- [ ] Aggiornare le dipendenze: prima le patch, poi `flutter_lints` 5 → 6 e `cupertino_icons` 1 → 2. *Dato riportato da `flutter pub outdated`, non rieseguito in fase di verifica.*
- [ ] Android: la release è firmata con la chiave di debug (`android/app/build.gradle.kts:35-37`) e l'`applicationId` ha ancora il TODO del template (`:23-24`). L'id Android `org.satowiki.sato_wiki` è diverso dal bundle id iOS `org.satowiki.satoWiki`: va deciso prima della prima pubblicazione.
- [ ] iOS: `IPHONEOS_DEPLOYMENT_TARGET = 12.0`. Alzarlo al valore del template Flutter corrente.
- [ ] CI: spostare `pages: write` e `id-token: write` dal livello workflow al solo job `publish-content` (`flutter.yml:9-12`), aggiungere `concurrency` a entrambi i workflow, aggiornare `actions/checkout@v4` e le azioni Pages. *Parziale: permessi, `concurrency` e timeout fatti. Versioni delle azioni non toccate.*
- [ ] Test mancanti: nessuna cartella `integration_test/`, nessun test che importi `lib/src/features/`, nessun test per `generate_bundle.dart`, `validate_content.dart`, `build_seed_bundle.dart` e `content_bundle_migrator.dart`. Un solo golden, senza gli elementi della timeline. *Parziale: aggiunti test per sync, validatore, generatore, flusso di aggiornamento, schermate Code e di lettura (120 test in totale). Mancano i test di integrazione, i golden della timeline e i test del migrator.*

## Fase 6 — Documentazione

- [x] `README.md:5`, `AGENTS.md:7`, `:45`, `:60`, `:87` e `docs/design-system.md:3-14` citano `stitch_satowiki_pages/`, che non esiste più.
- [x] `AGENTS.md:7` indica `SatoWiki_PRD.md` e `SatoWiki_DesignBrief.md` nella radice; i file sono in `docs/`.
- [x] `README.md:102` elenca gli stati BIP `draft, proposed, active, final, withdrawn, rejected`; quelli canonici sono `draft, complete, deployed, closed`.
- [x] `docs/roadmap.md` ha tutte le voci spuntate, comprese "Testare offline, text scale e screen reader" (riga 51), "Preparare notifiche future su BIP seguiti" (riga 70) e "Collegare BTCPay/Lightning" (riga 79). Nel codice non c'è nulla per notifiche e BTCPay, e `docs/release/release-readiness.md` dà ancora per mancanti i test manuali con screen reader e su Android di fascia bassa. *Le tre voci sono state riaperte.*
- [x] `docs/app-architecture.md:7` e `docs/SatoWiki_PRD.md:148` parlano di una repository `satowiki-content` separata; i contenuti stanno in questa repository.
- [x] `CLAUDE.md`, `AGENTS.md` e `README.md` non citano `tool/sync_code_content.dart` né `tool/build_seed_bundle.dart`.
- [x] `docs/content-model.md` va riallineato al parser: campi obbligatori di `Bip` e `ReleaseNote`, formato di `coverImage`, regola di conservazione dei testi dopo la revisione.
- [x] `docs/content-todo.md` ha 33 voci non spuntate da ricontrollare: i media history esistono già. *Tutte e 33 verificate presenti su disco e spuntate.*

## Segnalazioni non confermate

Riportate dalla review ma non verificate. Vanno provate prima di lavorarci.

- Il cambio tab con `pushReplacementNamed` (`sato_wiki_shell.dart:86-93`) azzererebbe filtri e scroll delle tab. Serve una prova sul dispositivo.
- Area di tocco sotto i 44dp nelle righe delle fonti (`sources_disclosure.dart`) e nei link a piè di pagina delle schermate Code; testo troncato a scale grandi in `related_links_grid.dart:24` (`mainAxisExtent: 76`). Stime sul layout, non misurate.
- Possibile condizione di gara in `loadLanguage` (`app_content_controller.dart:90-106`) se la lingua cambia durante un download.
- Costo di avvio: parsing del seed e del Markdown sul thread principale prima di `runApp`. Non misurato.
- Requisiti correnti di App Store e Play Store su versione minima iOS e `targetSdk`. Da controllare sulla documentazione ufficiale.
- Il golden che fallisce è attribuito a una differenza di rendering di 4 pixel; non è stato escluso che sia una regressione.
- Formato della richiesta a Gemini (`responseFormat`, `sync_code_content.dart:927-931`): i run recenti passano, ma non è stato confrontato con la documentazione dell'API.

## Lavoro mai iniziato

Presente nel PRD o nella roadmap, assente nel codice: notifiche sui BIP seguiti, donazioni BTCPay/Lightning, changelog di LND, Core Lightning ed Eclair, zoom e filtri temporali della timeline, test di integrazione, beta su TestFlight e Play Internal, `CONTRIBUTING.md`.
