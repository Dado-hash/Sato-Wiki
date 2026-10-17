import 'dart:async';

import '../../../core/settings/app_settings_controller.dart';
import '../data/esplora_client.dart';
import '../data/esplora_models.dart';

/// The calls the explorer screens make. [EsploraClient] is wrapped by
/// [EsploraExplorerApi]; tests pass a fake.
abstract interface class ExplorerApi {
  Future<String> blockHashAtHeight(int height);

  Future<EsploraBlock> block(String hash);

  Future<EsploraTransaction> transaction(String txid);

  Future<EsploraAddressStats> address(String address);

  Future<List<EsploraTransaction>> addressTransactions(String address);

  /// Recent confirmed blocks, newest first.
  Future<List<EsploraBlock>> recentBlocks();

  /// Mempool count, size, fees and fee histogram.
  Future<EsploraMempoolInfo> mempoolInfo();

  /// Fee rates by confirmation target.
  Future<EsploraFeeEstimates> feeEstimates();

  /// The last transactions that entered the mempool.
  Future<List<EsploraRecentTransaction>> recentMempoolTransactions();

  /// Drops the client and its cache. Later calls fail.
  void close();
}

/// [ExplorerApi] backed by the real [EsploraClient].
final class EsploraExplorerApi implements ExplorerApi {
  EsploraExplorerApi(this._client);

  final EsploraClient _client;

  @override
  Future<String> blockHashAtHeight(int height) =>
      _client.blockHashAtHeight(height);

  @override
  Future<EsploraBlock> block(String hash) => _client.block(hash);

  @override
  Future<EsploraTransaction> transaction(String txid) =>
      _client.transaction(txid);

  @override
  Future<EsploraAddressStats> address(String address) =>
      _client.address(address);

  @override
  Future<List<EsploraTransaction>> addressTransactions(String address) =>
      _client.addressTransactions(address);

  @override
  Future<List<EsploraBlock>> recentBlocks() => _client.recentBlocks();

  @override
  Future<EsploraMempoolInfo> mempoolInfo() => _client.mempoolInfo();

  @override
  Future<EsploraFeeEstimates> feeEstimates() => _client.feeEstimates();

  @override
  Future<List<EsploraRecentTransaction>> recentMempoolTransactions() =>
      _client.recentMempoolTransactions();

  @override
  void close() => _client.close();
}

/// The server URL as a [Uri], or null when the client would refuse it. The
/// same rules apply everywhere: https, or http only for local hosts.
Uri? parseExplorerServer(String input) {
  final text = input.trim();
  if (text.isEmpty) {
    return null;
  }
  final uri = Uri.tryParse(text);
  if (uri == null) {
    return null;
  }
  try {
    // Building a client only checks the URL. It opens no connection.
    EsploraClient(baseUrl: uri);

    return uri;
  } on ArgumentError {
    return null;
  }
}

/// Owns the one explorer client of the app, so the rate-limit lockout and
/// the session cache are shared by every explorer screen.
///
/// No client is created while the explorer is off. Closing the session
/// drops the client and its cache.
final class ExplorerSession {
  ExplorerSession({
    required this.settings,
    ExplorerApi Function(Uri server)? apiFactory,
  }) : _apiFactory = apiFactory ?? _defaultApi;

  /// The session used by the app for [settings]. One per settings controller.
  static final Expando<ExplorerSession> _sessions = Expando<ExplorerSession>(
    'explorer session',
  );

  static ExplorerSession of(AppSettingsController settings) {
    return _sessions[settings] ??= ExplorerSession(settings: settings);
  }

  /// Replaces the session for [settings]. Tests use it to inject a fake API.
  static void replaceFor(
    AppSettingsController settings,
    ExplorerSession value,
  ) {
    _sessions[settings] = value;
  }

  static ExplorerApi _defaultApi(Uri server) {
    return EsploraExplorerApi(EsploraClient(baseUrl: server));
  }

  final AppSettingsController settings;
  final ExplorerApi Function(Uri server) _apiFactory;

  ExplorerApi? _api;
  String? _apiServer;

  /// The API for the server in settings. Null when the explorer is off or
  /// the stored server is not allowed. Creates a client only when on.
  ExplorerApi? activeApi() {
    if (!settings.explorerEnabled) {
      close();

      return null;
    }

    final server = settings.explorerServer;
    final current = _api;
    if (current != null && _apiServer == server) {
      return current;
    }

    close();
    final uri = parseExplorerServer(server);
    if (uri == null) {
      return null;
    }

    final created = _apiFactory(uri);
    _api = created;
    _apiServer = server;

    return created;
  }

  /// Drops the client and its cache. Called when the explorer is turned off.
  void close() {
    _api?.close();
    _api = null;
    _apiServer = null;
  }
}

/// A short wait after a rate limit. While it runs the search button stays
/// disabled. No request is sent when it ends.
final class ExplorerCooldown {
  Timer? _timer;

  /// True while the wait runs.
  bool get active => _timer != null;

  void start(Duration wait, void Function() onEnd) {
    _timer?.cancel();
    _timer = Timer(wait, () {
      _timer = null;
      onEnd();
    });
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
