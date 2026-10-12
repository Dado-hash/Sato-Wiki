# Contributing Content

Content starts from Markdown/YAML templates in `content/templates/`. Everything lives in this repository:

- Markdown sources for wiki and history in `content/en/` and `content/it/`;
- seed bundles `assets/content/seed_bundle_en.json` and `assets/content/seed_bundle_it.json`, which hold every record type (wiki, news, history, BIP, release);
- images in `assets/content/media/`.

Flow:

1. Create or edit the content: a Markdown source under `content/{en,it}/` for wiki and history, or the record in the seed bundles for news, BIP and release records.
2. Update both seed bundles (EN and IT) so they contain the same records. Today the seed bundles are the source of truth for wiki and history too; see "Ricostruzione dei seed da Markdown" below.
3. Validate both bundles:

```bash
/Users/davide/development/flutter/bin/dart run tool/validate_content.dart assets/content/seed_bundle_en.json
/Users/davide/development/flutter/bin/dart run tool/validate_content.dart assets/content/seed_bundle_it.json
```

4. Generate the publishable output. `--stamp` assigns a new UTC version:

```bash
/Users/davide/development/flutter/bin/dart run tool/generate_bundle.dart --stamp
/Users/davide/development/flutter/bin/dart run tool/generate_bundle.dart --stamp assets/content/seed_bundle_it.json build/pages
```

5. Open a PR with the Markdown sources, the updated seed bundles and, if the data contract changes, `docs/content-model.md`.

The PR checks in `.github/workflows/flutter.yml` run the same validation (without `--strict`), generate both bundles, then run format, analysis and tests.

`--stamp` assigns automatically a new version `YYYY.MM.DD.HHMMSS` to the published bundle. Without a new version, the app may consider the content already installed and will not download text changes.

## Validation

`tool/validate_content.dart` checks a seed bundle and reports:

- Errors: a malformed or unsupported bundle; a `related` id that matches no record; a BIP with more than one status tag, or a status tag that contradicts its `status`; and the media problems listed in the next section.
- Warnings: records with `automation.needsReview: true`, and texts that still contain a generated placeholder (for example "Draft generated from official ...").

`--strict` turns warnings into errors. CI runs without it.

## Immagini inline

Nei corpi Markdown puoi inserire schemi e immagini con la sintassi standard:

```md
![Schema canali Lightning](media/lightning/channels/channel-lifecycle.svg "Ciclo di vita di un canale")
```

Usa solo file sotto `media/`, sempre con alt text descrittivo. I formati
supportati sono PNG, JPG/JPEG, WebP e SVG.

`validate_content.dart` controlla le immagini referenziate dal bundle (copertine wiki e immagini nei corpi di wiki, news, history, BIP e release): percorso relativo sotto `media/`, senza `..`, query o fragment, formato supportato, alt text non vuoto e file presente in `assets/content/`. Non controlla i percorsi scritti dentro i Markdown in `content/`.

## Publishing

Publishing target: static JSON bundle on GitHub Pages, with the media next to each version:

```text
content/{language}/{version}/bundle.json
content/{language}/{version}/media/...
content/{language}/latest/manifest.json
```

Each deploy replaces the whole Pages site, and older versions are not kept. Only the version currently published is reachable: `content/{language}/{old-version}/bundle.json` returns 404 after the next deploy. The app never uses versioned URLs directly. It always starts from `content/{language}/latest/manifest.json`, which points to the current `bundleUrl`.

The Pages deploy runs on pushes to `main` only when one of the seed bundles changed.

Current GitHub Pages target:

```text
https://dado-hash.github.io/Sato-Wiki/content/en/latest/manifest.json
https://dado-hash.github.io/Sato-Wiki/content/en/{version}/bundle.json   (current version only)
```

## Ricostruzione dei seed da Markdown

`tool/build_seed_bundle.dart <lang>` riscrive le sezioni `wiki` e `history` di `assets/content/seed_bundle_<lang>.json` a partire da `content/<lang>/`. Non e eseguito in CI e non e citato nei workflow.

I seed contengono oggi modifiche manuali che non sono nei Markdown (sommari history e fonti di alcune voci wiki). Rieseguire lo script riporterebbe quei valori alle versioni dei Markdown. Finche le due fonti non sono riconciliate, trattare i seed come fonte di verita per wiki e history e non eseguire lo script.

## Sync automatico Code

La sezione Code viene aggiornata da `tool/sync_code_content.dart`. Il workflow `.github/workflows/sync-code-content.yml` lo esegue ogni domenica alle 03:17 UTC, e a mano con `workflow_dispatch`.

Il sync legge i BIP da `bitcoin/bips` e le release notes di Bitcoin Core, genera bozze EN/IT con Gemini per i record nuovi o gestiti dall'AI, riscrive gli array `bips` e `changelogs` di entrambi i seed e apre una PR draft sul branch fisso `automation/code-content-sync`. Ogni run aggiorna la stessa PR.

Configurazione richiesta:

- secret GitHub `GEMINI_API_KEY`;
- variabile opzionale `GEMINI_MODEL`, default `gemini-3.1-flash-lite`.

Esecuzione manuale locale:

```bash
GEMINI_API_KEY=... /Users/davide/development/flutter/bin/dart run tool/sync_code_content.dart --require-ai --languages en,it --report build/code-content-sync-report.md
```

Senza `GEMINI_API_KEY` si puo usare `--skip-ai`: il sync crea i record con testi segnaposto da revisionare.

Importanza delle release: `X.0` e `major`, `X.Y` e `minor`, una terza componente diversa da zero e `patch`.

I record generati contengono `automation.needsReview: true`: prima del merge serve review tecnica/editoriale.

Conservazione dei testi: il sync non sostituisce un testo non vuoto gia presente, a meno che nella stessa esecuzione non abbia generato una nuova bozza. Una bozza viene generata solo per i record nuovi e per i record gestiti dall'AI (`automation.needsReview: true` oppure `automation.aiModel` presente) il cui `upstreamSha` e cambiato. Per proteggere un testo revisionato dalla rigenerazione, portare `needsReview` a `false` e rimuovere `aiModel`. Dettagli in `docs/content-model.md`.

Per recuperare lo storico dei BIP senza consumare credito Gemini, seguire la
guida per agent in `docs/code-bip-backfill-opencode.md`.
