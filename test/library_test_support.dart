import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sato_wiki/src/core/content/data/content_bundle_parser.dart';
import 'package:sato_wiki/src/core/content/domain/content_store.dart';
import 'package:sato_wiki/src/core/localization/app_locale.dart';
import 'package:sato_wiki/src/core/theme/app_theme.dart';
import 'package:sato_wiki/src/generated/l10n/app_localizations.dart';

/// Store with one record of each collection the library and search tests use.
ContentStore libraryFixtureStore({bool empty = false}) {
  final json = {
    'schemaVersion': 1,
    'version': 'test',
    'language': 'en',
    'generatedAt': '2026-05-25T00:00:00Z',
    'wiki': [_wikiEntry()],
    'news': <Object?>[],
    'history': <Object?>[],
    'bips': <Object?>[],
    'changelogs': <Object?>[],
    'glossary': empty
        ? <Object?>[]
        : [
            _glossaryTerm(
              'nonce',
              term: 'Nonce',
              definition: 'A number that miners change while searching.',
            ),
            _glossaryTerm(
              'utxo',
              term: 'UTXO',
              aliases: ['Unspent output'],
              definition: 'An output that has not been spent yet.',
            ),
          ],
    'products': empty ? <Object?>[] : [_product()],
    'references': empty ? <Object?>[] : [_referenceTable()],
    'library': empty
        ? <Object?>[]
        : [
            _work(
              'blind-signatures',
              title: 'Blind Signatures for Untraceable Payments',
              author: 'David Chaum',
              year: 1982,
              kind: 'paper',
              topics: ['cryptography', 'privacy'],
              archiveUrl:
                  'https://web.archive.org/web/2026/https://example.com/chaum',
              related: ['wiki.proof-of-work'],
            ),
            _work(
              'cypherpunk-manifesto',
              title: "A Cypherpunk's Manifesto",
              author: 'Eric Hughes',
              year: 1993,
              kind: 'manifesto',
              topics: ['privacy'],
            ),
            _work(
              'bitcoin-whitepaper',
              title: 'Bitcoin: A Peer-to-Peer Electronic Cash System',
              author: 'Satoshi Nakamoto',
              year: 2008,
              kind: 'paper',
              topics: ['bitcoin', 'consensus'],
            ),
          ],
  };

  return ContentStore(ContentBundleParser.parseJson(jsonEncode(json)).bundle);
}

/// Pumps [body] in a MaterialApp. Pushed routes show "Opened" plus the route name, so tests
/// can check navigation without building the target screen.
Future<void> pumpLibraryScreen(
  WidgetTester tester, {
  required Widget body,
  Locale? locale,
  Widget Function(RouteSettings settings)? routeBuilder,
}) async {
  tester.view.physicalSize = const Size(390, 3000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark(),
      locale: locale ?? const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocale.supportedLocales,
      onGenerateRoute: (routeSettings) => MaterialPageRoute<void>(
        settings: routeSettings,
        builder: (_) =>
            routeBuilder?.call(routeSettings) ??
            Scaffold(body: Text('Opened ${routeSettings.name}')),
      ),
      home: body,
    ),
  );
  await tester.pumpAndSettle();
}

Map<String, Object?> _wikiEntry() {
  const body = {'bodyMarkdown': 'Body.'};

  return {
    'id': 'wiki.proof-of-work',
    'slug': 'proof-of-work',
    'language': 'en',
    'category': 'consensus',
    'title': 'Proof of Work',
    'description': 'Summary.',
    'readingLevels': {'base': body, 'medium': body, 'advanced': body},
    'difficulty': 'base',
    'readTimeMinutes': 3,
    'tags': <Object?>[],
    'sources': <Object?>[],
    'related': <Object?>[],
    'updatedAt': '2026-05-25T00:00:00Z',
  };
}

Map<String, Object?> _glossaryTerm(
  String slug, {
  required String term,
  required String definition,
  List<String> aliases = const [],
}) {
  return {
    'id': 'glossary.$slug',
    'slug': slug,
    'language': 'en',
    'term': term,
    'definition': definition,
    'aliases': aliases,
    'related': <Object?>[],
    'updatedAt': '2026-05-25T00:00:00Z',
  };
}

Map<String, Object?> _product() {
  return {
    'id': 'product.acme-node',
    'slug': 'acme-node',
    'language': 'en',
    'name': 'Acme Node',
    'summary': 'A full node client for desktops.',
    'bodyMarkdown': 'Body.',
    'category': 'software',
    'subcategory': 'nodes',
    'maker': 'Acme Labs',
    'website': 'https://example.com/acme',
    'openSource': true,
    'status': 'active',
    'reviewedAt': '2026-06-01',
    'sources': <Object?>[],
    'related': <Object?>[],
    'updatedAt': '2026-06-20T00:00:00Z',
  };
}

Map<String, Object?> _referenceTable() {
  return {
    'id': 'reference.fees',
    'slug': 'fees',
    'language': 'en',
    'title': 'Fee table',
    'description': 'Typical fee rates by block target.',
    'columns': [
      {'key': 'target', 'label': 'Target'},
    ],
    'rows': <Object?>[],
    'sources': <Object?>[],
    'related': <Object?>[],
    'updatedAt': '2026-06-20T00:00:00Z',
  };
}

Map<String, Object?> _work(
  String slug, {
  required String title,
  required String author,
  required int year,
  required String kind,
  List<String> topics = const [],
  String? archiveUrl,
  List<String> related = const [],
}) {
  return {
    'id': 'library.$slug',
    'slug': slug,
    'language': 'en',
    'title': title,
    'author': author,
    'year': year,
    'summary': 'Summary of $title.',
    'introduction': 'Our introduction to $title.',
    'originalLanguage': 'en',
    'kind': kind,
    'topics': topics,
    'url': 'https://example.com/$slug',
    'archiveUrl': ?archiveUrl,
    'licenseNote': 'No license stated; linked, not reproduced',
    'sources': <Object?>[],
    'related': related,
    'updatedAt': '2026-06-20T00:00:00Z',
    'reviewedAt': '2026-06-20',
  };
}
