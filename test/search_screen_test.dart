import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sato_wiki/src/core/content/data/content_bundle_parser.dart';
import 'package:sato_wiki/src/core/content/domain/content_models.dart';
import 'package:sato_wiki/src/core/search/search_index.dart';
import 'package:sato_wiki/src/core/settings/app_settings_controller.dart';
import 'package:sato_wiki/src/core/settings/app_settings_repository.dart';
import 'package:sato_wiki/src/core/settings/app_settings_scope.dart';
import 'package:sato_wiki/src/core/theme/app_theme.dart';
import 'package:sato_wiki/src/features/search/presentation/search_screen.dart';
import 'package:sato_wiki/src/generated/l10n/app_localizations.dart';

void main() {
  late SearchIndex index;
  late AppLocalizations l10n;

  setUpAll(() async {
    index = SearchIndex.fromBundle(_fixtureBundle());
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  Future<AppSettingsController> pumpSearch(WidgetTester tester) async {
    final settings = await AppSettingsController.load(
      InMemoryAppSettingsRepository(),
    );
    await tester.pumpWidget(
      AppSettingsScope(
        controller: settings,
        child: MaterialApp(
          theme: AppTheme.dark(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SearchScreen(searchIndex: index),
        ),
      ),
    );
    await tester.pump();
    return settings;
  }

  TextField fieldOf(WidgetTester tester) {
    return tester.widget<TextField>(find.byType(TextField));
  }

  testWidgets('typing a query shows results under a section group label', (
    tester,
  ) async {
    await pumpSearch(tester);

    await tester.enterText(find.byType(TextField), 'taproot');
    await tester.pump();

    expect(find.text(l10n.wikiTab.toUpperCase()), findsOneWidget);
    expect(find.text('Taproot'), findsOneWidget);
    expect(find.text('Schnorr signatures'), findsOneWidget);
  });

  testWidgets('a query with no match shows the no-results text', (
    tester,
  ) async {
    await pumpSearch(tester);

    await tester.enterText(find.byType(TextField), 'zzzzz');
    await tester.pump();

    expect(find.text(l10n.noResultsFor('zzzzz')), findsOneWidget);
  });

  testWidgets('tapping a suggestion fills the field', (tester) async {
    await pumpSearch(tester);

    expect(find.text(l10n.suggestedSearches.toUpperCase()), findsOneWidget);
    await tester.tap(find.text('Lightning Network'));
    await tester.pump();

    expect(fieldOf(tester).controller!.text, 'Lightning Network');
    expect(
      fieldOf(tester).controller!.selection,
      const TextSelection.collapsed(offset: 17),
    );
  });

  testWidgets('submitting a query adds it to recent searches', (tester) async {
    final settings = await pumpSearch(tester);

    await tester.enterText(find.byType(TextField), 'halving');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pump();
    await tester.pump();

    expect(settings.recentSearches.first, 'halving');

    await tester.tap(find.byTooltip(l10n.clearSearch));
    await tester.pump();

    expect(find.text(l10n.recentSearches.toUpperCase()), findsOneWidget);
    expect(find.text('halving'), findsOneWidget);
  });

  testWidgets('the clear button empties the field', (tester) async {
    await pumpSearch(tester);

    expect(find.byTooltip(l10n.clearSearch), findsNothing);

    await tester.enterText(find.byType(TextField), 'bitcoin');
    await tester.pump();
    expect(find.byTooltip(l10n.clearSearch), findsOneWidget);

    await tester.tap(find.byTooltip(l10n.clearSearch));
    await tester.pump();

    expect(fieldOf(tester).controller!.text, isEmpty);
    expect(find.byTooltip(l10n.clearSearch), findsNothing);
  });
}

ContentBundle _fixtureBundle() {
  Map<String, Object?> entry(String id, String title, String summary) {
    const body = {'bodyMarkdown': 'Body.'};

    return {
      'id': id,
      'slug': id.substring('wiki.'.length),
      'language': 'en',
      'category': 'protocol',
      'title': title,
      'description': summary,
      'readingLevels': {'base': body, 'medium': body, 'advanced': body},
      'difficulty': 'base',
      'readTimeMinutes': 2,
      'tags': <String>[],
      'sources': <Object?>[],
      'related': <Object?>[],
      'updatedAt': '2026-05-25T00:00:00Z',
    };
  }

  final json = jsonEncode({
    'schemaVersion': 1,
    'version': 'test',
    'language': 'en',
    'generatedAt': '2026-05-25T00:00:00Z',
    'wiki': [
      entry('wiki.taproot', 'Taproot', 'Soft fork for scripts.'),
      entry(
        'wiki.schnorr',
        'Schnorr signatures',
        'Signatures used by Taproot.',
      ),
    ],
    'news': <Object?>[],
    'history': <Object?>[],
    'bips': <Object?>[],
    'changelogs': <Object?>[],
  });

  return ContentBundleParser.parseJson(json).bundle;
}
