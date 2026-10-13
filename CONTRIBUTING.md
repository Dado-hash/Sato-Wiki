# Contributing to SatoWiki

Thank you for wanting to help. SatoWiki is two things in one repository: a Flutter app and the Bitcoin content it displays. You can contribute to either one.

## Ways to contribute

| I want to... | Start here |
| --- | --- |
| Report a factual error or a broken source | Open a [content correction issue](https://github.com/Dado-hash/Sato-Wiki/issues/new?template=content_correction.yml) |
| Report a bug in the app | Open a [bug report](https://github.com/Dado-hash/Sato-Wiki/issues/new?template=bug_report.yml) |
| Suggest a feature or a new topic | Open a [feature request](https://github.com/Dado-hash/Sato-Wiki/issues/new?template=feature_request.yml) |
| Write or fix content | Read [Content changes](#content-changes) below |
| Change the app | Read [Code changes](#code-changes) below |

For anything larger than a small fix, please open an issue first so we can agree on the approach before you spend time on it.

## Setup

You need Flutter 3.32 or later (Dart 3.8).

```bash
git clone https://github.com/Dado-hash/Sato-Wiki.git
cd Sato-Wiki
flutter pub get
flutter run
```

No API keys or signing configuration are required.

## Branches and pull requests

- Branch from `develop` and open your pull request against `develop`. `main` is the released branch: a push to `main` publishes the content bundle to GitHub Pages.
- Keep each pull request to one topic.
- Write commit messages in the imperative mood: "Add wiki entry on timelocks", "Fix search crash on empty query".
- CI must pass. It checks formatting, analysis, content validation and tests.

Run the same checks locally before you push:

```bash
dart format lib test tool
flutter analyze
flutter test
dart run tool/validate_content.dart assets/content/seed_bundle_en.json
dart run tool/validate_content.dart assets/content/seed_bundle_it.json
```

## Content changes

The full workflow is in [docs/contributing-content.md](docs/contributing-content.md), and the field reference is in [docs/content-model.md](docs/content-model.md). The essentials:

- **Every record exists in English and Italian.** English is the source language. If you can only write one of the two, say so in the pull request and someone will help with the other.
- **The seed bundles are the source of truth.** Edit `assets/content/seed_bundle_en.json` and `assets/content/seed_bundle_it.json`. For wiki and history, also update the Markdown source under `content/`.
- **Do not run `tool/build_seed_bundle.dart`.** It would overwrite hand edits that exist only in the seed bundles.
- **Start from a template** in `content/templates/`.
- **Wiki entries have three levels**: `base`, `medium` and `advanced`. Each one must make sense on its own.
- **Cite sources.** Prefer primary ones: the BIP itself, the mailing list post, the release notes, the paper.
- **Stay neutral and factual.** No price predictions, no investment advice, no promotion of products or services.
- **History is append-only.** Existing events are changed only to fix a verifiable factual error.
- **Images** go under `assets/content/media/`, are referenced with a relative `media/...` path, and always have alt text. See [docs/image-generation-guidelines.md](docs/image-generation-guidelines.md).

### Generated drafts

BIP and release records are drafted by a weekly job and then reviewed by a person. A record that still has `automation.needsReview: true` has not been reviewed yet. Reviewing one of those, checking it against the upstream source and correcting it, is one of the most useful contributions you can make.

## Code changes

Read [docs/development-guidelines.md](docs/development-guidelines.md) and [docs/app-architecture.md](docs/app-architecture.md) first. The rules that matter most:

- `flutter analyze` must stay clean.
- **Offline first.** No screen may wait on the network to show content that is already on the device.
- **Privacy by default.** No analytics and no new third-party network calls.
- **Colors and text styles come from the theme.** No hex literals or `Colors.*` in widgets. See [docs/design-system.md](docs/design-system.md).
- **Accessibility.** Icon-only buttons need a tooltip, touch targets are at least 44dp, and status is never shown by color alone.
- **Localization.** Every user-facing string goes in both `lib/l10n/app_en.arb` and `lib/l10n/app_it.arb`.
- **Tests.** Add or update tests for the behavior you change.
- **Data model changes** must tolerate missing and unknown fields, and must update `docs/content-model.md` in the same pull request.

If your change is visible in the UI, regenerate the README screenshots:

```bash
flutter test tool/readme_screenshots_test.dart
```

## Licensing of contributions

By contributing you agree that your code is released under the [MIT License](LICENSE) and your content and documentation under [CC BY-SA 4.0](LICENSE-CONTENT). Only submit text and images that you wrote yourself or that are compatible with those licenses, and credit the source.
