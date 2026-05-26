import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:sato_wiki/src/core/content/data/content_bundle_parser.dart';
import 'package:sato_wiki/src/core/content/domain/content_media.dart';

void main() {
  test('extracts media references from every markdown content type', () {
    final bundle = ContentBundleParser.parseJson(
      _bundleJson(
        wiki: '![Wiki diagram](media/wiki/entry/wiki.svg "Wiki caption")',
        news: '![News chart](media/news/chart.png)',
        history: '![History map](media/history/map.webp)',
        bipSummary: '![BIP summary](media/code/bip-summary.jpg)',
        bipImpact: '![BIP impact](media/code/bip-impact.jpeg)',
        releaseUserImpact: '![User impact](media/releases/user.png)',
        releaseTechnicalChanges:
            '![Technical changes](media/releases/technical.svg)',
      ),
    ).bundle;

    final references = ContentMedia.referencesFromBundle(bundle);

    expect(
      references.map((reference) => reference.source),
      containsAll([
        'media/wiki/entry/wiki.svg',
        'media/news/chart.png',
        'media/history/map.webp',
        'media/code/bip-summary.jpg',
        'media/code/bip-impact.jpeg',
        'media/releases/user.png',
        'media/releases/technical.svg',
      ]),
    );
    expect(references.first.alt, 'Wiki diagram');
    expect(references.first.title, 'Wiki caption');
  });

  test('validates inline image conventions', () {
    final errors = ContentMedia.validateReferences([
      const ContentMediaReference(source: 'media/wiki/ok.svg', alt: 'OK'),
      const ContentMediaReference(source: 'https://example.com/x.png', alt: ''),
      const ContentMediaReference(source: '../escape.png', alt: 'Escape'),
      const ContentMediaReference(source: 'media/wiki/file.gif', alt: 'GIF'),
    ]);

    expect(errors, hasLength(4));
    expect(
      errors.map((error) => error.message),
      containsAll([
        'Image alt text is required.',
        'Image source must be a relative media path.',
        'Image source must start with media/.',
        'Image extension must be one of .jpeg, .jpg, .png, .svg, .webp.',
      ]),
    );
  });
}

String _bundleJson({
  required String wiki,
  required String news,
  required String history,
  required String bipSummary,
  required String bipImpact,
  required String releaseUserImpact,
  required String releaseTechnicalChanges,
}) {
  final data = {
    'schemaVersion': 1,
    'version': '2026.05.25',
    'language': 'en',
    'generatedAt': '2026-05-25T00:00:00Z',
    'wiki': [
      {
        'id': 'wiki.inline-media',
        'slug': 'inline-media',
        'language': 'en',
        'category': 'protocol',
        'title': 'Inline Media',
        'description': 'Inline media test.',
        'readingLevels': {
          'base': {'bodyMarkdown': wiki},
          'medium': {'bodyMarkdown': 'Medium.'},
          'advanced': {'bodyMarkdown': 'Advanced.'},
        },
        'difficulty': 'base',
        'readTimeMinutes': 1,
        'tags': [],
        'sources': [],
        'related': [],
        'updatedAt': '2026-05-25T00:00:00Z',
      },
    ],
    'news': [
      {
        'id': 'news.inline-media',
        'slug': 'inline-media',
        'language': 'en',
        'title': 'Inline Media',
        'summary': 'Inline media test.',
        'category': 'protocol',
        'author': {'displayName': 'Author'},
        'publishedAt': '2026-05-25',
        'readTimeMinutes': 1,
        'bodyMarkdown': news,
        'tags': [],
        'sources': [],
        'related': [],
        'updatedAt': '2026-05-25T00:00:00Z',
      },
    ],
    'history': [
      {
        'id': 'history.inline-media',
        'slug': 'inline-media',
        'language': 'en',
        'date': '2026-05-25',
        'title': 'Inline Media',
        'category': 'protocol',
        'summary': 'Inline media test.',
        'bodyMarkdown': history,
        'tags': [],
        'sources': [],
        'related': [],
        'updatedAt': '2026-05-25T00:00:00Z',
      },
    ],
    'bips': [
      {
        'id': 'code.bip.1',
        'number': 1,
        'language': 'en',
        'title': 'Inline Media',
        'summary': 'Inline media test.',
        'status': 'draft',
        'category': 'process',
        'authors': ['Author'],
        'createdAt': '2026-05-25',
        'summaryMarkdown': bipSummary,
        'impactMarkdown': bipImpact,
        'officialUrl': 'https://example.com/bip',
        'tags': [],
        'sources': [],
        'related': [],
        'statusHistory': [],
        'updatedAt': '2026-05-25T00:00:00Z',
      },
    ],
    'changelogs': [
      {
        'id': 'release.inline-media.1',
        'slug': 'inline-media-1',
        'language': 'en',
        'project': 'inline-media',
        'version': '1.0',
        'title': 'Inline Media',
        'summary': 'Inline media test.',
        'releasedAt': '2026-05-25',
        'importance': 'minor',
        'userImpactMarkdown': releaseUserImpact,
        'technicalChangesMarkdown': releaseTechnicalChanges,
        'officialUrl': 'https://example.com/release',
        'tags': [],
        'sources': [],
        'related': [],
        'updatedAt': '2026-05-25T00:00:00Z',
      },
    ],
  };

  return jsonEncode(data);
}
