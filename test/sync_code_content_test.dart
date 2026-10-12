import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/sync_code_content.dart';

final _runTime = DateTime.utc(2026, 10, 1, 12);
final _laterRunTime = DateTime.utc(2026, 10, 2, 12);

void main() {
  setUp(setUpBundleDirectory);
  tearDown(() => _tempDir.deleteSync(recursive: true));

  group('BipPreambleParser', () {
    test('parses MediaWiki preamble with continued authors', () {
      const source = '''
BIP: 341
      Layer: Consensus (soft fork)
      Title: Taproot: SegWit version 1 spending rules
      Authors: Pieter Wuille
               Jonas Nick
               Anthony Towns
      Status: Deployed
      Type: Specification
      Assigned: 2020-01-19
      License: BSD-3-Clause
==Introduction==
Body.
''';

      final preamble = BipPreambleParser.parse(source);
      final bip = SourceBip.fromPreamble(
        fileName: 'bip-0341.mediawiki',
        sha: 'abc123',
        preamble: preamble,
      );

      expect(bip.number, 341);
      expect(bip.title, 'Taproot: SegWit version 1 spending rules');
      expect(bip.status, 'deployed');
      expect(bip.category, 'consensus');
      expect(bip.authors, ['Pieter Wuille', 'Jonas Nick', 'Anthony Towns']);
      expect(bip.assignedAt, '2020-01-19');
    });

    test('parses Markdown fenced preamble', () {
      const source = '''
```
BIP: 3
Title: Updated BIP Process
Authors: Murch
Status: Complete
Type: Process
Assigned: 2025-01-09
```

## Abstract
Body.
''';

      final preamble = BipPreambleParser.parse(source);
      final bip = SourceBip.fromPreamble(
        fileName: 'bip-0003.md',
        sha: 'def456',
        preamble: preamble,
      );

      expect(bip.number, 3);
      expect(bip.status, 'complete');
      expect(bip.category, 'process');
      expect(bip.authors, ['Murch']);
    });

    test('keeps an unknown status as written instead of throwing', () {
      final bip = SourceBip.fromPreamble(
        fileName: 'bip-0999.mediawiki',
        sha: 'ghi789',
        preamble: const {'BIP': '999', 'Status': 'Experimental'},
      );

      expect(bip.status, 'Experimental');
      expect(bipStatusOrNull(bip.status), isNull);
    });
  });

  test('normalizes official and legacy BIP statuses', () {
    expect(normalizeBipStatus('Draft'), 'draft');
    expect(normalizeBipStatus('Proposed'), 'draft');
    expect(normalizeBipStatus('Complete'), 'complete');
    expect(normalizeBipStatus('Final'), 'complete');
    expect(normalizeBipStatus('Deployed'), 'deployed');
    expect(normalizeBipStatus('Active'), 'deployed');
    expect(normalizeBipStatus('Closed'), 'closed');
    expect(normalizeBipStatus('Withdrawn'), 'closed');
    expect(normalizeBipStatus('Rejected'), 'closed');
    expect(() => normalizeBipStatus('Experimental'), throwsFormatException);
  });

  test('parses Bitcoin Core release note metadata', () {
    const releaseNotes = '''
v30.0 Release Notes
===================

Bitcoin Core version v30.0 is now available from:

Notable changes
===============

Policy
------
- Relay policy changed.
''';

    final release = BitcoinCoreReleaseNoteParser.parse(
      version: '30.0',
      fileName: 'release-notes-30.0.md',
      sha: 'release-sha',
      releaseNotesMarkdown: releaseNotes,
      releasedAt: '2025-10-11',
    );

    expect(release.version, '30.0');
    expect(release.importance, 'major');
    expect(release.releasedAt, '2025-10-11');
    expect(release.officialUrl, 'https://bitcoincore.org/en/releases/30.0/');
    expect(release.releaseNotesMarkdown, contains('Relay policy changed'));
  });

  test('classifies release importance from the version number', () {
    const expectedImportance = {
      '30.0': 'major',
      '30.0.0': 'major',
      '30.1': 'minor',
      '29.3': 'minor',
      '28.4': 'minor',
      '27.0.1': 'patch',
      '30.1.1': 'patch',
    };

    for (final entry in expectedImportance.entries) {
      final release = BitcoinCoreReleaseNoteParser.parse(
        version: entry.key,
        fileName: 'release-notes-${entry.key}.md',
        sha: 'sha-${entry.key}',
        releaseNotesMarkdown: 'Notes',
        releasedAt: null,
      );
      expect(release.importance, entry.value, reason: entry.key);
    }
  });

  group('Gemini draft parsing', () {
    test('parses structured response JSON', () {
      final response = jsonEncode({
        'candidates': [
          {
            'content': {
              'parts': [
                {
                  'text': jsonEncode({
                    'summary': 'Short summary.',
                    'summaryMarkdown': 'Readable BIP summary.',
                    'impactMarkdown': 'Practical impact.',
                    'userImpactMarkdown': 'User impact.',
                    'technicalChangesMarkdown': 'Technical changes.',
                  }),
                },
              ],
            },
          },
        ],
      });

      final draft = GeminiCodeContentDraftClient.parseResponse(
        response,
        model: 'gemini-3.1-flash-lite',
      );

      expect(draft.summary, 'Short summary.');
      expect(draft.model, 'gemini-3.1-flash-lite');
    });

    test('rejects incomplete structured response JSON', () {
      final response = jsonEncode({
        'candidates': [
          {
            'content': {
              'parts': [
                {
                  'text': jsonEncode({
                    'summary': 'Short summary.',
                    'summaryMarkdown': 'Readable BIP summary.',
                  }),
                },
              ],
            },
          },
        ],
      });

      expect(
        () => GeminiCodeContentDraftClient.parseResponse(
          response,
          model: 'gemini-3.1-flash-lite',
        ),
        throwsFormatException,
      );
    });
  });

  group('retry policy', () {
    test('retries transient errors with exponential backoff', () async {
      final delays = <Duration>[];
      var calls = 0;

      final result = await retryWithBackoff(
        () async {
          calls += 1;
          if (calls < 3) throw TimeoutException('slow');
          return 'ok';
        },
        sleep: (delay) async => delays.add(delay),
        shouldRetry: isRetryableSyncError,
      );

      expect(result, 'ok');
      expect(calls, 3);
      expect(delays, [const Duration(seconds: 2), const Duration(seconds: 4)]);
    });

    test('gives up after the last attempt', () async {
      final delays = <Duration>[];
      var calls = 0;

      await expectLater(
        retryWithBackoff(
          () async {
            calls += 1;
            throw SocketException('reset');
          },
          sleep: (delay) async => delays.add(delay),
          shouldRetry: isRetryableSyncError,
        ),
        throwsA(isA<SocketException>()),
      );

      expect(calls, 3);
      expect(delays, hasLength(2));
    });

    test('does not retry client errors other than 429', () async {
      final delays = <Duration>[];
      var calls = 0;

      await expectLater(
        retryWithBackoff(
          () async {
            calls += 1;
            throw const CodeSyncHttpException(
              statusCode: 404,
              message: 'not found',
            );
          },
          sleep: (delay) async => delays.add(delay),
          shouldRetry: isRetryableSyncError,
        ),
        throwsA(isA<CodeSyncHttpException>()),
      );

      expect(calls, 1);
      expect(delays, isEmpty);
    });

    test('classifies retryable errors', () {
      final retryable = <Object>[
        const CodeSyncHttpException(statusCode: 429, message: 'rate limited'),
        const CodeSyncHttpException(statusCode: 500, message: 'server'),
        const CodeSyncHttpException(statusCode: 503, message: 'unavailable'),
        TimeoutException('slow'),
        SocketException('reset'),
      ];
      for (final error in retryable) {
        expect(isRetryableSyncError(error), isTrue, reason: '$error');
      }

      final notRetryable = <Object>[
        const CodeSyncHttpException(statusCode: 400, message: 'bad request'),
        const CodeSyncHttpException(statusCode: 404, message: 'not found'),
        FormatException('bad json'),
      ];
      for (final error in notRetryable) {
        expect(isRetryableSyncError(error), isFalse, reason: '$error');
      }
    });
  });

  group('AI text preservation', () {
    test('keeps AI text when upstream is unchanged (aiModel)', () async {
      writeBundle(bips: [storedBip(aiModel: 'gemini')]);
      final draft = FakeDraftClient();

      await runSync(
        source: FakeSourceClient(bips: [sourceBip()]),
        draft: draft,
      );

      final bip = findById(readBundle(), 'bips', 'code.bip.341');
      expect(draft.bipCalls, 0);
      expect(bip['summary'], 'Stored short summary.');
      expect(bip['summaryMarkdown'], 'Stored summary.');
      expect(bip['impactMarkdown'], 'Stored impact.');
    });

    test('keeps AI text when upstream is unchanged (needsReview)', () async {
      writeBundle(bips: [storedBip(needsReview: true)]);
      final draft = FakeDraftClient();

      await runSync(
        source: FakeSourceClient(bips: [sourceBip()]),
        draft: draft,
      );

      final bip = findById(readBundle(), 'bips', 'code.bip.341');
      expect(draft.bipCalls, 0);
      expect(bip['summaryMarkdown'], 'Stored summary.');
    });

    test('drafts a record that still shows the placeholder text', () async {
      final placeholder = GeneratedDraft.bipFallback(sourceBip(), 'en');
      final stored = storedBip(needsReview: true)
        ..['summaryMarkdown'] = placeholder.summaryMarkdown;
      writeBundle(bips: [stored]);
      final draft = FakeDraftClient();

      await runSync(
        source: FakeSourceClient(bips: [sourceBip()]),
        draft: draft,
      );

      final bip = findById(readBundle(), 'bips', 'code.bip.341');
      expect(draft.bipCalls, 1);
      expect(bip['summaryMarkdown'], isNot(placeholder.summaryMarkdown));
    });

    test('replaces AI text with a new draft when upstream changed', () async {
      writeBundle(
        bips: [storedBip(aiModel: 'gemini', upstreamSha: 'sha-old')],
      );
      final draft = FakeDraftClient();

      await runSync(
        source: FakeSourceClient(bips: [sourceBip(sha: 'sha-new')]),
        draft: draft,
      );

      final bip = findById(readBundle(), 'bips', 'code.bip.341');
      expect(draft.bipCalls, 1);
      expect(bip['summaryMarkdown'], 'AI draft sha-new');
      expect(_automation(bip)['upstreamSha'], 'sha-new');
    });

    test('keeps reviewed text when upstream changed', () async {
      writeBundle(bips: [storedBip(upstreamSha: 'sha-old')]);
      final draft = FakeDraftClient();

      await runSync(
        source: FakeSourceClient(bips: [sourceBip(sha: 'sha-new')]),
        draft: draft,
      );

      final bip = findById(readBundle(), 'bips', 'code.bip.341');
      expect(draft.bipCalls, 0);
      expect(bip['summaryMarkdown'], 'Stored summary.');
    });

    test('uses the fallback only when text is missing or blank', () async {
      final bip = storedBip(aiModel: 'gemini')
        ..['summaryMarkdown'] = '   '
        ..remove('impactMarkdown');
      writeBundle(bips: [bip]);

      await runSync(
        source: FakeSourceClient(bips: [sourceBip()]),
        draft: NullCodeContentDraftClient(),
      );

      final fallback = GeneratedDraft.bipFallback(sourceBip(), 'en');
      final saved = findById(readBundle(), 'bips', 'code.bip.341');
      expect(saved['summaryMarkdown'], fallback.summaryMarkdown);
      expect(saved['impactMarkdown'], fallback.impactMarkdown);
    });

    test('keeps AI release text when upstream is unchanged', () async {
      writeBundle(bips: const [], changelogs: [storedRelease()]);
      final draft = FakeDraftClient();

      await runSync(
        source: FakeSourceClient(releases: [sourceRelease()]),
        draft: draft,
      );

      final release = findById(
        readBundle(),
        'changelogs',
        'release.bitcoin-core.30.1',
      );
      expect(draft.releaseCalls, 0);
      expect(release['summary'], 'Stored release summary.');
      expect(release['userImpactMarkdown'], 'Stored user impact.');
    });
  });

  group('incremental sync', () {
    test('a second run over unchanged upstream writes nothing', () async {
      writeBundle(bips: const [], changelogs: const []);
      final source = FakeSourceClient(
        bips: [sourceBip()],
        releases: [sourceRelease()],
      );
      final draft = FakeDraftClient();

      final first = await runSync(source: source, draft: draft);
      final firstText = readBundleText();
      final firstVersion = readBundle()['version'];

      final second = await runSync(
        source: source,
        draft: draft,
        now: _laterRunTime,
      );

      final secondReport = second.languages.single;
      expect(first.languages.single.changed, isTrue);
      expect(secondReport.changed, isFalse);
      expect(secondReport.changedItems, isEmpty);
      expect(readBundle()['version'], firstVersion);
      expect(readBundleText(), firstText);
      expect(draft.bipCalls, 1);
      expect(draft.releaseCalls, 1);
    });

    test('updatedAt moves only for records that really changed', () async {
      writeBundle(bips: const [], changelogs: const []);
      final draft = FakeDraftClient();
      await runSync(
        source: FakeSourceClient(
          bips: [sourceBip()],
          releases: [sourceRelease()],
        ),
        draft: draft,
      );

      final report = await runSync(
        source: FakeSourceClient(
          bips: [sourceBip(status: 'closed')],
          releases: [sourceRelease()],
        ),
        draft: draft,
        now: _laterRunTime,
      );

      final bundle = readBundle();
      final bip = findById(bundle, 'bips', 'code.bip.341');
      final release = findById(
        bundle,
        'changelogs',
        'release.bitcoin-core.30.1',
      );
      expect(report.languages.single.changedItems, ['BIP 341: Taproot']);
      expect(bip['updatedAt'], _laterRunTime.toIso8601String());
      expect(release['updatedAt'], _runTime.toIso8601String());
    });
  });

  group('status tags', () {
    test(
      'removes the previous status tag when the BIP status changes',
      () async {
        writeBundle(
          bips: [
            storedBip(
              tags: const ['BIP', 'Consensus', 'Draft', 'Custom'],
              upstreamSha: 'sha-bip-1',
            ),
          ],
        );

        await runSync(
          source: FakeSourceClient(bips: [sourceBip(status: 'closed')]),
          draft: NullCodeContentDraftClient(),
        );

        final bip = findById(readBundle(), 'bips', 'code.bip.341');
        expect(bip['tags'], ['BIP', 'Consensus', 'Custom', 'Closed']);
        expect(bip['status'], 'closed');
      },
    );
  });

  group('unknown BIP status', () {
    test('keeps the existing record and skips the new one', () async {
      writeBundle(bips: [storedBip()]);

      final report = await runSync(
        source: FakeSourceClient(
          bips: [
            sourceBip(status: 'Experimental'),
            sourceBip(number: 342, status: 'Experimental'),
            sourceBip(number: 343),
          ],
        ),
        draft: FakeDraftClient(),
      );

      final bips = readBundle()['bips']! as List<Object?>;
      final ids = bips.cast<JsonMap>().map((bip) => bip['id']);
      final warnings = report.languages.single.warnings;

      expect(ids, ['code.bip.341', 'code.bip.343']);
      expect(findById(readBundle(), 'bips', 'code.bip.341'), storedBip());
      expect(warnings, hasLength(2));
      expect(warnings.first, contains('kept unchanged'));
      expect(warnings.last, contains('skipped'));
      expect(report.toMarkdown(), contains('BIP 342'));
    });
  });

  group('draft failures', () {
    test(
      'new record gets placeholder text and retries on the next run',
      () async {
        writeBundle(bips: const []);
        final failing = FakeDraftClient(
          failure: const CodeSyncHttpException(
            statusCode: 503,
            message: 'unavailable',
          ),
        );

        final first = await runSync(
          source: FakeSourceClient(bips: [sourceBip()]),
          draft: failing,
        );

        final placeholder = GeneratedDraft.bipFallback(sourceBip(), 'en');
        final saved = findById(readBundle(), 'bips', 'code.bip.341');
        expect(saved['summaryMarkdown'], placeholder.summaryMarkdown);
        expect(_automation(saved)['needsReview'], isTrue);
        expect(_automation(saved).containsKey('upstreamSha'), isFalse);
        expect(
          first.languages.single.warnings.single,
          contains('AI draft failed'),
        );

        final working = FakeDraftClient();
        await runSync(
          source: FakeSourceClient(bips: [sourceBip()]),
          draft: working,
        );

        final retried = findById(readBundle(), 'bips', 'code.bip.341');
        expect(working.bipCalls, 1);
        expect(retried['summaryMarkdown'], 'AI draft sha-bip-1');
        expect(_automation(retried)['upstreamSha'], 'sha-bip-1');
      },
    );

    test('existing AI record keeps its text and upstream SHA', () async {
      writeBundle(
        bips: [storedBip(aiModel: 'gemini', upstreamSha: 'sha-old')],
      );

      final report = await runSync(
        source: FakeSourceClient(bips: [sourceBip(sha: 'sha-new')]),
        draft: FakeDraftClient(
          failure: const CodeSyncHttpException(
            statusCode: 500,
            message: 'server error',
          ),
        ),
      );

      final bip = findById(readBundle(), 'bips', 'code.bip.341');
      expect(bip['summaryMarkdown'], 'Stored summary.');
      expect(_automation(bip)['upstreamSha'], 'sha-old');
      expect(
        report.languages.single.warnings.single,
        contains('current text kept'),
      );
    });
  });
}

final class FakeSourceClient implements CodeSourceClient {
  const FakeSourceClient({this.bips = const [], this.releases = const []});

  final List<SourceBip> bips;
  final List<SourceRelease> releases;

  @override
  Future<List<SourceBip>> fetchBips() async => bips;

  @override
  Future<List<SourceRelease>> fetchBitcoinCoreReleases({
    required int limit,
  }) async {
    return releases.take(limit).toList(growable: false);
  }
}

final class FakeDraftClient implements CodeContentDraftClient {
  FakeDraftClient({this.failure});

  final Object? failure;
  int bipCalls = 0;
  int releaseCalls = 0;

  @override
  Future<GeneratedDraft?> generateBipDraft(
    SourceBip source,
    String language,
  ) async {
    bipCalls += 1;
    _throwIfConfigured();
    return _draft(source.sha);
  }

  @override
  Future<GeneratedDraft?> generateReleaseDraft(
    SourceRelease source,
    String language,
  ) async {
    releaseCalls += 1;
    _throwIfConfigured();
    return _draft(source.sha);
  }

  void _throwIfConfigured() {
    final error = failure;
    if (error != null) throw error;
  }

  static GeneratedDraft _draft(String sha) {
    return GeneratedDraft(
      summary: 'AI summary $sha',
      summaryMarkdown: 'AI draft $sha',
      impactMarkdown: 'AI impact $sha',
      userImpactMarkdown: 'AI user impact $sha',
      technicalChangesMarkdown: 'AI technical $sha',
      model: 'fake-model',
    );
  }
}

SourceBip sourceBip({
  int number = 341,
  String sha = 'sha-bip-1',
  String status = 'draft',
}) {
  final fileName = 'bip-${number.toString().padLeft(4, '0')}.mediawiki';
  return SourceBip(
    number: number,
    fileName: fileName,
    sha: sha,
    title: 'Taproot',
    status: status,
    category: 'consensus',
    authors: const ['Pieter Wuille'],
    assignedAt: '2020-01-19',
    officialUrl: 'https://github.com/bitcoin/bips/blob/master/$fileName',
    rawTextExcerpt: 'BIP: $number',
  );
}

SourceRelease sourceRelease({
  String version = '30.1',
  String sha = 'sha-rel-1',
}) {
  return SourceRelease(
    version: version,
    fileName: 'release-notes-$version.md',
    sha: sha,
    releasedAt: '2025-10-11',
    importance: 'minor',
    officialUrl: 'https://bitcoincore.org/en/releases/$version/',
    releaseNotesUrl:
        'https://github.com/bitcoin/bitcoin/blob/master/doc/release-notes/release-notes-$version.md',
    releaseNotesMarkdown: 'Notes for $version',
  );
}

/// A BIP record as stored in a bundle. Pass [upstreamSha] null to omit it.
JsonMap storedBip({
  String? upstreamSha = 'sha-bip-1',
  bool needsReview = false,
  String? aiModel,
  List<String> tags = const ['BIP', 'Consensus', 'Draft'],
  String status = 'draft',
}) {
  return {
    'id': 'code.bip.341',
    'number': 341,
    'language': 'en',
    'title': 'Taproot',
    'summary': 'Stored short summary.',
    'summaryMarkdown': 'Stored summary.',
    'impactMarkdown': 'Stored impact.',
    'status': status,
    'category': 'consensus',
    'authors': ['Pieter Wuille'],
    'createdAt': '2020-01-19',
    'officialUrl':
        'https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki',
    'tags': tags,
    'sources': [
      {
        'title': 'BIP 341',
        'url': 'https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki',
        'author': 'Bitcoin BIPs',
      },
    ],
    'related': <Object?>[],
    'statusHistory': <Object?>[],
    'updatedAt': '2026-01-01T00:00:00.000Z',
    'automation': {
      'source': 'sync_code_content.dart',
      if (upstreamSha != null) 'upstreamSha': upstreamSha,
      if (aiModel != null) 'aiModel': aiModel,
      'needsReview': needsReview,
    },
  };
}

/// A release record as stored in a bundle, with AI-managed text.
JsonMap storedRelease() {
  return {
    'id': 'release.bitcoin-core.30.1',
    'slug': 'bitcoin-core-30-1',
    'language': 'en',
    'project': 'bitcoin-core',
    'version': '30.1',
    'title': 'Bitcoin Core 30.1',
    'summary': 'Stored release summary.',
    'releasedAt': '2025-10-11',
    'importance': 'minor',
    'userImpactMarkdown': 'Stored user impact.',
    'technicalChangesMarkdown': 'Stored technical changes.',
    'officialUrl': 'https://bitcoincore.org/en/releases/30.1/',
    'tags': ['Bitcoin Core', 'Release'],
    'sources': [
      {
        'title': 'Bitcoin Core 30.1 release notes',
        'url':
            'https://github.com/bitcoin/bitcoin/blob/master/doc/release-notes/release-notes-30.1.md',
        'author': 'Bitcoin Core',
      },
    ],
    'related': <Object?>[],
    'updatedAt': '2026-01-01T00:00:00.000Z',
    'automation': {
      'source': 'sync_code_content.dart',
      'upstreamSha': 'sha-rel-1',
      'aiModel': 'gemini',
      'needsReview': true,
    },
  };
}

late Directory _tempDir;

void setUpBundleDirectory() {
  _tempDir = Directory.systemTemp.createTempSync('sync_code_content_test_');
}

File get _bundleFile => File('${_tempDir.path}/seed_bundle_en.json');

void writeBundle({
  required List<JsonMap> bips,
  List<JsonMap> changelogs = const [],
}) {
  _bundleFile.writeAsStringSync(
    jsonEncode({
      'version': 'seed-version',
      'generatedAt': '2026-01-01T00:00:00.000Z',
      'bips': bips,
      'changelogs': changelogs,
    }),
  );
}

String readBundleText() => _bundleFile.readAsStringSync();

JsonMap readBundle() => jsonDecode(readBundleText()) as JsonMap;

JsonMap findById(JsonMap bundle, String listKey, String id) {
  final items = (bundle[listKey]! as List<Object?>).cast<JsonMap>();
  return items.firstWhere((item) => item['id'] == id);
}

JsonMap _automation(JsonMap record) => record['automation']! as JsonMap;

Future<CodeSyncReport> runSync({
  required CodeSourceClient source,
  required CodeContentDraftClient draft,
  DateTime? now,
}) {
  return CodeContentSync(
    options: const SyncCodeContentOptions(
      languages: ['en'],
      maxReleases: 12,
      skipAi: false,
      dryRun: false,
      verbose: false,
      reportPath: null,
    ),
    sourceClient: source,
    draftClient: draft,
    now: now ?? _runTime,
    bundleDirectory: _tempDir.path,
  ).run();
}
