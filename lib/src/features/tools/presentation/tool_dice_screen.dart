import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/content/domain/content_store.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/sato_colors.dart';
import '../../../core/widgets/detail_scaffold.dart';
import '../../../core/widgets/sato_segmented_control.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../data/dice_detector.dart';
import '../data/secure_screen_channel.dart';
import '../domain/dice_entropy.dart';
import 'dice_sandbox_screen.dart';
import 'dice_session_controller.dart';
import 'dice_widgets.dart';

/// Dice to seed, intro screen. Explains what to prepare, then opens the
/// sandbox full screen. Local state only: nothing from here is saved.
class ToolDiceScreen extends StatefulWidget {
  const ToolDiceScreen({
    required this.store,
    this.detectorFactory,
    this.secureScreen,
    super.key,
  });

  final ContentStore store;

  /// Builds the camera reader for each sandbox session. Null means keypad only.
  /// The sandbox owns the detector it receives and disposes it.
  final DiceDetector Function()? detectorFactory;

  /// Native guard for the sandbox. Null when the platform guard is not wired.
  final SecureScreen? secureScreen;

  @override
  State<ToolDiceScreen> createState() => _ToolDiceScreenState();
}

class _ToolDiceScreenState extends State<ToolDiceScreen>
    with WidgetsBindingObserver {
  /// Faces and tilts of the three dice in the hero row.
  static const _heroValues = [6, 3, 5];
  static const _heroTilts = [-8.0, 4.0, -3.0];

  DiceSeedLength _length = DiceSeedLength.words24;

  /// Checklist ticks of the manual rows, only for the user to see: the sandbox
  /// does not read them. The airplane row follows the device network when the
  /// native guard is present, so its tick is not stored here.
  final _checked = [false, false, false, false];

  /// Whether the device has no network, from the native guard. Null when the
  /// guard is missing, then the airplane row is ticked by hand.
  bool? _offline;

  /// Whether airplane mode is on, from the native guard. Null when the
  /// platform cannot tell. It can be on while Wi-Fi is still connected.
  bool? _airplaneOn;

  StreamSubscription<SecureScreenEvent>? _eventSub;

  /// One more network check after resume: the OS can still report the old
  /// network for a moment after the user returns from the settings.
  Timer? _recheckTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _eventSub = widget.secureScreen?.events.listen(_onSecureEvent);
    unawaited(_refreshNetwork());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _eventSub?.cancel();
    _recheckTimer?.cancel();
    super.dispose();
  }

  /// Coming back from the settings, or from Control Center, rechecks the
  /// network so the airplane row updates by itself.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    unawaited(_refreshNetwork());
    _recheckTimer?.cancel();
    _recheckTimer = Timer(const Duration(milliseconds: 1500), _refreshNetwork);
  }

  void _onSecureEvent(SecureScreenEvent event) {
    switch (event) {
      case SecureScreenEvent.wentOnline:
      case SecureScreenEvent.wentOffline:
        unawaited(_refreshNetwork());
      case SecureScreenEvent.screenshotTaken:
      case SecureScreenEvent.captureStarted:
      case SecureScreenEvent.captureStopped:
        break;
    }
  }

  Future<void> _refreshNetwork() async {
    final secure = widget.secureScreen;
    if (secure == null) return;
    final online = await secure.isOnline();
    final airplaneOn = await secure.isAirplaneModeOn();
    if (!mounted) return;
    setState(() {
      _offline = !online;
      _airplaneOn = airplaneOn;
    });
  }

  Future<void> _openAirplaneSettings() async {
    await widget.secureScreen?.openAirplaneModeSettings();
  }

  /// The sandbox is pushed as a plain route, not a named one, so no deep link
  /// can open it. The detector is created for this session; the sandbox
  /// disposes it when it closes.
  Future<void> _enterSandbox() async {
    final detector = widget.detectorFactory?.call();
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => DiceSandboxScreen(
          length: _length,
          detector: detector,
          secureScreen: widget.secureScreen,
        ),
      ),
    );
    _refreshNetwork();
  }

  Future<void> _showMath() {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      builder: (_) => _MathSheet(length: _length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final bits = _length.entropyBytes * 8;
    final throws = (_length.rolls / DiceSessionController.dicePerThrow).ceil();

    return DetailScaffold(
      children: [
        ExcludeSemantics(
          child: Row(
            children: [
              for (var i = 0; i < _heroValues.length; i++) ...[
                if (i > 0) const SizedBox(width: AppSpacing.md),
                Transform.rotate(
                  angle: _heroTilts[i] * math.pi / 180,
                  child: DieFace(value: _heroValues[i], size: 44),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          l10n.toolsDiceEyebrow,
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Semantics(
          header: true,
          child: Text(l10n.toolsDiceTitle, style: textTheme.headlineLarge),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.toolsDiceIntro,
          style: textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.section),
        Semantics(
          container: true,
          label: l10n.toolsDiceLengthLabel,
          child: _Panel(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SatoSegmentedControl<DiceSeedLength>(
                  items: DiceSeedLength.values,
                  selected: _length,
                  labelFor: (length) => l10n.toolsDiceWords(length.words),
                  onChanged: (length) => setState(() => _length = length),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.toolsDiceLengthSummary(_length.rolls, bits, throws),
                  textAlign: TextAlign.center,
                  style: textTheme.labelMedium,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.section),
        _MonoLabel(l10n.toolsDiceChecklistTitle),
        const SizedBox(height: 10),
        _Panel(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < _checked.length; i++) _checkRow(l10n, i),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.section),
        _Panel(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.shield_outlined,
                size: 20,
                color: context.sato.statusComplete,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.toolsDiceSandboxInfoTitle,
                      style: textTheme.titleSmall,
                    ),
                    const SizedBox(height: 6),
                    for (final line in [
                      l10n.toolsDiceSandboxInfo1,
                      l10n.toolsDiceSandboxInfo2,
                      l10n.toolsDiceSandboxInfo3,
                    ])
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          line,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.section),
        FilledButton.icon(
          onPressed: _enterSandbox,
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.primaryContainer,
            foregroundColor: colorScheme.onPrimaryContainer,
            minimumSize: const Size.fromHeight(52),
            shape: const StadiumBorder(),
            textStyle: textTheme.titleSmall,
          ),
          icon: const Icon(Icons.lock_outline_rounded, size: 18),
          label: Text(l10n.toolsDiceEnter),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextButton(
          onPressed: _showMath,
          style: TextButton.styleFrom(
            foregroundColor: colorScheme.primary,
            minimumSize: const Size.fromHeight(44),
            textStyle: textTheme.titleSmall,
          ),
          child: Text(l10n.toolsDiceHowMath),
        ),
      ],
    );
  }

  /// One checklist row. The airplane row follows the device network when the
  /// native guard reports it; the other rows are ticked by hand.
  Widget _checkRow(AppLocalizations l10n, int index) {
    final colorScheme = Theme.of(context).colorScheme;
    final title = _checkTitle(l10n, index);
    final offline = _offline;

    if (index != 0 || offline == null) {
      return _CheckRow(
        title: title,
        caption: _checkCaption(l10n, index),
        checked: _checked[index],
        showTopBorder: index > 0,
        onTap: () => setState(() => _checked[index] = !_checked[index]),
      );
    }
    if (offline) {
      return _CheckRow(
        title: title,
        caption: l10n.toolsDiceCheckAirplaneOffline,
        checked: true,
        showTopBorder: false,
        onTap: _refreshNetwork,
      );
    }
    // Airplane mode is on, but Wi-Fi still connects: the user has to turn
    // Wi-Fi off too, so the row stays unticked and a tap rechecks.
    if (_airplaneOn == true) {
      return _CheckRow(
        title: title,
        caption: l10n.toolsDiceCheckAirplaneWifiStillOn,
        checked: false,
        showTopBorder: false,
        onTap: _refreshNetwork,
      );
    }
    // Android can open the airplane mode screen. Elsewhere the user has to
    // use Control Center, so a tap only rechecks the network.
    if (defaultTargetPlatform == TargetPlatform.android) {
      return _CheckRow(
        title: title,
        caption: l10n.toolsDiceCheckAirplaneOpenSettings,
        checked: false,
        showTopBorder: false,
        hint: l10n.toolsDiceCheckAirplaneOpenSettingsHint,
        trailing: ExcludeSemantics(
          child: Icon(
            Icons.open_in_new_rounded,
            size: 18,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        onTap: _openAirplaneSettings,
      );
    }
    return _CheckRow(
      title: title,
      caption: l10n.toolsDiceCheckAirplaneControlCenter,
      checked: false,
      showTopBorder: false,
      onTap: _refreshNetwork,
    );
  }

  String _checkTitle(AppLocalizations l10n, int index) {
    return switch (index) {
      0 => l10n.toolsDiceCheckAirplane,
      1 => l10n.toolsDiceCheckPrivate,
      2 => l10n.toolsDiceCheckPaper,
      _ => l10n.toolsDiceCheckDice,
    };
  }

  String _checkCaption(AppLocalizations l10n, int index) {
    return switch (index) {
      0 => l10n.toolsDiceCheckAirplaneCaption,
      1 => l10n.toolsDiceCheckPrivateCaption,
      2 => l10n.toolsDiceCheckPaperCaption,
      _ => l10n.toolsDiceCheckDiceCaption,
    };
  }
}

/// Card surface shared by the intro panels.
class _Panel extends StatelessWidget {
  const _Panel({required this.padding, required this.child});

  final EdgeInsetsGeometry padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

/// Uppercase mono label above a panel.
class _MonoLabel extends StatelessWidget {
  const _MonoLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// One tappable checklist row. The tick is a dot with a check mark, so the
/// state does not rely on colour alone.
class _CheckRow extends StatelessWidget {
  const _CheckRow({
    required this.title,
    required this.caption,
    required this.checked,
    required this.showTopBorder,
    required this.onTap,
    this.hint,
    this.trailing,
  });

  final String title;
  final String caption;
  final bool checked;
  final bool showTopBorder;
  final VoidCallback onTap;

  /// Extra screen reader hint, for rows that do something when tapped.
  final String? hint;

  /// Icon shown after the text, for rows that open another screen.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      checked: checked,
      label: '$title. $caption',
      hint: hint,
      onTap: onTap,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            border: showTopBorder
                ? Border(top: BorderSide(color: colorScheme.outlineVariant))
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: checked
                    ? BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.primaryContainer,
                      )
                    : BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.outline,
                          width: 1.5,
                        ),
                      ),
                child: checked
                    ? Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: colorScheme.onPrimaryContainer,
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: textTheme.titleSmall),
                    const SizedBox(height: 2),
                    Text(
                      caption,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppSpacing.md),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: trailing,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet with the five steps from roll to words. The numbers are for
/// the chosen seed length.
class _MathSheet extends StatelessWidget {
  const _MathSheet({required this.length});

  final DiceSeedLength length;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final bits = length.entropyBytes * 8;
    final checksumBits = bits ~/ 32;
    final totalBits = bits + checksumBits;
    final groups = totalBits ~/ 11;

    final steps = [
      l10n.toolsDiceMathStep1(length.rolls),
      l10n.toolsDiceMathStep2(bits),
      l10n.toolsDiceMathStep3(checksumBits),
      l10n.toolsDiceMathStep4(totalBits, groups),
      l10n.toolsDiceMathStep5,
    ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          0,
          AppSpacing.gutter,
          AppSpacing.xl + MediaQuery.viewPaddingOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.toolsDiceMathTitle, style: textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.lg),
            for (var i = 0; i < steps.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 28,
                      child: Text(
                        '${i + 1}',
                        style: textTheme.labelMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(steps[i], style: textTheme.bodyMedium),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.toolsDiceMathNote,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.primary,
                minimumSize: const Size.fromHeight(44),
              ),
              child: Text(l10n.toolsDiceClose),
            ),
          ],
        ),
      ),
    );
  }
}
