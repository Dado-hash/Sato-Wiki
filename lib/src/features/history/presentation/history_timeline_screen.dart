import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/content/domain/content_models.dart';
import '../../../core/content/domain/content_store.dart';
import '../../../core/localization/content_labels.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/bookmark_button.dart';
import '../../../core/widgets/content_mappers.dart';
import '../../../core/widgets/content_thumbnail.dart';
import '../../../core/widgets/detail_scaffold.dart';
import '../../../core/widgets/filter_chip_bar.dart';
import '../../../core/widgets/markdown_text.dart';
import '../../../core/widgets/meta_line.dart';
import '../../../core/widgets/related_links_grid.dart';
import '../../../core/widgets/round_icon_button.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/section_title.dart';
import '../../../core/widgets/sources_disclosure.dart';
import '../../../core/widgets/tag_pill.dart';
import '../../../generated/l10n/app_localizations.dart';

class HistoryTimelineScreen extends StatefulWidget {
  const HistoryTimelineScreen({required this.store, this.now, super.key});

  final ContentStore store;

  /// Reference date for "On this day". Defaults to the current time.
  final DateTime? now;

  @override
  State<HistoryTimelineScreen> createState() => _HistoryTimelineScreenState();
}

class _HistoryTimelineScreenState extends State<HistoryTimelineScreen> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final now = widget.now ?? DateTime.now();
    final allEvents = [...widget.store.bundle.history]
      ..sort((a, b) => a.date.compareTo(b.date));
    final categories = allEvents.map((event) => event.category).toSet().toList()
      ..sort();
    final onThisDay = allEvents
        .where((e) => e.date.month == now.month && e.date.day == now.day)
        .toList(growable: false);
    final events = _selectedCategory == null
        ? allEvents
        : allEvents
              .where((e) => e.category == _selectedCategory)
              .toList(growable: false);
    final entries = _timelineEntries(events);

    final subtitle = allEvents.isEmpty
        ? l10n.historySubtitle
        : l10n.eventsFromTo(
            allEvents.length,
            allEvents.first.date.year,
            allEvents.last.date.year,
          );

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: ScreenHeader(
            title: l10n.historyTitle,
            subtitle: subtitle,
            actions: [
              RoundIconButton(
                icon: Icons.search_rounded,
                tooltip: l10n.searchTooltip,
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.search),
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.gutter,
              left: AppSpacing.gutter,
            ),
            child: FilterChipBar<String?>(
              items: [null, ...categories],
              selectedItem: _selectedCategory,
              labelFor: (category) => category == null
                  ? l10n.allEvents
                  : contentCategoryLabel(category, l10n),
              onSelected: (category) =>
                  setState(() => _selectedCategory = category),
            ),
          ),
        ),
        if (onThisDay.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                AppSpacing.xl,
                AppSpacing.gutter,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionTitle(title: l10n.onThisDayTitle),
                  const SizedBox(height: AppSpacing.md),
                  for (var i = 0; i < onThisDay.length; i++) ...[
                    if (i > 0) const SizedBox(height: AppSpacing.md),
                    _HistoryEventCard(event: onThisDay[i], showYear: true),
                  ],
                ],
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
        if (entries.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.gutter,
                vertical: 32,
              ),
              child: Text(
                l10n.noLocalResultFound,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
            sliver: SliverList.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                return switch (entries[index]) {
                  _YearEntry(:final year) => _YearHeader(
                    year: year,
                    isFirst: index == 0,
                  ),
                  _EventEntry(:final event) => _TimelineEventItem(event: event),
                };
              },
            ),
          ),
        const SliverPadding(
          padding: EdgeInsets.only(bottom: AppSpacing.tabBarClearance),
          sliver: SliverToBoxAdapter(child: SizedBox.shrink()),
        ),
      ],
    );
  }
}

sealed class _TimelineEntry {
  const _TimelineEntry();
}

final class _YearEntry extends _TimelineEntry {
  const _YearEntry(this.year);

  final int year;
}

final class _EventEntry extends _TimelineEntry {
  const _EventEntry(this.event);

  final HistoryEvent event;
}

/// Flattens date-sorted events into year headers followed by their events.
List<_TimelineEntry> _timelineEntries(List<HistoryEvent> events) {
  final entries = <_TimelineEntry>[];
  int? currentYear;
  for (final event in events) {
    if (event.date.year != currentYear) {
      currentYear = event.date.year;
      entries.add(_YearEntry(currentYear));
    }
    entries.add(_EventEntry(event));
  }
  return entries;
}

class _YearHeader extends StatelessWidget {
  const _YearHeader({required this.year, required this.isFirst});

  final int year;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      fontSize: 13,
      letterSpacing: 1.5,
      color: colorScheme.primary,
    );

    return Padding(
      padding: EdgeInsets.only(
        top: isFirst ? 0 : AppSpacing.xl,
        bottom: AppSpacing.md,
      ),
      child: Row(
        children: [
          Semantics(header: true, child: Text('$year', style: labelStyle)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Container(height: 1, color: colorScheme.outlineVariant),
          ),
        ],
      ),
    );
  }
}

class _TimelineEventItem extends StatelessWidget {
  const _TimelineEventItem({required this.event});

  final HistoryEvent event;

  @override
  Widget build(BuildContext context) {
    final lineColor = Theme.of(context).colorScheme.outlineVariant;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 12,
            child: Center(
              child: SizedBox(
                width: 2,
                height: double.infinity,
                child: ColoredBox(color: lineColor),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _HistoryEventCard(event: event),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryEventCard extends StatelessWidget {
  const _HistoryEventCard({required this.event, this.showYear = false});

  final HistoryEvent event;
  final bool showYear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final imageSource = firstMarkdownImageSource(event.bodyMarkdown);
    final date = DateFormat.MMMd(l10n.localeName).format(event.date);
    final category = contentCategoryLabel(event.category, l10n);

    return Material(
      color: colorScheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: () =>
            Navigator.of(context).pushNamed(AppRoutes.historyEvent(event.slug)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageSource != null)
              ContentThumbnail(
                source: imageSource,
                height: 132,
                width: double.infinity,
                borderRadius: 0,
                fallbackIcon: Icons.image_outlined,
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (showYear) ...[
                        Text(
                          '${event.date.year}',
                          style: textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        const ExcludeSemantics(child: Text('·')),
                        const SizedBox(width: AppSpacing.sm),
                      ],
                      Text(
                        date.toUpperCase(),
                        style: textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      const ExcludeSemantics(child: Text('·')),
                      const SizedBox(width: AppSpacing.sm),
                      Flexible(
                        child: Text(
                          category.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    event.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    event.summary,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
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

class HistoryEventScreen extends StatelessWidget {
  const HistoryEventScreen({
    required this.store,
    required this.slug,
    super.key,
  });

  final ContentStore store;
  final String slug;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final event = store.bundle.history
        .where((event) => event.slug == slug || event.id == slug)
        .firstOrNull;

    if (event == null) {
      return DetailScaffold(
        title: l10n.historyEventNotFound,
        children: const [],
      );
    }

    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return DetailScaffold(
      actions: [BookmarkButton(contentId: event.id)],
      children: [
        MetaLine(
          label: contentCategoryLabel(event.category, l10n),
          parts: [DateFormat.yMMMMd(l10n.localeName).format(event.date)],
        ),
        const SizedBox(height: 10),
        Semantics(
          header: true,
          child: Text(event.title, style: textTheme.headlineLarge),
        ),
        const SizedBox(height: 10),
        Text(
          event.summary,
          style: textTheme.bodyLarge?.copyWith(
            height: 26 / 17,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        MarkdownText(event.bodyMarkdown, store: store),
        if (event.tags.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.gutter),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [for (final tag in event.tags) TagPill(label: tag)],
          ),
        ],
        if (event.related.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.section),
          SectionTitle(title: l10n.relatedConcepts),
          const SizedBox(height: AppSpacing.md),
          RelatedLinksGrid(
            links: relatedLinks(
              event.related,
              store: store,
              onOpen: (route) => Navigator.of(context).pushNamed(route),
            ),
          ),
        ],
        if (event.sources.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          SourcesDisclosure(sources: sourceReferences(event.sources)),
        ],
      ],
    );
  }
}
