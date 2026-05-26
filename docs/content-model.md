# Content Model

Questo documento descrive il contratto dati target tra repo contenuti, pipeline CI e app Flutter.

## Bundle

```json
{
  "schemaVersion": 1,
  "version": "2026.05.25",
  "language": "en",
  "generatedAt": "2026-05-25T00:00:00Z",
  "wiki": [],
  "news": [],
  "history": [],
  "bips": [],
  "changelogs": []
}
```

`schemaVersion` governa compatibilita parser/migrazioni. La versione corrente e
`1`; bundle futuri con schema maggiore della app sono fatal error e non devono
sostituire il bundle locale valido.

Ogni record deve includere:

- `id` stabile;
- `slug` leggibile;
- `language`;
- `title`;
- `summary`;
- `tags`;
- `sources`;
- `related`;
- `updatedAt`.

## WikiEntry

```json
{
  "id": "wiki.proof-of-work",
  "slug": "proof-of-work",
  "category": "protocol",
  "title": "Proof of Work",
  "description": "The consensus mechanism used to validate transactions...",
  "readingLevels": {
    "base": { "bodyMarkdown": "..." },
    "medium": { "bodyMarkdown": "..." },
    "advanced": { "bodyMarkdown": "..." }
  },
  "difficulty": "advanced",
  "readTimeMinutes": 15,
  "tags": ["Mining", "Consensus", "Cryptography"],
  "related": ["wiki.sha-256", "wiki.difficulty-adjustment"],
  "sources": []
}
```

## Fixture Seed

La fixture locale iniziale inglese vive in `assets/content/seed_bundle_en.json`
ed e registrata come asset Flutter. I bundle sono separati per lingua:
`seed_bundle_{language}.json` per seed locali e `content/{language}/...` per CDN.
Serve per parser test, vertical slice e futuro bootstrap offline.

## Immagini Inline

I campi Markdown (`bodyMarkdown`, `summaryMarkdown`, `impactMarkdown`,
`userImpactMarkdown`, `technicalChangesMarkdown` e i livelli Wiki) supportano
immagini inline con sintassi Markdown standard:

```md
![Alt descrittivo](media/wiki/utxo-model/utxo-flow.svg "Caption opzionale")
```

Regole:

- il path deve essere relativo e iniziare con `media/`;
- URL esterni, query string, fragment e segmenti `..` non sono ammessi;
- l'alt text e obbligatorio;
- il title Markdown diventa caption;
- formati supportati: `.png`, `.jpg`, `.jpeg`, `.webp`, `.svg`.

Durante l'update remoto l'app scarica tutte le immagini referenziate prima di
installare il bundle. L'installazione e atomica: un errore su una immagine
mantiene il bundle locale precedente.

## Parser, Validazione E Fallback

Implementazione:

- modelli: `lib/src/core/content/domain/content_models.dart`;
- parser: `lib/src/core/content/data/content_bundle_parser.dart`;
- migrazione schema: `lib/src/core/content/data/content_bundle_migrator.dart`;
- repository interfaces: `lib/src/features/*/domain/repositories`.

Regole:

- JSON malformato, root non-oggetto o `schemaVersion` futuro sono errori fatali.
- Collezioni mancanti o non-lista diventano lista vuota con warning.
- Record non-oggetto o record con campi richiesti invalidi vengono saltati con warning.
- `language` del record puo mancare e ricade su `bundle.language`.
- `sources` e `related` possono essere vuoti.
- `related` accetta string ID o oggetto `{ "id": "...", "title": "..." }`.

Fallback runtime previsto:

1. provare il bundle aggiornato locale;
2. se fatal error, mantenere ultimo bundle valido;
3. se non esiste ultimo bundle valido, caricare `assets/content/seed_bundle_en.json`
   come fallback inglese;
4. mostrare warning recuperabili in diagnostica/log non invasivi.

## NewsArticle

```json
{
  "id": "news.taproot-retrospective",
  "slug": "taproot-retrospective",
  "title": "The Activation of Taproot: A Retrospective",
  "category": "protocol",
  "author": {
    "github": "author-handle",
    "displayName": "Andreas M.",
    "lightningAddress": "optional"
  },
  "publishedAt": "2023-11-14",
  "readTimeMinutes": 12,
  "coverImage": "optional",
  "bodyMarkdown": "...",
  "tags": ["Taproot", "Upgrades"],
  "related": ["code.bip.341"]
}
```

## HistoryEvent

```json
{
  "id": "history.bitcoin-pizza-day",
  "slug": "bitcoin-pizza-day",
  "date": "2010-05-22",
  "title": "Bitcoin Pizza Day",
  "category": "community",
  "summary": "Laszlo Hanyecz made the first documented commercial transaction...",
  "bodyMarkdown": "...",
  "sources": [],
  "related": ["wiki.transactions"]
}
```

Gli eventi sono append-only: correzioni ammesse solo per factual fix tracciati.

## Bip

```json
{
  "id": "code.bip.341",
  "number": 341,
  "title": "Taproot",
  "status": "active",
  "category": "consensus",
  "authors": ["Pieter Wuille", "Jonas Nick", "Anthony Towns"],
  "createdAt": "2020-01-19",
  "summaryMarkdown": "...",
  "impactMarkdown": "...",
  "officialUrl": "https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki",
  "related": ["wiki.taproot", "news.taproot-retrospective"],
  "statusHistory": []
}
```

Status ammessi:

- `draft`
- `proposed`
- `active`
- `final`
- `withdrawn`
- `rejected`

## ReleaseNote

```json
{
  "id": "release.bitcoin-core.27.0",
  "project": "bitcoin-core",
  "version": "27.0",
  "releasedAt": "2024-04-16",
  "importance": "major",
  "userImpactMarkdown": "...",
  "technicalChangesMarkdown": "...",
  "officialUrl": "..."
}
```
