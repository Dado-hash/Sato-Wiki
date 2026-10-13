import 'package:flutter/material.dart';

import '../../../core/content/domain/content_store.dart';
import '../../../core/navigation/content_routes.dart';
import '../../../core/settings/app_settings_controller.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/content_mappers.dart';
import '../../../core/widgets/detail_scaffold.dart';
import '../../../core/widgets/sato_group_card.dart';
import '../../../generated/l10n/app_localizations.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({
    required this.store,
    required this.settings,
    super.key,
  });

  final ContentStore store;
  final AppSettingsController settings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final rows = <_BookmarkRow>[];
        for (final id in settings.bookmarks) {
          final title = recordTitleFor(store, id);
          final route = routeForContentId(id);
          if (title == null || route == null) {
            continue;
          }

          rows.add(
            _BookmarkRow(
              contentId: id,
              title: title,
              route: route,
              sectionLabel: _sectionLabel(l10n, id),
              settings: settings,
            ),
          );
        }

        return DetailScaffold(
          title: l10n.bookmarks,
          children: [
            if (rows.isEmpty)
              const _EmptyBookmarks()
            else
              SatoGroupCard(children: rows),
          ],
        );
      },
    );
  }
}

String _sectionLabel(AppLocalizations l10n, String id) {
  if (id.startsWith('wiki.')) return l10n.wikiTab.toUpperCase();
  if (id.startsWith('news.')) return l10n.newsTab.toUpperCase();
  if (id.startsWith('history.')) return l10n.historyTab.toUpperCase();
  if (id.startsWith('code.') || id.startsWith('release.')) {
    return l10n.codeTab.toUpperCase();
  }
  if (id.startsWith('glossary.')) {
    return l10n.librarySearchTypeGlossary.toUpperCase();
  }
  if (id.startsWith('product.')) {
    return l10n.librarySearchTypeProduct.toUpperCase();
  }
  if (id.startsWith('reference.')) {
    return l10n.librarySearchTypeReference.toUpperCase();
  }
  if (id.startsWith('library.')) {
    return l10n.librarySearchTypeLibrary.toUpperCase();
  }

  return '';
}

class _BookmarkRow extends StatelessWidget {
  const _BookmarkRow({
    required this.contentId,
    required this.title,
    required this.route,
    required this.sectionLabel,
    required this.settings,
  });

  final String contentId;
  final String title;
  final String route;
  final String sectionLabel;
  final AppSettingsController settings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(route),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    sectionLabel,
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    title,
                    style: textTheme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.bookmark_rounded, color: colorScheme.primary),
              tooltip: l10n.removeBookmark,
              onPressed: () => settings.toggleBookmark(contentId),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyBookmarks extends StatelessWidget {
  const _EmptyBookmarks();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bookmark_border_rounded,
            size: 32,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.noBookmarks,
            style: textTheme.titleSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            l10n.noBookmarksHint,
            style: textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
