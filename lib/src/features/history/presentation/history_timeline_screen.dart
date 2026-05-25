import 'package:flutter/material.dart';

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

class HistoryTimelineScreen extends StatelessWidget {
  const HistoryTimelineScreen({required this.store, super.key});

  final ContentStore store;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final onThisDay = store.bundle.history
        .where(
          (event) => event.date.month == now.month && event.date.day == now.day,
        )
        .toList(growable: false);
    final events = [...store.bundle.history]
      ..sort((a, b) => a.date.compareTo(b.date));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 24),
      children: [
        const ReaderHeader(
          title: 'History',
          subtitle: 'Milestones and context from Bitcoin time.',
          metadata: [
            MetadataItem(label: 'Timeline', icon: Icons.history_edu_outlined),
          ],
        ),
        const SizedBox(height: 24),
        _OnThisDayCard(event: onThisDay.firstOrNull),
        const SizedBox(height: 28),
        const _HistoryFilters(),
        const SizedBox(height: 28),
        const SectionTitle(title: 'Timeline'),
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
  const _HistoryFilters();

  @override
  Widget build(BuildContext context) {
    return FilterChipBar<String>(
      items: const ['All Events', 'Protocol', 'Economics', 'Community'],
      selectedItem: 'All Events',
      labelFor: (item) => item,
      onSelected: (_) {},
    );
  }
}

class _OnThisDayCard extends StatelessWidget {
  const _OnThisDayCard({required this.event});

  final HistoryEvent? event;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ContentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'On this day',
            style: textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(event?.title ?? 'No event today', style: textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            event?.summary ??
                'Historic events connected to the current date will be surfaced here.',
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
      return Scaffold(
        appBar: AppBar(title: const Text('History')),
        body: const Center(child: Text('History event not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: ListView(
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
    );
  }
}
