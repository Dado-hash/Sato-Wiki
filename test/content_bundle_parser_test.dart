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
    expect(bundle.history.first.date, DateTime(2008, 10, 31));
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
  });
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
