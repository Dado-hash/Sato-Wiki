# BIP Backfill Guidelines For OpenCode Agents

Questa guida serve per creare lo storico dei BIP passati senza consumare
credito Gemini. L'obiettivo e arrivare a record BIP revisionati nei bundle
SatoWiki, cosi il workflow automatico aggiornera solo metadati e novita future.

## Obiettivo

Per ogni lotto di BIP assegnato:

- leggere solo fonti ufficiali `bitcoin/bips`;
- compilare contenuti EN e IT nei seed bundle;
- scrivere testi tecnici brevi, neutrali e verificabili;
- marcare i record come revisionati, non come bozze AI;
- non usare Gemini o altre API generative.

La sezione Code non usa file Markdown separati per ogni BIP: le pagine app sono
generate dai record `bips` in:

```text
assets/content/seed_bundle_en.json
assets/content/seed_bundle_it.json
```

## Preparazione Del Lotto

1. Partire da un branch dedicato, per esempio:

```bash
git checkout -b content/bip-backfill-001-020
```

2. Se i BIP non esistono ancora nei bundle, creare prima gli skeleton senza AI:

```bash
/Users/davide/development/flutter/bin/dart run tool/sync_code_content.dart --skip-ai --languages en,it
```

Questo comando legge fonti ufficiali e crea record fattuali con placeholder da
review. Non richiede `GEMINI_API_KEY`.

3. Limitare il lavoro a un lotto piccolo, consigliato 10-20 BIP per PR. Esempi:

```text
BIP 1-20
BIP 21-40
BIP 340-342
```

## Fonti Ammesse

Usare come fonte primaria il file ufficiale del BIP:

```text
https://github.com/bitcoin/bips/blob/master/bip-XXXX.mediawiki
https://github.com/bitcoin/bips/blob/master/bip-XXXX.md
```

Si possono usare altri link ufficiali presenti nel BIP stesso solo per chiarire
termini o contesto, ma il record SatoWiki deve restare una sintesi del BIP.

Non usare blog, thread social, video, riassunti non ufficiali o modelli AI per
scrivere il contenuto.

## Campi Da Compilare

Per ogni record in `bips`, verificare o aggiornare:

- `title`: titolo ufficiale del BIP.
- `summary`: una frase chiara e breve.
- `status`: usare solo `draft`, `complete`, `deployed`, `closed`.
- `category`: categoria tecnica semplice, per esempio `consensus`,
  `process`, `peer-services`, `applications`, `informational`.
- `authors`: autori dal preamble ufficiale.
- `createdAt`: data `Assigned` se presente.
- `summaryMarkdown`: spiegazione leggibile in 1-3 paragrafi.
- `impactMarkdown`: impatto pratico/tecnico in 1-3 paragrafi.
- `officialUrl`: link al file ufficiale nel repo `bitcoin/bips`.
- `tags`: includere almeno `BIP` e 1-3 tag utili.
- `sources`: includere il BIP ufficiale.
- `related`: aggiungere link solo se esistono gia nel bundle.
- `statusHistory`: mantenere eventi noti solo se verificabili.

Per il bundle italiano, tradurre in italiano naturale mantenendo termini tecnici
Bitcoin quando sono standard: `soft fork`, `script`, `wallet`, `node`,
`consensus`, `mempool`, `peer`.

## Regole Editoriali

- Scrivere in tono tecnico-editoriale, non promozionale.
- Non dire che un BIP e "approvato" se lo status ufficiale non lo implica.
- Distinguere sempre proposta, specifica, implementazione e deployment.
- Evitare frasi vaghe tipo "migliora Bitcoin" senza spiegare come.
- Non inventare impatti utente se il BIP e puramente process/informational.
- Se il BIP e obsoleto o chiuso, spiegare brevemente cosa lo ha sostituito solo
  se la fonte ufficiale lo rende chiaro.

## Automation Metadata

Quando il record e stato revisionato da un agent/persona, assicurarsi che non
rimanga gestito come bozza AI.

Forma consigliata:

```json
"automation": {
  "source": "sync_code_content.dart",
  "upstreamSha": "sha-esistente-se-presente",
  "upstreamUrl": "https://github.com/bitcoin/bips/blob/master/bip-XXXX.mediawiki",
  "needsReview": false
}
```

Regole:

- `needsReview` deve essere `false` per i record completati.
- Rimuovere `aiModel` e `aiPromptVersion` dai record revisionati.
- Se `upstreamSha` non e noto, si puo omettere: il prossimo sync lo aggiungera
  senza chiamare Gemini, purche `needsReview` sia `false` e non ci sia `aiModel`.

## Verifica Obbligatoria

Prima di chiudere il lotto:

```bash
/Users/davide/development/flutter/bin/dart format lib test tool
/Users/davide/development/flutter/bin/flutter analyze
/Users/davide/development/flutter/bin/flutter test
/Users/davide/development/flutter/bin/dart run tool/validate_content.dart assets/content/seed_bundle_en.json
/Users/davide/development/flutter/bin/dart run tool/validate_content.dart assets/content/seed_bundle_it.json
```

Se il lotto modifica solo contenuti JSON, i test completi possono comunque
girare: sono il modo piu semplice per verificare parser, search e app shell.

## Checklist Finale Per PR

- Il lotto dichiarato e l'unico modificato.
- EN e IT contengono gli stessi BIP.
- Nessun record completato ha `needsReview: true`.
- Nessun record completato ha `aiModel` o `aiPromptVersion`.
- Ogni `officialUrl` punta a `bitcoin/bips`.
- Ogni record ha `sources` con il BIP ufficiale.
- `flutter analyze`, `flutter test` e validazione bundle sono verdi.

## Prompt Breve Per Agent

```text
Backfill SatoWiki BIP records for BIP <range>.
Use only official bitcoin/bips sources.
Do not call Gemini or any generative API.
Edit assets/content/seed_bundle_en.json and assets/content/seed_bundle_it.json.
Write concise reviewed EN/IT summaries and impact text.
Set automation.needsReview=false and remove aiModel/aiPromptVersion for completed records.
Run format, analyze, tests, and validate both bundles.
Do not touch unrelated files or existing user changes.
```
