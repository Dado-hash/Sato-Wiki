import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/esplora_client.dart';
import '../data/esplora_models.dart';
import '../domain/difficulty_epoch.dart';
import '../domain/mempool_projection.dart';
import 'explorer_session.dart';
import 'explorer_widgets.dart';

/// Most projected blocks the strip shows.
const int dashboardProjectedBlocks = 8;

/// What the live dashboard shows. Each section keeps its last good value when
/// a later round fails. Fields are unmodifiable.
final class ExplorerDashboardState {
  /// Creates a snapshot. Empty sections are null.
  const ExplorerDashboardState({
    this.blocks,
    this.mempool,
    this.projected = const <ProjectedBlock>[],
    this.fees,
    this.feesDerived = false,
    this.epoch,
    this.recent,
    this.updatedAt,
    this.requestsPerRound = 4,
    this.loading = false,
    this.error,
  });

  /// Recent confirmed blocks, newest first.
  final List<EsploraBlock>? blocks;

  /// Mempool count, size and fee histogram.
  final EsploraMempoolInfo? mempool;

  /// Blocks the mempool would fill next, nearest first.
  final List<ProjectedBlock> projected;

  /// Fee estimates by confirmation target.
  final EsploraFeeEstimates? fees;

  /// True when [fees] were derived from the mempool because the server gave
  /// no usable `/fee-estimates` answer.
  final bool feesDerived;

  /// Progress of the difficulty epoch.
  final DifficultyEpoch? epoch;

  /// Latest transactions that entered the mempool.
  final List<EsploraRecentTransaction>? recent;

  /// When the last round got at least one answer. Null before that.
  final DateTime? updatedAt;

  /// Calls each refresh makes: 4, or 3 once the server has no
  /// `/fee-estimates`.
  final int requestsPerRound;

  /// True while a round runs.
  final bool loading;

  /// First failure of the last round, or null when it had none.
  final ExplorerException? error;

  /// True when at least one section has data.
  bool get hasData =>
      blocks != null || mempool != null || fees != null || recent != null;

  /// A copy with [loading] changed. Everything else is kept.
  ExplorerDashboardState withLoading({required bool loading}) {
    return ExplorerDashboardState(
      blocks: blocks,
      mempool: mempool,
      projected: projected,
      fees: fees,
      feesDerived: feesDerived,
      epoch: epoch,
      recent: recent,
      updatedAt: updatedAt,
      requestsPerRound: requestsPerRound,
      loading: loading,
      error: error,
    );
  }
}

/// Loads the live dashboard data and refreshes it on a timer.
///
/// A round makes four calls in parallel: recent blocks, mempool, fee
/// estimates and recent mempool transactions. Once the server has answered
/// notFound for fee estimates, the fee call is skipped for the session and a
/// round makes three. Fees the server does not give are derived from the
/// mempool histogram. The start block of the difficulty epoch is looked up
/// once per epoch and cached for the session.
///
/// Refreshes run only while the controller is started, visible and not
/// paused. A rate limit pauses the controller, and only [resume] or
/// [refresh] start calls again. Dispose cancels the timer.
final class ExplorerDashboardController extends ChangeNotifier {
  /// Creates a controller. [api] returns null while the explorer is off, and
  /// then no call is made.
  ExplorerDashboardController({
    required ExplorerApi? Function() api,
    this.interval = const Duration(seconds: 60),
    DateTime Function()? now,
  }) : _api = api,
       _now = now ?? DateTime.now;

  final ExplorerApi? Function() _api;
  final DateTime Function() _now;

  /// Time between two automatic rounds.
  final Duration interval;

  ExplorerDashboardState _state = const ExplorerDashboardState();

  /// The latest snapshot.
  ExplorerDashboardState get state => _state;

  bool _paused = false;

  /// True after [pause] or after a rate limit, until [resume].
  bool get paused => _paused;

  /// True once the server answered notFound for `/fee-estimates`. Later
  /// rounds then derive the fees and skip that call.
  bool _feesUnavailable = false;

  /// Calls each refresh makes now: 3 once `/fee-estimates` is skipped.
  int get requestsPerRound => _feesUnavailable ? 3 : 4;

  bool _started = false;
  bool _visible = true;
  bool _inFlight = false;
  bool _disposed = false;
  Timer? _timer;

  /// Start height of each difficulty epoch seen this session, with its
  /// block time.
  final Map<int, int> _epochStartTimes = <int, int>{};

  /// The clock of the controller, for labels that show elapsed time.
  DateTime now() => _now();

  /// Refreshes once now and then every [interval]. Does nothing when called
  /// twice.
  void start() {
    if (_disposed || _started) {
      return;
    }
    _started = true;
    if (_active) {
      unawaited(refresh());
    }
    _restartTimer();
  }

  /// Stops the timer. The user can still refresh by hand.
  void pause() {
    if (_paused) {
      return;
    }
    _paused = true;
    _restartTimer();
    _notify();
  }

  /// Clears the pause, refreshes now and restarts the timer.
  void resume() {
    if (!_paused) {
      return;
    }
    _paused = false;
    if (_active) {
      unawaited(refresh());
    }
    _restartTimer();
    _notify();
  }

  /// Shows or hides the dashboard. Hidden: no timer and no calls. Shown again
  /// (and not paused): one refresh now, then the timer.
  void setVisible(bool visible) {
    if (_visible == visible) {
      return;
    }
    _visible = visible;
    if (_active) {
      unawaited(refresh());
    }
    _restartTimer();
  }

  bool get _active => _started && _visible && !_paused;

  void _restartTimer() {
    _timer?.cancel();
    _timer = null;
    if (_disposed || !_active) {
      return;
    }
    _timer = Timer.periodic(interval, (_) => unawaited(refresh()));
  }

  /// One round of calls. Ignored while a round runs, and when the explorer is
  /// off. Failures are kept in [ExplorerDashboardState.error].
  Future<void> refresh() async {
    if (_disposed || _inFlight) {
      return;
    }
    final api = _api();
    if (api == null) {
      return;
    }

    _inFlight = true;
    _state = _state.withLoading(loading: true);
    _notify();

    final errors = <ExplorerException>[];
    final feeErrors = <ExplorerException>[];
    final blocksCall = _try(api.recentBlocks, errors);
    final mempoolCall = _try(api.mempoolInfo, errors);
    final feesCall = _feesUnavailable
        ? Future<EsploraFeeEstimates?>.value()
        : _try(api.feeEstimates, feeErrors);
    final recentCall = _try(api.recentMempoolTransactions, errors);
    final blocks = await blocksCall;
    final mempool = await mempoolCall;
    final serverFees = await feesCall;
    final recent = await recentCall;

    // Other fee failures are expected on some servers, so only a rate limit
    // is reported. A notFound counts as "no /fee-estimates" only when the
    // server answered the other calls of the round.
    final answered = blocks != null || mempool != null || recent != null;
    if (answered &&
        feeErrors.any((error) => error.failure == ExplorerFailure.notFound)) {
      _feesUnavailable = true;
    }
    errors.addAll(feeErrors.where(explorerIsRateLimit));

    final previous = _state;
    final epoch = blocks == null || blocks.isEmpty
        ? previous.epoch
        : await _epochFor(api, blocks.first, errors) ?? previous.epoch;

    // The mempool of this round, or else the last one, gives the fees when
    // the server gave none.
    final histogramMempool = mempool ?? previous.mempool;
    final projected = mempool == null
        ? previous.projected
        : projectMempoolBlocks(
            mempool.feeHistogram,
            maxBlocks: dashboardProjectedBlocks,
          );
    final EsploraFeeEstimates? fees;
    final bool feesDerived;
    if (serverFees != null) {
      fees = serverFees;
      feesDerived = false;
    } else if (histogramMempool != null) {
      fees = feeEstimatesFromProjection(
        projected,
        histogramMempool.feeHistogram,
      );
      feesDerived = true;
    } else {
      fees = previous.fees;
      feesDerived = previous.feesDerived;
    }

    _inFlight = false;
    if (_disposed) {
      return;
    }
    _state = ExplorerDashboardState(
      blocks: blocks ?? previous.blocks,
      mempool: mempool ?? previous.mempool,
      projected: projected,
      fees: fees,
      feesDerived: feesDerived,
      epoch: epoch,
      recent: recent ?? previous.recent,
      updatedAt:
          blocks != null ||
              mempool != null ||
              serverFees != null ||
              recent != null
          ? _now()
          : previous.updatedAt,
      requestsPerRound: requestsPerRound,
      error: errors.isEmpty ? null : errors.first,
    );
    if (errors.any(explorerIsRateLimit)) {
      // The user resumes. The controller does not retry on its own.
      _paused = true;
      _restartTimer();
    }
    _notify();
  }

  /// Runs [call]. A failure is added to [errors] and gives null.
  Future<T?> _try<T>(
    Future<T> Function() call,
    List<ExplorerException> errors,
  ) async {
    try {
      return await call();
    } on ExplorerException catch (error) {
      errors.add(error);
    } on Object {
      errors.add(
        const ExplorerException(
          ExplorerFailure.badResponse,
          'Unexpected explorer error.',
        ),
      );
    }

    return null;
  }

  /// The difficulty estimate for the epoch of [tip]. The start block is asked
  /// for once per epoch. Null when that call failed and nothing is cached.
  Future<DifficultyEpoch?> _epochFor(
    ExplorerApi api,
    EsploraBlock tip,
    List<ExplorerException> errors,
  ) async {
    final startHeight = epochStartHeight(tip.height);
    var startTime = _epochStartTimes[startHeight];
    if (startTime == null) {
      final hash = await _try(() => api.blockHashAtHeight(startHeight), errors);
      final startBlock = hash == null
          ? null
          : await _try(() => api.block(hash), errors);
      if (startBlock == null) {
        return null;
      }
      startTime = startBlock.timestamp;
      _epochStartTimes[startHeight] = startTime;
    }

    return DifficultyEpoch.estimate(
      tipHeight: tip.height,
      tipTime: tip.timestamp,
      startTime: startTime,
    );
  }

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }
}
