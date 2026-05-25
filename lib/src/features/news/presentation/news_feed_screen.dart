import 'package:flutter/material.dart';

import '../../../core/widgets/content_card.dart';
import '../../../core/widgets/section_title.dart';

class NewsFeedScreen extends StatelessWidget {
  const NewsFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 24),
      children: const [
        _NewsHeader(),
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

class _NewsHeader extends StatelessWidget {
  const _NewsHeader();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('News', style: textTheme.headlineLarge),
        const SizedBox(height: 8),
        Text(
          'Long-form Bitcoin analysis from the community.',
          style: textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _CategoryFilters extends StatelessWidget {
  const _CategoryFilters();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: const [
          _FilterChip(label: 'All', selected: true),
          _FilterChip(label: 'Protocol'),
          _FilterChip(label: 'Market'),
          _FilterChip(label: 'Regulatory'),
          _FilterChip(label: 'Culture'),
          _FilterChip(label: 'Development'),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {},
      ),
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
          Row(
            children: [
              const Icon(Icons.person_outline, size: 18),
              const SizedBox(width: 6),
              Text('$author · $readingTime'),
            ],
          ),
        ],
      ),
    );
  }
}
