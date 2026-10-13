import 'package:flutter/material.dart';

import '../../../core/content/domain/content_models.dart';
import '../../../core/content/domain/content_store.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/detail_scaffold.dart';
import '../../../core/widgets/filter_chip_bar.dart';
import '../../../core/widgets/sato_group_card.dart';
import '../../../generated/l10n/app_localizations.dart';

/// Library works sorted by year, then title, with filter chips for author and
/// topic. The chip values come from the loaded works.
class LibraryListScreen extends StatefulWidget {
  const LibraryListScreen({required this.store, super.key});

  final ContentStore store;

  @override
  State<LibraryListScreen> createState() => _LibraryListScreenState();
}

class _LibraryListScreenState extends State<LibraryListScreen> {
  String? _author;
  String? _topic;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final works = sortLibraryWorks(widget.store.bundle.library);
    final authors = libraryAuthors(works);
    final topics = libraryTopics(works);
    final visible = filterLibraryWorks(works, author: _author, topic: _topic);

    return DetailScaffold(
      title: l10n.libraryTitle,
      children: [
        if (works.isEmpty)
          Text(l10n.libraryEmpty, style: textTheme.bodyMedium)
        else ...[
          _FilterGroup(
            label: l10n.libraryAuthorLabel,
            child: FilterChipBar<String?>(
              items: [null, ...authors],
              selectedItem: _author,
              labelFor: (author) => author ?? l10n.all,
              onSelected: (author) => setState(() => _author = author),
            ),
          ),
          if (topics.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            _FilterGroup(
              label: l10n.libraryTopicLabel,
              child: FilterChipBar<String?>(
                items: [null, ...topics],
                selectedItem: _topic,
                labelFor: (topic) => topic ?? l10n.all,
                onSelected: (topic) => setState(() => _topic = topic),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          if (visible.isEmpty)
            Text(
              l10n.libraryNoMatch,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            )
          else
            SatoGroupCard(
              children: [for (final work in visible) _WorkRow(work: work)],
            ),
        ],
      ],
    );
  }
}

/// Works ordered by year, then by title, ignoring case.
List<LibraryWork> sortLibraryWorks(List<LibraryWork> works) {
  return [...works]..sort((a, b) {
    final byYear = a.year.compareTo(b.year);
    if (byYear != 0) return byYear;

    return a.title.toLowerCase().compareTo(b.title.toLowerCase());
  });
}

/// Works by [author] and tagged with [topic]. Both comparisons ignore case
/// and surrounding spaces. A null value does not filter.
List<LibraryWork> filterLibraryWorks(
  List<LibraryWork> works, {
  String? author,
  String? topic,
}) {
  final authorNeedle = author?.trim().toLowerCase();
  final topicNeedle = topic?.trim().toLowerCase();

  return [
    for (final work in works)
      if ((authorNeedle == null ||
              work.author.trim().toLowerCase() == authorNeedle) &&
          (topicNeedle == null ||
              work.topics.any(
                (item) => item.trim().toLowerCase() == topicNeedle,
              )))
        work,
  ];
}

/// Distinct authors, sorted, with the spelling of the first work that has them.
List<String> libraryAuthors(List<LibraryWork> works) {
  return _distinctSorted([for (final work in works) work.author]);
}

/// Distinct topics across all works, sorted.
List<String> libraryTopics(List<LibraryWork> works) {
  return _distinctSorted([for (final work in works) ...work.topics]);
}

List<String> _distinctSorted(List<String> values) {
  final byKey = <String, String>{};
  for (final value in values) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) continue;

    byKey.putIfAbsent(trimmed.toLowerCase(), () => trimmed);
  }

  return byKey.values.toList()
    ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
}

/// Label for the kind of work. Kinds the app does not know are shown as
/// they are stored.
String libraryKindName(AppLocalizations l10n, String kind) {
  return switch (kind) {
    'paper' => l10n.libraryKindPaper,
    'essay' => l10n.libraryKindEssay,
    'post' => l10n.libraryKindPost,
    'email' => l10n.libraryKindEmail,
    'book' => l10n.libraryKindBook,
    'manifesto' => l10n.libraryKindManifesto,
    _ => kind,
  };
}

class _FilterGroup extends StatelessWidget {
  const _FilterGroup({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        child,
      ],
    );
  }
}

class _WorkRow extends StatelessWidget {
  const _WorkRow({required this.work});

  final LibraryWork work;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: () =>
          Navigator.of(context).pushNamed(AppRoutes.libraryWork(work.slug)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 14,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(work.title, style: textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${work.author} · ${work.year}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      libraryKindName(l10n, work.kind),
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
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
