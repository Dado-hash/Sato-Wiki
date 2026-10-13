import 'package:flutter/material.dart';

import '../../../core/content/domain/content_store.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/content_mappers.dart';
import '../../../core/widgets/detail_scaffold.dart';
import '../../../core/widgets/external_url.dart';
import '../../../core/widgets/markdown_text.dart';
import '../../../core/widgets/related_links_grid.dart';
import '../../../core/widgets/section_title.dart';
import '../../../core/widgets/sources_disclosure.dart';
import '../../../generated/l10n/app_localizations.dart';
import 'wiki_tree_widgets.dart';

//
// ─── PRODUCT DETAIL ───────────────────────────────────────────────────────────
//

class ProductScreen extends StatelessWidget {
  const ProductScreen({
    required this.store,
    required this.slug,
    this.openLink = openExternalUrl,
    super.key,
  });

  final ContentStore store;
  final String slug;

  /// Opens the website and source links. Only called on tap.
  final Future<void> Function(BuildContext context, Uri uri) openLink;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final product = store.bundle.products
        .where((item) => item.slug == slug)
        .firstOrNull;

    if (product == null) {
      return DetailScaffold(
        title: l10n.wikiTreeProductNotFound,
        children: const [],
      );
    }

    final platforms = product.platforms.join(' · ');
    final license = product.license;

    return DetailScaffold(
      children: [
        Semantics(
          header: true,
          child: Text(product.name, style: textTheme.headlineLarge),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          product.summary,
          style: textTheme.bodyLarge?.copyWith(
            height: 26 / 17,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.gutter),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadii.card),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FactRow(
                label: l10n.wikiTreeMaker,
                child: Text(product.maker, style: textTheme.bodyMedium),
              ),
              _FactRow(
                label: l10n.wikiTreeStatus,
                child: ProductStatusPill(status: product.status),
              ),
              _FactRow(
                label: l10n.wikiTreeOpenSource,
                child: Text(
                  product.openSource ? l10n.wikiTreeYes : l10n.wikiTreeNo,
                  style: textTheme.bodyMedium,
                ),
              ),
              if (license != null)
                _FactRow(
                  label: l10n.wikiTreeLicense,
                  child: Text(license, style: textTheme.bodyMedium),
                ),
              if (platforms.isNotEmpty)
                _FactRow(
                  label: l10n.wikiTreePlatforms,
                  child: Text(platforms, style: textTheme.bodyMedium),
                ),
              CheckedOnLine(date: product.reviewedAt),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            FilledButton.icon(
              onPressed: () => openLink(context, product.website),
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: Text(l10n.wikiTreeWebsite),
            ),
            if (product.sourceUrl case final sourceUrl?)
              OutlinedButton.icon(
                onPressed: () => openLink(context, sourceUrl),
                icon: const Icon(Icons.code_rounded, size: 18),
                label: Text(l10n.wikiTreeSourceCode),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.section),
        MarkdownText(product.bodyMarkdown, store: store, openLink: openLink),
        if (product.related.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.section),
          SectionTitle(title: l10n.relatedConcepts),
          const SizedBox(height: AppSpacing.md),
          RelatedLinksGrid(
            links: relatedLinks(
              product.related,
              store: store,
              onOpen: (route) => Navigator.of(context).pushNamed(route),
            ),
          ),
        ],
        if (product.sources.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          SourcesDisclosure(sources: sourceReferences(product.sources)),
        ],
        const SizedBox(height: AppSpacing.section),
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.lg),
            child: Text(
              l10n.wikiTreeProductNotice,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Label above a value, inside the fact card.
class _FactRow extends StatelessWidget {
  const _FactRow({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          child,
        ],
      ),
    );
  }
}
