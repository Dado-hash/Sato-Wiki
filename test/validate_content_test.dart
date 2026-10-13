import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/validate_content.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('validate_content_test');
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  String writeBundle(Map<String, Object?> bundle) {
    final file = File('${tempDir.path}/bundle.json')
      ..writeAsStringSync(jsonEncode(bundle));

    return file.path;
  }

  test('valid bundle passes without warnings', () {
    final path = writeBundle(
      _bundle(
        wiki: [
          _wikiRecord(related: ['wiki.beta']),
          _wikiRecord(id: 'wiki.beta'),
        ],
        bips: [_bipRecord()],
        changelogs: [_releaseRecord()],
      ),
    );

    final result = validateContentBundle(path);

    expect(result.errors, isEmpty);
    expect(result.warnings, isEmpty);
    expect(result.failsWith(strict: true), isFalse);
    expect(result.summary, startsWith('valid 2026.06.20.000001 language=en'));
  });

  test('dangling related id fails', () {
    final path = writeBundle(
      _bundle(
        wiki: [
          _wikiRecord(related: ['wiki.missing']),
        ],
      ),
    );

    final result = validateContentBundle(path);

    expect(result.errors, hasLength(1));
    expect(result.errors.single, contains('wiki.missing'));
    expect(result.failsWith(strict: false), isTrue);
    expect(result.summary, isNotNull);
  });

  test('BIP related id to a missing BIP fails', () {
    final path = writeBundle(
      _bundle(
        bips: [
          _bipRecord(id: 'code.bip.1', related: ['bip.2']),
        ],
      ),
    );

    final result = validateContentBundle(path);

    expect(result.errors, hasLength(1));
    expect(result.errors.single, contains('related id bip.2'));
  });

  test('BIP with two status tags fails', () {
    final path = writeBundle(
      _bundle(
        bips: [
          _bipRecord(status: 'closed', tags: ['BIP', 'Draft', 'Closed']),
        ],
      ),
    );

    final result = validateContentBundle(path);

    expect(result.errors, hasLength(1));
    expect(result.errors.single, contains('more than one status tag'));
    expect(result.failsWith(strict: false), isTrue);
  });

  test('BIP status tag contradicting status fails', () {
    final path = writeBundle(
      _bundle(
        bips: [
          _bipRecord(status: 'closed', tags: ['BIP', 'Deployed']),
        ],
      ),
    );

    final result = validateContentBundle(path);

    expect(result.errors, hasLength(1));
    expect(result.errors.single, contains('contradicts'));
    expect(result.failsWith(strict: false), isTrue);
  });

  test('needsReview record warns and passes unless strict', () {
    final path = writeBundle(
      _bundle(
        changelogs: [
          _releaseRecord(automation: {'needsReview': true}),
        ],
      ),
    );

    final result = validateContentBundle(path);

    expect(result.errors, isEmpty);
    expect(result.warnings, hasLength(1));
    expect(result.warnings.single, contains('needsReview'));
    expect(result.failsWith(strict: false), isFalse);
    expect(result.failsWith(strict: true), isTrue);
  });

  test('placeholder text warns', () {
    final path = writeBundle(
      _bundle(
        changelogs: [
          _releaseRecord(
            userImpact:
                'Draft generated from official release notes. '
                'Requires review.',
          ),
        ],
      ),
    );

    final result = validateContentBundle(path);

    expect(result.errors, isEmpty);
    expect(result.warnings, hasLength(1));
    expect(result.warnings.single, contains('placeholder'));
  });

  test('wiki subcategory and reviewedAt validate without warnings', () {
    final path = writeBundle(
      _bundle(
        wiki: [
          _wikiRecord()
            ..['category'] = 'software'
            ..['subcategory'] = 'software-wallets'
            ..['reviewedAt'] = '2026-05-01',
        ],
        bips: [_bipRecord()..['reviewedAt'] = '2026-06-02T10:30:00Z'],
      ),
    );

    final result = validateContentBundle(path);

    expect(result.errors, isEmpty);
    expect(result.warnings, isEmpty);
  });

  test('software and hardware wiki without subcategory warn', () {
    final path = writeBundle(
      _bundle(
        wiki: [
          _wikiRecord()..['category'] = 'software',
          _wikiRecord(id: 'wiki.beta')..['category'] = 'Hardware',
          _wikiRecord(id: 'wiki.gamma')..['category'] = 'protocol',
        ],
      ),
    );

    final result = validateContentBundle(path);

    expect(result.errors, isEmpty);
    expect(result.warnings, hasLength(2));
    expect(result.warnings[0], contains('wiki wiki.alpha'));
    expect(result.warnings[0], contains('no subcategory'));
    expect(result.warnings[1], contains('wiki wiki.beta'));
    expect(result.failsWith(strict: false), isFalse);
    expect(result.failsWith(strict: true), isTrue);
  });

  test('non-string subcategory fails', () {
    final path = writeBundle(
      _bundle(
        wiki: [
          _wikiRecord()
            ..['category'] = 'software'
            ..['subcategory'] = 3,
        ],
      ),
    );

    final result = validateContentBundle(path);

    expect(result.errors, hasLength(1));
    expect(result.errors.single, contains('subcategory must be a string'));
    expect(result.failsWith(strict: false), isTrue);
  });

  test('malformed reviewedAt fails', () {
    final path = writeBundle(
      _bundle(bips: [_bipRecord()..['reviewedAt'] = 'not a date']),
    );

    final result = validateContentBundle(path);

    expect(result.errors, hasLength(1));
    expect(result.errors.single, contains('reviewedAt must be an ISO date'));
    expect(result.failsWith(strict: false), isTrue);
  });

  test('all optional collections together validate without warnings', () {
    final path = writeBundle(
      _bundle(
        wiki: [
          _wikiRecord(related: ['glossary.utxo']),
        ],
        glossary: [_glossaryRecord()],
        references: [
          _referenceRecord(
            rows: [
              {
                'cells': {'size': '250 vB', 'fee': '2500 sat'},
                'link': 'quote.genesis',
              },
            ],
          ),
        ],
        quotes: [_quoteRecord()],
        paths: [
          _pathRecord(stepIds: ['wiki.alpha', 'product.sparrow-wallet']),
        ],
        products: [_productRecord()],
      ),
    );

    final result = validateContentBundle(path, today: _validationDay);

    expect(result.errors, isEmpty);
    expect(result.warnings, isEmpty);
    expect(
      result.summary,
      contains('glossary=1 references=1 quotes=1 paths=1 products=1'),
    );
  });

  group('glossary', () {
    test('valid glossary term can be a related target', () {
      final path = writeBundle(
        _bundle(
          wiki: [
            _wikiRecord(related: ['glossary.utxo']),
          ],
          glossary: [_glossaryRecord()],
        ),
      );

      final result = validateContentBundle(path);

      expect(result.errors, isEmpty);
      expect(result.warnings, isEmpty);
      expect(result.summary, contains('glossary=1'));
    });

    test('glossary id without the glossary prefix fails', () {
      final path = writeBundle(
        _bundle(glossary: [_glossaryRecord(id: 'wiki.utxo')]),
      );

      final result = validateContentBundle(path);

      expect(result.errors, hasLength(1));
      expect(result.errors.single, contains('must start with glossary.'));
      expect(result.failsWith(strict: false), isTrue);
    });

    test('duplicate id across the bundle fails', () {
      final path = writeBundle(
        _bundle(glossary: [_glossaryRecord(), _glossaryRecord()]),
      );

      final result = validateContentBundle(path);
      expect(result.errors, hasLength(1));
      expect(result.errors.single, contains('duplicate id'));
    });

    test('malformed reviewedAt on a glossary term fails', () {
      final path = writeBundle(
        _bundle(glossary: [_glossaryRecord(reviewedAt: 'not a date')]),
      );

      final result = validateContentBundle(path);

      expect(result.errors.single, contains('reviewedAt must be an ISO date'));
    });
  });

  group('products', () {
    test('recent product with documented subcategory passes', () {
      final path = writeBundle(_bundle(products: [_productRecord()]));

      final result = validateContentBundle(path, today: _validationDay);

      expect(result.errors, isEmpty);
      expect(result.warnings, isEmpty);
      expect(result.summary, contains('products=1'));
    });

    test('product without reviewedAt fails', () {
      final path = writeBundle(
        _bundle(products: [_productRecord(reviewedAt: null)]),
      );

      final result = validateContentBundle(path, today: _validationDay);

      expect(result.errors.single, contains('reviewedAt is required'));
    });

    test('review older than 365 days warns, exactly 365 does not', () {
      final stale = writeBundle(
        _bundle(products: [_productRecord(reviewedAt: '2025-10-11')]),
      );
      final staleResult = validateContentBundle(stale, today: _validationDay);
      expect(staleResult.errors, isEmpty);
      expect(staleResult.warnings.single, contains('365 days old'));

      final boundary = writeBundle(
        _bundle(products: [_productRecord(reviewedAt: '2025-10-13')]),
      );
      final boundaryResult = validateContentBundle(
        boundary,
        today: _validationDay,
      );
      expect(boundaryResult.warnings, isEmpty);
    });

    test('undocumented subcategory warns', () {
      final path = writeBundle(
        _bundle(products: [_productRecord(subcategory: 'wallets')]),
      );

      final result = validateContentBundle(path, today: _validationDay);

      expect(result.errors, isEmpty);
      expect(result.warnings.single, contains('subcategory wallets'));
      expect(result.failsWith(strict: false), isFalse);
      expect(result.failsWith(strict: true), isTrue);
    });

    test('website that is not an absolute http(s) URL fails', () {
      final path = writeBundle(
        _bundle(products: [_productRecord(website: 'javascript:alert(1)')]),
      );

      final result = validateContentBundle(path, today: _validationDay);

      expect(result.errors, hasLength(1));
      expect(result.errors.single, contains('website must be an absolute'));
    });

    test('id without the product prefix fails', () {
      final path = writeBundle(
        _bundle(products: [_productRecord(id: 'wiki.sparrow')]),
      );

      final result = validateContentBundle(path, today: _validationDay);

      expect(result.errors.single, contains('must start with product.'));
    });
  });

  group('paths', () {
    test('valid path with existing steps passes and is counted', () {
      final path = writeBundle(
        _bundle(
          wiki: [_wikiRecord()],
          paths: [
            _pathRecord(stepIds: ['wiki.alpha']),
          ],
        ),
      );

      final result = validateContentBundle(path);

      expect(result.errors, isEmpty);
      expect(result.warnings, isEmpty);
      expect(result.summary, contains('paths=1'));
    });

    test('step id matching no record fails', () {
      final path = writeBundle(
        _bundle(
          wiki: [_wikiRecord()],
          paths: [
            _pathRecord(stepIds: ['wiki.alpha', 'wiki.missing']),
          ],
        ),
      );

      final result = validateContentBundle(path);

      expect(result.errors, hasLength(1));
      expect(result.errors.single, contains('step id wiki.missing'));
    });

    test('id without the path prefix fails', () {
      final path = writeBundle(
        _bundle(
          wiki: [_wikiRecord()],
          paths: [_pathRecord(id: 'wiki.start')],
        ),
      );

      final result = validateContentBundle(path);

      expect(result.errors.single, contains('must start with path.'));
    });
  });

  group('quotes', () {
    test('valid quote passes and is counted in the summary', () {
      final path = writeBundle(_bundle(quotes: [_quoteRecord()]));

      final result = validateContentBundle(path);

      expect(result.errors, isEmpty);
      expect(result.warnings, isEmpty);
      expect(result.summary, contains('quotes=1'));
    });

    test('sourceUrl that is not http(s) fails', () {
      final path = writeBundle(
        _bundle(quotes: [_quoteRecord(sourceUrl: 'ftp://example.com/genesis')]),
      );

      final result = validateContentBundle(path);

      expect(result.errors, hasLength(1));
      expect(result.errors.single, contains('sourceUrl must be an absolute'));
    });

    test('id without the quote prefix fails', () {
      final path = writeBundle(
        _bundle(quotes: [_quoteRecord(id: 'wiki.genesis')]),
      );

      final result = validateContentBundle(path);

      expect(result.errors.single, contains('must start with quote.'));
    });
  });

  group('references', () {
    test('valid table with a row link and summary count', () {
      final path = writeBundle(
        _bundle(wiki: [_wikiRecord()], references: [_referenceRecord()]),
      );

      final result = validateContentBundle(path);

      expect(result.errors, isEmpty);
      expect(result.warnings, isEmpty);
      expect(result.summary, contains('references=1'));
    });

    test('row cell with an undeclared column key fails', () {
      final path = writeBundle(
        _bundle(
          wiki: [_wikiRecord()],
          references: [
            _referenceRecord(
              rows: [
                {
                  'cells': {'size': '250 vB', 'weight': '1 kg'},
                },
              ],
            ),
          ],
        ),
      );

      final result = validateContentBundle(path);

      expect(result.errors, hasLength(1));
      expect(result.errors.single, contains('weight is not a declared column'));
    });

    test('row link to a missing record fails', () {
      final path = writeBundle(
        _bundle(
          references: [
            _referenceRecord(
              rows: [
                {
                  'cells': {'size': '250 vB', 'fee': '1 sat'},
                  'link': 'wiki.missing',
                },
              ],
            ),
          ],
        ),
      );

      final result = validateContentBundle(path);

      expect(result.errors, hasLength(1));
      expect(result.errors.single, contains('wiki.missing matches no record'));
    });

    test('id without the reference prefix fails', () {
      final path = writeBundle(
        _bundle(
          wiki: [_wikiRecord()],
          references: [_referenceRecord(id: 'wiki.fees')],
        ),
      );

      final result = validateContentBundle(path);

      expect(result.errors.single, contains('must start with reference.'));
    });
  });

  test('missing bundle fails', () {
    final result = validateContentBundle('${tempDir.path}/absent.json');

    expect(result.errors.single, startsWith('Missing content bundle'));
    expect(result.summary, isNull);
  });

  test('English seed passes without strict', () {
    final result = validateContentBundle('assets/content/seed_bundle_en.json');

    expect(result.errors, isEmpty);
    expect(result.failsWith(strict: false), isFalse);
    expect(result.summary, isNotNull);
  });

  test('Italian seed passes without strict', () {
    final result = validateContentBundle('assets/content/seed_bundle_it.json');

    expect(result.errors, isEmpty);
    expect(result.failsWith(strict: false), isFalse);
    expect(result.summary, isNotNull);
  });
}

Map<String, Object?> _bundle({
  List<Map<String, Object?>> wiki = const [],
  List<Map<String, Object?>> bips = const [],
  List<Map<String, Object?>> changelogs = const [],
  List<Map<String, Object?>> glossary = const [],
  List<Map<String, Object?>> references = const [],
  List<Map<String, Object?>> quotes = const [],
  List<Map<String, Object?>> paths = const [],
  List<Map<String, Object?>> products = const [],
}) {
  return {
    'schemaVersion': 1,
    'version': '2026.06.20.000001',
    'language': 'en',
    'generatedAt': '2026-06-20T00:00:00Z',
    'wiki': wiki,
    'news': <Object?>[],
    'history': <Object?>[],
    'bips': bips,
    'changelogs': changelogs,
    'glossary': glossary,
    'references': references,
    'quotes': quotes,
    'paths': paths,
    'products': products,
  };
}

final _validationDay = DateTime.utc(2026, 10, 13);

Map<String, Object?> _productRecord({
  String id = 'product.sparrow-wallet',
  String subcategory = 'software-wallets',
  String website = 'https://sparrowwallet.com',
  String? reviewedAt = '2026-09-01',
}) {
  return {
    'id': id,
    'slug': 'sparrow-wallet',
    'language': 'en',
    'name': 'Sparrow Wallet',
    'summary': 'Desktop wallet.',
    'bodyMarkdown': 'Details.',
    'category': 'software',
    'subcategory': subcategory,
    'maker': 'Sparrow Developers',
    'website': website,
    'openSource': true,
    'status': 'active',
    if (reviewedAt != null) 'reviewedAt': reviewedAt,
    'sources': <Object?>[],
    'related': <Object?>[],
    'updatedAt': '2026-09-01T00:00:00Z',
  };
}

Map<String, Object?> _pathRecord({
  String id = 'path.start',
  List<Object?> stepIds = const ['wiki.alpha'],
}) {
  return {
    'id': id,
    'slug': 'start',
    'language': 'en',
    'title': 'Start',
    'description': 'Where to begin.',
    'estimatedMinutes': 10,
    'steps': [
      for (final stepId in stepIds) {'id': stepId, 'note': 'Read it.'},
    ],
    'updatedAt': '2026-06-20T00:00:00Z',
  };
}

Map<String, Object?> _quoteRecord({
  String id = 'quote.genesis',
  String sourceUrl = 'https://example.com/genesis',
}) {
  return {
    'id': id,
    'slug': 'genesis',
    'language': 'en',
    'text': 'The Times 03/Jan/2009 Chancellor on brink of second bailout.',
    'author': 'Satoshi Nakamoto',
    'date': '2009-01-03',
    'sourceTitle': 'Genesis block',
    'sourceUrl': sourceUrl,
    'topics': <Object?>['Genesis'],
    'related': <Object?>[],
    'updatedAt': '2026-06-20T00:00:00Z',
  };
}

Map<String, Object?> _referenceRecord({
  String id = 'reference.fees',
  List<Object?>? columns,
  List<Object?>? rows,
}) {
  return {
    'id': id,
    'slug': 'fees',
    'language': 'en',
    'title': 'Fees',
    'description': 'Fee examples.',
    'columns':
        columns ??
        [
          {'key': 'size', 'label': 'Size'},
          {'key': 'fee', 'label': 'Fee'},
        ],
    'rows':
        rows ??
        [
          {
            'cells': {'size': '250 vB', 'fee': '2500 sat'},
            'link': 'wiki.alpha',
          },
        ],
    'sources': <Object?>[],
    'related': <Object?>[],
    'updatedAt': '2026-06-20T00:00:00Z',
  };
}

Map<String, Object?> _glossaryRecord({
  String id = 'glossary.utxo',
  String? reviewedAt,
}) {
  return {
    'id': id,
    'slug': id.substring('glossary.'.length),
    'language': 'en',
    'term': 'UTXO',
    'definition': 'Unspent transaction output.',
    'aliases': <Object?>['UTXOs'],
    'related': <Object?>[],
    'updatedAt': '2026-06-20T00:00:00Z',
    if (reviewedAt != null) 'reviewedAt': reviewedAt,
  };
}

Map<String, Object?> _wikiRecord({
  String id = 'wiki.alpha',
  List<Object?> related = const [],
}) {
  const body = 'Body text.';

  return {
    'id': id,
    'slug': id.substring('wiki.'.length),
    'language': 'en',
    'category': 'protocol',
    'title': 'Alpha',
    'description': 'Alpha entry.',
    'readingLevels': {
      'base': {'bodyMarkdown': body},
      'medium': {'bodyMarkdown': body},
      'advanced': {'bodyMarkdown': body},
    },
    'difficulty': 'base',
    'readTimeMinutes': 2,
    'tags': ['Alpha'],
    'sources': <Object?>[],
    'related': related,
    'updatedAt': '2026-06-20T00:00:00Z',
  };
}

Map<String, Object?> _bipRecord({
  String id = 'code.bip.1',
  String status = 'closed',
  List<String> tags = const ['BIP', 'Closed'],
  List<Object?> related = const [],
}) {
  return {
    'id': id,
    'number': 1,
    'language': 'en',
    'title': 'Process',
    'summary': 'BIP process.',
    'status': status,
    'category': 'process',
    'authors': ['Alice'],
    'createdAt': '2011-09-19',
    'summaryMarkdown': 'The BIP process.',
    'impactMarkdown': 'No impact.',
    'officialUrl': 'https://example.com/bip-0001',
    'tags': tags,
    'sources': <Object?>[],
    'related': related,
    'statusHistory': <Object?>[],
    'updatedAt': '2026-06-20T00:00:00Z',
  };
}

Map<String, Object?> _releaseRecord({
  String userImpact = 'Reviewed summary of the release.',
  Map<String, Object?>? automation,
}) {
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
    'userImpactMarkdown': userImpact,
    'technicalChangesMarkdown': 'Technical changes.',
    'officialUrl': 'https://bitcoincore.org/en/releases/31.0/',
    'tags': <Object?>[],
    'sources': <Object?>[],
    'related': <Object?>[],
    'updatedAt': '2026-06-20T00:00:00Z',
    if (automation != null) 'automation': automation,
  };
}
