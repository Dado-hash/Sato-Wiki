import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'esplora_models.dart';

/// Default Esplora server, the public mempool.space API.
const String defaultEsploraBaseUrl = 'https://mempool.space/api';

/// Why an explorer call failed.
enum ExplorerFailure {
  /// No connection, DNS or TLS failure, or the server cannot be reached.
  network,

  /// The whole exchange, including the body, took longer than the timeout.
  timeout,

  /// HTTP 404: the server does not know the block, transaction or address.
  notFound,

  /// HTTP 429: the server asks the client to slow down.
  rateLimited,

  /// The response is malformed, too large, redirected or has an unexpected
  /// status.
  badResponse,

  /// The input is not a valid hash, height or address. No request was sent.
  invalidInput,

  /// The client is paused after rate limiting. No request was sent.
  lockedOut,
}

/// A failed explorer call.
///
/// [message] is a short English note for developers. It is not user-facing
/// text.
final class ExplorerException implements Exception {
  /// Creates an exception for [failure].
  const ExplorerException(this.failure, this.message, {this.retryAfter});

  /// The failure category.
  final ExplorerFailure failure;

  /// Short English note for developers.
  final String message;

  /// How long to wait before calling again, when the server or the lockout
  /// says so.
  final Duration? retryAfter;

  @override
  String toString() => 'ExplorerException(${failure.name}): $message';
}

const _maxBodyBytes = 2 * 1024 * 1024;
const _maxCacheEntries = 200;
const _volatileTtl = Duration(seconds: 60);
const _baseLockout = Duration(seconds: 60);
const _maxLockout = Duration(minutes: 15);
const _maxLockoutDoublings = 20;

final _heightResponse = RegExp(r'^[0-9]{1,9}$');
final _hashPattern = RegExp(r'^[0-9a-fA-F]{64}$');
final _addressPattern = RegExp(r'^[A-Za-z0-9]{14,90}$');
final _hexPattern = RegExp(r'^(?:[0-9a-fA-F]{2})+$');

/// Read-only client for an Esplora REST server.
///
/// Every call validates its input before it touches the network. Responses
/// are cached in memory for the session only. A 429 pauses all calls with
/// [lockoutRemaining] set. Nothing is retried, polled or logged.
final class EsploraClient {
  /// Creates a client for the server at [baseUrl].
  ///
  /// Throws [ArgumentError] unless [baseUrl] is https. Plain http is allowed
  /// only for localhost, 127.0.0.1, ::1 and `.onion` or `.local` hosts.
  /// [httpClient] is used as given and is never closed by this class. When it
  /// is omitted, each request gets its own `HttpClient`, closed when the
  /// request ends.
  EsploraClient({
    required Uri baseUrl,
    HttpClient? httpClient,
    this.timeout = const Duration(seconds: 15),
    DateTime Function()? now,
  }) : _baseUrl = _validatedBaseUrl(baseUrl),
       _injectedClient = httpClient,
       _now = now ?? DateTime.now;

  /// Total deadline for one request, from connect to the last body byte.
  final Duration timeout;

  final Uri _baseUrl;
  final HttpClient? _injectedClient;
  final DateTime Function() _now;
  final _SessionCache _cache = _SessionCache();
  final Map<String, Future<Object>> _inFlight = <String, Future<Object>>{};
  final Set<HttpClient> _liveClients = <HttpClient>{};
  int _consecutiveRateLimits = 0;
  DateTime? _lockedUntil;
  bool _closed = false;

  /// Time left in the rate-limit lockout, or null when calls are allowed.
  Duration? get lockoutRemaining {
    final until = _lockedUntil;
    if (until == null) {
      return null;
    }
    final remaining = until.difference(_now());

    return remaining > Duration.zero ? remaining : null;
  }

  /// Height of the best block (`/blocks/tip/height`). Cached for 60 seconds.
  Future<int> tipHeight() {
    return _get<int>(
      path: '/blocks/tip/height',
      parse: _parseTipHeight,
      ttl: _volatile,
    );
  }

  /// Hash of the block at [height] (`/block-height/:height`). Cached for 60
  /// seconds.
  Future<String> blockHashAtHeight(int height) async {
    if (height < 0 || height > 10000000) {
      throw _invalid('Height must be between 0 and 10000000.');
    }

    return _get<String>(
      path: '/block-height/$height',
      parse: (body) => _parseHash(body.trim()),
      ttl: _volatile,
    );
  }

  /// Block by [hash] (`/block/:hash`). Cached for the session.
  Future<EsploraBlock> block(String hash) async {
    final checked = _checkHash(hash);

    return _get<EsploraBlock>(
      path: '/block/$checked',
      parse: (body) => EsploraBlock.fromJson(_decodeObject(body)),
      ttl: _forever,
    );
  }

  /// Transaction ids of the block [hash] (`/block/:hash/txids`). Cached for
  /// the session.
  Future<List<String>> blockTxids(String hash) async {
    final checked = _checkHash(hash);

    return _get<List<String>>(
      path: '/block/$checked/txids',
      parse: _parseTxids,
      ttl: _forever,
    );
  }

  /// Transaction [txid] (`/tx/:txid`). Confirmed transactions are cached for
  /// the session. Unconfirmed ones for 60 seconds.
  Future<EsploraTransaction> transaction(String txid) async {
    final checked = _checkHash(txid);

    return _get<EsploraTransaction>(
      path: '/tx/$checked',
      parse: (body) => EsploraTransaction.fromJson(_decodeObject(body)),
      ttl: (tx) => tx.status.confirmed ? null : _volatileTtl,
    );
  }

  /// Raw serialized transaction [txid] as hex (`/tx/:txid/hex`). Cached for
  /// the session.
  Future<String> transactionHex(String txid) async {
    final checked = _checkHash(txid);

    return _get<String>(
      path: '/tx/$checked/hex',
      parse: _parseHex,
      ttl: _forever,
    );
  }

  /// Balances and counts of [address] (`/address/:address`). Cached for 60
  /// seconds.
  Future<EsploraAddressStats> address(String address) async {
    final checked = _checkAddress(address);

    return _get<EsploraAddressStats>(
      path: '/address/$checked',
      parse: (body) => EsploraAddressStats.fromJson(_decodeObject(body)),
      ttl: _volatile,
    );
  }

  /// Transactions of [address], newest first (`/address/:address/txs`).
  ///
  /// The first page holds the mempool transactions and the first 25 confirmed
  /// ones. Pass [afterTxid], the last txid of the previous page, to get the
  /// next page of confirmed transactions
  /// (`/address/:address/txs/chain/:last_seen_txid`). Cached for 60 seconds.
  Future<List<EsploraTransaction>> addressTransactions(
    String address, {
    String? afterTxid,
  }) async {
    final checkedAddress = _checkAddress(address);
    final suffix = afterTxid == null ? '' : '/chain/${_checkHash(afterTxid)}';

    return _get<List<EsploraTransaction>>(
      path: '/address/$checkedAddress/txs$suffix',
      parse: (body) => List.unmodifiable(
        _decodeObjectList(body).map(EsploraTransaction.fromJson),
      ),
      ttl: _volatile,
    );
  }

  /// Forgets every cached response. Does not clear the lockout.
  void clearCache() {
    _cache.clear();
  }

  /// Closes the client. Requests in flight fail, and later calls fail with a
  /// network exception. An injected `HttpClient` is left open.
  void close() {
    _closed = true;
    for (final client in _liveClients.toList()) {
      client.close(force: true);
    }
    _liveClients.clear();
    _cache.clear();
  }

  Future<T> _get<T extends Object>({
    required String path,
    required T Function(String body) parse,
    required Duration? Function(T value) ttl,
  }) async {
    if (_closed) {
      throw const ExplorerException(
        ExplorerFailure.network,
        'The explorer client is closed.',
      );
    }
    // Cached data is served even during a lockout: it needs no network call.
    final cached = _cache.get(path, _now());
    if (cached != null) {
      return cached as T;
    }
    _throwIfLockedOut();

    final pending = _inFlight[path];
    if (pending != null) {
      return await pending as T;
    }

    final future = _download<T>(path: path, parse: parse, ttl: ttl);
    _inFlight[path] = future;
    unawaited(
      future.then<void>(
        (_) {
          _inFlight.remove(path);
        },
        onError: (Object _) {
          _inFlight.remove(path);
        },
      ),
    );

    return future;
  }

  Future<T> _download<T extends Object>({
    required String path,
    required T Function(String body) parse,
    required Duration? Function(T value) ttl,
  }) async {
    final body = await _send(path);
    final T value;
    try {
      value = parse(body);
    } on FormatException catch (error) {
      throw ExplorerException(
        ExplorerFailure.badResponse,
        'Unexpected explorer response: ${error.message}',
      );
    }

    final lifetime = ttl(value);
    _cache.put(path, value, lifetime == null ? null : _now().add(lifetime));

    return value;
  }

  Future<String> _send(String path) async {
    final uri = _baseUrl.replace(path: '${_baseUrl.path}$path');
    final injected = _injectedClient;
    final owned = injected == null;
    final client = injected ?? (HttpClient()..connectionTimeout = timeout);
    if (owned) {
      _liveClients.add(client);
    }

    try {
      return await _exchange(client, uri).timeout(
        timeout,
        onTimeout: () {
          if (owned) {
            client.close(force: true);
          }
          throw TimeoutException('Explorer request timed out.', timeout);
        },
      );
    } on TimeoutException {
      throw ExplorerException(
        ExplorerFailure.timeout,
        'Explorer request timed out after ${timeout.inMilliseconds} ms.',
      );
    } on IOException {
      throw const ExplorerException(
        ExplorerFailure.network,
        'Explorer server could not be reached.',
      );
    } on FormatException {
      throw const ExplorerException(
        ExplorerFailure.badResponse,
        'Explorer response is not valid UTF-8.',
      );
    } finally {
      if (owned) {
        _liveClients.remove(client);
        client.close(force: true);
      }
    }
  }

  Future<String> _exchange(HttpClient client, Uri uri) async {
    final request = await client.getUrl(uri);
    request
      ..followRedirects = false
      ..headers.set(HttpHeaders.acceptHeader, 'application/json, text/plain');
    final response = await request.close();
    final status = response.statusCode;

    if (status == HttpStatus.ok) {
      _consecutiveRateLimits = 0;
      _lockedUntil = null;

      return _readBody(response);
    }

    await _discard(response);
    if (status == HttpStatus.notFound) {
      throw const ExplorerException(
        ExplorerFailure.notFound,
        'The explorer server does not know this item.',
      );
    }
    if (status == HttpStatus.tooManyRequests) {
      throw _startLockout(response.headers.value(HttpHeaders.retryAfterHeader));
    }
    if (status >= 300 && status < 400) {
      throw const ExplorerException(
        ExplorerFailure.badResponse,
        'Redirects are not followed.',
      );
    }

    throw ExplorerException(
      ExplorerFailure.badResponse,
      'Unexpected HTTP status $status.',
    );
  }

  Future<String> _readBody(HttpClientResponse response) async {
    if (response.contentLength > _maxBodyBytes) {
      throw const ExplorerException(
        ExplorerFailure.badResponse,
        'Explorer response is larger than 2 MB.',
      );
    }

    final builder = BytesBuilder(copy: false);
    var received = 0;
    await for (final chunk in response) {
      received += chunk.length;
      if (received > _maxBodyBytes) {
        throw const ExplorerException(
          ExplorerFailure.badResponse,
          'Explorer response is larger than 2 MB.',
        );
      }
      builder.add(chunk);
    }

    return utf8.decode(builder.takeBytes());
  }

  Future<void> _discard(HttpClientResponse response) async {
    try {
      await response.drain<void>();
    } on Object {
      // The response is being abandoned anyway.
    }
  }

  ExplorerException _startLockout(String? retryAfterHeader) {
    _consecutiveRateLimits += 1;
    final previousRateLimits = _consecutiveRateLimits - 1;
    final doublings = previousRateLimits > _maxLockoutDoublings
        ? _maxLockoutDoublings
        : previousRateLimits;
    var lockout = _baseLockout * (1 << doublings);
    if (lockout > _maxLockout) {
      lockout = _maxLockout;
    }

    final requested = _parseRetryAfter(retryAfterHeader);
    if (requested != null && requested > lockout) {
      lockout = requested > _maxLockout ? _maxLockout : requested;
    }

    _lockedUntil = _now().add(lockout);

    return ExplorerException(
      ExplorerFailure.rateLimited,
      'The explorer server returned HTTP 429. Calls are paused.',
      retryAfter: lockout,
    );
  }

  void _throwIfLockedOut() {
    final remaining = lockoutRemaining;
    if (remaining != null) {
      throw ExplorerException(
        ExplorerFailure.lockedOut,
        'Calls are paused after rate limiting.',
        retryAfter: remaining,
      );
    }
  }

  static Duration? _parseRetryAfter(String? value) {
    final seconds = int.tryParse(value?.trim() ?? '');
    if (seconds == null || seconds < 0) {
      return null;
    }

    return Duration(seconds: seconds);
  }

  static Uri _validatedBaseUrl(Uri baseUrl) {
    final host = baseUrl.host.toLowerCase();
    if (!baseUrl.isAbsolute || host.isEmpty) {
      throw ArgumentError.value(
        baseUrl,
        'baseUrl',
        'must be an absolute URL with a host',
      );
    }
    if (baseUrl.userInfo.isNotEmpty ||
        baseUrl.hasQuery ||
        baseUrl.hasFragment) {
      throw ArgumentError.value(
        baseUrl,
        'baseUrl',
        'must not contain user info, a query or a fragment',
      );
    }

    final secure = baseUrl.scheme == 'https';
    final local = baseUrl.scheme == 'http' && _isLocalHost(host);
    if (!secure && !local) {
      throw ArgumentError.value(
        baseUrl,
        'baseUrl',
        'must use https, or http only for localhost, loopback or '
            '.onion and .local hosts',
      );
    }

    final path = baseUrl.path.endsWith('/')
        ? baseUrl.path.substring(0, baseUrl.path.length - 1)
        : baseUrl.path;

    return baseUrl.replace(path: path);
  }

  static bool _isLocalHost(String host) {
    return host == 'localhost' ||
        host == '127.0.0.1' ||
        host == '::1' ||
        host.endsWith('.onion') ||
        host.endsWith('.local');
  }

  static ExplorerException _invalid(String message) {
    return ExplorerException(ExplorerFailure.invalidInput, message);
  }

  static String _checkHash(String value) {
    if (!_hashPattern.hasMatch(value)) {
      throw _invalid('Hashes and txids must be 64 hexadecimal characters.');
    }

    return value.toLowerCase();
  }

  static String _checkAddress(String value) {
    if (!_addressPattern.hasMatch(value)) {
      throw _invalid('Addresses must be 14 to 90 letters or digits.');
    }

    return value;
  }

  static int _parseTipHeight(String body) {
    final text = body.trim();
    if (!_heightResponse.hasMatch(text)) {
      throw const FormatException('tip height is not a number');
    }

    return int.parse(text);
  }

  static String _parseHash(String text) {
    if (!_hashPattern.hasMatch(text)) {
      throw const FormatException('block hash is not 64 hex characters');
    }

    return text.toLowerCase();
  }

  static String _parseHex(String body) {
    final text = body.trim();
    if (!_hexPattern.hasMatch(text)) {
      throw const FormatException('transaction hex is not valid hex');
    }

    return text.toLowerCase();
  }

  static List<String> _parseTxids(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! List<Object?>) {
      throw const FormatException('txids must be a list');
    }

    final result = <String>[];
    for (final item in decoded) {
      if (item is! String) {
        throw const FormatException('txids must be strings');
      }
      result.add(item);
    }

    return List.unmodifiable(result);
  }

  static Map<String, Object?> _decodeObject(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, Object?>) {
      return decoded;
    }

    throw const FormatException('response must be a JSON object');
  }

  static List<Map<String, Object?>> _decodeObjectList(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! List<Object?>) {
      throw const FormatException('response must be a JSON list');
    }

    final result = <Map<String, Object?>>[];
    for (final item in decoded) {
      if (item is! Map<String, Object?>) {
        throw const FormatException('list items must be JSON objects');
      }
      result.add(item);
    }

    return result;
  }

  static Duration? _volatile(Object? _) => _volatileTtl;

  static Duration? _forever(Object? _) => null;
}

/// LRU map of successful responses. Entries past their expiry count as
/// misses.
final class _SessionCache {
  final LinkedHashMap<String, _CacheEntry> _entries =
      LinkedHashMap<String, _CacheEntry>();

  Object? get(String key, DateTime now) {
    final entry = _entries.remove(key);
    if (entry == null) {
      return null;
    }
    final expiresAt = entry.expiresAt;
    if (expiresAt != null && !now.isBefore(expiresAt)) {
      return null;
    }
    _entries[key] = entry;

    return entry.value;
  }

  void put(String key, Object value, DateTime? expiresAt) {
    _entries.remove(key);
    _entries[key] = _CacheEntry(value, expiresAt);
    while (_entries.length > _maxCacheEntries) {
      _entries.remove(_entries.keys.first);
    }
  }

  void clear() {
    _entries.clear();
  }
}

final class _CacheEntry {
  const _CacheEntry(this.value, this.expiresAt);

  final Object value;
  final DateTime? expiresAt;
}
