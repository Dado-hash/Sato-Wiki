import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sato_wiki/src/core/content/domain/content_store.dart';
import 'package:sato_wiki/src/core/navigation/app_router.dart';
import 'package:sato_wiki/src/features/learn/presentation/library_list_screen.dart';
import 'package:sato_wiki/src/features/learn/presentation/library_work_screen.dart';

import 'library_test_support.dart';

void main() {
  group('library list', () {
    testWidgets('sorts works by year, then title', (tester) async {
      await _pumpList(tester);

      final chaum = tester.getTopLeft(
        find.text('Blind Signatures for Untraceable Payments'),
      );
      final hughes = tester.getTopLeft(find.text("A Cypherpunk's Manifesto"));
      final nakamoto = tester.getTopLeft(
        find.text('Bitcoin: A Peer-to-Peer Electronic Cash System'),
      );

      expect(chaum.dy, lessThan(hughes.dy));
      expect(hughes.dy, lessThan(nakamoto.dy));
    });

    testWidgets('each row shows author, year and kind as text', (tester) async {
      await _pumpList(tester);

      expect(find.text('David Chaum · 1982'), findsOneWidget);
      expect(find.text('Eric Hughes · 1993'), findsOneWidget);
      expect(find.text('Paper'), findsNWidgets(2));
      expect(find.text('Manifesto'), findsOneWidget);
    });

    testWidgets('author chip keeps only works by that author', (tester) async {
      await _pumpList(tester);

      await _tapChip(tester, 'Eric Hughes');
      await tester.pumpAndSettle();

      expect(find.text("A Cypherpunk's Manifesto"), findsOneWidget);
      expect(
        find.text('Blind Signatures for Untraceable Payments'),
        findsNothing,
      );
    });

    testWidgets('topic chips come from the works and filter them', (
      tester,
    ) async {
      await _pumpList(tester);

      expect(find.text('consensus'), findsOneWidget);
      await _tapChip(tester, 'privacy');
      await tester.pumpAndSettle();

      expect(
        find.text('Blind Signatures for Untraceable Payments'),
        findsOneWidget,
      );
      expect(find.text("A Cypherpunk's Manifesto"), findsOneWidget);
      expect(
        find.text('Bitcoin: A Peer-to-Peer Electronic Cash System'),
        findsNothing,
      );
    });

    testWidgets('author and topic together can match nothing', (tester) async {
      await _pumpList(tester);

      await _tapChip(tester, 'Satoshi Nakamoto');
      await tester.pumpAndSettle();
      await _tapChip(tester, 'privacy');
      await tester.pumpAndSettle();

      expect(find.text('No works match this filter.'), findsOneWidget);
    });

    testWidgets('the All chip clears a filter', (tester) async {
      await _pumpList(tester);

      await _tapChip(tester, 'Eric Hughes');
      await tester.pumpAndSettle();
      await _tapChip(tester, 'All');
      await tester.pumpAndSettle();

      expect(
        find.text('Bitcoin: A Peer-to-Peer Electronic Cash System'),
        findsOneWidget,
      );
    });

    testWidgets('empty library shows the empty state', (tester) async {
      await _pumpList(tester, store: libraryFixtureStore(empty: true));

      expect(find.text('No works in the library yet.'), findsOneWidget);
      expect(find.text('All'), findsNothing);
    });

    testWidgets('tapping a work opens its screen', (tester) async {
      await _pumpList(tester);

      await tester.tap(find.text("A Cypherpunk's Manifesto"));
      await tester.pumpAndSettle();

      expect(find.text('Opened /library/cypherpunk-manifesto'), findsOneWidget);
    });

    testWidgets('renders the Italian labels and kinds', (tester) async {
      await _pumpList(tester, locale: const Locale('it'));

      expect(find.text('Biblioteca'), findsOneWidget);
      expect(find.text('AUTORE'), findsOneWidget);
      expect(find.text('ARGOMENTO'), findsOneWidget);
      expect(find.text('Manifesto'), findsOneWidget);
      expect(find.text('Tutti'), findsWidgets);
    });
  });

  group('library work', () {
    testWidgets('shows facts, summary, introduction and original language', (
      tester,
    ) async {
      await _pumpWork(tester, slug: 'blind-signatures');

      expect(
        find.text('Blind Signatures for Untraceable Payments'),
        findsOneWidget,
      );
      expect(
        find.text('Summary of Blind Signatures for Untraceable Payments.'),
        findsOneWidget,
      );
      expect(
        find.text(
          'Our introduction to Blind Signatures for Untraceable Payments.',
        ),
        findsOneWidget,
      );
      expect(find.text('DAVID CHAUM'), findsNothing);
      expect(find.text('David Chaum'), findsOneWidget);
      expect(find.text('1982'), findsOneWidget);
      expect(find.text('Paper'), findsOneWidget);
      expect(find.text('EN'), findsOneWidget);
      expect(find.text('cryptography · privacy'), findsOneWidget);
      expect(
        find.text('License: No license stated; linked, not reproduced'),
        findsOneWidget,
      );
    });

    testWidgets('Read the original opens the original URL on tap only', (
      tester,
    ) async {
      final opened = <Uri>[];
      await _pumpWork(
        tester,
        slug: 'blind-signatures',
        openLink: (_, uri) async => opened.add(uri),
      );

      expect(opened, isEmpty);
      await tester.tap(find.text('Read the original'));
      await tester.pumpAndSettle();

      expect(opened, [Uri.parse('https://example.com/blind-signatures')]);
    });

    testWidgets('Archived copy opens the archive URL when present', (
      tester,
    ) async {
      final opened = <Uri>[];
      await _pumpWork(
        tester,
        slug: 'blind-signatures',
        openLink: (_, uri) async => opened.add(uri),
      );

      await tester.tap(find.text('Archived copy'));
      await tester.pumpAndSettle();

      expect(opened, [
        Uri.parse('https://web.archive.org/web/2026/https://example.com/chaum'),
      ]);
    });

    testWidgets('no Archived copy button without an archive URL', (
      tester,
    ) async {
      await _pumpWork(tester, slug: 'bitcoin-whitepaper');

      expect(find.text('Read the original'), findsOneWidget);
      expect(find.text('Archived copy'), findsNothing);
    });

    testWidgets('related links open their screens', (tester) async {
      await _pumpWork(tester, slug: 'blind-signatures');

      await tester.tap(find.text('Proof of Work'));
      await tester.pumpAndSettle();

      expect(find.text('Opened /wiki/entries/proof-of-work'), findsOneWidget);
    });

    testWidgets('renders the Italian button labels', (tester) async {
      await _pumpWork(
        tester,
        slug: 'blind-signatures',
        locale: const Locale('it'),
      );

      expect(find.text("Leggi l'originale"), findsOneWidget);
      expect(find.text('Copia archiviata'), findsOneWidget);
      expect(find.text('La nostra introduzione'), findsOneWidget);
      expect(find.text('LINGUA ORIGINALE'), findsOneWidget);
      expect(find.text('Read the original'), findsNothing);
    });

    testWidgets('unknown slug shows the not-found title', (tester) async {
      await _pumpWork(tester, slug: 'missing');

      expect(find.text('Work not found'), findsOneWidget);
      expect(find.text('Read the original'), findsNothing);
    });
  });

  group('routes', () {
    test('library list and work are recognised deep links', () {
      expect(DeepLinkTarget.tryParse('/library'), isNotNull);
      expect(DeepLinkTarget.tryParse('/library/bitcoin-whitepaper'), isNotNull);
      expect(DeepLinkTarget.tryParse('/library/a/b'), isNull);
    });
  });
}

Future<void> _pumpList(
  WidgetTester tester, {
  ContentStore? store,
  Locale? locale,
}) async {
  await pumpLibraryScreen(
    tester,
    locale: locale,
    body: LibraryListScreen(store: store ?? libraryFixtureStore()),
  );
}

Future<void> _pumpWork(
  WidgetTester tester, {
  required String slug,
  Locale? locale,
  Future<void> Function(BuildContext context, Uri uri)? openLink,
}) async {
  await pumpLibraryScreen(
    tester,
    locale: locale,
    body: LibraryWorkScreen(
      store: libraryFixtureStore(),
      slug: slug,
      openLink: openLink ?? (_, _) async {},
    ),
  );
}

/// Filter chips sit in a horizontal scroller, so scroll the chip into view
/// before tapping it.
Future<void> _tapChip(WidgetTester tester, String label) async {
  final chip = find.text(label).first;
  await tester.ensureVisible(chip);
  await tester.pumpAndSettle();
  await tester.tap(chip);
  await tester.pumpAndSettle();
}
