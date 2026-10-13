import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sato_wiki/src/core/widgets/section_title.dart';
import 'package:sato_wiki/src/features/code/presentation/code_dashboard_screen.dart';
import 'package:sato_wiki/src/features/tools/presentation/reference_list_screen.dart';
import 'package:sato_wiki/src/features/tools/presentation/tool_hash_screen.dart';
import 'package:sato_wiki/src/features/tools/presentation/tool_units_screen.dart';

import 'tools_screen_fixtures.dart';

void main() {
  testWidgets('the Code dashboard shows the three new groups', (tester) async {
    await pumpToolsScreen(
      tester,
      home: (store) => CodeDashboardScreen(store: store),
    );

    expect(find.widgetWithText(SectionTitle, 'Tools'), findsOneWidget);
    expect(find.widgetWithText(SectionTitle, 'Learn by doing'), findsOneWidget);
    expect(find.widgetWithText(SectionTitle, 'Network'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Tables'), 300);

    expect(find.text('Hash'), findsOneWidget);
    expect(find.text('Address'), findsOneWidget);
    expect(find.text('Transaction'), findsOneWidget);
    expect(find.text('Target'), findsOneWidget);
    expect(find.text('Units'), findsOneWidget);
    expect(find.text('Tables'), findsOneWidget);
    expect(find.text('Blockchain lab'), findsOneWidget);
    expect(find.text('Script step by step'), findsOneWidget);
    expect(find.text('Explorer'), findsOneWidget);
    // The caption shows the real state: the explorer is off at install.
    expect(find.text('Off'), findsOneWidget);
  });

  testWidgets('tapping the Hash tile opens the hash tool', (tester) async {
    await pumpToolsScreen(
      tester,
      home: (store) => CodeDashboardScreen(store: store),
    );

    await tester.scrollUntilVisible(find.text('Hash'), 300);
    await tester.tap(find.text('Hash'));
    await tester.pumpAndSettle();

    expect(find.byType(ToolHashScreen), findsOneWidget);
  });

  testWidgets('tapping the Units tile opens the units tool', (tester) async {
    await pumpToolsScreen(
      tester,
      home: (store) => CodeDashboardScreen(store: store),
    );

    await tester.scrollUntilVisible(find.text('Units'), 300);
    await tester.tap(find.text('Units'));
    await tester.pumpAndSettle();

    expect(find.byType(ToolUnitsScreen), findsOneWidget);
  });

  testWidgets('tapping the Tables tile opens the reference list', (
    tester,
  ) async {
    await pumpToolsScreen(
      tester,
      home: (store) => CodeDashboardScreen(store: store),
    );

    await tester.scrollUntilVisible(find.text('Tables'), 300);
    await tester.tap(find.text('Tables'));
    await tester.pumpAndSettle();

    expect(find.byType(ReferenceListScreen), findsOneWidget);
  });

  testWidgets('the new groups are localized in Italian', (tester) async {
    await pumpToolsScreen(
      tester,
      locale: const Locale('it'),
      home: (store) => CodeDashboardScreen(store: store),
    );

    expect(find.widgetWithText(SectionTitle, 'Strumenti'), findsOneWidget);
    expect(find.widgetWithText(SectionTitle, 'Impara facendo'), findsOneWidget);
    expect(find.widgetWithText(SectionTitle, 'Rete'), findsOneWidget);
    expect(find.text('Indirizzo'), findsOneWidget);
  });
}
