import 'dart:math' as math;

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

class _ToolDiceScreenState extends State<ToolDiceScreen> {
  /// Faces and tilts of the three dice in the hero row.
  static const _heroValues = [6, 3, 5];
  static const _heroTilts = [-8.0, 4.0, -3.0];

  DiceSeedLength _length = DiceSeedLength.words24;

  /// Checklist ticks. Only for the user to see: the sandbox does not read them.
  final _checked = [true, true, false, false];

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
              for (var i = 0; i < _checked.length; i++)
                _CheckRow(
                  title: _checkTitle(l10n, i),
                  caption: _checkCaption(l10n, i),
                  checked: _checked[i],
                  showTopBorder: i > 0,
                  onTap: () => setState(() => _checked[i] = !_checked[i]),
                ),
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
  });

  final String title;
  final String caption;
  final bool checked;
  final bool showTopBorder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      checked: checked,
      label: '$title. $caption',
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
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          0,
          AppSpacing.gutter,
          AppSpacing.xl,
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
