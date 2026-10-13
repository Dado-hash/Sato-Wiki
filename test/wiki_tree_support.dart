import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:sato_wiki/src/core/content/data/content_bundle_parser.dart';
import 'package:sato_wiki/src/core/content/domain/content_store.dart';
import 'package:sato_wiki/src/core/localization/app_locale.dart';
import 'package:sato_wiki/src/core/theme/app_theme.dart';
import 'package:sato_wiki/src/generated/l10n/app_localizations.dart';

/// App shell for widget tests. Named routes show `opened <route>`, so a test
/// can check where a tap navigates.
Widget wikiTreeApp(Widget home, {Locale? locale}) {
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

/// Small English bundle covering the wiki tree: software and hardware with
/// subcategories, one plain category, a glossary and two products.
ContentStore wikiTreeStore({bool withGlossary = true}) {
  final wiki = [
    _wiki(
      slug: 'proof-of-work',
      title: 'Proof of Work',
      category: 'protocol',
      description: 'Proof of Work summary.',
    ),
    _wiki(
      slug: 'software-wallets',
      title: 'Software wallet',
      category: 'software',
      subcategory: 'software-wallets',
      description: 'Guide to software wallets.',
      readTimeMinutes: 5,
      reviewedAt: '2026-10-13',
    ),
    _wiki(
      slug: 'nodes-guide',
      title: 'Nodes guide',
      category: 'software',
      subcategory: 'nodes',
      description: 'Programs that validate blocks.',
    ),
    _wiki(
      slug: 'lightning-guide',
      title: 'Lightning guide',
      category: 'software',
      subcategory: 'lightning',
      description: 'Channels and payments.',
    ),
    _wiki(
      slug: 'servers-guide',
      title: 'Servers guide',
      category: 'software',
      subcategory: 'servers',
      description: 'Electrum servers and indexers.',
    ),
    _wiki(
      slug: 'custom-b-guide',
      title: 'Custom B guide',
      category: 'software',
      subcategory: 'custom-b',
      description: 'Custom B summary.',
    ),
    _wiki(
      slug: 'custom-a-guide',
      title: 'Custom A guide',
      category: 'software',
      subcategory: 'custom-a',
      description: 'Custom A summary.',
    ),
    _wiki(
      slug: 'software-overview',
      title: 'Software overview',
      category: 'software',
      description: 'Loose software entry.',
    ),
    _wiki(
      slug: 'hardware-wallets-guide',
      title: 'Hardware wallets guide',
      category: 'hardware',
      subcategory: 'hardware-wallets',
      description: 'Signing devices.',
    ),
  ];
  final products = [
    _product(
      slug: 'zeta-wallet',
      name: 'Zeta Wallet',
      subcategory: 'software-wallets',
      status: 'discontinued',
      openSource: false,
      platforms: const [],
    ),
    _product(
      slug: 'alpha-wallet',
      name: 'Alpha Wallet',
      subcategory: 'software-wallets',
      status: 'active',
      openSource: true,
      platforms: const ['Desktop', 'Android'],
      license: 'MIT',
      sourceUrl: 'https://github.com/example/alpha',
    ),
    _product(
      slug: 'mid-node',
      name: 'Mid Node',
      subcategory: 'nodes',
      status: 'active',
      openSource: true,
      platforms: const ['Linux'],
    ),
  ];
  final glossary = [
    if (withGlossary) ...[
      _glossaryTerm('utxo', 'UTXO'),
      _glossaryTerm('nonce', 'Nonce'),
    ],
  ];

  final json = {
    'schemaVersion': 1,
    'version': 'test',
    'language': 'en',
    'generatedAt': '2026-10-13T00:00:00Z',
    'wiki': wiki,
    'news': <Object?>[],
    'history': <Object?>[],
    'bips': <Object?>[],
    'changelogs': <Object?>[],
    'glossary': glossary,
    'products': products,
  };

  return ContentStore(ContentBundleParser.parseJson(jsonEncode(json)).bundle);
}

const _body = {'bodyMarkdown': 'Body text for the guide.'};

Map<String, Object?> _wiki({
  required String slug,
  required String title,
  required String category,
  required String description,
  String? subcategory,
  int readTimeMinutes = 3,
  String? reviewedAt,
}) {
  return {
    'id': 'wiki.$slug',
    'slug': slug,
    'language': 'en',
    'category': category,
    'subcategory': ?subcategory,
    'title': title,
    'description': description,
    'readingLevels': {'base': _body, 'medium': _body, 'advanced': _body},
    'difficulty': 'base',
    'readTimeMinutes': readTimeMinutes,
    'tags': <String>[],
    'sources': <Object?>[],
    'related': <Object?>[],
    'updatedAt': '2026-10-01T00:00:00Z',
    'reviewedAt': ?reviewedAt,
  };
}

Map<String, Object?> _product({
  required String slug,
  required String name,
  required String subcategory,
  required String status,
  required bool openSource,
  required List<String> platforms,
  String? license,
  String? sourceUrl,
}) {
  return {
    'id': 'product.$slug',
    'slug': slug,
    'language': 'en',
    'name': name,
    'summary': '$name summary.',
    'bodyMarkdown':
        '$name body.\n\nSatoWiki does not sell or recommend products.',
    'category': 'software',
    'subcategory': subcategory,
    'maker': '$name Labs',
    'website': 'https://${slug.replaceAll('-', '')}.example',
    'sourceUrl': ?sourceUrl,
    'openSource': openSource,
    'license': ?license,
    'platforms': platforms,
    'status': status,
    'reviewedAt': '2026-10-13',
    'sources': <Object?>[],
    'related': <Object?>[],
    'updatedAt': '2026-10-01T00:00:00Z',
  };
}

Map<String, Object?> _glossaryTerm(String slug, String term) {
  return {
    'id': 'glossary.$slug',
    'slug': slug,
    'language': 'en',
    'term': term,
    'definition': '$term definition.',
    'aliases': <String>[],
    'related': <Object?>[],
    'updatedAt': '2026-10-01T00:00:00Z',
  };
}
