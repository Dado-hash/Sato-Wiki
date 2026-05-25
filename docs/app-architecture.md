# App Architecture

## Stack

- Flutter per iOS e Android.
- Material 3 con tema custom derivato da Stitch.
- Contenuti Markdown/YAML nella futura repo `satowiki-content`.
- CI contenuti: Markdown/YAML -> JSON statico -> CDN + bundle offline.
- Runtime app: legge prima il bundle locale, poi aggiorna in background quando disponibile.

## Layout repository

```text
lib/
  main.dart
  src/
    app.dart
    core/
      theme/
      widgets/
      content/
      search/
      storage/
    features/
      shell/
      wiki/
      news/
      history/
      code/
```

Struttura target per ogni feature:

```text
feature/
  data/
    dto/
    repositories/
  domain/
    models/
    repositories/
    use_cases/
  presentation/
    screens/
    widgets/
```

La struttura attuale e volutamente leggera: contiene gia shell, tema e schermate starter. I layer `data/domain` vanno introdotti quando arrivano bundle, repository e parsing.

## Navigazione

Tab principali:

- `/wiki`
- `/news`
- `/history`
- `/code`

Route di dettaglio target:

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

Persistenza locale minima:

- ultima tab visitata;
- reading level preferito;
- preferenza lingua UI/contenuti (`system` oppure codice lingua supportato);
- versione bundle contenuti installata;
- BIP seguiti per notifiche future.

La fase Foundation introduce `AppSettingsRepository` e `AppSettingsController`
per ultima tab visitata e reading level preferito. L'implementazione iniziale
usa `shared_preferences`; storage piu strutturati restano da valutare quando
arrivano bundle, indice search e migrazioni.

## Content domain

Entita comuni:

- `ContentId`
- `LocalizedText`
- `Tag`
- `SourceReference`
- `RelatedContentLink`
- `Contributor`

Feature models:

- Wiki: `WikiEntry`, `ReadingLevelContent`, `WikiCategory`.
- News: `NewsArticle`, `AuthorProfile`, `LightningTipTarget`.
- History: `HistoryEvent`, `TimelineCategory`.
- Code: `Bip`, `BipStatus`, `ReleaseNote`, `ImplementationProject`.

## Offline-first

Flusso:

1. L'app installa un bundle seed.
2. All'avvio legge metadata versione.
3. Se online, controlla manifest remoto leggero.
4. Scarica bundle nuovo in background.
5. Verifica integrita e migra atomically.
6. Continua a servire contenuti locali se rete o CDN falliscono.

Implementazione corrente:

- `assets/content/seed_bundle_en.json` e caricato all'avvio come seed inglese.
- `LocalFirstContentBundleRepository` prova prima il bundle aggiornato in
  `shared_preferences` con chiave per lingua, poi torna al seed asset se il
  bundle aggiornato non e valido.
- `ContentManifest`, `RemoteContentManifestRepository` e
  `VerifiedBackgroundContentUpdater` definiscono manifest remoto, download
  bundle, verifica sha256, validazione schema e update background.
- `ContentStore` espone il bundle locale alle repository interface delle
  feature.
- La lingua contenuto risolta usa la preferenza app e le locale del sistema;
  nella v1 e attivo solo `en`, con fallback inglese per locale non supportate.

## Search

La ricerca deve coprire Wiki, News, History e Code. Fase iniziale:

- indice locale generato dal bundle;
- ricerca titolo/tag/summary;
- ranking semplice per sezione, match titolo e freschezza.

Implementazione corrente: `SearchIndex.fromBundle` genera un indice in memoria
per Wiki, News, History, BIP e release. `SearchScreen` permette filtro per
sezione e naviga alle route deep link locali.

Fase successiva:

- full-text con stemming per lingua;
- filtri per sezione, categoria, stato BIP e data.

## Stitch mapping

- Wiki explore: `wiki_explore_light`
- Wiki category list: `wiki_protocol_list_light`
- Wiki detail: `wiki_proof_of_work` e `wiki_proof_of_work_light`
- News reader: `news_article_reader_light`
- History timeline: `history_timeline_light`
- History detail: `history_bitcoin_pizza_day` e light
- Code dashboard/list: `code_bip_tracker_light`
- BIP detail: `code_bip_341_details_light`
