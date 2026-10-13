import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:sato_wiki/src/core/content/data/content_bundle_parser.dart';
import 'package:sato_wiki/src/core/content/domain/content_models.dart';
import 'package:sato_wiki/src/core/content/domain/content_store.dart';

void main() {
  ContentStore storeFrom(Map<String, Object?> extra) {
    final bundle = ContentBundleParser.parseJson(
      jsonEncode({
        'schemaVersion': 1,
        'version': '2026.06.20.000001',
        'language': 'en',
        'generatedAt': '2026-06-20T00:00:00Z',
        'wiki': <Object?>[],
        'news': <Object?>[],
        'history': <Object?>[],
        'bips': <Object?>[],
        'changelogs': <Object?>[],
        ...extra,
      }),
    ).bundle;

    return ContentStore(bundle);
  }

  Map<String, Object?> glossaryTerm(
    String slug, {
    String term = 'Term',
    List<String> aliases = const [],
  }) {
    return {
      'id': 'glossary.$slug',
      'slug': slug,
      'language': 'en',
      'term': term,
      'definition': 'Definition of $term.',
      'aliases': aliases,
      'related': <Object?>[],
      'updatedAt': '2026-06-20T00:00:00Z',
    };
  }

  Map<String, Object?> referenceTable(String slug) {
    return {
      'id': 'reference.$slug',
      'slug': slug,
      'language': 'en',
      'title': 'Table $slug',
      'description': 'Description.',
      'columns': [
        {'key': 'a', 'label': 'A'},
      ],
      'rows': <Object?>[],
      'sources': <Object?>[],
      'related': <Object?>[],
      'updatedAt': '2026-06-20T00:00:00Z',
    };
  }

  group('product store methods', () {
    Map<String, Object?> product(String slug, String subcategory) {
      return {
        'id': 'product.$slug',
        'slug': slug,
        'language': 'en',
        'name': slug,
        'summary': 'Summary.',
        'bodyMarkdown': 'Body.',
        'category': 'software',
        'subcategory': subcategory,
        'maker': 'Maker',
        'website': 'https://example.com/$slug',
        'openSource': false,
        'status': 'discontinued',
        'reviewedAt': '2026-06-01',
        'sources': <Object?>[],
        'related': <Object?>[],
        'updatedAt': '2026-06-20T00:00:00Z',
      };
    }

    final store = storeFrom({
      'products': [
        product('wallet-a', 'software-wallets'),
        product('node-b', 'nodes'),
        product('wallet-c', 'software-wallets'),
      ],
    });

    test('lists products and finds one by id', () async {
      expect(await store.listProducts(), hasLength(3));
      expect(
        (await store.findProductById('product.node-b'))?.status,
        ProductStatus.discontinued,
      );
      expect(await store.findProductById('product.none'), isNull);
    });

    test('filters products by subcategory', () async {
      final wallets = await store.listProductsBySubcategory('software-wallets');

      expect(wallets.map((product) => product.id), [
        'product.wallet-a',
        'product.wallet-c',
      ]);
      expect(await store.listProductsBySubcategory('lightning'), isEmpty);
    });
  });

  group('learning path store methods', () {
    final store = storeFrom({
      'paths': [
        {
          'id': 'path.start',
          'slug': 'start',
          'language': 'en',
          'title': 'Start here',
          'description': 'Where to begin.',
          'estimatedMinutes': 20,
          'steps': [
            {'id': 'wiki.alpha', 'note': 'Read first.'},
          ],
          'updatedAt': '2026-06-20T00:00:00Z',
        },
      ],
    });

    test('lists paths and finds one by id', () async {
      final paths = await store.listLearningPaths();

      expect(paths.single.steps.single.id, 'wiki.alpha');
      expect(
        (await store.findLearningPathById('path.start'))?.title,
        'Start here',
      );
      expect(await store.findLearningPathById('path.none'), isNull);
    });
  });

  group('quote store methods', () {
    final store = storeFrom({
      'quotes': [
        {
          'id': 'quote.genesis',
          'slug': 'genesis',
          'language': 'en',
          'text': 'Quote text.',
          'author': 'Satoshi Nakamoto',
          'date': '2009-01-03',
          'sourceTitle': 'Genesis block',
          'sourceUrl': 'https://example.com/genesis',
          'related': <Object?>[],
          'updatedAt': '2026-06-20T00:00:00Z',
        },
      ],
    });

    test('lists quotes and finds one by id', () async {
      expect(await store.listQuotes(), hasLength(1));
      expect(
        (await store.findQuoteById('quote.genesis'))?.author,
        'Satoshi Nakamoto',
      );
      expect(await store.findQuoteById('quote.none'), isNull);
    });
  });

  group('reference store methods', () {
    final store = storeFrom({
      'references': [referenceTable('fees'), referenceTable('sizes')],
    });

    test('lists tables and finds one by id', () async {
      expect(await store.listReferenceTables(), hasLength(2));
      expect(
        (await store.findReferenceTableById('reference.sizes'))?.title,
        'Table sizes',
      );
      expect(await store.findReferenceTableById('reference.none'), isNull);
    });
  });

  group('glossary store methods', () {
    final store = storeFrom({
      'glossary': [
        glossaryTerm('utxo', term: 'UTXO', aliases: ['Unspent output']),
        glossaryTerm('mempool', term: 'Mempool'),
      ],
    });

    test('lists all terms in bundle order', () async {
      final terms = await store.listGlossaryTerms();

      expect(terms.map((term) => term.id), [
        'glossary.utxo',
        'glossary.mempool',
      ]);
    });

    test('finds a term by id', () async {
      final term = await store.findGlossaryTermById('glossary.mempool');

      expect(term?.term, 'Mempool');
      expect(await store.findGlossaryTermById('glossary.missing'), isNull);
    });

    test('finds a term by its name or an alias, ignoring case', () async {
      expect((await store.findGlossaryTerm('utxo'))?.id, 'glossary.utxo');
      expect((await store.findGlossaryTerm('  MEMPOOL ')), isNotNull);
      expect(
        (await store.findGlossaryTerm('unspent OUTPUT'))?.id,
        'glossary.utxo',
      );
      expect(await store.findGlossaryTerm('wallet'), isNull);
    });

    test('empty collection gives empty lists and no matches', () async {
      final empty = storeFrom({});

      expect(await empty.listGlossaryTerms(), isEmpty);
      expect(await empty.findGlossaryTermById('glossary.utxo'), isNull);
      expect(await empty.findGlossaryTerm('utxo'), isNull);
    });
  });
}
