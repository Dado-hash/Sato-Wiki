import 'package:flutter/material.dart';

import '../content/domain/content_models.dart' as content;
import '../content/domain/content_store.dart';
import '../navigation/content_routes.dart';
import 'metadata_row.dart';
import 'related_links_grid.dart';
import 'sources_disclosure.dart' as disclosure;

List<MetadataItem> tagMetadata(List<String> tags) {
  return [for (final tag in tags) MetadataItem(label: '#$tag', isTag: true)];
}

/// Maps related content links to tiles.
///
/// A tile is tappable only when the id has a route in the app and the target
/// record is loaded. [onOpen] receives that route.
List<RelatedLink> relatedLinks(
  List<content.RelatedContentLink> links, {
  required ContentStore store,
  void Function(String route)? onOpen,
}) {
  return [
    for (final link in links) _relatedLink(link, store: store, onOpen: onOpen),
  ];
}

RelatedLink _relatedLink(
  content.RelatedContentLink link, {
  required ContentStore store,
  void Function(String route)? onOpen,
}) {
  final recordTitle = recordTitleFor(store, link.id);
  final route = routeForContentId(link.id);
  final canOpen = onOpen != null && route != null && recordTitle != null;

  return RelatedLink(
    title: link.title ?? recordTitle ?? _humanizedId(link.id),
    icon: Icons.link,
    onTap: canOpen ? () => onOpen(route) : null,
  );
}

/// Title of the loaded record with [id], or null when it is not loaded.
String? recordTitleFor(ContentStore store, String id) {
  final bundle = store.bundle;

  final wiki = bundle.wiki.where((entry) => entry.id == id).firstOrNull;
  if (wiki != null) return wiki.title;

  final news = bundle.news.where((article) => article.id == id).firstOrNull;
  if (news != null) return news.title;

  final history = bundle.history.where((event) => event.id == id).firstOrNull;
  if (history != null) return history.title;

  final bip = bundle.bips.where((item) => item.id == id).firstOrNull;
  if (bip != null) return 'BIP ${bip.number}: ${bip.title}';

  final release = bundle.changelogs.where((item) => item.id == id).firstOrNull;
  if (release != null) return release.title;

  final product = bundle.products.where((item) => item.id == id).firstOrNull;
  if (product != null) return product.name;

  final term = bundle.glossary.where((item) => item.id == id).firstOrNull;
  if (term != null) return term.term;

  final table = bundle.references.where((item) => item.id == id).firstOrNull;
  if (table != null) return table.title;

  final path = bundle.paths.where((item) => item.id == id).firstOrNull;
  if (path != null) return path.title;

  final work = bundle.library.where((item) => item.id == id).firstOrNull;
  if (work != null) return work.title;

  return null;
}

/// Last dot-separated segment with dashes as spaces and a capital first letter.
String _humanizedId(String id) {
  final slug = id.substring(id.lastIndexOf('.') + 1).replaceAll('-', ' ');
  if (slug.isEmpty) return id;

  return slug[0].toUpperCase() + slug.substring(1);
}

List<disclosure.SourceReference> sourceReferences(
  List<content.SourceReference> sources,
) {
  return [
    for (final source in sources)
      disclosure.SourceReference(
        title: source.title,
        author: source.author,
        url: source.url,
      ),
  ];
}
