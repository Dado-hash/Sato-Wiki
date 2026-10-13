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
  final now = DateTime(2026, 10, 13);

  testWidgets('no learning path in the bundle shows no start card', (
    tester,
  ) async {
    await _pump(
      tester,
      store: _store(paths: false),
      settings: await _settings(),
      now: now,
    );

    expect(find.text('START HERE · 12 MIN'), findsNothing);
  });

  testWidgets('start card shows zero of the resolved steps read', (
    tester,
  ) async {
    await _pump(tester, store: _store(), settings: await _settings(), now: now);

    expect(find.text('START HERE · 12 MIN'), findsOneWidget);
    expect(find.text('Bitcoin from the start'), findsOneWidget);
    // The step with an unknown id is skipped, so the total is 2.
    expect(find.text('0 of 2 read'), findsOneWidget);
    expect(find.text('Next: Bitcoin whitepaper published'), findsOneWidget);
  });

  testWidgets('start card points to the first unread step', (tester) async {
    final settings = await _settings();
    await settings.setReadingProgress('history.whitepaper', 1.0);
    await _pump(tester, store: _store(), settings: settings, now: now);

    expect(find.text('1 of 2 read'), findsOneWidget);
    expect(find.text('Next: Proof of Work'), findsOneWidget);
  });

  testWidgets('start card says so when every step is read', (tester) async {
    final settings = await _settings();
    await settings.setReadingProgress('history.whitepaper', 1.0);
    await settings.setReadingProgress('wiki.proof-of-work', 0.99);
    await _pump(tester, store: _store(), settings: settings, now: now);

    expect(find.text('2 of 2 read'), findsOneWidget);
    expect(find.text('All steps read'), findsOneWidget);
    expect(find.textContaining('Next:'), findsNothing);
  });

  testWidgets('start card in Italian uses the Italian labels', (tester) async {
    await _pump(
      tester,
      store: _store(language: 'it'),
      settings: await _settings(),
      now: now,
      locale: const Locale('it'),
    );

    expect(find.text('INIZIA QUI · 12 MIN'), findsOneWidget);
    expect(find.text('0 di 2 letti'), findsOneWidget);
    expect(find.text('Prossima: Bitcoin whitepaper published'), findsOneWidget);
  });

  testWidgets('tapping the start card opens the path screen', (tester) async {
    await _pump(tester, store: _store(), settings: await _settings(), now: now);

    await tester.tap(find.text('Bitcoin from the start'));
    await tester.pumpAndSettle();

    expect(find.text('Opened /paths/start-here'), findsOneWidget);
  });

  testWidgets('quote of the day shows the English quote without original', (
    tester,
  ) async {
    await _pump(tester, store: _store(), settings: await _settings(), now: now);

    expect(find.text('QUOTE'), findsOneWidget);
    expect(find.text('“Quote a text.”'), findsOneWidget);
    expect(find.text('Satoshi Nakamoto · Oct 31, 2008'), findsOneWidget);
    expect(find.text('Source'), findsOneWidget);
  });

  testWidgets('quote of the day in Italian shows translation and original', (
    tester,
  ) async {
    await _pump(
      tester,
      store: _store(language: 'it', withOriginal: true),
      settings: await _settings(),
      now: now,
      locale: const Locale('it'),
    );

    expect(find.text('CITAZIONE'), findsOneWidget);
    expect(find.text('“Citazione italiana.”'), findsOneWidget);
    expect(find.text('Original English quote.'), findsOneWidget);
    expect(find.text('Satoshi Nakamoto · 31 ott 2008'), findsOneWidget);
    expect(find.text('Fonte'), findsOneWidget);
  });

  testWidgets('quote of the day picks the quote for the date', (tester) async {
    // 2026-10-14 is one day after 2026-10-13: index 1 of three sorted quotes.
    await _pump(
      tester,
      store: _store(),
      settings: await _settings(),
      now: DateTime(2026, 10, 14),
    );

    expect(find.text('“Quote b text.”'), findsOneWidget);
    expect(find.text('“Quote a text.”'), findsNothing);
  });

  testWidgets('quote of the day comes right after the start card', (
    tester,
  ) async {
    await _pump(tester, store: _store(), settings: await _settings(), now: now);

    final pathTop = tester.getTopLeft(find.text('Bitcoin from the start')).dy;
    final quoteTop = tester.getTopLeft(find.text('“Quote a text.”')).dy;
    final featuredTop = tester.getTopLeft(find.text('Featured')).dy;

    expect(quoteTop, greaterThan(pathTop));
    expect(quoteTop, lessThan(featuredTop));
  });

  testWidgets('no quotes in the bundle shows no quote card', (tester) async {
    await _pump(
      tester,
      store: _store(quotes: false),
      settings: await _settings(),
      now: now,
    );

    expect(find.text('QUOTE'), findsNothing);
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
  Locale? locale,
}) async {
  // Tall surface so every block is built by the lazy list.
  tester.view.physicalSize = const Size(390, 3600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark(),
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocale.supportedLocales,
      onGenerateRoute: (routeSettings) => MaterialPageRoute<void>(
        settings: routeSettings,
        builder: (_) => Scaffold(body: Text('Opened ${routeSettings.name}')),
      ),
      home: Scaffold(
        body: TodayScreen(store: store, settings: settings, now: now),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

ContentStore _store({
  String language = 'en',
  bool paths = true,
  bool quotes = true,
  bool withOriginal = false,
}) {
  final json = {
    'schemaVersion': 1,
    'version': 'test',
    'language': language,
    'generatedAt': '2026-05-25T00:00:00Z',
    'wiki': [
      _wikiEntry(
        slug: 'proof-of-work',
        title: 'Proof of Work',
        language: language,
      ),
      _wikiEntry(slug: 'sha-256', title: 'SHA-256', language: language),
    ],
    'news': <Object?>[],
    'history': [
      {
        'id': 'history.whitepaper',
        'slug': 'whitepaper',
        'language': language,
        'date': '2008-10-31',
        'title': 'Bitcoin whitepaper published',
        'category': 'protocol',
        'summary': 'Summary.',
        'bodyMarkdown': 'Body.',
        'tags': <Object?>[],
        'sources': <Object?>[],
        'related': <Object?>[],
        'updatedAt': '2026-05-25T00:00:00Z',
      },
    ],
    'bips': <Object?>[],
    'changelogs': <Object?>[],
    if (paths) 'paths': [_path(language)],
    if (quotes)
      'quotes': [
        for (final id in ['c', 'a', 'b'])
          _quote(id, language: language, withOriginal: withOriginal),
      ],
  };

  return ContentStore(ContentBundleParser.parseJson(jsonEncode(json)).bundle);
}

Map<String, Object?> _path(String language) {
  return {
    'id': 'path.start-here',
    'slug': 'start-here',
    'language': language,
    'title': 'Bitcoin from the start',
    'description': 'A short path.',
    'estimatedMinutes': 12,
    'steps': [
      {'id': 'history.whitepaper', 'note': 'Begin with the problem.'},
      {'id': 'wiki.missing', 'note': 'This record does not exist.'},
      {'id': 'wiki.proof-of-work', 'note': 'Then the work.'},
    ],
    'updatedAt': '2026-05-25T00:00:00Z',
  };
}

Map<String, Object?> _quote(
  String id, {
  required String language,
  required bool withOriginal,
}) {
  final italian = language == 'it';

  return {
    'id': 'quote.$id',
    'slug': id,
    'language': language,
    'text': italian ? 'Citazione italiana.' : 'Quote $id text.',
    if (italian && withOriginal) 'originalText': 'Original English quote.',
    'author': 'Satoshi Nakamoto',
    'date': '2008-10-31',
    'sourceTitle': 'Bitcoin: A Peer-to-Peer Electronic Cash System',
    'sourceUrl': 'https://nakamotoinstitute.org/library/bitcoin/',
    'topics': <Object?>[],
    'related': <Object?>[],
    'updatedAt': '2026-05-25T00:00:00Z',
  };
}

Map<String, Object?> _wikiEntry({
  required String slug,
  required String title,
  required String language,
}) {
  const body = {'bodyMarkdown': 'Body text.'};

  return {
    'id': 'wiki.$slug',
    'slug': slug,
    'language': language,
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
