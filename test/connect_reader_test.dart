import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sato_wiki/src/core/navigation/app_routes.dart';
import 'package:sato_wiki/src/core/content/reading_level.dart';
import 'package:sato_wiki/src/features/wiki/presentation/wiki_overview_screen.dart';

import 'connect_support.dart';
import 'wiki_tree_support.dart';

void main() {
  testWidgets('mapped entry shows the Try it rows in English', (tester) async {
    useConnectTallScreen(tester);
    await tester.pumpWidget(_reader('hash-functions'));
    await tester.pumpAndSettle();

    expect(find.text('Try it'), findsOneWidget);
    expect(find.text('Hash tool'), findsOneWidget);
    expect(
      find.text('Compute SHA-256 and HASH160 of any text'),
      findsOneWidget,
    );
    expect(find.text('Blockchain lab, step 1'), findsOneWidget);
    expect(find.text('Type text and watch its hash change'), findsOneWidget);
  });

  testWidgets('Try it rows open their routes', (tester) async {
    useConnectTallScreen(tester);
    await tester.pumpWidget(_reader('hash-functions'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Hash tool'));
    await tester.pumpAndSettle();
    expect(find.text('opened ${AppRoutes.toolHash}'), findsOneWidget);
  });

  testWidgets('lab step row opens its step route', (tester) async {
    useConnectTallScreen(tester);
    await tester.pumpWidget(_reader('hash-functions'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Blockchain lab, step 1'));
    await tester.pumpAndSettle();
    expect(find.text('opened ${AppRoutes.labStep(1)}'), findsOneWidget);
  });

  testWidgets('entry with two tools shows both rows in order', (tester) async {
    useConnectTallScreen(tester);
    await tester.pumpWidget(_reader('proof-of-work'));
    await tester.pumpAndSettle();

    expect(find.text('Blockchain lab, step 2'), findsOneWidget);
    expect(find.text('Target tool'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Blockchain lab, step 2')).dy,
      lessThan(tester.getTopLeft(find.text('Target tool')).dy),
    );

    await tester.tap(find.text('Target tool'));
    await tester.pumpAndSettle();
    expect(find.text('opened ${AppRoutes.toolTarget}'), findsOneWidget);
  });

  testWidgets('script row opens the script stepper', (tester) async {
    useConnectTallScreen(tester);
    await tester.pumpWidget(_reader('bitcoin-script'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Script step by step'));
    await tester.pumpAndSettle();
    expect(find.text('opened ${AppRoutes.scriptStepper}'), findsOneWidget);
  });

  testWidgets('unmapped entry shows no Try it section', (tester) async {
    useConnectTallScreen(tester);
    await tester.pumpWidget(_reader('plain-entry'));
    await tester.pumpAndSettle();

    expect(find.text('Try it'), findsNothing);
    expect(find.text('Plain entry'), findsOneWidget);
  });

  testWidgets('Try it section is in Italian', (tester) async {
    useConnectTallScreen(tester);
    await tester.pumpWidget(
      _reader('hash-functions', locale: const Locale('it')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Prova'), findsOneWidget);
    expect(find.text('Strumento hash'), findsOneWidget);
    expect(find.text('Laboratorio blockchain, passo 1'), findsOneWidget);
    expect(find.text('Calcola SHA-256 e HASH160 di un testo'), findsOneWidget);
  });

  testWidgets('related quotes show at most two, with their sources', (
    tester,
  ) async {
    useConnectTallScreen(tester);
    await tester.pumpWidget(_reader('proof-of-work'));
    await tester.pumpAndSettle();

    expect(find.text('In their words'), findsOneWidget);
    expect(find.text('“Quote a.”'), findsOneWidget);
    expect(find.text('“Quote b.”'), findsOneWidget);
    expect(find.text('“Quote c.”'), findsNothing);
    expect(find.text('Source of quote a'), findsOneWidget);
    expect(find.text('Satoshi Nakamoto · Oct 31, 2008'), findsNWidgets(2));
    expect(find.text('Source'), findsNWidgets(2));
  });

  testWidgets('entry without related quotes shows no quote section', (
    tester,
  ) async {
    useConnectTallScreen(tester);
    await tester.pumpWidget(_reader('plain-entry'));
    await tester.pumpAndSettle();

    expect(find.text('In their words'), findsNothing);
    expect(find.text('Source'), findsNothing);
  });

  testWidgets('related quotes in Italian show the original and the title', (
    tester,
  ) async {
    useConnectTallScreen(tester);
    await tester.pumpWidget(
      _reader('hash-functions', locale: const Locale('it')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Con le loro parole'), findsOneWidget);
    expect(find.text('“Citazione d.”'), findsOneWidget);
    expect(find.text('Original quote d.'), findsOneWidget);
    expect(find.text('Fonte'), findsOneWidget);
  });
}

Widget _reader(String slug, {Locale? locale}) {
  return wikiTreeApp(
    WikiEntryScreen(
      store: connectStore(language: locale?.languageCode ?? 'en'),
      slug: slug,
      selectedLevel: ReadingLevel.base,
      onLevelChanged: (_) {},
    ),
    locale: locale,
  );
}
