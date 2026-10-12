# Release Readiness

Stato verificato sul repository il 2026-10-12. Le voci sotto dicono cosa e verificato e cosa resta da fare a mano.

## Accessibility

- Core navigation has labels/tooltips.
- Status uses text plus color.
- Reader order: title, metadata, body, related, sources.
- Remaining manual pass: screen reader on physical iOS/Android. Non ancora eseguito.

## Performance

- Seed bundle is local asset.
- Search index is in-memory over local bundle.
- No runtime network dependency for first content paint.
- Remaining manual pass: low-end Android scroll/profile. Non ancora eseguito.

## Install And Bundle Update

- App loads updated bundle from local storage first.
- Bad updated bundle falls back to seed asset.
- Updated bundle storage is keyed by language.
- Background updates fetch the language manifest from GitHub Pages, verify
  sha256, validate schema and install atomically.
- Tests cover malformed JSON, future schema, bad hash, missing manifest, wrong
  language and fallback cases (`test/content_update_test.dart`,
  `test/content_bundle_parser_test.dart`).

## Splash And Icons

- Branded dark/editorial orange launcher icons and splash images replace the
  Flutter scaffold defaults on Android and iOS.

## Beta

- TestFlight and Play Internal need signing, store metadata and privacy links.
- Use `docs/privacy-policy.md` as privacy baseline.

## Open before release

- Android: la build di release e firmata con la chiave di debug (`android/app/build.gradle.kts`), e `applicationId` e ancora `org.satowiki.sato_wiki` con il TODO del template. Il bundle id iOS e `org.satowiki.satoWiki`: l'id definitivo va scelto e allineato prima della prima pubblicazione.
- iOS: `IPHONEOS_DEPLOYMENT_TARGET` e `12.0` (`ios/Runner.xcodeproj/project.pbxproj`). Va alzato al valore del template Flutter corrente.
- Toolchain: Flutter 3.32.6 (Dart 3.8.1), fissato in `.github/workflows/`. La revisione risale all'8 luglio 2025. L'aggiornamento va fatto in un cambio separato.
- Test: il golden test `core_editorial_components` fallisce. La differenza di rendering e di pochi pixel, ma non e ancora stato escluso che sia una regressione.
- Test: non ci sono test di integrazione (`integration_test/` non esiste).
