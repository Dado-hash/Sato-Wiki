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
    expect(bundle.version, '2026.05.26');
    expect(
      bundle.wiki.single.contentFor(ReadingLevel.base).bodyMarkdown,
      contains('history costly to rewrite'),
    );
    expect(
      bundle.wiki.single.coverImage,
      Uri.parse('media/wiki/proof-of-work/pow-mining-loop.svg'),
    );
    expect(bundle.news.single.author.github, 'andreas-m');
    expect(bundle.history.single.date, DateTime(2010, 5, 22));
    expect(bundle.bips.single.status, BipStatus.active);
    expect(bundle.changelogs.single.importance, ReleaseImportance.major);
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
