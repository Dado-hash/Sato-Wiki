import 'package:flutter/material.dart';

import '../../../core/widgets/content_card.dart';
import '../../../core/widgets/filter_chip_bar.dart';
import '../../../core/widgets/metadata_row.dart';
import '../../../core/widgets/reader_header.dart';
import '../../../core/widgets/section_title.dart';

class NewsFeedScreen extends StatelessWidget {
  const NewsFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 24),
      children: const [
        ReaderHeader(
          title: 'News',
          subtitle: 'Long-form Bitcoin analysis from the community.',
          metadata: [
            MetadataItem(label: 'Editorial', icon: Icons.newspaper_outlined),
          ],
        ),
        SizedBox(height: 24),
        _CategoryFilters(),
        SizedBox(height: 24),
        SectionTitle(title: 'Latest analysis'),
        SizedBox(height: 12),
        _ArticleCard(
          category: 'Protocol',
          title: 'The Activation of Taproot: A Retrospective',
          author: 'Andreas M.',
          readingTime: '12 min',
        ),
        SizedBox(height: 12),
        _ArticleCard(
          category: 'Development',
          title: 'How to read a technical discussion without getting lost',
          author: 'Maintainers',
          readingTime: '4 min',
        ),
      ],
    );
  }
}

class _CategoryFilters extends StatelessWidget {
  const _CategoryFilters();

  @override
  Widget build(BuildContext context) {
    return FilterChipBar<String>(
      items: const [
        'All',
        'Protocol',
        'Market',
        'Regulatory',
        'Culture',
        'Development',
      ],
      selectedItem: 'All',
      labelFor: (item) => item,
      onSelected: (_) {},
    );
  }
}

class _ArticleCard extends StatelessWidget {
  const _ArticleCard({
    required this.category,
    required this.title,
    required this.author,
    required this.readingTime,
  });

  final String category;
  final String title;
  final String author;
  final String readingTime;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ContentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category,
            style: textTheme.labelLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          MetadataRow(
            items: [
              MetadataItem(label: author, icon: Icons.person_outline),
              MetadataItem(label: readingTime, icon: Icons.schedule_outlined),
            ],
          ),
        ],
      ),
    );
  }
}
