import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/sato_colors.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../data/esplora_models.dart';
import '../domain/difficulty_epoch.dart';
import '../domain/mempool_projection.dart';
import '../domain/units.dart';
import 'explorer_widgets.dart';
import 'explorer_dashboard_controller.dart';
import 'tool_widgets.dart';

/// Width and height of one block cube.
const double _cubeSize = 104;

/// Space between two cubes, and between a card and the next section.
const double _cubeGap = AppSpacing.md;

/// Width of the "Now" divider column.
const double _nowWidth = 44;

/// Most queued (projected) cubes the strip shows, the nearest ones.
const int _maxQueuedCubes = 4;

/// Fee-rate unit, as shown in the cubes and the fee card.
const String _satVb = 'sat/vB';

/// Vbytes of a full block, the top of a confirmed cube's fill.
const int _maxWeightUnits = 4000000;

/// Fee rate for the display: a whole number from 10 up, and one decimal
/// below 10 (2.5 shows as 2.5, 8.0 as 8).
String formatFeeRate(double rate, String locale) {
  if (rate >= 10 || rate == rate.roundToDouble()) {
    return NumberFormat.decimalPattern(locale).format(rate.round());
  }

  return NumberFormat.decimalPatternDigits(
    locale: locale,
    decimalDigits: 1,
  ).format(rate);
}

/// Share of the mempool vbytes in each fee band, from 0 to 1. The bands are
/// below 2, 2 to 5, 5 to 10, 10 to 50 and 50 sat/vB or more, in that order.
/// All zero when the histogram is empty.
List<double> mempoolBandShares(List<EsploraFeeBucket> histogram) {
  final vsize = List<int>.filled(_bandLabels.length, 0);
  var total = 0;
  for (final bucket in histogram) {
    vsize[_bandIndex(bucket.feeRate)] += bucket.vsize;
    total += bucket.vsize;
  }

  return [for (final value in vsize) total == 0 ? 0.0 : value / total];
}

const List<String> _bandLabels = ['<2', '2–5', '5–10', '10–50', '≥50'];

int _bandIndex(double rate) {
  if (rate < 2) {
    return 0;
  }
  if (rate < 5) {
    return 1;
  }
  if (rate < 10) {
    return 2;
  }
  if (rate < 50) {
    return 3;
  }

  return 4;
}

/// Connection line above the search: a dot, and text that says whether the
/// dashboard is live or paused. The text carries the state, not the colour.
class ExplorerLiveLine extends StatelessWidget {
  const ExplorerLiveLine({required this.host, required this.paused, super.key});

  final String host;
  final bool paused;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final sato = context.sato;

    return Row(
      children: [
        ExcludeSemantics(
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: paused
                  ? colorScheme.onSurfaceVariant
                  : sato.statusDeployed,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            paused
                ? l10n.explorerDashLivePaused(host)
                : l10n.explorerDashLive(host),
            style: toolMonoStyle(
              context,
              size: 12,
            ).copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

/// Everything below the search field. Shows an error with a retry button when
/// nothing has loaded yet, and the sections otherwise. Each section shows a
/// placeholder until its data arrives.
class ExplorerDashboardBody extends StatelessWidget {
  const ExplorerDashboardBody({
    required this.state,
    required this.paused,
    required this.interval,
    required this.now,
    required this.host,
    required this.onRefresh,
    required this.onTogglePause,
    super.key,
  });

  final ExplorerDashboardState state;
  final bool paused;
  final Duration interval;
  final DateTime now;
  final String host;
  final Future<void> Function() onRefresh;
  final VoidCallback onTogglePause;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final error = state.error;
    final mempool = state.mempool;
    final showError = !state.hasData && error != null;
    final queued = mempool == null ? 0 : blocksToClear(mempool.vsize);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showError) ...[
          ExplorerNotice(text: explorerErrorText(l10n, error)),
          if (explorerIsRateLimit(error)) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.explorerNoAutoRetry,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
            ),
            onPressed: onRefresh,
            child: Text(l10n.explorerRetry),
          ),
          const SizedBox(height: AppSpacing.section),
        ] else ...[
          _DashSection(
            title: l10n.explorerDashBlocks,
            hint: l10n.explorerDashBlocksHint,
            child: ExplorerBlockStrip(
              blocks: state.blocks,
              projected: state.projected,
              queuedBlocks: queued,
              now: now,
            ),
          ),
          const SizedBox(height: AppSpacing.section),
          _DashSection(
            title: l10n.explorerDashFeesTitle,
            child: ExplorerFeesCard(
              fees: state.fees,
              derived: state.feesDerived,
              pending: state.updatedAt == null,
            ),
          ),
          const SizedBox(height: AppSpacing.section),
          ExplorerStatsRow(
            mempool: mempool,
            queuedBlocks: queued,
            epoch: state.epoch,
          ),
          const SizedBox(height: AppSpacing.section),
          _DashSection(
            title: l10n.explorerDashLatestTxs,
            child: ExplorerRecentList(recent: state.recent),
          ),
        ],
        const SizedBox(height: AppSpacing.section),
        ExplorerDashboardFooter(
          state: state,
          paused: paused,
          interval: interval,
          host: host,
          onToggle: onTogglePause,
        ),
      ],
    );
  }
}

/// Section title in the mono style of the dashboard, with an optional hint
/// on the right.
class _DashSection extends StatelessWidget {
  const _DashSection({required this.title, required this.child, this.hint});

  final String title;
  final String? hint;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Flexible(
              child: Semantics(
                header: true,
                child: Text(
                  title.toUpperCase(),
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            if (hint != null) ...[
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  hint!,
                  textAlign: TextAlign.end,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        child,
      ],
    );
  }
}

/// Card used by the dashboard: surface colour, thin border, card radius.
class _DashCard extends StatelessWidget {
  const _DashCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: child,
      ),
    );
  }
}

/// Placeholder box of the size a section will have, shown until its data
/// arrives. It is read as one loading item.
class ExplorerSkeleton extends StatelessWidget {
  const ExplorerSkeleton({required this.height, this.width, super.key});

  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: l10n.explorerLoading,
      child: ExcludeSemantics(
        child: SizedBox(
          width: width,
          height: height,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppRadii.card),
            ),
          ),
        ),
      ),
    );
  }
}

/// Horizontal strip of block cubes. Projected blocks come first, furthest
/// from now on the left, then a dashed "Now" divider, then the confirmed
/// blocks, newest first.
class ExplorerBlockStrip extends StatefulWidget {
  const ExplorerBlockStrip({
    required this.blocks,
    required this.projected,
    required this.queuedBlocks,
    required this.now,
    super.key,
  });

  /// Confirmed blocks, newest first. Null while loading.
  final List<EsploraBlock>? blocks;

  /// Projected blocks, nearest first.
  final List<ProjectedBlock> projected;

  /// Blocks the mempool needs to clear. Used for the "+n blocks" label.
  final int queuedBlocks;

  final DateTime now;

  @override
  State<ExplorerBlockStrip> createState() => _ExplorerBlockStripState();
}

class _ExplorerBlockStripState extends State<ExplorerBlockStrip> {
  final ScrollController _scroll = ScrollController();

  /// True once the strip has been scrolled to its starting place.
  bool _placed = false;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /// Puts the "Now" divider at about 40 % of the strip width, so the queued
  /// blocks are on its left and the confirmed ones on its right. Runs after
  /// layout, once the scroll view is attached. Cube widths are fixed, so the
  /// position does not depend on the text scale.
  void _showNow(int queuedShown) {
    if (!mounted || _placed || !_scroll.hasClients) {
      return;
    }
    final position = _scroll.position;
    final dividerCentre = queuedShown * (_cubeSize + _cubeGap) + _nowWidth / 2;
    final target = dividerCentre - position.viewportDimension * 0.4;
    _scroll.jumpTo(target.clamp(0, position.maxScrollExtent).toDouble());
    _placed = true;
  }

  @override
  Widget build(BuildContext context) {
    final blocks = widget.blocks;
    final projected = widget.projected;
    if (blocks == null && projected.isEmpty) {
      return SizedBox(
        height: _cubeSize,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: const [
            ExplorerSkeleton(height: _cubeSize, width: _cubeSize),
            SizedBox(width: _cubeGap),
            ExplorerSkeleton(height: _cubeSize, width: _cubeSize),
            SizedBox(width: _cubeGap),
            ExplorerSkeleton(height: _cubeSize, width: _cubeSize),
          ],
        ),
      );
    }

    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final items = <Widget>[];
    final queuedShown = projected.length < _maxQueuedCubes
        ? projected.length
        : _maxQueuedCubes;

    for (var i = queuedShown - 1; i >= 0; i--) {
      final block = projected[i];
      final stats = [
        l10n.explorerDashMedianRate(formatFeeRate(block.medianFeeRate, locale)),
        _rangeText(l10n, block, locale),
        l10n.explorerDashBtc(_btcText(block.estimatedFees, 3, locale)),
      ];
      // The last cube stands for every block past the third.
      final beyond = widget.queuedBlocks - (_maxQueuedCubes - 1);
      final isLastCube = i == _maxQueuedCubes - 1;
      final caption = isLastCube && beyond > 1
          ? l10n.explorerDashMoreBlocks(beyond)
          : l10n.explorerDashMinutes((i + 1) * 10);
      final marker = i == 0
          ? l10n.explorerDashNext
          : isLastCube
          ? l10n.explorerDashQueued
          : '+${i + 1}';
      items
        ..add(
          _BlockCube(
            background: context.sato.accentTint,
            fillColor: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.55),
            fill: block.vsize / projectedBlockVsize,
            title: stats.first,
            lines: stats.skip(1).toList(),
            caption: caption,
            marker: marker,
            semanticsLabel: [...stats, caption, marker].join(', '),
          ),
        )
        ..add(const SizedBox(width: _cubeGap));
    }

    items.add(_NowDivider(label: l10n.explorerDashNow));

    for (final block in blocks ?? const <EsploraBlock>[]) {
      final ago = widget.now.difference(
        DateTime.fromMillisecondsSinceEpoch(block.timestamp * 1000),
      );
      final minutes = ago.inMinutes < 0 ? 0 : ago.inMinutes;
      final txs = l10n.explorerDashTxCount(
        NumberFormat.decimalPattern(locale).format(block.txCount),
      );
      final size = l10n.explorerDashSizeMb(
        _decimal(block.size / 1000000, 2, locale),
      );
      final weight = l10n.explorerDashWeightMwu(
        _decimal(block.weight / 1000000, 2, locale),
      );
      final caption = l10n.explorerDashBlockAgo(minutes);
      final height = NumberFormat.decimalPattern(locale).format(block.height);
      items
        ..add(
          _BlockCube(
            background: context.sato.fieldBlue,
            fillColor: context.sato.statusComplete.withValues(alpha: 0.35),
            fill: block.weight / _maxWeightUnits,
            title: txs,
            lines: [size, weight],
            caption: caption,
            marker: height,
            semanticsLabel: [txs, size, weight, caption, height].join(', '),
            markerIsAccent: true,
            onTap: () => Navigator.of(
              context,
            ).pushNamed(AppRoutes.explorerBlock(block.id)),
          ),
        )
        ..add(const SizedBox(width: _cubeGap));
    }
    if (items.isNotEmpty) {
      items.removeLast();
    }

    if (!_placed) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _showNow(queuedShown),
      );
    }

    return SingleChildScrollView(
      controller: _scroll,
      scrollDirection: Axis.horizontal,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: items,
        ),
      ),
    );
  }
}

/// Fee range of a projected block, or one rate when the block has one rate.
String _rangeText(AppLocalizations l10n, ProjectedBlock block, String locale) {
  final min = formatFeeRate(block.minFeeRate, locale);
  final max = formatFeeRate(block.maxFeeRate, locale);

  return min == max
      ? l10n.explorerFeeRateValue(min)
      : l10n.explorerDashRange(min, max);
}

String _decimal(double value, int digits, String locale) {
  return NumberFormat.decimalPatternDigits(
    locale: locale,
    decimalDigits: digits,
  ).format(value);
}

String _btcText(int satoshi, int digits, String locale) {
  return _decimal(satoshi / satoshiPerBitcoin, digits, locale);
}

/// One block cube. The fill rises from the bottom to [fill] of the box height.
/// The text grows the box when the text scale is large.
class _BlockCube extends StatelessWidget {
  const _BlockCube({
    required this.background,
    required this.fillColor,
    required this.fill,
    required this.title,
    required this.lines,
    required this.caption,
    required this.marker,
    required this.semanticsLabel,
    this.markerIsAccent = false,
    this.onTap,
  });

  final Color background;
  final Color fillColor;
  final double fill;
  final String title;
  final List<String> lines;
  final String caption;
  final String marker;
  final String semanticsLabel;
  final bool markerIsAccent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final box = ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.thumb),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppRadii.thumb),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: FractionallySizedBox(
                  heightFactor: fill.clamp(0.0, 1.0).toDouble(),
                  widthFactor: 1,
                  child: ColoredBox(color: fillColor),
                ),
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: _cubeSize),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FitLine(title, style: textTheme.titleSmall),
                    for (final line in lines)
                      _FitLine(line, style: toolMonoStyle(context, size: 11)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    final body = SizedBox(
      width: _cubeSize,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          box,
          const SizedBox(height: AppSpacing.xs),
          _FitLine(
            caption,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          _FitLine(
            marker,
            style: toolMonoStyle(context, size: 12).copyWith(
              fontWeight: FontWeight.w700,
              color: markerIsAccent
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );

    return Semantics(
      button: onTap != null,
      label: semanticsLabel,
      onTap: onTap,
      excludeSemantics: true,
      child: onTap == null
          ? body
          : InkWell(
              borderRadius: BorderRadius.circular(AppRadii.thumb),
              onTap: onTap,
              child: body,
            ),
    );
  }
}

/// Dashed vertical line with a label, between the projected and the
/// confirmed blocks.
class _NowDivider extends StatelessWidget {
  const _NowDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: _nowWidth,
      child: Column(
        children: [
          Expanded(
            child: CustomPaint(
              painter: _DashedLinePainter(colorScheme.onSurfaceVariant),
              size: Size.infinite,
            ),
          ),
          Text(
            label.toUpperCase(),
            style: toolMonoStyle(
              context,
              size: 10,
            ).copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2;
    final x = size.width / 2;
    var y = 0.0;
    while (y < size.height) {
      final end = y + 6 < size.height ? y + 6 : size.height;
      canvas.drawLine(Offset(x, y), Offset(x, end), paint);
      y += 10;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

/// Four recommended fee rates in one card, with a bar that runs from fast
/// (red) to slow (green), and a line with the cost of a typical transaction.
class ExplorerFeesCard extends StatelessWidget {
  const ExplorerFeesCard({
    required this.fees,
    this.derived = false,
    this.pending = false,
    super.key,
  });

  /// The estimates, or null when the server gave none.
  final EsploraFeeEstimates? fees;

  /// True when [fees] were derived from the mempool.
  final bool derived;

  /// True until a refresh round has finished. Only then is the skeleton shown.
  final bool pending;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final sato = context.sato;
    if (fees == null && pending) {
      return ExplorerSkeleton(height: 120);
    }
    // A finished round without fee data shows dashes.
    final estimates = fees ?? const EsploraFeeEstimates(<int, double>{});

    String rate(int target) {
      final value = estimates.forTarget(target);

      return value == null ? '—' : formatFeeRate(value, locale);
    }

    final columns = [
      (l10n.explorerDashFeeNoPriority, rate(144), l10n.explorerDashFeeDay),
      (l10n.explorerDashFeeLow, rate(6), l10n.explorerDashFeeHour),
      (l10n.explorerDashFeeMedium, rate(3), l10n.explorerDashMinutes(30)),
      (l10n.explorerDashFeeHigh, rate(1), l10n.explorerDashMinutes(10)),
    ];
    final high = estimates.forTarget(1);
    final typical = high == null
        ? '—'
        : NumberFormat.decimalPattern(locale).format((high * 140).round());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadii.card),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  // Column width: the card less the three 1 dp dividers, split
                  // four ways, less the horizontal padding of each column.
                  final columnWidth = max(
                    0.0,
                    (constraints.maxWidth - 3) / 4 - AppSpacing.xs * 2,
                  );
                  final labelStyle = textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  );
                  final labelHeight = _feeLabelHeight(
                    context,
                    [for (final column in columns) column.$1],
                    labelStyle,
                    columnWidth,
                  );

                  return IntrinsicHeight(
                    child: Row(
                      children: [
                        for (var i = 0; i < columns.length; i++) ...[
                          if (i > 0)
                            VerticalDivider(
                              width: 1,
                              thickness: 1,
                              color: colorScheme.outlineVariant,
                            ),
                          Expanded(
                            child: MergeSemantics(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.md,
                                  horizontal: AppSpacing.xs,
                                ),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: labelHeight,
                                      child: _feeLabel(
                                        context,
                                        columns[i].$1,
                                        labelStyle,
                                        columnWidth,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    _FitLine(
                                      columns[i].$2,
                                      alignment: Alignment.center,
                                      style: textTheme.headlineSmall?.copyWith(
                                        fontFeatures: const [
                                          FontFeature.tabularFigures(),
                                        ],
                                      ),
                                    ),
                                    _FitLine(
                                      _satVb,
                                      alignment: Alignment.center,
                                      style: textTheme.labelSmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    _FitLine(
                                      columns[i].$3,
                                      alignment: Alignment.center,
                                      style: textTheme.labelSmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
              Container(
                height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      sato.statusDeployed,
                      sato.statusDraft,
                      colorScheme.primary,
                      colorScheme.error,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.explorerDashTypicalTx(typical),
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        if (derived) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.explorerDashFeesDerived,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

/// Most lines a fee column label takes. Labels wrap at spaces up to here.
const int _feeLabelMaxLines = 2;

/// Whether one word of [text] is wider than [width] at [style].
bool _hasWordWiderThan(
  BuildContext context,
  String text,
  TextStyle? style,
  double width,
) {
  for (final word in text.split(' ')) {
    final painter = TextPainter(
      text: TextSpan(text: word, style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      locale: Localizations.maybeLocaleOf(context),
    )..layout();
    final wider = painter.width > width;
    painter.dispose();
    if (wider) {
      return true;
    }
  }

  return false;
}

/// Height every fee column label reserves: the tallest of [labels] when each
/// wraps at spaces to at most [_feeLabelMaxLines] lines within [width].
double _feeLabelHeight(
  BuildContext context,
  List<String> labels,
  TextStyle? style,
  double width,
) {
  var height = 0.0;
  for (final label in labels) {
    final painter = TextPainter(
      text: TextSpan(text: label, style: style),
      textAlign: TextAlign.center,
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      locale: Localizations.maybeLocaleOf(context),
      maxLines: _feeLabelMaxLines,
    )..layout(maxWidth: width);
    height = max(height, painter.height);
    painter.dispose();
  }

  return height;
}

/// A fee column label, centred. It wraps at spaces. Only a single word too
/// wide for [width] shrinks to fit instead.
Widget _feeLabel(
  BuildContext context,
  String text,
  TextStyle? style,
  double width,
) {
  if (_hasWordWiderThan(context, text, style, width)) {
    return _FitLine(text, style: style, alignment: Alignment.center);
  }

  return Center(
    child: Text(
      text,
      style: style,
      textAlign: TextAlign.center,
      maxLines: _feeLabelMaxLines,
      overflow: TextOverflow.ellipsis,
    ),
  );
}

/// Mempool and difficulty cards side by side. They stack in one column on a
/// narrow screen or at a large text scale.
class ExplorerStatsRow extends StatelessWidget {
  const ExplorerStatsRow({
    required this.mempool,
    required this.queuedBlocks,
    required this.epoch,
    super.key,
  });

  final EsploraMempoolInfo? mempool;
  final int queuedBlocks;
  final DifficultyEpoch? epoch;

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 360;
    final largeText = MediaQuery.textScalerOf(context).scale(16) > 16 * 1.3;
    final mempoolCard = ExplorerMempoolCard(
      mempool: mempool,
      queuedBlocks: queuedBlocks,
    );
    const gap = SizedBox(height: AppSpacing.md, width: AppSpacing.md);
    final difficultyCard = ExplorerDifficultyCard(epoch: epoch);

    if (narrow || largeText) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [mempoolCard, gap, difficultyCard],
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: mempoolCard),
          gap,
          Expanded(child: difficultyCard),
        ],
      ),
    );
  }
}

/// Mempool count, a bar of the fee bands, and size, fees and clearing time.
class ExplorerMempoolCard extends StatelessWidget {
  const ExplorerMempoolCard({
    required this.mempool,
    required this.queuedBlocks,
    super.key,
  });

  final EsploraMempoolInfo? mempool;
  final int queuedBlocks;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final sato = context.sato;
    final info = mempool;
    if (info == null) {
      return ExplorerSkeleton(height: 170);
    }

    final shares = mempoolBandShares(info.feeHistogram);
    final colors = [
      sato.statusDeployed,
      sato.statusComplete,
      sato.statusDraft,
      colorScheme.primary,
      colorScheme.error,
    ];
    final bandsText = [
      for (var i = 0; i < shares.length; i++)
        '${_bandLabels[i]} sat/vB ${(shares[i] * 100).round()} %',
    ].join(', ');

    return _DashCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.explorerDashMempoolTitle.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.explorerDashTxCount(
              NumberFormat.decimalPattern(locale).format(info.count),
            ),
            style: textTheme.headlineSmall?.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Semantics(
            label: l10n.explorerDashBandsLabel(bandsText),
            child: ExcludeSemantics(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: SizedBox(
                  height: 10,
                  child: ColoredBox(
                    color: colorScheme.surfaceContainerHighest,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < shares.length; i++)
                          if (shares[i] > 0)
                            Expanded(
                              flex: max(1, (shares[i] * 1000).round()),
                              child: ColoredBox(
                                key: ValueKey('mempoolBand$i'),
                                color: colors[i],
                              ),
                            ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _KeyValue(
            label: l10n.explorerSize,
            value: l10n.explorerDashVsizeMb(
              _decimal(info.vsize / 1000000, 1, locale),
            ),
          ),
          _KeyValue(
            label: l10n.explorerDashTotalFees,
            value: l10n.explorerDashBtc(_btcText(info.totalFee, 3, locale)),
          ),
          _KeyValue(
            label: l10n.explorerDashToClear,
            value: l10n.explorerDashBlocksToClear(queuedBlocks),
          ),
        ],
      ),
    );
  }
}

/// Difficulty estimate: the change as a big number, progress through the
/// epoch, and the remaining blocks and average block time.
class ExplorerDifficultyCard extends StatelessWidget {
  const ExplorerDifficultyCard({required this.epoch, super.key});

  final DifficultyEpoch? epoch;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final sato = context.sato;
    final current = epoch;
    if (current == null) {
      return ExplorerSkeleton(height: 170);
    }

    final change = current.estimatedChange;
    final up = change == null || change >= 0;
    final changeText = change == null
        ? '—'
        : '${up ? '+' : '-'}${_decimal(change.abs() * 100, 2, locale)} %';
    final average = current.averageBlockSeconds;
    final averageText = average == null
        ? '—'
        : _minutesSeconds(average.round());
    final seconds = current.estimatedSecondsLeft;
    final blocksLeft = NumberFormat.decimalPattern(
      locale,
    ).format(current.blocksRemaining);
    final remainingText = seconds == null
        ? blocksLeft
        : seconds >= 86400
        ? l10n.explorerDashRemainingDays(
            blocksLeft,
            NumberFormat.decimalPattern(
              locale,
            ).format((seconds / 86400).round()),
          )
        : l10n.explorerDashRemainingHours(
            blocksLeft,
            NumberFormat.decimalPattern(
              locale,
            ).format((seconds / 3600).round()),
          );
    final progressLabel = l10n.explorerDashEpochProgress(
      NumberFormat.decimalPattern(locale).format(current.blocksMined),
      NumberFormat.decimalPattern(locale).format(difficultyEpochBlocks),
    );

    return _DashCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.explorerDifficulty.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            changeText,
            style: textTheme.headlineSmall?.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          if (change != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: (up ? sato.statusDeployed : colorScheme.error)
                      .withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        up
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                        size: 14,
                        color: up ? sato.statusDeployed : colorScheme.error,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        l10n.explorerDashEstimate,
                        style: textTheme.labelSmall?.copyWith(
                          color: up ? sato.statusDeployed : colorScheme.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          LinearProgressIndicator(
            value: current.progress.clamp(0.0, 1.0).toDouble(),
            minHeight: 8,
            color: colorScheme.primary,
            backgroundColor: colorScheme.surfaceContainerHighest,
            semanticsLabel: progressLabel,
          ),
          const SizedBox(height: AppSpacing.md),
          _KeyValue(
            label: l10n.explorerDashEpoch,
            value:
                '${NumberFormat.decimalPattern(locale).format(current.blocksMined)}'
                '/${NumberFormat.decimalPattern(locale).format(difficultyEpochBlocks)}',
          ),
          _KeyValue(label: l10n.explorerDashRemaining, value: remainingText),
          _KeyValue(label: l10n.explorerDashAverageBlock, value: averageText),
        ],
      ),
    );
  }
}

String _minutesSeconds(int total) {
  final seconds = total % 60;

  return '${total ~/ 60}:${seconds.toString().padLeft(2, '0')}';
}

/// A label on one line, with its value below in mono. Neither wraps inside
/// a number: a line that is too wide shrinks instead.
class _KeyValue extends StatelessWidget {
  const _KeyValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FitLine(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          _FitLine(value, style: toolMonoStyle(context, size: 13)),
        ],
      ),
    );
  }
}

/// One line of text that never breaks. A line wider than its space shrinks
/// to fit, so a number is never split across two lines.
class _FitLine extends StatelessWidget {
  const _FitLine(
    this.text, {
    this.style,
    this.alignment = Alignment.centerLeft,
  });

  final String text;
  final TextStyle? style;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(text, style: style, softWrap: false, maxLines: 1),
      ),
    );
  }
}

/// The latest transactions that entered the mempool, up to six. Each row
/// opens its transaction screen.
class ExplorerRecentList extends StatelessWidget {
  const ExplorerRecentList({required this.recent, super.key});

  final List<EsploraRecentTransaction>? recent;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final list = recent;
    if (list == null) {
      return ExplorerSkeleton(height: 180);
    }
    final shown = list.take(6).toList();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          for (var i = 0; i < shown.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 1,
                color: colorScheme.outlineVariant,
              ),
            _RecentRow(
              transaction: shown[i],
              shortId: _shortTxid(shown[i].txid),
              amount: l10n.explorerDashBtc(
                satoshiToBitcoinText(shown[i].value),
              ),
              size: l10n.explorerDashTxVsize('${shown[i].vsize}'),
              rate: l10n.explorerFeeRateValue(
                _decimal(shown[i].feeRate, 1, locale),
              ),
              textTheme: textTheme,
            ),
          ],
        ],
      ),
    );
  }
}

/// Shortened txid: the first six and the last eight characters.
String _shortTxid(String txid) {
  if (txid.length <= 16) {
    return txid;
  }

  return '${txid.substring(0, 6)}…${txid.substring(txid.length - 8)}';
}

class _RecentRow extends StatelessWidget {
  const _RecentRow({
    required this.transaction,
    required this.shortId,
    required this.amount,
    required this.size,
    required this.rate,
    required this.textTheme,
  });

  final EsploraRecentTransaction transaction;
  final String shortId;
  final String amount;
  final String size;
  final String rate;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final secondary = textTheme.labelSmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );

    return Semantics(
      button: true,
      label: [shortId, amount, size, rate].join(', '),
      onTap: () => Navigator.of(
        context,
      ).pushNamed(AppRoutes.explorerTransaction(transaction.txid)),
      excludeSemantics: true,
      child: InkWell(
        onTap: () => Navigator.of(
          context,
        ).pushNamed(AppRoutes.explorerTransaction(transaction.txid)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _FitLine(
                        shortId,
                        style: toolMonoStyle(
                          context,
                          size: 12.5,
                        ).copyWith(color: colorScheme.primary),
                      ),
                      Text(size, style: secondary),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      amount,
                      style: toolMonoStyle(context, size: 12.5),
                      textAlign: TextAlign.end,
                    ),
                    Text(rate, style: secondary, textAlign: TextAlign.end),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Refresh state, the pause button, and the privacy line. The status text is
/// read first, then the failure line when the last update failed.
class ExplorerDashboardFooter extends StatelessWidget {
  const ExplorerDashboardFooter({
    required this.state,
    required this.paused,
    required this.interval,
    required this.host,
    required this.onToggle,
    super.key,
  });

  final ExplorerDashboardState state;
  final bool paused;
  final Duration interval;
  final String host;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final updated = state.updatedAt;
    final String status;
    if (paused) {
      status = l10n.explorerDashPaused;
    } else if (updated != null) {
      final time = DateFormat.Hm(
        Localizations.localeOf(context).toLanguageTag(),
      ).format(updated.toLocal());
      status = l10n.explorerDashFooterUpdated(time, interval.inSeconds);
    } else if (state.loading) {
      status = l10n.explorerLoading;
    } else {
      status = '';
    }
    final failed = state.error != null && updated != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(AppRadii.tile),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xs,
              AppSpacing.xs,
              AppSpacing.xs,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (status.isNotEmpty)
                        Text(
                          status,
                          style: textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      if (failed)
                        Text(
                          l10n.explorerDashUpdateFailed,
                          style: textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: paused
                      ? l10n.explorerDashResume
                      : l10n.explorerDashPause,
                  icon: Icon(
                    paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                  ),
                  onPressed: onToggle,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          l10n.explorerDashPrivacy(state.requestsPerRound, host),
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
