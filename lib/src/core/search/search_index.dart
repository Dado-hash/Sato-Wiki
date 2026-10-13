import '../content/domain/content_models.dart';
import '../navigation/content_routes.dart';

/// Order here is the order of the type filters and of the result groups.
enum SearchSection {
  wiki,
  news,
  history,
  code,
  glossary,
  product,
  reference,
  library,
}

const _titleWeight = 8;
const _tagWeight = 4;
const _summaryWeight = 2;
const _wholeTitleBonus = 8;

// Accented letters that Italian and English text use, folded to ASCII.
const _foldedLetters = {
  'à': 'a',
  'á': 'a',
  'â': 'a',
  'ã': 'a',
  'ä': 'a',
  'å': 'a',
  'ç': 'c',
  'è': 'e',
  'é': 'e',
  'ê': 'e',
  'ë': 'e',
  'ì': 'i',
  'í': 'i',
  'î': 'i',
  'ï': 'i',
  'ñ': 'n',
  'ò': 'o',
  'ó': 'o',
  'ô': 'o',
  'õ': 'o',
  'ö': 'o',
  'ø': 'o',
  'ù': 'u',
  'ú': 'u',
  'û': 'u',
  'ü': 'u',
  'ý': 'y',
  'ÿ': 'y',
  'ß': 'ss',
  'æ': 'ae',
  'œ': 'oe',
};

final _nonWordCharacters = RegExp(r'[^\p{L}\p{N}]+', unicode: true);

/// Lower-cases, folds accents and turns punctuation and dashes into spaces.
String normalizeForSearch(String text) {
  final folded = StringBuffer();
  for (final character in text.toLowerCase().split('')) {
    folded.write(_foldedLetters[character] ?? character);
  }

  return folded.toString().replaceAll(_nonWordCharacters, ' ').trim();
}

final class SearchResult {
  const SearchResult({
    required this.id,
    required this.title,
    required this.summary,
    required this.section,
    required this.route,
    required this.tags,
  });

  final String id;
  final String title;
  final String summary;
  final SearchSection section;
  final String route;
  final List<String> tags;
}

final class _IndexedResult {
  const _IndexedResult({
    required this.result,
    required this.title,
    required this.summary,
    required this.tags,
  });

  factory _IndexedResult.from(SearchResult result) {
    return _IndexedResult(
      result: result,
      title: normalizeForSearch(result.title),
      summary: normalizeForSearch(result.summary),
      tags: normalizeForSearch(result.tags.join(' ')),
    );
  }

  final SearchResult result;
  final String title;
  final String summary;
  final String tags;
}

/// Result whose route comes from its content id. Null when the id has no
/// detail screen, so such a record is left out of the index.
SearchResult? _linkedResult({
  required String id,
  required String title,
  required String summary,
  required SearchSection section,
  required List<String> tags,
}) {
  final route = routeForContentId(id);
  if (route == null) {
    return null;
  }

  return SearchResult(
    id: id,
    title: title,
    summary: summary,
    section: section,
    route: route,
    tags: tags,
  );
}

final class SearchIndex {
  SearchIndex.fromBundle(ContentBundle bundle)
    : _items = [
        for (final entry in bundle.wiki)
          SearchResult(
            id: entry.id,
            title: entry.title,
            summary: entry.description,
            section: SearchSection.wiki,
            route: '/wiki/entries/${entry.slug}',
            tags: entry.tags,
          ),
        for (final article in bundle.news)
          SearchResult(
            id: article.id,
            title: article.title,
            summary: article.summary,
            section: SearchSection.news,
            route: '/news/articles/${article.slug}',
            tags: article.tags,
          ),
        for (final event in bundle.history)
          SearchResult(
            id: event.id,
            title: event.title,
            summary: event.summary,
            section: SearchSection.history,
            route: '/history/events/${event.slug}',
            tags: event.tags,
          ),
        for (final bip in bundle.bips)
          SearchResult(
            id: bip.id,
            title: 'BIP ${bip.number}: ${bip.title}',
            summary: bip.summary,
            section: SearchSection.code,
            route: '/code/bips/${bip.number}',
            tags: bip.tags,
          ),
        for (final release in bundle.changelogs)
          SearchResult(
            id: release.id,
            title: release.title,
            summary: release.summary,
            section: SearchSection.code,
            route: '/code/changelogs/${release.project}/${release.version}',
            tags: release.tags,
          ),
        // Glossary, products, reference tables and library works. Only the
        // short fields are indexed, never their Markdown bodies.
        for (final term in bundle.glossary)
          ?_linkedResult(
            id: term.id,
            title: term.term,
            summary: term.definition,
            section: SearchSection.glossary,
            tags: term.aliases,
          ),
        for (final product in bundle.products)
          ?_linkedResult(
            id: product.id,
            title: product.name,
            summary: product.summary,
            section: SearchSection.product,
            tags: [product.maker],
          ),
        for (final table in bundle.references)
          ?_linkedResult(
            id: table.id,
            title: table.title,
            summary: table.description,
            section: SearchSection.reference,
            tags: const [],
          ),
        for (final work in bundle.library)
          ?_linkedResult(
            id: work.id,
            title: work.title,
            summary: work.summary,
            section: SearchSection.library,
            tags: [work.author],
          ),
      ];

  final List<SearchResult> _items;

  late final List<_IndexedResult> _indexed = [
    for (final item in _items) _IndexedResult.from(item),
  ];

  /// Every query token must match the title, tags or summary.
  ///
  /// Each token adds the weight of every field that contains it. A query that
  /// matches the whole title gets a bonus. Ties are broken by section (enum
  /// order), then title, then id.
  List<SearchResult> search(String query, {Set<SearchSection>? sections}) {
    final normalizedQuery = normalizeForSearch(query);
    if (normalizedQuery.isEmpty) {
      return const [];
    }
    final tokens = normalizedQuery.split(' ');

    final scored = <({SearchResult result, int score})>[];
    for (final item in _indexed) {
      if (sections != null && !sections.contains(item.result.section)) {
        continue;
      }

      final score = _scoreFor(item, tokens, normalizedQuery);
      if (score > 0) {
        scored.add((result: item.result, score: score));
      }
    }

    scored.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;

      final bySection = a.result.section.index.compareTo(
        b.result.section.index,
      );
      if (bySection != 0) return bySection;

      final byTitle = a.result.title.compareTo(b.result.title);
      if (byTitle != 0) return byTitle;

      return a.result.id.compareTo(b.result.id);
    });

    return scored.map((item) => item.result).toList(growable: false);
  }

  /// Zero when any token is missing from every field.
  int _scoreFor(_IndexedResult item, List<String> tokens, String query) {
    var score = 0;
    for (final token in tokens) {
      final tokenScore =
          (item.title.contains(token) ? _titleWeight : 0) +
          (item.tags.contains(token) ? _tagWeight : 0) +
          (item.summary.contains(token) ? _summaryWeight : 0);
      if (tokenScore == 0) {
        return 0;
      }
      score += tokenScore;
    }

    if (item.title.contains(query)) {
      score += _wholeTitleBonus;
    }

    return score;
  }
}
