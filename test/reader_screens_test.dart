import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sato_wiki/src/core/content/application/app_content_controller.dart';
import 'package:sato_wiki/src/core/content/data/content_bundle_parser.dart';
import 'package:sato_wiki/src/core/content/data/content_bundle_repository.dart';
import 'package:sato_wiki/src/core/content/domain/content_models.dart';
import 'package:sato_wiki/src/core/content/domain/content_store.dart';
import 'package:sato_wiki/src/core/content/reading_level.dart';
import 'package:sato_wiki/src/core/localization/app_locale.dart';
import 'package:sato_wiki/src/core/navigation/app_router.dart';
import 'package:sato_wiki/src/core/navigation/content_routes.dart';
import 'package:sato_wiki/src/core/navigation/sato_wiki_tab.dart';
import 'package:sato_wiki/src/core/settings/app_settings_controller.dart';
import 'package:sato_wiki/src/core/settings/app_settings_repository.dart';
import 'package:sato_wiki/src/core/theme/app_theme.dart';
import 'package:sato_wiki/src/core/widgets/related_links_grid.dart';
import 'package:sato_wiki/src/features/history/presentation/history_timeline_screen.dart';
import 'package:sato_wiki/src/features/news/presentation/news_feed_screen.dart';
import 'package:sato_wiki/src/features/wiki/presentation/wiki_overview_screen.dart';
import 'package:sato_wiki/src/generated/l10n/app_localizations.dart';

void main() {
  group('routeForContentId', () {
    test('maps each supported id prefix to its detail route', () {
      expect(routeForContentId('wiki.sha-256'), '/wiki/entries/sha-256');
      expect(
        routeForContentId('news.taproot-retro'),
        '/news/articles/taproot-retro',
      );
      expect(
        routeForContentId('history.pizza-day'),
        '/history/events/pizza-day',
      );
      expect(routeForContentId('code.bip.341'), '/code/bips/341');
      expect(
        routeForContentId('release.bitcoin-core.31.0'),
        '/code/changelogs/bitcoin-core/31.0',
      );
    });

    test('returns null for unknown prefixes and malformed ids', () {
      expect(routeForContentId('glossary.term'), isNull);
      expect(routeForContentId('wiki.'), isNull);
      expect(routeForContentId('code.bip.x'), isNull);
      expect(routeForContentId('release.bitcoin-core'), isNull);
      expect(routeForContentId('sha-256'), isNull);
    });
  });

  testWidgets('related link without onTap shows no chevron', (tester) async {
    await tester.pumpWidget(
      _app(
        const Scaffold(
          body: RelatedLinksGrid(
            links: [
              RelatedLink(title: 'Plain link', icon: Icons.link),
              RelatedLink(title: 'Open link', icon: Icons.link, onTap: _noop),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Plain link'), findsOneWidget);
    expect(find.text('Open link'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
  });

  testWidgets(
    'wiki related links open only loaded records and humanise missing ones',
    (tester) async {
      final store = _contentStore();

      await tester.pumpWidget(
        _app(
          WikiEntryScreen(
            store: store,
            slug: 'proof-of-work',
            selectedLevel: ReadingLevel.base,
            onLevelChanged: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('SHA-256'), 300);
      expect(find.text('SHA-256'), findsOneWidget);
      expect(find.text('Twenty one million cap'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);

      await tester.tap(find.text('SHA-256'));
      await tester.pumpAndSettle();

      expect(find.text('opened /wiki/entries/sha-256'), findsOneWidget);
    },
  );

  testWidgets('wiki category title is localized in Italian', (tester) async {
    await tester.pumpWidget(
      _app(
        WikiCategoryScreen(store: _contentStore(), category: 'Protocol'),
        locale: const Locale('it'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Protocollo'), findsOneWidget);
    expect(find.text('Protocol'), findsNothing);
  });

  testWidgets('wiki category shows empty state when no entries match', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(WikiCategoryScreen(store: _contentStore(), category: 'Economics')),
    );
    await tester.pumpAndSettle();

    expect(find.text('No local result found.'), findsOneWidget);
  });

  testWidgets('news chips come from the loaded articles', (tester) async {
    await tester.pumpWidget(
      _app(Scaffold(body: NewsFeedScreen(store: _contentStore()))),
    );
    await tester.pumpAndSettle();

    expect(find.text('All'), findsOneWidget);
    expect(find.text('Protocol'), findsOneWidget);
    expect(find.text('Culture'), findsOneWidget);
    expect(find.text('Market'), findsNothing);
    expect(find.text('Regulatory'), findsNothing);
    expect(find.text('Development'), findsNothing);
  });

  testWidgets('news list is sorted newest first and filters by category', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(Scaffold(body: NewsFeedScreen(store: _contentStore()))),
    );
    await tester.pumpAndSettle();

    expect(
      tester.getTopLeft(find.text('Newer culture piece')).dy,
      lessThan(tester.getTopLeft(find.text('Older protocol piece')).dy),
    );

    await tester.tap(find.text('Protocol'));
    await tester.pumpAndSettle();

    expect(find.text('Newer culture piece'), findsNothing);
    expect(find.text('Older protocol piece'), findsOneWidget);
  });

  testWidgets('news article hides the mock send tip button', (tester) async {
    await tester.pumpWidget(
      _app(NewsArticleScreen(store: _contentStore(), slug: 'older-protocol')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Send Tip'), findsNothing);
    expect(find.byIcon(Icons.payments_outlined), findsNothing);
    expect(find.text('Older protocol piece'), findsWidgets);
  });

  testWidgets('history shows empty state when there are no events', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        Scaffold(
          body: HistoryTimelineScreen(
            store: ContentStore(_bundle(wiki: const [], news: const [])),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No local result found.'), findsOneWidget);
  });

  testWidgets('opening a content link does not change the last tab', (
    tester,
  ) async {
    final repository = InMemoryAppSettingsRepository(
      lastTab: SatoWikiTab.history,
    );
    final settingsController = await AppSettingsController.load(repository);
    final contentController = await AppContentController.load(
      repository: _FixtureBundleRepository(_fixtureJson()),
      languageCode: 'en',
    );

    AppRouter.generateRoute(
      const RouteSettings(name: '/wiki/entries/proof-of-work'),
      settingsController,
      contentController,
    );

    expect(settingsController.lastTab, SatoWikiTab.history);
  });
}

void _noop() {}

Widget _app(Widget home, {Locale? locale}) {
  return MaterialApp(
    theme: AppTheme.dark(),
    locale: locale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: AppLocale.supportedLocales,
    home: home,
    onGenerateRoute: (settings) => MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => Scaffold(body: Text('opened ${settings.name}')),
    ),
  );
}

ContentStore _contentStore() {
  return ContentStore(ContentBundleParser.parseJson(_fixtureJson()).bundle);
}

String _fixtureJson() {
  final wiki = [
    _wikiEntry(
      slug: 'proof-of-work',
      title: 'Proof of Work',
      category: 'protocol',
      related: const [
        {'id': 'wiki.sha-256'},
        {'id': 'wiki.twenty-one-million-cap'},
      ],
    ),
    _wikiEntry(slug: 'sha-256', title: 'SHA-256', category: 'cryptography'),
  ];
  final news = [
    _newsArticle(
      slug: 'older-protocol',
      title: 'Older protocol piece',
      category: 'protocol',
      publishedAt: '2023-01-10',
    ),
    _newsArticle(
      slug: 'newer-culture',
      title: 'Newer culture piece',
      category: 'culture',
      publishedAt: '2024-06-01',
    ),
  ];

  return jsonEncode(_bundleJson(wiki: wiki, news: news));
}

ContentBundle _bundle({
  required List<Map<String, Object?>> wiki,
  required List<Map<String, Object?>> news,
}) {
  return ContentBundleParser.parseJson(
    jsonEncode(_bundleJson(wiki: wiki, news: news)),
  ).bundle;
}

Map<String, Object?> _bundleJson({
  required List<Map<String, Object?>> wiki,
  required List<Map<String, Object?>> news,
}) {
  return {
    'schemaVersion': 1,
    'version': 'test',
    'language': 'en',
    'generatedAt': '2026-05-25T00:00:00Z',
    'wiki': wiki,
    'news': news,
    'history': <Object?>[],
    'bips': <Object?>[],
    'changelogs': <Object?>[],
  };
}

Map<String, Object?> _wikiEntry({
  required String slug,
  required String title,
  required String category,
  List<Map<String, Object?>> related = const [],
}) {
  const body = {'bodyMarkdown': 'Body text.'};

  return {
    'id': 'wiki.$slug',
    'slug': slug,
    'language': 'en',
    'category': category,
    'title': title,
    'description': '$title summary.',
    'readingLevels': {'base': body, 'medium': body, 'advanced': body},
    'difficulty': 'base',
    'readTimeMinutes': 3,
    'tags': <String>[],
    'sources': <Object?>[],
    'related': related,
    'updatedAt': '2026-05-25T00:00:00Z',
  };
}

Map<String, Object?> _newsArticle({
  required String slug,
  required String title,
  required String category,
  required String publishedAt,
}) {
  return {
    'id': 'news.$slug',
    'slug': slug,
    'language': 'en',
    'title': title,
    'summary': '$title summary.',
    'category': category,
    'author': {'displayName': 'Author'},
    'publishedAt': publishedAt,
    'readTimeMinutes': 4,
    'bodyMarkdown': 'Article body.',
    'tags': <String>[],
    'sources': <Object?>[],
    'related': <Object?>[],
    'updatedAt': '2026-05-25T00:00:00Z',
  };
}

final class _FixtureBundleRepository implements ContentBundleRepository {
  const _FixtureBundleRepository(this.json);

  final String json;

  @override
  Future<ContentBundleParseResult> load(String languageCode) async {
    return ContentBundleParser.parseJson(json);
  }

  @override
  Future<void> saveUpdatedBundleJson(String languageCode, String json) async {}
}
