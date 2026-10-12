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
