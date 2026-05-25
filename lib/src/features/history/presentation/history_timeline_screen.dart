import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/content_card.dart';
import '../../../core/widgets/filter_chip_bar.dart';
import '../../../core/widgets/metadata_row.dart';
import '../../../core/widgets/reader_header.dart';
import '../../../core/widgets/section_title.dart';

class HistoryTimelineScreen extends StatelessWidget {
  const HistoryTimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 24),
      children: const [
        ReaderHeader(
          title: 'History',
          subtitle: 'Milestones and context from Bitcoin time.',
          metadata: [
            MetadataItem(label: 'Timeline', icon: Icons.history_edu_outlined),
          ],
        ),
        SizedBox(height: 24),
        _OnThisDayCard(),
        SizedBox(height: 28),
        _HistoryFilters(),
        SizedBox(height: 28),
        SectionTitle(title: 'Timeline'),
        SizedBox(height: 12),
        _TimelineEvent(
          year: '2009',
          title: 'Genesis Block',
          category: 'Protocol',
          color: AppColors.bitcoinOrange,
        ),
        _TimelineEvent(
          year: '2012',
          title: 'First Halving',
          category: 'Economics',
          color: AppColors.warning,
        ),
        _TimelineEvent(
          year: '2014',
          title: 'Mt. Gox Hack',
          category: 'Community',
          color: AppColors.success,
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
  const _OnThisDayCard();

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
          Text('Bitcoin Pizza Day', style: textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            'Historic events connected to the current date will be surfaced here.',
            style: textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _TimelineEvent extends StatelessWidget {
  const _TimelineEvent({
    required this.year,
    required this.title,
    required this.category,
    required this.color,
  });

  final String year;
  final String title;
  final String category;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 56,
            child: Text(
              year,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    style: textTheme.labelMedium?.copyWith(color: color),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'A short sourced description will be loaded from the offline content bundle.',
                    style: textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
