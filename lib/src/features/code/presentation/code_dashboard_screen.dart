import 'package:flutter/material.dart';

import '../../../generated/l10n/app_localizations.dart';
import '../../../core/content/domain/content_models.dart';
import '../../../core/content/domain/content_store.dart';
import '../../../core/localization/localized_labels.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/widgets/markdown_text.dart';
import '../../../core/widgets/section_title.dart';
import '../../../core/widgets/status_badge.dart';

class CodeDashboardScreen extends StatefulWidget {
  const CodeDashboardScreen({required this.store, super.key});

  final ContentStore store;

  @override
  State<CodeDashboardScreen> createState() => _CodeDashboardScreenState();
}

class _CodeDashboardScreenState extends State<CodeDashboardScreen> {
  BipStatus? _selectedFilter;

  List<Bip> get _filteredBips {
    final bips = widget.store.bundle.bips;
    if (_selectedFilter == null) return bips;
    return bips.where((b) => b.status == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final bips = _filteredBips;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 24),
      children: [
        Text(
          l10n.codeDashboardTitle,
          style: textTheme.displayLarge?.copyWith(fontSize: 42, height: 1.08),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.codeDashboardSubtitle,
          style: textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        _StatusFilters(
          selected: _selectedFilter,
          onSelected: (f) => setState(() => _selectedFilter = f),
        ),
        const SizedBox(height: 28),
        _BipTrackerCard(store: widget.store),
        const SizedBox(height: 16),
        _ChangelogSummaryCard(store: widget.store),
        const SizedBox(height: 28),
        SectionTitle(
          title: l10n.recentBips,
          actionLabel: l10n.filter,
          onAction: null,
        ),
        const SizedBox(height: 16),
        if (bips.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                l10n.noBipsMatchFilter,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          for (final bip in bips) ...[
            _BipCard(
              bip: bip,
              onTap: () => Navigator.of(
                context,
              ).pushNamed(AppRoutes.codeBip(bip.number)),
            ),
            const SizedBox(height: 10),
          ],
      ],
    );
  }
}

class _StatusFilters extends StatelessWidget {
  const _StatusFilters({required this.selected, required this.onSelected});

  final BipStatus? selected;
  final ValueChanged<BipStatus?> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    const filters = [
      null,
      BipStatus.active,
      BipStatus.draft,
      BipStatus.proposed,
      BipStatus.rejected,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final filter in filters)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(filter?.label(l10n) ?? l10n.all),
                selected: filter == selected,
                showCheckmark: false,
                onSelected: (_) => onSelected(filter),
                selectedColor: colorScheme.primaryContainer,
                labelStyle: TextStyle(
                  color: filter == selected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant,
                ),
                side: BorderSide(
                  color: filter == selected
                      ? colorScheme.primary
                      : colorScheme.outlineVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BipTrackerCard extends StatelessWidget {
  const _BipTrackerCard({required this.store});

  final ContentStore store;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final bips = store.bundle.bips;

    final activeCount = bips.where((b) => b.status == BipStatus.active).length;
    final draftCount = bips.where((b) => b.status == BipStatus.draft).length;
    final rejectedCount = bips
        .where((b) => b.status == BipStatus.rejected)
        .length;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_outlined, color: colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                l10n.bipTracker,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _CountBox(
                  label: l10n.activeUpper,
                  count: activeCount,
                  color: colorScheme.tertiary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _CountBox(
                  label: l10n.draftUpper,
                  count: draftCount,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _CountBox(
                  label: l10n.rejectedUpper,
                  count: rejectedCount,
                  color: colorScheme.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CountBox extends StatelessWidget {
  const _CountBox({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Text(
            '$count',
            style: textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontFamily: 'JetBrains Mono',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChangelogSummaryCard extends StatelessWidget {
  const _ChangelogSummaryCard({required this.store});

  final ContentStore store;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    const maxItems = 3;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.commit_outlined, color: colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                l10n.changelog,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (store.bundle.changelogs.isEmpty)
            Text(
              l10n.noRecentReleases,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            )
          else
            for (
              var i = 0;
              i < store.bundle.changelogs.length && i < maxItems;
              i++
            ) ...[
              _ChangelogItem(
                release: store.bundle.changelogs[i],
                isFirst: i == 0,
              ),
              if (i < store.bundle.changelogs.length - 1 && i < maxItems - 1)
                const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}

class _ChangelogItem extends StatelessWidget {
  const _ChangelogItem({required this.release, this.isFirst = false});

  final ReleaseNote release;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            color: isFirst ? colorScheme.primary : colorScheme.outlineVariant,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                release.title,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${release.project} ${release.version}',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontFamily: 'JetBrains Mono',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BipCard extends StatelessWidget {
  const _BipCard({required this.bip, required this.onTap});

  final Bip bip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final categoryTag = bip.tags.isNotEmpty ? bip.tags.first : bip.category;
    final dotColor = _statusDotColor(bip.status, colorScheme);

    return Material(
      color: colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: colorScheme.outlineVariant),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Text(
                          'BIP ${bip.number}',
                          style: textTheme.labelSmall?.copyWith(
                            fontFamily: 'JetBrains Mono',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bip.title,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            bip.summary,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (categoryTag.isNotEmpty)
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  child: Text(
                    _capitalize(categoryTag),
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: dotColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: dotColor.withValues(alpha: 0.3)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: dotColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        bip.status.label(l10n).toUpperCase(),
                        style: textTheme.labelSmall?.copyWith(
                          color: dotColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusDotColor(BipStatus status, ColorScheme colors) {
    return switch (status) {
      BipStatus.active || BipStatus.finalStatus => colors.tertiary,
      BipStatus.draft => colors.primary,
      BipStatus.proposed => colors.primary.withValues(alpha: 0.6),
      BipStatus.withdrawn => colors.error.withValues(alpha: 0.6),
      BipStatus.rejected => colors.error,
    };
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return '${s[0].toUpperCase()}${s.substring(1)}';
  }
}

class BipDetailScreen extends StatelessWidget {
  const BipDetailScreen({required this.store, required this.number, super.key});

  final ContentStore store;
  final int number;

  @override
  Widget build(BuildContext context) {
    final bip = store.bundle.bips
        .where((bip) => bip.number == number)
        .firstOrNull;

    if (bip == null) {
      final l10n = AppLocalizations.of(context);
      return Scaffold(
        appBar: AppBar(title: Text(l10n.codeTab)),
        body: Center(child: Text(l10n.bipNotFound)),
      );
    }

    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(l10n.appTitle),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            Row(
              children: [
                _StatusPill(status: bip.status),
                const SizedBox(width: 10),
                Text(
                  'BIP ${bip.number}',
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontFamily: 'JetBrains Mono',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${bip.title}: ${bip.summary}',
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: colorScheme.surfaceContainerHighest),
                  bottom: BorderSide(
                    color: colorScheme.surfaceContainerHighest,
                  ),
                ),
              ),
              child: Wrap(
                spacing: 24,
                runSpacing: 12,
                children: [
                  _MetaColumn(
                    label: l10n.authors,
                    value: bip.authors.join(', '),
                    useMono: false,
                  ),
                  _MetaColumn(
                    label: l10n.created,
                    value: bip.createdAt.toIso8601String().split('T').first,
                    useMono: true,
                  ),
                  _MetaColumn(
                    label: l10n.layer,
                    value: _capitalize(bip.category),
                    useMono: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.menu_book_outlined,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.plainEnglishSummary,
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  MarkdownText(bip.summaryMarkdown),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SectionTitle(title: l10n.practicalImpact),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: MarkdownText(bip.impactMarkdown),
            ),
            const SizedBox(height: 24),
            SectionTitle(title: l10n.statusHistory),
            const SizedBox(height: 12),
            _StatusTimeline(history: bip.statusHistory),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                _FooterLink(
                  icon: Icons.terminal_outlined,
                  label: l10n.viewOfficialTextOnGitHub,
                  url: bip.officialUrl.toString(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return '${s[0].toUpperCase()}${s.substring(1)}';
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final BipStatus status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final color = switch (status) {
      BipStatus.active ||
      BipStatus.finalStatus => colorScheme.tertiaryContainer,
      BipStatus.draft => colorScheme.primaryContainer,
      BipStatus.proposed => colorScheme.secondaryContainer,
      BipStatus.withdrawn || BipStatus.rejected => colorScheme.errorContainer,
    };
    final textColor = switch (status) {
      BipStatus.active ||
      BipStatus.finalStatus => colorScheme.onTertiaryContainer,
      BipStatus.draft => colorScheme.onPrimaryContainer,
      BipStatus.proposed => colorScheme.onSecondaryContainer,
      BipStatus.withdrawn || BipStatus.rejected => colorScheme.onErrorContainer,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.label(l10n),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w700,
          fontFamily: 'JetBrains Mono',
          letterSpacing: 0.05,
        ),
      ),
    );
  }
}

class _MetaColumn extends StatelessWidget {
  const _MetaColumn({
    required this.label,
    required this.value,
    required this.useMono,
  });

  final String label;
  final String value;
  final bool useMono;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontFamily: 'JetBrains Mono',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: useMono
              ? textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontFamily: 'JetBrains Mono',
                )
              : textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
        ),
      ],
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  const _StatusTimeline({required this.history});

  final List<BipStatusChange> history;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < history.length; i++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: i == history.length - 1 ? 14 : 10,
                    height: i == history.length - 1 ? 14 : 10,
                    decoration: BoxDecoration(
                      color: i == history.length - 1
                          ? colorScheme.tertiary
                          : colorScheme.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.outlineVariant,
                        width: 2,
                      ),
                      boxShadow: i == history.length - 1
                          ? [
                              BoxShadow(
                                color: colorScheme.tertiary.withValues(
                                  alpha: 0.4,
                                ),
                                blurRadius: 8,
                              ),
                            ]
                          : null,
                    ),
                  ),
                  if (i < history.length - 1)
                    Container(
                      width: 1,
                      height: 32,
                      color: colorScheme.outlineVariant,
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Padding(
                padding: EdgeInsets.only(
                  top: i == history.length - 1 ? 0 : 0,
                  bottom: i < history.length - 1 ? 24 : 0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      history[i].date.toIso8601String().split('T').first,
                      style: textTheme.labelSmall?.copyWith(
                        color: i == history.length - 1
                            ? colorScheme.tertiary
                            : colorScheme.onSurfaceVariant,
                        fontFamily: 'JetBrains Mono',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      history[i].note,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: i == history.length - 1
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({
    required this.icon,
    required this.label,
    required this.url,
  });

  final IconData icon;
  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: textTheme.labelMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReleaseNoteScreen extends StatelessWidget {
  const ReleaseNoteScreen({
    required this.store,
    required this.project,
    required this.version,
    super.key,
  });

  final ContentStore store;
  final String project;
  final String version;

  @override
  Widget build(BuildContext context) {
    final release = store.bundle.changelogs
        .where(
          (release) => release.project == project && release.version == version,
        )
        .firstOrNull;

    if (release == null) {
      final l10n = AppLocalizations.of(context);
      return Scaffold(
        appBar: AppBar(title: Text(l10n.codeTab)),
        body: Center(child: Text(l10n.releaseNotFound)),
      );
    }

    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(l10n.appTitle),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            StatusBadge(
              status: release.importance == ReleaseImportance.major
                  ? ContentStatus.major
                  : ContentStatus.minor,
            ),
            const SizedBox(height: 12),
            Text(
              release.title,
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              release.summary,
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            SectionTitle(title: l10n.userImpact),
            const SizedBox(height: 8),
            MarkdownText(release.userImpactMarkdown),
            const SizedBox(height: 24),
            SectionTitle(title: l10n.technicalChanges),
            const SizedBox(height: 8),
            MarkdownText(release.technicalChangesMarkdown),
          ],
        ),
      ),
    );
  }
}
