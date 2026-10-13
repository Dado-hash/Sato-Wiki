# Development Guidelines

## Principi

- Preferire codice leggibile e locale alla feature invece di astrazioni premature.
- Ogni feature deve avere presentation, domain e data quando il comportamento supera il mock statico.
- Le schermate devono rimanere offline-first: nessuna UI centrale deve dipendere da una chiamata runtime per mostrare contenuti gia scaricati.
- Privacy by default: niente analytics invasivi, niente chiamate terze parti non necessarie, font e asset preferibilmente bundled.

## Stile Dart e Flutter

- Usare `flutter_lints` come base e mantenere `flutter analyze` pulito.
- File e cartelle in `snake_case`.
- Classi widget e modelli in `PascalCase`.
- Preferire `const` dove possibile.
- Evitare logiche dati dentro i widget: i widget compongono stato e UI, non parsano bundle o file.
- Usare enum per stati noti: reading level, BIP status, content category.
- Non usare stringhe raw ripetute per route, status e categorie: centralizzarle quando iniziano a essere condivise.

## Struttura widget

- Widget pubblici riusabili in `lib/src/core/widgets`.
- Widget privati di schermata nello stesso file se sono piccoli e non condivisi.
- Estrarre un widget solo quando migliora leggibilita, testabilita o riuso reale.
- I componenti visuali devono leggere colori e testo dal tema, non da hex locali:
  - colori da `Theme.of(context).colorScheme` e da `context.sato` (`SatoColors`);
  - testo da `Theme.of(context).textTheme`, con i ruoli di `docs/design-system.md`;
  - spaziature e raggi da `AppSpacing` e `AppRadii` in `lib/src/core/theme/app_tokens.dart`.
- Nei widget non si scrivono hex e `Colors.*`. Fanno eccezione `Colors.transparent` e i valori in `lib/src/core/theme/`.
- Scaffolding delle schermate:
  - schermate a tab: nessuno `Scaffold` proprio; iniziano con `ScreenHeader` e chiudono con padding inferiore `AppSpacing.tabBarClearance`;
  - schermate push: `DetailScaffold`, con pulsante indietro e titolo opzionale;
  - nessun `AppBar`.
## Frontend

- Seguire il design system in `docs/design-system.md`.
- Usare Material Symbols equivalenti tramite `Icons.*` finche non viene introdotto un icon set dedicato.
- Ogni touch target deve essere almeno 44dp (`RoundIconButton` e i bottoni del tema rispettano il minimo).
- I testi devono poter andare a capo; truncation solo su metadata secondari e liste dense.
- Usare skeleton o contenuti cached per loading oltre 300ms.
- Ogni stato vuoto deve spiegare cosa manca e quale azione e possibile.

## Accessibilita

- Icon-only button sempre con `tooltip`.
- Reader compatibile con text scaling.
- Colore mai come unico significato: status badge con testo, dot o label.
- Ordine di lettura logico: titolo, metadata, contenuto, related, sources.
- Preparare widget test per navigazione base e golden test per i componenti piu importanti.

## Testing

Livelli minimi:

- Widget test per shell, tab principali, reading level selector.
- Unit test per parsing content bundle, ricerca e filtri.
- Golden test per card, chip, status badge, reader header e timeline item.
- Integration test per vertical slice Wiki offline.

Comandi:

```bash
flutter analyze
flutter test
```

## Git e contenuti

- Il codice app e i contenuti editoriali devono restare separati.
- I contenuti stanno in questa repository (`content/` e `assets/content/`) e la pipeline ne produce JSON statici versionati (vedi `docs/contributing-content.md`).
- Ogni modello app deve tollerare campi opzionali e bundle content piu vecchi.
- Le modifiche ai contratti dati richiedono aggiornamento di `docs/content-model.md`.
