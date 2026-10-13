import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sato_wiki/src/core/content/domain/content_store.dart';
import 'package:sato_wiki/src/core/navigation/app_router.dart';
import 'package:sato_wiki/src/features/wiki/presentation/product_screen.dart';
import 'package:sato_wiki/src/features/wiki/presentation/wiki_subcategory_screen.dart';

import 'wiki_tree_support.dart';

void main() {
  testWidgets('subcategory screen shows the guide and the sorted products', (
    tester,
  ) async {
    _useTallScreen(tester);
    await tester.pumpWidget(_subcategory(wikiTreeStore(), 'software-wallets'));
    await tester.pumpAndSettle();

    expect(find.text('GUIDE · 5 MIN'), findsOneWidget);
    expect(find.text('Software wallet'), findsOneWidget);
    expect(find.text('Guide to software wallets.'), findsOneWidget);
    expect(find.text('Products · 2'), findsOneWidget);
    expect(find.text('Mid Node'), findsNothing);
    expect(
      tester.getTopLeft(find.text('Alpha Wallet')).dy,
      lessThan(tester.getTopLeft(find.text('Zeta Wallet')).dy),
    );
  });

  testWidgets('product rows show status, openness and platforms as text', (
    tester,
  ) async {
    _useTallScreen(tester);
    await tester.pumpWidget(_subcategory(wikiTreeStore(), 'software-wallets'));
    await tester.pumpAndSettle();

    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Discontinued'), findsOneWidget);
    expect(find.text('Open source'), findsOneWidget);
    expect(find.text('Source not open'), findsOneWidget);
    expect(find.text('Desktop · Android'), findsOneWidget);
  });

  testWidgets('subcategory tap on a product opens the product route', (
    tester,
  ) async {
    _useTallScreen(tester);
    await tester.pumpWidget(_subcategory(wikiTreeStore(), 'software-wallets'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Alpha Wallet'));
    await tester.pumpAndSettle();

    expect(find.text('opened /products/alpha-wallet'), findsOneWidget);
  });

  testWidgets('subcategory without products shows only the guide', (
    tester,
  ) async {
    _useTallScreen(tester);
    await tester.pumpWidget(_subcategory(wikiTreeStore(), 'lightning'));
    await tester.pumpAndSettle();

    expect(find.text('Lightning guide'), findsOneWidget);
    expect(find.textContaining('Products ·'), findsNothing);
  });

  testWidgets('subcategory screen is localized in Italian', (tester) async {
    _useTallScreen(tester);
    await tester.pumpWidget(
      _subcategory(
        wikiTreeStore(),
        'software-wallets',
        locale: const Locale('it'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Prodotti · 2'), findsOneWidget);
    expect(find.text('Attivo'), findsOneWidget);
    expect(find.text('Dismesso'), findsOneWidget);
    expect(find.text('Codice non aperto'), findsOneWidget);
  });

  testWidgets('product screen shows the metadata, body and advisory notice', (
    tester,
  ) async {
    _useTallScreen(tester);
    await tester.pumpWidget(_product(wikiTreeStore(), 'alpha-wallet'));
    await tester.pumpAndSettle();

    expect(find.text('Alpha Wallet'), findsOneWidget);
    expect(find.text('Alpha Wallet summary.'), findsOneWidget);
    expect(find.text('Alpha Wallet Labs'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Yes'), findsOneWidget);
    expect(find.text('MIT'), findsOneWidget);
    expect(find.text('Desktop · Android'), findsOneWidget);
    expect(find.text('Checked on Oct 13, 2026'), findsOneWidget);
    expect(find.textContaining('Alpha Wallet body.'), findsOneWidget);
    expect(
      find.text(
        'SatoWiki does not sell or recommend products and has no affiliate links.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('product links open only when tapped', (tester) async {
    _useTallScreen(tester);
    final opened = <Uri>[];
    await tester.pumpWidget(
      _product(
        wikiTreeStore(),
        'alpha-wallet',
        openLink: (_, uri) async => opened.add(uri),
      ),
    );
    await tester.pumpAndSettle();

    expect(opened, isEmpty);

    await tester.tap(find.text('Website'));
    await tester.pumpAndSettle();
    expect(opened, [Uri.parse('https://alphawallet.example')]);

    await tester.tap(find.text('Source code'));
    await tester.pumpAndSettle();
    expect(opened.last, Uri.parse('https://github.com/example/alpha'));
  });

  testWidgets('product without source URL has no source button', (
    tester,
  ) async {
    _useTallScreen(tester);
    await tester.pumpWidget(_product(wikiTreeStore(), 'zeta-wallet'));
    await tester.pumpAndSettle();

    expect(find.text('Website'), findsOneWidget);
    expect(find.text('Source code'), findsNothing);
    expect(find.text('Discontinued'), findsOneWidget);
    expect(find.text('No'), findsOneWidget);
  });

  testWidgets('product screen is localized in Italian', (tester) async {
    _useTallScreen(tester);
    await tester.pumpWidget(
      _product(wikiTreeStore(), 'alpha-wallet', locale: const Locale('it')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Verificato il 13 ott 2026'), findsOneWidget);
    expect(find.text('LICENZA'), findsOneWidget);
    expect(
      find.text(
        'SatoWiki non vende e non raccomanda prodotti e non usa link di affiliazione.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('unknown product slug shows the not-found title', (tester) async {
    await tester.pumpWidget(_product(wikiTreeStore(), 'missing'));
    await tester.pumpAndSettle();

    expect(find.text('Product not found'), findsOneWidget);
  });

  test('deep links accept the subcategory and product routes', () {
    expect(
      DeepLinkTarget.tryParse('/wiki/subcategories/nodes')?.routeName,
      '/wiki/subcategories/nodes',
    );
    expect(
      DeepLinkTarget.tryParse('/products/alpha-wallet')?.routeName,
      '/products/alpha-wallet',
    );
    expect(DeepLinkTarget.tryParse('/products'), isNull);
    expect(DeepLinkTarget.tryParse('/wiki/subcategories'), isNull);
  });
}

Widget _subcategory(
  ContentStore store,
  String subcategoryId, {
  Locale? locale,
}) {
  return wikiTreeApp(
    WikiSubcategoryScreen(store: store, subcategoryId: subcategoryId),
    locale: locale,
  );
}

Widget _product(
  ContentStore store,
  String slug, {
  Locale? locale,
  Future<void> Function(BuildContext context, Uri uri)? openLink,
}) {
  return wikiTreeApp(
    ProductScreen(
      store: store,
      slug: slug,
      openLink: openLink ?? (_, _) async {},
    ),
    locale: locale,
  );
}

/// The lists are long: a tall surface builds every row, so taps can reach them.
void _useTallScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 4000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
}
