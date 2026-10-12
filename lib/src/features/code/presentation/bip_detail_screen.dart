import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/content/domain/content_models.dart';
import '../../../core/content/domain/content_store.dart';
import '../../../core/localization/content_labels.dart';
import '../../../core/localization/localized_labels.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/bookmark_button.dart';
import '../../../core/widgets/content_mappers.dart';
import '../../../core/widgets/content_thumbnail.dart';
import '../../../core/widgets/detail_scaffold.dart';
import '../../../core/widgets/external_url.dart';
import '../../../core/widgets/markdown_text.dart';
import '../../../core/widgets/related_links_grid.dart';
import '../../../core/widgets/sato_group_card.dart';
import '../../../core/widgets/section_title.dart';
import '../../../core/widgets/sources_disclosure.dart';
import '../../../core/widgets/status_pill.dart';
import '../../../generated/l10n/app_localizations.dart';

class BipDetailScreen extends StatelessWidget {
  const BipDetailScreen({required this.store, required this.number, super.key});

  final ContentStore store;
  final int number;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bip = store.bundle.bips
        .where((bip) => bip.number == number)
        .firstOrNull;

    if (bip == null) {
      return DetailScaffold(title: l10n.bipNotFound, children: const []);
    }

    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final wikiLinks = <WikiEntry>[];
    final otherLinks = <RelatedContentLink>[];
    for (final link in bip.related) {
      final entry = link.id.startsWith('wiki.')
          ? store.bundle.wiki.where((entry) => entry.id == link.id).firstOrNull
          : null;
      if (entry != null) {
        wikiLinks.add(entry);
      } else {
        otherLinks.add(link);
      }
    }

    return DetailScaffold(
      actions: [BookmarkButton(contentId: bip.id)],
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'BIP ${bip.number}',
              style: textTheme.labelMedium?.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
              ),
            ),
            BipStatusPill(status: bip.status),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Semantics(
          header: true,
          child: Text(bip.title, style: textTheme.headlineMedium),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          bip.summary,
          style: textTheme.bodyLarge?.copyWith(
            height: 26 / 17,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.lg + AppSpacing.xs),
        SatoGroupCard(
          children: [
            if (bip.authors.isNotEmpty)
              _FactRow(
                label: l10n.authors,
                value: Text(
                  bip.authors.join(', '),
                  style: textTheme.bodyMedium,
                ),
              ),
            _FactRow(
              label: l10n.created,
              value: Text(
                DateFormat.yMMMd(l10n.localeName).format(bip.createdAt),
                style: textTheme.labelMedium?.copyWith(
                  fontSize: 14,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            _FactRow(
              label: l10n.bipType,
              value: Text(
                contentCategoryLabel(bip.category, l10n),
                style: textTheme.bodyMedium,
              ),
            ),
          ],
        ),
        if (bip.summaryMarkdown.trim().isNotEmpty) ...[
          const SizedBox(height: AppSpacing.section),
          SectionTitle(title: l10n.inPlainWords),
          const SizedBox(height: AppSpacing.md),
          MarkdownText(bip.summaryMarkdown, store: store),
        ],
        if (bip.impactMarkdown.trim().isNotEmpty) ...[
          const SizedBox(height: AppSpacing.section),
          SectionTitle(title: l10n.practicalImpact),
          const SizedBox(height: AppSpacing.md),
          MarkdownText(bip.impactMarkdown, store: store),
        ],
        if (bip.statusHistory.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.section),
          SectionTitle(title: l10n.statusHistory),
          const SizedBox(height: AppSpacing.md),
          SatoGroupCard(
            children: [
              for (final change in bip.statusHistory)
                _StatusChangeRow(change: change),
            ],
          ),
        ],
        if (wikiLinks.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.section),
          SectionTitle(title: l10n.readMoreInWiki),
          const SizedBox(height: AppSpacing.md),
          for (var i = 0; i < wikiLinks.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.md),
            _WikiLinkCard(entry: wikiLinks[i]),
          ],
        ],
        if (otherLinks.isNotEmpty) ...[
          if (wikiLinks.isNotEmpty)
            const SizedBox(height: AppSpacing.md)
          else ...[
            const SizedBox(height: AppSpacing.section),
            SectionTitle(title: l10n.relatedConcepts),
            const SizedBox(height: AppSpacing.md),
          ],
          RelatedLinksGrid(
            links: relatedLinks(
              otherLinks,
              store: store,
              onOpen: (route) => Navigator.of(context).pushNamed(route),
            ),
          ),
        ],
        if (bip.sources.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          SourcesDisclosure(sources: sourceReferences(bip.sources)),
        ],
        const SizedBox(height: AppSpacing.section),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            onPressed: () => openExternalUrl(context, bip.officialUrl),
            iconAlignment: IconAlignment.end,
            icon: const Icon(Icons.open_in_new_rounded, size: 18),
            label: Text(l10n.officialTextOnGitHub),
          ),
        ),
      ],
    );
  }
}

class _FactRow extends StatelessWidget {
  const _FactRow({required this.label, required this.value});

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 14,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(child: value),
        ],
      ),
    );
  }
}

class _StatusChangeRow extends StatelessWidget {
  const _StatusChangeRow({required this.change});

  final BipStatusChange change;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 14,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: bipStatusColor(context, change.status),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat.yMMMd(l10n.localeName).format(change.date),
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(change.status.label(l10n), style: textTheme.titleSmall),
                if (change.note.isNotEmpty)
                  Text(change.note, style: textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WikiLinkCard extends StatelessWidget {
  const _WikiLinkCard({required this.entry});

  final WikiEntry entry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: () =>
            Navigator.of(context).pushNamed(AppRoutes.wikiEntry(entry.slug)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              ContentThumbnail(
                source: entry.coverImage?.toString(),
                width: 92,
                height: 68,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${l10n.shortMin(entry.readTimeMinutes)} · ${entry.difficulty.label(l10n)}',
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
