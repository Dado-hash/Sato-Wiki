import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/sato_colors.dart';
import '../../../core/widgets/round_icon_button.dart';
import '../../../core/widgets/sato_progress_bar.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../data/dice_detector.dart';
import '../data/secure_screen_channel.dart';
import '../domain/dice_detection.dart';
import '../domain/dice_entropy.dart';
import 'dice_result_view.dart';
import 'dice_session_controller.dart';
import 'dice_widgets.dart';

/// Offline dice session: reads the dice with the camera, records the rolls in
/// memory and shows the seed. Nothing is saved, and leaving the screen, the
/// app, or a screenshot erases the session.
class DiceSandboxScreen extends StatefulWidget {
  const DiceSandboxScreen({
    required this.length,
    this.detector,
    this.secureScreen,
    super.key,
  });

  /// Seed length to build.
  final DiceSeedLength length;

  /// Camera reader. Null when the device has none; rolls are then typed in.
  final DiceDetector? detector;

  /// Native guard: screenshots, capture, network state. Defaults to a no-op
  /// channel when the platform has none.
  final SecureScreen? secureScreen;

  @override
  State<DiceSandboxScreen> createState() => _DiceSandboxScreenState();
}

class _DiceSandboxScreenState extends State<DiceSandboxScreen>
    with WidgetsBindingObserver {
  late final DiceSessionController _controller = DiceSessionController(
    length: widget.length,
  );
  late final SecureScreen _secure = widget.secureScreen ?? SecureScreen();
  final DiceStabilityTracker _tracker = DiceStabilityTracker();

  StreamSubscription<List<DetectedDie>>? _detectionSub;
  StreamSubscription<SecureScreenEvent>? _secureSub;
  ModalRoute<dynamic>? _route;

  /// Dice in the latest camera frame, in position order.
  List<DetectedDie> _latest = const [];

  bool _inactive = false;
  bool _captured = false;
  bool _online = false;

  /// Airplane mode from the native guard; null when the platform cannot tell.
  bool? _airplaneOn;
  bool _cameraChecked = false;
  bool _cameraReady = false;
  bool _cameraRunning = false;
  bool _sheetOpen = false;
  bool _leaving = false;

  bool get _veiled => _inactive || _captured;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller.addListener(_onControllerChanged);
    unawaited(_secure.enable());
    _secureSub = _secure.events.listen(_onSecureEvent);
    unawaited(_loadNetwork());
    unawaited(_startCamera());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _route ??= ModalRoute.of(context);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.removeListener(_onControllerChanged);
    _detectionSub?.cancel();
    _secureSub?.cancel();
    unawaited(_shutdownDetector());
    unawaited(_secure.disable());
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_leaving) {
      return;
    }
    switch (state) {
      case AppLifecycleState.inactive:
        setState(() => _inactive = true);
      case AppLifecycleState.resumed:
        setState(() => _inactive = false);
        // The network can change while the app is in the settings, and the
        // events may not arrive, so the banner is checked again here.
        unawaited(_loadNetwork());
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        _leave(notify: true);
    }
  }

  Future<void> _loadNetwork() async {
    final online = await _secure.isOnline();
    final airplaneOn = await _secure.isAirplaneModeOn();
    if (mounted) {
      setState(() {
        _online = online;
        _airplaneOn = airplaneOn;
      });
    }
  }

  void _onSecureEvent(SecureScreenEvent event) {
    if (!mounted || _leaving) {
      return;
    }
    switch (event) {
      case SecureScreenEvent.screenshotTaken:
        unawaited(_onScreenshot());
      case SecureScreenEvent.captureStarted:
        setState(() => _captured = true);
      case SecureScreenEvent.captureStopped:
        setState(() => _captured = false);
      case SecureScreenEvent.wentOnline:
        setState(() => _online = true);
        unawaited(_loadNetwork());
      case SecureScreenEvent.wentOffline:
        setState(() => _online = false);
        unawaited(_loadNetwork());
    }
  }

  Future<void> _onScreenshot() async {
    final l10n = AppLocalizations.of(context);
    _wipe();
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.toolsDiceScreenshotTitle),
        content: Text(l10n.toolsDiceScreenshotBody),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.toolsDiceClose),
          ),
        ],
      ),
    );
    if (mounted) {
      _leave(notify: false);
    }
  }

  Future<void> _confirmExit() async {
    if (_leaving) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.toolsDiceExitConfirmTitle),
        content: Text(l10n.toolsDiceExitConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.toolsDiceCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.toolsDiceExitConfirm),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      _leave(notify: false);
    }
  }

  /// Erases the session, closes this screen and every sheet or dialog above
  /// it, and shows the erased notice when [notify] is set.
  void _leave({required bool notify}) {
    if (_leaving) {
      return;
    }
    _leaving = true;
    final messenger = ScaffoldMessenger.maybeOf(context);
    final message = notify
        ? AppLocalizations.of(context).toolsDiceWipedNotice
        : null;
    _wipe();

    final navigator = Navigator.of(context);
    final route = _route;
    if (route == null) {
      if (navigator.canPop()) {
        navigator.pop();
      }
    } else if (route.isActive) {
      navigator.popUntil((candidate) => candidate == route);
      navigator.pop();
    }
    if (message != null) {
      messenger?.showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _wipe() {
    _stopCamera();
    _latest = const [];
    _tracker.reset();
    _tracker.forgetRecorded();
    _controller.wipe();
  }

  void _newSession() {
    _wipe();
    unawaited(_startCamera());
  }

  void _onControllerChanged() {
    if (_controller.isComplete) {
      _stopCamera();
    }
  }

  Future<void> _startCamera() async {
    final detector = widget.detector;
    if (detector == null) {
      _setCamera(ready: false);
      return;
    }

    var available = false;
    try {
      available = await detector.isAvailable();
    } on Object {
      available = false;
    }
    if (!mounted || _leaving) {
      return;
    }
    if (!available) {
      _setCamera(ready: false);
      return;
    }

    try {
      await detector.start();
    } on Object {
      _setCamera(ready: false);
      return;
    }
    if (!mounted || _leaving || _controller.isComplete) {
      unawaited(detector.stop());
      return;
    }

    _detectionSub = detector.detections.listen(_onDetections);
    _cameraRunning = true;
    _setCamera(ready: true);
  }

  void _setCamera({required bool ready}) {
    if (!mounted) {
      return;
    }
    setState(() {
      _cameraChecked = true;
      _cameraReady = ready;
    });
  }

  void _stopCamera() {
    _detectionSub?.cancel();
    _detectionSub = null;
    if (_cameraRunning) {
      _cameraRunning = false;
      final detector = widget.detector;
      if (detector != null) {
        unawaited(detector.stop());
      }
    }
  }

  Future<void> _shutdownDetector() async {
    final detector = widget.detector;
    if (detector == null) {
      return;
    }
    try {
      await detector.stop();
    } on Object {
      // Already stopped or never started: nothing to undo.
    }
    await detector.dispose();
  }

  void _onDetections(List<DetectedDie> frame) {
    if (!mounted || _leaving || _controller.isComplete) {
      return;
    }
    final dice = orderByPosition(frame);
    _latest = dice;
    final candidate = _tracker.addFrame(dice);
    setState(() {});

    if (candidate == null) {
      return;
    }
    // A camera reading is never recorded on its own: the sheet asks first.
    unawaited(
      _openSheet(
        values: candidate.values,
        confidences: [for (final die in candidate.dice) die.confidence],
      ),
    );
  }

  /// Dice of the latest frame that the tracker would also accept.
  List<DetectedDie> _stableDice() {
    return [
      for (final die in _latest)
        if (die.confidence >= _tracker.minConfidence) die,
    ];
  }

  void _confirmThrow() {
    final dice = _stableDice();
    if (dice.isEmpty || dice.length > DiceSessionController.dicePerThrow) {
      return;
    }
    _tracker.markRecorded(dice);
    unawaited(
      _openSheet(
        values: [for (final die in dice) die.value],
        confidences: [for (final die in dice) die.confidence],
      ),
    );
  }

  Future<void> _openManual() async {
    _tracker.markRecorded(_latest);
    await _openSheet(values: const []);
  }

  Future<void> _openSheet({
    required List<int> values,
    List<double>? confidences,
  }) async {
    if (_sheetOpen || _leaving) {
      return;
    }
    _sheetOpen = true;
    final result = await DiceCorrectionSheet.show(
      context,
      values: values,
      confidences: confidences,
      throwNumber: _controller.throwCount + 1,
    );
    _sheetOpen = false;
    if (!mounted || _leaving) {
      return;
    }
    if (result != null && result.isNotEmpty) {
      _controller.addThrow(result);
    }
  }

  void _undo() {
    _tracker.forgetRecorded();
    _controller.undoLastThrow();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          unawaited(_confirmExit());
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            SafeArea(
              child: ListenableBuilder(
                listenable: _controller,
                builder: (context, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SandboxTopBar(
                        online: _online,
                        onExit: () => unawaited(_confirmExit()),
                      ),
                      if (_online)
                        _OnlineBanner(
                          text: _airplaneOn == true
                              ? l10n.toolsDiceOnlineWarningWifi
                              : l10n.toolsDiceOnlineWarning,
                        ),
                      Expanded(
                        child: _controller.isComplete
                            ? DiceResultView(
                                controller: _controller,
                                onWipe: () => _leave(notify: true),
                                onNewSession: _newSession,
                              )
                            : _buildRolling(l10n),
                      ),
                    ],
                  );
                },
              ),
            ),
            if (_veiled)
              Positioned.fill(child: _SandboxVeil(text: l10n.toolsDiceVeil)),
          ],
        ),
      ),
    );
  }

  Widget _buildRolling(AppLocalizations l10n) {
    final canConfirm = _stableDice().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              AppSpacing.sm,
              AppSpacing.gutter,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildViewfinder(l10n),
                const SizedBox(height: AppSpacing.lg),
                _buildStats(l10n),
                const SizedBox(height: AppSpacing.section),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.toolsDiceRecordedRolls,
                        style: diceLabelStyle(context),
                      ),
                    ),
                    Text(
                      l10n.toolsDiceCountOf(
                        _controller.rollCount,
                        _controller.requiredRolls,
                      ),
                      style: diceMonoStyle(
                        context,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                DiceRollGrid(controller: _controller, pending: _latest.length),
                const SizedBox(height: AppSpacing.lg),
                DiceHistogram(stats: _controller.stats),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            AppSpacing.md,
            AppSpacing.gutter,
            AppSpacing.gutter,
          ),
          child: Row(
            children: [
              RoundIconButton(
                icon: Icons.undo,
                tooltip: l10n.toolsDiceUndo,
                onPressed: _controller.throwCount > 0 ? _undo : null,
              ),
              const SizedBox(width: AppSpacing.sm),
              RoundIconButton(
                icon: Icons.dialpad,
                tooltip: l10n.toolsDiceKeypad,
                onPressed: () => unawaited(_openManual()),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton(
                  onPressed: canConfirm ? _confirmThrow : null,
                  child: Text(l10n.toolsDiceConfirmThrow),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildViewfinder(AppLocalizations l10n) {
    if (_cameraChecked && !_cameraReady) {
      return _CameraNotice(text: l10n.toolsDiceCameraUnavailable);
    }

    final colorScheme = Theme.of(context).colorScheme;
    final preview = widget.detector?.buildPreview();
    final dice = _latest;

    return AspectRatio(
      aspectRatio: 350 / 330,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          border: Border.all(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(AppRadii.media),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              fit: StackFit.expand,
              children: [
                if (preview != null)
                  preview
                else
                  const Center(
                    child: SizedBox.square(
                      dimension: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                for (final die in dice)
                  _DieBox(
                    die: die,
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                  ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: _LivePill(text: l10n.toolsDiceLive),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _ViewfinderStrip(
                    text: dice.isEmpty
                        ? l10n.toolsDiceAimCamera
                        : l10n.toolsDiceHoldStill,
                    progress: _tracker.progress,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStats(AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    final valueStyle = TextStyle(
      fontFamily: AppFonts.display,
      fontSize: 24,
      fontWeight: FontWeight.w600,
      height: 1.1,
      color: colorScheme.onSurface,
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: diceCardDecoration(context),
      child: Row(
        children: [
          EntropyRing(
            bits: _controller.entropyBits,
            maxBits: widget.length.entropyBytes * 8.0,
          ),
          const SizedBox(width: AppSpacing.xl),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.toolsDiceThrowLabel, style: diceLabelStyle(context)),
                Text(
                  l10n.toolsDiceCountOf(
                    _controller.throwCount,
                    _controller.throwsNeeded,
                  ),
                  style: valueStyle,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(l10n.toolsDiceRollsLabel, style: diceLabelStyle(context)),
                Text(
                  l10n.toolsDiceCountOf(
                    _controller.rollCount,
                    _controller.requiredRolls,
                  ),
                  style: valueStyle,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.toolsDiceBitsPerRoll,
                  style: TextStyle(
                    fontSize: 12,
                    height: 16 / 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Box drawn over one detected die: corner brackets and a value and confidence chip.
class _DieBox extends StatelessWidget {
  const _DieBox({required this.die, required this.width, required this.height});

  final DetectedDie die;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final box = die.box;
    final chipAbove = box.top * height >= 24;
    final percent = (die.confidence * 100).round();

    return Positioned(
      left: box.left * width,
      top: box.top * height,
      width: box.width * width,
      height: box.height * height,
      child: CustomPaint(
        painter: _CornerPainter(color: colorScheme.primaryContainer),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              top: chipAbove ? -22 : 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Text(
                  '${die.value} · $percent%',
                  softWrap: false,
                  style: diceMonoStyle(
                    context,
                    weight: FontWeight.w700,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Four orange corner brackets along the edges of a box.
class _CornerPainter extends CustomPainter {
  const _CornerPainter({required this.color});

  final Color color;

  static const double _arm = 12;
  static const double _inset = 1.5;

  @override
  void paint(Canvas canvas, Size size) {
    final left = _inset;
    final top = _inset;
    final right = size.width - _inset;
    final bottom = size.height - _inset;
    final path = Path()
      ..moveTo(left, top + _arm)
      ..lineTo(left, top)
      ..lineTo(left + _arm, top)
      ..moveTo(right - _arm, top)
      ..lineTo(right, top)
      ..lineTo(right, top + _arm)
      ..moveTo(right, bottom - _arm)
      ..lineTo(right, bottom)
      ..lineTo(right - _arm, bottom)
      ..moveTo(left + _arm, bottom)
      ..lineTo(left, bottom)
      ..lineTo(left, bottom - _arm);

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.square,
    );
  }

  @override
  bool shouldRepaint(_CornerPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _LivePill extends StatelessWidget {
  const _LivePill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ExcludeSemantics(
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: context.sato.statusDeployed,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: diceMonoStyle(context, letterSpacing: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom strip of the viewfinder: the capture hint and the stability bar.
class _ViewfinderStrip extends StatelessWidget {
  const _ViewfinderStrip({required this.text, required this.progress});

  final String text;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      color: colorScheme.surface.withValues(alpha: 0.72),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              height: 16 / 12,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SatoProgressBar(value: progress),
        ],
      ),
    );
  }
}

class _CameraNotice extends StatelessWidget {
  const _CameraNotice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: diceCardDecoration(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ExcludeSemantics(
            child: Icon(
              Icons.no_photography_outlined,
              size: 32,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 20 / 14,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _OnlineBanner extends StatelessWidget {
  const _OnlineBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final sato = context.sato;

    return Semantics(
      liveRegion: true,
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          0,
          AppSpacing.gutter,
          AppSpacing.sm,
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: sato.statusDraft.withValues(alpha: 0.06),
          border: Border.all(color: sato.statusDraft.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(AppRadii.tile),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: Icon(
                Icons.warning_amber_rounded,
                size: 20,
                color: sato.statusDraft,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  height: 20 / 14,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Opaque cover shown while the app is inactive or the screen is captured.
class _SandboxVeil extends StatelessWidget {
  const _SandboxVeil({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: colorScheme.surface,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.gutter),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ExcludeSemantics(
                child: Icon(
                  Icons.visibility_off_outlined,
                  size: 40,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppFonts.display,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
