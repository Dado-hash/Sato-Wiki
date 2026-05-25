import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sato_wiki/src/app.dart';
import 'package:sato_wiki/src/core/content/app_content.dart';
import 'package:sato_wiki/src/core/content/data/content_bundle_parser.dart';
import 'package:sato_wiki/src/core/content/domain/content_store.dart';
import 'package:sato_wiki/src/core/content/reading_level.dart';
import 'package:sato_wiki/src/core/navigation/app_router.dart';
import 'package:sato_wiki/src/core/navigation/app_routes.dart';
import 'package:sato_wiki/src/core/search/search_index.dart';
import 'package:sato_wiki/src/core/navigation/sato_wiki_tab.dart';
import 'package:sato_wiki/src/core/settings/app_settings_controller.dart';
import 'package:sato_wiki/src/core/settings/app_settings_repository.dart';
import 'package:sato_wiki/src/core/theme/app_theme.dart';

void main() {
  testWidgets('SatoWiki shell renders primary tabs', (tester) async {
    final repository = InMemoryAppSettingsRepository();
    final settingsController = await AppSettingsController.load(repository);
    final appContent = _testContent();

    await tester.pumpWidget(
      SatoWikiApp(
        settingsController: settingsController,
        appContent: appContent,
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
    final appContent = _testContent();

    await tester.pumpWidget(
      SatoWikiApp(
        settingsController: settingsController,
        appContent: appContent,
      ),
    );

    const advancedDescription =
        'Difficulty adjustment, SHA-256 hashing and accumulated work form the security model behind Bitcoin consensus.';

    await tester.scrollUntilVisible(
      find.text(advancedDescription),
      260,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text(advancedDescription), findsOneWidget);
  });

  testWidgets('SatoWiki exposes deep link targets', (tester) async {
    final repository = InMemoryAppSettingsRepository();
    final settingsController = await AppSettingsController.load(repository);
    final appContent = _testContent();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        initialRoute: AppRoutes.codeBip(341),
        onGenerateRoute: (settings) {
          return AppRouter.generateRoute(
            settings,
            settingsController,
            appContent,
          );
        },
      ),
    );

    expect(find.text('BIP 341: Taproot'), findsOneWidget);
    expect(find.text('Status History'), findsOneWidget);
  });
}

AppContent _testContent() {
  final result = ContentBundleParser.parseJson(_fixtureJson);
  final store = ContentStore(result.bundle);

  return AppContent(
    store: store,
    searchIndex: SearchIndex.fromBundle(result.bundle),
    warnings: result.warnings,
  );
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
