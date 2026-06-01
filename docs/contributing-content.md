# Contributing Content

Content starts from Markdown/YAML templates in `content/templates/`.

Flow:

1. Create or edit content in the content repo.
2. Generate JSON bundle.
3. Validate JSON with:

```bash
/Users/davide/development/flutter/bin/dart run tool/validate_content.dart assets/content/seed_bundle_en.json
/Users/davide/development/flutter/bin/dart run tool/validate_content.dart assets/content/seed_bundle_it.json
```

4. Open PR with generated bundle and source Markdown.

PR checks must run:

```bash
/Users/davide/development/flutter/bin/dart run tool/validate_content.dart
/Users/davide/development/flutter/bin/dart run tool/generate_bundle.dart --stamp
/Users/davide/development/flutter/bin/dart run tool/generate_bundle.dart --stamp assets/content/seed_bundle_it.json build/pages
```

`--stamp` assegna automaticamente una nuova versione UTC
`YYYY.MM.DD.HHMMSS` al bundle pubblicato. Senza una versione nuova, l'app puo
considerare il contenuto gia installato e non riscaricare modifiche testuali.

## Immagini inline

Nei corpi Markdown puoi inserire schemi e immagini con la sintassi standard:

```md
![Schema canali Lightning](media/lightning/channels/channel-lifecycle.svg "Ciclo di vita di un canale")
```

Usa solo file sotto `media/`, sempre con alt text descrittivo. I formati
supportati sono PNG, JPG/JPEG, WebP e SVG. `validate_content.dart` fallisce se
un'immagine referenziata non esiste o non segue queste convenzioni.

Publishing target: static JSON bundle on CDN plus immutable versioned path:

```text
content/{language}/{version}/bundle.json
content/{language}/latest/manifest.json
```

Current GitHub Pages target:

```text
https://dado-hash.github.io/Sato-Wiki/content/en/latest/manifest.json
https://dado-hash.github.io/Sato-Wiki/content/en/{version}/bundle.json
```

## Sync automatico Code

La sezione Code viene preparata da `tool/sync_code_content.dart`, che legge
fonti ufficiali Bitcoin (`bitcoin/bips` e release notes Bitcoin Core), genera
bozze EN/IT con Gemini e apre una PR draft tramite
`.github/workflows/sync-code-content.yml`.

Configurazione richiesta:

- secret GitHub `GEMINI_API_KEY`;
- variabile opzionale `GEMINI_MODEL`, default `gemini-3.1-flash-lite-preview`.

Esecuzione manuale locale:

```bash
GEMINI_API_KEY=... /Users/davide/development/flutter/bin/dart run tool/sync_code_content.dart --require-ai --languages en,it --report build/code-content-sync-report.md
```

I record generati contengono `automation.needsReview: true`: prima del merge
serve review tecnica/editoriale. Dopo review, portare `needsReview` a `false`
o rimuoverlo se si vuole preservare il testo nei sync successivi.
