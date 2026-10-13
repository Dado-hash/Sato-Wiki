import 'app_routes.dart';

/// Route for a content id such as `wiki.sha-256` or `code.bip.341`.
///
/// Returns null when the app has no detail screen for the id prefix or the
/// id does not have the expected shape. Existence of the record is checked
/// separately against the loaded content.
String? routeForContentId(String id) {
  if (id.startsWith('wiki.')) {
    return _slugRoute(id, 'wiki.', AppRoutes.wikiEntry);
  }
  if (id.startsWith('news.')) {
    return _slugRoute(id, 'news.', AppRoutes.newsArticle);
  }
  if (id.startsWith('history.')) {
    return _slugRoute(id, 'history.', AppRoutes.historyEvent);
  }
  if (id.startsWith('product.')) {
    return _slugRoute(id, 'product.', AppRoutes.product);
  }
  if (id.startsWith('glossary.')) {
    return _slugRoute(id, 'glossary.', AppRoutes.glossaryTerm);
  }
  if (id.startsWith('path.')) {
    return _slugRoute(id, 'path.', AppRoutes.learningPath);
  }
  if (id.startsWith('reference.')) {
    return _slugRoute(id, 'reference.', AppRoutes.reference);
  }
  if (id.startsWith('library.')) {
    return _slugRoute(id, 'library.', AppRoutes.libraryWork);
  }
  if (id.startsWith('code.bip.')) {
    final number = int.tryParse(id.substring('code.bip.'.length));
    return number == null ? null : AppRoutes.codeBip(number);
  }
  if (id.startsWith('release.')) {
    // Ids are `release.<project>.<version>`; projects have no dots.
    final rest = id.substring('release.'.length);
    final split = rest.indexOf('.');
    if (split <= 0 || split == rest.length - 1) {
      return null;
    }

    return AppRoutes.codeChangelog(
      rest.substring(0, split),
      rest.substring(split + 1),
    );
  }

  return null;
}

String? _slugRoute(String id, String prefix, String Function(String) build) {
  final slug = id.substring(prefix.length);

  return slug.isEmpty ? null : build(slug);
}
