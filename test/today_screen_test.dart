import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sato_wiki/src/core/content/data/content_bundle_parser.dart';
import 'package:sato_wiki/src/core/content/domain/content_store.dart';
import 'package:sato_wiki/src/core/localization/app_locale.dart';
import 'package:sato_wiki/src/core/settings/app_settings_controller.dart';
import 'package:sato_wiki/src/core/settings/app_settings_repository.dart';
import 'package:sato_wiki/src/core/theme/app_theme.dart';
import 'package:sato_wiki/src/features/today/presentation/today_screen.dart';
import 'package:sato_wiki/src/generated/l10n/app_localizations.dart';

void main() {
  testWidgets('shows headline and featured entry, hides continue reading', (
    tester,
  ) async {
    final settings = await _settings();

    await _pump(
      tester,
      store: _store(),
      settings: settings,
      now: DateTime(2026, 10, 13),
    );

    expect(find.textContaining('The orange book of'), findsOneWidget);
    // Day 286 of 2026 picks index 0 of the id-sorted wiki entries.
    expect(find.text('Proof of Work'), findsOneWidget);
    expect(find.text('Continue reading'), findsNothing);
  });

  testWidgets('continue reading appears after progress is recorded', (
    tester,
  ) async {
    final settings = await _settings();
    await _pump(
      tester,
      store: _store(),
      settings: settings,
      now: DateTime(2026, 10, 13),
    );

    await settings.setReadingProgress('wiki.proof-of-work', 0.5);
    await tester.pumpAndSettle();

    expect(find.text('Continue reading'), findsOneWidget);
    expect(find.textContaining('2 min left'), findsOneWidget);
    // The entry shown as continue reading is not featured again.
    expect(find.text('SHA-256'), findsOneWidget);
  });

  testWidgets('shows on this day when an event matches today', (tester) async {
    await _pump(
      tester,
      store: _store(),
      settings: await _settings(),
      now: DateTime(2026, 10, 31),
    );

    expect(find.text('On this day'), findsOneWidget);
    expect(find.text('Next anniversary'), findsNothing);
    expect(find.text('2008 · today'), findsOneWidget);
  });

  testWidgets('shows next anniversary when no event matches today', (
    tester,
  ) async {
    await _pump(
      tester,
      store: _store(),
      settings: await _settings(),
      now: DateTime(2026, 10, 13),
    );

    expect(find.text('Next anniversary'), findsOneWidget);
    expect(find.text('On this day'), findsNothing);
    expect(find.text('2008 · in 18 days'), findsOneWidget);
  });

  testWidgets('29 February events count as 28 February in non-leap years', (
    tester,
  ) async {
    await _pump(
      tester,
      store: _store(leapDay: true),
      settings: await _settings(),
      now: DateTime(2026, 2, 27),
    );

    expect(find.text('Next anniversary'), findsOneWidget);
    expect(find.text('2024 · tomorrow'), findsOneWidget);
  });

  testWidgets('from the code shows the highest BIP number and latest release', (
    tester,
  ) async {
    await _pump(
      tester,
      store: _store(),
      settings: await _settings(),
      now: DateTime(2026, 10, 13),
    );

    expect(find.text('From the code'), findsOneWidget);
    expect(find.text('BIP 451'), findsOneWidget);
    expect(find.text('BIP 341'), findsNothing);
    expect(find.text('v31.0'), findsOneWidget);
  });
}

Future<AppSettingsController> _settings() async {
  return AppSettingsController.load(InMemoryAppSettingsRepository());
}

Future<void> _pump(
  WidgetTester tester, {
  required ContentStore store,
  required AppSettingsController settings,
  required DateTime now,
}) async {
  // Tall surface so every block is built by the lazy list.
  tester.view.physicalSize = const Size(390, 3000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

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
      home: Scaffold(
        body: TodayScreen(store: store, settings: settings, now: now),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

ContentStore _store({bool leapDay = false}) {
  final json = {
    'schemaVersion': 1,
    'version': 'test',
    'language': 'en',
    'generatedAt': '2026-05-25T00:00:00Z',
    'wiki': [
      _wikiEntry(slug: 'proof-of-work', title: 'Proof of Work'),
      _wikiEntry(slug: 'sha-256', title: 'SHA-256'),
    ],
    'news': [
      {
        'id': 'news.core-report',
        'slug': 'core-report',
        'language': 'en',
        'title': 'Core development report',
        'summary': 'Summary.',
        'category': 'development',
        'author': {'displayName': 'Reporter'},
        'publishedAt': '2026-06-01',
        'readTimeMinutes': 4,
        'bodyMarkdown': 'Article body.',
        'tags': <Object?>[],
        'sources': <Object?>[],
        'related': <Object?>[],
        'updatedAt': '2026-06-01T00:00:00Z',
      },
    ],
    'history': [
      {
        'id': 'history.whitepaper',
        'slug': 'whitepaper',
        'language': 'en',
        'date': leapDay ? '2024-02-29' : '2008-10-31',
        'title': leapDay
            ? 'Leap day milestone'
            : 'Bitcoin whitepaper published',
        'category': 'protocol',
        'summary': 'Summary.',
        'bodyMarkdown': 'Body.',
        'tags': <Object?>[],
        'sources': <Object?>[],
        'related': <Object?>[],
        'updatedAt': '2026-05-25T00:00:00Z',
      },
    ],
    'bips': [_bip(341, 'complete', 'Taproot'), _bip(451, 'draft', 'Dust')],
    'changelogs': [
      {
        'id': 'release.bitcoin-core.31.0',
        'slug': 'bitcoin-core-31-0',
        'language': 'en',
        'project': 'bitcoin-core',
        'version': '31.0',
        'title': 'Bitcoin Core 31.0',
        'summary': 'Release notes.',
        'releasedAt': '2026-04-20',
        'importance': 'major',
        'userImpactMarkdown': 'Impact.',
        'technicalChangesMarkdown': 'Changes.',
        'officialUrl': 'https://bitcoincore.org/en/releases/31.0/',
        'tags': <Object?>[],
        'sources': <Object?>[],
        'related': <Object?>[],
        'updatedAt': '2026-06-20T00:00:00Z',
      },
    ],
  };

  return ContentStore(ContentBundleParser.parseJson(jsonEncode(json)).bundle);
}

Map<String, Object?> _wikiEntry({required String slug, required String title}) {
  const body = {'bodyMarkdown': 'Body text.'};

  return {
    'id': 'wiki.$slug',
    'slug': slug,
    'language': 'en',
    'category': 'protocol',
    'title': title,
    'description': '$title summary.',
    'readingLevels': {'base': body, 'medium': body, 'advanced': body},
    'difficulty': 'base',
    'readTimeMinutes': 3,
    'tags': <Object?>[],
    'sources': <Object?>[],
    'related': <Object?>[],
    'updatedAt': '2026-05-25T00:00:00Z',
  };
}

Map<String, Object?> _bip(int number, String status, String title) {
  return {
    'id': 'code.bip.$number',
    'number': number,
    'language': 'en',
    'title': title,
    'summary': '$title summary.',
    'status': status,
    'category': 'consensus',
    'authors': ['Author'],
    'createdAt': '2020-01-01',
    'summaryMarkdown': 'Summary.',
    'impactMarkdown': 'Impact.',
    'officialUrl': 'https://github.com/bitcoin/bips',
    'tags': ['Consensus'],
    'sources': <Object?>[],
    'related': <Object?>[],
    'statusHistory': <Object?>[],
    'updatedAt': '2026-05-25T00:00:00Z',
  };
}
