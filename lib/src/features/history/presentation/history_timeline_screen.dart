import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
        for (int i = 0; i < events.length; i++)
          _TimelineEvent(
            event: events[i],
            isFirst: i == 0,
            isLast: i == events.length - 1,
            onTap: () {
              Navigator.of(
                context,
              ).pushNamed(AppRoutes.historyEvent(events[i].slug));
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
  const _TimelineEvent({
    required this.event,
    required this.onTap,
    required this.isFirst,
    required this.isLast,
  });

  final HistoryEvent event;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final color = colorScheme.primary;
    final lineColor = colorScheme.outlineVariant;
    final l10n = AppLocalizations.of(context);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 76,
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  DateFormat.yMMMd(l10n.localeName).format(event.date),
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: isFirst
                        ? const SizedBox()
                        : Container(width: 2, color: lineColor),
                  ),
                ),
                SizedBox(
                  height: 14,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Center(child: Container(width: 2, color: lineColor)),
                      Row(
                        children: [
                          const SizedBox(width: 13),
                          Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Container(height: 2, color: lineColor),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: isLast
                        ? const SizedBox()
                        : Container(width: 2, color: lineColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
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
