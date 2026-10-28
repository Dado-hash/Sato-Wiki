import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/sato_colors.dart';
import '../../../core/widgets/round_icon_button.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../domain/dice_detection.dart';
import '../domain/dice_entropy.dart';
import 'dice_session_controller.dart';

/// Lit pip cells of each face, row-major on a 3×3 grid.
const Map<int, List<int>> _pipCells = {
  1: [4],
  2: [0, 8],
  3: [0, 4, 8],
  4: [0, 2, 6, 8],
  5: [0, 2, 4, 6, 8],
  6: [0, 2, 3, 5, 6, 8],
};

/// Monospace style for data and uppercase labels.
TextStyle diceMonoStyle(
  BuildContext context, {
  double size = 11,
  FontWeight weight = FontWeight.w500,
  double letterSpacing = 0,
  Color? color,
}) {
  return TextStyle(
    fontFamily: AppFonts.mono,
    fontSize: size,
    fontWeight: weight,
    letterSpacing: letterSpacing,
    color: color ?? Theme.of(context).colorScheme.onSurface,
  );
}

/// Uppercase monospace label, secondary colour.
TextStyle diceLabelStyle(BuildContext context) {
  return diceMonoStyle(
    context,
    letterSpacing: 0.9,
    color: Theme.of(context).colorScheme.onSurfaceVariant,
  );
}

/// Card surface shared by the dice screens.
BoxDecoration diceCardDecoration(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;

  return BoxDecoration(
    color: colorScheme.surfaceContainerLow,
    border: Border.all(color: colorScheme.outlineVariant),
    borderRadius: BorderRadius.circular(AppRadii.card),
  );
}

/// A die showing [value] as a 3×3 pip grid on a rounded body. The body uses
/// the text colour and the pips the ground colour, so the die reads light on
/// the dark theme and inverted on the light one.
class DieFace extends StatelessWidget {
  const DieFace({required this.value, required this.size, super.key});

  /// Face value, 1 to 6.
  final int value;

  /// Width and height of the die.
  final double size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: AppLocalizations.of(context).toolsDiceValue(value),
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _DieFacePainter(
            value: value,
            body: colorScheme.onSurface,
            pip: colorScheme.surface,
          ),
        ),
      ),
    );
  }
}

class _DieFacePainter extends CustomPainter {
  const _DieFacePainter({
    required this.value,
    required this.body,
    required this.pip,
  });

  final int value;
  final Color body;
  final Color pip;

  /// Share of the side left empty around the pip grid.
  static const double _padding = 0.15;

  /// Corner radius of the body, as a share of the side.
  static const double _radius = 0.22;

  /// Pip radius, as a share of one grid cell.
  static const double _pipRadius = 0.38;

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;
    final body = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(side * _radius),
    );
    canvas.drawRRect(body, Paint()..color = this.body);

    final pad = side * _padding;
    final cell = (side - 2 * pad) / 3;
    final pipPaint = Paint()..color = pip;
    for (final index in _pipCells[value] ?? const <int>[]) {
      final column = index % 3;
      final row = index ~/ 3;
      canvas.drawCircle(
        Offset(pad + cell * (column + 0.5), pad + cell * (row + 0.5)),
        cell * _pipRadius,
        pipPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_DieFacePainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.body != body ||
        oldDelegate.pip != pip;
  }
}

/// Entropy collected so far, as an arc around the whole-bit count.
class EntropyRing extends StatelessWidget {
  const EntropyRing({required this.bits, required this.maxBits, super.key});

  /// Bits collected so far.
  final double bits;

  /// Bits of the seed being built.
  final double maxBits;

  static const double _size = 120;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final whole = bits.floor();
    final maxWhole = maxBits.round();
    final fraction = maxBits <= 0 ? 0.0 : (bits / maxBits).clamp(0.0, 1.0);

    return Semantics(
      label: '$whole ${l10n.toolsDiceBitsOf(maxWhole)}',
      child: ExcludeSemantics(
        child: SizedBox.square(
          dimension: _size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size.square(_size),
                painter: _EntropyRingPainter(
                  fraction: fraction.toDouble(),
                  track: colorScheme.outlineVariant,
                  arc: colorScheme.primaryContainer,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$whole',
                    style: TextStyle(
                      fontFamily: AppFonts.display,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      height: 1,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.toolsDiceBitsOf(maxWhole),
                    style: diceMonoStyle(
                      context,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EntropyRingPainter extends CustomPainter {
  const _EntropyRingPainter({
    required this.fraction,
    required this.track,
    required this.arc,
  });

  final double fraction;
  final Color track;
  final Color arc;

  static const double _stroke = 10;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - _stroke) / 2;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = track
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke,
    );
    if (fraction <= 0) {
      return;
    }

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * fraction,
      false,
      Paint()
        ..color = arc
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_EntropyRingPainter oldDelegate) {
    return oldDelegate.fraction != fraction ||
        oldDelegate.track != track ||
        oldDelegate.arc != arc;
  }
}

/// Recorded rolls as dice, pulsing cells for the dice on the table, and dashed
/// empty cells for the rest. Eleven columns; the rows are as tall as a cell.
class DiceRollGrid extends StatelessWidget {
  const DiceRollGrid({required this.controller, this.pending = 0, super.key});

  final DiceSessionController controller;

  /// Dice on the table that are not recorded yet, shown as pulsing cells.
  final int pending;

  static const int columns = 11;
  static const double _gap = 5;
  static const double _maxCell = 26;

  @override
  Widget build(BuildContext context) {
    final total = controller.requiredRolls;
    final recorded = controller.rollCount;
    final pendingCells = math.max(0, math.min(pending, total - recorded));
    final rows = (total + columns - 1) ~/ columns;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cell = math.max(
          0.0,
          math.min(
            (constraints.maxWidth - _gap * (columns - 1)) / columns,
            _maxCell,
          ),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var row = 0; row < rows; row++)
              Padding(
                padding: EdgeInsets.only(bottom: row < rows - 1 ? _gap : 0),
                child: Row(
                  children: [
                    for (var column = 0; column < columns; column++) ...[
                      if (column > 0) const SizedBox(width: _gap),
                      _cellAt(
                        row * columns + column,
                        cell: cell,
                        recorded: recorded,
                        pendingCells: pendingCells,
                        total: total,
                      ),
                    ],
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _cellAt(
    int index, {
    required double cell,
    required int recorded,
    required int pendingCells,
    required int total,
  }) {
    final Widget content;
    if (index >= total) {
      content = const SizedBox.shrink();
    } else if (index < recorded) {
      content = _RecordedCell(value: controller.rollAt(index), size: cell);
    } else if (index < recorded + pendingCells) {
      content = _PendingCell(size: cell);
    } else {
      content = _DashedCell(size: cell);
    }

    return SizedBox.square(dimension: cell, child: content);
  }
}

/// A recorded roll. It pops in once, when it is first built.
class _RecordedCell extends StatelessWidget {
  const _RecordedCell({required this.value, required this.size});

  final int value;
  final double size;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) {
        return Opacity(
          opacity: t,
          child: Transform.scale(scale: 0.6 + 0.4 * t, child: child),
        );
      },
      child: DieFace(value: value, size: size),
    );
  }
}

/// A dashed accent cell for a die on the table that is not recorded yet.
class _PendingCell extends StatefulWidget {
  const _PendingCell({required this.size});

  final double size;

  @override
  State<_PendingCell> createState() => _PendingCellState();
}

class _PendingCellState extends State<_PendingCell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      if (!MediaQuery.disableAnimationsOf(context)) {
        _pulse.repeat(reverse: true);
      }
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FadeTransition(
      opacity: Tween<double>(begin: 1, end: 0.5).animate(_pulse),
      child: _DashedCell(
        size: widget.size,
        fill: context.sato.accentTint,
        borderColor: colorScheme.primaryContainer,
      ),
    );
  }
}

/// A square cell with a dashed border, optionally filled.
class _DashedCell extends StatelessWidget {
  const _DashedCell({required this.size, this.fill, this.borderColor});

  final double size;
  final Color? fill;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(_DashedBorderPainter.radius),
      ),
      child: CustomPaint(
        size: Size.square(size),
        painter: _DashedBorderPainter(
          color: borderColor ?? colorScheme.outlineVariant,
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color});

  final Color color;

  static const double radius = 6;
  static const double _dash = 4;
  static const double _gap = 3;

  @override
  void paint(Canvas canvas, Size size) {
    final inset = Rect.fromLTWH(0.5, 0.5, size.width - 1, size.height - 1);
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(inset, const Radius.circular(radius)));
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = math.min(distance + _dash, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += _dash + _gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

/// Face counts of the recorded rolls, with a status line from the chi-square check.
class DiceHistogram extends StatelessWidget {
  const DiceHistogram({required this.stats, super.key});

  final DiceRollStats stats;

  static const double _barMaxHeight = 72;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final sato = context.sato;
    final counts = stats.counts;
    final maxCount = counts.fold<int>(0, math.max);
    final biased = stats.looksBiased;
    final statusColor = biased ? sato.statusDraft : sato.statusDeployed;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: diceCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.toolsDiceDistributionTitle,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var face = 0; face < counts.length; face++) ...[
                if (face > 0) const SizedBox(width: 10),
                Expanded(
                  child: _HistogramBar(
                    face: face + 1,
                    count: counts[face],
                    height: maxCount == 0
                        ? 0
                        : counts[face] / maxCount * _barMaxHeight,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              ExcludeSemantics(
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  biased
                      ? l10n.toolsDiceDistributionBiased
                      : l10n.toolsDiceDistributionOk,
                  style: TextStyle(
                    fontSize: 13,
                    height: 18 / 13,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HistogramBar extends StatelessWidget {
  const _HistogramBar({
    required this.face,
    required this.count,
    required this.height,
  });

  final int face;
  final int count;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: '$face: $count',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '$count',
              textAlign: TextAlign.center,
              style: diceMonoStyle(context),
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: DiceHistogram._barMaxHeight,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: height,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6),
                      bottomLeft: Radius.circular(2),
                      bottomRight: Radius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$face',
              textAlign: TextAlign.center,
              style: diceMonoStyle(
                context,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Six keys, three by two, each showing its die face and number.
class DiceKeypad extends StatelessWidget {
  const DiceKeypad({
    required this.onValue,
    this.selectedValue,
    this.enabled = true,
    super.key,
  });

  final ValueChanged<int> onValue;

  /// Key to show as selected, if any.
  final int? selectedValue;

  /// False greys the keys out and ignores taps.
  final bool enabled;

  static const double _gap = 12;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var row = 0; row < 2; row++) ...[
          if (row > 0) const SizedBox(height: _gap),
          Row(
            children: [
              for (var column = 0; column < 3; column++) ...[
                if (column > 0) const SizedBox(width: _gap),
                Expanded(
                  child: _DiceKey(
                    value: row * 3 + column + 1,
                    selected: selectedValue == row * 3 + column + 1,
                    enabled: enabled,
                    onTap: () => onValue(row * 3 + column + 1),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class _DiceKey extends StatelessWidget {
  const _DiceKey({
    required this.value,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final int value;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  static const double _height = 96;
  static const double _radius = 16;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final sato = context.sato;
    final label = l10n.toolsDiceValue(value);

    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        selected: selected,
        enabled: enabled,
        label: label,
        onTap: enabled ? onTap : null,
        child: Opacity(
          opacity: enabled ? 1 : 0.4,
          child: Material(
            color: selected
                ? sato.accentTint
                : colorScheme.surfaceContainerHigh,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_radius),
              side: BorderSide(
                color: selected
                    ? colorScheme.primaryContainer
                    : colorScheme.outlineVariant,
                width: selected ? 2 : 1,
              ),
            ),
            child: InkWell(
              excludeFromSemantics: true,
              customBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_radius),
              ),
              onTap: enabled ? onTap : null,
              child: SizedBox(
                height: _height,
                child: ExcludeSemantics(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DieFace(value: value, size: 44),
                      const SizedBox(height: 6),
                      Text(
                        '$value',
                        style: diceMonoStyle(
                          context,
                          size: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Sandbox status line: the SANDBOX pill, the network pill and the exit button.
class SandboxTopBar extends StatelessWidget {
  const SandboxTopBar({required this.online, required this.onExit, super.key});

  /// True when the device reports a network connection.
  final bool online;

  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final sato = context.sato;
    final networkColor = online ? sato.statusDraft : sato.statusDeployed;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.gutter,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  constraints: const BoxConstraints(minHeight: 28),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: sato.accentTint,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ExcludeSemantics(
                        child: Icon(
                          Icons.lock_outline,
                          size: 14,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          l10n.toolsDiceSandboxActive,
                          style: diceMonoStyle(
                            context,
                            weight: FontWeight.w700,
                            letterSpacing: 0.9,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  constraints: const BoxConstraints(minHeight: 28),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    border: Border.all(color: colorScheme.outlineVariant),
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
                            color: networkColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          online ? l10n.toolsDiceOnline : l10n.toolsDiceOffline,
                          style: diceMonoStyle(context, letterSpacing: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          RoundIconButton(
            icon: Icons.close,
            tooltip: l10n.toolsDiceExit,
            onPressed: onExit,
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet to check or enter the dice of one throw. With [values] it
/// corrects a reading: tap a die, then a key. With no values it enters a
/// throw by hand: each key appends a die, each die tapped is removed.
/// Returns the edited values, or null when closed.
class DiceCorrectionSheet extends StatefulWidget {
  const DiceCorrectionSheet({
    required this.values,
    required this.throwNumber,
    this.confidences,
    super.key,
  });

  /// Readings to correct. Empty for manual entry.
  final List<int> values;

  /// Confidence of each reading, same length as [values] when given.
  final List<double>? confidences;

  /// Number of the throw, shown in the title.
  final int throwNumber;

  /// Opens the sheet and resolves to the saved values, or null.
  static Future<List<int>?> show(
    BuildContext context, {
    required List<int> values,
    List<double>? confidences,
    required int throwNumber,
  }) {
    return showModalBottomSheet<List<int>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => DiceCorrectionSheet(
        values: values,
        confidences: confidences,
        throwNumber: throwNumber,
      ),
    );
  }

  @override
  State<DiceCorrectionSheet> createState() => _DiceCorrectionSheetState();
}

class _DiceCorrectionSheetState extends State<DiceCorrectionSheet> {
  late List<int> _values;
  int _selected = 0;

  bool get _manual => widget.values.isEmpty;

  bool get _full => _values.length >= DiceSessionController.dicePerThrow;

  @override
  void initState() {
    super.initState();
    _values = List<int>.of(widget.values);
  }

  void _onKey(int value) {
    setState(() {
      if (_manual) {
        if (!_full) {
          _values.add(value);
        }
      } else {
        _values[_selected] = value;
      }
    });
  }

  void _removeAt(int index) {
    setState(() => _values.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final title = _manual
        ? l10n.toolsDiceManualTitle
        : l10n.toolsDiceCorrectTitle(widget.throwNumber);
    final valueLabel = _manual
        ? (_full ? null : l10n.toolsDiceNewValueFor(_values.length + 1))
        : l10n.toolsDiceNewValueFor(_selected + 1);
    final selectedValue = _manual || _values.isEmpty
        ? null
        : _values[_selected];

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          0,
          AppSpacing.gutter,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontFamily: AppFonts.display,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.4,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                RoundIconButton(
                  icon: Icons.close,
                  tooltip: l10n.toolsDiceClose,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            if (!_manual) ...[
              const SizedBox(height: 4),
              Text(
                l10n.toolsDiceCorrectBody,
                style: TextStyle(
                  fontSize: 14,
                  height: 19 / 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            _buildSlots(l10n),
            const SizedBox(height: AppSpacing.lg),
            if (valueLabel != null)
              Text(valueLabel, style: diceLabelStyle(context)),
            const SizedBox(height: 10),
            DiceKeypad(
              onValue: _onKey,
              selectedValue: selectedValue,
              enabled: !_manual || !_full,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: _values.isEmpty
                  ? null
                  : () => Navigator.of(context).pop(List<int>.of(_values)),
              child: Text(l10n.toolsDiceSaveThrow),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlots(AppLocalizations l10n) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final slot = math.min(
          60.0,
          (constraints.maxWidth - 4 * AppSpacing.sm) /
              DiceSessionController.dicePerThrow,
        );
        if (_values.isEmpty) {
          return SizedBox(height: slot);
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var index = 0; index < _values.length; index++)
              _DieSlot(
                number: index + 1,
                value: _values[index],
                size: slot,
                selected: !_manual && index == _selected,
                confidence:
                    widget.confidences != null &&
                        index < widget.confidences!.length
                    ? widget.confidences![index]
                    : null,
                onTap: _manual
                    ? () => _removeAt(index)
                    : () => setState(() => _selected = index),
              ),
          ],
        );
      },
    );
  }
}

/// One die of the throw in the correction sheet, with its confidence below it.
class _DieSlot extends StatelessWidget {
  const _DieSlot({
    required this.number,
    required this.value,
    required this.size,
    required this.selected,
    required this.onTap,
    this.confidence,
  });

  final int number;
  final int value;
  final double size;
  final bool selected;
  final double? confidence;
  final VoidCallback onTap;

  static const double _radius = 14;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final sato = context.sato;
    final label = l10n.toolsDiceDie(number, value);
    final reading = confidence;
    final warn =
        reading != null && reading < DiceThrowCandidate.reviewThreshold;
    final labelColor = warn ? sato.statusDraft : colorScheme.onSurfaceVariant;

    return SizedBox(
      width: size,
      child: Column(
        children: [
          Tooltip(
            message: label,
            child: Semantics(
              button: true,
              selected: selected,
              label: label,
              onTap: onTap,
              child: Material(
                color: selected
                    ? sato.accentTint
                    : colorScheme.surfaceContainerHigh,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_radius),
                  side: BorderSide(
                    color: selected
                        ? colorScheme.primaryContainer
                        : colorScheme.outlineVariant,
                    width: selected ? 2 : 1,
                  ),
                ),
                child: InkWell(
                  excludeFromSemantics: true,
                  onTap: onTap,
                  child: SizedBox.square(
                    dimension: size,
                    child: Center(
                      child: ExcludeSemantics(
                        child: DieFace(value: value, size: size - 10),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (reading != null) ...[
            const SizedBox(height: 6),
            Text.rich(
              TextSpan(
                style: diceMonoStyle(context, color: labelColor),
                children: [
                  if (warn)
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: ExcludeSemantics(
                        child: Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.only(right: 4),
                          decoration: BoxDecoration(
                            color: sato.statusDraft,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  TextSpan(
                    text: warn
                        ? '${(reading * 100).round()}% · ${l10n.toolsDiceCheckReading}'
                        : '${(reading * 100).round()}%',
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
