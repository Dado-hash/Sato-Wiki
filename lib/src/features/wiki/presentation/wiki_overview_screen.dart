import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../../generated/l10n/app_localizations.dart';
import '../../../core/content/domain/content_media.dart';
import '../../../core/content/domain/content_models.dart';
import '../../../core/content/domain/content_store.dart';
import '../../../core/content/reading_level.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/widgets/content_mappers.dart';
import '../../../core/widgets/content_media_scope.dart';
import '../../../core/widgets/hero_media.dart';
import '../../../core/widgets/markdown_text.dart';
import '../../../core/widgets/reading_level_selector.dart';
import '../../../core/widgets/related_links_grid.dart';
import '../../../core/widgets/section_title.dart';
import '../../../core/widgets/sources_disclosure.dart';

//
// ─── MAIN PAGE: MACRO CATEGORY BENTO GRID ────────────────────────────────────
//

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
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final categories = _deriveCategories(store, l10n);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 24),
      children: [
        Text(
          l10n.orangeBookTitle,
          style: textTheme.displayLarge?.copyWith(fontSize: 42, height: 1.08),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.wikiOverviewSubtitle,
          style: textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 32),
        SectionTitle(title: l10n.knowledgeBase),
        const SizedBox(height: 16),
        for (final cat in categories)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _CategoryCard(
              icon: cat.icon,
              title: cat.title,
              description: cat.description,
              tags: cat.tags,
              onTap: () => Navigator.of(
                context,
              ).pushNamed(AppRoutes.wikiCategory(cat.routeCategory)),
            ),
          ),
      ],
    );
  }

  List<_CategoryMeta> _deriveCategories(
    ContentStore store,
    AppLocalizations l10n,
  ) {
    final curated = <_CategoryMeta>[
      _categoryMetaFor('Protocol', l10n),
      _categoryMetaFor('Cryptography', l10n),
      _categoryMetaFor('Lightning Network', l10n),
      _categoryMetaFor('Economics', l10n),
    ];
    final seen = <String>{
      'protocol',
      'cryptography',
      'lightning network',
      'economics',
    };
    for (final entry in store.bundle.wiki) {
      final key = entry.category.toLowerCase();
      if (seen.add(key)) {
        curated.add(_categoryMetaFor(entry.category, l10n));
      }
    }
    curated.sort((a, b) => a.title.compareTo(b.title));
    return curated;
  }
}

final class _CategoryMeta {
  const _CategoryMeta({
    required this.icon,
    required this.routeCategory,
    required this.title,
    required this.description,
    required this.tags,
  });

  final IconData icon;
  final String routeCategory;
  final String title;
  final String description;
  final List<String> tags;
}

_CategoryMeta _categoryMetaFor(String category, AppLocalizations l10n) {
  final key = category.toLowerCase();
  // Curated mapping — extend as new categories are added to the content.
  switch (key) {
    case 'protocol':
      return _CategoryMeta(
        icon: Icons.code,
        routeCategory: 'Protocol',
        title: l10n.categoryProtocol,
        description: l10n.categoryProtocolDescription,
        tags: [l10n.categoryBips, l10n.categoryConsensus],
      );
    case 'cryptography':
      return _CategoryMeta(
        icon: Icons.vpn_key,
        routeCategory: 'Cryptography',
        title: l10n.categoryCryptography,
        description: l10n.categoryCryptographyDescription,
        tags: [l10n.categorySecp256k1, l10n.categorySha256],
      );
    case 'lightning network':
      return _CategoryMeta(
        icon: Icons.bolt,
        routeCategory: 'Lightning Network',
        title: l10n.categoryLightningNetwork,
        description: l10n.categoryLightningNetworkDescription,
        tags: [l10n.categoryBolts, l10n.categoryChannels],
      );
    case 'economics':
      return _CategoryMeta(
        icon: Icons.trending_up,
        routeCategory: 'Economics',
        title: l10n.categoryEconomics,
        description: l10n.categoryEconomicsDescription,
        tags: [l10n.categoryHalving, l10n.categoryDifficulty],
      );
    default:
      return _CategoryMeta(
        icon: Icons.menu_book,
        routeCategory: category,
        title: category,
        description: l10n.wikiEntriesInCategory(category),
        tags: const [],
      );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.tags,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final List<String> tags;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(icon, color: colorScheme.primary, size: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final tag in tags)
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Text(
                          tag,
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurface,
                            fontFamily: 'JetBrains Mono',
                          ),
                        ),
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

//
// ─── CATEGORY LIST: ENTRIES WITH FILTER CHIPS ─────────────────────────────────
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

  List<String> get _tags {
    final entries = _allEntries;
    final tags = <String>{};
    for (final entry in entries) {
      tags.addAll(entry.tags);
    }
    final sorted = tags.toList()..sort();
    return sorted;
  }

  List<WikiEntry> get _allEntries {
    return widget.store.bundle.wiki
        .where(
          (entry) =>
              entry.category.toLowerCase() == widget.category.toLowerCase(),
        )
        .toList(growable: false);
  }

  List<WikiEntry> get _filteredEntries {
    if (_selectedTag == null) return _allEntries;
    return _allEntries
        .where((entry) => entry.tags.contains(_selectedTag))
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final entries = _filteredEntries;
    final tags = [l10n.all, ..._tags];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.category),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Text(
                _subtitleFor(widget.category, l10n),
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            if (tags.length > 1)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final tag in tags)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _FilterChip(
                            label: tag,
                            selected:
                                _selectedTag == null && tag == l10n.all ||
                                tag == _selectedTag,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedTag = tag == l10n.all ? null : tag;
                                });
                              }
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            for (final entry in entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _CategoryEntryCard(
                  entry: entry,
                  highlighted: entry == entries.first,
                  onTap: () => Navigator.of(
                    context,
                  ).pushNamed(AppRoutes.wikiEntry(entry.slug)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _subtitleFor(String category, AppLocalizations l10n) {
    return switch (category) {
      'Protocol' => l10n.categoryProtocolDescription,
      'Cryptography' => l10n.categoryCryptographyDescription,
      'Lightning Network' => l10n.categoryLightningNetworkDescription,
      'Economics' => l10n.categoryEconomicsDescription,
      _ => l10n.wikiEntriesInThisCategory,
    };
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FilterChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      onSelected: onSelected,
      selectedColor: colorScheme.primaryContainer,
      checkmarkColor: colorScheme.onPrimaryContainer,
      labelStyle: TextStyle(
        color: selected
            ? colorScheme.onPrimaryContainer
            : colorScheme.onSurfaceVariant,
      ),
      side: BorderSide(
        color: selected ? colorScheme.primary : colorScheme.outlineVariant,
      ),
    );
  }
}

class _DifficultyIndicator extends StatelessWidget {
  const _DifficultyIndicator({required this.level});

  final ReadingLevel level;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final filledCount = switch (level) {
      ReadingLevel.base => 1,
      ReadingLevel.medium => 2,
      ReadingLevel.advanced => 3,
    };
    final activeColor = switch (level) {
      ReadingLevel.base => colorScheme.tertiaryContainer,
      ReadingLevel.medium => colorScheme.primaryContainer,
      ReadingLevel.advanced => colorScheme.error,
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 3; i++)
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(left: 3),
            decoration: BoxDecoration(
              color: i < filledCount
                  ? activeColor
                  : activeColor.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }
}

class _CategoryEntryCard extends StatelessWidget {
  const _CategoryEntryCard({
    required this.entry,
    required this.highlighted,
    required this.onTap,
  });

  final WikiEntry entry;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final resolver =
        ContentMediaScope.maybeOf(context) ?? ContentMediaResolver.empty;

    Widget? backgroundImage;
    if (entry.coverImage != null) {
      final resolvedUri = resolver.resolve(entry.coverImage.toString());
      if (resolvedUri != null && resolvedUri.scheme == 'file') {
        final file = File.fromUri(resolvedUri);
        final ext = ContentMedia.extensionFor(file.path);
        backgroundImage = ext == '.svg'
            ? SvgPicture.file(file, fit: BoxFit.cover)
            : Image.file(file, fit: BoxFit.cover);
      }
    }

    return Material(
      color: highlighted
          ? colorScheme.surfaceContainerHigh
          : colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          child: Stack(
            children: [
              if (backgroundImage != null)
                Positioned.fill(
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                    child: backgroundImage,
                  ),
                ),
              if (backgroundImage != null)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          colorScheme.surface.withValues(alpha: 0.92),
                        ],
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Stack(
                  children: [
                    if (highlighted)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(8),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            child: Text(
                              l10n.coreConcept,
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.05,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.title,
                          style: textTheme.titleLarge?.copyWith(
                            color: highlighted
                                ? colorScheme.primary
                                : colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          entry.description,
                          style: textTheme.bodyMedium?.copyWith(
                            color: highlighted
                                ? colorScheme.onSurface
                                : colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _MetaLabel(
                              icon: Icons.schedule_outlined,
                              label: l10n.minRead(entry.readTimeMinutes),
                            ),
                            const SizedBox(width: 16),
                            _MetaLabel(
                              icon: Icons.update,
                              label: _formatDate(entry.updatedAt, l10n),
                            ),
                            const Spacer(),
                            _DifficultyIndicator(level: entry.difficulty),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (backgroundImage != null)
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: highlighted
                              ? colorScheme.primary
                              : colorScheme.outlineVariant,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date, AppLocalizations l10n) {
    return DateFormat.yMMM(l10n.localeName).format(date);
  }
}

class _MetaLabel extends StatelessWidget {
  const _MetaLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontFamily: 'JetBrains Mono',
          ),
        ),
      ],
    );
  }
}

//
// ─── ENTRY DETAIL: FULL ARTICLE ───────────────────────────────────────────────
//

class WikiEntryScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final entry = store.bundle.wiki
        .where((entry) => entry.slug == slug || entry.id == slug)
        .firstOrNull;

    if (entry == null) {
      final l10n = AppLocalizations.of(context);
      return Scaffold(
        appBar: AppBar(title: Text(l10n.wikiTab)),
        body: Center(child: Text(l10n.wikiEntryNotFound)),
      );
    }

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(l10n.wikiTab),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            Text(
              entry.title,
              style: textTheme.displayLarge?.copyWith(
                fontSize: 42,
                height: 1.08,
              ),
            ),
            const SizedBox(height: 20),
            ReadingLevelSelector(
              selectedLevel: selectedLevel,
              onLevelChanged: onLevelChanged,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tag in entry.tags)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      child: Text(
                        '#$tag',
                        style: textTheme.labelMedium?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.schedule_outlined,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.minRead(entry.readTimeMinutes),
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontFamily: 'JetBrains Mono',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (entry.coverImage != null)
              ContentImageFigure(
                source: entry.coverImage.toString(),
                alt: entry.title,
                aspectRatio: 16 / 9,
                showCaption: false,
                padding: EdgeInsets.zero,
              )
            else
              HeroMedia(
                icon: _iconForEntry(entry),
                label: l10n.entryConceptualVisual(entry.title),
              ),
            const SizedBox(height: 24),
            MarkdownText(entry.contentFor(selectedLevel).bodyMarkdown),
            if (entry.related.isNotEmpty) ...[
              const SizedBox(height: 32),
              SectionTitle(title: l10n.relatedConcepts),
              const SizedBox(height: 12),
              RelatedLinksGrid(links: relatedLinks(entry.related)),
            ],
            if (entry.sources.isNotEmpty) ...[
              const SizedBox(height: 24),
              SourcesDisclosure(sources: sourceReferences(entry.sources)),
            ],
          ],
        ),
      ),
    );
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
}
