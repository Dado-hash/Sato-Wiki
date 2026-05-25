# SatoWiki

The Orange Book of Bitcoin.

SatoWiki e un'app Flutter open source per enciclopedia, news, storia e tracking tecnico dell'ecosistema Bitcoin. Il prodotto e descritto in `docs/SatoWiki_PRD.md`; le schermate Stitch locali sono in `stitch_satowiki_pages/`.

## Setup

Questa repo e stata inizializzata come applicazione Flutter per iOS e Android.

```bash
/Users/davide/development/flutter/bin/flutter pub get
/Users/davide/development/flutter/bin/flutter run
```

## Qualita

```bash
/Users/davide/development/flutter/bin/flutter analyze
/Users/davide/development/flutter/bin/flutter test
```

## Documentazione

- `docs/design-system.md`: tema, token, componenti e regole UI derivate da Stitch.
- `docs/development-guidelines.md`: linee guida codice, frontend, accessibilita e test.
- `docs/app-architecture.md`: struttura Flutter, routing, stato, offline-first e search.
- `docs/content-model.md`: modelli dati target per bundle contenuti.
- `docs/licensing.md`: licenze per codice, contenuti e font bundled.
- `docs/roadmap.md`: roadmap per macro aree e task sequenziali.

## Stato attuale

La base contiene:

- shell mobile con tab Wiki, News, History e Code;
- tema Material 3 dark-first allineato ai token Stitch;
- font Inter e JetBrains Mono bundled come asset locali;
- route nominate per tab principali e deep link target;
- persistenza locale di ultima tab visitata e reading level;
- schermate starter per le quattro sezioni;
- test widget base della shell.

## Licenze

Il codice applicativo e distribuito sotto MIT. I contenuti editoriali e la
documentazione sono distribuiti sotto CC BY-SA 4.0 salvo diversa indicazione.
