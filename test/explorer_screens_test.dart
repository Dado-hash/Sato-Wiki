import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sato_wiki/src/core/navigation/app_routes.dart';
import 'package:sato_wiki/src/core/settings/app_settings_controller.dart';
import 'package:sato_wiki/src/core/settings/app_settings_scope.dart';
import 'package:sato_wiki/src/features/code/presentation/code_dashboard_screen.dart';
import 'package:sato_wiki/src/features/tools/data/esplora_client.dart';
import 'package:sato_wiki/src/features/tools/domain/base58.dart';

import 'explorer_test_support.dart';

const _xpub =
    'xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8';

/// A 64-character hash that starts with a non-zero digit, so it is tried as a
/// txid first.
final _neutralHash = List<String>.filled(32, '5a').join();

Finder _selectable(String value) {
  return find.byWidgetPredicate(
    (widget) => widget is SelectableText && widget.data == value,
  );
}

Finder _searchButton() => find.widgetWithText(FilledButton, 'Search');

/// Calls that the dashboard on the search screen makes when it opens.
const _dashboardCalls = ['blocks', 'mempool', 'fees', 'recent'];

/// A fake that answers the dashboard calls too, so the dashboard shows data
/// and adds no error text to the search messages.
FakeExplorerApi _dashboardFake() {
  final api = FakeExplorerApi();
  fillDashboard(api);

  return api;
}

/// Pumps the search screen with the explorer on. The calls the dashboard makes
/// on open are cleared, so each test checks only the calls it makes itself.
Future<ExplorerHarness> _pumpSearch(
  WidgetTester tester, {
  FakeExplorerApi? api,
}) async {
  final harness = await pumpExplorer(
    tester,
    route: AppRoutes.explorer,
    enabled: true,
    api: api ?? _dashboardFake(),
  );
  harness.api.calls.clear();

  return harness;
}

Finder _searchField() => find.byType(TextField);

void main() {
  group('explorer off', () {
    testWidgets('search route shows activation and sends nothing', (
      tester,
    ) async {
      final harness = await pumpExplorer(tester, route: AppRoutes.explorer);

      expect(
        find.text(
          'The explorer asks a server on the internet for data. '
          'The rest of the app works without a network.',
        ),
        findsOneWidget,
      );
      expect(find.text('Turn on the explorer'), findsOneWidget);
      expect(find.text('Height, block hash, txid or address'), findsNothing);
      expect(harness.api.calls, isEmpty);
      expect(harness.clientsCreated, isEmpty);
    });

    testWidgets('detail routes show activation and sends nothing', (
      tester,
    ) async {
      final harness = await pumpExplorer(
        tester,
        route: AppRoutes.explorerTransaction(txHash),
      );

      expect(find.text('Turn on the explorer'), findsOneWidget);
      expect(harness.api.calls, isEmpty);
      expect(harness.clientsCreated, isEmpty);
    });

    testWidgets('activation explains what the server sees', (tester) async {
      await pumpExplorer(tester, route: AppRoutes.explorerSetup);

      expect(
        find.textContaining('Every search is sent to the server shown below'),
        findsOneWidget,
      );
      expect(find.textContaining('IP address'), findsWidgets);
      // The default server is the text of the field, and nothing else.
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'https://mempool.space/api',
      );
    });

    testWidgets('a server that the client refuses is not saved', (
      tester,
    ) async {
      final harness = await pumpExplorer(
        tester,
        route: AppRoutes.explorerSetup,
      );

      await tester.enterText(find.byType(TextField), 'http://example.com/api');
      await tester.tap(find.text('Turn on the explorer'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'This address is not allowed. Use https, or http only for '
          'localhost, .onion or .local. It was not saved.',
        ),
        findsOneWidget,
      );
      expect(harness.settings.explorerEnabled, isFalse);
      expect(
        harness.settings.explorerServer,
        AppSettingsController.defaultExplorerServer,
      );
      expect(harness.api.calls, isEmpty);
      expect(harness.clientsCreated, isEmpty);
    });

    testWidgets('a valid own server is saved when the explorer is turned on', (
      tester,
    ) async {
      final harness = await pumpExplorer(
        tester,
        route: AppRoutes.explorerSetup,
      );

      await tester.enterText(find.byType(TextField), 'https://example.org/api');
      await tester.tap(find.text('Turn on the explorer'));
      await tester.pumpAndSettle();

      expect(harness.settings.explorerEnabled, isTrue);
      expect(harness.settings.explorerServer, 'https://example.org/api');
      // Turning on sends nothing: the client is created by the first search.
      expect(harness.api.calls, isEmpty);
      expect(harness.clientsCreated, isEmpty);
    });

    testWidgets('activation turns the explorer on and shows the search', (
      tester,
    ) async {
      final harness = await pumpExplorer(tester, route: AppRoutes.explorer);

      await tester.tap(find.text('Turn on the explorer'));
      await tester.pumpAndSettle();

      expect(harness.settings.explorerEnabled, isTrue);
      expect(_searchField(), findsOneWidget);
      expect(find.byTooltip('Turn off the explorer'), findsOneWidget);
      // Opening the search loads the dashboard, and nothing else.
      expect(harness.api.calls, _dashboardCalls);
    });
  });

  group('explorer on', () {
    testWidgets('search shows the server in use and a turn off action', (
      tester,
    ) async {
      await _pumpSearch(tester);

      expect(find.text('Live · mempool.space'), findsOneWidget);
      expect(find.byTooltip('Turn off the explorer'), findsOneWidget);
    });

    testWidgets('a height opens the block screen with its fields', (
      tester,
    ) async {
      final harness = await _pumpSearch(tester);
      harness.api
        ..heightToHash[850000] = blockHash850000
        ..blocks[blockHash850000] = cannedBlock();

      await tester.enterText(_searchField(), '850000');
      await tester.pump();
      await tester.tap(_searchButton());
      await tester.pumpAndSettle();

      expect(_selectable(blockHash850000), findsOneWidget);
      expect(find.text('850000'), findsOneWidget);
      expect(find.text('PREVIOUS BLOCK'), findsOneWidget);
      expect(harness.api.calls, ['height:850000', 'block:$blockHash850000']);
    });

    testWidgets('a txid opens the transaction screen with fee and status', (
      tester,
    ) async {
      final harness = await _pumpSearch(tester);
      harness.api.transactions[txHash] = cannedTransaction();

      await tester.enterText(_searchField(), txHash);
      await tester.pump();
      await tester.tap(_searchButton());
      await tester.pumpAndSettle();

      expect(_selectable(txHash), findsOneWidget);
      expect(find.text('Confirmed'), findsOneWidget);
      expect(find.text('0.00001000 BTC · 1000 sat'), findsOneWidget);
      expect(harness.api.calls.where((c) => c.startsWith('block:')), isEmpty);
    });

    testWidgets('a block hash with leading zeros opens the block first', (
      tester,
    ) async {
      final harness = await _pumpSearch(tester);
      harness.api.blocks[blockHash850000] = cannedBlock();

      await tester.enterText(_searchField(), blockHash850000);
      await tester.pump();
      await tester.tap(_searchButton());
      await tester.pumpAndSettle();

      expect(_selectable(blockHash850000), findsOneWidget);
      expect(harness.api.calls.where((c) => c.startsWith('tx:')), isEmpty);
    });

    testWidgets('a hash that is not a txid falls back to the block lookup', (
      tester,
    ) async {
      final harness = await _pumpSearch(tester);
      harness.api.blocks[_neutralHash] = cannedBlock(id: _neutralHash);

      await tester.enterText(_searchField(), _neutralHash);
      await tester.pump();
      await tester.tap(_searchButton());
      await tester.pumpAndSettle();

      expect(_selectable(_neutralHash), findsOneWidget);
      expect(harness.api.calls, [
        'tx:$_neutralHash',
        'block:$_neutralHash',
        'block:$_neutralHash',
      ]);
    });

    testWidgets('an address opens the address screen with balances', (
      tester,
    ) async {
      final harness = await _pumpSearch(tester);
      harness.api
        ..addresses[addressValue] = cannedAddress()
        ..addressTxs[addressValue] = [cannedTransaction()];

      await tester.enterText(_searchField(), addressValue);
      await tester.pump();
      await tester.tap(_searchButton());
      await tester.pumpAndSettle();

      expect(_selectable(addressValue), findsOneWidget);
      expect(find.text('0.50000000 BTC · 50000000 sat'), findsWidgets);
      expect(find.text(txHash), findsOneWidget);
    });

    testWidgets('a hash found nowhere shows the not found message', (
      tester,
    ) async {
      await _pumpSearch(tester);

      await tester.enterText(_searchField(), txHash);
      await tester.pump();
      await tester.tap(_searchButton());
      await tester.pumpAndSettle();

      expect(
        find.text(
          'The server does not know this block, transaction or address.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('text that is not an id is refused without a request', (
      tester,
    ) async {
      final harness = await _pumpSearch(tester);

      await tester.enterText(_searchField(), 'hello world');
      await tester.pump();
      await tester.tap(_searchButton());
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Enter a block height, a 64-character hash or txid, or an address.',
        ),
        findsOneWidget,
      );
      expect(harness.api.calls, isEmpty);
    });

    testWidgets('a pasted private key shows the warning and sends nothing', (
      tester,
    ) async {
      final harness = await _pumpSearch(tester);
      final wif = base58CheckEncode(0x80, List<int>.filled(32, 1));

      await tester.enterText(_searchField(), wif);
      await tester.pumpAndSettle();

      expect(find.text('This looks like a private key'), findsOneWidget);
      expect(
        find.text(
          'Nothing was sent. The field was cleared. Never paste a private '
          'key into any app or website.',
        ),
        findsOneWidget,
      );
      expect(tester.widget<TextField>(_searchField()).controller!.text, '');
      expect(find.textContaining(wif), findsNothing);
      // The dashboard opened the client. The key itself was not sent.
      expect(harness.api.calls, isEmpty);
    });

    testWidgets('a pasted extended key shows the warning and sends nothing', (
      tester,
    ) async {
      final harness = await _pumpSearch(tester);

      await tester.enterText(_searchField(), _xpub);
      await tester.pumpAndSettle();

      expect(find.text('This looks like an extended key'), findsOneWidget);
      expect(harness.api.calls, isEmpty);
    });

    testWidgets('429 shows the wait and disables search until it passes', (
      tester,
    ) async {
      final harness = await _pumpSearch(tester);
      harness.api.failure = const ExplorerException(
        ExplorerFailure.rateLimited,
        'The explorer server returned HTTP 429. Calls are paused.',
        retryAfter: Duration(seconds: 60),
      );

      await tester.enterText(_searchField(), txHash);
      await tester.pump();
      await tester.tap(_searchButton());
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Too many requests. The server asked to slow down. '
          'Try again in 60 seconds.',
        ),
        findsOneWidget,
      );
      expect(
        find.text('The explorer does not retry on its own.'),
        findsOneWidget,
      );
      expect(tester.widget<FilledButton>(_searchButton()).onPressed, isNull);

      // A second tap while disabled sends nothing.
      await tester.tap(_searchButton(), warnIfMissed: false);
      await tester.pump();
      expect(harness.api.calls, ['tx:$txHash']);

      // The wait ends with a timer, not a request. The dashboard refreshes
      // once a minute on its own, so only the search calls are checked.
      await tester.pump(const Duration(seconds: 61));
      expect(tester.widget<FilledButton>(_searchButton()).onPressed, isNotNull);
      expect(harness.api.calls.where((call) => call.startsWith('tx:')), [
        'tx:$txHash',
      ]);
    });

    testWidgets('turn off returns to the activation screen', (tester) async {
      final harness = await _pumpSearch(tester);

      await tester.tap(find.byTooltip('Turn off the explorer'));
      await tester.pumpAndSettle();

      expect(harness.settings.explorerEnabled, isFalse);
      expect(harness.api.closed, isTrue, reason: 'the client is dropped');
      expect(find.text('Turn on the explorer'), findsOneWidget);
    });
  });

  group('detail screens', () {
    testWidgets('network error shows a message and a retry button', (
      tester,
    ) async {
      final harness = await pumpExplorer(
        tester,
        route: AppRoutes.explorerTransaction(txHash),
        enabled: true,
        api: FakeExplorerApi()
          ..failure = const ExplorerException(
            ExplorerFailure.network,
            'Explorer server could not be reached.',
          ),
      );

      expect(
        find.text(
          'The server could not be reached. Check the connection and try again.',
        ),
        findsOneWidget,
      );
      expect(find.text('Try again'), findsOneWidget);

      harness.api.failure = null;
      harness.api.transactions[txHash] = cannedTransaction();
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();

      expect(_selectable(txHash), findsOneWidget);
      expect(harness.api.calls.where((c) => c == 'tx:$txHash').length, 2);
    });

    testWidgets('an unknown txid on a detail screen shows not found', (
      tester,
    ) async {
      await pumpExplorer(
        tester,
        route: AppRoutes.explorerTransaction(txHash),
        enabled: true,
      );

      expect(
        find.text(
          'The server does not know this block, transaction or address.',
        ),
        findsOneWidget,
      );
      expect(find.text('Try again'), findsNothing);
    });

    testWidgets('a rate limit on a detail screen waits and shows the seconds', (
      tester,
    ) async {
      await pumpExplorer(
        tester,
        route: AppRoutes.explorerBlock(blockHash850000),
        enabled: true,
        api: FakeExplorerApi()
          ..failure = const ExplorerException(
            ExplorerFailure.rateLimited,
            'paused',
            retryAfter: Duration(seconds: 1),
          ),
      );

      expect(
        find.text(
          'Too many requests. The server asked to slow down. '
          'Try again in 1 second.',
        ),
        findsOneWidget,
      );
      expect(
        tester
            .widget<OutlinedButton>(
              find.widgetWithText(OutlinedButton, 'Try again'),
            )
            .onPressed,
        isNull,
      );
      await tester.pump(const Duration(seconds: 2));
    });
  });

  group('languages', () {
    testWidgets('Italian rendering of the activation and search screens', (
      tester,
    ) async {
      await pumpExplorer(
        tester,
        route: AppRoutes.explorer,
        locale: const Locale('it'),
      );

      expect(
        find.text(
          "L'explorer chiede i dati a un server su internet. Il resto "
          "dell'app funziona senza rete.",
        ),
        findsOneWidget,
      );
      expect(find.text("Attiva l'explorer"), findsOneWidget);

      await tester.tap(find.text("Attiva l'explorer"));
      await tester.pumpAndSettle();

      expect(
        find.text('Altezza, hash del blocco, txid o indirizzo'),
        findsOneWidget,
      );
      expect(find.text('Cerca'), findsOneWidget);
    });

    testWidgets('Italian labels on a block screen', (tester) async {
      await pumpExplorer(
        tester,
        route: AppRoutes.explorerBlock(blockHash850000),
        enabled: true,
        locale: const Locale('it'),
        api: FakeExplorerApi()..blocks[blockHash850000] = cannedBlock(),
      );

      expect(find.text('BLOCCO PRECEDENTE'), findsOneWidget);
      expect(find.text('Altezza'), findsOneWidget);
    });
  });

  group('entry points', () {
    testWidgets('the settings row shows Off and opens the setup', (
      tester,
    ) async {
      await pumpExplorer(tester, route: AppRoutes.settings);

      expect(find.text('Off'), findsOneWidget);
      await tester.tap(find.text('Explorer'));
      await tester.pumpAndSettle();

      expect(find.text('Turn on the explorer'), findsOneWidget);
    });

    testWidgets('the code dashboard row shows the real state', (tester) async {
      await pumpExplorer(
        tester,
        route: AppRoutes.code,
        enabled: true,
        server: 'https://example.org/api',
        home: (settings, store) => AppSettingsScope(
          controller: settings,
          child: CodeDashboardScreen(store: store),
        ),
      );

      expect(find.text('On · example.org'), findsOneWidget);
    });

    testWidgets('the code dashboard row says Off when the explorer is off', (
      tester,
    ) async {
      await pumpExplorer(
        tester,
        route: AppRoutes.code,
        home: (settings, store) => AppSettingsScope(
          controller: settings,
          child: CodeDashboardScreen(store: store),
        ),
      );

      expect(find.text('Off'), findsOneWidget);
    });
  });
}
