import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sato_wiki/src/features/tools/data/esplora_client.dart';

// Every request goes to a fake server on 127.0.0.1. No test contacts the
// internet.

const _genesisId =
    '000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f';
const _genesisCoinbaseTxid =
    '4a5e1e4baab89f3a32518a88c31bc87f618f76673e2cc77ab2127b7afdeda33b';
const _address = '1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa';
const _segwitTxid =
    '19b07dc823648870150e9425aa994195f4250511784eece89eefe8d75a13e00d';
const _prevTxid =
    '142b72c2847faee404e6b4d2c2bda64339fd5cf52c5bf87735c036e95d4a4868';
const _tipHash =
    'f8ffe0e0425c3ac96d1f2642b4d2d1ab96967b0f3fab2b43935784896982c5f0';

/// A 64-character hash that differs for each [n].
String _hashOf(int n) => n.toRadixString(16).padLeft(64, '0');

/// Test clock, read by the client through its `now` parameter.
final class _Clock {
  DateTime value = DateTime.utc(2026, 10, 13, 12);

  DateTime read() => value;

  void advance(Duration by) {
    value = value.add(by);
  }
}

/// One canned HTTP reply.
final class _Reply {
  const _Reply(
    this.body, {
    this.status = HttpStatus.ok,
    this.contentType = 'application/json',
    this.headers = const {},
  }) : never = false;

  /// A reply that is never sent, so the client sees a silent server.
  const _Reply.never()
    : body = '',
      status = HttpStatus.ok,
      contentType = 'text/plain',
      headers = const {},
      never = true;

  final String body;
  final int status;
  final String contentType;
  final Map<String, String> headers;
  final bool never;
}

/// Loopback HTTP server that records the request paths it receives.
final class _FakeServer {
  _FakeServer._(this._server);

  final HttpServer _server;
  final List<String> requested = <String>[];
  final Map<String, List<_Reply>> _routes = <String, List<_Reply>>{};

  /// Answers paths without a fixed route. Null means 404.
  _Reply Function(String path)? fallback;

  static Future<_FakeServer> start() async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final fake = _FakeServer._(server);
    server.listen(fake._handle);

    return fake;
  }

  int get port => _server.port;

  String get origin => 'http://127.0.0.1:$port';

  /// Every request to [path] gets [reply].
  void route(String path, _Reply reply) {
    _routes[path] = <_Reply>[reply];
  }

  /// Requests to [path] get [replies] in order. The last one repeats.
  void routeSequence(String path, List<_Reply> replies) {
    _routes[path] = List<_Reply>.of(replies);
  }

  Future<void> close() => _server.close(force: true);

  void _handle(HttpRequest request) {
    final path = request.uri.path;
    requested.add(path);
    final reply = _next(path);
    if (reply.never) {
      return;
    }

    final response = request.response
      ..statusCode = reply.status
      ..headers.contentType = ContentType.parse(reply.contentType);
    for (final header in reply.headers.entries) {
      response.headers.set(header.key, header.value);
    }
    response.add(utf8.encode(reply.body));
    unawaited(response.close());
  }

  _Reply _next(String path) {
    final queue = _routes[path];
    if (queue != null) {
      return queue.length > 1 ? queue.removeAt(0) : queue.first;
    }
    final fallbackReply = fallback;
    if (fallbackReply != null) {
      return fallbackReply(path);
    }

    return const _Reply('{"error":"not found"}', status: HttpStatus.notFound);
  }
}

EsploraClient _client(
  _FakeServer server, {
  String path = '/api',
  Duration timeout = const Duration(seconds: 5),
  DateTime Function()? now,
}) {
  return EsploraClient(
    baseUrl: Uri.parse('${server.origin}$path'),
    timeout: timeout,
    now: now,
  );
}

Map<String, Object?> _blockJson(String id) => <String, Object?>{
  'id': id,
  'height': 0,
  'version': 1,
  'timestamp': 1231006505,
  'tx_count': 1,
  'size': 285,
  'weight': 1140,
  'merkle_root': _genesisCoinbaseTxid,
  'previousblockhash': null,
  'nonce': 2083236893,
  'bits': 486604799,
  'difficulty': 1,
};

Map<String, Object?> _coinbaseTxJson() => <String, Object?>{
  'txid': _genesisCoinbaseTxid,
  'version': 1,
  'locktime': 0,
  'size': 204,
  'weight': 816,
  'vin': <Object?>[
    <String, Object?>{
      'txid': '0' * 64,
      'vout': 4294967295,
      'is_coinbase': true,
      'scriptsig': '04ffff001d010455',
      'scriptsig_asm': 'OP_PUSHBYTES_4 ffff001d',
      'sequence': 4294967295,
      'witness': <Object?>[],
      'prevout': null,
    },
  ],
  'vout': <Object?>[
    <String, Object?>{
      'scriptpubkey': '4104678afdb0fe5548',
      'scriptpubkey_asm': 'OP_PUSHBYTES_65 OP_CHECKSIG',
      'scriptpubkey_type': 'p2pk',
      'value': 5000000000,
    },
  ],
  'status': <String, Object?>{
    'confirmed': true,
    'block_height': 0,
    'block_hash': _genesisId,
    'block_time': 1231006505,
  },
};

Map<String, Object?> _segwitTxJson({
  String txid = _segwitTxid,
  bool confirmed = true,
}) => <String, Object?>{
  'txid': txid,
  'version': 2,
  'locktime': 0,
  'size': 222,
  'weight': 561,
  'fee': 1500,
  'vin': <Object?>[
    <String, Object?>{
      'txid': _prevTxid,
      'vout': 1,
      'is_coinbase': false,
      'scriptsig': '',
      'scriptsig_asm': '',
      'witness': <Object?>['3045022100aa01', '02cc'],
      'sequence': 4294967293,
      'prevout': <String, Object?>{
        'scriptpubkey': '0014751e76e8199196d454941c45d1b3a323f1433bd6',
        'scriptpubkey_asm': 'OP_0 OP_PUSHBYTES_20 751e',
        'scriptpubkey_type': 'v0_p2wpkh',
        'scriptpubkey_address': 'bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4',
        'value': 100000,
      },
    },
  ],
  'vout': <Object?>[
    <String, Object?>{
      'scriptpubkey':
          '00201863143c14c5166804bd19203356da136c985678cd4d27a1b8c6329604903262',
      'scriptpubkey_asm': 'OP_0 OP_PUSHBYTES_32 1863',
      'scriptpubkey_type': 'v0_p2wsh',
      'scriptpubkey_address':
          'bc1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3qccfmv3',
      'value': 98500,
    },
  ],
  'status': confirmed
      ? <String, Object?>{
          'confirmed': true,
          'block_height': 850000,
          'block_hash': _tipHash,
          'block_time': 1760000000,
        }
      : <String, Object?>{'confirmed': false},
};

Map<String, Object?> _addressStatsJson() => <String, Object?>{
  'address': _address,
  'chain_stats': <String, Object?>{
    'funded_txo_count': 1,
    'funded_txo_sum': 5000000000,
    'spent_txo_count': 0,
    'spent_txo_sum': 0,
    'tx_count': 1,
  },
  'mempool_stats': <String, Object?>{
    'funded_txo_count': 0,
    'funded_txo_sum': 0,
    'spent_txo_count': 0,
    'spent_txo_sum': 0,
    'tx_count': 0,
  },
};

_Reply _json(Object value, {int status = HttpStatus.ok}) {
  return _Reply(jsonEncode(value), status: status);
}

Matcher _failure(ExplorerFailure failure) {
  return throwsA(
    isA<ExplorerException>().having((e) => e.failure, 'failure', failure),
  );
}

void main() {
  group('happy paths and request paths', () {
    test('tipHeight reads the plain-text height', () async {
      final server = await _FakeServer.start();
      addTearDown(server.close);
      server.route(
        '/api/blocks/tip/height',
        const _Reply('850000\n', contentType: 'text/plain'),
      );

      final height = await _client(server).tipHeight();

      expect(height, 850000);
      expect(server.requested, ['/api/blocks/tip/height']);
    });

    test('a base URL with a trailing slash is normalized', () async {
      final server = await _FakeServer.start();
      addTearDown(server.close);
      server.route(
        '/api/blocks/tip/height',
        const _Reply('1', contentType: 'text/plain'),
      );

      await _client(server, path: '/api/').tipHeight();

      expect(server.requested, ['/api/blocks/tip/height']);
    });

    test('blockHashAtHeight', () async {
      final server = await _FakeServer.start();
      addTearDown(server.close);
      server.route(
        '/api/block-height/850000',
        const _Reply('$_tipHash\n', contentType: 'text/plain'),
      );

      final hash = await _client(server).blockHashAtHeight(850000);

      expect(hash, _tipHash);
      expect(server.requested, ['/api/block-height/850000']);
    });

    test('block parses the block and uses a lower-case path', () async {
      final server = await _FakeServer.start();
      addTearDown(server.close);
      server.route('/api/block/$_genesisId', _json(_blockJson(_genesisId)));

      final block = await _client(server).block(_genesisId.toUpperCase());

      expect(block.id, _genesisId);
      expect(block.txCount, 1);
      expect(block.previousBlockHash, isNull);
      expect(server.requested, ['/api/block/$_genesisId']);
    });

    test('blockTxids', () async {
      final server = await _FakeServer.start();
      addTearDown(server.close);
      server.route(
        '/api/block/$_genesisId/txids',
        _json(<String>[_genesisCoinbaseTxid]),
      );

      final txids = await _client(server).blockTxids(_genesisId);

      expect(txids, [_genesisCoinbaseTxid]);
      expect(server.requested, ['/api/block/$_genesisId/txids']);
    });

    test('transaction parses a coinbase with no fee and no prevout', () async {
      final server = await _FakeServer.start();
      addTearDown(server.close);
      server.route('/api/tx/$_genesisCoinbaseTxid', _json(_coinbaseTxJson()));

      final tx = await _client(server).transaction(_genesisCoinbaseTxid);

      expect(tx.fee, isNull);
      expect(tx.inputs.single.isCoinbase, isTrue);
      expect(tx.inputs.single.prevout, isNull);
      expect(tx.outputs.single.valueSatoshi, 5000000000);
      expect(server.requested, ['/api/tx/$_genesisCoinbaseTxid']);
    });

    test('transaction parses a segwit transaction with witness', () async {
      final server = await _FakeServer.start();
      addTearDown(server.close);
      server.route('/api/tx/$_segwitTxid', _json(_segwitTxJson()));

      final tx = await _client(server).transaction(_segwitTxid);

      expect(tx.fee, 1500);
      expect(tx.inputs.single.witness, hasLength(2));
      expect(tx.inputs.single.prevout!.valueSatoshi, 100000);
      expect(tx.status.blockHeight, 850000);
    });

    test('transactionHex', () async {
      final server = await _FakeServer.start();
      addTearDown(server.close);
      server.route(
        '/api/tx/$_segwitTxid/hex',
        const _Reply('0200000001ab\n', contentType: 'text/plain'),
      );

      final hex = await _client(server).transactionHex(_segwitTxid);

      expect(hex, '0200000001ab');
      expect(server.requested, ['/api/tx/$_segwitTxid/hex']);
    });

    test('address', () async {
      final server = await _FakeServer.start();
      addTearDown(server.close);
      server.route('/api/address/$_address', _json(_addressStatsJson()));

      final stats = await _client(server).address(_address);

      expect(stats.chain.fundedTxoSum, 5000000000);
      expect(stats.mempool.txCount, 0);
      expect(server.requested, ['/api/address/$_address']);
    });

    test('addressTransactions first page', () async {
      final server = await _FakeServer.start();
      addTearDown(server.close);
      server.route(
        '/api/address/$_address/txs',
        _json(<Object?>[_segwitTxJson()]),
      );

      final txs = await _client(server).addressTransactions(_address);

      expect(txs.single.txid, _segwitTxid);
      expect(server.requested, ['/api/address/$_address/txs']);
    });

    test('addressTransactions next page uses the chain path', () async {
      final server = await _FakeServer.start();
      addTearDown(server.close);
      server.route(
        '/api/address/$_address/txs/chain/$_prevTxid',
        _json(<Object?>[]),
      );

      final txs = await _client(
        server,
      ).addressTransactions(_address, afterTxid: _prevTxid);

      expect(txs, isEmpty);
      expect(server.requested, ['/api/address/$_address/txs/chain/$_prevTxid']);
    });

    test('the default base URL is mempool.space', () {
      expect(defaultEsploraBaseUrl, 'https://mempool.space/api');
    });
  });

  group('errors', () {
    test('HTTP 404 is notFound', () async {
      final server = await _FakeServer.start();
      addTearDown(server.close);
      server.route(
        '/api/block/$_genesisId',
        const _Reply('Block not found', status: HttpStatus.notFound),
      );

      await expectLater(
        _client(server).block(_genesisId),
        _failure(ExplorerFailure.notFound),
      );
    });

    test('malformed JSON is badResponse', () async {
      final server = await _FakeServer.start();
      addTearDown(server.close);
      server.route('/api/block/$_genesisId', const _Reply('{"id":'));

      await expectLater(
        _client(server).block(_genesisId),
        _failure(ExplorerFailure.badResponse),
      );
    });

    test('a wrong type inside JSON is badResponse, not a TypeError', () async {
      final server = await _FakeServer.start();
      addTearDown(server.close);
      final block = _blockJson(_genesisId)..['height'] = '0';
      server.route('/api/block/$_genesisId', _json(block));

      await expectLater(
        _client(server).block(_genesisId),
        _failure(ExplorerFailure.badResponse),
      );
    });

    test('a JSON list where an object belongs is badResponse', () async {
      final server = await _FakeServer.start();
      addTearDown(server.close);
      server.route('/api/tx/$_segwitTxid', _json(<Object?>[1, 2]));

      await expectLater(
        _client(server).transaction(_segwitTxid),
        _failure(ExplorerFailure.badResponse),
      );
    });

    test('non-numeric tip height is badResponse', () async {
      final server = await _FakeServer.start();
      addTearDown(server.close);
      server.route(
        '/api/blocks/tip/height',
        const _Reply('abc', contentType: 'text/plain'),
      );

      await expectLater(
        _client(server).tipHeight(),
        _failure(ExplorerFailure.badResponse),
      );
    });

    test('a block hash that is not 64 hex characters is badResponse', () async {
      final server = await _FakeServer.start();
      addTearDown(server.close);
      server.route(
        '/api/block-height/5',
        const _Reply('short', contentType: 'text/plain'),
      );

      await expectLater(
        _client(server).blockHashAtHeight(5),
        _failure(ExplorerFailure.badResponse),
      );
    });

    test('a txid list with a number in it is badResponse', () async {
      final server = await _FakeServer.start();
      addTearDown(server.close);
      server.route('/api/block/$_genesisId/txids', _json(<Object?>[1]));

      await expectLater(
        _client(server).blockTxids(_genesisId),
        _failure(ExplorerFailure.badResponse),
      );
    });

    test('transaction hex that is not hex is badResponse', () async {
      final server = await _FakeServer.start();
      addTearDown(server.close);
      server.route(
        '/api/tx/$_segwitTxid/hex',
        const _Reply('zz', contentType: 'text/plain'),
      );

      await expectLater(
        _client(server).transactionHex(_segwitTxid),
        _failure(ExplorerFailure.badResponse),
      );
    });

    test('a body over 2 MB is badResponse', () async {
      final server = await _FakeServer.start();
      addTearDown(server.close);
      server.route(
        '/api/block/$_genesisId',
        _Reply('x' * (2 * 1024 * 1024 + 1)),
      );

      await expectLater(
        _client(server).block(_genesisId),
        _failure(ExplorerFailure.badResponse),
      );
    });

    test('an unexpected status is badResponse', () async {
      final server = await _FakeServer.start();
      addTearDown(server.close);
      server.route(
        '/api/block/$_genesisId',
        const _Reply('oops', status: HttpStatus.internalServerError),
      );

      await expectLater(
        _client(server).block(_genesisId),
        _failure(ExplorerFailure.badResponse),
      );
    });

    test('a redirect to another host is not followed', () async {
      final server = await _FakeServer.start();
      addTearDown(server.close);
      final other = await _FakeServer.start();
      addTearDown(other.close);
      other.route(
        '/api/blocks/tip/height',
        const _Reply('1', contentType: 'text/plain'),
      );
      server.route(
        '/api/blocks/tip/height',
        _Reply(
          '',
          status: HttpStatus.movedTemporarily,
          headers: {'location': '${other.origin}/api/blocks/tip/height'},
        ),
      );

      await expectLater(
        _client(server).tipHeight(),
        _failure(ExplorerFailure.badResponse),
      );
      expect(server.requested, ['/api/blocks/tip/height']);
      expect(other.requested, isEmpty);
    });

    test('a server that never answers times out', () async {
      final server = await _FakeServer.start();
      addTearDown(server.close);
      server.route('/api/blocks/tip/height', const _Reply.never());

      await expectLater(
        _client(server, timeout: const Duration(milliseconds: 300)).tipHeight(),
        _failure(ExplorerFailure.timeout),
      );
    });

    test('connection refused is network', () async {
      final probe = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      final port = probe.port;
      await probe.close();
      final client = EsploraClient(
        baseUrl: Uri.parse('http://127.0.0.1:$port/api'),
        timeout: const Duration(seconds: 5),
      );
      addTearDown(client.close);

      await expectLater(client.tipHeight(), _failure(ExplorerFailure.network));
    });

    test('calls after close fail as network with no request', () async {
      final server = await _FakeServer.start();
      addTearDown(server.close);
      final client = _client(server)..close();

      await expectLater(client.tipHeight(), _failure(ExplorerFailure.network));
      expect(server.requested, isEmpty);
    });
  });

  group('rate limiting', () {
    test('cached data is still served during a lockout', () async {
      final server = await _FakeServer.start();
      addTearDown(server.close);
      final clock = _Clock();
      server.route('/api/tx/$_segwitTxid/hex', const _Reply('00ff'));
      server.routeSequence('/api/blocks/tip/height', const [
        _Reply('', status: HttpStatus.tooManyRequests),
      ]);
      final client = _client(server, now: clock.read);

      expect(await client.transactionHex(_segwitTxid), '00ff');
      await expectLater(
        client.tipHeight(),
        _failure(ExplorerFailure.rateLimited),
      );

      expect(await client.transactionHex(_segwitTxid), '00ff');
      expect(server.requested, [
        '/api/tx/$_segwitTxid/hex',
        '/api/blocks/tip/height',
      ]);
    });

    test('a 429 starts a 60 second lockout and blocks the next call', () async {
      final server = await _FakeServer.start();
      addTearDown(server.close);
      final clock = _Clock();
      server.routeSequence('/api/blocks/tip/height', const [
        _Reply('', status: HttpStatus.tooManyRequests),
        _Reply('850000', contentType: 'text/plain'),
      ]);
      final client = _client(server, now: clock.read);

      await expectLater(
        client.tipHeight(),
        throwsA(
          isA<ExplorerException>()
              .having((e) => e.failure, 'failure', ExplorerFailure.rateLimited)
              .having(
                (e) => e.retryAfter,
                'retryAfter',
                const Duration(seconds: 60),
              ),
        ),
      );
      expect(client.lockoutRemaining, const Duration(seconds: 60));

      await expectLater(
        client.block(_genesisId),
        throwsA(
          isA<ExplorerException>()
              .having((e) => e.failure, 'failure', ExplorerFailure.lockedOut)
              .having(
                (e) => e.retryAfter,
                'retryAfter',
                const Duration(seconds: 60),
              ),
        ),
      );
      await expectLater(
        client.tipHeight(),
        _failure(ExplorerFailure.lockedOut),
      );
      expect(server.requested, ['/api/blocks/tip/height']);

      clock.advance(const Duration(seconds: 30));
      expect(client.lockoutRemaining, const Duration(seconds: 30));
    });

    test(
      'the lockout doubles on each consecutive 429 and resets on success',
      () async {
        final server = await _FakeServer.start();
        addTearDown(server.close);
        final clock = _Clock();
        const tooMany = _Reply('', status: HttpStatus.tooManyRequests);
        server.routeSequence('/api/blocks/tip/height', const [
          tooMany,
          tooMany,
          tooMany,
          _Reply('850000', contentType: 'text/plain'),
          tooMany,
        ]);
        final client = _client(server, now: clock.read);

        Future<Duration?> rateLimitRetryAfter() async {
          try {
            await client.tipHeight();
          } on ExplorerException catch (error) {
            return error.retryAfter;
          }

          return null;
        }

        expect(await rateLimitRetryAfter(), const Duration(seconds: 60));
        clock.advance(const Duration(seconds: 60));
        expect(await rateLimitRetryAfter(), const Duration(seconds: 120));
        clock.advance(const Duration(seconds: 120));
        expect(await rateLimitRetryAfter(), const Duration(seconds: 240));

        clock.advance(const Duration(seconds: 240));
        expect(client.lockoutRemaining, isNull);
        expect(await client.tipHeight(), 850000);
        expect(client.lockoutRemaining, isNull);

        client.clearCache();
        expect(await rateLimitRetryAfter(), const Duration(seconds: 60));
      },
    );

    test('the lockout is capped at 15 minutes', () async {
      final server = await _FakeServer.start();
      addTearDown(server.close);
      final clock = _Clock();
      const tooMany = _Reply('', status: HttpStatus.tooManyRequests);
      server.route('/api/blocks/tip/height', tooMany);
      final client = _client(server, now: clock.read);

      Duration? last;
      for (var i = 0; i < 8; i++) {
        try {
          await client.tipHeight();
        } on ExplorerException catch (error) {
          last = error.retryAfter;
        }
        clock.advance(const Duration(minutes: 16));
      }

      expect(last, const Duration(minutes: 15));
    });

    test('a longer Retry-After header is honoured', () async {
      final server = await _FakeServer.start();
      addTearDown(server.close);
      server.route(
        '/api/blocks/tip/height',
        const _Reply(
          '',
          status: HttpStatus.tooManyRequests,
          headers: {'retry-after': '300'},
        ),
      );
      final client = _client(server, now: _Clock().read);

      await expectLater(
        client.tipHeight(),
        throwsA(
          isA<ExplorerException>().having(
            (e) => e.retryAfter,
            'retryAfter',
            const Duration(seconds: 300),
          ),
        ),
      );
      expect(client.lockoutRemaining, const Duration(seconds: 300));
    });

    test('a shorter Retry-After header does not shorten the lockout', () async {
      final server = await _FakeServer.start();
      addTearDown(server.close);
      server.route(
        '/api/blocks/tip/height',
        const _Reply(
          '',
          status: HttpStatus.tooManyRequests,
          headers: {'retry-after': '10'},
        ),
      );
      final client = _client(server, now: _Clock().read);

      await expectLater(
        client.tipHeight(),
        throwsA(
          isA<ExplorerException>().having(
            (e) => e.retryAfter,
            'retryAfter',
            const Duration(seconds: 60),
          ),
        ),
      );
    });

    test('a Retry-After header is capped at 15 minutes', () async {
      final server = await _FakeServer.start();
      addTearDown(server.close);
      server.route(
        '/api/blocks/tip/height',
        const _Reply(
          '',
          status: HttpStatus.tooManyRequests,
          headers: {'retry-after': '5000'},
        ),
      );
      final client = _client(server, now: _Clock().read);

      await expectLater(
        client.tipHeight(),
        throwsA(
          isA<ExplorerException>().having(
            (e) => e.retryAfter,
            'retryAfter',
            const Duration(minutes: 15),
          ),
        ),
      );
    });
  });

  group('session cache', () {
    test('a second identical call is served from memory', () async {
      final server = await _FakeServer.start();
      addTearDown(server.close);
      server.route(
        '/api/blocks/tip/height',
        const _Reply('850000', contentType: 'text/plain'),
      );
      final client = _client(server, now: _Clock().read);

      expect(await client.tipHeight(), 850000);
      expect(await client.tipHeight(), 850000);
      expect(server.requested, hasLength(1));
    });

    test('tipHeight expires after 60 seconds on the injected clock', () async {
      final server = await _FakeServer.start();
      addTearDown(server.close);
      server.route(
        '/api/blocks/tip/height',
        const _Reply('850000', contentType: 'text/plain'),
      );
      final clock = _Clock();
      final client = _client(server, now: clock.read);

      await client.tipHeight();
      clock.advance(const Duration(seconds: 59));
      await client.tipHeight();
      expect(server.requested, hasLength(1));

      clock.advance(const Duration(seconds: 2));
      await client.tipHeight();
      expect(server.requested, hasLength(2));
    });

    test('blocks by hash never expire during the session', () async {
      final server = await _FakeServer.start();
      addTearDown(server.close);
      server.route('/api/block/$_genesisId', _json(_blockJson(_genesisId)));
      final clock = _Clock();
      final client = _client(server, now: clock.read);

      await client.block(_genesisId);
      clock.advance(const Duration(days: 1));
      await client.block(_genesisId);

      expect(server.requested, hasLength(1));
    });

    test('transaction hex never expires during the session', () async {
      final server = await _FakeServer.start();
      addTearDown(server.close);
      server.route(
        '/api/tx/$_segwitTxid/hex',
        const _Reply('0200', contentType: 'text/plain'),
      );
      final clock = _Clock();
      final client = _client(server, now: clock.read);

      await client.transactionHex(_segwitTxid);
      clock.advance(const Duration(days: 1));
      await client.transactionHex(_segwitTxid);

      expect(server.requested, hasLength(1));
    });

    test('confirmed transactions never expire, unconfirmed ones do', () async {
      final server = await _FakeServer.start();
      addTearDown(server.close);
      final unconfirmed = '0' * 63 + '1';
      server.route('/api/tx/$_segwitTxid', _json(_segwitTxJson()));
      server.route(
        '/api/tx/$unconfirmed',
        _json(_segwitTxJson(txid: unconfirmed, confirmed: false)),
      );
      final clock = _Clock();
      final client = _client(server, now: clock.read);

      await client.transaction(_segwitTxid);
      await client.transaction(unconfirmed);
      clock.advance(const Duration(minutes: 61));
      await client.transaction(_segwitTxid);
      await client.transaction(unconfirmed);

      expect(
        server.requested.where((path) => path == '/api/tx/$_segwitTxid'),
        hasLength(1),
      );
      expect(
        server.requested.where((path) => path == '/api/tx/$unconfirmed'),
        hasLength(2),
      );
    });

    test('address stats expire after 60 seconds', () async {
      final server = await _FakeServer.start();
      addTearDown(server.close);
      server.route('/api/address/$_address', _json(_addressStatsJson()));
      final clock = _Clock();
      final client = _client(server, now: clock.read);

      await client.address(_address);
      clock.advance(const Duration(seconds: 61));
      await client.address(_address);

      expect(server.requested, hasLength(2));
    });

    test('the least recently used entry is evicted past 200 entries', () async {
      final server = await _FakeServer.start();
      addTearDown(server.close);
      server.fallback = (path) => _json(_blockJson(_genesisId));
      final client = _client(server, now: _Clock().read);

      for (var i = 1; i <= 200; i++) {
        await client.block(_hashOf(i));
      }
      expect(server.requested, hasLength(200));

      // Touch the oldest entry so that entry 2 becomes the least recent.
      await client.block(_hashOf(1));
      expect(server.requested, hasLength(200));

      await client.block(_hashOf(201));
      expect(server.requested, hasLength(201));

      await client.block(_hashOf(1));
      expect(server.requested, hasLength(201));

      await client.block(_hashOf(2));
      expect(server.requested, hasLength(202));
    });

    test('clearCache forces the next call to the network', () async {
      final server = await _FakeServer.start();
      addTearDown(server.close);
      server.route(
        '/api/blocks/tip/height',
        const _Reply('850000', contentType: 'text/plain'),
      );
      final client = _client(server, now: _Clock().read);

      await client.tipHeight();
      client.clearCache();
      await client.tipHeight();

      expect(server.requested, hasLength(2));
    });

    test('concurrent identical calls share one request', () async {
      final server = await _FakeServer.start();
      addTearDown(server.close);
      server.route(
        '/api/blocks/tip/height',
        const _Reply('850000', contentType: 'text/plain'),
      );
      final client = _client(server, now: _Clock().read);

      final results = await Future.wait([
        client.tipHeight(),
        client.tipHeight(),
        client.tipHeight(),
      ]);

      expect(results, [850000, 850000, 850000]);
      expect(server.requested, hasLength(1));
    });
  });

  group('input validation sends nothing', () {
    test('invalid inputs fail before any request', () async {
      final server = await _FakeServer.start();
      addTearDown(server.close);
      server.fallback = (path) => _json(_blockJson(_genesisId));
      final client = _client(server, now: _Clock().read);

      final bad = <Future<Object?> Function()>[
        () => client.block('abc'),
        () => client.block('g' * 64),
        () => client.block(' ${_hashOf(1)}'),
        () => client.block('${_hashOf(1)}0'),
        () => client.blockTxids(''),
        () => client.transaction('z' * 64),
        () => client.transactionHex('${_hashOf(1).substring(1)}/..'),
        () => client.blockHashAtHeight(-1),
        () => client.blockHashAtHeight(10000001),
        () => client.address('short'),
        () => client.address('1' * 91),
        () => client.address('1A1zP1eP5QGefi2DMPTfTL5SLmv7Div!a'),
        () => client.address('../../etc/passwd'),
        () => client.addressTransactions(_address, afterTxid: 'bad'),
      ];

      for (final call in bad) {
        await expectLater(call(), _failure(ExplorerFailure.invalidInput));
      }
      expect(server.requested, isEmpty);
    });

    test('boundary values are accepted', () async {
      final server = await _FakeServer.start();
      addTearDown(server.close);
      server.route(
        '/api/block-height/10000000',
        _Reply('0' * 63 + '1', contentType: 'text/plain'),
      );
      server.route(
        '/api/block-height/0',
        _Reply('0' * 63 + '2', contentType: 'text/plain'),
      );
      final client = _client(server, now: _Clock().read);

      expect(await client.blockHashAtHeight(10000000), '0' * 63 + '1');
      expect(await client.blockHashAtHeight(0), '0' * 63 + '2');
    });
  });

  group('base URL', () {
    test('plain http to a public host is rejected', () {
      for (final url in [
        'http://mempool.space/api',
        'http://example.com',
        'http://8.8.8.8/api',
      ]) {
        expect(
          () => EsploraClient(baseUrl: Uri.parse(url)),
          throwsArgumentError,
          reason: url,
        );
      }
    });

    test('https is accepted', () {
      final client = EsploraClient(baseUrl: Uri.parse(defaultEsploraBaseUrl));
      addTearDown(client.close);

      expect(client, isNotNull);
    });

    test('http to localhost, loopback, ::1, .onion and .local is accepted', () {
      for (final url in [
        'http://localhost:3006/api',
        'http://127.0.0.1:3006/api',
        'http://[::1]:3006/api',
        'http://abcdef.onion/api',
        'http://node.local/api',
      ]) {
        final client = EsploraClient(baseUrl: Uri.parse(url));
        addTearDown(client.close);
        expect(client, isNotNull, reason: url);
      }
    });

    test('relative URLs, user info and queries are rejected', () {
      for (final url in [
        'mempool.space/api',
        'https://user:secret@mempool.space/api',
        'https://mempool.space/api?key=1',
        'ftp://mempool.space/api',
      ]) {
        expect(
          () => EsploraClient(baseUrl: Uri.parse(url)),
          throwsArgumentError,
          reason: url,
        );
      }
    });
  });

  group('live dashboard calls', () {
    Map<String, Object?> mempoolJson() => <String, Object?>{
      'count': 48213,
      'vsize': 11550000,
      'total_fee': 2345678,
      'fee_histogram': <Object?>[
        <Object?>[120.5, 150000],
        <Object?>[1, 3000000],
      ],
    };

    test('recentBlocks reads GET /blocks', () async {
      final server = await _FakeServer.start();
      addTearDown(server.close);
      server.route('/api/blocks', _json(<Object?>[_blockJson(_genesisId)]));

      final blocks = await _client(server).recentBlocks();

      expect(blocks.single.id, _genesisId);
      expect(server.requested, ['/api/blocks']);
    });

    test('mempoolInfo reads GET /mempool', () async {
      final server = await _FakeServer.start();
      addTearDown(server.close);
      server.route('/api/mempool', _json(mempoolJson()));

      final info = await _client(server).mempoolInfo();

      expect(info.count, 48213);
      expect(info.feeHistogram.first.feeRate, 120.5);
      expect(server.requested, ['/api/mempool']);
    });

    test('feeEstimates reads GET /fee-estimates', () async {
      final server = await _FakeServer.start();
      addTearDown(server.close);
      server.route(
        '/api/fee-estimates',
        _json(<String, Object?>{'1': 8.0, '144': 2}),
      );

      final fees = await _client(server).feeEstimates();

      expect(fees.forTarget(1), 8.0);
      expect(fees.forTarget(144), 2.0);
      expect(server.requested, ['/api/fee-estimates']);
    });

    test('recentMempoolTransactions reads GET /mempool/recent', () async {
      final server = await _FakeServer.start();
      addTearDown(server.close);
      server.route(
        '/api/mempool/recent',
        _json(<Object?>[
          <String, Object?>{
            'txid': _segwitTxid,
            'fee': 1500,
            'vsize': 141,
            'value': 98500,
          },
        ]),
      );

      final txs = await _client(server).recentMempoolTransactions();

      expect(txs.single.txid, _segwitTxid);
      expect(server.requested, ['/api/mempool/recent']);
    });

    test('the four live answers are cached for 15 seconds', () async {
      final server = await _FakeServer.start();
      addTearDown(server.close);
      server.route('/api/blocks', _json(<Object?>[]));
      server.route('/api/mempool', _json(mempoolJson()));
      server.route('/api/fee-estimates', _json(<String, Object?>{'1': 8.0}));
      server.route('/api/mempool/recent', _json(<Object?>[]));
      final clock = _Clock();
      final client = _client(server, now: clock.read);

      Future<void> callAll() async {
        await client.recentBlocks();
        await client.mempoolInfo();
        await client.feeEstimates();
        await client.recentMempoolTransactions();
      }

      await callAll();
      clock.advance(const Duration(seconds: 14));
      await callAll();
      expect(server.requested, hasLength(4));

      clock.advance(const Duration(seconds: 2));
      await callAll();
      expect(server.requested, hasLength(8));
    });

    test('a malformed mempool histogram is badResponse', () async {
      final server = await _FakeServer.start();
      addTearDown(server.close);
      server.route(
        '/api/mempool',
        _json(<String, Object?>{
          ...mempoolJson(),
          'fee_histogram': <Object?>[
            <Object?>[1],
          ],
        }),
      );

      await expectLater(
        _client(server).mempoolInfo(),
        _failure(ExplorerFailure.badResponse),
      );
    });

    test('a recent list with a non-object item is badResponse', () async {
      final server = await _FakeServer.start();
      addTearDown(server.close);
      server.route('/api/blocks', _json(<Object?>[42]));

      await expectLater(
        _client(server).recentBlocks(),
        _failure(ExplorerFailure.badResponse),
      );
    });

    test('a 429 on the mempool call pauses the other live calls', () async {
      final server = await _FakeServer.start();
      addTearDown(server.close);
      server.route(
        '/api/mempool',
        _Reply('{}', status: HttpStatus.tooManyRequests),
      );
      final client = _client(server);

      await expectLater(
        client.mempoolInfo(),
        _failure(ExplorerFailure.rateLimited),
      );
      await expectLater(
        client.feeEstimates(),
        _failure(ExplorerFailure.lockedOut),
      );
      expect(server.requested, ['/api/mempool']);
    });
  });
}
