import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sato_wiki/src/features/tools/presentation/lab_index_screen.dart';
import 'package:sato_wiki/src/features/tools/presentation/lab_step_mine.dart';
import 'package:sato_wiki/src/features/tools/presentation/lab_step_screen.dart';

import 'tools_screen_fixtures.dart';

const _sha256Abc =
    'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad';
const _genesisHash =
    '000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f';

/// Finds a selectable monospace value by its exact text.
Finder _selectableValue(String value) {
  return find.byWidgetPredicate(
    (widget) => widget is SelectableText && widget.data == value,
  );
}

/// A bare step widget on a scaffold, for tests that do not need the frame.
Widget _bare(Widget child) {
  return Scaffold(
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: child,
    ),
  );
}

/// Pumps frames until [condition] holds, so that a mining run can finish.
Future<void> _pumpUntil(
  WidgetTester tester,
  bool Function() condition, {
  int maxPumps = 20000,
}) async {
  for (var i = 0; i < maxPumps; i++) {
    await tester.pump(const Duration(milliseconds: 1));
    if (condition()) {
      return;
    }
  }
  fail('The expected state did not appear');
}

/// Pumps until [finder] matches at least once.
Future<void> _pumpUntilFound(WidgetTester tester, Finder finder) {
  return _pumpUntil(tester, () => finder.evaluate().isNotEmpty);
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pump();
}

Future<void> _pumpStep(
  WidgetTester tester, {
  required int step,
  Locale locale = const Locale('en'),
}) {
  return pumpToolsScreen(
    tester,
    locale: locale,
    home: (store) => LabStepScreen(store: store, step: step),
  );
}

void main() {
  group('lab index', () {
    testWidgets('lists the seven steps in English', (tester) async {
      await pumpToolsScreen(tester, home: (_) => const LabIndexScreen());

      expect(find.text('Blockchain lab'), findsWidgets);
      for (final title in [
        'Hash',
        'Mine a block',
        'Chain',
        'Network',
        'Transactions',
        'Coinbase',
        'A real header',
      ]) {
        expect(find.text(title), findsOneWidget);
      }
      expect(find.text('Optional'), findsOneWidget);
    });

    testWidgets('renders in Italian', (tester) async {
      await pumpToolsScreen(
        tester,
        locale: const Locale('it'),
        home: (_) => const LabIndexScreen(),
      );

      expect(find.text('Laboratorio blockchain'), findsWidgets);
      expect(find.text('Mina un blocco'), findsOneWidget);
      expect(find.text('Un header reale'), findsOneWidget);
      expect(find.text('Facoltativo'), findsOneWidget);
    });

    testWidgets('a row opens its step', (tester) async {
      await pumpToolsScreen(tester, home: (_) => const LabIndexScreen());

      await _tap(tester, find.text('Network'));
      await tester.pumpAndSettle();

      expect(find.text('Step 4 of 7'), findsOneWidget);
      expect(find.text('Network'), findsWidgets);
    });
  });

  group('step 1, hash', () {
    testWidgets('the hash changes at every key press and matches SHA-256', (
      tester,
    ) async {
      await pumpToolsScreen(
        tester,
        home: (store) => LabStepScreen(store: store, step: 1),
      );

      await tester.enterText(find.byType(TextField), 'a');
      await tester.pump();
      final hashOfA = _sha256OfField(tester);

      await tester.enterText(find.byType(TextField), 'ab');
      await tester.pump();
      final hashOfAb = _sha256OfField(tester);

      await tester.enterText(find.byType(TextField), 'abc');
      await tester.pump();

      expect(hashOfA, isNot(hashOfAb));
      expect(_selectableValue(_sha256Abc), findsOneWidget);
    });

    testWidgets('empty text gives the SHA-256 of the empty input', (
      tester,
    ) async {
      await pumpToolsScreen(
        tester,
        home: (store) => LabStepScreen(store: store, step: 1),
      );

      expect(
        _selectableValue(
          'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
        ),
        findsOneWidget,
      );
      expect(find.text('Step 1 of 7'), findsOneWidget);
      expect(find.text('In Bitcoin it is different'), findsOneWidget);
    });
  });

  group('step 2, mine a block', () {
    testWidgets('mining finds a nonce at low difficulty and shows Valid', (
      tester,
    ) async {
      await pumpToolsScreen(
        tester,
        home: (_) => _bare(const LabMineStep(difficulty: 2)),
      );

      expect(find.text('Not valid'), findsOneWidget);
      expect(find.text('Valid'), findsNothing);

      await _tap(tester, find.text('Mine'));
      await _pumpUntilFound(tester, find.text('Valid'));

      expect(find.text('Not valid'), findsNothing);
      expect(find.textContaining('Nonce found after'), findsOneWidget);
    });

    testWidgets('editing the data after mining makes the block Not valid', (
      tester,
    ) async {
      await pumpToolsScreen(
        tester,
        home: (_) => _bare(const LabMineStep(difficulty: 2)),
      );

      await _tap(tester, find.text('Mine'));
      await _pumpUntilFound(tester, find.text('Valid'));

      await tester.enterText(find.byType(TextField), 'Alice -> Bob: 6');
      await tester.pump();

      expect(find.text('Not valid'), findsOneWidget);
      expect(find.text('Valid'), findsNothing);
    });

    testWidgets('a run shows attempts and speed, then its result', (
      tester,
    ) async {
      await pumpToolsScreen(
        tester,
        home: (_) => _bare(const LabMineStep(difficulty: 2)),
      );

      await _tap(tester, find.text('Mine'));
      await _pumpUntilFound(tester, find.text('Valid'));

      expect(find.text('Attempts'), findsOneWidget);
      expect(find.textContaining('hash/s'), findsOneWidget);
      expect(find.textContaining('Nonce found after'), findsOneWidget);
      expect(find.text('Mine'), findsOneWidget);
    });

    testWidgets('the step screen shows the Bitcoin difference box', (
      tester,
    ) async {
      await _pumpStep(tester, step: 2);

      expect(find.text('Mine a block'), findsWidgets);
      expect(
        find.text(
          'The header is 80 bytes, the hash is double SHA-256, and the rule is a numeric target, not a count of zeros.',
        ),
        findsOneWidget,
      );
    });
  });

  group('step 3, chain', () {
    testWidgets('the default chain is valid and a change breaks what follows', (
      tester,
    ) async {
      await _pumpStep(tester, step: 3);

      expect(find.text('Valid'), findsNWidgets(3));
      expect(find.text('Not valid'), findsNothing);

      await tester.enterText(find.byType(TextField).at(1), 'Bob -> Carol: 200');
      await tester.pump();

      expect(find.text('Valid'), findsOneWidget);
      expect(find.text('Not valid'), findsNWidgets(2));
    });

    testWidgets('mine again repairs the chain from the first invalid block', (
      tester,
    ) async {
      await _pumpStep(tester, step: 3);

      await tester.enterText(find.byType(TextField).at(1), 'Bob -> Carol: 200');
      await tester.pump();
      await _tap(tester, find.text('Mine again'));
      await _pumpUntil(tester, () => find.text('Valid').evaluate().length == 3);

      expect(find.text('Not valid'), findsNothing);
    });
  });

  group('step 4, network', () {
    testWidgets('a node with a changed copy rejects it and keeps the others', (
      tester,
    ) async {
      await _pumpStep(tester, step: 4);

      expect(find.text('Keeps this copy'), findsNWidgets(3));

      await _tap(tester, find.text('Change data on node B'));

      expect(find.text('Keeps this copy'), findsNWidgets(2));
      expect(find.text('Rejects this copy'), findsOneWidget);
      expect(find.text('Not valid'), findsOneWidget);
    });
  });

  group('step 5, transactions', () {
    testWidgets('adding a transfer changes the block data', (tester) async {
      await _pumpStep(tester, step: 5);

      expect(find.text('Alice -> Bob: 5'), findsOneWidget);

      await tester.enterText(find.byType(TextField).at(0), 'Dan');
      await tester.enterText(find.byType(TextField).at(1), 'Eve');
      await tester.enterText(find.byType(TextField).at(2), '3');
      await _tap(tester, find.text('Add transfer'));

      expect(find.text('Dan -> Eve: 3'), findsOneWidget);
    });

    testWidgets('a negative or empty amount gives an error', (tester) async {
      await _pumpStep(tester, step: 5);

      await tester.enterText(find.byType(TextField).at(0), 'Dan');
      await tester.enterText(find.byType(TextField).at(1), 'Eve');
      await tester.enterText(find.byType(TextField).at(2), 'x');
      await _tap(tester, find.text('Add transfer'));

      expect(find.text('Enter a whole number, zero or more.'), findsOneWidget);
    });
  });

  group('step 6, coinbase', () {
    testWidgets('the coinbase line names the miner and pays 50', (
      tester,
    ) async {
      await _pumpStep(tester, step: 6);

      expect(find.textContaining('Coinbase -> Miner: 50'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'Nadia');
      await tester.pump();

      expect(find.textContaining('Coinbase -> Nadia: 50'), findsOneWidget);
    });
  });

  group('step 7, real header', () {
    testWidgets('decodes the genesis header and hashes it to the known value', (
      tester,
    ) async {
      await _pumpStep(tester, step: 7);

      expect(_selectableValue(_genesisHash), findsOneWidget);
      expect(find.text('2009-01-03 18:15:05 UTC'), findsOneWidget);
      expect(find.text('Hash below target'), findsOneWidget);
      expect(find.text('Valid'), findsOneWidget);
      expect(find.text('Optional'), findsOneWidget);
    });

    testWidgets('Italian uses the same decoded values', (tester) async {
      await _pumpStep(tester, step: 7, locale: const Locale('it'));

      expect(_selectableValue(_genesisHash), findsOneWidget);
      expect(find.text('CAMPI DECODIFICATI'), findsOneWidget);
      expect(find.text('Hash sotto il target'), findsOneWidget);
    });
  });

  group('every step', () {
    testWidgets('renders its counter and box in English and Italian', (
      tester,
    ) async {
      for (var step = 1; step <= 7; step++) {
        await _pumpStep(tester, step: step);
        expect(find.text('Step $step of 7'), findsOneWidget);
        expect(find.text('In Bitcoin it is different'), findsOneWidget);
        expect(
          find.text('Previous step'),
          step > 1 ? findsOneWidget : findsNothing,
        );
        expect(
          find.text('Next step'),
          step < 7 ? findsOneWidget : findsNothing,
        );

        await _pumpStep(tester, step: step, locale: const Locale('it'));
        expect(find.text('Passo $step di 7'), findsOneWidget);
        expect(find.text('In Bitcoin è diverso'), findsOneWidget);
      }
    });
  });

  group('step screens', () {
    testWidgets('each step renders its title in Italian', (tester) async {
      await _pumpStep(tester, step: 3, locale: const Locale('it'));

      expect(find.text('Passo 3 di 7'), findsOneWidget);
      expect(find.text('Catena'), findsWidgets);
      expect(find.text('In Bitcoin è diverso'), findsOneWidget);
      expect(find.text('Passo successivo'), findsOneWidget);
    });

    testWidgets('previous and next move between steps', (tester) async {
      await pumpToolsScreen(
        tester,
        home: (store) => LabStepScreen(store: store, step: 1),
      );

      expect(find.text('Previous step'), findsNothing);
      await _tap(tester, find.text('Next step'));
      await tester.pumpAndSettle();

      expect(find.text('Step 2 of 7'), findsOneWidget);

      await _tap(tester, find.text('Previous step'));
      await tester.pumpAndSettle();

      expect(find.text('Step 1 of 7'), findsOneWidget);
    });

    testWidgets('the last step has no next button', (tester) async {
      await _pumpStep(tester, step: 7);

      expect(find.text('Next step'), findsNothing);
      expect(find.text('Previous step'), findsOneWidget);
    });
  });
}

/// Reads the hash shown by the step 1 result, the only SHA-256 value on it.
String _sha256OfField(WidgetTester tester) {
  final texts = tester
      .widgetList<SelectableText>(find.byType(SelectableText))
      .map((widget) => widget.data ?? '')
      .where((value) => value.length == 64)
      .toList();

  return texts.single;
}
