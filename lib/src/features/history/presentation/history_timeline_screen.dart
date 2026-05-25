import 'package:flutter/material.dart';

import '../../../generated/l10n/app_localizations.dart';
import '../../../core/content/domain/content_models.dart';
import '../../../core/content/domain/content_store.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/widgets/content_card.dart';
import '../../../core/widgets/filter_chip_bar.dart';
import '../../../core/widgets/markdown_text.dart';
import '../../../core/widgets/metadata_row.dart';
import '../../../core/widgets/reader_header.dart';
import '../../../core/widgets/related_links_grid.dart';
import '../../../core/widgets/section_title.dart';
import '../../../core/widgets/content_mappers.dart';
import '../../../core/widgets/sources_disclosure.dart';

class HistoryTimelineScreen extends StatefulWidget {
  const HistoryTimelineScreen({required this.store, super.key});

  final ContentStore store;

  @override
  State<HistoryTimelineScreen> createState() => _HistoryTimelineScreenState();
}

class _HistoryTimelineScreenState extends State<HistoryTimelineScreen> {
  String? _selectedCategory;

  List<HistoryEvent> get _events {
    final sorted = [...widget.store.bundle.history]
      ..sort((a, b) => a.date.compareTo(b.date));
    if (_selectedCategory == null) return sorted;
    return sorted
        .where((e) => e.category == _selectedCategory)
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final onThisDay = widget.store.bundle.history
        .where(
          (event) => event.date.month == now.month && event.date.day == now.day,
        )
        .toList(growable: false);
    final events = _events;
    final l10n = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 24),
      children: [
        ReaderHeader(
          title: l10n.historyTitle,
          subtitle: l10n.historySubtitle,
          metadata: [
            MetadataItem(
              label: l10n.timelineMetadata,
              icon: Icons.history_edu_outlined,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _OnThisDayCard(event: onThisDay.firstOrNull),
        const SizedBox(height: 28),
        _HistoryFilters(
          selected: _selectedCategory,
          onSelected: (category) =>
              setState(() => _selectedCategory = category),
        ),
        const SizedBox(height: 28),
        SectionTitle(title: l10n.timelineMetadata),
        const SizedBox(height: 12),
        for (final event in events)
          _TimelineEvent(
            event: event,
            onTap: () {
              Navigator.of(
                context,
              ).pushNamed(AppRoutes.historyEvent(event.slug));
            },
          ),
      ],
    );
  }
}

class _HistoryFilters extends StatelessWidget {
  const _HistoryFilters({required this.selected, required this.onSelected});

  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return FilterChipBar<String?>(
      items: const [null, 'protocol', 'economics', 'community'],
      selectedItem: selected,
      labelFor: (item) => switch (item) {
        null => l10n.allEvents,
        'protocol' => l10n.categoryProtocol,
        'economics' => l10n.categoryEconomics,
        'community' => l10n.community,
        _ => item,
      },
      onSelected: onSelected,
    );
  }
}

class _OnThisDayCard extends StatelessWidget {
  const _OnThisDayCard({required this.event});

  final HistoryEvent? event;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return ContentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.onThisDay,
            style: textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(event?.title ?? l10n.noEventToday, style: textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            event?.summary ?? l10n.noEventTodayDescription,
            style: textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _TimelineEvent extends StatelessWidget {
  const _TimelineEvent({required this.event, required this.onTap});

  final HistoryEvent event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 56,
            child: Text(
              '${event.date.year}',
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              Container(
                width: 2,
                height: 76,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: ContentCard(
              onTap: onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.category,
                    style: textTheme.labelMedium?.copyWith(color: color),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    event.title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(event.summary, style: textTheme.bodyMedium),
                ],
              ),
            ),
          ),
        ],
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
    final event = store.bundle.history
        .where((event) => event.slug == slug || event.id == slug)
        .firstOrNull;

    if (event == null) {
      final l10n = AppLocalizations.of(context);
      return Scaffold(
        appBar: AppBar(title: Text(l10n.historyTitle)),
        body: Center(child: Text(l10n.historyEventNotFound)),
      );
    }
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.historyTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ReaderHeader(
              title: event.title,
              subtitle: event.summary,
              metadata: [
                MetadataItem(
                  label: event.date.toIso8601String().split('T').first,
                  icon: Icons.calendar_today_outlined,
                ),
                ...tagMetadata(event.tags),
              ],
            ),
            const SizedBox(height: 24),
            MarkdownText(event.bodyMarkdown),
            const SizedBox(height: 24),
            RelatedLinksGrid(links: relatedLinks(event.related)),
            const SizedBox(height: 24),
            SourcesDisclosure(sources: sourceReferences(event.sources)),
          ],
        ),
      ),
    );
  }
}
