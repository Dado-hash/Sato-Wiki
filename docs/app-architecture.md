# App Architecture

## Stack

- Flutter per iOS e Android.
- Material 3 con tema custom in `lib/src/core/theme/`; le regole UI sono in `docs/design-system.md`.
- Contenuti Markdown/YAML in `content/` di questa repository; seed bundle JSON e media in `assets/content/`.
- CI contenuti: Markdown/YAML -> seed JSON -> bundle statico su GitHub Pages (CDN) + bundle offline.
- Runtime app: legge prima il bundle locale, poi aggiorna in background quando disponibile.

## Layout repository

```text
lib/
  main.dart
  l10n/                           # ARB inglese e italiano
  src/
    app.dart
    generated/l10n/               # codice generato dai file ARB
    core/
      content/
        application/              # AppContentController
        data/                     # parser, migrator, repository, media store
        domain/                   # modelli, ContentStore, regole media
        reading_level.dart
      localization/
      navigation/                 # AppRouter, AppRoutes, SatoWikiTab, content_routes
      search/                     # SearchIndex in memoria
      settings/                   # AppSettingsController e repository
      theme/
      widgets/
    features/
      shell/presentation/
      wiki/        domain/repositories/, presentation/
      news/        domain/repositories/, presentation/
      history/     domain/repositories/, presentation/
      code/        domain/repositories/, presentation/
      search/presentation/
```

Dove stanno i layer:

- I layer data e domain dei contenuti sono in `lib/src/core/content/`: parsing e validazione dei bundle, repository remoto e locale, store dei media e modelli.
- Le feature hanno solo le interfacce dei repository in `domain/repositories/` e le schermate in `presentation/`.
- La persistenza usa `shared_preferences` (impostazioni e bundle aggiornati) e il file system (media). Non esiste una cartella `storage/`.

## Navigazione

Tab principali:

- `/wiki`
- `/news`
- `/history`
- `/code`

Route di dettaglio:

- `/wiki/categories/:categoryId`
- `/wiki/entries/:entryId`
- `/news/articles/:articleId`
- `/history/events/:eventId`
- `/code/bips/:bipNumber`
- `/code/changelogs/:project/:version`

La shell conserva i quattro tab. Le route di dettaglio devono poter essere deep-linkate e tornare correttamente al tab di provenienza.
Le costanti e factory per le route vivono in `lib/src/core/navigation/app_routes.dart`;
la shell usa `SatoWikiTab` per allineare tab, label e route principali.

## Stato

Persistenza locale:

- ultima tab visitata (`settings.lastTab`);
- reading level preferito (`settings.readingLevel`);
- preferenza lingua UI/contenuti (`settings.localePreference`: `system` oppure codice lingua supportato);
- bundle aggiornato per lingua, come JSON in `shared_preferences` con chiave `content.updatedBundleJson.<lingua>`; la versione installata e quella del bundle salvato;
- media dei bundle nella application support directory (`content_media`), una cartella per versione del bundle.

Non implementato: la persistenza dei BIP seguiti e le notifiche su di essi. Non esiste ancora nessuna logica di follow.

La fase Foundation introduce `AppSettingsRepository` e `AppSettingsController`
per ultima tab visitata e reading level preferito. L'implementazione iniziale
usa `shared_preferences`; storage piu strutturati restano da valutare quando
arrivano indice search e migrazioni piu complesse.

## Content domain

Entita comuni:

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

Limite noto: se un media referenziato non si scarica, l'aggiornamento del testo viene scartato e viene riprovato a ogni avvio (vedi il test `updater keeps previous bundle when referenced media fails`).

## Search

La ricerca copre Wiki, News, History, BIP e release. Comportamento:

- indice in memoria generato dal bundle caricato (`SearchIndex.fromBundle`);
- campi indicizzati: titolo, tag e sommario. Il sommario e la `description` per le wiki, il `summary` per news, history e release, il `summary` per i BIP (il titolo di un BIP include il numero);
- il corpo del testo (`bodyMarkdown`, `summaryMarkdown`, `impactMarkdown`, `userImpactMarkdown`, `technicalChangesMarkdown`) non e indicizzato;
- query e campi sono normalizzati con maiuscole/minuscole e accenti (diacritic folding), quindi `bitcoin` trova anche `Bitcóin`; punteggiatura e trattini diventano spazi;
- la query viene divisa in termini; ogni termine deve comparire in titolo, tag o sommario (confronto per sottostringa dentro ciascun campo), altrimenti il risultato e escluso;
- il punteggio e ponderato: per ogni termine, titolo 8, tag 4, sommario 2; un bonus di 8 se l'intera query compare nel titolo. A parita di punteggio si ordina per titolo e poi per id;
- `SearchScreen` permette il filtro per sezione (`SearchSection`) e naviga alle route locali.

Non sono previsti stemming, ricerca full-text sul corpo, filtri per categoria o stato BIP, ne ranking per freschezza.

## Riferimenti di design storici

Le schermate Stitch da cui e partito il design (wiki explore, lista categoria, dettaglio wiki, news reader, history timeline, tracker BIP e dettaglio BIP) non sono piu nel repository. La fonte di verita e il codice in `lib/src/core/theme/` e le regole in `docs/design-system.md`.
