import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sato_wiki/src/app.dart';
import 'package:sato_wiki/src/core/content/application/app_content_controller.dart';
import 'package:sato_wiki/src/core/content/data/content_bundle_parser.dart';
import 'package:sato_wiki/src/core/content/data/content_bundle_repository.dart';
import 'package:sato_wiki/src/core/localization/app_locale.dart';
import 'package:sato_wiki/src/core/navigation/app_router.dart';
import 'package:sato_wiki/src/core/navigation/app_routes.dart';
import 'package:sato_wiki/src/core/navigation/sato_wiki_tab.dart';
import 'package:sato_wiki/src/core/settings/app_settings_controller.dart';
import 'package:sato_wiki/src/core/settings/app_settings_repository.dart';
import 'package:sato_wiki/src/core/settings/theme_preference.dart';
import 'package:sato_wiki/src/core/theme/app_theme.dart';
import 'package:sato_wiki/src/core/widgets/sato_tab_bar.dart';
import 'package:sato_wiki/src/features/code/presentation/code_dashboard_screen.dart';
import 'package:sato_wiki/src/features/code/presentation/release_list_screen.dart';
import 'package:sato_wiki/src/features/history/presentation/history_timeline_screen.dart';
import 'package:sato_wiki/src/features/news/presentation/news_feed_screen.dart';
import 'package:sato_wiki/src/features/search/presentation/search_screen.dart';
import 'package:sato_wiki/src/features/settings/presentation/settings_screen.dart';
import 'package:sato_wiki/src/features/today/presentation/today_screen.dart';
import 'package:sato_wiki/src/features/wiki/presentation/wiki_overview_screen.dart';
import 'package:sato_wiki/src/generated/l10n/app_localizations.dart';

void main() {
  testWidgets('a fresh install opens the Today tab first', (tester) async {
    _usePhoneSurface(tester);
    final repository = InMemoryAppSettingsRepository();
    final settingsController = await AppSettingsController.load(repository);
    final contentController = await _testContentController();

    await _pumpApp(tester, settingsController, contentController);

    expect(find.byType(TodayScreen), findsOneWidget);
    expect(_selectedTab('Today'), findsOneWidget);
    expect(find.byType(WikiOverviewScreen), findsNothing);
  });

  testWidgets('every tab can be selected and the selection is persisted', (
    tester,
  ) async {
    _usePhoneSurface(tester);
    final repository = InMemoryAppSettingsRepository();
    final settingsController = await AppSettingsController.load(repository);
    final contentController = await _testContentController();

    await _pumpApp(tester, settingsController, contentController);

    final screens = <SatoWikiTab, Type>{
      SatoWikiTab.today: TodayScreen,
      SatoWikiTab.wiki: WikiOverviewScreen,
      SatoWikiTab.news: NewsFeedScreen,
      SatoWikiTab.history: HistoryTimelineScreen,
      SatoWikiTab.code: CodeDashboardScreen,
    };
    final labels = <SatoWikiTab, String>{
      SatoWikiTab.today: 'Today',
      SatoWikiTab.wiki: 'Wiki',
      SatoWikiTab.news: 'News',
      SatoWikiTab.history: 'History',
      SatoWikiTab.code: 'Code',
    };

    // Today is the default, so selecting it first would not persist anything.
    // Visit it last, after another tab has been saved.
    final order = [
      SatoWikiTab.wiki,
      SatoWikiTab.news,
      SatoWikiTab.history,
      SatoWikiTab.code,
      SatoWikiTab.today,
    ];
    for (final tab in order) {
      await tester.tap(_tabItem(labels[tab]!));
      await tester.pumpAndSettle();

      expect(_selectedTab(labels[tab]!), findsOneWidget);
      expect(_visibleScreenCount(screens[tab]!), 1);
      expect(await repository.loadLastTab(), tab);
    }
  });

  testWidgets('the search button on the Today screen opens search', (
    tester,
  ) async {
    _usePhoneSurface(tester);
    final repository = InMemoryAppSettingsRepository();
    final settingsController = await AppSettingsController.load(repository);
    final contentController = await _testContentController();

    await _pumpApp(tester, settingsController, contentController);

    await tester.tap(find.byTooltip('Search'));
    await tester.pumpAndSettle();

    expect(find.byType(SearchScreen), findsOneWidget);
  });

  testWidgets('settings screen changes the app theme brightness', (
    tester,
  ) async {
    _usePhoneSurface(tester);
    final repository = InMemoryAppSettingsRepository();
    final settingsController = await AppSettingsController.load(repository);
    final contentController = await _testContentController();

    await _pumpApp(tester, settingsController, contentController);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);

    final settingsLight = find.descendant(
      of: find.byType(SettingsScreen),
      matching: find.text('Light'),
    );
    await tester.scrollUntilVisible(settingsLight, 300);
    await tester.tap(settingsLight);
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(SettingsScreen));
    expect(Theme.of(context).brightness, Brightness.light);
    expect(await repository.loadThemePreference(), ThemePreference.light);
  });

  testWidgets('deep link to the changelog list shows the release list', (
    tester,
  ) async {
    _usePhoneSurface(tester);
    final repository = InMemoryAppSettingsRepository();
    final settingsController = await AppSettingsController.load(repository);
    final contentController = await _testContentController();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocale.supportedLocales,
        initialRoute: AppRoutes.codeChangelogs,
        onGenerateRoute: (settings) {
          return AppRouter.generateRoute(
            settings,
            settingsController,
            contentController,
          );
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ReleaseListScreen), findsOneWidget);
    expect(find.text('All releases'), findsOneWidget);
  });

  testWidgets('bookmarking a wiki entry from its reader saves its id', (
    tester,
  ) async {
    _usePhoneSurface(tester);
    final repository = InMemoryAppSettingsRepository();
    final settingsController = await AppSettingsController.load(repository);
    final contentController = await _testContentController();

    await _pumpApp(tester, settingsController, contentController);

    Navigator.of(
      tester.element(find.byType(TodayScreen)),
    ).pushNamed(AppRoutes.wikiEntry('proof-of-work'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Save to bookmarks'));
    await tester.pumpAndSettle();

    expect(settingsController.bookmarks, ['wiki.proof-of-work']);
    expect(find.byTooltip('Remove from bookmarks'), findsOneWidget);
  });
}

void _usePhoneSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

Future<void> _pumpApp(
  WidgetTester tester,
  AppSettingsController settingsController,
  AppContentController contentController,
) async {
  await tester.pumpWidget(
    SatoWikiApp(
      settingsController: settingsController,
      contentController: contentController,
    ),
  );
  await tester.pumpAndSettle();
}

Finder _tabItem(String label) {
  return find.descendant(
    of: find.byType(SatoTabBar),
    matching: find.text(label),
  );
}

Finder _selectedTab(String label) {
  return find.byWidgetPredicate(
    (widget) =>
        widget is Semantics &&
        widget.properties.selected == true &&
        widget.properties.label == label,
  );
}

int _visibleScreenCount(Type screenType) {
  // Tabs live in an IndexedStack: offstage tabs are skipped by default.
  return find.byType(screenType).evaluate().length;
}

Future<AppContentController> _testContentController() {
  return AppContentController.load(
    repository: _TestContentBundleRepository(_fixtureJson),
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
  "version": "test",
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
        "advanced": {"bodyMarkdown": "Difficulty adjustment and accumulated work."}
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
