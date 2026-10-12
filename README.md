# SatoWiki

The Orange Book of Bitcoin.

SatoWiki e un'app Flutter open source per enciclopedia, news, storia e tracking tecnico dell'ecosistema Bitcoin. Il prodotto e descritto in `docs/SatoWiki_PRD.md` e il design brief in `docs/SatoWiki_DesignBrief.md`. I token del tema derivano da esportazioni Stitch che non sono piu nel repository: la fonte di verita per tema e regole UI sono `docs/design-system.md` e `lib/src/core/theme/`.

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
/Users/davide/development/flutter/bin/dart run tool/validate_content.dart assets/content/seed_bundle_it.json
/Users/davide/development/flutter/bin/dart run tool/generate_bundle.dart --stamp
/Users/davide/development/flutter/bin/dart run tool/generate_bundle.dart --stamp assets/content/seed_bundle_it.json build/pages
```

Il bundle seed inglese dell'app vive in `assets/content/seed_bundle_en.json`, quello italiano in `assets/content/seed_bundle_it.json`.
Il generatore produce bundle statici pubblicabili su GitHub Pages in
`build/pages/content/{language}/{version}/bundle.json` (con i media in
`build/pages/content/{language}/{version}/media/`) e il relativo manifest in
`build/pages/content/{language}/latest/manifest.json`. Genera anche
`build/pages/index.html`, una pagina indice minimale per evitare il 404 alla
root di GitHub Pages. Ogni deploy sostituisce l'intero sito: sono raggiungibili
solo le versioni correnti, e l'app parte sempre da `latest/manifest.json`.

## Workflow contenuti

I contenuti sono **bilingue**: ogni voce deve essere creata sia in inglese che
in italiano. L'inglese e la lingua source; l'italiano e la lingua target.

Le fonti stanno in questa repository:

- sorgenti Markdown/YAML di wiki e history in `content/en/` e `content/it/`;
- template in `content/templates/`;
- bundle JSON seed in `assets/content/seed_bundle_en.json` e `assets/content/seed_bundle_it.json`;
- immagini in `assets/content/media/`.

Oggi i bundle seed sono la fonte di verita per wiki e history. `tool/build_seed_bundle.dart`
riscrive quelle sezioni dai Markdown, ma non e eseguito in CI e i seed contengono
modifiche manuali che non sono nei Markdown: eseguirlo riporterebbe quei valori
indietro. Vedi `docs/contributing-content.md`.

Workflow consigliato:

1. Scegli il template giusto in `content/templates/`.
2. Crea o modifica il sorgente Markdown/YAML in `content/{en,it}/` (wiki e history).
3. Aggiorna i bundle JSON di entrambe le lingue in `assets/content/`. Per news, BIP e release il bundle e l'unica fonte.
4. Valida i bundle:

```bash
/Users/davide/development/flutter/bin/dart run tool/validate_content.dart assets/content/seed_bundle_en.json
/Users/davide/development/flutter/bin/dart run tool/validate_content.dart assets/content/seed_bundle_it.json
```

5. Genera l'output statico pubblicabile:

```bash
/Users/davide/development/flutter/bin/dart run tool/generate_bundle.dart --stamp
/Users/davide/development/flutter/bin/dart run tool/generate_bundle.dart --stamp assets/content/seed_bundle_it.json build/pages
```

Usa `--stamp` quando vuoi pubblicare un aggiornamento scaricabile dall'app: il
generatore assegna una versione UTC `YYYY.MM.DD.HHMMSS` e aggiorna
`generatedAt` nel bundle prodotto, senza modificare i seed sorgente.

6. Apri PR includendo sorgente Markdown/YAML, bundle JSON generato e, se cambia
   il contratto dati, `docs/content-model.md`.

Il validatore segnala come errori i riferimenti `related` verso id inesistenti,
gli stati BIP contraddetti dai tag e i media mancanti o non validi. Come warning
segnala record con `automation.needsReview: true` e testi segnaposto; con
`--strict` i warning diventano errori.

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
tra `draft`, `complete`, `deployed`, `closed`, e `officialUrl` alla fonte
canonica. Il parser accetta anche gli alias legacy `proposed`, `final`,
`active`, `withdrawn`, `rejected` e `bip-number-allocated`, ma i bundle
pubblicati devono usare solo gli stati canonici. Il corpo deve contenere:

- `## summaryMarkdown`
- `## impactMarkdown`

Per le release usa `id` nel formato `release.project.version`, `project`,
`version`, `releasedAt`, `importance` tra `patch`, `minor`, `major`, e
`officialUrl`. Il sync assegna la importance cosi: `X.0` major, `X.Y` minor, terza
componente diversa da zero patch. Il corpo deve contenere:

- `## userImpactMarkdown`
- `## technicalChangesMarkdown`

#### Sync automatico Code

`tool/sync_code_content.dart` aggiorna gli array `bips` e `changelogs` di entrambi
i seed. Il workflow `.github/workflows/sync-code-content.yml` lo esegue ogni
domenica alle 03:17 UTC, oppure a mano con `workflow_dispatch`. Legge i BIP da
`bitcoin/bips` e le release notes di Bitcoin Core, chiede a Gemini bozze per i
record nuovi o gestiti dall'AI, e apre una PR draft dal branch fisso
`automation/code-content-sync` per la review del maintainer. Richiede il secret
`GEMINI_API_KEY`; `GEMINI_MODEL` e opzionale. Le regole di conservazione dei
testi sono in `docs/content-model.md`.

#### Ricostruzione dei seed da Markdown

`tool/build_seed_bundle.dart <lang>` riscrive le sezioni `wiki` e `history` di
`assets/content/seed_bundle_<lang>.json` a partire da `content/<lang>/`. Non e
eseguito in CI e non va usato finche i seed e i Markdown non sono riconciliati.

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

### Immagini inline

Tutti i corpi Markdown supportano immagini inline con sintassi standard:

```md
![Schema UTXO](media/wiki/utxo-model/utxo-flow.svg "Flusso semplificato degli UTXO")
```

Regole:

- usare solo path relativi sotto `media/`;
- non usare URL esterni o segmenti `..`;
- scrivere sempre un alt text descrittivo;
- usare il title Markdown per la caption opzionale;
- formati supportati: `.png`, `.jpg`, `.jpeg`, `.webp`, `.svg`.

Le immagini stanno in `assets/content/media/`, accanto al bundle seed. Il
generatore le copia nel bundle pubblicato e l'app le scarica insieme al bundle.
Se una immagine referenziata non e disponibile, l'update contenuti viene
scartato per mantenere il comportamento offline-first.

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
`docs/content-model.md`, mentre il flusso contributor e descritto in
`docs/contributing-content.md`.

## Documentazione

- `docs/design-system.md`: tema, token, componenti e regole UI (i token derivano da esportazioni Stitch non piu nel repository).
- `docs/image-generation-guidelines.md`: stile, prompt e checklist per immagini dei contenuti.
- `docs/development-guidelines.md`: linee guida codice, frontend, accessibilita e test.
- `docs/app-architecture.md`: struttura Flutter, routing, stato, offline-first e search.
- `docs/content-model.md`: contratto dati dei bundle contenuti.
- `docs/contributing-content.md`: flusso contenuti, validazione, pubblicazione bundle e sync Code.
- `docs/licensing.md`: licenze per codice, contenuti e font bundled.
- `docs/roadmap.md`: roadmap per macro aree e task sequenziali.

## Stato attuale

La base contiene:

- shell mobile con tab Wiki, News, History e Code;
- tema Material 3 dark-first (token in `lib/src/core/theme/`);
- font Inter e JetBrains Mono bundled come asset locali;
- route nominate per tab principali e deep link target;
- persistenza locale di ultima tab visitata e reading level;
- localizzazione app predisposta con inglese attivo e bundle contenuti per lingua;
- update contenuti da bundle statici GitHub Pages con manifest e sha256;
- schermate per le quattro sezioni;
- test widget, parser, search e update contenuti.

## Licenze

Il codice applicativo e distribuito sotto MIT. I contenuti editoriali e la
documentazione sono distribuiti sotto CC BY-SA 4.0 salvo diversa indicazione.
