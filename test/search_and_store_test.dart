import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:sato_wiki/src/core/content/data/content_bundle_parser.dart';
import 'package:sato_wiki/src/core/content/domain/content_models.dart';
import 'package:sato_wiki/src/core/content/domain/content_store.dart';
import 'package:sato_wiki/src/core/search/search_index.dart';

void main() {
  late ContentStore store;
  late SearchIndex index;

  setUpAll(() {
    final json = File('assets/content/seed_bundle_en.json').readAsStringSync();
    final bundle = ContentBundleParser.parseJson(json).bundle;
    store = ContentStore(bundle);
    index = SearchIndex.fromBundle(bundle);
  });

  test('store sorts timeline and finds on-this-day events', () async {
    final events = await store.listEvents();
    final onPizzaDay = await store.listEventsOnMonthDay(5, 22);

    expect(events.first.title, 'Cypherpunk\'s Manifesto Published');
    expect(onPizzaDay.single.slug, 'bitcoin-pizza-day');
  });

  test('store filters BIPs by status', () async {
    final codeBundle = ContentBundleParser.parseJson(_codeFixtureJson).bundle;
    final codeStore = ContentStore(codeBundle);
    final active = await codeStore.listBipsByStatus(BipStatus.deployed);

    expect(active.single.number, 341);
  });

  test('search matches title tags and summary with section filter', () {
    final codeBundle = ContentBundleParser.parseJson(_codeFixtureJson).bundle;
    final codeIndex = SearchIndex.fromBundle(codeBundle);
    final taproot = codeIndex.search('taproot', sections: {SearchSection.code});
    final mining = index.search('mining');

    expect(taproot.first.route, '/code/bips/341');
    expect(mining.first.route, '/wiki/entries/mining-energy-economics');
  });

  group('search ranking', () {
    late SearchIndex fixture;

    setUpAll(() {
      fixture = SearchIndex.fromBundle(_searchFixtureBundle());
    });

    test('folds accents and case', () {
      expect(_titles(fixture.search('perche')), ['Perché usare il Bitcoin']);
      expect(_titles(fixture.search('PERCHÉ')), ['Perché usare il Bitcoin']);
    });

    test('requires every token and treats dashes as spaces', () {
      expect(_titles(fixture.search('proof work')), ['Proof-of-work basics']);
      expect(fixture.search('proof signature'), isEmpty);
    });

    test('ranks whole-title matches first', () {
      final results = _titles(fixture.search('mining pool'));

      expect(results, ['Mining pool basics', 'Pool of mining']);
    });

    test('orders ties by title then id and is stable across calls', () {
      final first = fixture.search('mining', sections: {SearchSection.wiki});
      final second = fixture.search('mining', sections: {SearchSection.wiki});

      // Whole-title matches score 16 and sort by title; the summary-only
      // match in "Pool of mining" scores lower and comes last.
      expect(_titles(first), [
        'Mining alpha',
        'Mining beta',
        'Mining beta',
        'Mining pool basics',
        'Pool of mining',
      ]);
      expect(first.map((r) => r.id).toList(), [
        'wiki.alpha',
        'wiki.beta-a',
        'wiki.beta-b',
        'wiki.pool-title',
        'wiki.pool-summary',
      ]);
      expect(first.map((r) => r.id).toList(), second.map((r) => r.id).toList());
    });

    test('empty and punctuation-only queries return nothing', () {
      expect(fixture.search('   '), isEmpty);
      expect(fixture.search('---'), isEmpty);
    });
  });
}

List<String> _titles(List<SearchResult> results) =>
    results.map((result) => result.title).toList();

ContentBundle _searchFixtureBundle() {
  Map<String, Object?> entry(
    String id,
    String title, {
    String summary = 'Summary.',
  }) {
    const body = {'bodyMarkdown': 'Body.'};

    return {
      'id': id,
      'slug': id.substring('wiki.'.length),
      'language': 'en',
      'category': 'protocol',
      'title': title,
      'description': summary,
      'readingLevels': {'base': body, 'medium': body, 'advanced': body},
      'difficulty': 'base',
      'readTimeMinutes': 2,
      'tags': <String>[],
      'sources': <Object?>[],
      'related': <Object?>[],
      'updatedAt': '2026-05-25T00:00:00Z',
    };
  }

  final json = jsonEncode({
    'schemaVersion': 1,
    'version': 'test',
    'language': 'en',
    'generatedAt': '2026-05-25T00:00:00Z',
    'wiki': [
      entry('wiki.perche', 'Perché usare il Bitcoin'),
      entry('wiki.pow', 'Proof-of-work basics'),
      entry('wiki.pool-title', 'Mining pool basics'),
      entry('wiki.pool-summary', 'Pool of mining'),
      entry('wiki.beta-b', 'Mining beta'),
      entry('wiki.beta-a', 'Mining beta'),
      entry('wiki.alpha', 'Mining alpha'),
    ],
    'news': <Object?>[],
    'history': <Object?>[],
    'bips': <Object?>[],
    'changelogs': <Object?>[],
  });

  return ContentBundleParser.parseJson(json).bundle;
}

const _codeFixtureJson = '''
{
  "schemaVersion": 1,
  "version": "test",
  "language": "en",
  "generatedAt": "2026-05-25T00:00:00Z",
  "wiki": [],
  "news": [],
  "history": [],
  "bips": [
    {
      "id": "code.bip.341",
      "number": 341,
      "language": "en",
      "title": "Taproot",
      "summary": "SegWit version 1 spending rules.",
      "status": "deployed",
      "category": "consensus",
      "authors": ["Pieter Wuille"],
      "createdAt": "2020-01-19",
      "summaryMarkdown": "Summary.",
      "impactMarkdown": "Impact.",
      "officialUrl": "https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki",
      "tags": ["Taproot"],
      "sources": [],
      "related": [],
      "statusHistory": [],
      "updatedAt": "2026-05-25T00:00:00Z"
    }
  ],
  "changelogs": []
}
''';
