# SatoWiki Design System

Questo documento traduce `SatoWiki_DesignBrief.md` in regole applicabili in Flutter.

## Direzione

SatoWiki deve sembrare una rivista tecnica editoriale, non una crypto app speculativa. La UI è dark-first, con fondo ardesia scuro, testo caldo e un solo accento arancione. Il tema chiaro è disponibile e si sceglie in Impostazioni. L'accento Bitcoin serve per priorità, stati attivi e link importanti.

I token derivano in origine da esportazioni Stitch (design narrative e schermate di wiki, news, history e Code). Quelle esportazioni non sono più nel repository. La fonte di verità oggi sono questo documento e il codice in `lib/src/core/theme/`: se un valore qui e nel codice non coincidono, si aggiornano entrambi.

## Colori

Il tema scuro è il riferimento. Il tema chiaro usa gli stessi ruoli con valori propri. I valori sono in `lib/src/core/theme/app_colors.dart` e `lib/src/core/theme/app_theme.dart`.

Ruoli di `ColorScheme`:

| Ruolo | Uso | Dark | Light |
|---|---|---:|---:|
| `surface` | sfondo schermata | `#0B0D10` | `#FAF7F2` |
| `surfaceContainerLow`, `surfaceContainer` | sfondo card | `#14171C` | `#FFFFFF` |
| `surfaceContainerHigh`, `surfaceContainerHighest` | tile dentro una card, track del segmented control, tab bar | `#1C2027` | `#F1ECE4` |
| `outlineVariant` | bordo card, divisori | `#262B33` | `#E4DDD2` |
| `onSurface` | testo principale | `#F2EDE4` | `#1A1613` |
| `onSurfaceVariant` | testo secondario e meta | `#A9A49B` | `#5F5850` |
| `primary` | accento come testo, link o icona | `#F7931A` | `#B35C00` |
| `primaryContainer` | accento come fondo: chip e segmento selezionati, bottone primario, progresso | `#F7931A` | `#F7931A` |
| `onPrimaryContainer` | testo o icona sul fondo accento | `#1A0E00` | `#1A0E00` |

Colori extra in `SatoColors`, letti con `context.sato` (`lib/src/core/theme/sato_colors.dart`):

| Token | Dark | Light | Uso |
|---|---:|---:|---|
| `accentTint` | `#2C2011` | `#FFF0DC` | tab attiva, tile icona |
| `statusDeployed` | `#4ADE80` | `#15803D` | stato Deployed |
| `statusComplete` | `#7DD3FC` | `#0369A1` | stato Complete |
| `statusDraft` | `#FBBF24` | `#A16207` | stato Draft |
| `statusClosed` | `#A9A49B` | `#5F5850` | stato Closed |
| `borderStrong` | `#2E343D` | `#D6CEC1` | bordo della tab bar |

Regole:

- Nei widget i colori si leggono da `Theme.of(context).colorScheme` e da `context.sato`. Niente hex locali.
- Lo stato non è mai indicato solo dal colore: `StatusPill`, `BipStatusPill` e `StatusBadge` mostrano sempre un testo.
- Il colore di ogni stato BIP viene da `bipStatusColor` (`status_pill.dart`).

## Tipografia

Font, definiti in `AppFonts` (`lib/src/core/theme/app_tokens.dart`):

- Space Grotesk (`AppFonts.display`) per titoli e numeri grandi.
- Inter (`AppFonts.body`) per testo corrente, label e font di base del tema.
- JetBrains Mono (`AppFonts.mono`) solo per dati (date, versioni, conteggi) e label maiuscole.

I tre font sono asset locali in `assets/fonts/` e sono dichiarati in `pubspec.yaml`, quindi non dipendono dai font di sistema. Space Grotesk è un file variabile.

Scala di `TextTheme` (`lib/src/core/theme/app_theme.dart`):

| Ruolo | Font, peso | Dimensione / linea | Uso |
|---|---|---:|---|
| `displayLarge` | Space Grotesk 700 | 44 / 48 | riserva, non usato nelle schermate |
| `displayMedium` | Space Grotesk 700 | 40 / 44 | riserva, non usato nelle schermate |
| `displaySmall` | Space Grotesk 700 | 36 / 40 | titolo della schermata Oggi |
| `headlineLarge` | Space Grotesk 700 | 32 / 36 | titolo di schermata a tab, titolo del reader |
| `headlineMedium` | Space Grotesk 700 | 28 / 33 | titolo di dettaglio (BIP, release, impostazioni) |
| `headlineSmall` | Space Grotesk 700 | 24 / 28 | card in evidenza, numeri grandi |
| `titleLarge` | Space Grotesk 600 | 17 / 22 | titolo di sezione, titolo di card |
| `titleMedium` | Space Grotesk 600 | 16 / 20 | titolo di tile piccola |
| `titleSmall` | Inter 500 | 15 / 20 | etichetta di riga |
| `bodyLarge` | Inter 400 | 17 / 28 | testo lungo da leggere |
| `bodyMedium` | Inter 400 | 15 / 22 | testo corrente |
| `bodySmall` | Inter 400 | 13 / 18, `onSurfaceVariant` | riga di meta |
| `labelLarge` | Inter 500 | 14 / 20 | chip, bottoni, link |
| `labelMedium` | JetBrains Mono 500 | 12 / 16, `onSurfaceVariant` | dati: date, versioni, conteggi |
| `labelSmall` | JetBrains Mono 700 | 11 / 14 | label maiuscola di categoria, pillola di stato |

I titoli grandi hanno un letter spacing negativo (da -0.3 su `headlineSmall` a -0.8 su `displaySmall`).

## Spaziature, raggi e forme

Token in `lib/src/core/theme/app_tokens.dart`:

- `AppSpacing`: `xs` 4, `sm` 8, `md` 12, `lg` 16, `gutter` 20, `xl` 24, `section` 28.
- `AppSpacing.gutter` (20) è il margine laterale delle schermate.
- `AppSpacing.section` (28) è la distanza tra i blocchi di una schermata.
- Le schermate a tab chiudono con padding inferiore `SatoScaffold.bottomClearanceOf(context)`, cioè l'altezza coperta dalla tab bar più `AppSpacing.tabBarGap` (24), così il contenuto resta sopra la tab bar. La tab bar fluttua `AppSpacing.tabBarLift` (12) sopra l'inset di sistema, con margine laterale `gutter`.
- `AppRadii`: `thumb` 12, `tile` 14, `card` 20, `media` 24, `pill` 999.
- `thumb` per le miniature, `tile` per le tile e le SnackBar, `card` per `ContentCard`, `media` per immagini principali, bottom sheet e dialog, `pill` per chip, tag, pillole di stato, segmented control e barra di progresso.
- La tab bar usa un raggio fisso di 28.

Forme e dimensioni da `AppTheme`:

- Card: raggio `card`, bordo di 1 px in `outlineVariant`, nessuna elevazione.
- Divisori: 1 px in `outlineVariant`.
- Bottone pieno: forma a stadio, fondo `primaryContainer`, altezza minima 52.
- Bottone di testo e icon button: dimensione minima 44 x 44.
- Chip: forma a stadio con bordo `outlineVariant`.
- Bottom sheet e dialog: raggio `media`.

Layout delle schermate:

- Schermate a tab (`ScreenHeader`): titolo in alto, padding superiore uguale al padding di sistema più 16, margine laterale `gutter`, padding inferiore `SatoScaffold.bottomClearanceOf(context)`.
- Schermate di dettaglio (`DetailScaffold`): riga con pulsante indietro di 44 px, barra di progresso opzionale sotto la riga, corpo con margine laterale `gutter` e padding inferiore 32 più il margine di sistema.
- Tab bar: flottante, con margine di 16 su tre lati e padding interno `sm`.

## Componenti

Navigazione e scaffold:

- `SatoScaffold`: `Scaffold` con corpo esteso sotto la tab bar. Nessuna AppBar.
- `SatoTabBar`: barra flottante a pillola con cinque tab (Oggi, Wiki, News, History, Code). Ogni tab mostra icona ed etichetta. La tab attiva usa `accentTint` con colore `primary`.
- Il corpo delle tab è un `IndexedStack`: cambiare tab conserva filtri e posizione di scroll.
- `ScreenHeader`: blocco superiore delle schermate a tab, con titolo, sottotitolo opzionale e azioni.
- La schermata Oggi usa una propria riga superiore (`_TopBar` in `today_screen.dart`) al posto di `ScreenHeader`.
- `DetailScaffold`: schermata push con pulsante indietro, titolo opzionale, azioni, barra di progresso opzionale e corpo scrollabile. Il padding inferiore del corpo è 32 più il margine di sistema.
- `RoundIconButton`: cerchio di 44 px su fondo card con bordo `outlineVariant`. Ogni pulsante con sola icona ha un `tooltip`.

Card e contenuti:

- `ContentCard`: card tappabile con padding di default 16 e raggio `card`. Accetta un `trailing` opzionale.
- `SatoGroupCard`: una card con righe separate da divisori di 1 px.
- `SectionTitle`: titolo di sezione.
- `ContentThumbnail`: copertina del contenuto con raggio `thumb`. Se il file manca, mostra un'icona su una tile.
- `MetaLine`: label maiuscola in accento, seguita dai metadati separati da punti medi, in `labelMedium`.
- `TagPill`: tag di sola lettura sotto i contenuti.
- `RelatedLinksGrid`: collegamenti correlati in due colonne.
- `SourcesDisclosure`: fonti in un blocco a scomparsa.
- `MetadataRow`: metadati come chip.

Filtri e selezione:

- `FilterChipBar`: filtri orizzontali a pillola.
- `SatoSegmentedControl`: track a pillola con segmenti uguali. Il segmento selezionato usa `primaryContainer`.
- `ReadingLevelSelector`: Base, Medio, Avanzato, costruito su `SatoSegmentedControl`. La scelta è salvata nelle impostazioni.

Stati:

- `StatusPill`: punto di 6 px e testo in `labelSmall`, su un fondo del colore di stato al 12% di opacità.
- `BipStatusPill`: `StatusPill` per lo stato di un BIP.
- `StatusBadge`: badge per lo stato di contenuti e release, con testo e punto. Il punto si può nascondere con `showDot`.

Lettura:

- `ReaderHeader`: titolo, metadati e tag in cima ai contenuti lunghi.
- `HeroMedia`: immagine principale con raggio `media`.
- `MarkdownText`: corpo in Markdown. Le citazioni hanno un bordo sinistro di 3 px in `primary`.
- `ContentImageFigure`: immagine nel corpo. Un tap apre l'anteprima a schermo intero.
- `SatoProgressBar`: barra di progresso sottile a pillola.
- `BookmarkButton`: `RoundIconButton` che salva o rimuove il segnalibro. Non appare se non c'è `AppSettingsScope` sopra.

Ricerca:

- I risultati sono raggruppati per sezione (`SearchSection`).
- La schermata mostra le ricerche recenti (massimo 6, con pulsante per cancellarle) e alcuni suggerimenti quando il campo è vuoto.

Aggiornamento contenuti:

- `UpdateProgressBanner`: banner in basso sopra la tab bar, non bloccante, con stato e avanzamento del download o dell'installazione. L'utente può chiuderlo; sparisce da solo a fine aggiornamento o dopo un errore.

## Regole di qualita UI

- Dark e light vanno disegnate insieme, non invertite automaticamente.
- Evitare nero puro, gradienti crypto/neon e arancione usato ovunque.
- Ogni schermata deve avere una sola azione primaria evidente.
- Testare ogni schermata con text scale aumentato e screen reader.
- Niente card annidate salvo casi di dati tecnici dove la gerarchia e chiara.
