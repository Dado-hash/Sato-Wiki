# Development Roadmap

La roadmap e organizzata per macro aree. Ogni area contiene task da completare in sequenza.

## 1. Foundation

1. [x] Confermare licenza codice e contenuti.
2. [x] Stabilizzare tema Flutter da `docs/design-system.md`.
3. [x] Aggiungere font Inter e JetBrains Mono come asset locali.
4. [x] Introdurre route names e deep link target.
5. [x] Persistire ultima tab visitata e reading level.
6. [x] Preparare CI base con `flutter analyze` e `flutter test`.

## 2. Design System e Componenti

1. [x] Estrarre `SatoScaffold` con top app bar e bottom nav.
2. [x] Creare `ContentCard`, `FilterChipBar`, `MetadataRow`.
3. [x] Creare `ReadingLevelSelector` definitivo.
4. [x] Creare `StatusBadge` per BIP e release.
5. [x] Creare `ReaderHeader`, `HeroMedia`, `SourcesDisclosure`.
6. [x] Creare `RelatedLinksGrid`.
7. [x] Aggiungere golden test per componenti critici.

## 3. Content Domain

1. [x] Definire modelli Dart per `WikiEntry`, `NewsArticle`, `HistoryEvent`, `Bip`, `ReleaseNote`.
2. [x] Definire repository interfaces per ogni sezione.
3. [x] Creare fixture JSON locali.
4. [x] Implementare parser e validazione bundle.
5. [x] Gestire versioning e migrazione bundle.
6. [x] Documentare errori recuperabili e fallback.

## 4. Offline e Search

1. [x] Caricare bundle seed da asset.
2. [x] Salvare bundle aggiornato in storage locale.
3. [x] Implementare manifest remoto.
4. [x] Scaricare update in background.
5. [x] Costruire indice search locale.
6. [x] Implementare ricerca per titolo, tag e summary.
7. [x] Aggiungere filtri per sezione.

## 5. Wiki Vertical Slice

1. [x] Ricostruire `Wiki Explore` da Stitch.
2. [x] Implementare lista categoria Protocol.
3. [x] Implementare detail `Proof of Work`.
4. [x] Collegare selector Base/Medio/Avanzato a contenuto reale.
5. [x] Aggiungere related concepts.
6. [x] Aggiungere sources disclosure.
7. [x] Testare offline, text scale e screen reader.

## 6. History Vertical Slice

1. [x] Implementare widget `On this day`.
2. [x] Implementare timeline mobile.
3. [x] Aggiungere filtri categoria.
4. [x] Implementare detail `Bitcoin Pizza Day`.
5. [x] Collegare evento a Wiki/News related.
6. [x] Aggiungere test per ordinamento e range date.

## 7. Code Vertical Slice

1. [x] Implementare dashboard BIP/changelog.
2. [x] Implementare lista BIP con filtri status/category.
3. [x] Implementare detail BIP 341.
4. [x] Aggiungere impact cards e status history.
5. [x] Implementare lista release per progetto.
6. [x] Implementare detail changelog leggibile.
7. [x] Preparare notifiche future su BIP seguiti.

## 8. News Vertical Slice

1. [x] Implementare feed con categorie.
2. [x] Implementare article reader.
3. [x] Supportare autore GitHub e metadata.
4. [x] Collegare inline link a Wiki/BIP.
5. [x] Implementare Lightning Tip modal mock.
6. [x] Collegare BTCPay/Lightning solo dopo definizione privacy e UX.

## 9. Content Pipeline

1. [x] Definire template Markdown/YAML per ogni contenuto.
2. [x] Creare validatore schema.
3. [x] Creare generatore JSON statico.
4. [x] Aggiungere check obbligatori in PR contenuti.
5. [x] Pubblicare bundle su CDN.
6. [x] Aggiornare docs contributor.

## 10. Release Readiness

1. Pass accessibilita completa.
2. Pass performance su device low-end.
3. [x] Test install/update bundle.
4. [x] Preparare splash e icone definitive.
5. [x] Preparare privacy policy.
6. Preparare beta TestFlight/Play Internal.
