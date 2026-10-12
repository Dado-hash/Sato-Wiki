# Content Model

Questo documento descrive il contratto dati tra i sorgenti contenuti di questa repository, la pipeline CI e l'app Flutter.

Fonte autorevole: il parser `lib/src/core/content/data/content_bundle_parser.dart` e i modelli in `lib/src/core/content/domain/content_models.dart`. Quando questo documento e il parser non coincidono, vale il parser; le differenze note sono elencate in fondo.

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

Regole:

- `schemaVersion` governa compatibilita parser/migrazioni. La versione corrente e `1`. Se manca, si assume `1` con warning. Un valore maggiore di quello supportato dall'app e un errore fatale: il bundle non sostituisce quello locale valido.
- `language` del bundle e il fallback per i record che non dichiarano `language`.
- Una collezione mancante o non lista diventa lista vuota con warning.
- I campi extra sono ignorati. I seed contengono anche `historyCount` e `totalRecords`, che il parser non legge.

## Campi per tipo

Ogni record ha un `id` stringa non vuota. Gli id sono `wiki.slug`, `news.slug`, `history.slug`, `code.bip.<numero>` e `release.<project>.<version>`.

Sotto: campi che il parser richiede (obbligatori) e campi opzionali. Un record con un campo obbligatorio mancante o non valido viene saltato con warning; non blocca il bundle.

| Tipo | Obbligatori | Opzionali |
|---|---|---|
| `WikiEntry` | `id`, `slug`, `category`, `title`, `description`, `readingLevels` (con `base`, `medium`, `advanced`, ciascuno con `bodyMarkdown`), `difficulty`, `readTimeMinutes`, `updatedAt` | `language`, `coverImage`, `tags`, `sources`, `related` |
| `NewsArticle` | `id`, `slug`, `title`, `summary`, `category`, `author` (con `displayName`), `publishedAt`, `readTimeMinutes`, `bodyMarkdown`, `updatedAt` | `language`, `coverImage`, `tags`, `sources`, `related`; in `author`: `github`, `lightningAddress` |
| `HistoryEvent` | `id`, `slug`, `date`, `title`, `category`, `summary`, `bodyMarkdown`, `updatedAt` | `language`, `tags`, `sources`, `related` |
| `Bip` | `id`, `number`, `title`, `summary`, `status`, `category`, `createdAt`, `summaryMarkdown`, `impactMarkdown`, `officialUrl`, `updatedAt` | `language`, `authors`, `tags`, `sources`, `related`, `statusHistory`, `automation` |
| `ReleaseNote` | `id`, `slug`, `project`, `version`, `title`, `summary`, `releasedAt`, `importance`, `userImpactMarkdown`, `technicalChangesMarkdown`, `officialUrl`, `updatedAt` | `language`, `tags`, `sources`, `related`, `automation` |

Tipi e formati letti dal parser:

- date (`publishedAt`, `date`, `createdAt`, `releasedAt`, `updatedAt`): stringa ISO. Accetta `YYYY-MM-DD` e timestamp ISO completi.
- `officialUrl` e `coverImage` di news: URI assoluto (con schema).
- `coverImage` di wiki: URI relativo (vedi "Immagini inline").
- `readTimeMinutes`, `number`: intero.
- `tags`, `authors`: lista di stringhe. Assenti: lista vuota.
- `sources`: lista di oggetti `{ "title", "url", "author"?, "publishedAt"? }`. `title` e `url` (URI assoluto) sono obbligatori.
- `related`: lista di stringhe (id) oppure oggetti `{ "id", "title"? }`. Assente: lista vuota.
- `language` mancante: si usa `language` del bundle.

## WikiEntry

```json
{
  "id": "wiki.proof-of-work",
  "slug": "proof-of-work",
  "language": "en",
  "category": "protocol",
  "title": "Proof of Work",
  "description": "The consensus mechanism used to validate transactions...",
  "coverImage": "media/wiki/proof-of-work/hero.svg",
  "readingLevels": {
    "base": { "bodyMarkdown": "..." },
    "medium": { "bodyMarkdown": "..." },
    "advanced": { "bodyMarkdown": "..." }
  },
  "difficulty": "advanced",
  "readTimeMinutes": 15,
  "tags": ["Mining", "Consensus", "Cryptography"],
  "related": ["wiki.sha-256", "wiki.difficulty-adjustment"],
  "sources": [],
  "updatedAt": "2026-05-25T00:00:00Z"
}
```

`difficulty` accetta `base`, `medium` o `advanced`.

## Fixture Seed

La fixture locale inglese vive in `assets/content/seed_bundle_en.json`, quella italiana in `assets/content/seed_bundle_it.json`. Entrambe sono registrate come asset Flutter. I bundle sono separati per lingua: `assets/content/seed_bundle_{language}.json` per i seed locali.

Il bundle pubblicato e generato da `tool/generate_bundle.dart` in `build/pages/content/{language}/{version}/bundle.json`, con i media in `.../{version}/media/`, e il manifest in `build/pages/content/{language}/latest/manifest.json`. Vedi `docs/contributing-content.md`.

Serve per parser test, vertical slice e bootstrap offline.

## Immagini Inline

I campi Markdown (`bodyMarkdown`, `summaryMarkdown`, `impactMarkdown`,
`userImpactMarkdown`, `technicalChangesMarkdown`) supportano immagini inline con sintassi Markdown standard:

```md
![Alt descrittivo](media/wiki/utxo-model/utxo-flow.svg "Caption opzionale")
```

Regole:

- il path deve essere relativo e iniziare con `media/`;
- URL esterni, query string, fragment e segmenti `..` non sono ammessi;
- l'alt text e obbligatorio;
- il title Markdown diventa caption;
- formati supportati: `.png`, `.jpg`, `.jpeg`, `.webp`, `.svg`.

Le `WikiEntry` possono anche dichiarare `coverImage` con le stesse regole di path. Il parser accetta qualunque URI relativo; le regole sopra sono applicate dal validatore. L'immagine viene mostrata come visuale principale dell'articolo e viene inclusa nel prefetch media offline insieme alle immagini inline.

Durante l'update remoto l'app scarica tutte le immagini referenziate prima di
installare il bundle. L'installazione e atomica: un errore su una immagine
mantiene il bundle locale precedente. Limite noto: l'aggiornamento del testo viene riprovato a ogni avvio finche l'immagine non e disponibile (vedi `docs/app-architecture.md`).

Per il seed bundled, le immagini referenziate vivono in `assets/content/media/`
e vengono copiate nello store media locale al caricamento del bundle.

## Parser, Validazione E Fallback

Implementazione:

- modelli: `lib/src/core/content/domain/content_models.dart`;
- parser: `lib/src/core/content/data/content_bundle_parser.dart`;
- migrazione schema: `lib/src/core/content/data/content_bundle_migrator.dart`;
- validatore: `tool/validate_content.dart`;
- repository interfaces: `lib/src/features/*/domain/repositories/`.

Regole:

- JSON malformato, root non-oggetto o `schemaVersion` futuro sono errori fatali.
- Collezioni mancanti o non-lista diventano lista vuota con warning.
- Record non-oggetto o record con campi richiesti invalidi vengono saltati con warning.
- Uno `status` BIP non riconosciuto o una `importance` di release non riconosciuta fanno saltare il record con warning.
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
  "language": "en",
  "title": "The Activation of Taproot: A Retrospective",
  "summary": "Short summary of the article.",
  "category": "protocol",
  "author": {
    "github": "author-handle",
    "displayName": "Andreas M.",
    "lightningAddress": "optional"
  },
  "publishedAt": "2023-11-14",
  "readTimeMinutes": 12,
  "bodyMarkdown": "...",
  "tags": ["Taproot", "Upgrades"],
  "related": ["code.bip.341"],
  "sources": [],
  "updatedAt": "2023-11-14T00:00:00Z"
}
```

`coverImage` e opzionale e deve essere un URI assoluto (vedi "Differenze note").

## HistoryEvent

```json
{
  "id": "history.bitcoin-pizza-day",
  "slug": "bitcoin-pizza-day",
  "language": "en",
  "date": "2010-05-22",
  "title": "Bitcoin Pizza Day",
  "category": "community",
  "summary": "Laszlo Hanyecz made the first documented commercial transaction...",
  "bodyMarkdown": "...",
  "tags": [],
  "sources": [],
  "related": ["wiki.transactions"],
  "updatedAt": "2026-05-25T00:00:00Z"
}
```

Gli eventi sono append-only: correzioni ammesse solo per factual fix tracciati.

## Bip

```json
{
  "id": "code.bip.341",
  "number": 341,
  "language": "en",
  "title": "Taproot",
  "summary": "Defines the Taproot output type and its signature scheme.",
  "status": "deployed",
  "category": "consensus",
  "authors": ["Pieter Wuille", "Jonas Nick", "Anthony Towns"],
  "createdAt": "2020-01-19",
  "summaryMarkdown": "...",
  "impactMarkdown": "...",
  "officialUrl": "https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki",
  "tags": ["BIP", "Taproot"],
  "related": ["wiki.taproot", "news.taproot-retrospective"],
  "sources": [],
  "statusHistory": [],
  "updatedAt": "2026-05-25T00:00:00Z"
}
```

I record BIP non hanno `slug`.

Status canonici:

- `draft`
- `complete`
- `deployed`
- `closed`

Il parser accetta ancora alias legacy nei bundle esistenti:

| Alias | Stato canonico |
|---|---|
| `proposed`, `bip-number-allocated` | `draft` |
| `final` | `complete` |
| `active` | `deployed` |
| `withdrawn`, `rejected` | `closed` |

I bundle generati dalla pipeline devono pubblicare solo gli stati canonici.

I record BIP e release possono includere un oggetto opzionale `automation`
ignorato dal runtime app e usato dalla pipeline contenuti:

```json
{
  "automation": {
    "source": "sync_code_content.dart",
    "upstreamSha": "official-source-sha",
    "upstreamUrl": "https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki",
    "aiModel": "gemini-3.1-flash-lite",
    "aiPromptVersion": "code-sync-v1",
    "generatedAt": "2026-06-01T00:00:00Z",
    "needsReview": true
  }
}
```

### Conservazione dei testi

Il sync (`tool/sync_code_content.dart`) non sostituisce mai un testo non vuoto gia presente, a meno che nella stessa esecuzione non abbia generato una nuova bozza. Una bozza viene generata solo:

- per i record nuovi;
- per i record gestiti dall'AI, cioe con `automation.needsReview: true` oppure con `automation.aiModel`, il cui `upstreamSha` e cambiato rispetto alla fonte ufficiale.

Per proteggere un testo revisionato dalla rigenerazione: portare `needsReview` a `false` e rimuovere `aiModel` (e `aiPromptVersion`). Un record con `needsReview: false` e senza `aiModel` non viene piu toccato nel testo, anche quando la fonte cambia.

## ReleaseNote

```json
{
  "id": "release.bitcoin-core.27.0",
  "slug": "bitcoin-core-27-0",
  "language": "en",
  "project": "bitcoin-core",
  "version": "27.0",
  "title": "Bitcoin Core 27.0",
  "summary": "Bitcoin Core 27.0 release.",
  "releasedAt": "2024-04-16",
  "importance": "major",
  "userImpactMarkdown": "...",
  "technicalChangesMarkdown": "...",
  "officialUrl": "https://bitcoincore.org/en/releases/27.0/",
  "tags": ["Bitcoin Core", "Release"],
  "sources": [],
  "related": [],
  "updatedAt": "2024-04-16T00:00:00Z"
}
```

`importance` accetta `patch`, `minor`, `major`. La regola usata dal sync per assegnarla:

- `X.0` e `major` (per esempio `30.0`);
- `X.Y` con `Y` diverso da zero e `minor` (per esempio `29.3`);
- una terza componente diversa da zero e `patch`.

## Differenze note

- Il contratto generale di una versione precedente di questo documento richiedeva `summary` su ogni record. Il parser richiede `summary` su news, history, BIP e release, ma `description` sulle `WikiEntry` (che non hanno `summary`).
- I record `Bip` non hanno `slug`, mentre `NewsArticle`, `HistoryEvent` e `ReleaseNote` lo richiedono.
- `coverImage` non e uniforme: nelle wiki e un URI relativo (path `media/...`), nelle news il parser richiede un URI assoluto. Le copertine delle news non sono mostrate da nessuna schermata: il campo viene letto ma non usato.
- `HistoryEvent` non ha `coverImage`: il parser lo ignora. Le immagini di un evento si inseriscono nel Markdown del corpo.
- Il validatore richiede che i media delle wiki (`coverImage` incluso) siano sotto `media/` con estensione supportata, mentre il parser accetta qualunque URI relativo.
