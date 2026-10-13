import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sato_wiki/src/features/tools/domain/base58.dart';
import 'package:sato_wiki/src/features/tools/domain/compact_target.dart';
import 'package:sato_wiki/src/features/tools/presentation/tool_address_screen.dart';
import 'package:sato_wiki/src/features/tools/presentation/tool_hash_screen.dart';
import 'package:sato_wiki/src/features/tools/presentation/tool_target_screen.dart';
import 'package:sato_wiki/src/features/tools/presentation/tool_transaction_screen.dart';
import 'package:sato_wiki/src/features/tools/presentation/tool_units_screen.dart';
import 'package:sato_wiki/src/features/wiki/presentation/wiki_overview_screen.dart';

import 'tools_screen_fixtures.dart';

const _genesisAddress = '1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa';
const _genesisTxid =
    '4a5e1e4baab89f3a32518a88c31bc87f618f76673e2cc77ab2127b7afdeda33b';
const _segwitAddress = 'bc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq';

void main() {
  group('hash tool', () {
    testWidgets('SHA-256 of "abc" is shown in text mode', (tester) async {
      await pumpToolsScreen(tester, home: (s) => ToolHashScreen(store: s));

      await tester.enterText(find.byType(TextField), 'abc');
      await tester.pumpAndSettle();

      expect(
        _selectable(
          'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
        ),
        findsOneWidget,
      );
      expect(find.byTooltip('Copy'), findsWidgets);
    });

    testWidgets('empty text shows the hashes of the empty input', (
      tester,
    ) async {
      await pumpToolsScreen(tester, home: (s) => ToolHashScreen(store: s));

      expect(
        _selectable(
          'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
        ),
        findsOneWidget,
      );
    });

    testWidgets('invalid hex shows an inline message and no results', (
      tester,
    ) async {
      await pumpToolsScreen(tester, home: (s) => ToolHashScreen(store: s));

      await tester.tap(find.text('Hex'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'abc');
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Not valid hex. Use pairs of digits 0-9 and a-f, with no spaces.',
        ),
        findsOneWidget,
      );
      expect(find.text('SHA-256'), findsNothing);
    });

    testWidgets('links to the wiki entries that exist, in Italian too', (
      tester,
    ) async {
      await pumpToolsScreen(
        tester,
        locale: const Locale('it'),
        home: (s) => ToolHashScreen(store: s),
      );

      expect(find.text('Approfondisci nella wiki'), findsOneWidget);
      expect(find.text('Hash functions'), findsOneWidget);
      expect(find.text('About SHA-256'), findsOneWidget);
      expect(find.text('DOPPIO SHA-256'), findsOneWidget);
    });
  });

  group('address tool', () {
    testWidgets('genesis address is P2PKH on mainnet with a valid checksum', (
      tester,
    ) async {
      await pumpToolsScreen(tester, home: (s) => ToolAddressScreen(store: s));

      await tester.enterText(find.byType(TextField), _genesisAddress);
      await tester.pumpAndSettle();

      expect(find.text('Checksum valid'), findsOneWidget);
      expect(find.text('Mainnet'), findsOneWidget);
      expect(find.text('P2PKH'), findsOneWidget);
      expect(find.text('HOW IT IS BUILT'), findsOneWidget);
      expect(find.text('Bitcoin addresses'), findsOneWidget);
    });

    testWidgets('bech32 address shows the legend of its parts', (tester) async {
      await pumpToolsScreen(tester, home: (s) => ToolAddressScreen(store: s));

      await tester.enterText(find.byType(TextField), _segwitAddress);
      await tester.pumpAndSettle();

      expect(find.text('P2WPKH'), findsOneWidget);
      expect(find.text('Network prefix'), findsOneWidget);
      expect(find.text('Witness version'), findsOneWidget);
      expect(find.text('Checksum, last 6 characters'), findsOneWidget);
      expect(find.text('Segregated witness'), findsOneWidget);
    });

    testWidgets('a changed character gives the checksum error', (tester) async {
      await pumpToolsScreen(tester, home: (s) => ToolAddressScreen(store: s));

      final broken =
          '${_genesisAddress.substring(0, _genesisAddress.length - 1)}b';
      await tester.enterText(find.byType(TextField), broken);
      await tester.pumpAndSettle();

      expect(find.text('Checksum not valid'), findsOneWidget);
      expect(
        find.text(
          'The checksum does not match. The text was changed or mistyped.',
        ),
        findsOneWidget,
      );
      expect(find.text('HOW IT IS BUILT'), findsNothing);
    });

    testWidgets('a WIF private key shows only the warning and is cleared', (
      tester,
    ) async {
      await pumpToolsScreen(tester, home: (s) => ToolAddressScreen(store: s));
      final wif = base58CheckEncode(0x80, List.filled(32, 1));

      await tester.enterText(find.byType(TextField), wif);
      await tester.pumpAndSettle();

      expect(find.text('This looks like a private key'), findsOneWidget);
      expect(find.text('HOW IT IS BUILT'), findsNothing);
      expect(find.text('Checksum valid'), findsNothing);
      expect(find.text(wif), findsNothing);
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller!.text, isEmpty);
    });

    testWidgets('tapping the type link opens the wiki entry', (tester) async {
      await pumpToolsScreen(tester, home: (s) => ToolAddressScreen(store: s));

      await tester.enterText(find.byType(TextField), _genesisAddress);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bitcoin addresses'));
      await tester.pumpAndSettle();

      expect(find.byType(WikiEntryScreen), findsOneWidget);
    });
  });

  group('transaction tool', () {
    testWidgets('the example shows the genesis txid and its fields', (
      tester,
    ) async {
      await pumpToolsScreen(
        tester,
        home: (s) => ToolTransactionScreen(store: s),
      );

      await tester.tap(find.text('Load example'));
      await tester.pumpAndSettle();

      expect(_selectable(_genesisTxid), findsOneWidget);
      expect(find.text('Input 0 · coinbase'), findsWidgets);
      expect(find.text('50.00000000 BTC · 5000000000 sat'), findsOneWidget);
      expect(find.text('P2PK'), findsOneWidget);
      expect(find.text('Coinbase'), findsWidgets);
    });

    testWidgets('a field row with a wiki entry opens that entry', (
      tester,
    ) async {
      await pumpToolsScreen(
        tester,
        home: (s) => ToolTransactionScreen(store: s),
      );

      await tester.tap(find.text('Load example'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Input 0 · coinbase').first);
      await tester.tap(find.text('Input 0 · coinbase').first);
      await tester.pumpAndSettle();

      expect(find.byType(WikiEntryScreen), findsOneWidget);
    });

    testWidgets('invalid hex shows the reason from the decoder', (
      tester,
    ) async {
      await pumpToolsScreen(
        tester,
        home: (s) => ToolTransactionScreen(store: s),
      );

      await tester.enterText(find.byType(TextField), 'zz');
      await tester.pumpAndSettle();

      expect(
        find.text(
          'The input is empty, has an odd number of digits, or is not hexadecimal.',
        ),
        findsOneWidget,
      );
    });
  });

  group('target tool', () {
    testWidgets('bits 1d00ffff gives difficulty 1 and the maximum target', (
      tester,
    ) async {
      await pumpToolsScreen(tester, home: (s) => ToolTargetScreen(store: s));

      expect(find.text('1'), findsOneWidget);
      expect(
        _selectable(
          '00000000ffff0000000000000000000000000000000000000000000000000000',
        ),
        findsOneWidget,
      );
      expect(find.text('4,295,032,833'), findsOneWidget);
    });

    testWidgets('invalid bits show an inline message', (tester) async {
      await pumpToolsScreen(tester, home: (s) => ToolTargetScreen(store: s));

      await tester.enterText(find.byType(TextField), 'zz');
      await tester.pumpAndSettle();

      expect(
        find.text('Enter exactly 8 hex digits, with an optional 0x prefix.'),
        findsOneWidget,
      );
      expect(find.text('DIFFICULTY'), findsNothing);
    });

    test('1d00ffff is the difficulty 1 target', () {
      expect(difficultyFromBits(parseBits('0x1d00ffff')), 1.0);
    });
  });

  group('units tool', () {
    testWidgets('1 BTC is 100000000 satoshi and back', (tester) async {
      await pumpToolsScreen(tester, home: (s) => ToolUnitsScreen(store: s));

      await tester.enterText(find.byType(TextField).at(0), '1');
      await tester.pumpAndSettle();

      expect(_fieldText(tester, 1), '100000000');

      await tester.enterText(find.byType(TextField).at(1), '250');
      await tester.pumpAndSettle();

      expect(_fieldText(tester, 0), '0.00000250');
    });

    testWidgets('more than 8 decimals gives an error', (tester) async {
      await pumpToolsScreen(tester, home: (s) => ToolUnitsScreen(store: s));

      await tester.enterText(find.byType(TextField).at(0), '0.123456789');
      await tester.pumpAndSettle();

      expect(
        find.text('Bitcoin amounts have at most 8 decimals.'),
        findsOneWidget,
      );
    });

    testWidgets('561 weight units is 141 vB', (tester) async {
      await pumpToolsScreen(tester, home: (s) => ToolUnitsScreen(store: s));

      await tester.enterText(find.byType(TextField).at(2), '561');
      await tester.pumpAndSettle();

      expect(find.text('141 vB'), findsOneWidget);
    });

    testWidgets('fee 1000 sat over 200 vB is 5 sat/vB', (tester) async {
      await pumpToolsScreen(tester, home: (s) => ToolUnitsScreen(store: s));

      await tester.enterText(find.byType(TextField).at(3), '1000');
      await tester.enterText(find.byType(TextField).at(4), '200');
      await tester.pumpAndSettle();

      expect(find.text('5 sat/vB'), findsOneWidget);
    });

    testWidgets('a fee rate of 2 over 150 vB is 300 sat', (tester) async {
      await pumpToolsScreen(tester, home: (s) => ToolUnitsScreen(store: s));

      await tester.enterText(find.byType(TextField).at(5), '2');
      await tester.enterText(find.byType(TextField).at(6), '150');
      await tester.pumpAndSettle();

      expect(find.text('300 sat'), findsOneWidget);
    });
  });
}

/// Values that are selectable text (hashes, hex, targets, ids).
Finder _selectable(String value) {
  return find.byWidgetPredicate(
    (widget) => widget is SelectableText && widget.data == value,
  );
}

String _fieldText(WidgetTester tester, int index) {
  return tester
      .widget<TextField>(find.byType(TextField).at(index))
      .controller!
      .text;
}
