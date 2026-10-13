import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/content/domain/content_models.dart';
import '../../../core/content/domain/content_store.dart';
import '../../../core/localization/content_labels.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/settings/app_settings_scope.dart';
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
import '../../../core/widgets/sato_scaffold.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/section_title.dart';
import '../../../core/widgets/sources_disclosure.dart';
import '../../../core/widgets/tag_pill.dart';
import '../../../generated/l10n/app_localizations.dart';

class NewsFeedScreen extends StatefulWidget {
  const NewsFeedScreen({required this.store, super.key});

  final ContentStore store;

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  String? _selectedCategory;

  List<String> get _categories {
    final categories = widget.store.bundle.news
        .map((article) => article.category)
        .toSet()
        .toList(growable: false);

    return [...categories]..sort();
  }

  List<NewsArticle> get _articles {
    final sorted = [...widget.store.bundle.news]
      ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    if (_selectedCategory == null) return sorted;

    return sorted
        .where((article) => article.category == _selectedCategory)
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final categories = _categories;
    final articles = _articles;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: ScreenHeader(
            title: l10n.newsTitle,
            subtitle: l10n.newsSubtitle,
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
        if (categories.length > 1) ...[
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.gutter)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: AppSpacing.gutter),
              child: FilterChipBar<String?>(
                items: [null, ...categories],
                selectedItem: _selectedCategory,
                labelFor: (item) =>
                    item == null ? l10n.all : contentCategoryLabel(item, l10n),
                onSelected: (category) =>
                    setState(() => _selectedCategory = category),
              ),
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
        if (articles.isEmpty)
          SliverToBoxAdapter(
            child: _EmptyState(message: l10n.noLocalResultFound),
          )
        else
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              0,
              AppSpacing.gutter,
              SatoScaffold.bottomClearanceOf(context),
            ),
            sliver: SliverList.separated(
              itemCount: articles.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final article = articles[index];

                return _ArticleCard(
                  article: article,
                  onTap: () => Navigator.of(
                    context,
                  ).pushNamed(AppRoutes.newsArticle(article.slug)),
                );
              },
            ),
          ),
      ],
    );
  }
}

class NewsArticleScreen extends StatefulWidget {
  const NewsArticleScreen({required this.store, required this.slug, super.key});

  final ContentStore store;
  final String slug;

  @override
  State<NewsArticleScreen> createState() => _NewsArticleScreenState();
}

class _NewsArticleScreenState extends State<NewsArticleScreen> {
  final ScrollController _controller = ScrollController();
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Content that fits on screen counts as fully read.
      if (!mounted || !_controller.hasClients) return;
      if (_controller.position.maxScrollExtent <= 0) {
        _setProgress(1);
      }
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_controller.hasClients) return;
    final maxExtent = _controller.position.maxScrollExtent;
    if (maxExtent <= 0) return;

    final value = (_controller.offset / maxExtent).clamp(0.0, 1.0);
    _setProgress(value.toDouble());
  }

  void _setProgress(double value) {
    if (value != _progress) {
      setState(() => _progress = value);
    }
    final article = _articleFor(widget.store, widget.slug);
    if (article != null) {
      AppSettingsScope.maybeOf(context)?.setReadingProgress(article.id, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final article = _articleFor(widget.store, widget.slug);

    if (article == null) {
      return DetailScaffold(title: l10n.articleNotFound, children: const []);
    }

    final settings = AppSettingsScope.maybeOf(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final cover = article.coverImage;
    final textScale = settings?.readerTextScale ?? 1.0;

    return DetailScaffold(
      controller: _controller,
      progress: _progress,
      actions: [
        if (settings != null)
          RoundIconButton.child(
            tooltip: l10n.textSize,
            onPressed: () => settings.cycleReaderTextScale(),
            child: Text(
              'Aa',
              style: textTheme.titleSmall?.copyWith(
                fontFamily: AppFonts.display,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        BookmarkButton(contentId: article.id),
      ],
      children: [
        if (cover != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.media),
            child: ContentImageFigure(
              source: cover.toString(),
              alt: article.title,
              aspectRatio: 16 / 9,
              showCaption: false,
              padding: EdgeInsets.zero,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: AppSpacing.gutter),
        ],
        MetaLine(
          label: contentCategoryLabel(article.category, l10n),
          parts: [l10n.shortMin(article.readTimeMinutes)],
        ),
        const SizedBox(height: AppSpacing.sm + 2),
        Semantics(
          header: true,
          child: Text(article.title, style: textTheme.headlineLarge),
        ),
        const SizedBox(height: AppSpacing.sm + 2),
        Text(
          article.summary,
          style: textTheme.bodyLarge?.copyWith(
            height: 26 / 17,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          '${article.author.displayName} · '
          '${DateFormat.yMMMMd(l10n.localeName).format(article.publishedAt)}',
          style: textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.xl),
        MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.textScalerOf(context).scale(1) * textScale,
            ),
          ),
          child: MarkdownText(article.bodyMarkdown, store: widget.store),
        ),
        if (article.tags.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.gutter),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [for (final tag in article.tags) TagPill(label: tag)],
          ),
        ],
        if (article.related.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.section),
          SectionTitle(title: l10n.relatedConcepts),
          const SizedBox(height: AppSpacing.md),
          RelatedLinksGrid(
            links: relatedLinks(
              article.related,
              store: widget.store,
              onOpen: (route) => Navigator.of(context).pushNamed(route),
            ),
          ),
        ],
        if (article.sources.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          SourcesDisclosure(sources: sourceReferences(article.sources)),
        ],
      ],
    );
  }
}

NewsArticle? _articleFor(ContentStore store, String slug) {
  return store.bundle.news
      .where((article) => article.slug == slug || article.id == slug)
      .firstOrNull;
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
    final cover = article.coverImage;

    return Material(
      color: colorScheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (cover != null)
              ContentThumbnail(
                source: cover.toString(),
                aspectRatio: 16 / 9,
                borderRadius: 0,
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MetaLine(
                    label: contentCategoryLabel(article.category, l10n),
                    parts: [
                      DateFormat.yMMMd(
                        l10n.localeName,
                      ).format(article.publishedAt),
                      l10n.shortMin(article.readTimeMinutes),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    article.title,
                    style: textTheme.titleLarge,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    article.summary,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Text(article.author.displayName, style: textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.gutter,
        vertical: 32,
      ),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
