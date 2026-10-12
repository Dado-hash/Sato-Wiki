import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sato_wiki/src/core/content/application/app_content_controller.dart';
import 'package:sato_wiki/src/core/content/data/content_bundle_parser.dart';
import 'package:sato_wiki/src/core/content/data/content_bundle_repository.dart';
import 'package:sato_wiki/src/core/content/reading_level.dart';
import 'package:sato_wiki/src/core/localization/app_locale.dart';
import 'package:sato_wiki/src/core/settings/app_settings_controller.dart';
import 'package:sato_wiki/src/core/settings/app_settings_repository.dart';
import 'package:sato_wiki/src/core/settings/theme_preference.dart';
import 'package:sato_wiki/src/core/theme/app_theme.dart';
import 'package:sato_wiki/src/features/settings/presentation/bookmarks_screen.dart';
import 'package:sato_wiki/src/features/settings/presentation/settings_screen.dart';
import 'package:sato_wiki/src/generated/l10n/app_localizations.dart';

void main() {
  testWidgets('settings screen changes theme, language and reading level', (
    tester,
  ) async {
    _useMockupSize(tester);
    final settings = await AppSettingsController.load(
      InMemoryAppSettingsRepository(),
    );
    final content = await _testContentController();

    await _pump(tester, SettingsScreen(settings: settings, content: content));

    await tester.tap(find.text('Advanced'));
    await tester.pumpAndSettle();
    expect(settings.readingLevel, ReadingLevel.advanced);

    await tester.tap(find.text('Light'));
    await tester.pumpAndSettle();
    expect(settings.themePreference, ThemePreference.light);

    await tester.scrollUntilVisible(find.text('Italiano'), 200);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Italiano'));
    await tester.pumpAndSettle();
    expect(settings.localePreference, const AppLocalePreference.language('it'));
  });

  testWidgets('settings screen shows the content version', (tester) async {
    _useMockupSize(tester);
    final settings = await AppSettingsController.load(
      InMemoryAppSettingsRepository(),
    );
    final content = await _testContentController();

    await _pump(tester, SettingsScreen(settings: settings, content: content));

    expect(find.text('Content version'), findsOneWidget);
    expect(find.text('2026.06.20'), findsOneWidget);
  });

  testWidgets('bookmarks screen shows empty state, then a saved entry', (
    tester,
  ) async {
    _useMockupSize(tester);
    final settings = await AppSettingsController.load(
      InMemoryAppSettingsRepository(),
    );
    final content = await _testContentController();

    await _pump(
      tester,
      BookmarksScreen(store: content.content.store, settings: settings),
    );

    expect(find.text('Nothing saved yet.'), findsOneWidget);
    expect(find.text('Proof of Work'), findsNothing);

    await settings.toggleBookmark('wiki.proof-of-work');
    await tester.pumpAndSettle();

    expect(find.text('Nothing saved yet.'), findsNothing);
    expect(find.text('Proof of Work'), findsOneWidget);
    expect(find.text('WIKI'), findsOneWidget);

    await tester.tap(find.byTooltip('Remove from bookmarks'));
    await tester.pumpAndSettle();

    expect(settings.isBookmarked('wiki.proof-of-work'), isFalse);
    expect(find.text('Proof of Work'), findsNothing);
    expect(find.text('Nothing saved yet.'), findsOneWidget);
  });
}

void _useMockupSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 960);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _pump(WidgetTester tester, Widget home) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark(),
      locale: const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocale.supportedLocales,
      home: home,
    ),
  );
}

Future<AppContentController> _testContentController() {
  return AppContentController.load(
    repository: const _TestContentBundleRepository(_fixtureJson),
    languageCode: 'en',
  );
}

final class _TestContentBundleRepository implements ContentBundleRepository {
  const _TestContentBundleRepository(this.json);

  final String json;

  @override
  Future<ContentBundleParseResult> load(String languageCode) async {
    return ContentBundleParser.parseJson(json);
  }

  @override
  Future<void> saveUpdatedBundleJson(String languageCode, String json) async {}
}

const _fixtureJson = '''
{
  "schemaVersion": 1,
  "version": "2026.06.20",
  "language": "en",
  "generatedAt": "2026-05-25T00:00:00Z",
  "wiki": [
    {
      "id": "wiki.proof-of-work",
      "slug": "proof-of-work",
      "language": "en",
      "category": "protocol",
      "title": "Proof of Work",
      "description": "Proof of Work summary.",
      "readingLevels": {
        "base": {"bodyMarkdown": "Base content."},
        "medium": {"bodyMarkdown": "Medium content."},
        "advanced": {"bodyMarkdown": "Advanced content."}
      },
      "difficulty": "advanced",
      "readTimeMinutes": 5,
      "tags": ["Mining"],
      "sources": [],
      "related": [],
      "updatedAt": "2026-05-25T00:00:00Z"
    }
  ],
  "news": [],
  "history": [],
  "bips": [],
  "changelogs": []
}
''';
