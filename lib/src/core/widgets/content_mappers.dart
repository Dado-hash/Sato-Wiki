import 'package:flutter/material.dart';

import '../content/domain/content_models.dart' as content;
import 'metadata_row.dart';
import 'related_links_grid.dart';
import 'sources_disclosure.dart' as disclosure;

List<MetadataItem> tagMetadata(List<String> tags) {
  return [for (final tag in tags) MetadataItem(label: '#$tag', isTag: true)];
}

List<RelatedLink> relatedLinks(
  List<content.RelatedContentLink> links, {
  void Function(String id)? onTap,
}) {
  return [
    for (final link in links)
      RelatedLink(
        title: link.title ?? link.id,
        icon: Icons.link,
        onTap: onTap != null ? () => onTap(link.id) : null,
      ),
  ];
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
