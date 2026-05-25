# AGENTS.md

Guida rapida per agenti che lavorano su SatoWiki.

## Contesto Progetto

SatoWiki e una app Flutter iOS/Android: "The Orange Book of Bitcoin". Il PRD e in `SatoWiki_PRD.md`; il design brief e in `SatoWiki_DesignBrief.md`; le schermate Stitch esportate sono in `stitch_satowiki_pages/`.

La direzione prodotto e:

- enciclopedia Bitcoin con livelli di lettura Base / Medio / Avanzato;
- news editoriali e approfondimenti community;
- timeline storica Bitcoin;
- tracker tecnico per BIP e changelog;
- offline-first, privacy-first, open source.

## Comandi

Flutter non e necessariamente nel PATH. Usare l'SDK locale:

```bash
/Users/davide/development/flutter/bin/flutter pub get
/Users/davide/development/flutter/bin/flutter analyze
/Users/davide/development/flutter/bin/flutter test
/Users/davide/development/flutter/bin/dart format lib test
```

## Struttura

```text
lib/
  main.dart
  src/
    app.dart
    core/
      theme/
      widgets/
    features/
      shell/
      wiki/
      news/
      history/
      code/
docs/
stitch_satowiki_pages/
```

Usare `lib/src/core/theme` per token e tema, `lib/src/core/widgets` per componenti condivisi, e `lib/src/features/*` per UI e logica specifica di sezione.

## Documentazione Da Leggere Prima Di Modificare

- `docs/design-system.md` per tema, token e regole UI.
- `docs/development-guidelines.md` per stile codice, frontend e test.
- `docs/app-architecture.md` per struttura target, routing, offline e search.
- `docs/content-model.md` per contratti dati.
- `docs/roadmap.md` per priorita e task sequenziali.

## Design E UI

La dark mode e canonica. I token sono derivati da `stitch_satowiki_pages/satowiki_design_narrative/DESIGN.md`.

Regole pratiche:

- Material 3 custom, estetica editoriale tecnica, non crypto/neon.
- Inter per display/body; JetBrains Mono per label tecniche, BIP, read time, status.
- Card senza ombre pesanti: usare tonal surface e bordo sottile.
- Touch target minimo 44dp.
- Bottom nav: Wiki, News, History, Code.
- Testi e colori devono venire dal tema quando possibile.
- Evitare hex locali nei componenti; aggiungere token in `AppColors` quando serve.

## Coding Rules

- Mantenere `flutter analyze` pulito.
- Preferire widget piccoli e leggibili.
- Usare `const` dove possibile.
- Non mettere parsing dati o accesso storage dentro widget presentation.
- Introdurre layer `domain` e `data` quando una feature supera il mock statico.
- Usare enum per stati noti come reading level e BIP status.
- Aggiornare docs quando si cambiano architettura, data model o design system.

## File Sensibili E Artefatti

- Non committare `.codex/`: puo contenere configurazioni locali e chiavi MCP.
- Non committare `.DS_Store`, `.dart_tool/`, `build/`, `.idea/`.
- `pubspec.lock` va mantenuto: questa repo e una app.
- `stitch_satowiki_pages/` e una fonte progettuale utile: non eliminarla senza richiesta esplicita.

## Verifica Minima Prima Di Chiudere

Per modifiche Dart/Flutter:

```bash
/Users/davide/development/flutter/bin/dart format lib test
/Users/davide/development/flutter/bin/flutter analyze
/Users/davide/development/flutter/bin/flutter test
```

Se non puoi eseguire un comando, segnalo chiaramente nel riepilogo finale.
