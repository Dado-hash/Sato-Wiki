import 'package:flutter/material.dart';

import '../../../core/content/domain/content_models.dart';
import '../../../core/content/domain/content_store.dart';
import '../../../core/content/reading_level.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/widgets/content_card.dart';
import '../../../core/widgets/content_mappers.dart';
import '../../../core/widgets/hero_media.dart';
import '../../../core/widgets/metadata_row.dart';
import '../../../core/widgets/reader_header.dart';
import '../../../core/widgets/reading_level_selector.dart';
import '../../../core/widgets/related_links_grid.dart';
import '../../../core/widgets/section_title.dart';
import '../../../core/widgets/sources_disclosure.dart';

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
    final entries = store.bundle.wiki;
    final featured = entries.first;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 24),
      children: [
        ReaderHeader(
          title: 'The Orange Book',
          subtitle: 'A technical encyclopedia for Bitcoin readers.',
          metadata: [
            ...tagMetadata(featured.tags.take(2).toList(growable: false)),
            MetadataItem(
              label: '${featured.readTimeMinutes} min read',
              icon: Icons.schedule_outlined,
            ),
          ],
        ),
        const SizedBox(height: 24),
        const SectionTitle(title: 'Knowledge Base'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final category in _categories(entries))
              _CategoryChip(
                icon: Icons.account_tree_outlined,
                label: category,
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pushNamed(AppRoutes.wikiCategory(category));
                },
              ),
          ],
        ),
        const SizedBox(height: 28),
        const SectionTitle(title: 'Featured concept'),
        const SizedBox(height: 12),
        const HeroMedia(
          icon: Icons.memory,
          label: 'Proof of Work conceptual visual',
        ),
        const SizedBox(height: 12),
        _WikiEntryCard(
          entry: featured,
          selectedLevel: selectedLevel,
          onLevelChanged: onLevelChanged,
          onTap: () {
            Navigator.of(context).pushNamed(AppRoutes.wikiEntry(featured.slug));
          },
        ),
        const SizedBox(height: 28),
        const SectionTitle(title: 'Related Concepts'),
        const SizedBox(height: 12),
        RelatedLinksGrid(links: relatedLinks(featured.related)),
        const SizedBox(height: 28),
        SourcesDisclosure(sources: sourceReferences(featured.sources)),
        const SizedBox(height: 28),
        ContentCard(
          child: Row(
            children: [
              Icon(
                Icons.volunteer_activism_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Content is versioned in Markdown and reviewed through GitHub pull requests.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<String> _categories(List<WikiEntry> entries) {
    return entries.map((entry) => entry.category).toSet().toList()
      ..sort((a, b) => a.compareTo(b));
  }
}

class _WikiEntryCard extends StatelessWidget {
  const _WikiEntryCard({
    required this.entry,
    required this.selectedLevel,
    required this.onLevelChanged,
    this.onTap,
  });

  final WikiEntry entry;
  final ReadingLevel selectedLevel;
  final ValueChanged<ReadingLevel> onLevelChanged;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ContentCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.title,
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            entry.contentFor(selectedLevel).bodyMarkdown,
            style: textTheme.bodyLarge,
          ),
          const SizedBox(height: 18),
          ReadingLevelSelector(
            selectedLevel: selectedLevel,
            onLevelChanged: onLevelChanged,
          ),
          const SizedBox(height: 18),
          MetadataRow(items: tagMetadata(entry.tags)),
        ],
      ),
    );
  }
}

class WikiCategoryScreen extends StatelessWidget {
  const WikiCategoryScreen({
    required this.store,
    required this.category,
    super.key,
  });

  final ContentStore store;
  final String category;

  @override
  Widget build(BuildContext context) {
    final entries = store.bundle.wiki
        .where((entry) => entry.category == category)
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(title: Text(category)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ReaderHeader(
            title: category,
            subtitle: 'Wiki entries in this category.',
          ),
          const SizedBox(height: 16),
          for (final entry in entries) ...[
            ContentCard(
              onTap: () {
                Navigator.of(
                  context,
                ).pushNamed(AppRoutes.wikiEntry(entry.slug));
              },
              trailing: const Icon(Icons.chevron_right),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(entry.description),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

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
      return Scaffold(
        appBar: AppBar(title: const Text('Wiki')),
        body: const Center(child: Text('Wiki entry not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Wiki')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ReaderHeader(
            title: entry.title,
            subtitle: entry.description,
            metadata: [
              ...tagMetadata(entry.tags),
              MetadataItem(
                label: '${entry.readTimeMinutes} min read',
                icon: Icons.schedule_outlined,
              ),
            ],
          ),
          const SizedBox(height: 18),
          ReadingLevelSelector(
            selectedLevel: selectedLevel,
            onLevelChanged: onLevelChanged,
          ),
          const SizedBox(height: 18),
          const HeroMedia(icon: Icons.memory, label: 'Proof of Work'),
          const SizedBox(height: 18),
          ContentCard(
            child: Text(
              entry.contentFor(selectedLevel).bodyMarkdown,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          const SizedBox(height: 24),
          const SectionTitle(title: 'Related Concepts'),
          const SizedBox(height: 12),
          RelatedLinksGrid(links: relatedLinks(entry.related)),
          const SizedBox(height: 24),
          SourcesDisclosure(sources: sourceReferences(entry.sources)),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onPressed,
    );
  }
}
