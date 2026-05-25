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
- Validator covers malformed and future schema cases.

## Splash And Icons

- Current platform icons/splash exist from Flutter scaffold.
- Definitive branded artwork must replace scaffold assets before store beta.

## Beta

- TestFlight and Play Internal need signing, store metadata and privacy links.
- Use `docs/privacy-policy.md` as privacy baseline.
