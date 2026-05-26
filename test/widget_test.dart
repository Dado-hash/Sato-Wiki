import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:sato_wiki/src/app.dart';
import 'package:sato_wiki/src/core/content/application/app_content_controller.dart';
import 'package:sato_wiki/src/core/content/data/content_bundle_parser.dart';
import 'package:sato_wiki/src/core/content/data/content_bundle_repository.dart';
import 'package:sato_wiki/src/core/content/reading_level.dart';
import 'package:sato_wiki/src/core/localization/app_locale.dart';
import 'package:sato_wiki/src/core/navigation/app_router.dart';
import 'package:sato_wiki/src/core/navigation/app_routes.dart';
import 'package:sato_wiki/src/core/navigation/sato_wiki_tab.dart';
import 'package:sato_wiki/src/core/settings/app_settings_controller.dart';
import 'package:sato_wiki/src/core/settings/app_settings_repository.dart';
import 'package:sato_wiki/src/core/theme/app_theme.dart';
import 'package:sato_wiki/src/generated/l10n/app_localizations.dart';

void main() {
  testWidgets('SatoWiki shell renders primary tabs', (tester) async {
    final repository = InMemoryAppSettingsRepository();
    final settingsController = await AppSettingsController.load(repository);
    final contentController = await _testContentController();

    await tester.pumpWidget(
      SatoWikiApp(
        settingsController: settingsController,
        contentController: contentController,
      ),
    );

    expect(find.text('SatoWiki'), findsOneWidget);
    expect(find.text('The Orange Book'), findsOneWidget);
    expect(find.text('Wiki'), findsOneWidget);
    expect(find.text('News'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Code'), findsOneWidget);

    await tester.tap(find.text('Code'));
    await tester.pumpAndSettle();

    expect(find.text('Code Dashboard'), findsWidgets);
    expect(await repository.loadLastTab(), SatoWikiTab.code);
  });

  testWidgets('SatoWiki restores persisted reading level', (tester) async {
    final repository = InMemoryAppSettingsRepository(
      lastTab: SatoWikiTab.wiki,
      readingLevel: ReadingLevel.advanced,
    );
    final settingsController = await AppSettingsController.load(repository);
    final contentController = await _testContentController();

    await tester.pumpWidget(
      SatoWikiApp(
        settingsController: settingsController,
        contentController: contentController,
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('The Orange Book'), findsOneWidget);
    expect(find.text('Knowledge Base'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Protocol'), 300);
    expect(find.text('Protocol'), findsOneWidget);
  });

  testWidgets('SatoWiki exposes deep link targets', (tester) async {
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
        initialRoute: AppRoutes.codeBip(341),
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

    expect(
      find.text('Taproot: SegWit version 1 spending rules.'),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(find.text('Status History'), 300);
    expect(find.text('Status History'), findsOneWidget);
  });

  testWidgets('SatoWiki persists locale preference from language sheet', (
    tester,
  ) async {
    final repository = InMemoryAppSettingsRepository();
    final settingsController = await AppSettingsController.load(repository);
    final contentController = await _testContentController();

    await tester.pumpWidget(
      SatoWikiApp(
        settingsController: settingsController,
        contentController: contentController,
      ),
    );

    await tester.tap(find.byIcon(Icons.language));
    await tester.pumpAndSettle();

    expect(find.text('Italiano'), findsOneWidget);

    await tester.tap(find.text('Italiano'));
    await tester.pumpAndSettle();

    expect(
      await repository.loadLocalePreference(),
      const AppLocalePreference.language('it'),
    );
  });

  testWidgets(
    'Code dashboard links to full BIP list with filters and sorting',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repository = InMemoryAppSettingsRepository(
        lastTab: SatoWikiTab.code,
      );
      final settingsController = await AppSettingsController.load(repository);
      final contentController = await _testContentController(
        _bipListFixtureJson,
      );

      await tester.pumpWidget(
        SatoWikiApp(
          settingsController: settingsController,
          contentController: contentController,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('BIP 400'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('BIP 342'), 300);
      expect(find.text('BIP 342'), findsOneWidget);
      expect(find.text('BIP 1'), findsNothing);

      await tester.scrollUntilVisible(find.text('All'), -300);
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();

      expect(find.text('All BIPs'), findsWidgets);
      expect(
        tester.getTopLeft(find.text('BIP 400')).dy,
        lessThan(tester.getTopLeft(find.text('BIP 1')).dy),
      );

      await tester.tap(find.text('Rejected'));
      await tester.pumpAndSettle();

      expect(find.text('BIP 400'), findsNothing);
      expect(find.text('BIP 399'), findsOneWidget);
      expect(find.text('BIP 1'), findsOneWidget);

      await tester.tap(find.byTooltip('Lowest BIP #'));
      await tester.pumpAndSettle();

      expect(
        tester.getTopLeft(find.text('BIP 1')).dy,
        lessThan(tester.getTopLeft(find.text('BIP 399')).dy),
      );
    },
  );
}

Future<AppContentController> _testContentController([
  String json = _fixtureJson,
]) {
  return AppContentController.load(
    repository: _TestContentBundleRepository(json),
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
        "advanced": {"bodyMarkdown": "Difficulty adjustment, SHA-256 hashing and accumulated work form the security model behind Bitcoin consensus."}
      },
      "difficulty": "advanced",
      "readTimeMinutes": 5,
      "tags": ["Mining", "Consensus"],
      "sources": [{"title": "Bitcoin paper", "url": "https://bitcoin.org/bitcoin.pdf"}],
      "related": [{"id": "wiki.sha-256", "title": "SHA-256"}],
      "updatedAt": "2026-05-25T00:00:00Z"
    }
  ],
  "news": [
    {
      "id": "news.taproot-retrospective",
      "slug": "taproot-retrospective",
      "language": "en",
      "title": "Taproot Retrospective",
      "summary": "Taproot summary.",
      "category": "protocol",
      "author": {"displayName": "Andreas M."},
      "publishedAt": "2023-11-14",
      "readTimeMinutes": 12,
      "bodyMarkdown": "Article body.",
      "tags": ["Taproot"],
      "sources": [],
      "related": [],
      "updatedAt": "2026-05-25T00:00:00Z"
    }
  ],
  "history": [],
  "bips": [
    {
      "id": "code.bip.341",
      "number": 341,
      "language": "en",
      "title": "Taproot",
      "summary": "SegWit version 1 spending rules.",
      "status": "active",
      "category": "consensus",
      "authors": ["Pieter Wuille"],
      "createdAt": "2020-01-19",
      "summaryMarkdown": "Summary.",
      "impactMarkdown": "Impact.",
      "officialUrl": "https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki",
      "tags": ["Taproot"],
      "sources": [],
      "related": [],
      "statusHistory": [{"date": "2021-11-14", "status": "active", "note": "Activated."}],
      "updatedAt": "2026-05-25T00:00:00Z"
    }
  ],
  "changelogs": []
}
''';

const _bipListFixtureJson = '''
{
  "schemaVersion": 1,
  "version": "test",
  "language": "en",
  "generatedAt": "2026-05-25T00:00:00Z",
  "wiki": [],
  "news": [],
  "history": [],
  "bips": [
    {
      "id": "code.bip.400",
      "number": 400,
      "language": "en",
      "title": "Newest Active",
      "summary": "Newest active BIP.",
      "status": "active",
      "category": "consensus",
      "authors": ["Author"],
      "createdAt": "2026-01-01",
      "summaryMarkdown": "Summary.",
      "impactMarkdown": "Impact.",
      "officialUrl": "https://github.com/bitcoin/bips",
      "tags": ["Consensus"],
      "sources": [],
      "related": [],
      "statusHistory": [],
      "updatedAt": "2026-05-25T00:00:00Z"
    },
    {
      "id": "code.bip.399",
      "number": 399,
      "language": "en",
      "title": "Recent Rejected",
      "summary": "Rejected BIP.",
      "status": "rejected",
      "category": "consensus",
      "authors": ["Author"],
      "createdAt": "2025-01-01",
      "summaryMarkdown": "Summary.",
      "impactMarkdown": "Impact.",
      "officialUrl": "https://github.com/bitcoin/bips",
      "tags": ["Consensus"],
      "sources": [],
      "related": [],
      "statusHistory": [],
      "updatedAt": "2026-05-25T00:00:00Z"
    },
    {
      "id": "code.bip.342",
      "number": 342,
      "language": "en",
      "title": "Recent Draft",
      "summary": "Draft BIP.",
      "status": "draft",
      "category": "consensus",
      "authors": ["Author"],
      "createdAt": "2024-01-01",
      "summaryMarkdown": "Summary.",
      "impactMarkdown": "Impact.",
      "officialUrl": "https://github.com/bitcoin/bips",
      "tags": ["Consensus"],
      "sources": [],
      "related": [],
      "statusHistory": [],
      "updatedAt": "2026-05-25T00:00:00Z"
    },
    {
      "id": "code.bip.1",
      "number": 1,
      "language": "en",
      "title": "Old Rejected",
      "summary": "Old rejected BIP.",
      "status": "rejected",
      "category": "process",
      "authors": ["Author"],
      "createdAt": "2011-01-01",
      "summaryMarkdown": "Summary.",
      "impactMarkdown": "Impact.",
      "officialUrl": "https://github.com/bitcoin/bips",
      "tags": ["Process"],
      "sources": [],
      "related": [],
      "statusHistory": [],
      "updatedAt": "2026-05-25T00:00:00Z"
    }
  ],
  "changelogs": []
}
''';
