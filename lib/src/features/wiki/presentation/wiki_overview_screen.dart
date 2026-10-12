import 'package:flutter/material.dart';

import '../../../core/content/domain/content_models.dart';
import '../../../core/content/domain/content_store.dart';
import '../../../core/content/reading_level.dart';
import '../../../core/localization/content_labels.dart';
import '../../../core/localization/localized_labels.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/settings/app_settings_controller.dart';
import '../../../core/settings/app_settings_scope.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/sato_colors.dart';
import '../../../core/widgets/bookmark_button.dart';
import '../../../core/widgets/content_mappers.dart';
import '../../../core/widgets/content_thumbnail.dart';
import '../../../core/widgets/detail_scaffold.dart';
import '../../../core/widgets/filter_chip_bar.dart';
import '../../../core/widgets/hero_media.dart';
import '../../../core/widgets/markdown_text.dart';
import '../../../core/widgets/meta_line.dart';
import '../../../core/widgets/reading_level_selector.dart';
import '../../../core/widgets/related_links_grid.dart';
import '../../../core/widgets/round_icon_button.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/section_title.dart';
import '../../../core/widgets/sources_disclosure.dart';
import '../../../core/widgets/tag_pill.dart';
import '../../../generated/l10n/app_localizations.dart';

//
// ─── WIKI TAB: HEADER, SEARCH, LEVEL, CATEGORIES, EXPLORE ─────────────────────
//

/// Categories listed first, in this order. Others follow alphabetically.
const _leadingCategoryKeys = [
  'protocol',
  'cryptography',
  'lightning network',
  'economics',
];

const _exploreCount = 6;

class WikiOverviewScreen extends StatelessWidget {
  const WikiOverviewScreen({
    required this.store,
    required this.selectedLevel,
    required this.onLevelChanged,
    super.key,
  });

  final ContentStore store;
  final ReadingLevel selectedLevel;
  final ValueChanged<ReadingLevel> onLevelChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final entries = store.bundle.wiki;
    final categories = _categoriesFor(entries);
    final explore = entries.isEmpty
        ? const <WikiEntry>[]
        : _dailySelection(entries, DateTime.now());

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.tabBarClearance),
      children: [
        ScreenHeader(
          title: l10n.wikiTab,
          subtitle: l10n.entriesInCategories(entries.length, categories.length),
          actions: [
            RoundIconButton(
              icon: Icons.tune_rounded,
              tooltip: l10n.settingsTooltip,
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.settings),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.gutter),
              _SearchField(
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.search),
              ),
              const SizedBox(height: AppSpacing.section),
              Text(l10n.readingLevelTitle, style: textTheme.titleLarge),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.readingLevelAppliesToAll,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ReadingLevelSelector(
                selectedLevel: selectedLevel,
                onLevelChanged: onLevelChanged,
              ),
              const SizedBox(height: AppSpacing.section),
              SectionTitle(title: l10n.categories),
              const SizedBox(height: AppSpacing.md),
              ..._categoryRows(context, categories, l10n),
              if (explore.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.section),
                SectionTitle(title: l10n.toExplore),
                const SizedBox(height: AppSpacing.md),
                ..._spaced([
                  for (final entry in explore)
                    _EntryRow(
                      entry: entry,
                      onTap: () => _openEntry(context, entry),
                    ),
                ], AppSpacing.md),
              ],
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _categoryRows(
    BuildContext context,
    List<_CategorySummary> categories,
    AppLocalizations l10n,
  ) {
    final rows = <Widget>[];
    for (var start = 0; start < categories.length; start += 2) {
      if (start > 0) rows.add(const SizedBox(height: AppSpacing.md));
      final first = categories[start];
      final hasSecond = start + 1 < categories.length;
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _CategoryTile(
                  category: first.category,
                  count: first.count,
                  onTap: () => _openCategory(context, first.category),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: hasSecond
                    ? _CategoryTile(
                        category: categories[start + 1].category,
                        count: categories[start + 1].count,
                        onTap: () => _openCategory(
                          context,
                          categories[start + 1].category,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      );
    }
    return rows;
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return Semantics(
      button: true,
      child: Material(
        color: colorScheme.surfaceContainerLow,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 48,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      l10n.searchWikiHint,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategorySummary {
  const _CategorySummary({required this.category, required this.count});

  final String category;
  final int count;
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.count,
    required this.onTap,
  });

  final String category;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return _CardSurface(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 132),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.sato.accentTint,
                  borderRadius: BorderRadius.circular(AppRadii.thumb),
                ),
                child: Icon(
                  _iconForCategory(category),
                  size: 22,
                  color: colorScheme.primary,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    contentCategoryLabel(category, l10n),
                    style: textTheme.titleLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(l10n.entriesCount(count), style: textTheme.labelMedium),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//
// ─── CATEGORY LIST: ENTRIES WITH TAG FILTER ───────────────────────────────────
//

class WikiCategoryScreen extends StatefulWidget {
  const WikiCategoryScreen({
    required this.store,
    required this.category,
    super.key,
  });

  final ContentStore store;
  final String category;

  @override
  State<WikiCategoryScreen> createState() => _WikiCategoryScreenState();
}

class _WikiCategoryScreenState extends State<WikiCategoryScreen> {
  String? _selectedTag;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final categoryEntries = widget.store.bundle.wiki
        .where(
          (entry) =>
              entry.category.toLowerCase() == widget.category.toLowerCase(),
        )
        .toList(growable: false);
    final tags = _tagsOf(categoryEntries);
    final entries = _selectedTag == null
        ? categoryEntries
        : categoryEntries
              .where((entry) => entry.tags.contains(_selectedTag))
              .toList(growable: false);

    return DetailScaffold(
      title: contentCategoryLabel(widget.category, l10n),
      children: [
        Text(
          l10n.entriesCount(categoryEntries.length),
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        if (tags.length > 1) ...[
          const SizedBox(height: AppSpacing.lg),
          FilterChipBar<String?>(
            items: <String?>[null, ...tags],
            selectedItem: _selectedTag,
            labelFor: (tag) => tag ?? l10n.all,
            onSelected: (tag) => setState(() => _selectedTag = tag),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        if (entries.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.section),
            child: Text(
              l10n.noLocalResultFound,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ..._spaced([
          for (final entry in entries)
            _EntryRow(entry: entry, onTap: () => _openEntry(context, entry)),
        ], AppSpacing.md),
      ],
    );
  }

  List<String> _tagsOf(List<WikiEntry> entries) {
    final tags = <String>{};
    for (final entry in entries) {
      tags.addAll(entry.tags);
    }
    return tags.toList()..sort();
  }
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({required this.entry, required this.onTap});

  final WikiEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return _CardSurface(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            ContentThumbnail(
              source: entry.coverImage?.toString(),
              width: 92,
              height: 68,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    contentCategoryLabel(entry.category, l10n).toUpperCase(),
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs + 2),
                  Text(
                    entry.title,
                    style: textTheme.titleLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs + 2),
                  Text(
                    '${l10n.shortMin(entry.readTimeMinutes)} · '
                    '${entry.difficulty.label(l10n)}',
                    style: textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

class _CardSurface extends StatelessWidget {
  const _CardSurface({required this.onTap, required this.child});

  final VoidCallback onTap;
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
      child: InkWell(onTap: onTap, child: child),
    );
  }
}

//
// ─── ENTRY DETAIL: READER ─────────────────────────────────────────────────────
//

class WikiEntryScreen extends StatefulWidget {
  const WikiEntryScreen({
    required this.store,
    required this.slug,
    required this.selectedLevel,
    required this.onLevelChanged,
    super.key,
  });

  final ContentStore store;
  final String slug;
  final ReadingLevel selectedLevel;
  final ValueChanged<ReadingLevel> onLevelChanged;

  @override
  State<WikiEntryScreen> createState() => _WikiEntryScreenState();
}

class _WikiEntryScreenState extends State<WikiEntryScreen> {
  final ScrollController _scrollController = ScrollController();
  AppSettingsController? _settings;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onFirstLayout());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _settings = AppSettingsScope.maybeOf(context);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  WikiEntry? _findEntry() {
    return widget.store.bundle.wiki
        .where((entry) => entry.slug == widget.slug || entry.id == widget.slug)
        .firstOrNull;
  }

  /// Content that fits the screen counts as fully read.
  void _onFirstLayout() {
    if (!mounted || !_scrollController.hasClients) return;
    if (_scrollController.position.maxScrollExtent <= 0) {
      _reportProgress(1.0);
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.maxScrollExtent <= 0) return;
    _reportProgress(position.pixels / position.maxScrollExtent);
  }

  void _reportProgress(double value) {
    final entry = _findEntry();
    if (entry == null) return;

    final next = value.clamp(0.0, 1.0).toDouble();
    if ((next * 100).round() != (_progress * 100).round()) {
      setState(() => _progress = next);
    }
    _settings?.setReadingProgress(entry.id, next);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final entry = _findEntry();

    if (entry == null) {
      return DetailScaffold(title: l10n.wikiEntryNotFound, children: const []);
    }

    final settings = _settings;
    final level = widget.selectedLevel;
    final readerTextScale = settings?.readerTextScale ?? 1.0;

    return DetailScaffold(
      controller: _scrollController,
      progress: _progress,
      actions: [
        if (settings != null)
          RoundIconButton.child(
            tooltip: l10n.textSize,
            onPressed: settings.cycleReaderTextScale,
            child: Text(
              'Aa',
              style: textTheme.titleSmall?.copyWith(
                fontFamily: AppFonts.display,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        BookmarkButton(contentId: entry.id),
      ],
      children: [
        if (entry.coverImage != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.media),
            child: ContentImageFigure(
              source: entry.coverImage.toString(),
              alt: entry.title,
              aspectRatio: 16 / 9,
              showCaption: false,
              padding: EdgeInsets.zero,
              fit: BoxFit.cover,
            ),
          )
        else
          HeroMedia(
            icon: _iconForEntry(entry),
            label: l10n.entryConceptualVisual(entry.title),
          ),
        const SizedBox(height: AppSpacing.gutter),
        MetaLine(
          label: contentCategoryLabel(entry.category, l10n),
          parts: [
            l10n.shortMin(entry.readTimeMinutes),
            entry.difficulty.label(l10n),
          ],
        ),
        const SizedBox(height: 10),
        Semantics(
          header: true,
          child: Text(entry.title, style: textTheme.headlineLarge),
        ),
        const SizedBox(height: 10),
        Text(
          entry.description,
          style: textTheme.bodyLarge?.copyWith(
            height: 26 / 17,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.gutter),
        ReadingLevelSelector(
          selectedLevel: level,
          onLevelChanged: widget.onLevelChanged,
        ),
        const SizedBox(height: AppSpacing.xl),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: KeyedSubtree(
            key: ValueKey(level),
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(
                  MediaQuery.textScalerOf(context).scale(1) * readerTextScale,
                ),
              ),
              child: MarkdownText(
                entry.contentFor(level).bodyMarkdown,
                store: widget.store,
              ),
            ),
          ),
        ),
        if (entry.tags.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.gutter),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [for (final tag in entry.tags) TagPill(label: tag)],
          ),
        ],
        if (entry.related.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.section),
          SectionTitle(title: l10n.relatedConcepts),
          const SizedBox(height: AppSpacing.md),
          RelatedLinksGrid(
            links: relatedLinks(
              entry.related,
              store: widget.store,
              onOpen: (route) => Navigator.of(context).pushNamed(route),
            ),
          ),
        ],
        if (entry.sources.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          SourcesDisclosure(sources: sourceReferences(entry.sources)),
        ],
      ],
    );
  }
}

//
// ─── HELPERS ──────────────────────────────────────────────────────────────────
//

void _openEntry(BuildContext context, WikiEntry entry) {
  Navigator.of(context).pushNamed(AppRoutes.wikiEntry(entry.slug));
}

void _openCategory(BuildContext context, String category) {
  Navigator.of(context).pushNamed(AppRoutes.wikiCategory(category));
}

/// Distinct categories: the leading ones first, the rest alphabetically.
List<_CategorySummary> _categoriesFor(List<WikiEntry> entries) {
  final rawByKey = <String, String>{};
  final counts = <String, int>{};
  for (final entry in entries) {
    final key = entry.category.toLowerCase();
    rawByKey.putIfAbsent(key, () => entry.category);
    counts[key] = (counts[key] ?? 0) + 1;
  }

  final keys = counts.keys.toList()..sort(_compareCategoryKeys);
  return [
    for (final key in keys)
      _CategorySummary(category: rawByKey[key]!, count: counts[key]!),
  ];
}

int _compareCategoryKeys(String a, String b) {
  final indexA = _leadingCategoryKeys.indexOf(a);
  final indexB = _leadingCategoryKeys.indexOf(b);
  if (indexA != -1 || indexB != -1) {
    if (indexA == -1) return 1;
    if (indexB == -1) return -1;
    return indexA.compareTo(indexB);
  }
  return a.compareTo(b);
}

/// Up to [_exploreCount] entries, sorted by id, starting at the day's offset.
List<WikiEntry> _dailySelection(List<WikiEntry> entries, DateTime today) {
  final sorted = [...entries]..sort((a, b) => a.id.compareTo(b.id));
  final day = DateTime.utc(today.year, today.month, today.day);
  final dayOfYear = day.difference(DateTime.utc(today.year)).inDays + 1;
  final count = sorted.length < _exploreCount ? sorted.length : _exploreCount;
  final start = dayOfYear % sorted.length;

  return [for (var i = 0; i < count; i++) sorted[(start + i) % sorted.length]];
}

IconData _iconForCategory(String category) {
  return switch (category.toLowerCase()) {
    'protocol' => Icons.account_tree_outlined,
    'cryptography' => Icons.key_outlined,
    'lightning network' => Icons.bolt_outlined,
    'economics' => Icons.trending_up_rounded,
    _ => Icons.menu_book_outlined,
  };
}

IconData _iconForEntry(WikiEntry entry) {
  return switch (entry.slug) {
    'proof-of-work' => Icons.memory,
    'segregated-witness' => Icons.call_split,
    'taproot' => Icons.account_tree,
    'difficulty-adjustment' => Icons.tune,
    _ => Icons.article_outlined,
  };
}

/// Puts [gap] between consecutive widgets.
List<Widget> _spaced(List<Widget> widgets, double gap) {
  return [
    for (var i = 0; i < widgets.length; i++) ...[
      if (i > 0) SizedBox(height: gap),
      widgets[i],
    ],
  ];
}
