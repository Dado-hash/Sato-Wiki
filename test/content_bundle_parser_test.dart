import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:sato_wiki/src/core/content/data/content_bundle_errors.dart';
import 'package:sato_wiki/src/core/content/data/content_bundle_parser.dart';
import 'package:sato_wiki/src/core/content/domain/content_models.dart';
import 'package:sato_wiki/src/core/content/reading_level.dart';

void main() {
  test('parses seed content bundle fixture', () {
    final json = File('assets/content/seed_bundle_en.json').readAsStringSync();

    final result = ContentBundleParser.parseJson(json);
    final bundle = result.bundle;

    expect(result.warnings, isEmpty);
    expect(bundle.schemaVersion, 1);
    expect(bundle.version, matches(RegExp(r'^\d{4}\.\d{2}\.\d{2}\.\d{6}$')));
    final proofOfWork = bundle.wiki.firstWhere(
      (entry) => entry.id == 'wiki.proof-of-work',
    );
    expect(
      proofOfWork.contentFor(ReadingLevel.base).bodyMarkdown,
      contains('history costly to rewrite'),
    );
    expect(
      proofOfWork.coverImage,
      Uri.parse('media/wiki/proof-of-work/pow-mining-loop.svg'),
    );
    expect(bundle.news.single.author.github, 'andreas-m');
    expect(bundle.history.first.date, DateTime(1993, 3, 9));
    expect(bundle.bips, hasLength(greaterThanOrEqualTo(200)));
    expect(bundle.bips.first.number, 1);
    expect(bundle.bips.first.status, BipStatus.closed);
    expect(bundle.bips.first.category, 'process');
    expect(bundle.bips.first.language, 'en');
    expect(bundle.changelogs, isNotEmpty);
  });

  test('skips invalid section records as recoverable warnings', () {
    const json = '''
{
  "schemaVersion": 1,
  "version": "2026.05.25",
  "language": "en",
  "generatedAt": "2026-05-25T00:00:00Z",
  "wiki": [
    {"id": "wiki.invalid"}
  ],
  "news": [],
  "history": [],
  "bips": [],
  "changelogs": []
}
''';

    final result = ContentBundleParser.parseJson(json);

    expect(result.bundle.wiki, isEmpty);
    expect(result.warnings, hasLength(1));
    expect(result.warnings.single.path, 'wiki[0]');
    expect(result.warnings.single.message, contains('must be'));
  });

  test('missing optional collections become empty with warning', () {
    const json = '''
{
  "version": "2026.05.25",
  "language": "en",
  "generatedAt": "2026-05-25T00:00:00Z",
  "wiki": [],
  "news": [],
  "history": [],
  "bips": []
}
''';

    final result = ContentBundleParser.parseJson(json);

    expect(result.bundle.schemaVersion, 1);
    expect(result.bundle.changelogs, isEmpty);
    expect(
      result.warnings.map((warning) => warning.path),
      containsAll(['schemaVersion', 'changelogs']),
    );
  });

  test('parses official BIP statuses and legacy aliases', () {
    expect(BipStatus.fromJson('draft'), BipStatus.draft);
    expect(BipStatus.fromJson('proposed'), BipStatus.draft);
    expect(BipStatus.fromJson('complete'), BipStatus.complete);
    expect(BipStatus.fromJson('final'), BipStatus.complete);
    expect(BipStatus.fromJson('deployed'), BipStatus.deployed);
    expect(BipStatus.fromJson('active'), BipStatus.deployed);
    expect(BipStatus.fromJson('closed'), BipStatus.closed);
    expect(BipStatus.fromJson('withdrawn'), BipStatus.closed);
    expect(BipStatus.fromJson('rejected'), BipStatus.closed);
    expect(BipStatus.fromJson('unknown'), isNull);
  });

  test('reads optional subcategory and reviewedAt when present', () {
    final result = ContentBundleParser.parseJson(
      _bundleJson(
        wiki: [_wikiRecord(subcategory: ' nodes ', reviewedAt: '2026-05-01')],
        bips: [_bipRecord(reviewedAt: '2026-06-02T10:30:00Z')],
      ),
    );

    expect(result.warnings, isEmpty);
    final wiki = result.bundle.wiki.single;
    expect(wiki.subcategory, 'nodes');
    expect(wiki.reviewedAt, DateTime.parse('2026-05-01'));
    expect(
      result.bundle.bips.single.reviewedAt,
      DateTime.parse('2026-06-02T10:30:00Z'),
    );
  });

  test('missing, null or blank optional fields give null', () {
    final result = ContentBundleParser.parseJson(
      _bundleJson(
        wiki: [
          _wikiRecord(),
          _wikiRecord(id: 'wiki.blank', subcategory: '   '),
          _wikiRecord(id: 'wiki.null', subcategory: null, reviewedAt: null),
        ],
      ),
    );

    expect(result.warnings, isEmpty);
    for (final entry in result.bundle.wiki) {
      expect(entry.subcategory, isNull);
      expect(entry.reviewedAt, isNull);
    }
  });

  test('old bundles without the new fields still parse', () {
    final result = ContentBundleParser.parseJson(
      _bundleJson(wiki: [_wikiRecord()]),
    );

    expect(result.warnings, isEmpty);
    expect(result.bundle.schemaVersion, 1);
    expect(result.bundle.wiki.single.subcategory, isNull);
    expect(result.bundle.wiki.single.reviewedAt, isNull);
  });

  test('non-string subcategory skips the wiki record with a warning', () {
    final result = ContentBundleParser.parseJson(
      _bundleJson(wiki: [_wikiRecord(subcategory: 7)]),
    );

    expect(result.bundle.wiki, isEmpty);
    expect(result.warnings, hasLength(1));
    expect(result.warnings.single.path, 'wiki[0]');
    expect(result.warnings.single.message, contains('subcategory'));
  });

  test('malformed reviewedAt skips the record with a warning', () {
    final result = ContentBundleParser.parseJson(
      _bundleJson(
        bips: [_bipRecord(reviewedAt: 'last spring')],
        changelogs: [_releaseRecord(reviewedAt: 20260501)],
      ),
    );

    expect(result.bundle.bips, isEmpty);
    expect(result.bundle.changelogs, isEmpty);
    expect(result.warnings.map((warning) => warning.path), [
      'bips[0]',
      'changelogs[0]',
    ]);
    expect(result.warnings.first.message, contains('reviewedAt'));
  });

  test('bundle without the optional collections parses with empty lists', () {
    final result = ContentBundleParser.parseJson(
      _bundleJson(wiki: [_wikiRecord()]),
    );

    expect(result.warnings, isEmpty);
    expect(result.bundle.glossary, isEmpty);
  });

  group('products', () {
    test('parses a product with optional fields and reviewedAt', () {
      final result = ContentBundleParser.parseJson(
        _bundleJson(
          products: [
            _productRecord(sourceUrl: 'https://github.com/sparrowwallet'),
          ],
        ),
      );

      expect(result.warnings, isEmpty);
      final product = result.bundle.products.single;
      expect(product.id, 'product.sparrow-wallet');
      expect(product.status, ProductStatus.active);
      expect(product.openSource, isTrue);
      expect(product.license, 'Apache-2.0');
      expect(product.platforms, ['macOS', 'Linux']);
      expect(product.website, Uri.parse('https://sparrowwallet.com'));
      expect(product.sourceUrl, Uri.parse('https://github.com/sparrowwallet'));
      expect(product.reviewedAt, DateTime.parse('2026-05-01'));
    });

    test('platforms, license and sourceUrl are optional', () {
      final record = _productRecord()
        ..remove('platforms')
        ..remove('license');
      final result = ContentBundleParser.parseJson(
        _bundleJson(products: [record]),
      );

      final product = result.bundle.products.single;
      expect(product.platforms, isEmpty);
      expect(product.license, isNull);
      expect(product.sourceUrl, isNull);
    });

    test('unknown status skips the product with a warning', () {
      final result = ContentBundleParser.parseJson(
        _bundleJson(products: [_productRecord(status: 'beta')]),
      );

      expect(result.bundle.products, isEmpty);
      expect(result.warnings.single.path, 'products[0]');
      expect(result.warnings.single.message, contains('status'));
    });

    test('missing reviewedAt skips the product with a warning', () {
      final result = ContentBundleParser.parseJson(
        _bundleJson(products: [_productRecord(reviewedAt: _absent)]),
      );

      expect(result.bundle.products, isEmpty);
      expect(
        result.warnings.single.message,
        contains('reviewedAt is required'),
      );
    });

    test('malformed reviewedAt and non-boolean openSource skip', () {
      final result = ContentBundleParser.parseJson(
        _bundleJson(
          products: [
            _productRecord(reviewedAt: 'spring'),
            _productRecord(openSource: 'yes'),
          ],
        ),
      );

      expect(result.bundle.products, isEmpty);
      expect(result.warnings.map((warning) => warning.path), [
        'products[0]',
        'products[1]',
      ]);
      expect(result.warnings.last.message, contains('openSource'));
    });
  });

  group('paths', () {
    test('parses ordered steps with notes', () {
      final result = ContentBundleParser.parseJson(
        _bundleJson(paths: [_pathRecord()]),
      );

      expect(result.warnings, isEmpty);
      final path = result.bundle.paths.single;
      expect(path.id, 'path.first-steps');
      expect(path.estimatedMinutes, 30);
      expect(path.steps.map((step) => step.id), [
        'wiki.alpha',
        'history.bitcoin-pizza-day',
      ]);
      expect(path.steps.first.note, 'Start with the basics.');
    });

    test('empty steps skip the path with a warning', () {
      final result = ContentBundleParser.parseJson(
        _bundleJson(paths: [_pathRecord(steps: <Object?>[])]),
      );

      expect(result.bundle.paths, isEmpty);
      expect(result.warnings.single.path, 'paths[0]');
      expect(result.warnings.single.message, contains('steps'));
    });

    test('non-integer estimatedMinutes skips the path', () {
      final result = ContentBundleParser.parseJson(
        _bundleJson(paths: [_pathRecord(estimatedMinutes: '30')]),
      );

      expect(result.bundle.paths, isEmpty);
      expect(result.warnings.single.message, contains('estimatedMinutes'));
    });
  });

  group('quotes', () {
    test('parses a translated quote with its English original', () {
      final result = ContentBundleParser.parseJson(
        _bundleJson(
          quotes: [
            _quoteRecord(originalText: 'Original text.', topics: ['Origins']),
          ],
        ),
      );

      expect(result.warnings, isEmpty);
      final quote = result.bundle.quotes.single;
      expect(quote.id, 'quote.satoshi-cpu');
      expect(quote.language, 'it');
      expect(quote.originalText, 'Original text.');
      expect(quote.date, DateTime.parse('2009-01-09'));
      expect(quote.sourceUrl, Uri.parse('https://example.com/paper.pdf'));
      expect(quote.topics, ['Origins']);
    });

    test('originalText and topics are optional', () {
      final result = ContentBundleParser.parseJson(
        _bundleJson(quotes: [_quoteRecord()]),
      );

      final quote = result.bundle.quotes.single;
      expect(quote.originalText, isNull);
      expect(quote.topics, isEmpty);
      expect(result.warnings, isEmpty);
    });

    test('missing sourceUrl or a relative one skips the quote', () {
      final result = ContentBundleParser.parseJson(
        _bundleJson(
          quotes: [
            _quoteRecord(sourceUrl: _absent),
            _quoteRecord(sourceUrl: 'paper.pdf'),
          ],
        ),
      );

      expect(result.bundle.quotes, isEmpty);
      expect(result.warnings.map((warning) => warning.path), [
        'quotes[0]',
        'quotes[1]',
      ]);
      expect(result.warnings.first.message, contains('sourceUrl'));
    });
  });

  group('references', () {
    test('parses columns, rows with optional links and reviewedAt', () {
      final result = ContentBundleParser.parseJson(
        _bundleJson(references: [_referenceRecord(reviewedAt: '2026-05-01')]),
      );

      expect(result.warnings, isEmpty);
      final table = result.bundle.references.single;
      expect(table.id, 'reference.compact-targets');
      expect(table.columns.map((column) => column.key), ['bits', 'meaning']);
      expect(table.columns.first.label, 'Bits');
      expect(table.rows, hasLength(2));
      expect(table.rows.first.cells['meaning'], 'Genesis target');
      expect(table.rows.first.link, 'wiki.alpha');
      expect(table.rows.last.link, isNull);
      expect(table.reviewedAt, DateTime.parse('2026-05-01'));
    });

    test('empty columns skip the table with a warning', () {
      final result = ContentBundleParser.parseJson(
        _bundleJson(references: [_referenceRecord(columns: <Object?>[])]),
      );

      expect(result.bundle.references, isEmpty);
      expect(result.warnings.single.path, 'references[0]');
      expect(result.warnings.single.message, contains('columns'));
    });

    test('a row whose cells are not strings skips the table', () {
      final result = ContentBundleParser.parseJson(
        _bundleJson(
          references: [
            _referenceRecord(
              rows: [
                {
                  'cells': {'bits': 7},
                },
              ],
            ),
          ],
        ),
      );

      expect(result.bundle.references, isEmpty);
      expect(result.warnings.single.path, 'references[0]');
      expect(result.warnings.single.message, contains('cells.bits'));
    });

    test('a row without cells skips the table', () {
      final result = ContentBundleParser.parseJson(
        _bundleJson(
          references: [
            _referenceRecord(
              rows: [
                {'link': 'wiki.alpha'},
              ],
            ),
          ],
        ),
      );

      expect(result.bundle.references, isEmpty);
      expect(result.warnings.single.message, contains('cells'));
    });
  });

  group('glossary', () {
    test('parses terms with aliases, related links and reviewedAt', () {
      final result = ContentBundleParser.parseJson(
        _bundleJson(
          glossary: [
            _glossaryRecord(
              aliases: ['UTXOs'],
              related: [
                'wiki.alpha',
                {'id': 'wiki.alpha', 'title': 'Alpha'},
              ],
              reviewedAt: '2026-05-01',
            ),
          ],
        ),
      );

      expect(result.warnings, isEmpty);
      final term = result.bundle.glossary.single;
      expect(term.id, 'glossary.utxo');
      expect(term.slug, 'utxo');
      expect(term.language, 'en');
      expect(term.term, 'UTXO');
      expect(term.definition, 'Unspent transaction output.');
      expect(term.aliases, ['UTXOs']);
      expect(term.related.map((link) => link.id), ['wiki.alpha', 'wiki.alpha']);
      expect(term.related.last.title, 'Alpha');
      expect(term.reviewedAt, DateTime.parse('2026-05-01'));
    });

    test('aliases, related and reviewedAt default when absent', () {
      final result = ContentBundleParser.parseJson(
        _bundleJson(glossary: [_glossaryRecord()]),
      );

      final term = result.bundle.glossary.single;
      expect(term.aliases, isEmpty);
      expect(term.related, isEmpty);
      expect(term.reviewedAt, isNull);
      expect(result.warnings, isEmpty);
    });

    test('unknown extra fields are ignored', () {
      final record = _glossaryRecord()..['futureField'] = {'x': 1};
      final result = ContentBundleParser.parseJson(
        _bundleJson(glossary: [record]),
      );

      expect(result.bundle.glossary, hasLength(1));
      expect(result.warnings, isEmpty);
    });

    test('malformed term is skipped with a warning like other records', () {
      final broken = _glossaryRecord(id: 'glossary.broken')..remove('term');
      final result = ContentBundleParser.parseJson(
        _bundleJson(glossary: [broken, _glossaryRecord()]),
      );

      expect(result.bundle.glossary.map((term) => term.id), ['glossary.utxo']);
      expect(result.warnings.single.path, 'glossary[0]');
      expect(result.warnings.single.message, contains('term'));
    });

    test('malformed reviewedAt and non-object records are skipped', () {
      final result = ContentBundleParser.parseJson(
        _bundleJson(
          glossary: [
            _glossaryRecord(reviewedAt: 'last spring'),
            'not an object',
          ],
        ),
      );

      expect(result.bundle.glossary, isEmpty);
      expect(result.warnings.map((warning) => warning.path), [
        'glossary[0]',
        'glossary[1]',
      ]);
    });

    test('a collection that is not a list gives a warning', () {
      final result = ContentBundleParser.parseJson(
        _bundleJson(glossary: 'nope'),
      );

      expect(result.bundle.glossary, isEmpty);
      expect(result.warnings.single.path, 'glossary');
    });
  });

  group('library', () {
    test('parses a work with its optional fields', () {
      final result = ContentBundleParser.parseJson(
        _bundleJson(library: [_libraryRecord()]),
      );

      expect(result.warnings, isEmpty);
      final work = result.bundle.library.single;
      expect(work.id, 'library.blind-signatures');
      expect(work.title, 'Blind Signatures for Untraceable Payments');
      expect(work.year, 1982);
      expect(work.url, Uri.parse('https://example.com/chaum-1982'));
      expect(work.archiveUrl, isNotNull);
      expect(work.topics, ['cryptography', 'digital cash']);
      expect(work.related.single.id, 'history.hashcash');
      expect(work.reviewedAt, DateTime(2026, 6, 20));
      expect(work.language, 'en');
    });

    test('an unknown kind is kept as it is', () {
      final result = ContentBundleParser.parseJson(
        _bundleJson(library: [_libraryRecord(kind: 'thread')]),
      );

      expect(result.warnings, isEmpty);
      expect(result.bundle.library.single.kind, 'thread');
    });

    test('bundle without the library key has an empty list', () {
      final result = ContentBundleParser.parseJson(_bundleJson());

      expect(result.warnings, isEmpty);
      expect(result.bundle.library, isEmpty);
    });

    test('a record without licenseNote is skipped with a warning', () {
      final result = ContentBundleParser.parseJson(
        _bundleJson(library: [_libraryRecord(licenseNote: null)]),
      );

      expect(result.bundle.library, isEmpty);
      expect(result.warnings.single.path, contains('library'));
    });

    test('a non-integer year is skipped with a warning', () {
      final result = ContentBundleParser.parseJson(
        _bundleJson(library: [_libraryRecord(year: '1982')]),
      );

      expect(result.bundle.library, isEmpty);
      expect(result.warnings.single.message, contains('year'));
    });

    test('a relative url is skipped with a warning', () {
      final result = ContentBundleParser.parseJson(
        _bundleJson(library: [_libraryRecord(url: 'chaum-1982')]),
      );

      expect(result.bundle.library, isEmpty);
      expect(result.warnings.single.message, contains('url'));
    });
  });

  test('unsupported future schema is fatal', () {
    const json = '''
{
  "schemaVersion": 99,
  "version": "2026.05.25",
  "language": "en",
  "generatedAt": "2026-05-25T00:00:00Z",
  "wiki": [],
  "news": [],
  "history": [],
  "bips": [],
  "changelogs": []
}
''';

    expect(
      () => ContentBundleParser.parseJson(json),
      throwsA(isA<ContentBundleParseException>()),
    );
  });
}

String _bundleJson({
  List<Map<String, Object?>> wiki = const [],
  List<Map<String, Object?>> bips = const [],
  List<Map<String, Object?>> changelogs = const [],
  Object? glossary,
  Object? references,
  Object? quotes,
  Object? paths,
  Object? products,
  Object? library,
}) {
  return jsonEncode({
    'schemaVersion': 1,
    'version': '2026.05.25',
    'language': 'en',
    'generatedAt': '2026-05-25T00:00:00Z',
    'wiki': wiki,
    'news': <Object?>[],
    'history': <Object?>[],
    'bips': bips,
    'changelogs': changelogs,
    if (glossary != null) 'glossary': glossary,
    if (references != null) 'references': references,
    if (quotes != null) 'quotes': quotes,
    if (paths != null) 'paths': paths,
    if (products != null) 'products': products,
    if (library != null) 'library': library,
  });
}

Map<String, Object?> _libraryRecord({
  String id = 'library.blind-signatures',
  Object? year = 1982,
  Object? url = 'https://example.com/chaum-1982',
  Object? licenseNote = 'No license stated; linked, not reproduced',
  Object? kind = 'paper',
}) {
  return {
    'id': id,
    'slug': 'blind-signatures',
    'title': 'Blind Signatures for Untraceable Payments',
    'author': 'David Chaum',
    'year': year,
    'summary': 'The paper that introduced blind signatures for payments.',
    'introduction': 'Our introduction.',
    'originalLanguage': 'en',
    'kind': kind,
    'topics': <Object?>['cryptography', 'digital cash'],
    'url': url,
    'archiveUrl': 'https://web.archive.org/web/2026/https://example.com/chaum',
    'licenseNote': licenseNote,
    'sources': <Object?>[],
    'related': <Object?>['history.hashcash'],
    'updatedAt': '2026-06-20T00:00:00Z',
    'reviewedAt': '2026-06-20',
  };
}

Map<String, Object?> _productRecord({
  Object? status = 'active',
  Object? reviewedAt = '2026-05-01',
  Object? openSource = true,
  Object? sourceUrl = _absent,
}) {
  return {
    'id': 'product.sparrow-wallet',
    'slug': 'sparrow-wallet',
    'language': 'en',
    'name': 'Sparrow Wallet',
    'summary': 'Desktop wallet.',
    'bodyMarkdown': 'Details.',
    'category': 'software',
    'subcategory': 'software-wallets',
    'maker': 'Sparrow Developers',
    'website': 'https://sparrowwallet.com',
    if (sourceUrl != _absent) 'sourceUrl': sourceUrl,
    'openSource': openSource,
    'license': 'Apache-2.0',
    'platforms': <Object?>['macOS', 'Linux'],
    'status': status,
    if (reviewedAt != _absent) 'reviewedAt': reviewedAt,
    'sources': <Object?>[],
    'related': <Object?>[],
    'updatedAt': '2026-05-25T00:00:00Z',
  };
}

Map<String, Object?> _pathRecord({
  Object? steps = _absent,
  Object? estimatedMinutes = 30,
}) {
  return {
    'id': 'path.first-steps',
    'slug': 'first-steps',
    'language': 'en',
    'title': 'First steps',
    'description': 'A short tour.',
    'estimatedMinutes': estimatedMinutes,
    'steps': steps == _absent
        ? [
            {'id': 'wiki.alpha', 'note': 'Start with the basics.'},
            {'id': 'history.bitcoin-pizza-day', 'note': 'Then the history.'},
          ]
        : steps,
    'updatedAt': '2026-05-25T00:00:00Z',
  };
}

Map<String, Object?> _quoteRecord({
  Object? sourceUrl = 'https://example.com/paper.pdf',
  Object? originalText = _absent,
  Object? topics = _absent,
}) {
  return {
    'id': 'quote.satoshi-cpu',
    'slug': 'satoshi-cpu',
    'language': 'it',
    'text': 'Testo tradotto.',
    if (originalText != _absent) 'originalText': originalText,
    'author': 'Satoshi Nakamoto',
    'date': '2009-01-09',
    'sourceTitle': 'Bitcoin v0.1 release',
    if (sourceUrl != _absent) 'sourceUrl': sourceUrl,
    if (topics != _absent) 'topics': topics,
    'related': <Object?>[],
    'updatedAt': '2026-05-25T00:00:00Z',
  };
}

Map<String, Object?> _referenceRecord({
  Object? columns = _absent,
  Object? rows = _absent,
  Object? reviewedAt = _absent,
}) {
  return {
    'id': 'reference.compact-targets',
    'slug': 'compact-targets',
    'language': 'en',
    'title': 'Compact targets',
    'description': 'Examples of compact target encodings.',
    'columns': columns == _absent
        ? [
            {'key': 'bits', 'label': 'Bits'},
            {'key': 'meaning', 'label': 'Meaning'},
          ]
        : columns,
    'rows': rows == _absent
        ? [
            {
              'cells': {'bits': '0x1d00ffff', 'meaning': 'Genesis target'},
              'link': 'wiki.alpha',
            },
            {
              'cells': {'bits': '0x17034219', 'meaning': 'Current era'},
            },
          ]
        : rows,
    'sources': <Object?>[],
    'related': <Object?>[],
    'updatedAt': '2026-05-25T00:00:00Z',
    if (reviewedAt != _absent) 'reviewedAt': reviewedAt,
  };
}

Map<String, Object?> _glossaryRecord({
  String id = 'glossary.utxo',
  String term = 'UTXO',
  Object? aliases = _absent,
  Object? related = _absent,
  Object? reviewedAt = _absent,
}) {
  return {
    'id': id,
    'slug': id.substring('glossary.'.length),
    'language': 'en',
    'term': term,
    'definition': 'Unspent transaction output.',
    if (aliases != _absent) 'aliases': aliases,
    if (related != _absent) 'related': related,
    'updatedAt': '2026-05-25T00:00:00Z',
    if (reviewedAt != _absent) 'reviewedAt': reviewedAt,
  };
}

Map<String, Object?> _wikiRecord({
  String id = 'wiki.alpha',
  Object? subcategory = _absent,
  Object? reviewedAt = _absent,
}) {
  const body = 'Body text.';

  return {
    'id': id,
    'slug': id.substring('wiki.'.length),
    'language': 'en',
    'category': 'software',
    'title': 'Alpha',
    'description': 'Alpha entry.',
    'readingLevels': {
      'base': {'bodyMarkdown': body},
      'medium': {'bodyMarkdown': body},
      'advanced': {'bodyMarkdown': body},
    },
    'difficulty': 'base',
    'readTimeMinutes': 2,
    'tags': <Object?>[],
    'sources': <Object?>[],
    'related': <Object?>[],
    'updatedAt': '2026-05-25T00:00:00Z',
    if (subcategory != _absent) 'subcategory': subcategory,
    if (reviewedAt != _absent) 'reviewedAt': reviewedAt,
  };
}

Map<String, Object?> _bipRecord({Object? reviewedAt = _absent}) {
  return {
    'id': 'code.bip.1',
    'number': 1,
    'language': 'en',
    'title': 'Process',
    'summary': 'BIP process.',
    'status': 'closed',
    'category': 'process',
    'authors': <Object?>['Alice'],
    'createdAt': '2011-09-19',
    'summaryMarkdown': 'The BIP process.',
    'impactMarkdown': 'No impact.',
    'officialUrl': 'https://example.com/bip-0001',
    'tags': <Object?>['BIP', 'Closed'],
    'sources': <Object?>[],
    'related': <Object?>[],
    'statusHistory': <Object?>[],
    'updatedAt': '2026-05-25T00:00:00Z',
    if (reviewedAt != _absent) 'reviewedAt': reviewedAt,
  };
}

Map<String, Object?> _releaseRecord({Object? reviewedAt = _absent}) {
  return {
    'id': 'release.bitcoin-core.31.0',
    'slug': 'bitcoin-core-31-0',
    'language': 'en',
    'project': 'bitcoin-core',
    'version': '31.0',
    'title': 'Bitcoin Core 31.0',
    'summary': 'Bitcoin Core 31.0 release notes.',
    'releasedAt': '2026-04-20',
    'importance': 'major',
    'userImpactMarkdown': 'Impact.',
    'technicalChangesMarkdown': 'Technical changes.',
    'officialUrl': 'https://bitcoincore.org/en/releases/31.0/',
    'tags': <Object?>[],
    'sources': <Object?>[],
    'related': <Object?>[],
    'updatedAt': '2026-05-25T00:00:00Z',
    if (reviewedAt != _absent) 'reviewedAt': reviewedAt,
  };
}

const _absent = Object();
