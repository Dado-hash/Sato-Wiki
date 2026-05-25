# SatoWiki

The Orange Book of Bitcoin.

SatoWiki e un'app Flutter open source per enciclopedia, news, storia e tracking tecnico dell'ecosistema Bitcoin. Il prodotto e descritto in `docs/SatoWiki_PRD.md`; le schermate Stitch locali sono in `stitch_satowiki_pages/`.

## Setup

Questa repo e stata inizializzata come applicazione Flutter per iOS e Android.

```bash
/Users/davide/development/flutter/bin/flutter pub get
/Users/davide/development/flutter/bin/flutter run
```

## Qualita e contenuti

```bash
/Users/davide/development/flutter/bin/dart format lib test tool
/Users/davide/development/flutter/bin/flutter analyze
/Users/davide/development/flutter/bin/flutter test
/Users/davide/development/flutter/bin/dart run tool/validate_content.dart
/Users/davide/development/flutter/bin/dart run tool/generate_bundle.dart
```

Il bundle seed inglese dell'app vive in `assets/content/seed_bundle_en.json`.
Il generatore produce bundle statici pubblicabili su GitHub Pages in
`build/pages/content/{language}/{version}/bundle.json` e il relativo manifest in
`build/pages/content/{language}/latest/manifest.json`. Genera anche
`build/pages/index.html`, una pagina indice minimale per evitare il 404 alla
root di GitHub Pages.

## Workflow contenuti

I contenuti editoriali partono dai template Markdown/YAML in
`content/templates/`. Oggi la pipeline inclusa nella repo valida e pubblica il
bundle JSON seed; i template servono come contratto sorgente per la futura repo
contenuti o per preparare nuovi record prima di inserirli nel bundle generato.

Workflow consigliato:

1. Scegli il template giusto in `content/templates/`.
2. Copialo nella repo contenuti o nella cartella di lavoro editoriale.
3. Compila il frontmatter YAML mantenendo `id`, `slug`, `language`, date ISO,
   `tags`, `sources`, `related` e `updatedAt`.
4. Scrivi il corpo Markdown seguendo le sezioni richieste dal template.
5. Rigenera o aggiorna il bundle JSON di lingua, per ora
   `assets/content/seed_bundle_en.json`.
6. Valida il bundle:

```bash
/Users/davide/development/flutter/bin/dart run tool/validate_content.dart assets/content/seed_bundle_en.json
```

7. Genera l'output statico pubblicabile:

```bash
/Users/davide/development/flutter/bin/dart run tool/generate_bundle.dart
```

8. Apri PR includendo sorgente Markdown/YAML, bundle JSON generato e, se cambia
   il contratto dati, `docs/content-model.md`.

### Wiki

Template: `content/templates/wiki_entry.md`.

Usalo per voci enciclopediche come concetti di protocollo, crittografia,
economia o Lightning. Campi chiave:

- `id`: formato stabile `wiki.slug-della-voce`.
- `category`: categoria di navigazione, per esempio `protocol`.
- `difficulty`: `base`, `medium` o `advanced`.
- `readTimeMinutes`: tempo di lettura stimato.
- corpo Markdown con tre sezioni obbligatorie: `## base`, `## medium`,
  `## advanced`.

Ogni livello deve poter essere letto autonomamente: `base` non deve dipendere da
`advanced`.

### Code

L'area Code ha due template:

- `content/templates/bip.md` per BIP.
- `content/templates/release_note.md` per changelog/release.

Per i BIP usa `id` nel formato `code.bip.341`, `number` numerico, `status`
tra `draft`, `proposed`, `active`, `final`, `withdrawn`, `rejected`, e
`officialUrl` alla fonte canonica. Il corpo deve contenere:

- `## summaryMarkdown`
- `## impactMarkdown`

Per le release usa `id` nel formato `release.project.version`, `project`,
`version`, `releasedAt`, `importance` tra `patch`, `minor`, `major`, e
`officialUrl`. Il corpo deve contenere:

- `## userImpactMarkdown`
- `## technicalChangesMarkdown`

### News

Template: `content/templates/news_article.md`.

Usalo per analisi editoriali e approfondimenti community. Campi chiave:

- `id`: formato `news.slug-articolo`.
- `category`: per esempio `protocol`, `market`, `culture`, `development`.
- `author.displayName` obbligatorio; `author.github` consigliato.
- `publishedAt` e `readTimeMinutes`.
- corpo Markdown libero dopo il frontmatter.

I link inline a Wiki/BIP devono essere riflessi anche in `related` quando sono
rilevanti per la navigazione interna.

### History

Template: `content/templates/history_event.md`.

Usalo per eventi storici della timeline. Campi chiave:

- `id`: formato `history.slug-evento`.
- `date`: data evento in formato `YYYY-MM-DD`.
- `category`: per esempio `community`, `protocol`, `economics`.
- `summary`: una frase breve, adatta a timeline e ricerca.
- corpo Markdown libero dopo il frontmatter.

Gli eventi storici dovrebbero essere append-only: correzioni ammesse, ma solo
per fix fattuali verificabili.

## Template e istruzioni disponibili

Si, i template necessari ci sono:

- Wiki: `content/templates/wiki_entry.md`
- Code/BIP: `content/templates/bip.md`
- Code/release: `content/templates/release_note.md`
- News: `content/templates/news_article.md`
- History: `content/templates/history_event.md`

Le istruzioni sintetiche sono in questo README; il contratto dati completo e in
`docs/content-model.md`, mentre il flusso contributor e riassunto in
`docs/contributing-content.md`.

## Documentazione

- `docs/design-system.md`: tema, token, componenti e regole UI derivate da Stitch.
- `docs/development-guidelines.md`: linee guida codice, frontend, accessibilita e test.
- `docs/app-architecture.md`: struttura Flutter, routing, stato, offline-first e search.
- `docs/content-model.md`: modelli dati target per bundle contenuti.
- `docs/contributing-content.md`: flusso contenuti, validazione e pubblicazione bundle.
- `docs/licensing.md`: licenze per codice, contenuti e font bundled.
- `docs/roadmap.md`: roadmap per macro aree e task sequenziali.

## Stato attuale

La base contiene:

- shell mobile con tab Wiki, News, History e Code;
- tema Material 3 dark-first allineato ai token Stitch;
- font Inter e JetBrains Mono bundled come asset locali;
- route nominate per tab principali e deep link target;
- persistenza locale di ultima tab visitata e reading level;
- localizzazione app predisposta con inglese attivo e bundle contenuti per lingua;
- update contenuti da bundle statici GitHub Pages con manifest e sha256;
- schermate starter per le quattro sezioni;
- test widget, parser, search e update contenuti.

## Licenze

Il codice applicativo e distribuito sotto MIT. I contenuti editoriali e la
documentazione sono distribuiti sotto CC BY-SA 4.0 salvo diversa indicazione.
