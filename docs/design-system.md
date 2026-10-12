# SatoWiki Design System

Questo documento traduce `SatoWiki_DesignBrief.md` in regole applicabili in Flutter.

## Direzione

SatoWiki deve sembrare una rivista tecnica editoriale, non una crypto app speculativa. La UI e dark-first, autorevole, compatta ma leggibile, con accento Bitcoin usato per priorita, stati attivi e link importanti.

I token sono stati derivati in origine da esportazioni Stitch (design narrative e schermate di wiki, news, history e Code). Quelle esportazioni non sono piu nel repository. La fonte di verita oggi sono questo documento e il codice in `lib/src/core/theme/`: se un valore qui e nel codice non coincidono, si aggiornano entrambi.

## Colori

La dark mode e il riferimento canonico.

| Token | Dark | Light warm |
|---|---:|---:|
| Primary | `#ffb874` | `#f7931a` |
| Primary container | `#f7931a` | `#ffdcbf` |
| Surface | `#131313` | `#fffbff` |
| Surface container lowest | `#0e0e0e` | `#ffffff` |
| Surface container low | `#1c1b1b` | `#faf1ec` |
| Surface container | `#201f1f` | `#f4ebe6` |
| Surface container high | `#2a2a2a` | `#eee6e0` |
| Surface container highest | `#353534` | `#e8e0db` |
| On surface | `#e5e2e1` | `#201a18` |
| On surface variant | `#dbc2ae` | `#52443d` |
| Outline | `#a38d7b` | `#85736b` |
| Outline variant | `#554335` | `#d7c2b9` |

Status colors:

- Deployed / Complete (alias legacy Active / Final): green (`AppColors.success`)
- Draft (alias legacy Proposed): orange/amber (`AppColors.warning`)
- Closed (alias legacy Withdrawn / Rejected): red (`AppColors.error`)

## Tipografia

Target:

- Inter per display, headline, title e body.
- JetBrains Mono per label tecniche, BIP number, metadata, read time, code snippets.

Scala:

- Display: 57/64, weight 700
- Headline: 32/40, weight 600
- Mobile headline: 28/36, weight 600
- Title: 22/28, weight 500
- Body large: 18/28
- Body medium: 16/24
- Label mono: 14/20, weight 500
- Code mono: 13/18

Nota implementativa: `Inter` (variabile, `assets/fonts/inter/InterVariable.ttf`) e `JetBrains Mono` (`assets/fonts/jetbrains_mono/`, pesi 400 e 500) sono dichiarati come asset locali in `pubspec.yaml`, quindi non dipendono dai font di sistema. Le licenze sono in `assets/fonts/NOTICE.md`.

## Spacing e shape

- Baseline spacing: 8dp.
- Margine mobile: 16dp.
- Gutter: 24dp.
- Content max width per reader/tablet: 800dp.
- App bar: 64dp.
- Bottom navigation: include safe area e padding inferiore generoso.

Radius:

- Small: 2dp.
- Controls: 4dp.
- Cards and media: 8dp.
- Bottom nav top corners: 12dp.
- Pills/chips: fully rounded quando il componente e semanticamente un filtro o uno status.

## Componenti

App scaffold:

- Top app bar 64dp, `surface`, bordo inferiore `outlineVariant`, titolo centrato in primary.
- Icon button menu/search con target minimo 44dp.
- Bottom nav a 4 tab: Wiki, News, History, Code.
- Tab attivo: primary container, testo/icon on-primary-container, icona filled.

Cards:

- Tonal elevation, nessuna ombra pesante.
- Bordo 1dp outline variant.
- Padding 16/20/24 in base alla densita.
- Hover/pressed: surface container high.

Chips:

- Filter chip: mono 14px, pill, padding orizzontale 16dp.
- Tag content: `#Mining`, `#Consensus`, ecc. con testo primary e surface variant.
- BIP/status badge: mono, uppercase, dot colorato dove utile.

Reader:

- Titolo grande, metadati mono, tag sopra/sotto il titolo.
- Hero media con radius 8dp e bordo leggero.
- Callout con bordo sinistro primary.
- Related links e Sources/References in fondo.

Reading level selector:

- Tre opzioni: Base, Medio, Avanzato.
- Selettore compatto sotto il titolo.
- Stato attivo in primary container.
- La preferenza utente deve essere persistita.

Implementazione Flutter:

- `SatoScaffold`: app bar, bottom navigation e shell tab.
- `ContentCard`: card tonale con bordo sottile e padding configurabile.
- `FilterChipBar`: filtri orizzontali compatti.
- `MetadataRow`: tag, read time, autore e metadati mono.
- `ReadingLevelSelector`: selettore Base / Medio / Avanzato.
- `StatusBadge`: stati BIP e release con label e dot, non solo colore.
- `ReaderHeader`, `HeroMedia`, `SourcesDisclosure`, `RelatedLinksGrid`: blocchi reader riusabili.
- Golden test componenti critici: `test/core_widgets_golden_test.dart`.

## Regole di qualita UI

- Dark e light vanno disegnate insieme, non invertite automaticamente.
- Evitare nero puro, gradienti crypto/neon e arancione usato ovunque.
- Ogni schermata deve avere una sola azione primaria evidente.
- Testare ogni schermata con text scale aumentato e screen reader.
- Niente card annidate salvo casi di dati tecnici dove la gerarchia e chiara.
