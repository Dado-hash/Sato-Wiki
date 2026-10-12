# App Architecture

## Stack

- Flutter per iOS e Android.
- Material 3 con tema chiaro e scuro in `lib/src/core/theme/`; le regole UI sono in `docs/design-system.md`. L'utente sceglie il tema in Impostazioni (sistema, chiaro, scuro).
- Contenuti Markdown/YAML in `content/` di questa repository; seed bundle JSON e media in `assets/content/`.
- CI contenuti: Markdown/YAML -> seed JSON -> bundle statico su GitHub Pages (CDN) + bundle offline.
- Runtime app: legge prima il bundle locale, poi aggiorna in background quando disponibile.

## Layout repository

```text
lib/
  main.dart
  l10n/                           # ARB inglese e italiano
  src/
    app.dart                      # SatoWikiApp: MaterialApp, tema chiaro e scuro, AppSettingsScope
    generated/l10n/               # codice generato dai file ARB
    core/
      content/
        application/              # AppContentController
        data/                     # parser, migrator, repository, media store
        domain/                   # modelli, ContentStore, regole media
        reading_level.dart
      localization/               # AppLocale, etichette localizzate, etichette dei contenuti
      navigation/                 # AppRouter, AppRoutes, SatoWikiTab, content_routes
      search/                     # SearchIndex in memoria
      settings/                   # AppSettingsController, repository, AppSettingsScope, ThemePreference
      theme/                      # AppTheme, AppColors, AppTokens, SatoColors
      widgets/                    # componenti condivisi (vedi docs/design-system.md)
    features/
      shell/presentation/         # shell a tab e tab bar
      today/presentation/         # schermata Oggi (home)
      wiki/        domain/repositories/, presentation/
      news/        domain/repositories/, presentation/
      history/     domain/repositories/, presentation/
      code/        domain/repositories/, presentation/   # BIP, release, dettagli e lista release
      search/presentation/
      settings/presentation/      # Impostazioni e segnalibri
```

Dove stanno i layer:

- I layer data e domain dei contenuti sono in `lib/src/core/content/`: parsing e validazione dei bundle, repository remoto e locale, store dei media e modelli.
- Le feature hanno solo le interfacce dei repository in `domain/repositories/` e le schermate in `presentation/`. Oggi, Impostazioni e segnalibri non hanno un `domain/`.
- La persistenza usa `shared_preferences` (impostazioni, segnalibri, progresso di lettura, ricerche recenti e bundle aggiornati) e il file system (media). Non esiste una cartella `storage/`.
- Il dettaglio di un BIP e di una release sta in un file proprio (`bip_detail_screen.dart`, `release_note_screen.dart`). `code_dashboard_screen.dart` li ri-esporta, quindi gli import che usano la dashboard continuano a funzionare.

## Navigazione

Tab principali (`SatoWikiTab`):

- `/today`
- `/wiki`
- `/news`
- `/history`
- `/code`

La tab bar (`SatoTabBar`) mostra le cinque tab. La shell (`SatoWikiShell`) tiene le cinque schermate in un `IndexedStack`, quindi ogni tab conserva filtri e posizione di scroll. L'ultima tab visitata è salvata in `settings.lastTab` e diventa la route iniziale (`/`).

Route fuori dalla tab bar:

- `/search`
- `/settings`
- `/bookmarks`
- `/wiki/categories/:categoryId`
- `/wiki/entries/:entryId`
- `/news/articles/:articleId`
- `/history/events/:eventId`
- `/code/bips`
- `/code/bips/:bipNumber`
- `/code/changelogs` (lista completa delle release)
- `/code/changelogs/:project/:version`

Regole:

- Le route di dettaglio si aprono sopra la tab corrente con `pushNamed`. Non cambiano la tab salvata, così la tab di provenienza resta visibile sotto.
- Un deep link a una tab la rende la tab salvata.
- Le costanti e le factory delle route vivono in `lib/src/core/navigation/app_routes.dart`. `SatoWikiTab` allinea tab, etichette e route principali.
- `routeForContentId` in `content_routes.dart` mappa un id di contenuto alla sua route. Il router (`app_router.dart`) risolve le route con nome e costruisce le schermate.
- Le schermate a tab non hanno un proprio `Scaffold`: la shell le avvolge in `SatoScaffold`. Le schermate a tab iniziano con `ScreenHeader`; le schermate push usano `DetailScaffold`. Nessuna schermata usa `AppBar`.

## Stato

`AppSettingsController` (in `lib/src/core/settings/`) è il punto unico per le preferenze e lo stato dell'utente. Lo carica `AppSettingsController.load` dal repository, che usa `shared_preferences`. Ogni chiave ha il prefisso `settings.`:

| Chiave | Contenuto |
|---|---|
| `settings.lastTab` | ultima tab visitata (route) |
| `settings.readingLevel` | livello di lettura preferito (Base, Medio, Avanzato) |
| `settings.localePreference` | lingua UI/contenuti: `system` oppure codice lingua supportato |
| `settings.themePreference` | `system`, `light` o `dark`; predefinito `dark` |
| `settings.readerTextScale` | scala del testo nei reader: 0.9, 1.0, 1.15 o 1.3; predefinito 1.0 |
| `settings.bookmarks` | id dei contenuti salvati, dal più recente |
| `settings.readingProgress` | mappa JSON id -> progresso (0 a 1) |
| `settings.lastRead` | id letti di recente, al massimo 20; il progresso degli id esclusi viene rimosso |
| `settings.recentSearches` | ultime ricerche, al massimo 6, dalla più recente |

Altre regole:

- Il progresso di lettura conserva il valore massimo visto. Un avanzamento minore di 0.02 rispetto al valore salvato viene ignorato. Da 0.98 in su il contenuto è considerato finito.
- `continueReadingId` è il primo id di `settings.lastRead` con progresso tra 0 e 0.98. Alimenta la sezione "Continua a leggere" della schermata Oggi.
- Gli errori di scrittura delle preferenze sono ignorati, per non interrompere la lettura. Le letture di chiavi mancanti o non valide tornano ai valori predefiniti.

Bundle e media:

- Il bundle aggiornato è salvato come JSON in `shared_preferences` con chiave `content.updatedBundleJson.<lingua>`; la versione installata e quella del bundle salvato.
- I media dei bundle stanno nella application support directory (`content_media`), una cartella per versione del bundle.
- L'indice di ricerca è generato in memoria all'avvio.

`AppSettingsScope` (`app_settings_scope.dart`) è un `InheritedNotifier` che porta il controller a tutto l'albero, ed è inserito in `MaterialApp.builder`. `AppSettingsScope.maybeOf(context)` restituisce il controller, oppure `null` quando non c'è uno scope (per esempio nei test). In quel caso i widget nascondono i segnalibri, trattano il progresso come 0 e la scala del testo come 1.0.

Non implementato: la persistenza dei BIP seguiti e le notifiche su di essi. Non esiste ancora nessuna logica di follow.

Le ricerche recenti e il progresso di lettura sono preferenze locali. Non vengono sincronizzate né inviate da nessuna parte.

## Content domain

Entità comuni:

- `SourceReference` (titolo, URL, autore, data);
- `RelatedContentLink` (id, titolo opzionale);
- `Contributor` (autore con `displayName`, `github`, `lightningAddress`);
- `ReadingLevel` e `ReadingLevelContent` per i livelli Base / Medio / Avanzato.

Gli id dei record sono stringhe stabili (`wiki.slug`, `news.slug`, `history.slug`, `code.bip.341`, `release.project.version`).

Modelli per feature (in `lib/src/core/content/domain/content_models.dart`):

- Wiki: `WikiEntry`.
- News: `NewsArticle`.
- History: `HistoryEvent`.
- Code: `Bip`, `BipStatus`, `BipStatusChange`, `ReleaseNote`, `ReleaseImportance`.

Il contratto di ogni modello, con i campi obbligatori letti dal parser, e in `docs/content-model.md`.

## Offline-first

Flusso:

1. L'app installa un bundle seed come asset.
2. All'avvio legge il bundle aggiornato salvato per la lingua; se non esiste o non e valido, usa il seed.
3. Se online, scarica il manifest leggero `content/{lingua}/latest/manifest.json`.
4. Se la versione e piu recente, scarica bundle e media, verifica sha256 e schema, poi installa.
5. Continua a servire contenuti locali se rete o CDN falliscono.

Implementazione corrente:

- `assets/content/seed_bundle_en.json` e `assets/content/seed_bundle_it.json` sono gli asset seed per lingua.
- `LocalFirstContentBundleRepository` (in `content_bundle_repository.dart`) prova prima il bundle aggiornato salvato per lingua, poi torna al seed se il bundle aggiornato non e valido.
- `ContentManifest`, `RemoteContentManifestRepository` e `VerifiedBackgroundContentUpdater` definiscono il manifest remoto, il download del bundle, la verifica sha256, la validazione dello schema e l'update in background.
- `ContentMediaStore` scarica i media referenziati dal bundle e riusa quelli gia presenti quando l'hash nel manifest coincide.
- `ContentStore` espone il bundle locale alle interfacce dei repository delle feature.
- La lingua contenuto risolta usa la preferenza app e le locale del sistema. I seed locali attivi sono `en` e `it`, con fallback inglese per locale non supportate.
- L'aggiornamento non blocca mai la UI. Quando inizia un download o un'installazione compare un banner in basso, sopra la tab bar (`UpdateProgressBanner`), che l'utente può chiudere e che sparisce da solo a fine aggiornamento o dopo un errore. Il controllo del manifest non mostra nulla.

Limite noto: se un media referenziato non si scarica, l'aggiornamento del testo viene scartato e viene riprovato a ogni avvio (vedi il test `updater keeps previous bundle when referenced media fails`).

## Search

La ricerca copre Wiki, News, History, BIP e release. La schermata di ricerca e una route push (`/search`), aperta dalle schermate a tab. Comportamento:

- indice in memoria generato dal bundle caricato (`SearchIndex.fromBundle`);
- campi indicizzati: titolo, tag e sommario. Il sommario e la `description` per le wiki, il `summary` per news, history e release, il `summary` per i BIP (il titolo di un BIP include il numero);
- il corpo del testo (`bodyMarkdown`, `summaryMarkdown`, `impactMarkdown`, `userImpactMarkdown`, `technicalChangesMarkdown`) non e indicizzato;
- query e campi sono normalizzati con maiuscole/minuscole e accenti (diacritic folding), quindi `bitcoin` trova anche `Bitcóin`; punteggiatura e trattini diventano spazi;
- la query viene divisa in termini; ogni termine deve comparire in titolo, tag o sommario (confronto per sottostringa dentro ciascun campo), altrimenti il risultato e escluso;
- il punteggio e ponderato: per ogni termine, titolo 8, tag 4, sommario 2; un bonus di 8 se l'intera query compare nel titolo. A parita di punteggio si ordina per titolo e poi per id;
- i risultati sono raggruppati per sezione (`SearchSection`), con un filtro per sezione;
- a campo vuoto la schermata mostra le ricerche recenti (con pulsante per cancellarle) e alcuni suggerimenti. Una ricerca eseguita si aggiunge alle recenti.

Non sono previsti stemming, ricerca full-text sul corpo, filtri per categoria o stato BIP, ne ranking per freschezza.

## Riferimenti di design storici

Le schermate Stitch da cui e partito il design (wiki explore, lista categoria, dettaglio wiki, news reader, history timeline, tracker BIP e dettaglio BIP) non sono piu nel repository. La fonte di verita e il codice in `lib/src/core/theme/` e le regole in `docs/design-system.md`.
