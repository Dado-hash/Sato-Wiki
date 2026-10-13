import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sato_wiki/src/core/navigation/app_routes.dart';
import 'package:sato_wiki/src/core/content/domain/content_store.dart';
import 'package:sato_wiki/src/core/content/reading_level.dart';
import 'package:sato_wiki/src/features/wiki/presentation/wiki_overview_screen.dart';

import 'wiki_tree_support.dart';

void main() {
  testWidgets(
    'categories with subcategories count them, others count entries',
    (tester) async {
      await tester.pumpWidget(_overview(wikiTreeStore()));
      await tester.pumpAndSettle();

      expect(find.text('6 subcategories'), findsOneWidget);
      expect(find.text('1 subcategory'), findsOneWidget);
      expect(find.text('1 entries'), findsOneWidget);
    },
  );

  testWidgets('subcategory count is localized in Italian', (tester) async {
    _useTallScreen(tester);
    await tester.pumpWidget(
      _overview(wikiTreeStore(), locale: const Locale('it')),
    );
    await tester.pumpAndSettle();

    expect(find.text('6 sottocategorie'), findsOneWidget);
  });

  testWidgets('glossary entry shows the term count and opens the glossary', (
    tester,
  ) async {
    _useTallScreen(tester);
    await tester.pumpWidget(_overview(wikiTreeStore()));
    await tester.pumpAndSettle();

    expect(find.text('Glossary'), findsOneWidget);
    expect(find.text('Short definitions · 2 terms'), findsOneWidget);

    await tester.tap(find.text('Glossary'));
    await tester.pumpAndSettle();

    expect(find.text('opened ${AppRoutes.glossary}'), findsOneWidget);
  });

  testWidgets('glossary entry is hidden when the bundle has no glossary', (
    tester,
  ) async {
    _useTallScreen(tester);
    await tester.pumpWidget(_overview(wikiTreeStore(withGlossary: false)));
    await tester.pumpAndSettle();

    expect(find.text('Glossary'), findsNothing);
  });

  testWidgets('category with subcategories lists them in the fixed order', (
    tester,
  ) async {
    _useTallScreen(tester);
    await tester.pumpWidget(
      wikiTreeApp(
        WikiCategoryScreen(store: wikiTreeStore(), category: 'software'),
      ),
    );
    await tester.pumpAndSettle();

    final labels = [
      'Nodes',
      'Software wallets',
      'Lightning',
      'Servers and infrastructure',
      'Custom a',
      'Custom b',
    ];
    for (final label in labels) {
      expect(find.text(label), findsOneWidget);
    }
    for (var i = 1; i < labels.length; i++) {
      expect(
        tester.getTopLeft(find.text(labels[i])).dy,
        greaterThan(tester.getTopLeft(find.text(labels[i - 1])).dy),
        reason: '${labels[i]} should come after ${labels[i - 1]}',
      );
    }
  });

  testWidgets(
    'subcategory rows show the guide description and open the route',
    (tester) async {
      await tester.pumpWidget(
        wikiTreeApp(
          WikiCategoryScreen(store: wikiTreeStore(), category: 'software'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Guide to software wallets.'), findsOneWidget);
      expect(find.text('6 subcategories'), findsOneWidget);
      expect(find.text('Other entries'), findsOneWidget);
      expect(find.text('Software overview'), findsOneWidget);
      expect(find.text('Software wallet'), findsNothing);

      await tester.tap(find.text('Lightning'));
      await tester.pumpAndSettle();

      expect(find.text('opened /wiki/subcategories/lightning'), findsOneWidget);
    },
  );

  testWidgets('category without subcategories keeps the entry list', (
    tester,
  ) async {
    _useTallScreen(tester);
    await tester.pumpWidget(
      wikiTreeApp(
        WikiCategoryScreen(store: wikiTreeStore(), category: 'protocol'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('1 entries'), findsOneWidget);
    expect(find.text('Proof of Work'), findsOneWidget);
    expect(find.text('Other entries'), findsNothing);
    expect(find.textContaining('subcategor'), findsNothing);
  });

  testWidgets('hardware category lists its subcategories', (tester) async {
    _useTallScreen(tester);
    await tester.pumpWidget(
      wikiTreeApp(
        WikiCategoryScreen(store: wikiTreeStore(), category: 'hardware'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Hardware wallets'), findsOneWidget);
    expect(find.text('1 subcategory'), findsOneWidget);
    expect(find.text('Hardware wallets guide'), findsNothing);
  });

  testWidgets(
    'reader shows the category and subcategory eyebrow and the review date',
    (tester) async {
      await tester.pumpWidget(_reader(wikiTreeStore(), 'software-wallets'));
      await tester.pumpAndSettle();

      expect(find.text('SOFTWARE · SOFTWARE WALLETS'), findsOneWidget);
      expect(find.text('Checked on Oct 13, 2026'), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    },
  );

  testWidgets('reader shows the review date in Italian', (tester) async {
    _useTallScreen(tester);
    await tester.pumpWidget(
      _reader(wikiTreeStore(), 'software-wallets', locale: const Locale('it')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Verificato il 13 ott 2026'), findsOneWidget);
  });

  testWidgets('reader without subcategory or review date shows neither', (
    tester,
  ) async {
    _useTallScreen(tester);
    await tester.pumpWidget(_reader(wikiTreeStore(), 'proof-of-work'));
    await tester.pumpAndSettle();

    expect(find.text('PROTOCOL'), findsOneWidget);
    expect(find.textContaining('Checked on'), findsNothing);
    expect(find.byIcon(Icons.check_rounded), findsNothing);
  });
}

Widget _reader(ContentStore store, String slug, {Locale? locale}) {
  return wikiTreeApp(
    WikiEntryScreen(
      store: store,
      slug: slug,
      selectedLevel: ReadingLevel.base,
      onLevelChanged: (_) {},
    ),
    locale: locale,
  );
}

Widget _overview(ContentStore store, {Locale? locale}) {
  return wikiTreeApp(
    Scaffold(
      body: WikiOverviewScreen(
        store: store,
        selectedLevel: ReadingLevel.base,
        onLevelChanged: (_) {},
      ),
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
