# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**SatoWiki** is a Flutter application serving as "The Orange Book of Bitcoin" — an open-source encyclopedia, news archive, historical timeline, and technical tracking system for the Bitcoin ecosystem. It's a bilingual app (English/Italian) designed for iOS and Android with offline-first architecture and Material 3 theming.

The project is documented comprehensively in `docs/`. Refer to `docs/app-architecture.md` for system design, `docs/content-model.md` for data contracts, and `docs/development-guidelines.md` for coding standards.

## Development Workflow

### Environment Setup

Flutter is installed locally at `/Users/davide/development/flutter/`. All flutter and dart commands use the full paths shown below.

**Initial setup:**
```bash
/Users/davide/development/flutter/bin/flutter pub get
```

**Run the app (default to iOS simulator):**
```bash
/Users/davide/development/flutter/bin/flutter run
```

### Code Quality

**Format Dart code:**
```bash
/Users/davide/development/flutter/bin/dart format lib test tool
```

**Lint analysis (must be clean):**
```bash
/Users/davide/development/flutter/bin/flutter analyze
```

**Run tests:**
```bash
/Users/davide/development/flutter/bin/flutter test
```

**Lint configuration:** `analysis_options.yaml` defines the lint set and must stay clean. Use `flutter_lints` as the baseline.

## Content Pipeline

SatoWiki keeps content in this repository: Markdown/YAML sources in `content/` (wiki and history, per language, plus templates in `content/templates/`), JSON seed bundles and media in `assets/content/`. The build system generates versioned static JSON bundles published to GitHub Pages.

### Content Validation

Validate content bundles for schema correctness:
```bash
/Users/davide/development/flutter/bin/dart run tool/validate_content.dart assets/content/seed_bundle_en.json
/Users/davide/development/flutter/bin/dart run tool/validate_content.dart assets/content/seed_bundle_it.json
```

The validator reports as **errors**: malformed or unsupported bundles, media referenced from the bundle that is not a relative `media/` path with a supported extension, has no alt text, or does not exist under `assets/content/`, `related` ids that match no record, and BIP status tags that are duplicated or contradict `status`. As **warnings**: records with `automation.needsReview: true` and texts that still contain generated placeholders. `--strict` turns warnings into errors. It does not check paths inside `content/*.md`.

### Content Generation

Generate static bundles for publication (adds UTC version stamp):
```bash
/Users/davide/development/flutter/bin/dart run tool/generate_bundle.dart --stamp
/Users/davide/development/flutter/bin/dart run tool/generate_bundle.dart --stamp assets/content/seed_bundle_it.json build/pages
```

Output published to `build/pages/content/{language}/{version}/bundle.json` (bundle, with `media/` next to it) and `build/pages/content/{language}/latest/manifest.json` (metadata). Also generates `build/pages/index.html` (index page). Each Pages deploy replaces the whole site, so only the latest version of each language is reachable.

### Automated Code Sync

`tool/sync_code_content.dart` rewrites the `bips` and `changelogs` arrays of both seed bundles from `bitcoin/bips` and Bitcoin Core release notes. It asks Gemini for drafts only for new records and for AI-managed records whose upstream changed, then opens a draft PR on the fixed branch `automation/code-content-sync`. Runs weekly (Sundays, 03:17 UTC) via `.github/workflows/sync-code-content.yml`, or manually. Needs the `GEMINI_API_KEY` secret. Review the PR before merging. Preservation rules are in `docs/content-model.md`.

### Seed Rebuild From Markdown (do not run yet)

`tool/build_seed_bundle.dart <lang>` rebuilds the `wiki` and `history` arrays of `assets/content/seed_bundle_<lang>.json` from `content/<lang>/`. It is not run in CI, and the seeds contain hand edits that are not in the Markdown sources (history summaries and wiki source lists). Running it today would revert them. Until the two are reconciled, treat the seed bundles as the source of truth for wiki and history.

### Content Templates

Templates live in `content/templates/`:
- `wiki_entry.md` — encyclopedia entries with base/medium/advanced sections
- `bip.md` — Bitcoin Improvement Proposals
- `release_note.md` — changelog/release notes
- `news_article.md` — editorial analysis and community perspectives
- `history_event.md` — historical timeline events

Each template defines required frontmatter (YAML) and structure. See `docs/content-model.md` for full data contract and `docs/contributing-content.md` for the contributor workflow.

## Architecture and Code Structure

### Repository Layout

```
lib/
  main.dart
  l10n/                             # ARB files (en, it)
  src/
    app.dart                        # SatoWikiApp root (light and dark themes, AppSettingsScope)
    core/
      content/                      # bundle loading and updates
        application/                # AppContentController
        data/                       # parser, migrator, repository, media store
        domain/                     # models, ContentStore, media rules
      localization/                 # AppLocale, localized labels, content labels
      navigation/                   # AppRouter, AppRoutes, SatoWikiTab, content_routes
      search/                       # in-memory SearchIndex
      settings/                     # AppSettingsController, repository, AppSettingsScope, ThemePreference
      theme/                        # AppTheme, AppColors, AppTokens (spacing, radii, fonts), SatoColors
      widgets/                      # reusable UI (ScreenHeader, DetailScaffold, SatoTabBar, ContentCard, StatusPill, ...)
    features/
      shell/presentation/           # tab shell and SatoTabBar host
      today/presentation/           # Today (home) tab
      wiki/                         # domain/repositories, presentation
      news/                         # domain/repositories, presentation
      history/                      # domain/repositories, presentation
      code/                         # domain/repositories, presentation (BIPs and releases)
      search/presentation/          # search screen
      settings/presentation/        # Settings and Bookmarks
```

Feature `domain/` holds repository interfaces; the data layer for content lives in `core/content/data/`. Feature `presentation/` holds screens and widgets.

### Key Systems

**Navigation:** Routes are defined in `lib/src/core/navigation/app_routes.dart`. Tab routes come from the `SatoWikiTab` enum (`/today`, `/wiki`, `/news`, `/history`, `/code`) and are drawn by `SatoTabBar` in the shell. Detail, search, settings, bookmarks and the full release list are named routes resolved in `app_router.dart` and opened with `pushNamed`. Content ids map to routes in `content_routes.dart`. Tab screens start with `ScreenHeader`; pushed screens use `DetailScaffold`. No screen uses an AppBar.

**State & Persistence:**
- `AppSettingsController` — user preferences and reading state (last tab, reading level, locale, theme, reader text scale, bookmarks, reading progress, recent searches) via `shared_preferences`, keys under `settings.*`. `AppSettingsScope` makes it available to the widget tree; `AppSettingsScope.maybeOf` returns null when no scope is present (for example in tests).
- `AppContentController` — bundle loading and content updates
- Updated bundles are stored as JSON in `shared_preferences`, one key per language; media files are kept in the application support directory; search index generated in-memory at startup

**Offline-First:**
1. App ships with seed bundles (`assets/content/seed_bundle_en.json`, `seed_bundle_it.json`)
2. At startup, reads local bundle (or seed if none exists)
3. If online, checks remote manifest (`content/{language}/latest/manifest.json`) and downloads updates in background
4. Bundles are verified by SHA256 and validated against schema before install
5. UI always serves local bundle first; never blocks on network

**Localization:** Languages resolved via `AppLocale.resolveLanguageCode()` using app preference + system locales. Supported seeds: `en`, `it`. Fallback is English.

**Search:** `SearchIndex` covers wiki, news, history, BIPs and release notes. Body text is not indexed.

### Styling & Theme

- Material 3 via `AppTheme.light()` and `AppTheme.dark()` (`lib/src/core/theme/app_theme.dart`); the user picks system, light or dark in Settings (default dark)
- Dark is the reference theme; design rules in `docs/design-system.md`
- Colors: read from `Theme.of(context).colorScheme` and `context.sato` (`SatoColors`); no hex literals or `Colors.*` in widgets (except `Colors.transparent`). The raw palette lives in `AppColors`
- Tokens: `AppSpacing`, `AppRadii` and `AppFonts` in `lib/src/core/theme/app_tokens.dart`
- Font assets bundled locally in `assets/fonts/`: Space Grotesk (titles), Inter (body), JetBrains Mono (data and uppercase labels only)
- Icons: Material Symbols via `Icons.*` until a dedicated icon set is introduced

### Content Models

Common entities:
- `SourceReference`, `RelatedContentLink`, `Contributor`, `ReadingLevelContent` — metadata
- Record ids are plain strings: `wiki.slug`, `news.slug`, `history.slug`, `code.bip.341`, `release.project.version`
- Feature models: `WikiEntry`, `NewsArticle`, `HistoryEvent`, `Bip`, `ReleaseNote`

Full schema in `docs/content-model.md`.

## Development Guidelines

**Core principles:**
- Prefer readable, localized code over premature abstraction
- Offline-first: no central UI should block on a runtime call for already-downloaded content
- Privacy by default: no invasive analytics, no unnecessary third-party calls
- Keep `flutter analyze` clean; this is non-negotiable

**Dart Style:**
- Files and directories: `snake_case`
- Classes and widgets: `PascalCase`
- Use `const` where possible
- Centralize repeated strings (routes, status, categories) in enums or constants when shared
- Extract widgets only if they improve readability, testability, or true reuse

**Widget Structure:**
- Reusable widgets in `lib/src/core/widgets/`
- Feature-specific widgets co-located with their screen if small and not shared
- Read theme colors and text styles from the theme, never use local hex
- Touch targets: minimum 44dp
- Text must wrap; truncate only secondary metadata in dense lists

**Accessibility:**
- Icon-only buttons always have a tooltip
- Status never conveyed by color alone — add badge text, dot, or label
- Text must scale with system settings
- Logical read order: title, metadata, content, related, sources

## Testing

**Test organization:**
- Widget tests for shell, tabs, reading level selector
- Unit tests for bundle parsing, search, filters, content validation and sync logic
- Golden tests for cards, chips, status badges, reader header, timeline items
- Integration tests for vertical slices (e.g., Wiki offline flow): not implemented yet, there is no `integration_test/` directory

Test files in `test/`: `app_settings_controller_test.dart`, `code_screens_test.dart`, `content_bundle_parser_test.dart`, `content_media_test.dart`, `content_seed_media_assets_test.dart`, `content_update_test.dart`, `content_version_test.dart`, `core_new_widgets_test.dart`, `core_widgets_golden_test.dart`, `generate_bundle_test.dart`, `markdown_text_test.dart`, `reader_screens_test.dart`, `search_and_store_test.dart`, `search_screen_test.dart`, `settings_screen_test.dart`, `shell_navigation_test.dart`, `sync_code_content_test.dart`, `today_screen_test.dart`, `validate_content_test.dart`, `widget_test.dart`. Golden images are in `test/goldens/`.

All tests use the standard Flutter test harness. See `test/` for examples.

## Key Dependencies

Core dependencies (see `pubspec.yaml` for versions):
- `flutter_localizations` — i18n support
- `crypto` — SHA256 for bundle verification
- `flutter_markdown_plus`, `markdown` — Markdown parsing and rendering
- `flutter_svg` — SVG rendering
- `shared_preferences` — local storage for settings and bundles
- `path_provider` — platform-specific paths
- `url_launcher` — opening external links
- `intl` — internationalization utilities

Dev: `flutter_lints` (required; keep clean), `flutter_launcher_icons` (app icon generation), standard Flutter test SDK.

## Common Tasks

### To add a new wiki entry
1. Use template `content/templates/wiki_entry.md`
2. Fill frontmatter: `id` (format: `wiki.slug`), `category`, `difficulty`, `readTimeMinutes`
3. Write three sections: `## base`, `## medium`, `## advanced` — each standalone
4. Place any images in `assets/content/media/wiki/{slug}/` using relative paths
5. Add to the appropriate seed bundle (`seed_bundle_en.json` or `_it.json`) by hand. Do not rely on `tool/build_seed_bundle.dart`: it would overwrite hand edits (see Seed Rebuild above)
6. Validate: `dart run tool/validate_content.dart assets/content/seed_bundle_en.json`
7. Generate output: `dart run tool/generate_bundle.dart --stamp`

### To update content model
1. Modify data contract in `docs/content-model.md`
2. Update model files in relevant feature directories
3. Update any parsing/validation logic
4. Run validation and tests
5. Include both model changes and updated `docs/content-model.md` in the PR

### To run a single test
```bash
/Users/davide/development/flutter/bin/flutter test test/path/to/test_file.dart
```

### To debug app
Run with verbose logging:
```bash
/Users/davide/development/flutter/bin/flutter run -v
```

## Git & CI

- Code and editorial content are tracked in the same repo but logically separate
- App code changes and content bundle changes should be grouped by feature (e.g., "Add wiki category system")
- Data model changes require updates to `docs/content-model.md`
- Every new content model must tolerate missing or extra fields (backward/forward compatibility)
- Code sync PRs are opened as drafts on `automation/code-content-sync` and must be reviewed before merge

## References

- `docs/app-architecture.md` — routing, state management, offline-first, search architecture
- `docs/content-model.md` — all data contracts and field definitions
- `docs/development-guidelines.md` — Dart style, widget structure, accessibility, testing
- `docs/design-system.md` — Material 3 tokens, components, theming rules
- `docs/image-generation-guidelines.md` — media asset style and guidelines
- `docs/contributing-content.md` — content contributor workflow
- `AGENTS.md` — quick guide for AI agents working on the repository
