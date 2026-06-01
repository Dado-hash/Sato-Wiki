import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import '../tool/sync_code_content.dart';

void main() {
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
        model: 'gemini-3.1-flash-lite-preview',
      );

      expect(draft.summary, 'Short summary.');
      expect(draft.model, 'gemini-3.1-flash-lite-preview');
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
          model: 'gemini-3.1-flash-lite-preview',
        ),
        throwsFormatException,
      );
    });
  });
}
