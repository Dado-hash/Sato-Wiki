import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/content/domain/content_models.dart';
import '../../../core/content/domain/content_store.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/bookmark_button.dart';
import '../../../core/widgets/content_mappers.dart';
import '../../../core/widgets/detail_scaffold.dart';
import '../../../core/widgets/external_url.dart';
import '../../../core/widgets/markdown_text.dart';
import '../../../core/widgets/related_links_grid.dart';
import '../../../core/widgets/sato_group_card.dart';
import '../../../core/widgets/section_title.dart';
import '../../../core/widgets/sources_disclosure.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../generated/l10n/app_localizations.dart';

class ReleaseNoteScreen extends StatelessWidget {
  const ReleaseNoteScreen({
    required this.store,
    required this.project,
    required this.version,
    super.key,
  });

  final ContentStore store;
  final String project;
  final String version;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final release = store.bundle.changelogs
        .where(
          (release) => release.project == project && release.version == version,
        )
        .firstOrNull;

    if (release == null) {
      return DetailScaffold(title: l10n.releaseNotFound, children: const []);
    }

    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return DetailScaffold(
      actions: [BookmarkButton(contentId: release.id)],
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'v${release.version}',
              style: textTheme.labelMedium?.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
              ),
            ),
            StatusBadge(
              status: switch (release.importance) {
                ReleaseImportance.major => ContentStatus.major,
                ReleaseImportance.minor => ContentStatus.minor,
                ReleaseImportance.patch => ContentStatus.patch,
              },
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Semantics(
          header: true,
          child: Text(release.title, style: textTheme.headlineMedium),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          release.summary,
          style: textTheme.bodyLarge?.copyWith(
            height: 26 / 17,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.lg + AppSpacing.xs),
        SatoGroupCard(
          children: [
            _FactRow(
              label: l10n.version,
              value: Text(
                release.version,
                style: textTheme.labelMedium?.copyWith(
                  fontSize: 14,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            _FactRow(
              label: l10n.released,
              value: Text(
                DateFormat.yMMMMd(l10n.localeName).format(release.releasedAt),
                style: textTheme.labelMedium?.copyWith(
                  fontSize: 14,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        if (release.userImpactMarkdown.trim().isNotEmpty) ...[
          const SizedBox(height: AppSpacing.section),
          SectionTitle(title: l10n.userImpact),
          const SizedBox(height: AppSpacing.md),
          MarkdownText(release.userImpactMarkdown, store: store),
        ],
        if (release.technicalChangesMarkdown.trim().isNotEmpty) ...[
          const SizedBox(height: AppSpacing.section),
          SectionTitle(title: l10n.technicalChanges),
          const SizedBox(height: AppSpacing.md),
          MarkdownText(release.technicalChangesMarkdown, store: store),
        ],
        if (release.related.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.section),
          SectionTitle(title: l10n.relatedConcepts),
          const SizedBox(height: AppSpacing.md),
          RelatedLinksGrid(
            links: relatedLinks(
              release.related,
              store: store,
              onOpen: (route) => Navigator.of(context).pushNamed(route),
            ),
          ),
        ],
        if (release.sources.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          SourcesDisclosure(sources: sourceReferences(release.sources)),
        ],
        const SizedBox(height: AppSpacing.section),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            onPressed: () => openExternalUrl(context, release.officialUrl),
            iconAlignment: IconAlignment.end,
            icon: const Icon(Icons.open_in_new_rounded, size: 18),
            label: Text(l10n.officialReleaseNotes),
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
