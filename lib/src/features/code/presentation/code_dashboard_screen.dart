import 'package:flutter/material.dart';

import '../../../core/content/domain/content_models.dart';
import '../../../core/content/domain/content_store.dart';
import '../../../core/localization/content_labels.dart';
import '../../../core/localization/localized_labels.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/settings/app_settings_scope.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/filter_chip_bar.dart';
import '../../../core/widgets/round_icon_button.dart';
import '../../../core/widgets/sato_group_card.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/section_title.dart';
import '../../../core/widgets/status_pill.dart';
import '../../../generated/l10n/app_localizations.dart';
import 'release_list_screen.dart';

export 'bip_detail_screen.dart';
export 'release_note_screen.dart';

const _statusOrder = [
  BipStatus.deployed,
  BipStatus.complete,
  BipStatus.draft,
  BipStatus.closed,
];

class CodeDashboardScreen extends StatelessWidget {
  const CodeDashboardScreen({required this.store, super.key});

  final ContentStore store;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bips = store.bundle.bips;
    final releases = store.bundle.changelogs;
    final recentBips = _sortBips(bips, _BipSortOrder.descending).take(3);
    final recentReleases = _sortReleases(releases).take(3);

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.tabBarClearance),
      children: [
        ScreenHeader(
          title: l10n.codeTab,
          subtitle: l10n.codeSummary(bips.length, releases.length),
          actions: [
            RoundIconButton(
              icon: Icons.search_rounded,
              tooltip: l10n.searchTooltip,
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.search),
            ),
          ],
        ),
        _gutter(
          top: AppSpacing.xl,
          child: _BipStatusCard(store: store),
        ),
        _gutter(
          top: AppSpacing.section,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle(
                title: l10n.recentBips,
                actionLabel: l10n.allCount(bips.length),
                onAction: () =>
                    Navigator.of(context).pushNamed(AppRoutes.codeBips),
              ),
              const SizedBox(height: AppSpacing.md),
              if (recentBips.isEmpty)
                _emptyState(context, l10n.noBipsAvailable)
              else
                SatoGroupCard(
                  children: [for (final bip in recentBips) _BipRow(bip: bip)],
                ),
            ],
          ),
        ),
        _gutter(
          top: AppSpacing.section,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle(
                title: l10n.releases,
                actionLabel: l10n.seeAll,
                onAction: () =>
                    Navigator.of(context).pushNamed(AppRoutes.codeChangelogs),
              ),
              const SizedBox(height: AppSpacing.md),
              if (recentReleases.isEmpty)
                _emptyState(context, l10n.noRecentReleases)
              else
                SatoGroupCard(
                  children: [
                    for (final release in recentReleases)
                      ReleaseRow(release: release),
                  ],
                ),
            ],
          ),
        ),
        _gutter(top: AppSpacing.section, child: const _ToolsSection()),
        _gutter(top: AppSpacing.section, child: const _LearnSection()),
        _gutter(top: AppSpacing.section, child: const _NetworkSection()),
      ],
    );
  }
}

/// Offline tools and reference tables, two tiles per row.
class _ToolsSection extends StatelessWidget {
  const _ToolsSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tiles = [
      _ToolTile(
        name: l10n.toolsTileHashName,
        caption: l10n.toolsTileHashCaption,
        route: AppRoutes.toolHash,
      ),
      _ToolTile(
        name: l10n.toolsTileAddressName,
        caption: l10n.toolsTileAddressCaption,
        route: AppRoutes.toolAddress,
      ),
      _ToolTile(
        name: l10n.toolsTileTransactionName,
        caption: l10n.toolsTileTransactionCaption,
        route: AppRoutes.toolTransaction,
      ),
      _ToolTile(
        name: l10n.toolsTileTargetName,
        caption: l10n.toolsTileTargetCaption,
        route: AppRoutes.toolTarget,
      ),
      _ToolTile(
        name: l10n.toolsTileUnitsName,
        caption: l10n.toolsTileUnitsCaption,
        route: AppRoutes.toolUnits,
      ),
      _ToolTile(
        name: l10n.toolsTileTablesName,
        caption: l10n.toolsTileTablesCaption,
        route: AppRoutes.references,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: l10n.toolsSectionTools),
        const SizedBox(height: AppSpacing.md),
        for (var start = 0; start < tiles.length; start += 2) ...[
          if (start > 0) const SizedBox(height: AppSpacing.md),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: tiles[start]),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: tiles[start + 1]),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ToolTile extends StatelessWidget {
  const _ToolTile({
    required this.name,
    required this.caption,
    required this.route,
  });

  final String name;
  final String caption;
  final String route;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: colorScheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: () => Navigator.of(context).pushNamed(route),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              Text(caption, style: textTheme.labelMedium),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lab and script stepper. The screens come later: their rows already open
/// their routes.
class _LearnSection extends StatelessWidget {
  const _LearnSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: l10n.toolsSectionLearn),
        const SizedBox(height: AppSpacing.md),
        SatoGroupCard(
          children: [
            _ActionRow(
              title: l10n.toolsLabName,
              caption: l10n.toolsLabCaption,
              route: AppRoutes.lab,
            ),
            _ActionRow(
              title: l10n.toolsScriptName,
              caption: l10n.toolsScriptCaption,
              route: AppRoutes.scriptStepper,
            ),
          ],
        ),
      ],
    );
  }
}

/// Explorer row. The caption shows the real state: off, or on with the server
/// host. The row opens the explorer when it is on, and the setup screen when
/// it is off.
class _NetworkSection extends StatelessWidget {
  const _NetworkSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = AppSettingsScope.maybeOf(context);
    final enabled = settings?.explorerEnabled ?? false;
    final host = enabled ? Uri.tryParse(settings!.explorerServer)?.host : null;
    final caption = !enabled
        ? l10n.explorerStateOff
        : host == null || host.isEmpty
        ? l10n.explorerStateOn
        : l10n.explorerStateOnServer(host);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: l10n.toolsSectionNetwork),
        const SizedBox(height: AppSpacing.md),
        SatoGroupCard(
          children: [
            _ActionRow(
              title: l10n.toolsExplorerName,
              caption: caption,
              route: enabled ? AppRoutes.explorer : AppRoutes.explorerSetup,
            ),
          ],
        ),
      ],
    );
  }
}

/// Row with a title, a caption and a chevron, opening [route].
class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.title,
    required this.caption,
    required this.route,
  });

  final String title;
  final String caption;
  final String route;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(route),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 14,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(caption, style: textTheme.bodySmall),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BipListScreen extends StatefulWidget {
  const BipListScreen({required this.store, super.key});

  final ContentStore store;

  @override
  State<BipListScreen> createState() => _BipListScreenState();
}

class _BipListScreenState extends State<BipListScreen> {
  static const List<BipStatus?> _filters = [
    null,
    BipStatus.deployed,
    BipStatus.complete,
    BipStatus.draft,
    BipStatus.closed,
  ];

  BipStatus? _selectedStatus;
  _BipSortOrder _sortOrder = _BipSortOrder.descending;
  bool _didReadArguments = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didReadArguments) return;
    _didReadArguments = true;
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is BipStatus) _selectedStatus = arguments;
  }

  List<Bip> get _bips {
    final filtered = _selectedStatus == null
        ? widget.store.bundle.bips
        : widget.store.bundle.bips
              .where((bip) => bip.status == _selectedStatus)
              .toList(growable: false);

    return _sortBips(filtered, _sortOrder);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final bips = _bips;
    const gutter = AppSpacing.gutter;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(gutter, 8, gutter, 0),
                child: Row(
                  children: [
                    RoundIconButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      tooltip: l10n.back,
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        l10n.allBipsTitle,
                        style: textTheme.headlineMedium,
                      ),
                    ),
                    RoundIconButton(
                      icon: Icons.swap_vert_rounded,
                      tooltip: switch (_sortOrder) {
                        _BipSortOrder.descending => l10n.bipNumberAscending,
                        _BipSortOrder.ascending => l10n.bipNumberDescending,
                      },
                      onPressed: () {
                        setState(() {
                          _sortOrder = switch (_sortOrder) {
                            _BipSortOrder.descending => _BipSortOrder.ascending,
                            _BipSortOrder.ascending => _BipSortOrder.descending,
                          };
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: gutter),
                child: FilterChipBar<BipStatus?>(
                  items: _filters,
                  selectedItem: _selectedStatus,
                  labelFor: (status) =>
                      status == null ? l10n.all : status.label(l10n),
                  onSelected: (status) {
                    setState(() => _selectedStatus = status);
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
            if (bips.isEmpty)
              SliverToBoxAdapter(
                child: _emptyState(
                  context,
                  widget.store.bundle.bips.isEmpty
                      ? l10n.noBipsAvailable
                      : l10n.noBipsMatchFilter,
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: gutter),
                sliver: SliverList.separated(
                  itemCount: bips.length,
                  itemBuilder: (context, index) {
                    return Material(
                      color: colorScheme.surfaceContainerLow,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.card),
                        side: BorderSide(color: colorScheme.outlineVariant),
                      ),
                      child: _BipRow(bip: bips[index]),
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                ),
              ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 32 + MediaQuery.paddingOf(context).bottom,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _BipSortOrder { descending, ascending }

List<Bip> _sortBips(Iterable<Bip> bips, _BipSortOrder order) {
  final sorted = bips.toList(growable: false);
  sorted.sort((a, b) {
    return switch (order) {
      _BipSortOrder.descending => b.number.compareTo(a.number),
      _BipSortOrder.ascending => a.number.compareTo(b.number),
    };
  });

  return sorted;
}

List<ReleaseNote> _sortReleases(Iterable<ReleaseNote> releases) {
  final sorted = releases.toList(growable: false);
  sorted.sort((a, b) => b.releasedAt.compareTo(a.releasedAt));

  return sorted;
}

Widget _gutter({required double top, required Widget child}) {
  return Padding(
    padding: EdgeInsets.fromLTRB(AppSpacing.gutter, top, AppSpacing.gutter, 0),
    child: child,
  );
}

Widget _emptyState(BuildContext context, String message) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 32),
    child: Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    ),
  );
}

class _BipStatusCard extends StatelessWidget {
  const _BipStatusCard({required this.store});

  final ContentStore store;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final bips = store.bundle.bips;
    final counts = {
      for (final status in _statusOrder)
        status: bips.where((bip) => bip.status == status).length,
    };
    final summary = _statusOrder
        .map((status) => '${status.label(l10n)} ${counts[status]}')
        .join(', ');

    final segments = <Widget>[];
    for (final status in _statusOrder) {
      final count = counts[status]!;
      if (count == 0) continue;
      if (segments.isNotEmpty) segments.add(const SizedBox(width: 3));
      segments.add(
        Expanded(
          flex: count,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: bipStatusColor(context, status),
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            child: const SizedBox(height: 12),
          ),
        ),
      );
    }

    return Material(
      color: colorScheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.media),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(l10n.bipStatusTitle, style: textTheme.titleLarge),
                ),
                Text(
                  l10n.totalCount(bips.length),
                  style: textTheme.labelMedium,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Semantics(
              label: summary,
              child: ExcludeSemantics(
                child: SizedBox(height: 12, child: Row(children: segments)),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            IntrinsicHeight(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _StatusTile(
                          status: BipStatus.deployed,
                          count: counts[BipStatus.deployed]!,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatusTile(
                          status: BipStatus.complete,
                          count: counts[BipStatus.complete]!,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _StatusTile(
                          status: BipStatus.draft,
                          count: counts[BipStatus.draft]!,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatusTile(
                          status: BipStatus.closed,
                          count: counts[BipStatus.closed]!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusTile extends StatelessWidget {
  const _StatusTile({required this.status, required this.count});

  final BipStatus status;
  final int count;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(AppRadii.tile),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.tile),
        onTap: () => Navigator.of(
          context,
        ).pushNamed(AppRoutes.codeBips, arguments: status),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$count',
                style: textTheme.headlineSmall?.copyWith(
                  fontSize: 26,
                  height: 30 / 26,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: bipStatusColor(context, status),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      status.label(l10n),
                      style: textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

class _BipRow extends StatelessWidget {
  const _BipRow({required this.bip});

  final Bip bip;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () =>
          Navigator.of(context).pushNamed(AppRoutes.codeBip(bip.number)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'BIP ${bip.number}',
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    contentCategoryLabel(bip.category, l10n).toUpperCase(),
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                BipStatusPill(status: bip.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              bip.title,
              style: textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
