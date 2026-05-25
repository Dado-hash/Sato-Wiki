# Release Readiness

## Accessibility

- Core navigation has labels/tooltips.
- Status uses text plus color.
- Reader order: title, metadata, body, related, sources.
- Remaining manual pass: screen reader on physical iOS/Android.

## Performance

- Seed bundle is local asset.
- Search index is in-memory over local bundle.
- No runtime network dependency for first content paint.
- Remaining manual pass: low-end Android scroll/profile.

## Install And Bundle Update

- App loads updated bundle from local storage first.
- Bad updated bundle falls back to seed asset.
- Updated bundle storage is keyed by language.
- Background updates fetch the language manifest from GitHub Pages, verify
  sha256, validate schema and install atomically.
- Validator and tests cover malformed JSON, future schema, bad hash, missing
  manifest, wrong language and fallback cases.

## Splash And Icons

- Branded dark/editorial orange launcher icons and splash images replace the
  Flutter scaffold defaults on Android and iOS.

## Beta

- TestFlight and Play Internal need signing, store metadata and privacy links.
- Use `docs/privacy-policy.md` as privacy baseline.
