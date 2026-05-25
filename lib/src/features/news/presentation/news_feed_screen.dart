import 'package:flutter/material.dart';

import '../../../generated/l10n/app_localizations.dart';
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

class NewsFeedScreen extends StatefulWidget {
  const NewsFeedScreen({required this.store, super.key});

  final ContentStore store;

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  String? _selectedCategory;

  List<NewsArticle> get _articles {
    if (_selectedCategory == null) return widget.store.bundle.news;
    return widget.store.bundle.news
        .where((a) => a.category == _selectedCategory)
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final articles = _articles;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 24),
      children: [
        ReaderHeader(
          title: l10n.newsTitle,
          subtitle: l10n.newsSubtitle,
          metadata: [
            MetadataItem(label: l10n.editorial, icon: Icons.newspaper_outlined),
          ],
        ),
        const SizedBox(height: 24),
        _CategoryFilters(
          selected: _selectedCategory,
          onSelected: (category) =>
              setState(() => _selectedCategory = category),
        ),
        const SizedBox(height: 24),
        SectionTitle(title: l10n.latestAnalysis),
        const SizedBox(height: 12),
        for (final article in articles) ...[
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
      final l10n = AppLocalizations.of(context);
      return Scaffold(
        appBar: AppBar(title: Text(l10n.newsTitle)),
        body: Center(child: Text(l10n.articleNotFound)),
      );
    }
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.newsTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ReaderHeader(
              title: article.title,
              subtitle: article.summary,
              metadata: [
                ...tagMetadata(article.tags),
                MetadataItem(
                  label: l10n.minRead(article.readTimeMinutes),
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
                    l10n.lightningTip,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.lightningTipDescription,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(l10n.lightningTipMockTitle),
                          content: Text(
                            article.author.lightningAddress ??
                                l10n.noLightningAddress,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(l10n.close),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.payments_outlined),
                    label: Text(l10n.sendTip),
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
    final l10n = AppLocalizations.of(context);

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
                label: l10n.shortMin(article.readTimeMinutes),
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
  const _CategoryFilters({required this.selected, required this.onSelected});

  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return FilterChipBar<String?>(
      items: const [
        null,
        'protocol',
        'market',
        'regulatory',
        'culture',
        'development',
      ],
      selectedItem: selected,
      labelFor: (item) => switch (item) {
        null => l10n.all,
        'protocol' => l10n.categoryProtocol,
        'market' => l10n.market,
        'regulatory' => l10n.regulatory,
        'culture' => l10n.culture,
        'development' => l10n.development,
        _ => item,
      },
      onSelected: onSelected,
    );
  }
}
