import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sato_wiki/src/core/content/application/app_content_controller.dart';
import 'package:sato_wiki/src/core/content/data/content_bundle_parser.dart';
import 'package:sato_wiki/src/core/content/domain/content_store.dart';
import 'package:sato_wiki/src/core/content/data/content_bundle_repository.dart';
import 'package:sato_wiki/src/core/localization/app_locale.dart';
import 'package:sato_wiki/src/core/navigation/app_router.dart';
import 'package:sato_wiki/src/core/settings/app_settings_controller.dart';
import 'package:sato_wiki/src/core/settings/app_settings_repository.dart';
import 'package:sato_wiki/src/core/theme/app_theme.dart';
import 'package:sato_wiki/src/features/tools/data/esplora_client.dart';
import 'package:sato_wiki/src/features/tools/data/esplora_models.dart';
import 'package:sato_wiki/src/features/tools/presentation/explorer_session.dart';
import 'package:sato_wiki/src/generated/l10n/app_localizations.dart';

import 'tools_screen_fixtures.dart';

// Every explorer test uses this fake. No test opens a socket or contacts a
// server: the fake records each call and answers from canned data.

const genesisHash =
    '000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f';
const txHash =
    '19b07dc823648870150e9425aa994195f4250511784eece89eefe8d75a13e00d';
const otherTxHash =
    '142b72c2847faee404e6b4d2c2bda64339fd5cf52c5bf87735c036e95d4a4868';
const addressValue = '1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa';

/// A block hash that the fake knows only by a block lookup.
const blockHash850000 =
    '00000000000000000002a7c4c1e48d76c5a37902165a270156b7a8d72728a054';

/// Canned answers for the explorer, plus the list of calls made.
final class FakeExplorerApi implements ExplorerApi {
  /// Every call, as `kind:value`, in the order it was made.
  final List<String> calls = <String>[];

  final Map<int, String> heightToHash = <int, String>{};
  final Map<String, EsploraBlock> blocks = <String, EsploraBlock>{};
  final Map<String, EsploraTransaction> transactions =
      <String, EsploraTransaction>{};
  final Map<String, EsploraAddressStats> addresses =
      <String, EsploraAddressStats>{};
  final Map<String, List<EsploraTransaction>> addressTxs =
      <String, List<EsploraTransaction>>{};

  /// When set, every call fails with this exception.
  ExplorerException? failure;

  bool closed = false;

  T _answer<T extends Object>(String call, T? value) {
    calls.add(call);
    final error = failure;
    if (error != null) {
      throw error;
    }
    if (value == null) {
      throw const ExplorerException(
        ExplorerFailure.notFound,
        'The explorer server does not know this item.',
      );
    }

    return value;
  }

  @override
  Future<String> blockHashAtHeight(int height) async =>
      _answer('height:$height', heightToHash[height]);

  @override
  Future<EsploraBlock> block(String hash) async =>
      _answer('block:$hash', blocks[hash]);

  @override
  Future<EsploraTransaction> transaction(String txid) async =>
      _answer('tx:$txid', transactions[txid]);

  @override
  Future<EsploraAddressStats> address(String address) async =>
      _answer('address:$address', addresses[address]);

  @override
  Future<List<EsploraTransaction>> addressTransactions(String address) async {
    calls.add('addresstxs:$address');
    final error = failure;
    if (error != null) {
      throw error;
    }

    return addressTxs[address] ?? const <EsploraTransaction>[];
  }

  @override
  void close() {
    closed = true;
  }
}

/// A block as the Esplora server sends it, using the real JSON field names.
EsploraBlock cannedBlock({
  String id = blockHash850000,
  int height = 850000,
  String? previous,
}) {
  return EsploraBlock.fromJson({
    'id': id,
    'height': height,
    'version': 536870912,
    'timestamp': 1499000000,
    'tx_count': 2100,
    'size': 1200000,
    'weight': 3990000,
    'merkle_root':
        '4a5e1e4baab89f3a32518a88c31bc87f618f76673e2cc77ab2127b7afdeda33b',
    'previousblockhash': previous ?? genesisHash,
    'nonce': 2083236893,
    'bits': 402990014,
    'difficulty': 1.0e13,
  });
}

/// A confirmed transaction with one input and two outputs.
EsploraTransaction cannedTransaction({
  String txid = txHash,
  bool confirmed = true,
  int fee = 1000,
}) {
  return EsploraTransaction.fromJson({
    'txid': txid,
    'version': 2,
    'locktime': 0,
    'size': 225,
    'weight': 573,
    'fee': fee,
    'vin': [
      {
        'txid': otherTxHash,
        'vout': 1,
        'is_coinbase': false,
        'scriptsig': '',
        'sequence': 4294967295,
        'witness': <String>[],
        'prevout': {
          'scriptpubkey': '0014751e76e8199196d454941c45d1b3a323f1433bd6',
          'scriptpubkey_type': 'v0_p2wpkh',
          'scriptpubkey_address': 'bc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq',
          'value': 50000000,
        },
      },
    ],
    'vout': [
      {
        'scriptpubkey': '0014',
        'scriptpubkey_type': 'v0_p2wpkh',
        'scriptpubkey_address': 'bc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq',
        'value': 10000000,
      },
      {
        'scriptpubkey': '0014',
        'scriptpubkey_type': 'v0_p2wpkh',
        'value': 39999000,
      },
    ],
    'status': confirmed
        ? {
            'confirmed': true,
            'block_height': 850000,
            'block_hash': blockHash850000,
            'block_time': 1499000000,
          }
        : {'confirmed': false},
  });
}

/// Balances of an address with one confirmed payment of 0.5 BTC.
EsploraAddressStats cannedAddress() {
  return EsploraAddressStats.fromJson({
    'address': addressValue,
    'chain_stats': {
      'funded_txo_count': 1,
      'funded_txo_sum': 50000000,
      'spent_txo_count': 0,
      'spent_txo_sum': 0,
      'tx_count': 1,
    },
    'mempool_stats': {
      'funded_txo_count': 0,
      'funded_txo_sum': 0,
      'spent_txo_count': 0,
      'spent_txo_sum': 0,
      'tx_count': 0,
    },
  });
}

/// Settings, session and fake API of one test, plus the calls they recorded.
final class ExplorerHarness {
  ExplorerHarness({
    required this.settings,
    required this.api,
    required this.session,
    required this.clientsCreated,
  });

  final AppSettingsController settings;
  final FakeExplorerApi api;
  final ExplorerSession session;

  /// How many clients the session asked for. Must stay 0 while off.
  final List<Uri> clientsCreated;
}

/// Pumps the app router at [route] with the explorer session for [settings]
/// replaced by one that uses [api].
Future<ExplorerHarness> pumpExplorer(
  WidgetTester tester, {
  required String route,
  bool enabled = false,
  String? server,
  Locale locale = const Locale('en'),
  AppSettingsRepository? repository,
  FakeExplorerApi? api,
  Widget Function(AppSettingsController settings, ContentStore store)? home,
}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final settings = await AppSettingsController.load(
    repository ??
        InMemoryAppSettingsRepository(
          explorerEnabled: enabled,
          explorerServer: server,
        ),
  );
  final fake = api ?? FakeExplorerApi();
  final created = <Uri>[];
  final session = ExplorerSession(
    settings: settings,
    apiFactory: (uri) {
      created.add(uri);

      return fake;
    },
  );
  ExplorerSession.replaceFor(settings, session);

  final content = await AppContentController.load(
    repository: _FixtureRepository(toolsFixtureJson()),
    languageCode: 'en',
  );

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark(),
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocale.supportedLocales,
      home: home == null ? null : home(settings, content.content.store),
      initialRoute: home == null ? route : null,
      onGenerateRoute: (routeSettings) {
        return AppRouter.generateRoute(routeSettings, settings, content);
      },
    ),
  );
  await tester.pumpAndSettle();

  return ExplorerHarness(
    settings: settings,
    api: fake,
    session: session,
    clientsCreated: created,
  );
}

final class _FixtureRepository implements ContentBundleRepository {
  const _FixtureRepository(this.json);

  final String json;

  @override
  Future<ContentBundleParseResult> load(String languageCode) async {
    return ContentBundleParser.parseJson(json);
  }

  @override
  Future<void> saveUpdatedBundleJson(String languageCode, String json) async {}
}
