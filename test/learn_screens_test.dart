import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sato_wiki/src/core/content/data/content_bundle_parser.dart';
import 'package:sato_wiki/src/core/content/domain/content_store.dart';
import 'package:sato_wiki/src/core/localization/app_locale.dart';
import 'package:sato_wiki/src/core/navigation/app_router.dart';
import 'package:sato_wiki/src/core/settings/app_settings_controller.dart';
import 'package:sato_wiki/src/core/settings/app_settings_repository.dart';
import 'package:sato_wiki/src/core/theme/app_theme.dart';
import 'package:sato_wiki/src/features/learn/presentation/glossary_screens.dart';
import 'package:sato_wiki/src/features/learn/presentation/learning_path_screen.dart';
import 'package:sato_wiki/src/generated/l10n/app_localizations.dart';

void main() {
  group('learning path screen', () {
    testWidgets(
      'lists resolved steps in order, numbered, skipping unknown ids',
      (tester) async {
        await _pumpPath(tester, settings: await _settings());

        expect(find.text('Bitcoin from the start'), findsOneWidget);
        expect(find.text('A short path.'), findsOneWidget);
        expect(find.text('12 min'), findsOneWidget);
        expect(find.text('0 of 3 read'), findsOneWidget);
        expect(find.text('Bitcoin whitepaper published'), findsOneWidget);
        expect(find.text('Proof of Work'), findsOneWidget);
        expect(find.text('Nonce'), findsOneWidget);
        expect(find.text('Begin with the problem.'), findsOneWidget);
        expect(find.text('This record does not exist.'), findsNothing);
        expect(find.text('Read'), findsNothing);
        expect(find.text('All steps read'), findsNothing);
      },
    );

    testWidgets('read steps show a Read label with a check icon', (
      tester,
    ) async {
      final settings = await _settings();
      await settings.setReadingProgress('wiki.proof-of-work', 1.0);
      await settings.setReadingProgress('history.whitepaper', 0.5);
      await _pumpPath(tester, settings: settings);

      // Half read does not count: only the finished entry is read.
      expect(find.text('1 of 3 read'), findsOneWidget);
      expect(find.text('Read'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('says so when every step is read', (tester) async {
      final settings = await _settings();
      await settings.setReadingProgress('history.whitepaper', 1.0);
      await settings.setReadingProgress('wiki.proof-of-work', 1.0);
      await settings.setReadingProgress('glossary.nonce', 1.0);
      await _pumpPath(tester, settings: settings);

      expect(find.text('3 of 3 read'), findsOneWidget);
      expect(find.text('All steps read'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsNWidgets(3));
    });

    testWidgets('renders the Italian labels', (tester) async {
      await _pumpPath(
        tester,
        settings: await _settings(),
        locale: const Locale('it'),
      );

      expect(find.text('0 di 3 letti'), findsOneWidget);
      expect(find.text('Passo 1'), findsNothing);
      expect(find.text('Hai letto tutti i passi'), findsNothing);
    });

    testWidgets('tapping a step opens its entry', (tester) async {
      await _pumpPath(tester, settings: await _settings());

      await tester.tap(find.text('Proof of Work'));
      await tester.pumpAndSettle();

      expect(find.text('Opened /wiki/entries/proof-of-work'), findsOneWidget);
    });

    testWidgets('unknown path shows the not-found title', (tester) async {
      await _pumpPath(tester, settings: await _settings(), slug: 'missing');

      expect(find.text('Path not found'), findsOneWidget);
    });
  });

  group('glossary list', () {
    testWidgets('sorts terms with a letter header for each initial', (
      tester,
    ) async {
      await _pumpGlossary(tester);

      expect(find.text('A'), findsOneWidget);
      expect(find.text('N'), findsOneWidget);
      expect(find.text('U'), findsOneWidget);
      expect(find.text('Address'), findsOneWidget);
      expect(find.text('Glossary'), findsOneWidget);
    });

    testWidgets('filters by term, case-insensitive', (tester) async {
      await _pumpGlossary(tester);

      await tester.enterText(find.byType(TextField), 'NONCE');
      await tester.pumpAndSettle();

      expect(find.text('Nonce'), findsOneWidget);
      expect(find.text('Address'), findsNothing);
      expect(find.text('U'), findsNothing);
    });

    testWidgets('filters by alias', (tester) async {
      await _pumpGlossary(tester);

      await tester.enterText(find.byType(TextField), 'unspent');
      await tester.pumpAndSettle();

      expect(find.text('UTXO'), findsOneWidget);
      expect(find.text('Address'), findsNothing);
    });

    testWidgets('a filter with no match says so', (tester) async {
      await _pumpGlossary(tester);

      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pumpAndSettle();

      expect(find.text('No terms match "zzz".'), findsOneWidget);
    });

    testWidgets('renders the Italian labels', (tester) async {
      await _pumpGlossary(tester, locale: const Locale('it'));

      expect(find.text('Glossario'), findsOneWidget);
      expect(find.text('Filtra i termini'), findsOneWidget);
    });

    testWidgets('tapping a term opens its screen', (tester) async {
      await _pumpGlossary(tester);

      await tester.tap(find.text('Nonce'));
      await tester.pumpAndSettle();

      expect(find.text('Opened /glossary/nonce'), findsOneWidget);
    });
  });

  group('glossary term screen', () {
    testWidgets('shows aliases, definition and related entries', (
      tester,
    ) async {
      await _pumpTerm(tester, slug: 'address');

      expect(find.text('Address'), findsWidgets);
      expect(find.text('Also called: Bitcoin address'), findsOneWidget);
      expect(
        find.text(
          'An identifier that tells the network where to send bitcoin.',
        ),
        findsOneWidget,
      );
      expect(find.text('Related Concepts'), findsOneWidget);
      expect(find.text('Proof of Work'), findsOneWidget);
    });

    testWidgets('a related entry opens its wiki screen', (tester) async {
      await _pumpTerm(tester, slug: 'address');

      await tester.tap(find.text('Proof of Work'));
      await tester.pumpAndSettle();

      expect(find.text('Opened /wiki/entries/proof-of-work'), findsOneWidget);
    });

    testWidgets('no aliases means no "Also called" line', (tester) async {
      await _pumpTerm(tester, slug: 'nonce');

      expect(find.textContaining('Also called'), findsNothing);
    });

    testWidgets('unknown slug shows the not-found title', (tester) async {
      await _pumpTerm(tester, slug: 'missing');

      expect(find.text('Term not found'), findsOneWidget);
    });
  });

  group('routes', () {
    test('glossary and path routes are recognised deep links', () {
      expect(DeepLinkTarget.tryParse('/glossary'), isNotNull);
      expect(DeepLinkTarget.tryParse('/glossary/address'), isNotNull);
      expect(DeepLinkTarget.tryParse('/paths/start-here'), isNotNull);
      expect(DeepLinkTarget.tryParse('/glossary/a/b'), isNull);
      expect(DeepLinkTarget.tryParse('/paths'), isNull);
    });
  });
}

Future<AppSettingsController> _settings() async {
  return AppSettingsController.load(InMemoryAppSettingsRepository());
}

Future<void> _pumpPath(
  WidgetTester tester, {
  required AppSettingsController settings,
  String slug = 'start-here',
  Locale? locale,
}) async {
  await _pumpScreen(
    tester,
    locale: locale,
    body: LearningPathScreen(store: _store(), settings: settings, slug: slug),
  );
}

Future<void> _pumpGlossary(WidgetTester tester, {Locale? locale}) async {
  await _pumpScreen(
    tester,
    locale: locale,
    body: GlossaryListScreen(store: _store()),
  );
}

Future<void> _pumpTerm(WidgetTester tester, {required String slug}) async {
  await _pumpScreen(
    tester,
    body: GlossaryTermScreen(store: _store(), slug: slug),
  );
}

Future<void> _pumpScreen(
  WidgetTester tester, {
  required Widget body,
  Locale? locale,
}) async {
  tester.view.physicalSize = const Size(390, 3000);
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
      home: body,
    ),
  );
  await tester.pumpAndSettle();
}

ContentStore _store() {
  final json = {
    'schemaVersion': 1,
    'version': 'test',
    'language': 'en',
    'generatedAt': '2026-05-25T00:00:00Z',
    'wiki': [
      {
        'id': 'wiki.proof-of-work',
        'slug': 'proof-of-work',
        'language': 'en',
        'category': 'consensus',
        'title': 'Proof of Work',
        'description': 'Summary.',
        'readingLevels': _levels,
        'difficulty': 'base',
        'readTimeMinutes': 3,
        'tags': <Object?>[],
        'sources': <Object?>[],
        'related': <Object?>[],
        'updatedAt': '2026-05-25T00:00:00Z',
      },
    ],
    'news': <Object?>[],
    'history': [
      {
        'id': 'history.whitepaper',
        'slug': 'whitepaper',
        'language': 'en',
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
    'glossary': [
      _term(
        'address',
        term: 'Address',
        aliases: ['Bitcoin address'],
        definition:
            'An identifier that tells the network where to send bitcoin.',
        related: [
          {'id': 'wiki.proof-of-work'},
        ],
      ),
      _term(
        'nonce',
        term: 'Nonce',
        definition: 'A number that miners change while searching for a hash.',
      ),
      _term(
        'utxo',
        term: 'UTXO',
        aliases: ['Unspent output'],
        definition: 'An output that has not been spent yet.',
      ),
    ],
    'paths': [
      {
        'id': 'path.start-here',
        'slug': 'start-here',
        'language': 'en',
        'title': 'Bitcoin from the start',
        'description': 'A short path.',
        'estimatedMinutes': 12,
        'steps': [
          {'id': 'history.whitepaper', 'note': 'Begin with the problem.'},
          {'id': 'wiki.missing', 'note': 'This record does not exist.'},
          {'id': 'wiki.proof-of-work', 'note': 'Then the work.'},
          {'id': 'glossary.nonce', 'note': 'Finally the nonce.'},
        ],
        'updatedAt': '2026-05-25T00:00:00Z',
      },
    ],
  };

  return ContentStore(ContentBundleParser.parseJson(jsonEncode(json)).bundle);
}

const _levels = {
  'base': {'bodyMarkdown': 'Body.'},
  'medium': {'bodyMarkdown': 'Body.'},
  'advanced': {'bodyMarkdown': 'Body.'},
};

Map<String, Object?> _term(
  String slug, {
  required String term,
  required String definition,
  List<String> aliases = const [],
  List<Map<String, Object?>> related = const [],
}) {
  return {
    'id': 'glossary.$slug',
    'slug': slug,
    'language': 'en',
    'term': term,
    'definition': definition,
    'aliases': aliases,
    'related': related,
    'updatedAt': '2026-05-25T00:00:00Z',
  };
}
