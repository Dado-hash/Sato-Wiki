import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sato_wiki/src/core/widgets/filter_chip_bar.dart';
import 'package:sato_wiki/src/features/tools/presentation/reference_list_screen.dart';
import 'package:sato_wiki/src/features/tools/presentation/reference_table_screen.dart';
import 'package:sato_wiki/src/features/wiki/presentation/wiki_overview_screen.dart';

import 'tools_screen_fixtures.dart';

void main() {
  testWidgets('the list shows each table with its number of rows', (
    tester,
  ) async {
    await pumpToolsScreen(
      tester,
      home: (store) => ReferenceListScreen(store: store),
    );

    expect(find.text('Reference tables'), findsOneWidget);
    expect(find.text('Script opcodes'), findsOneWidget);
    expect(find.text('3 rows'), findsOneWidget);
    expect(find.text('Units'), findsOneWidget);
    expect(find.text('2 rows'), findsOneWidget);
  });

  testWidgets('the filter matches any cell and hides the other rows', (
    tester,
  ) async {
    await pumpToolsScreen(
      tester,
      home: (store) =>
          ReferenceTableScreen(store: store, slug: 'script-opcodes'),
    );

    expect(find.text('OP_0'), findsOneWidget);
    expect(find.text('OP_CAT'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'strings');
    await tester.pumpAndSettle();

    expect(find.text('OP_CAT'), findsOneWidget);
    expect(find.text('OP_0'), findsNothing);
    expect(find.text('OP_NOP'), findsNothing);

    await tester.enterText(find.byType(TextField), 'no such text');
    await tester.pumpAndSettle();

    expect(find.text('No rows match this filter.'), findsOneWidget);
  });

  testWidgets('the status chips filter the rows by the status column', (
    tester,
  ) async {
    await pumpToolsScreen(
      tester,
      home: (store) =>
          ReferenceTableScreen(store: store, slug: 'script-opcodes'),
    );

    final chips = find.byType(FilterChipBar<String?>);
    expect(chips, findsOneWidget);
    expect(
      find.descendant(of: chips, matching: find.text('disabled')),
      findsOneWidget,
    );

    await tester.tap(
      find.descendant(of: chips, matching: find.text('disabled')),
    );
    await tester.pumpAndSettle();

    expect(find.text('OP_CAT'), findsOneWidget);
    expect(find.text('OP_0'), findsNothing);
    expect(find.text('OP_NOP'), findsNothing);
  });

  testWidgets('a table without a status column has no chips', (tester) async {
    await pumpToolsScreen(
      tester,
      home: (store) => ReferenceTableScreen(store: store, slug: 'units'),
    );

    expect(find.byType(FilterChipBar<String?>), findsNothing);
    expect(find.text('satoshi'), findsOneWidget);
  });

  testWidgets('a row with a link opens its entry and shows a chevron', (
    tester,
  ) async {
    await pumpToolsScreen(
      tester,
      home: (store) =>
          ReferenceTableScreen(store: store, slug: 'script-opcodes'),
    );

    expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);

    await tester.tap(find.text('OP_NOP'));
    await tester.pumpAndSettle();

    expect(find.byType(WikiEntryScreen), findsOneWidget);
  });

  testWidgets('an unknown slug shows the not-found screen', (tester) async {
    await pumpToolsScreen(
      tester,
      home: (store) => ReferenceTableScreen(store: store, slug: 'missing'),
    );

    expect(find.text('Route not found'), findsOneWidget);
    expect(find.text('missing'), findsOneWidget);
  });

  testWidgets('the table screen is localized in Italian', (tester) async {
    await pumpToolsScreen(
      tester,
      locale: const Locale('it'),
      home: (store) =>
          ReferenceTableScreen(store: store, slug: 'script-opcodes'),
    );

    expect(find.text('Filtra le righe'), findsOneWidget);
    expect(find.text('Tutti'), findsOneWidget);
  });
}
