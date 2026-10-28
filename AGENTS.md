# AGENTS.md

Guida rapida per agenti che lavorano su SatoWiki.

## Contesto Progetto

SatoWiki e una app Flutter iOS/Android: "The Orange Book of Bitcoin". Il PRD e in `docs/SatoWiki_PRD.md`; il design brief e in `docs/SatoWiki_DesignBrief.md`. Le schermate Stitch da cui sono partiti i token non sono piu nel repository: la fonte di verita e `docs/design-system.md` insieme a `lib/src/core/theme/`.

La direzione prodotto e:

- enciclopedia Bitcoin con livelli di lettura Base / Medio / Avanzato;
- news editoriali e approfondimenti community;
- timeline storica Bitcoin;
- tracker tecnico per BIP e changelog;
- offline-first, privacy-first, open source.

## Comandi

Serve Flutter 3.47 o successivo (Dart 3.13), con `flutter` e `dart` nel PATH:

```bash
flutter pub get
flutter analyze
flutter test
dart format lib test tool
```

## Struttura

```text
lib/
  main.dart
  l10n/                    # ARB inglese e italiano
  src/
    app.dart
    generated/l10n/        # codice generato, non modificare a mano
    core/
      content/             # bundle: application/, data/ (parser, repository, media), domain/
      localization/
      navigation/
      search/
      settings/              # AppSettingsController, AppSettingsScope, preferenze
      theme/                 # AppTheme, AppTokens, SatoColors
      widgets/
    features/
      shell/
      today/
      wiki/
      news/
      history/
      code/
      search/
      settings/              # Impostazioni e segnalibri
assets/
  content/                 # seed_bundle_en.json, seed_bundle_it.json, media/
  fonts/                   # Space Grotesk, Inter, JetBrains Mono
content/                   # sorgenti Markdown (en, it) e template
tool/                      # script dei contenuti (validazione, generazione, sync, seed)
test/
docs/
.github/workflows/
```

Usare `lib/src/core/theme` per token e tema, `lib/src/core/widgets` per componenti condivisi, e `lib/src/features/*` per UI e logica specifica di sezione. Il caricamento, il parsing e la verifica dei bundle stanno in `lib/src/core/content/`, non nelle feature.

## Documentazione Da Leggere Prima Di Modificare

- `docs/design-system.md` per tema, token e regole UI.
- `docs/development-guidelines.md` per stile codice, frontend e test.
- `docs/app-architecture.md` per struttura, routing, offline e search.
- `docs/content-model.md` per contratti dati.
- `docs/contributing-content.md` per il flusso dei contenuti.
- `docs/roadmap.md` per priorita e task sequenziali.
- `docs/plan.md` per le scelte di progetto dietro la roadmap.
- `docs/content-todo.md` per l'elenco dei contenuti da scrivere.

## Design E UI

La dark mode e canonica. I token sono definiti in `lib/src/core/theme/` e descritti in `docs/design-system.md`.

Regole pratiche:

- Material 3 custom, estetica editoriale tecnica, non crypto/neon.
- Space Grotesk per titoli, Inter per il corpo, JetBrains Mono solo per dati ed etichette maiuscole.
- Card senza ombre pesanti: usare tonal surface e bordo sottile.
- Touch target minimo 44dp.
- Tab bar flottante con cinque tab: Oggi, Wiki, News, History, Code. Nessun AppBar: schermate a tab con `ScreenHeader`, schermate push con `DetailScaffold`.
- Testi e colori devono venire dal tema quando possibile: `colorScheme`, `context.sato`, `textTheme`.
- Evitare hex locali nei componenti; spaziature e raggi da `AppSpacing` e `AppRadii` in `app_tokens.dart`.

## Coding Rules

- Mantenere `flutter analyze` pulito.
- Preferire widget piccoli e leggibili.
- Usare `const` dove possibile.
- Non mettere parsing dati o accesso storage dentro widget presentation.
- Il layer data dei contenuti sta in `lib/src/core/content/data/`; le feature espongono interfacce in `domain/repositories/`.
- Usare enum per stati noti come reading level e BIP status.
- Aggiornare docs quando si cambiano architettura, data model o design system.
- Regola sulle chiavi: nessuno strumento genera o gestisce chiavi private, tranne la sandbox Dadi → Seed (`tool_dice_screen.dart`, `dice_sandbox_screen.dart`). Un WIF o una chiave estesa incollata viene riconosciuto solo per svuotare il campo e mostrare un avviso. La sandbox genera una seed BIP39 da dadi fisici, offline e solo in memoria: niente salvataggi, log, clipboard, selezione o `TextField`; screenshot e registrazione bloccati dove la piattaforma lo permette; sessione cancellata all'uscita, al passaggio in background e allo screenshot; parole, bit e valori della matematica nascosti finché non si tiene premuto. Dettagli in `docs/dice-seed.md`. La fotocamera è usata solo dalla sandbox: i fotogrammi non vengono mai salvati, e i test dei dadi non aprono la fotocamera.

## Contenuti

- `tool/validate_content.dart [--strict] [bundle.json]`: schema, media, riferimenti `related`, stati BIP e warning su record da rivedere o testi segnaposto.
- `tool/generate_bundle.dart --stamp [bundle.json] [pagesRoot]`: genera il bundle statico per GitHub Pages in `build/pages`.
- `tool/sync_code_content.dart`: sync settimanale di BIP e release Bitcoin Core dai sorgenti ufficiali, con bozze AI da rivedere. Apre una PR draft su `automation/code-content-sync`. Non sovrascrive testi gia revisionati: vedi `docs/content-model.md`.
- `tool/build_seed_bundle.dart <lang>`: riscrive wiki e history dei seed dai Markdown. Non e in CI e, finche seed e Markdown non sono riconciliati, non va eseguito (riscriverebbe le modifiche manuali dei seed).

## File Sensibili E Artefatti

- Non committare `.codex/`: puo contenere configurazioni locali e chiavi MCP.
- Non committare `.DS_Store`, `.dart_tool/`, `build/`, `.idea/`.
- `pubspec.lock` va mantenuto: questa repo e una app.
- `assets/content/seed_bundle_*.json` e `content/` sono contenuti editoriali: modificarli seguendo `docs/contributing-content.md`.

## Verifica Minima Prima Di Chiudere

Per modifiche Dart/Flutter:

```bash
dart format lib test
flutter analyze
flutter test
```

Se non puoi eseguire un comando, segnalo chiaramente nel riepilogo finale.
