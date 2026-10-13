import 'package:flutter/material.dart';

import '../../../core/content/domain/content_store.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/bookmark_button.dart';
import '../../../core/widgets/content_mappers.dart';
import '../../../core/widgets/detail_scaffold.dart';
import '../../../core/widgets/external_url.dart';
import '../../../core/widgets/markdown_text.dart';
import '../../../core/widgets/related_links_grid.dart';
import '../../../core/widgets/section_title.dart';
import '../../../core/widgets/sources_disclosure.dart';
import '../../../generated/l10n/app_localizations.dart';
import 'library_list_screen.dart';

/// One library work: facts, our summary and introduction, and links to the
/// original and to an archived copy. The app never fetches or shows the
/// original text; the buttons open it in the browser on tap only.
class LibraryWorkScreen extends StatelessWidget {
  const LibraryWorkScreen({
    required this.store,
    required this.slug,
    this.openLink = openExternalUrl,
    super.key,
  });

  final ContentStore store;
  final String slug;

  /// Opens the original and the archived copy. Only called on tap.
  final Future<void> Function(BuildContext context, Uri uri) openLink;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final work = store.bundle.library
        .where((item) => item.slug == slug)
        .firstOrNull;

    if (work == null) {
      return DetailScaffold(title: l10n.libraryNotFound, children: const []);
    }

    final topics = work.topics.join(' · ');
    final archiveUrl = work.archiveUrl;

    return DetailScaffold(
      actions: [BookmarkButton(contentId: work.id)],
      children: [
        Semantics(
          header: true,
          child: Text(work.title, style: textTheme.headlineLarge),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          work.summary,
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
                label: l10n.libraryAuthorLabel,
                child: Text(work.author, style: textTheme.bodyMedium),
              ),
              _FactRow(
                label: l10n.libraryYearLabel,
                child: Text(
                  '${work.year}',
                  style: textTheme.bodyMedium?.copyWith(
                    fontFamily: AppFonts.mono,
                  ),
                ),
              ),
              _FactRow(
                label: l10n.libraryKindLabel,
                child: Text(
                  libraryKindName(l10n, work.kind),
                  style: textTheme.bodyMedium,
                ),
              ),
              _FactRow(
                label: l10n.libraryOriginalLanguageLabel,
                child: Text(
                  work.originalLanguage.toUpperCase(),
                  style: textTheme.bodyMedium?.copyWith(
                    fontFamily: AppFonts.mono,
                  ),
                ),
              ),
              if (topics.isNotEmpty)
                _FactRow(
                  label: l10n.libraryTopicLabel,
                  child: Text(topics, style: textTheme.bodyMedium),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            FilledButton.icon(
              onPressed: () => openLink(context, work.url),
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: Text(l10n.libraryReadOriginal),
            ),
            if (archiveUrl != null)
              OutlinedButton.icon(
                onPressed: () => openLink(context, archiveUrl),
                icon: const Icon(Icons.archive_outlined, size: 18),
                label: Text(l10n.libraryArchivedCopy),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          '${l10n.libraryLicenseLabel}: ${work.licenseNote}',
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l10n.libraryNotice,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.section),
        SectionTitle(title: l10n.libraryIntroduction),
        const SizedBox(height: AppSpacing.md),
        MarkdownText(work.introduction, store: store, openLink: openLink),
        if (work.related.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.section),
          SectionTitle(title: l10n.relatedConcepts),
          const SizedBox(height: AppSpacing.md),
          RelatedLinksGrid(
            links: relatedLinks(
              work.related,
              store: store,
              onOpen: (route) => Navigator.of(context).pushNamed(route),
            ),
          ),
        ],
        if (work.sources.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          SourcesDisclosure(sources: sourceReferences(work.sources)),
        ],
        const SizedBox(height: AppSpacing.section),
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
