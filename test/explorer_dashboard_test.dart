import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sato_wiki/src/core/navigation/app_routes.dart';
import 'package:sato_wiki/src/features/tools/data/esplora_client.dart';
import 'package:sato_wiki/src/features/tools/data/esplora_models.dart';
import 'package:sato_wiki/src/features/tools/domain/mempool_projection.dart';
import 'package:sato_wiki/src/features/tools/presentation/explorer_dashboard_controller.dart';
import 'package:sato_wiki/src/features/tools/presentation/explorer_dashboard_widgets.dart';
import 'package:sato_wiki/src/features/tools/presentation/explorer_search_screen.dart';

import 'explorer_test_support.dart';

const _dashboardCalls = ['blocks', 'mempool', 'fees', 'recent'];

/// Shortened txid, as the dashboard shows it.
String _short(String txid) =>
    '${txid.substring(0, 6)}…${txid.substring(txid.length - 8)}';

/// Pumps the search screen with a filled fake and clears the calls made on
/// open. Tests then check only what they do themselves.
Future<ExplorerHarness> _pumpDashboard(
  WidgetTester tester, {
  Locale locale = const Locale('en'),
  FakeExplorerApi? api,
}) async {
  final fake = api ?? _filled();
  final harness = await pumpExplorer(
    tester,
    route: AppRoutes.explorer,
    enabled: true,
    locale: locale,
    api: fake,
  );
  harness.api.calls.clear();

  return harness;
}

/// A fake with every dashboard answer.
FakeExplorerApi _filled() {
  final api = FakeExplorerApi();
  fillDashboard(api);

  return api;
}

Finder _selectable(String value) {
  return find.byWidgetPredicate(
    (widget) => widget is SelectableText && widget.data == value,
  );
}

void main() {
  group('dashboard layout', () {
    testWidgets('shows every section with canned data', (tester) async {
      await _pumpDashboard(tester);

      expect(find.text('Live · mempool.space'), findsOneWidget);
      expect(find.text('BLOCKS'), findsOneWidget);
      expect(find.text('NOW'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('971,412'), findsOneWidget);
      expect(find.text('RECOMMENDED FEES'), findsOneWidget);
      expect(find.text('High'), findsOneWidget);
      expect(find.text('MEMPOOL'), findsOneWidget);
      expect(find.text('48,213\u00A0tx'), findsOneWidget);
      expect(find.text('DIFFICULTY'), findsOneWidget);
      expect(find.text('LATEST TRANSACTIONS'), findsOneWidget);
      expect(find.text(_short(cannedHash('recent tx 0'))), findsOneWidget);
      expect(
        find.text(
          'Each refresh sends 4 requests to mempool.space. The server sees '
          'your IP address. Searches are not saved.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('projected blocks, fee rates and the difficulty estimate', (
      tester,
    ) async {
      await _pumpDashboard(tester);

      // Four queued cubes, nearest first. The last one stands for the rest.
      // The fee card also shows ~10 min and ~30 min, so these are not unique.
      expect(find.text('~10\u00A0min'), findsWidgets);
      expect(find.text('~20\u00A0min'), findsOneWidget);
      expect(find.text('~30\u00A0min'), findsWidgets);
      expect(find.text('+9\u00A0blocks'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('+2'), findsOneWidget);
      expect(find.text('+3'), findsOneWidget);
      expect(find.text('Queued'), findsOneWidget);
      expect(find.text('+2.31 %'), findsOneWidget);
      expect(find.text('1,716/2,016'), findsOneWidget);
      expect(find.text('9:46'), findsOneWidget);
      expect(find.text('Estimate'), findsOneWidget);
      expect(find.text('8'), findsWidgets);
    });

    testWidgets('no data yet shows the error and a retry button', (
      tester,
    ) async {
      final harness = await pumpExplorer(
        tester,
        route: AppRoutes.explorer,
        enabled: true,
        api: FakeExplorerApi(),
      );

      expect(harness.api.calls, _dashboardCalls);
      expect(find.text('RECOMMENDED FEES'), findsNothing);
      expect(
        find.text(
          'The server does not know this block, transaction or address.',
        ),
        findsOneWidget,
      );
      expect(find.text('Try again'), findsOneWidget);

      harness.api.calls.clear();
      fillDashboard(harness.api);
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();

      // The epoch start block is looked up too, once.
      expect(harness.api.calls, containsAll(_dashboardCalls));
      expect(find.text('RECOMMENDED FEES'), findsOneWidget);
    });

    testWidgets('Italian labels', (tester) async {
      await _pumpDashboard(tester, locale: const Locale('it'));

      expect(find.text('COMMISSIONI CONSIGLIATE'), findsOneWidget);
      expect(find.text('ORA'), findsOneWidget);
      expect(find.text('Prossimo'), findsOneWidget);
      expect(find.text('ULTIME TRANSAZIONI'), findsOneWidget);
      expect(find.text('DIFFICULTY'), findsNothing);
      expect(find.text('Resume updates'), findsNothing);
    });
  });

  group('block strip', () {
    testWidgets('opens with Now at about 40 % and queued blocks on its left', (
      tester,
    ) async {
      await _pumpDashboard(tester);

      final strip = tester.getRect(
        find
            .ancestor(
              of: find.text('NOW'),
              matching: find.byType(SingleChildScrollView),
            )
            .first,
      );
      final nowX = tester.getCenter(find.text('NOW')).dx;
      final fraction = (nowX - strip.left) / strip.width;
      expect(fraction, inInclusiveRange(0.35, 0.45));

      final queuedX = tester.getCenter(find.text('Queued')).dx;
      final confirmedX = tester.getCenter(find.text('971,412')).dx;
      expect(queuedX, lessThan(nowX));
      expect(confirmedX, greaterThan(nowX));
    });

    testWidgets('Italian queued and fee labels are translated', (tester) async {
      await _pumpDashboard(tester, locale: const Locale('it'));

      expect(find.text('In coda'), findsOneWidget);
      expect(find.text('+9\u00A0blocchi'), findsOneWidget);
      expect(find.text('DIFFICOLTÀ'), findsOneWidget);
      expect(find.byTooltip('Spegni l\'explorer'), findsOneWidget);
      expect(find.text('Spegni'), findsOneWidget);
    });
  });

  group('taps', () {
    testWidgets('a confirmed cube opens its block screen', (tester) async {
      final harness = await _pumpDashboard(tester);
      final hash = cannedRecentBlocks().first.id;

      await tester.tap(find.text('971,412'));
      await tester.pumpAndSettle();

      expect(_selectable(hash), findsOneWidget);
      expect(harness.api.calls, contains('block:$hash'));
    });

    testWidgets('a transaction row opens its transaction screen', (
      tester,
    ) async {
      final harness = await _pumpDashboard(tester);
      final txid = cannedRecent().first.txid;
      harness.api.transactions[txid] = cannedTransaction(txid: txid);

      await tester.tap(find.text(_short(txid)));
      await tester.pumpAndSettle();

      expect(_selectable(txid), findsOneWidget);
      expect(harness.api.calls, contains('tx:$txid'));
    });
  });

  group('timing', () {
    testWidgets('refreshes every 60 seconds and stops when paused', (
      tester,
    ) async {
      final harness = await _pumpDashboard(tester);

      await tester.pump(const Duration(seconds: 60));
      expect(harness.api.calls, _dashboardCalls);

      await tester.tap(find.byTooltip('Pause updates'));
      await tester.pumpAndSettle();
      harness.api.calls.clear();

      await tester.pump(const Duration(seconds: 120));
      expect(harness.api.calls, isEmpty);
      expect(find.text('Paused'), findsOneWidget);
      expect(find.text('Paused · mempool.space'), findsOneWidget);

      await tester.tap(find.byTooltip('Resume updates'));
      await tester.pumpAndSettle();
      expect(harness.api.calls, _dashboardCalls);
    });

    testWidgets('a failed round keeps the last data and says so', (
      tester,
    ) async {
      final harness = await _pumpDashboard(tester);
      harness.api.mempoolAnswer = null;

      await tester.pump(const Duration(seconds: 60));
      await tester.pumpAndSettle();

      expect(find.text('48,213\u00A0tx'), findsOneWidget);
      expect(
        find.text('The last update failed. The data shown is from before.'),
        findsOneWidget,
      );
    });

    testWidgets('a rate limit pauses by itself and does not retry', (
      tester,
    ) async {
      final api = FakeExplorerApi()
        ..failure = const ExplorerException(
          ExplorerFailure.rateLimited,
          'paused',
          retryAfter: Duration(seconds: 60),
        );
      final harness = await pumpExplorer(
        tester,
        route: AppRoutes.explorer,
        enabled: true,
        api: api,
      );

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
      expect(find.text('Paused'), findsOneWidget);
      expect(harness.api.calls, _dashboardCalls);

      await tester.pump(const Duration(minutes: 5));
      expect(harness.api.calls, _dashboardCalls, reason: 'no retry');
    });

    testWidgets('a pushed route pauses the refresh until it is popped', (
      tester,
    ) async {
      final harness = await _pumpDashboard(tester);
      final navigator = Navigator.of(
        tester.element(find.byType(ExplorerSearchScreen)),
      );
      final txid = cannedRecent().first.txid;
      harness.api.transactions[txid] = cannedTransaction(txid: txid);

      navigator.pushNamed(AppRoutes.explorerTransaction(txid));
      await tester.pumpAndSettle();
      harness.api.calls.clear();

      await tester.pump(const Duration(seconds: 120));
      expect(harness.api.calls, isEmpty, reason: 'hidden under the route');

      navigator.pop();
      await tester.pumpAndSettle();
      expect(harness.api.calls, _dashboardCalls);
    });

    testWidgets('no request when the explorer is off', (tester) async {
      final harness = await pumpExplorer(
        tester,
        route: AppRoutes.explorer,
        api: _filled(),
      );

      await tester.pump(const Duration(minutes: 5));
      expect(harness.api.calls, isEmpty);
      expect(harness.clientsCreated, isEmpty);
    });
  });

  group('fee estimates', () {
    testWidgets('without /fee-estimates the fees come from the mempool', (
      tester,
    ) async {
      final api = _filled()..feesAnswer = null;
      final harness = await _pumpDashboard(tester, api: api);

      // The fee card shows the rates derived from the canned histogram.
      final histogram = cannedMempool().feeHistogram;
      final derived = feeEstimatesFromProjection(
        projectMempoolBlocks(histogram, maxBlocks: dashboardProjectedBlocks),
        histogram,
      );
      expect(find.text('RECOMMENDED FEES'), findsOneWidget);
      expect(
        find.text(formatFeeRate(derived.forTarget(1)!, 'en')),
        findsWidgets,
      );
      expect(
        find.text(formatFeeRate(derived.forTarget(144)!, 'en')),
        findsWidgets,
      );
      expect(find.text('Estimated from the mempool'), findsOneWidget);

      // No error notice: the missing endpoint is not a failure.
      expect(
        find.text(
          'The server does not know this block, transaction or address.',
        ),
        findsNothing,
      );
      expect(find.text('Try again'), findsNothing);

      // Later rounds skip /fee-estimates.
      await tester.pump(const Duration(seconds: 60));
      expect(harness.api.calls, ['blocks', 'mempool', 'recent']);
      expect(
        find.text(
          'Each refresh sends 3 requests to mempool.space. The server sees '
          'your IP address. Searches are not saved.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('a fee failure other than notFound is not an error', (
      tester,
    ) async {
      final api = _filled()
        ..feesFailure = const ExplorerException(
          ExplorerFailure.network,
          'The explorer server could not be reached.',
        );
      final harness = await _pumpDashboard(tester, api: api);

      expect(find.text('Estimated from the mempool'), findsOneWidget);
      expect(find.textContaining('could not be reached'), findsNothing);
      expect(find.text('Try again'), findsNothing);

      // Any failure but a rate limit stops the call for the session.
      await tester.pump(const Duration(seconds: 60));
      expect(harness.api.calls, ['blocks', 'mempool', 'recent']);
    });

    testWidgets('a bad fee response stops the call like notFound', (
      tester,
    ) async {
      // Mempool.space answers /fee-estimates with HTTP 203, which the client
      // reports as a bad response when it is not a 2xx it accepts.
      final api = _filled()
        ..feesFailure = const ExplorerException(
          ExplorerFailure.badResponse,
          'Unexpected HTTP status 203.',
        );
      final harness = await _pumpDashboard(tester, api: api);

      expect(find.text('Estimated from the mempool'), findsOneWidget);
      expect(find.textContaining('Unexpected HTTP'), findsNothing);
      expect(find.text('Try again'), findsNothing);

      await tester.pump(const Duration(seconds: 60));
      expect(harness.api.calls, ['blocks', 'mempool', 'recent']);
    });

    testWidgets('a finished round without fee data shows dashes', (
      tester,
    ) async {
      final api = _filled()
        ..feesAnswer = null
        ..mempoolAnswer = null;
      await _pumpDashboard(tester, api: api);

      expect(find.text('RECOMMENDED FEES'), findsOneWidget);
      expect(find.text('Estimated from the mempool'), findsNothing);
      expect(find.text('—'), findsWidgets);
    });
  });

  group('mempool bar', () {
    testWidgets('fee band segments paint with non-zero width', (tester) async {
      await _pumpDashboard(tester);

      final shares = mempoolBandShares(cannedMempool().feeHistogram);
      final drawn = [
        for (var i = 0; i < shares.length; i++)
          if (shares[i] > 0) i,
      ];
      expect(drawn, isNotEmpty);
      for (final i in drawn) {
        final finder = find.byKey(ValueKey('mempoolBand$i'));
        expect(finder, findsOneWidget, reason: 'band $i is not built');
        final size = tester.getSize(finder);
        expect(size.width, greaterThan(0), reason: 'band $i width');
        expect(size.height, greaterThan(0), reason: 'band $i height');
      }
    });
  });

  group('formatting', () {
    test('band shares add up to one and follow the fee bands', () {
      final shares = mempoolBandShares(const [
        EsploraFeeBucket(feeRate: 120, vsize: 100),
        EsploraFeeBucket(feeRate: 7, vsize: 100),
        EsploraFeeBucket(feeRate: 1.5, vsize: 200),
      ]);

      expect(shares.length, 5);
      expect(shares[0], closeTo(0.5, 1e-9));
      expect(shares[1], 0);
      expect(shares[2], closeTo(0.25, 1e-9));
      expect(shares[3], 0);
      expect(shares[4], closeTo(0.25, 1e-9));
      expect(shares.reduce((a, b) => a + b), closeTo(1, 1e-9));
    });

    test('an empty histogram gives zero shares', () {
      expect(mempoolBandShares(const []), everyElement(0));
    });

    test('fee rates: whole numbers from 10, one decimal below', () {
      expect(formatFeeRate(8, 'en'), '8');
      expect(formatFeeRate(2.5, 'en'), '2.5');
      expect(formatFeeRate(12.4, 'en'), '12');
      expect(formatFeeRate(2.5, 'it'), '2,5');
    });
  });
}
