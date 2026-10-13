import 'package:flutter/material.dart';

import '../../../core/content/domain/content_models.dart';
import '../../../core/content/domain/content_store.dart';
import '../../../core/localization/content_labels.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/sato_colors.dart';
import '../../../core/widgets/detail_scaffold.dart';
import '../../../core/widgets/section_title.dart';
import '../../../generated/l10n/app_localizations.dart';
import 'wiki_tree_widgets.dart';

//
// ─── SUBCATEGORY: GUIDES AND PRODUCTS ─────────────────────────────────────────
//

class WikiSubcategoryScreen extends StatelessWidget {
  const WikiSubcategoryScreen({
    required this.store,
    required this.subcategoryId,
    super.key,
  });

  final ContentStore store;
  final String subcategoryId;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final guides = store.bundle.wiki
        .where((entry) => entry.subcategory == subcategoryId)
        .toList(growable: false);
    final products =
        store.bundle.products
            .where((product) => product.subcategory == subcategoryId)
            .toList()
          ..sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          );

    return DetailScaffold(
      title: contentSubcategoryLabel(subcategoryId, l10n),
      children: [
        if (guides.isEmpty && products.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.section),
            child: Text(
              l10n.noLocalResultFound,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ...spaced([
          for (final entry in guides)
            _GuideCard(
              entry: entry,
              onTap: () => Navigator.of(
                context,
              ).pushNamed(AppRoutes.wikiEntry(entry.slug)),
            ),
        ], AppSpacing.md),
        if (products.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.section),
          SectionTitle(title: l10n.wikiTreeProductsCount(products.length)),
          const SizedBox(height: AppSpacing.md),
          ...spaced([
            for (final product in products)
              _ProductRow(
                product: product,
                onTap: () => Navigator.of(
                  context,
                ).pushNamed(AppRoutes.product(product.slug)),
              ),
          ], AppSpacing.md),
        ],
      ],
    );
  }
}

/// Guide entry of the subcategory, on the accent tint.
class _GuideCard extends StatelessWidget {
  const _GuideCard({required this.entry, required this.onTap});

  final WikiEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return Material(
      color: context.sato.accentTint,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
        side: BorderSide(color: colorScheme.primary),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.wikiTreeGuideMinutes(entry.readTimeMinutes).toUpperCase(),
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(entry.title, style: textTheme.titleLarge),
              const SizedBox(height: AppSpacing.xs),
              Text(entry.description, style: textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return WikiCardSurface(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(product.name, style: textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    product.summary,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      ProductStatusPill(status: product.status),
                      WikiInfoPill(
                        label: product.openSource
                            ? l10n.wikiTreeOpenSource
                            : l10n.wikiTreeSourceNotOpen,
                      ),
                      if (product.platforms.isNotEmpty)
                        WikiInfoPill(label: product.platforms.join(' · ')),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
