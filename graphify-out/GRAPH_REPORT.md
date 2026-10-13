# Graph Report - .  (2026-10-12)

## Corpus Check
- Large corpus: 483 files · ~759,194 words. Semantic extraction will be expensive (many Claude tokens). Consider running on a subfolder.

## Summary
- 1931 nodes · 2370 edges · 87 communities (82 shown, 5 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- Community 0
- Community 1
- Community 2
- Community 3
- Community 4
- Community 5
- Community 6
- Community 7
- Community 8
- Community 9
- Community 10
- Community 11
- Community 12
- Community 13
- Community 14
- Community 15
- Community 16
- Community 17
- Community 18
- Community 19
- Community 20
- Community 21
- Community 22
- Community 23
- Community 24
- Community 25
- Community 26
- Community 27
- Community 28
- Community 29
- Community 30
- Community 31
- Community 32
- Community 33
- Community 34
- Community 35
- Community 36
- Community 37
- Community 38
- Community 39
- Community 40
- Community 41
- Community 42
- Community 43
- Community 44
- Community 45
- Community 46
- Community 47
- Community 48
- Community 49
- Community 50
- Community 51
- Community 52
- Community 53
- Community 54
- Community 55
- Community 56
- Community 57
- Community 58
- Community 59
- Community 60
- Community 61
- Community 62
- Community 63
- Community 64
- Community 65
- Community 66
- Community 67
- Community 68
- Community 69
- Community 70
- Community 71
- Community 72
- Community 73
- Community 74
- Community 75
- Community 76
- Community 77
- Community 78
- Community 79
- Community 80
- Community 81
- Community 82
- Community 86

## God Nodes (most connected - your core abstractions)
1. `ContentStore` - 12 edges
2. `ContentBundleRepository` - 8 edges
3. `iconImage()` - 8 edges
4. `ReadingLevel` - 7 edges
5. `AppLocalizations` - 7 edges
6. `drawCenteredText()` - 7 edges
7. `launchImage()` - 7 edges
8. `ContentBundleParseException` - 6 edges
9. `drawBookMark()` - 6 edges
10. `AppContentController` - 5 edges

## Surprising Connections (you probably didn't know these)
- `_TestContentBundleRepository` --implements--> `ContentBundleRepository`  [EXTRACTED]
  test/code_screens_test.dart → lib/src/core/content/data/content_bundle_repository.dart
- `_GatedContentRepository` --implements--> `ContentBundleRepository`  [EXTRACTED]
  test/content_update_test.dart → lib/src/core/content/data/content_bundle_repository.dart
- `_FixtureBundleRepository` --implements--> `ContentBundleRepository`  [EXTRACTED]
  test/reader_screens_test.dart → lib/src/core/content/data/content_bundle_repository.dart
- `_TestContentBundleRepository` --implements--> `ContentBundleRepository`  [EXTRACTED]
  test/widget_test.dart → lib/src/core/content/data/content_bundle_repository.dart
- `_CountingManifestRepository` --implements--> `RemoteContentManifestRepository`  [EXTRACTED]
  test/content_update_test.dart → lib/src/core/content/data/content_bundle_repository.dart

## Import Cycles
- None detected.

## Communities (87 total, 5 thin omitted)

### Community 0 - "Community 0"
Cohesion: 0.01
Nodes (146): app_localizations_en.dart, app_localizations_it.dart, activeUpper, all, allBipsSubtitle, allBipsTitle, allEvents, appTitle (+138 more)

### Community 1 - "Community 1"
Cohesion: 0.01
Nodes (143): HttpClient, a, apiKey, assignedAt, authors, automation, _automationMetadata, baseDelay (+135 more)

### Community 2 - "Community 2"
Cohesion: 0.01
Nodes (135): app_localizations.dart, activeUpper, all, allBipsSubtitle, allBipsTitle, allEvents, appTitle, articleNotFound (+127 more)

### Community 3 - "Community 3"
Cohesion: 0.01
Nodes (134): activeUpper, all, allBipsSubtitle, allBipsTitle, allEvents, appTitle, articleNotFound, authors (+126 more)

### Community 4 - "Community 4"
Cohesion: 0.03
Nodes (59): DateTime, draft,
  complete,
  deployed,, author, authors, bips, BipStatusChange, bodyMarkdown, category (+51 more)

### Community 5 - "Community 5"
Cohesion: 0.04
Nodes (57): ../../../core/widgets/external_url.dart, ../../../core/widgets/status_badge.dart, Bip, ReleaseNote, bip, _BipCard, BipDetailScreen, _BipSortOrder (+49 more)

### Community 6 - "Community 6"
Cohesion: 0.04
Nodes (48): 0 Release, File get, Notable, Object?, required List, SocketException, String? aiModel,
  List, _automation (+40 more)

### Community 7 - "Community 7"
Cohesion: 0.04
Nodes (46): , required String baseUrl,
  bool, baseUrl, _buildStamp, bundle, bundleFile, _BundleStamp, bundleUrl (+38 more)

### Community 8 - "Community 8"
Cohesion: 0.05
Nodes (40): ../content/app_content.dart, ../../features/code/presentation/code_dashboard_screen.dart, ../../features/history/presentation/history_timeline_screen.dart, ../../features/news/presentation/news_feed_screen.dart, ../../features/search/presentation/search_screen.dart, ../../features/shell/presentation/sato_wiki_shell.dart, ../../features/wiki/presentation/wiki_overview_screen.dart, AppRouter (+32 more)

### Community 9 - "Community 9"
Cohesion: 0.05
Nodes (41): _addKv, bodyRaw, bodyStart, _dequote, existingData, existingSeed, _extractSection, fmMatch (+33 more)

### Community 10 - "Community 10"
Cohesion: 0.06
Nodes (35): automation, _bipStatusTags, bundle, _checkMedia, _checkRecords, _containsPlaceholder, ContentValidationResult, data (+27 more)

### Community 11 - "Community 11"
Cohesion: 0.06
Nodes (34): content_bundle_parser.dart, content_media_store.dart, _assetBundle, BackgroundContentUpdater, baseUri, bundleUrl, checkForUpdates, ContentManifest (+26 more)

### Community 12 - "Community 12"
Cohesion: 0.06
Nodes (34): AppColors, bitcoinOrange, error, muted, onPrimaryContainerDark, onPrimaryContainerLight, onPrimaryDark, onSurfaceDark (+26 more)

### Community 13 - "Community 13"
Cohesion: 0.06
Nodes (34): package:sato_wiki/src/core/settings/shared_preferences_app_settings_repository.dart, required String json,
  int, required String version,
  String, String? sha256Override,
  Map, _bundleJson, downloadBundle, downloadMedia, fetchCount (+26 more)

### Community 14 - "Community 14"
Cohesion: 0.06
Nodes (33): BoxFit, content_mappers.dart, content_media_scope.dart, double?, File, alt, aspectRatio, build (+25 more)

### Community 15 - "Community 15"
Cohesion: 0.07
Nodes (31): ../../../core/content/domain/content_store.dart, ../../../core/localization/localized_labels.dart, ../../../core/navigation/app_routes.dart, ../../../core/search/search_index.dart, ../../../core/widgets/content_card.dart, ../../../core/widgets/filter_chip_bar.dart, ../../../core/widgets/markdown_text.dart, ../../../core/widgets/metadata_row.dart (+23 more)

### Community 16 - "Community 16"
Cohesion: 0.06
Nodes (30): content_bundle_migrator.dart, _bip, bundle, ContentBundleParser, ContentBundleParseResult, _contributor, _dateTime, hasWarnings (+22 more)

### Community 17 - "Community 17"
Cohesion: 0.06
Nodes (30): ../../../core/content/domain/content_media.dart, ../../../core/content/reading_level.dart, ../../../core/widgets/hero_media.dart, ../../../core/widgets/reading_level_selector.dart, WikiEntry, category, _CategoryMeta, _categoryMetaFor (+22 more)

### Community 18 - "Community 18"
Cohesion: 0.07
Nodes (28): class ContentStore, ../../../features/code/domain/repositories/code_repository.dart, ../../../features/history/domain/repositories/history_repository.dart, ../../../features/news/domain/repositories/news_repository.dart, ../../../features/wiki/domain/repositories/wiki_repository.dart, ContentBundle, bundle, findArticleById (+20 more)

### Community 19 - "Community 19"
Cohesion: 0.07
Nodes (26): ../app_content.dart, AppContent get, ../data/content_bundle_parser.dart, ../data/content_bundle_repository.dart, ../data/content_media_store.dart, checkForUpdates, _content, _contentFromResult (+18 more)

### Community 20 - "Community 20"
Cohesion: 0.09
Nodes (22): ../../../core/content/domain/content_models.dart, ContentStore, CodeRepository, findBipByNumber, findReleaseNoteById, listBips, listBipsByStatus, listReleaseNotes (+14 more)

### Community 21 - "Community 21"
Cohesion: 0.08
Nodes (22): app_colors.dart, external_url.dart, ../../../generated/l10n/app_localizations.dart, AppTheme, _buildTheme, dark, light, _textTheme (+14 more)

### Community 22 - "Community 22"
Cohesion: 0.08
Nodes (24): content_http_deadline.dart, dart:typed_data, ../domain/content_version.dart, Duration, canAttemptMediaRepair, create, _downloader, downloadMedia (+16 more)

### Community 23 - "Community 23"
Cohesion: 0.15
Nodes (21): AppKit, CGFloat, build, color, ContentStatus, showDot, status, StatusBadge (+13 more)

### Community 24 - "Community 24"
Cohesion: 0.08
Nodes (23): bool get, dart:ui, int get, AppLocale, explicitLocale, fallbackLanguageCode, fromStorageValue, hashCode (+15 more)

### Community 25 - "Community 25"
Cohesion: 0.08
Nodes (23): folded, _foldedLetters, from, id, _indexed, _IndexedResult, _items, _nonWordCharacters (+15 more)

### Community 26 - "Community 26"
Cohesion: 0.09
Nodes (22): ../../../core/widgets/content_mappers.dart, ../../../core/widgets/sources_disclosure.dart, HistoryEvent, build, categories, _categoryLabel, createState, event (+14 more)

### Community 27 - "Community 27"
Cohesion: 0.09
Nodes (22): package:sato_wiki/src/core/navigation/content_routes.dart, package:sato_wiki/src/features/history/presentation/history_timeline_screen.dart, package:sato_wiki/src/features/news/presentation/news_feed_screen.dart, package:sato_wiki/src/features/wiki/presentation/wiki_overview_screen.dart, _app, body, _bundle, _bundleJson (+14 more)

### Community 28 - "Community 28"
Cohesion: 0.09
Nodes (21): ../content/domain/content_store.dart, bip, bundle, canOpen, history, _humanizedId, news, null (+13 more)

### Community 29 - "Community 29"
Cohesion: 0.10
Nodes (20): content_models.dart, alt, ContentMedia, ContentMediaLookup, ContentMediaReference, ContentMediaValidationError, empty, _emptyMediaLookup (+12 more)

### Community 30 - "Community 30"
Cohesion: 0.10
Nodes (19): core/localization/app_locale.dart, core/navigation/app_router.dart, core/theme/app_theme.dart, core/widgets/update_progress_dialog.dart, build, contentController, createState, didChangeLocales (+11 more)

### Community 31 - "Community 31"
Cohesion: 0.11
Nodes (18): ../../code/presentation/code_dashboard_screen.dart, ../../../core/content/application/app_content_controller.dart, ../../../core/settings/app_settings_controller.dart, ../../../core/widgets/content_media_scope.dart, ../../../core/widgets/sato_scaffold.dart, ../../history/presentation/history_timeline_screen.dart, build, contentController (+10 more)

### Community 32 - "Community 32"
Cohesion: 0.11
Nodes (17): Locale, package:sato_wiki/src/features/code/presentation/code_dashboard_screen.dart, _bip, _codeFixtureJson, contentController, json, jsonEncode, load (+9 more)

### Community 33 - "Community 33"
Cohesion: 0.11
Nodes (17): _bipRecord, bips, body, _bundle, changelogs, id, main, related (+9 more)

### Community 34 - "Community 34"
Cohesion: 0.12
Nodes (15): content_card.dart, IconData, build, icon, links, onTap, RelatedLink, RelatedLinksGrid (+7 more)

### Community 35 - "Community 35"
Cohesion: 0.12
Nodes (16): contentController, contentMediaStore, contentRepository, contentUpdater, languageCode, main, preferences, settingsController (+8 more)

### Community 36 - "Community 36"
Cohesion: 0.12
Nodes (15): AssetBundle, Map, package:crypto/crypto.dart, package:sato_wiki/src/core/content/data/content_media_store.dart, assets, _bundleJson, data, downloadMedia (+7 more)

### Community 37 - "Community 37"
Cohesion: 0.12
Nodes (15): package:flutter_localizations/flutter_localizations.dart, package:sato_wiki/src/core/localization/app_locale.dart, package:sato_wiki/src/core/widgets/content_card.dart, package:sato_wiki/src/core/widgets/filter_chip_bar.dart, package:sato_wiki/src/core/widgets/hero_media.dart, package:sato_wiki/src/core/widgets/metadata_row.dart, package:sato_wiki/src/core/widgets/reader_header.dart, package:sato_wiki/src/core/widgets/reading_level_selector.dart (+7 more)

### Community 38 - "Community 38"
Cohesion: 0.13
Nodes (14): app_settings_repository.dart, class, _lastTabKey, loadLastTab, loadLocalePreference, loadReadingLevel, _localePreferenceKey, _preferences (+6 more)

### Community 39 - "Community 39"
Cohesion: 0.18
Nodes (15): SatoWikiApp, _SatoWikiAppState, BipListScreen, _BipListScreenState, HistoryTimelineScreen, _HistoryTimelineScreenState, NewsFeedScreen, _NewsFeedScreenState (+7 more)

### Community 40 - "Community 40"
Cohesion: 0.13
Nodes (14): package:sato_wiki/src/app.dart, package:sato_wiki/src/core/content/application/app_content_controller.dart, package:sato_wiki/src/core/navigation/app_router.dart, package:sato_wiki/src/core/navigation/app_routes.dart, package:sato_wiki/src/core/navigation/sato_wiki_tab.dart, package:sato_wiki/src/core/settings/app_settings_controller.dart, package:sato_wiki/src/core/settings/app_settings_repository.dart, _bipListFixtureJson (+6 more)

### Community 41 - "Community 41"
Cohesion: 0.15
Nodes (10): Any, Bool, Flutter, FlutterAppDelegate, AppDelegate, RunnerTests, UIApplication, UIKit (+2 more)

### Community 42 - "Community 42"
Cohesion: 0.14
Nodes (13): AppLocalePreference get, _lastTab, load, _localePreference, _persist, _readingLevel, _repository, setLastTab (+5 more)

### Community 43 - "Community 43"
Cohesion: 0.14
Nodes (13): AppLocalePreference, body, build, localePreference, onLocalePreferenceChanged, onTabSelected, SatoScaffold, selectedTab (+5 more)

### Community 44 - "Community 44"
Cohesion: 0.15
Nodes (13): AppSettingsRepository, InMemoryAppSettingsRepository, _lastTab, loadLastTab, loadLocalePreference, loadReadingLevel, _localePreference, _readingLevel (+5 more)

### Community 45 - "Community 45"
Cohesion: 0.14
Nodes (12): build, FilterChipBar, items, onSelected, selectedItem, build, onLevelChanged, ReadingLevelSelector (+4 more)

### Community 46 - "Community 46"
Cohesion: 0.17
Nodes (11): ColorScheme, CustomPainter, aspectRatio, build, colorScheme, HeroMedia, _HeroMediaPainter, icon (+3 more)

### Community 47 - "Community 47"
Cohesion: 0.17
Nodes (11): candidateParts, compareTo, _contentVersionPattern, currentParts, hasMatch, isNewerContentVersion, isValidContentVersion, parts (+3 more)

### Community 48 - "Community 48"
Cohesion: 0.17
Nodes (10): package:sato_wiki/src/core/content/domain/content_media.dart, package:sato_wiki/src/core/theme/app_theme.dart, package:sato_wiki/src/core/widgets/markdown_text.dart, _declaredMediaDirectories, directories, _directoryOf, main, pubspec (+2 more)

### Community 49 - "Community 49"
Cohesion: 0.17
Nodes (11): package:sato_wiki/src/core/content/domain/content_store.dart, package:sato_wiki/src/core/search/search_index.dart, _codeFixtureJson, entry, index, json, main, parseJson (+3 more)

### Community 50 - "Community 50"
Cohesion: 0.18
Nodes (10): content_bundle_errors.dart, ../domain/content_models.dart, JsonMap, ContentBundleMigrationResult, ContentBundleMigrator, currentSchemaVersion, data, migrate (+2 more)

### Community 51 - "Community 51"
Cohesion: 0.18
Nodes (10): build, icon, isTag, item, items, label, _MetadataChip, MetadataItem (+2 more)

### Community 52 - "Community 52"
Cohesion: 0.20
Nodes (9): package:flutter_test/flutter_test.dart, package:sato_wiki/src/core/content/data/content_bundle_errors.dart, package:sato_wiki/src/core/content/data/content_bundle_parser.dart, package:sato_wiki/src/core/content/data/content_bundle_repository.dart, package:sato_wiki/src/core/content/domain/content_models.dart, package:sato_wiki/src/core/content/domain/content_version.dart, package:sato_wiki/src/core/content/reading_level.dart, main (+1 more)

### Community 53 - "Community 53"
Cohesion: 0.22
Nodes (9): ../content/application/app_content_controller.dart, build, contentController, createState, dispose, initState, _onProgressChanged, UpdateProgressDialog (+1 more)

### Community 54 - "Community 54"
Cohesion: 0.20
Nodes (9): data/content_bundle_errors.dart, ../domain/content_media.dart, ../domain/content_store.dart, AppContent, mediaResolver, searchIndex, store, warnings (+1 more)

### Community 55 - "Community 55"
Cohesion: 0.22
Nodes (8): ../content/domain/content_media.dart, InheritedWidget, ContentMediaResolver, ContentMediaScope, maybeOf, resolver, updateShouldNotify, package:flutter/widgets.dart

### Community 56 - "Community 56"
Cohesion: 0.22
Nodes (8): ../content/domain/content_models.dart, ../content/reading_level.dart, BipStatus, BipStatusLabels, label, SearchSectionLabels, SearchSection, ../search/search_index.dart

### Community 57 - "Community 57"
Cohesion: 0.22
Nodes (8): dart:convert, Directory, FormatException, main, pagesRoot, tempDir, writeSource, ../tool/generate_bundle.dart

### Community 58 - "Community 58"
Cohesion: 0.22
Nodes (8): EdgeInsetsGeometry, build, child, ContentCard, onTap, padding, trailing, Widget

### Community 59 - "Community 59"
Cohesion: 0.25
Nodes (7): Exception, ContentBundleParseException, ContentBundleWarning, message, path, toString, CodeSyncHttpException

### Community 60 - "Community 60"
Cohesion: 0.25
Nodes (7): build, metadata, ReaderHeader, subtitle, title, trailing, metadata_row.dart

### Community 61 - "Community 61"
Cohesion: 0.29
Nodes (6): app_routes.dart, null, routeForContentId, slug, _slugRoute, return

### Community 62 - "Community 62"
Cohesion: 0.29
Nodes (7): ContentBundleRepository, DiscardableContentBundleRepository, LocalFirstContentBundleRepository, _TestContentBundleRepository, _GatedContentRepository, _FixtureBundleRepository, _TestContentBundleRepository

### Community 63 - "Community 63"
Cohesion: 0.33
Nodes (5): handle_new_rx_page(), __lldb_init_module(), Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages., SBDebugger, SBFrame

### Community 64 - "Community 64"
Cohesion: 0.40
Nodes (3): GeneratedPluginRegistrant, +registerWithRegistry, NSObject

### Community 65 - "Community 65"
Cohesion: 0.40
Nodes (6): AppLocalizations, _AppLocalizationsDelegate, AppLocalizationsEn, AppLocalizationsIt, of, LocalizationsDelegate

### Community 66 - "Community 66"
Cohesion: 0.60
Nodes (3): GeneratedPluginRegistrant, FlutterEngine, Keep

### Community 67 - "Community 67"
Cohesion: 0.60
Nodes (3): gradlew script, die(), warn()

### Community 68 - "Community 68"
Cohesion: 0.40
Nodes (4): fromStorageValue, ReadingLevel, storageValue, ReadingLevelLabels

### Community 69 - "Community 69"
Cohesion: 0.40
Nodes (4): fromIndex, fromRoutePath, routePath, SatoWikiTab

### Community 70 - "Community 70"
Cohesion: 0.50
Nodes (3): dart:async, dart:io, T

### Community 71 - "Community 71"
Cohesion: 0.50
Nodes (4): ContentBundleDownloader, HttpContentBundleDownloader, _FakeDownloader, _GatedDownloader

### Community 72 - "Community 72"
Cohesion: 0.50
Nodes (4): GitHubPagesContentManifestRepository, RemoteContentManifestRepository, _CountingManifestRepository, _FakeManifestRepository

### Community 73 - "Community 73"
Cohesion: 0.50
Nodes (4): ContentMediaDownloader, HttpContentMediaDownloader, _FakeMediaDownloader, _FakeMediaDownloader

### Community 74 - "Community 74"
Cohesion: 0.50
Nodes (4): build, AppRoutes.codeBip, AppRoutes.codeBips, AppRoutes.codeChangelog

### Community 75 - "Community 75"
Cohesion: 0.50
Nodes (4): build, build, AppRoutes.wikiCategory, AppRoutes.wikiEntry

### Community 76 - "Community 76"
Cohesion: 0.50
Nodes (4): FakeDraftClient, CodeContentDraftClient, GeminiCodeContentDraftClient, NullCodeContentDraftClient

### Community 78 - "Community 78"
Cohesion: 0.67
Nodes (3): ChangeNotifier, AppContentController, AppSettingsController

### Community 79 - "Community 79"
Cohesion: 0.67
Nodes (3): FakeSourceClient, CodeSourceClient, HttpCodeSourceClient

## Knowledge Gaps
- **1434 isolated node(s):** `flutter_export_environment.sh script`, `+registerWithRegistry`, `XCTest`, `preferences`, `settingsRepository` (+1429 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **5 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `ContentStore` connect `Community 20` to `Community 5`, `Community 14`, `Community 15`, `Community 17`, `Community 18`, `Community 49`, `Community 54`, `Community 26`?**
  _High betweenness centrality (0.027) - this node is a cross-community bridge._
- **Why does `ReadingLevel` connect `Community 68` to `Community 4`, `Community 42`, `Community 44`, `Community 45`, `Community 17`?**
  _High betweenness centrality (0.014) - this node is a cross-community bridge._
- **Why does `Color` connect `Community 23` to `Community 5`?**
  _High betweenness centrality (0.008) - this node is a cross-community bridge._
- **What connects `Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages.`, `flutter_export_environment.sh script`, `+registerWithRegistry` to the rest of the system?**
  _1435 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Community 0` be split into smaller, more focused modules?**
  _Cohesion score 0.013605442176870748 - nodes in this community are weakly interconnected._
- **Should `Community 1` be split into smaller, more focused modules?**
  _Cohesion score 0.013888888888888888 - nodes in this community are weakly interconnected._
- **Should `Community 2` be split into smaller, more focused modules?**
  _Cohesion score 0.014705882352941176 - nodes in this community are weakly interconnected._