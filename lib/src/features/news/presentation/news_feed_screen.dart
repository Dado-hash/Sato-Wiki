import 'package:flutter/material.dart';

import '../../../core/content/domain/content_models.dart';
import '../../../core/content/domain/content_store.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/widgets/content_card.dart';
import '../../../core/widgets/content_mappers.dart';
import '../../../core/widgets/filter_chip_bar.dart';
import '../../../core/widgets/markdown_text.dart';
import '../../../core/widgets/metadata_row.dart';
import '../../../core/widgets/reader_header.dart';
import '../../../core/widgets/related_links_grid.dart';
import '../../../core/widgets/section_title.dart';
import '../../../core/widgets/sources_disclosure.dart';

class NewsFeedScreen extends StatelessWidget {
  const NewsFeedScreen({required this.store, super.key});

  final ContentStore store;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 24),
      children: [
        const ReaderHeader(
          title: 'News',
          subtitle: 'Long-form Bitcoin analysis from the community.',
          metadata: [
            MetadataItem(label: 'Editorial', icon: Icons.newspaper_outlined),
          ],
        ),
        SizedBox(height: 24),
        const _CategoryFilters(),
        const SizedBox(height: 24),
        const SectionTitle(title: 'Latest analysis'),
        const SizedBox(height: 12),
        for (final article in store.bundle.news) ...[
          _ArticleCard(
            article: article,
            onTap: () {
              Navigator.of(
                context,
              ).pushNamed(AppRoutes.newsArticle(article.slug));
            },
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class NewsArticleScreen extends StatelessWidget {
  const NewsArticleScreen({required this.store, required this.slug, super.key});

  final ContentStore store;
  final String slug;

  @override
  Widget build(BuildContext context) {
    final article = store.bundle.news
        .where((article) => article.slug == slug || article.id == slug)
        .firstOrNull;

    if (article == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('News')),
        body: const Center(child: Text('Article not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('News')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ReaderHeader(
            title: article.title,
            subtitle: article.summary,
            metadata: [
              ...tagMetadata(article.tags),
              MetadataItem(
                label: '${article.readTimeMinutes} min read',
                icon: Icons.schedule_outlined,
              ),
            ],
          ),
          const SizedBox(height: 18),
          MetadataRow(
            items: [
              MetadataItem(
                label: article.author.displayName,
                icon: Icons.person_outline,
              ),
              MetadataItem(
                label: article.publishedAt.toIso8601String().split('T').first,
                icon: Icons.calendar_today_outlined,
              ),
            ],
          ),
          const SizedBox(height: 24),
          MarkdownText(article.bodyMarkdown),
          const SizedBox(height: 24),
          ContentCard(
            child: Column(
              children: [
                Icon(
                  Icons.bolt,
                  color: Theme.of(context).colorScheme.primary,
                  size: 36,
                ),
                const SizedBox(height: 8),
                Text(
                  'Lightning Tip',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Mock only. Payment wiring waits for privacy and UX definition.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Lightning Tip mock'),
                        content: Text(
                          article.author.lightningAddress ??
                              'No Lightning address configured.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.payments_outlined),
                  label: const Text('Send Tip'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          RelatedLinksGrid(links: relatedLinks(article.related)),
          const SizedBox(height: 24),
          SourcesDisclosure(sources: sourceReferences(article.sources)),
        ],
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  const _ArticleCard({required this.article, required this.onTap});

  final NewsArticle article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ContentCard(
      onTap: onTap,
      trailing: const Icon(Icons.chevron_right),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            article.category,
            style: textTheme.labelLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            article.title,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          MetadataRow(
            items: [
              MetadataItem(
                label: article.author.displayName,
                icon: Icons.person_outline,
              ),
              MetadataItem(
                label: '${article.readTimeMinutes} min',
                icon: Icons.schedule_outlined,
              ),
            ],
          ),
        ],
      ),
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
