import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sato_wiki/src/core/content/data/content_bundle_parser.dart';
import 'package:sato_wiki/src/core/content/domain/content_store.dart';

/// Tall surface so the lazy lists build every block.
void useConnectTallScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 4000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
}

/// Bundle for the connection tests. Wiki entries: `hash-functions`,
/// `sha-256`, `proof-of-work` and `bitcoin-script` have "Try it" rows,
/// `plain-entry` has none. Quotes `a`, `b` and
/// `c` relate to `proof-of-work`, `d` to `hash-functions`. [libraryWorks]
/// library works are added to the bundle.
ContentStore connectStore({String language = 'en', int libraryWorks = 0}) {
  final json = {
    'schemaVersion': 1,
    'version': 'test',
    'language': language,
    'generatedAt': '2026-10-13T00:00:00Z',
    'wiki': [
      _wiki('hash-functions', 'Hash functions'),
      _wiki('sha-256', 'SHA-256'),
      _wiki('proof-of-work', 'Proof of Work'),
      _wiki('bitcoin-script', 'Bitcoin Script'),
      _wiki('plain-entry', 'Plain entry'),
    ],
    'news': <Object?>[],
    'history': <Object?>[],
    'bips': <Object?>[],
    'changelogs': <Object?>[],
    'quotes': [
      _quote('a', 'wiki.proof-of-work', italian: language == 'it'),
      _quote('b', 'wiki.proof-of-work', italian: language == 'it'),
      _quote('c', 'wiki.proof-of-work', italian: language == 'it'),
      _quote('d', 'wiki.hash-functions', italian: language == 'it'),
    ],
    'library': [for (var i = 1; i <= libraryWorks; i++) _work(i)],
  };

  return ContentStore(ContentBundleParser.parseJson(jsonEncode(json)).bundle);
}

/// Overview store with a glossary and [libraryWorks] library works.
ContentStore connectOverviewStore({int libraryWorks = 0}) {
  final json = {
    'schemaVersion': 1,
    'version': 'test',
    'language': 'en',
    'generatedAt': '2026-10-13T00:00:00Z',
    'wiki': [_wiki('proof-of-work', 'Proof of Work')],
    'news': <Object?>[],
    'history': <Object?>[],
    'bips': <Object?>[],
    'changelogs': <Object?>[],
    'glossary': [
      {
        'id': 'glossary.utxo',
        'slug': 'utxo',
        'language': 'en',
        'term': 'UTXO',
        'definition': 'UTXO definition.',
        'aliases': <String>[],
        'related': <Object?>[],
        'updatedAt': '2026-10-01T00:00:00Z',
      },
      {
        'id': 'glossary.nonce',
        'slug': 'nonce',
        'language': 'en',
        'term': 'Nonce',
        'definition': 'Nonce definition.',
        'aliases': <String>[],
        'related': <Object?>[],
        'updatedAt': '2026-10-01T00:00:00Z',
      },
    ],
    'library': [for (var i = 1; i <= libraryWorks; i++) _work(i)],
  };

  return ContentStore(ContentBundleParser.parseJson(jsonEncode(json)).bundle);
}

const _body = {'bodyMarkdown': 'Body text.'};

Map<String, Object?> _wiki(String slug, String title) {
  return {
    'id': 'wiki.$slug',
    'slug': slug,
    'language': 'en',
    'category': 'protocol',
    'title': title,
    'description': '$title summary.',
    'readingLevels': {'base': _body, 'medium': _body, 'advanced': _body},
    'difficulty': 'base',
    'readTimeMinutes': 3,
    'tags': <Object?>[],
    'sources': <Object?>[],
    'related': <Object?>[],
    'updatedAt': '2026-10-01T00:00:00Z',
  };
}

Map<String, Object?> _quote(
  String slug,
  String relatedId, {
  required bool italian,
}) {
  return {
    'id': 'quote.$slug',
    'slug': slug,
    'language': italian ? 'it' : 'en',
    'text': italian ? 'Citazione $slug.' : 'Quote $slug.',
    if (italian) 'originalText': 'Original quote $slug.',
    'author': 'Satoshi Nakamoto',
    'date': '2008-10-31',
    'sourceTitle': 'Source of quote $slug',
    'sourceUrl': 'https://example.com/quote-$slug',
    'topics': <Object?>[],
    'related': [relatedId],
    'updatedAt': '2026-10-01T00:00:00Z',
  };
}

Map<String, Object?> _work(int index) {
  return {
    'id': 'library.work-$index',
    'slug': 'work-$index',
    'language': 'en',
    'title': 'Work $index',
    'author': 'Author $index',
    'year': 1990,
    'summary': 'Summary $index.',
    'introduction': 'Introduction $index.',
    'originalLanguage': 'en',
    'kind': 'paper',
    'topics': <Object?>[],
    'url': 'https://example.com/work-$index',
    'licenseNote': 'Linked, not reproduced',
    'sources': <Object?>[],
    'related': <Object?>[],
    'updatedAt': '2026-10-01T00:00:00Z',
  };
}
