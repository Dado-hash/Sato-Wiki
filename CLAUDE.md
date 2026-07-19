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

SatoWiki separates content (Markdown/YAML) from app code. The build system generates versioned static JSON bundles published to GitHub Pages.

### Content Validation

Validate content bundles for schema correctness:
```bash
/Users/davide/development/flutter/bin/dart run tool/validate_content.dart assets/content/seed_bundle_en.json
/Users/davide/development/flutter/bin/dart run tool/validate_content.dart assets/content/seed_bundle_it.json
```

### Content Generation

Generate static bundles for publication (adds UTC version stamp):
```bash
/Users/davide/development/flutter/bin/dart run tool/generate_bundle.dart --stamp
/Users/davide/development/flutter/bin/dart run tool/generate_bundle.dart --stamp assets/content/seed_bundle_it.json build/pages
```

Output published to `build/pages/content/{language}/{version}/bundle.json` (bundle) and `build/pages/content/{language}/latest/manifest.json` (metadata). Also generates `build/pages/index.html` (index page).

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
lib/src/
  app.dart                          # SatoWikiApp root
  core/
    navigation/                     # routing (AppRouter, routes)
    settings/                       # preferences (AppSettingsController)
    content/                        # bundle loading, offline-first (AppContentController)
    search/                         # search index and UI
    theme/                          # Material 3 theming (AppTheme, AppColors)
    widgets/                        # reusable UI (FilterChipBar, StatusBadge, ContentCard)
  features/
    shell/                          # tab shell and navigation
    wiki/                           # encyclopedia entries
    news/                           # news articles
    history/                        # timeline events
    code/                           # BIPs and releases
```

Each feature follows the pattern: `data/` (models, repository), `domain/` (business logic), `presentation/` (screens, widgets).

### Key Systems

**Navigation:** Routes are defined in `lib/src/core/navigation/app_routes.dart`. Tab names and routes are centralized via `SatoWikiTab` enum. Deep links are routed through a nominate router.

**State & Persistence:** 
- `AppSettingsController` — UI preferences (last tab, reading level, locale) via `shared_preferences`
- `AppContentController` — bundle loading and content updates
- Content stored as JSON in preferences; search index generated in-memory at startup

**Offline-First:**
1. App ships with seed bundles (`assets/content/seed_bundle_en.json`, `seed_bundle_it.json`)
2. At startup, reads local bundle (or seed if none exists)
3. If online, checks remote manifest and downloads updates in background
4. Updates verified by SHA256 and validated against schema
5. UI always serves local bundle first; never blocks on network

**Localization:** Languages resolved via `AppLocale.resolveLanguageCode()` using app preference + system locales. Supported seeds: `en`, `it`. Fallback is English.

### Styling & Theme

- Material 3 via `AppTheme` (`lib/src/core/theme/app_theme.dart`)
- Dark-first design aligned to Stitch design system
- Custom colors in `AppColors` — always read from theme, not hex literals
- Font assets: Inter (UI) and JetBrains Mono (code) bundled locally
- Icons: Material Symbols via `Icons.*` until a dedicated icon set is introduced

### Content Models

Common entities:
- `ContentId` — stable identifier (e.g., `wiki.slug`, `news.slug`, `history.slug`, `code.bip.341`)
- `LocalizedText` — translatable strings
- `Tag`, `SourceReference`, `RelatedContentLink` — metadata
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
- Unit tests for bundle parsing, search, filters
- Golden tests for cards, chips, status badges, reader header, timeline items
- Integration tests for vertical slices (e.g., Wiki offline flow)

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
5. Add to the appropriate seed bundle (`seed_bundle_en.json` or `_it.json`)
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

## References

- `docs/app-architecture.md` — routing, state management, offline-first, search architecture
- `docs/content-model.md` — all data contracts and field definitions
- `docs/development-guidelines.md` — Dart style, widget structure, accessibility, testing
- `docs/design-system.md` — Material 3 tokens, components, theming rules
- `docs/image-generation-guidelines.md` — media asset style and guidelines
- `docs/contributing-content.md` — content contributor workflow
- `AGENTS.md` — AI agent system for content tasks
