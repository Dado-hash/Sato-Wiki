import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sato_wiki/src/features/tools/presentation/script_stepper_screen.dart';

import 'tools_screen_fixtures.dart';

Future<void> _pumpScript(
  WidgetTester tester, {
  Locale locale = const Locale('en'),
}) {
  return pumpToolsScreen(
    tester,
    locale: locale,
    home: (store) => ScriptStepperScreen(store: store),
  );
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  group('script stepper', () {
    testWidgets('states that signatures are simulated', (tester) async {
      await _pumpScript(tester);

      expect(find.text('Script step by step'), findsOneWidget);
      expect(
        find.textContaining('Signature checks are simulated'),
        findsOneWidget,
      );
      expect(find.text('Arithmetic'), findsOneWidget);
      expect(find.text('Pay to public key hash'), findsOneWidget);
    });

    testWidgets('the arithmetic example runs to success', (tester) async {
      await _pumpScript(tester);

      await _tap(tester, find.text('Run to end'));

      expect(find.text('Script succeeds'), findsOneWidget);
      expect(find.text('5 opcodes run'), findsOneWidget);
      expect(find.text('Nothing left to run.'), findsOneWidget);
    });

    testWidgets('one step runs one opcode and marks the next one', (
      tester,
    ) async {
      await _pumpScript(tester);

      await _tap(tester, find.text('Step'));

      expect(find.text('1 opcode run'), findsOneWidget);
      // Pushing 2 leaves the byte 0x02 on the stack, with the top marked.
      expect(find.text('02'), findsOneWidget);
      expect(find.text('Top'), findsOneWidget);
      // The opcode for 3 is the next one to run.
      expect(find.text('OP_3'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Script succeeds'), findsNothing);
    });

    testWidgets('a failing typed script reports the reason', (tester) async {
      await _pumpScript(tester);

      await _tap(tester, find.text('Your script'));
      await tester.enterText(find.byType(TextField), '1 OP_0 OP_VERIFY');
      await tester.pump();
      await _tap(tester, find.text('Run to end'));

      expect(
        find.text('Script fails: a VERIFY opcode found a false value'),
        findsOneWidget,
      );
      expect(find.text('Script succeeds'), findsNothing);
    });

    testWidgets('a typed script that cannot be read shows the token', (
      tester,
    ) async {
      await _pumpScript(tester);

      await _tap(tester, find.text('Your script'));
      await tester.enterText(find.byType(TextField), '1 hello');
      await tester.pump();

      expect(
        find.text(
          'Token 2 cannot be read: not an opcode, number, hex or quoted text',
        ),
        findsOneWidget,
      );
      final step = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Step'),
      );
      expect(step.onPressed, isNull);
    });

    testWidgets('a P2PKH example shows the simulated signature note', (
      tester,
    ) async {
      await _pumpScript(tester);

      await _tap(tester, find.text('Pay to public key hash'));
      await _tap(tester, find.text('Run to end'));

      expect(find.text('Script succeeds'), findsOneWidget);
      expect(
        find.text('This signature was checked against the simulated set.'),
        findsOneWidget,
      );
    });

    testWidgets('reset returns to the start', (tester) async {
      await _pumpScript(tester);

      await _tap(tester, find.text('Run to end'));
      expect(find.text('Script succeeds'), findsOneWidget);

      await _tap(tester, find.text('Reset'));

      expect(find.text('Not started'), findsOneWidget);
      expect(find.text('Script succeeds'), findsNothing);
    });

    testWidgets('renders in Italian', (tester) async {
      await _pumpScript(tester, locale: const Locale('it'));

      expect(find.text('Script passo per passo'), findsOneWidget);
      expect(find.text('Esegui fino in fondo'), findsOneWidget);
      expect(find.text('Il tuo script'), findsOneWidget);

      await _tap(tester, find.text('Esegui fino in fondo'));

      expect(find.text('Lo script riesce'), findsOneWidget);
    });
  });
}
