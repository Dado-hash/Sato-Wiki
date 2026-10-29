import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/sato_colors.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../domain/bip39.dart';
import 'dice_session_controller.dart';
import 'dice_widgets.dart';

/// Result of a complete session: the BIP39 words (hidden until held), the
/// bit groups with their indices, and the math behind them.
class DiceResultView extends StatelessWidget {
  const DiceResultView({
    required this.controller,
    required this.onWipe,
    required this.onNewSession,
    super.key,
  });

  final DiceSessionController controller;

  /// Erases the session and leaves the sandbox.
  final VoidCallback onWipe;

  /// Erases the session and starts rolling again.
  final VoidCallback onNewSession;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final mnemonic = controller.mnemonic;
        if (mnemonic == null || mnemonic.isWiped) {
          return const SizedBox.shrink();
        }
        final l10n = AppLocalizations.of(context);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.gutter,
                  AppSpacing.sm,
                  AppSpacing.gutter,
                  AppSpacing.gutter,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ResultHeader(
                      title: l10n.toolsDiceResultTitle,
                      done: l10n.toolsDiceDone,
                      meta: l10n.toolsDiceResultMeta(
                        mnemonic.wordCount,
                        controller.requiredRolls,
                        mnemonic.entropyBitLength,
                        mnemonic.checksumBitLength,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _WarningCard(text: l10n.toolsDiceResultWarning),
                    const SizedBox(height: AppSpacing.lg),
                    _WordsCard(controller: controller, mnemonic: mnemonic),
                    const SizedBox(height: AppSpacing.lg),
                    _BitsCard(controller: controller, mnemonic: mnemonic),
                    const SizedBox(height: AppSpacing.lg),
                    _MathCard(controller: controller, mnemonic: mnemonic),
                    const SizedBox(height: AppSpacing.xl),
                    FilledButton.icon(
                      onPressed: onWipe,
                      icon: const Icon(Icons.delete_outline, size: 20),
                      label: Text(l10n.toolsDiceWipeDone),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    OutlinedButton(
                      onPressed: onNewSession,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        shape: const StadiumBorder(),
                      ),
                      child: Text(l10n.toolsDiceNewSession),
                    ),
                  ],
                ),
              ),
            ),
            _HoldBar(controller: controller),
          ],
        );
      },
    );
  }
}

/// Card surface of the result sections.
class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: diceCardDecoration(context),
      child: child,
    );
  }
}

class _ResultHeader extends StatelessWidget {
  const _ResultHeader({
    required this.title,
    required this.done,
    required this.meta,
  });

  final String title;
  final String done;
  final String meta;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            constraints: const BoxConstraints(minHeight: 24),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              border: Border.all(color: colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ExcludeSemantics(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: context.sato.statusDeployed,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(child: Text(done, style: diceLabelStyle(context))),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          title,
          style: TextStyle(
            fontFamily: AppFonts.display,
            fontSize: 30,
            fontWeight: FontWeight.w700,
            height: 34 / 30,
            letterSpacing: -0.6,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          meta,
          style: diceMonoStyle(
            context,
            size: 12,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _WarningCard extends StatelessWidget {
  const _WarningCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final sato = context.sato;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: sato.statusDraft.withValues(alpha: 0.06),
        border: Border.all(color: sato.statusDraft.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(AppRadii.card),
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
          const SizedBox(width: AppSpacing.md),
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
    );
  }
}

/// Words in three columns. Each word is a Text only while revealed.
class _WordsCard extends StatelessWidget {
  const _WordsCard({required this.controller, required this.mnemonic});

  final DiceSessionController controller;
  final Bip39Mnemonic mnemonic;

  static const int _columns = 3;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final revealed = controller.revealed;
    final count = mnemonic.wordCount;
    final rows = (count + _columns - 1) ~/ _columns;

    return _ResultCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.toolsDiceWordsLabel, style: diceLabelStyle(context)),
          const SizedBox(height: AppSpacing.md),
          for (var row = 0; row < rows; row++) ...[
            if (row > 0) const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                for (var column = 0; column < _columns; column++) ...[
                  if (column > 0) const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: row * _columns + column < count
                        ? _WordCell(
                            mnemonic: mnemonic,
                            index: row * _columns + column,
                            revealed: revealed,
                            selected:
                                controller.selectedWord ==
                                row * _columns + column,
                            onTap: () =>
                                controller.selectWord(row * _columns + column),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.toolsDiceRevealCaption,
            style: TextStyle(
              fontSize: 12,
              height: 16 / 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _WordCell extends StatelessWidget {
  const _WordCell({
    required this.mnemonic,
    required this.index,
    required this.revealed,
    required this.selected,
    required this.onTap,
  });

  final Bip39Mnemonic mnemonic;
  final int index;
  final bool revealed;
  final bool selected;
  final VoidCallback onTap;

  static const double _radius = 12;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final number = (index + 1).toString().padLeft(2, '0');

    return Semantics(
      button: true,
      selected: selected,
      label: revealed ? '${index + 1}. ${mnemonic.wordAt(index)}' : number,
      onTap: onTap,
      child: Material(
        color: colorScheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
          side: BorderSide(
            color: selected
                ? colorScheme.primaryContainer
                : colorScheme.outlineVariant,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: InkWell(
          excludeFromSemantics: true,
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
          ),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: ExcludeSemantics(
                child: Row(
                  children: [
                    Text(
                      number,
                      style: diceMonoStyle(
                        context,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: revealed
                            ? Text(
                                mnemonic.wordAt(index),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              )
                            : Text(
                                '••••••',
                                style: diceMonoStyle(
                                  context,
                                  size: 12,
                                  letterSpacing: 1.2,
                                  color: colorScheme.outline,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Pinned bar at the bottom of the result with the one reveal control. It
/// stays in view while the cards scroll. Holding it reveals the words, bits
/// and math values together, and releasing it hides them all.
class _HoldBar extends StatelessWidget {
  const _HoldBar({required this.controller});

  final DiceSessionController controller;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.md,
        AppSpacing.gutter,
        AppSpacing.md,
      ),
      child: _HoldToReveal(controller: controller),
    );
  }
}

/// Reveals the secret while the pointer is down. With a screen reader on,
/// holding is not possible, so it becomes a toggle button instead.
class _HoldToReveal extends StatelessWidget {
  const _HoldToReveal({required this.controller});

  final DiceSessionController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final revealed = controller.revealed;
    final visibleLabel = revealed
        ? l10n.toolsDiceReleaseToHide
        : l10n.toolsDiceHoldToReveal;

    final visual = Container(
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.primary, width: 1.5),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          ExcludeSemantics(
            child: Icon(
              Icons.visibility_outlined,
              size: 20,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              visibleLabel,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );

    if (MediaQuery.accessibleNavigationOf(context)) {
      void toggle() => controller.setRevealed(!revealed);

      return Semantics(
        button: true,
        toggled: revealed,
        label: revealed
            ? l10n.toolsDiceReleaseToHide
            : l10n.toolsDiceHoldToReveal,
        onTap: toggle,
        child: ExcludeSemantics(
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            onTap: toggle,
            child: visual,
          ),
        ),
      );
    }

    return Semantics(
      button: true,
      label: visibleLabel,
      child: ExcludeSemantics(
        child: Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (_) => controller.setRevealed(true),
          onPointerUp: (_) => controller.setRevealed(false),
          onPointerCancel: (_) => controller.setRevealed(false),
          child: visual,
        ),
      ),
    );
  }
}

/// Placeholder for hidden data: middle dots in the same mono style.
String _hiddenDots(int count) => '·' * count;

/// Placeholder for a hidden math data line.
const _hiddenLine = '· · · · · · · ·';

/// One row per 11-bit group, with its index. The bits and indices are hidden
/// until the hold control at the bottom of the result is pressed. The
/// structure (row numbers, checksum width) stays visible. The row of the
/// selected word is highlighted.
class _BitsCard extends StatelessWidget {
  const _BitsCard({required this.controller, required this.mnemonic});

  final DiceSessionController controller;
  final Bip39Mnemonic mnemonic;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final rowCount = mnemonic.wordCount;
    final checksumBits = mnemonic.checksumBitLength;
    final selected = controller.selectedWord;
    final revealed = controller.revealed;
    // Secret data is read only while revealed; hidden rows get null.
    final groups = revealed ? mnemonic.bitGroups() : null;
    final indices = revealed ? mnemonic.indices : null;

    return _ResultCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.toolsDiceBitsLabel(
              mnemonic.wordCount * 11,
              mnemonic.wordCount,
            ),
            style: diceLabelStyle(context),
          ),
          const SizedBox(height: AppSpacing.md),
          for (var index = 0; index < rowCount; index++)
            _BitRow(
              position: index,
              checksumBits: index == rowCount - 1 ? checksumBits : 0,
              bits: groups?[index],
              wordIndex: indices?[index],
              selected: index == selected,
            ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.sm,
            children: [
              _LegendItem(
                color: colorScheme.primary,
                text: l10n.toolsDiceLegendChecksum(checksumBits),
              ),
              _LegendItem(
                color: colorScheme.onSurface,
                text: l10n.toolsDiceLegendEntropy(mnemonic.entropyBitLength),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.toolsDiceTapWordHint,
            style: TextStyle(
              fontSize: 12,
              height: 16 / 12,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Width of one BIP39 bit group.
const _groupBits = 11;

class _BitRow extends StatelessWidget {
  /// [bits] and [wordIndex] are null while hidden; the row then shows only
  /// placeholder dots, sized from the structure. They are passed only while
  /// the reveal flag is on, the same flag as the words and math values.
  const _BitRow({
    required this.position,
    required this.checksumBits,
    required this.selected,
    this.bits,
    this.wordIndex,
  });

  final int position;

  /// Checksum tail width of this row (non-zero only on the last row).
  final int checksumBits;
  final bool selected;

  /// The 11-bit group, or null while hidden.
  final String? bits;

  /// The word index, or null while hidden.
  final int? wordIndex;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final value = bits;
    final index = wordIndex;
    final headLength = _groupBits - checksumBits;
    final head = value == null
        ? _hiddenDots(headLength)
        : value.substring(0, headLength);
    final tail = value == null
        ? _hiddenDots(checksumBits)
        : value.substring(headLength);
    final bitColor = position.isEven
        ? colorScheme.onSurface
        : colorScheme.onSurfaceVariant;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: selected ? context.sato.accentTint : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              '#${(position + 1).toString().padLeft(2, '0')}',
              style: diceMonoStyle(
                context,
                size: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: diceMonoStyle(
                  context,
                  size: 12,
                  letterSpacing: 0.72,
                  color: bitColor,
                ),
                children: [
                  TextSpan(text: head),
                  if (tail.isNotEmpty)
                    TextSpan(
                      text: tail,
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            index == null ? '→ ····' : '→ $index',
            style: diceMonoStyle(
              context,
              size: 12,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.text});

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            height: 16 / 12,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Math section: five steps with the data of each one. Expanded by default.
class _MathCard extends StatefulWidget {
  const _MathCard({required this.controller, required this.mnemonic});

  final DiceSessionController controller;
  final Bip39Mnemonic mnemonic;

  @override
  State<_MathCard> createState() => _MathCardState();
}

class _MathCardState extends State<_MathCard> {
  bool _open = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final steps = _mathSteps(
      l10n,
      widget.controller,
      widget.mnemonic,
      widget.controller.revealed,
    );

    return _ResultCard(
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              button: true,
              expanded: _open,
              child: InkWell(
                onTap: () => setState(() => _open = !_open),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 44),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.toolsDiceMathTitle,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      AnimatedRotation(
                        turns: _open ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: ExcludeSemantics(
                          child: Icon(
                            Icons.expand_more,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_open) ...[
              const SizedBox(height: AppSpacing.md),
              if (!widget.controller.revealed) ...[
                Text(
                  l10n.toolsDiceMathHidden,
                  style: TextStyle(
                    fontSize: 12,
                    height: 16 / 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              for (var index = 0; index < steps.length; index++) ...[
                if (index > 0) const SizedBox(height: 14),
                _StepRow(step: steps[index]),
              ],
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.toolsDiceMathNote,
                style: TextStyle(
                  fontSize: 12,
                  height: 16 / 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MathStep {
  const _MathStep({
    required this.number,
    required this.text,
    required this.data,
  });

  final int number;
  final String text;
  final String data;
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.step});

  final _MathStep step;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh,
            border: Border.all(color: colorScheme.outlineVariant),
            shape: BoxShape.circle,
          ),
          child: Text('${step.number}', style: diceMonoStyle(context)),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                step.text,
                style: TextStyle(
                  fontSize: 14,
                  height: 20 / 14,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                step.data,
                style: diceMonoStyle(
                  context,
                  size: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The five steps. The step texts (counts) are always shown; the data lines
/// (rolls, entropy, checksum, bit groups, index pairs) only while revealed.
List<_MathStep> _mathSteps(
  AppLocalizations l10n,
  DiceSessionController controller,
  Bip39Mnemonic mnemonic,
  bool revealed,
) {
  final totalBits = mnemonic.wordCount * 11;

  String shown(String Function() value) => revealed ? value() : _hiddenLine;

  return [
    _MathStep(
      number: 1,
      text: l10n.toolsDiceMathStep1(controller.rollCount),
      data: shown(() => _rollsPreview(controller)),
    ),
    _MathStep(
      number: 2,
      text: l10n.toolsDiceMathStep2(mnemonic.entropyBitLength),
      data: shown(() => _hexEnds(mnemonic.entropy)),
    ),
    _MathStep(
      number: 3,
      text: l10n.toolsDiceMathStep3(mnemonic.checksumBitLength),
      data: shown(
        () => '→ ${mnemonic.bitString().substring(mnemonic.entropyBitLength)}',
      ),
    ),
    _MathStep(
      number: 4,
      text: l10n.toolsDiceMathStep4(totalBits, mnemonic.wordCount),
      data: shown(() {
        final groups = mnemonic.bitGroups();

        return '${groups[0]} · ${groups[1]} · …';
      }),
    ),
    _MathStep(
      number: 5,
      text: l10n.toolsDiceMathStep5,
      data: shown(() {
        final indices = mnemonic.indices;

        return '${indices[0]} → ${mnemonic.wordAt(0)} · '
            '${indices[1]} → ${mnemonic.wordAt(1)} · …';
      }),
    ),
  ];
}

/// First 36 rolls as digits, then an ellipsis.
String _rollsPreview(DiceSessionController controller) {
  const shownRolls = 36;
  final shown = math.min(shownRolls, controller.rollCount);
  final buffer = StringBuffer();
  for (var index = 0; index < shown; index++) {
    buffer.write(controller.rollAt(index));
  }
  if (controller.rollCount > shown) {
    buffer.write('…');
  }

  return buffer.toString();
}

/// Entropy in hex, first and last four bytes only.
String _hexEnds(Uint8List bytes) {
  const edgeBytes = 4;
  if (bytes.length <= edgeBytes * 2) {
    return _hex(bytes, 0, bytes.length);
  }

  return '${_hex(bytes, 0, edgeBytes)}…'
      '${_hex(bytes, bytes.length - edgeBytes, bytes.length)}';
}

String _hex(Uint8List bytes, int from, int to) {
  final buffer = StringBuffer();
  for (var index = from; index < to; index++) {
    buffer.write(bytes[index].toRadixString(16).padLeft(2, '0'));
  }

  return buffer.toString();
}
