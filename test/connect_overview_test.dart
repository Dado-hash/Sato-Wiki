import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sato_wiki/src/core/content/domain/content_store.dart';
import 'package:sato_wiki/src/core/content/reading_level.dart';
import 'package:sato_wiki/src/core/navigation/app_routes.dart';
import 'package:sato_wiki/src/features/wiki/presentation/wiki_overview_screen.dart';

import 'connect_support.dart';
import 'wiki_tree_support.dart';

void main() {
  testWidgets('library card shows the work count and opens the library', (
    tester,
  ) async {
    useConnectTallScreen(tester);
    await tester.pumpWidget(_overview(connectOverviewStore(libraryWorks: 2)));
    await tester.pumpAndSettle();

    expect(find.text('Library'), findsOneWidget);
    expect(find.text('2 works'), findsOneWidget);
    expect(find.byIcon(Icons.local_library_outlined), findsOneWidget);

    await tester.tap(find.text('Library'));
    await tester.pumpAndSettle();

    expect(find.text('opened ${AppRoutes.library}'), findsOneWidget);
  });

  testWidgets('library card sits under the glossary card', (tester) async {
    useConnectTallScreen(tester);
    await tester.pumpWidget(_overview(connectOverviewStore(libraryWorks: 1)));
    await tester.pumpAndSettle();

    expect(find.text('Glossary'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Library')).dy,
      greaterThan(tester.getTopLeft(find.text('Glossary')).dy),
    );
  });

  testWidgets('library card is hidden when the bundle has no works', (
    tester,
  ) async {
    useConnectTallScreen(tester);
    await tester.pumpWidget(_overview(connectOverviewStore()));
    await tester.pumpAndSettle();

    expect(find.text('Library'), findsNothing);
    expect(find.text('Glossary'), findsOneWidget);
  });

  testWidgets('library card in Italian', (tester) async {
    useConnectTallScreen(tester);
    await tester.pumpWidget(
      _overview(
        connectOverviewStore(libraryWorks: 3),
        locale: const Locale('it'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Biblioteca'), findsOneWidget);
    expect(find.text('3 opere'), findsOneWidget);
  });
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
