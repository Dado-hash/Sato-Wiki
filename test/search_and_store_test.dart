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

    expect(events.single.title, 'Bitcoin Pizza Day');
    expect(onPizzaDay.single.slug, 'bitcoin-pizza-day');
  });

  test('store filters BIPs by status', () async {
    final active = await store.listBipsByStatus(BipStatus.active);

    expect(active.single.number, 341);
  });

  test('search matches title tags and summary with section filter', () {
    final taproot = index.search('taproot', sections: {SearchSection.code});
    final mining = index.search('mining');

    expect(taproot.first.route, '/code/bips/341');
    expect(mining.first.route, '/wiki/entries/mining');
  });
}
