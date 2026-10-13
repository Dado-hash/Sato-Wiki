import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sato_wiki/src/core/search/search_index.dart';
import 'package:sato_wiki/src/core/settings/app_settings_controller.dart';
import 'package:sato_wiki/src/core/settings/app_settings_repository.dart';
import 'package:sato_wiki/src/core/settings/app_settings_scope.dart';
import 'package:sato_wiki/src/features/learn/presentation/glossary_screens.dart';
import 'package:sato_wiki/src/features/learn/presentation/library_work_screen.dart';
import 'package:sato_wiki/src/features/search/presentation/search_screen.dart';
import 'package:sato_wiki/src/features/settings/presentation/bookmarks_screen.dart';
import 'package:sato_wiki/src/features/wiki/presentation/product_screen.dart';

import 'library_test_support.dart';

void main() {
  final store = libraryFixtureStore();
  final index = SearchIndex.fromBundle(store.bundle);

  group('search index covers the new collections', () {
    test('finds a glossary term by its term', () {
      final results = index.search('nonce');

      expect(results.first.id, 'glossary.nonce');
      expect(results.first.route, '/glossary/nonce');
      expect(results.first.section, SearchSection.glossary);
    });

    test('finds a glossary term by an alias', () {
      final results = index.search('unspent');

      expect(results.single.id, 'glossary.utxo');
      expect(results.single.route, '/glossary/utxo');
    });

    test('finds a product by its maker', () {
      final results = index.search('acme labs');

      expect(results.single.id, 'product.acme-node');
      expect(results.single.route, '/products/acme-node');
      expect(results.single.section, SearchSection.product);
    });

    test('finds a reference table by its title', () {
      final results = index.search('fee table');

      expect(results.single.id, 'reference.fees');
      expect(results.single.route, '/code/references/fees');
      expect(results.single.section, SearchSection.reference);
    });

    test('finds a library work by its author', () {
      final results = index.search('nakamoto');

      expect(results.single.id, 'library.bitcoin-whitepaper');
      expect(results.single.route, '/library/bitcoin-whitepaper');
      expect(results.single.section, SearchSection.library);
    });

    test('section filter limits results to the new type', () {
      final results = index.search('nonce', sections: {SearchSection.glossary});
      expect(results.map((result) => result.id), ['glossary.nonce']);

      expect(index.search('nonce', sections: {SearchSection.wiki}), isEmpty);
    });

    test('long body text is not indexed', () {
      // Library introductions and product bodies are not searched.
      expect(index.search('introduction'), isEmpty);
    });
  });

  group('search screen', () {
    testWidgets('a library result shows its type label and opens its route', (
      tester,
    ) async {
      await _pumpSearch(tester, index, query: 'nakamoto');

      expect(find.text('LIBRARY'), findsOneWidget);
      await tester.tap(
        find.text('Bitcoin: A Peer-to-Peer Electronic Cash System'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Opened /library/bitcoin-whitepaper'), findsOneWidget);
    });

    testWidgets('a glossary result shows the glossary label', (tester) async {
      await _pumpSearch(tester, index, query: 'nonce');

      expect(find.text('GLOSSARY'), findsOneWidget);
    });

    testWidgets('a product result shows its label and opens its route', (
      tester,
    ) async {
      await _pumpSearch(tester, index, query: 'acme');

      expect(find.text('PRODUCT'), findsOneWidget);
      await tester.tap(find.text('Acme Node'));
      await tester.pumpAndSettle();

      expect(find.text('Opened /products/acme-node'), findsOneWidget);
    });

    testWidgets('a reference result shows the reference label', (tester) async {
      await _pumpSearch(tester, index, query: 'fee table');

      expect(find.text('REFERENCE'), findsOneWidget);
    });

    testWidgets('type labels are localized in Italian', (tester) async {
      await _pumpSearch(
        tester,
        index,
        query: 'nonce',
        locale: const Locale('it'),
      );

      expect(find.text('GLOSSARIO'), findsOneWidget);
    });
  });

  group('bookmarks for the new record types', () {
    testWidgets('lists saved product, glossary, reference and library rows', (
      tester,
    ) async {
      final settings = await AppSettingsController.load(
        InMemoryAppSettingsRepository(),
      );
      await settings.toggleBookmark('product.acme-node');
      await settings.toggleBookmark('glossary.nonce');
      await settings.toggleBookmark('reference.fees');
      await settings.toggleBookmark('library.bitcoin-whitepaper');
      await settings.toggleBookmark('library.missing');

      await pumpLibraryScreen(
        tester,
        body: BookmarksScreen(store: store, settings: settings),
      );

      expect(find.text('Acme Node'), findsOneWidget);
      expect(find.text('PRODUCT'), findsOneWidget);
      expect(find.text('Nonce'), findsOneWidget);
      expect(find.text('GLOSSARY'), findsOneWidget);
      expect(find.text('Fee table'), findsOneWidget);
      expect(find.text('REFERENCE'), findsOneWidget);
      expect(
        find.text('Bitcoin: A Peer-to-Peer Electronic Cash System'),
        findsOneWidget,
      );
      expect(find.text('LIBRARY'), findsOneWidget);
      expect(find.byTooltip('Remove from bookmarks'), findsNWidgets(4));
    });

    testWidgets('tapping a saved library row opens its screen', (tester) async {
      final settings = await AppSettingsController.load(
        InMemoryAppSettingsRepository(),
      );
      await settings.toggleBookmark('library.cypherpunk-manifesto');

      await pumpLibraryScreen(
        tester,
        body: BookmarksScreen(store: store, settings: settings),
      );
      await tester.tap(find.text("A Cypherpunk's Manifesto"));
      await tester.pumpAndSettle();

      expect(find.text('Opened /library/cypherpunk-manifesto'), findsOneWidget);
    });

    testWidgets('library work saves its id from the bookmark button', (
      tester,
    ) async {
      final settings = await AppSettingsController.load(
        InMemoryAppSettingsRepository(),
      );

      await pumpLibraryScreen(
        tester,
        body: AppSettingsScope(
          controller: settings,
          child: LibraryWorkScreen(store: store, slug: 'bitcoin-whitepaper'),
        ),
      );
      await tester.tap(find.byTooltip('Save to bookmarks'));
      await tester.pumpAndSettle();

      expect(settings.isBookmarked('library.bitcoin-whitepaper'), isTrue);
      expect(find.byTooltip('Remove from bookmarks'), findsOneWidget);
    });

    testWidgets('product and glossary term screens save their ids', (
      tester,
    ) async {
      final settings = await AppSettingsController.load(
        InMemoryAppSettingsRepository(),
      );

      await pumpLibraryScreen(
        tester,
        body: AppSettingsScope(
          controller: settings,
          child: ProductScreen(store: store, slug: 'acme-node'),
        ),
      );
      await tester.tap(find.byTooltip('Save to bookmarks'));
      await tester.pumpAndSettle();
      expect(settings.isBookmarked('product.acme-node'), isTrue);

      await pumpLibraryScreen(
        tester,
        body: AppSettingsScope(
          controller: settings,
          child: GlossaryTermScreen(store: store, slug: 'nonce'),
        ),
      );
      await tester.tap(find.byTooltip('Save to bookmarks'));
      await tester.pumpAndSettle();
      expect(settings.isBookmarked('glossary.nonce'), isTrue);
    });
  });
}

Future<void> _pumpSearch(
  WidgetTester tester,
  SearchIndex index, {
  required String query,
  Locale? locale,
}) async {
  await pumpLibraryScreen(
    tester,
    locale: locale,
    body: SearchScreen(searchIndex: index),
  );
  await tester.enterText(find.byType(TextField), query);
  await tester.pumpAndSettle();
}
