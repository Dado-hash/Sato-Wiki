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

    expect(events.first.title, 'Bitcoin Whitepaper Published');
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
