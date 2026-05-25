import '../content/domain/content_models.dart';

enum SearchSection { wiki, news, history, code }

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
      ];

  final List<SearchResult> _items;

  List<SearchResult> search(String query, {Set<SearchSection>? sections}) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return const [];
    }

    final scored = <({SearchResult result, int score})>[];
    for (final item in _items) {
      if (sections != null && !sections.contains(item.section)) {
        continue;
      }

      final title = item.title.toLowerCase();
      final summary = item.summary.toLowerCase();
      final tags = item.tags.map((tag) => tag.toLowerCase()).join(' ');
      final score =
          (title.contains(normalized) ? 8 : 0) +
          (tags.contains(normalized) ? 4 : 0) +
          (summary.contains(normalized) ? 2 : 0);

      if (score > 0) {
        scored.add((result: item, score: score));
      }
    }

    scored.sort((a, b) => b.score.compareTo(a.score));

    return scored.map((item) => item.result).toList(growable: false);
  }
}
