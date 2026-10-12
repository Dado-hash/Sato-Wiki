import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/content/domain/content_models.dart';
import '../../../core/content/domain/content_store.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/detail_scaffold.dart';
import '../../../core/widgets/sato_group_card.dart';
import '../../../generated/l10n/app_localizations.dart';

class ReleaseListScreen extends StatelessWidget {
  const ReleaseListScreen({required this.store, super.key});

  final ContentStore store;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final releases = _sortReleases(store.bundle.changelogs);

    return DetailScaffold(
      title: l10n.allReleasesTitle,
      children: [
        if (releases.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                l10n.noRecentReleases,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          SatoGroupCard(
            children: [
              for (final release in releases) ReleaseRow(release: release),
            ],
          ),
      ],
    );
  }
}

/// One release line: version, title, importance and date. Tap opens the note.
class ReleaseRow extends StatelessWidget {
  const ReleaseRow({required this.release, super.key});

  final ReleaseNote release;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isMajor = release.importance == ReleaseImportance.major;
    final importanceLabel = switch (release.importance) {
      ReleaseImportance.major => l10n.statusMajor,
      ReleaseImportance.minor => l10n.statusMinor,
      ReleaseImportance.patch => l10n.statusPatch,
    };

    return InkWell(
      onTap: () => Navigator.of(
        context,
      ).pushNamed(AppRoutes.codeChangelog(release.project, release.version)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              SizedBox(
                width: 56,
                child: Text(
                  'v${release.version}',
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  release.title,
                  style: textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    importanceLabel.toUpperCase(),
                    style: textTheme.labelSmall?.copyWith(
                      color: isMajor
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat.yMMMd(
                      l10n.localeName,
                    ).format(release.releasedAt),
                    style: textTheme.labelMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

List<ReleaseNote> _sortReleases(Iterable<ReleaseNote> releases) {
  final sorted = releases.toList(growable: false);
  sorted.sort((a, b) => b.releasedAt.compareTo(a.releasedAt));

  return sorted;
}
