import 'package:flutter/material.dart';

import '../../../core/content/domain/content_models.dart';
import '../../../core/content/domain/content_store.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/content_mappers.dart';
import '../../../core/widgets/detail_scaffold.dart';
import '../../../core/widgets/related_links_grid.dart';
import '../../../core/widgets/sato_group_card.dart';
import '../../../core/widgets/section_title.dart';
import '../../../generated/l10n/app_localizations.dart';

/// Glossary terms sorted alphabetically, with a text filter over the term and
/// its aliases.
class GlossaryListScreen extends StatefulWidget {
  const GlossaryListScreen({required this.store, super.key});

  final ContentStore store;

  @override
  State<GlossaryListScreen> createState() => _GlossaryListScreenState();
}

class _GlossaryListScreenState extends State<GlossaryListScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    setState(() => _query = '');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final sorted = [...widget.store.bundle.glossary]
      ..sort((a, b) => a.term.toLowerCase().compareTo(b.term.toLowerCase()));
    final terms = filterGlossaryTerms(sorted, _query);
    final query = _query.trim();

    return DetailScaffold(
      title: l10n.learnGlossaryTitle,
      children: [
        TextField(
          controller: _controller,
          onChanged: (value) => setState(() => _query = value),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: l10n.learnGlossaryFilterHint,
            prefixIcon: Icon(
              Icons.search_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    tooltip: l10n.clearSearch,
                    icon: const Icon(Icons.close_rounded),
                    onPressed: _clear,
                  ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (sorted.isEmpty)
          Text(l10n.learnGlossaryEmpty, style: textTheme.bodyMedium)
        else if (terms.isEmpty)
          Text(
            l10n.learnGlossaryNoMatch(query),
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        for (final group in groupGlossaryByLetter(terms)) ...[
          Semantics(
            header: true,
            child: Padding(
              padding: const EdgeInsets.only(
                top: AppSpacing.lg,
                bottom: AppSpacing.sm,
              ),
              child: Text(
                group.letter,
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          SatoGroupCard(
            children: [for (final term in group.terms) _TermRow(term: term)],
          ),
        ],
      ],
    );
  }
}

/// Terms whose term or any alias contains [query], ignoring case. An empty
/// query keeps every term, in the order given.
List<GlossaryTerm> filterGlossaryTerms(List<GlossaryTerm> terms, String query) {
  final needle = query.trim().toLowerCase();
  if (needle.isEmpty) {
    return terms;
  }

  return [
    for (final term in terms)
      if (term.term.toLowerCase().contains(needle) ||
          term.aliases.any((alias) => alias.toLowerCase().contains(needle)))
        term,
  ];
}

final class GlossaryLetterGroup {
  const GlossaryLetterGroup({required this.letter, required this.terms});

  final String letter;
  final List<GlossaryTerm> terms;
}

/// Groups terms that are already sorted by their first letter. Terms that do
/// not start with a letter go under "#".
List<GlossaryLetterGroup> groupGlossaryByLetter(List<GlossaryTerm> terms) {
  final groups = <GlossaryLetterGroup>[];
  final letterPattern = RegExp(r'\p{L}', unicode: true);

  for (final term in terms) {
    final trimmed = term.term.trim();
    final first = trimmed.isEmpty ? '#' : trimmed[0].toUpperCase();
    final letter = letterPattern.hasMatch(first) ? first : '#';

    if (groups.isEmpty || groups.last.letter != letter) {
      groups.add(GlossaryLetterGroup(letter: letter, terms: [term]));
    } else {
      groups.last.terms.add(term);
    }
  }

  return groups;
}

class _TermRow extends StatelessWidget {
  const _TermRow({required this.term});

  final GlossaryTerm term;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: () =>
          Navigator.of(context).pushNamed(AppRoutes.glossaryTerm(term.slug)),
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
                    Text(term.term, style: textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      term.definition,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
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

/// One glossary term: the term, its aliases, the full definition and related
/// entries.
class GlossaryTermScreen extends StatelessWidget {
  const GlossaryTermScreen({
    required this.store,
    required this.slug,
    super.key,
  });

  final ContentStore store;
  final String slug;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final term = store.bundle.glossary
        .where((item) => item.slug == slug)
        .firstOrNull;

    if (term == null) {
      return DetailScaffold(
        title: l10n.learnGlossaryNotFound,
        children: const [],
      );
    }

    return DetailScaffold(
      title: term.term,
      children: [
        Semantics(
          header: true,
          child: Text(term.term, style: textTheme.headlineMedium),
        ),
        if (term.aliases.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${l10n.learnAlsoCalled}: ${term.aliases.join(', ')}',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        Text(
          term.definition,
          style: textTheme.bodyLarge?.copyWith(
            height: 26 / 17,
            color: colorScheme.onSurface,
          ),
        ),
        if (term.related.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.section),
          SectionTitle(title: l10n.relatedConcepts),
          const SizedBox(height: AppSpacing.md),
          RelatedLinksGrid(
            links: relatedLinks(
              term.related,
              store: store,
              onOpen: (route) => Navigator.of(context).pushNamed(route),
            ),
          ),
        ],
      ],
    );
  }
}
