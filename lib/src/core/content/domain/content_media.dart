import 'package:markdown/markdown.dart' as markdown;

import 'content_models.dart';

typedef ContentMediaLookup = Uri? Function(String source);

Uri? _emptyMediaLookup(String source) => null;

final class ContentMediaResolver {
  const ContentMediaResolver({required this.resolve});

  final ContentMediaLookup resolve;

  static const empty = ContentMediaResolver(resolve: _emptyMediaLookup);
}

final class ContentMediaReference {
  const ContentMediaReference({
    required this.source,
    required this.alt,
    this.title,
  });

  final String source;
  final String alt;
  final String? title;
}

final class ContentMediaValidationError {
  const ContentMediaValidationError({
    required this.source,
    required this.message,
  });

  final String source;
  final String message;
}

abstract final class ContentMedia {
  static const supportedExtensions = <String>{
    '.jpeg',
    '.jpg',
    '.png',
    '.svg',
    '.webp',
  };

  static List<ContentMediaReference> referencesFromBundle(
    ContentBundle bundle,
  ) {
    final references = <ContentMediaReference>[];

    for (final entry in bundle.wiki) {
      final coverImage = entry.coverImage;
      if (coverImage != null) {
        references.add(
          ContentMediaReference(
            source: coverImage.toString(),
            alt: entry.title,
            title: entry.description,
          ),
        );
      }
      for (final level in entry.readingLevels.values) {
        references.addAll(referencesFromMarkdown(level.bodyMarkdown));
      }
    }
    for (final article in bundle.news) {
      references.addAll(referencesFromMarkdown(article.bodyMarkdown));
    }
    for (final event in bundle.history) {
      references.addAll(referencesFromMarkdown(event.bodyMarkdown));
    }
    for (final bip in bundle.bips) {
      references.addAll(referencesFromMarkdown(bip.summaryMarkdown));
      references.addAll(referencesFromMarkdown(bip.impactMarkdown));
    }
    for (final release in bundle.changelogs) {
      references.addAll(referencesFromMarkdown(release.userImpactMarkdown));
      references.addAll(
        referencesFromMarkdown(release.technicalChangesMarkdown),
      );
    }

    return List.unmodifiable(references);
  }

  static List<ContentMediaReference> referencesFromMarkdown(String source) {
    final document = markdown.Document(
      extensionSet: markdown.ExtensionSet.gitHubFlavored,
    );
    final nodes = document.parseLines(source.split('\n'));
    final references = <ContentMediaReference>[];

    void visit(markdown.Node node) {
      if (node is markdown.Element) {
        if (node.tag == 'img') {
          references.add(
            ContentMediaReference(
              source: node.attributes['src']?.trim() ?? '',
              alt: node.attributes['alt']?.trim() ?? '',
              title: node.attributes['title']?.trim(),
            ),
          );
        }

        for (final child in node.children ?? const <markdown.Node>[]) {
          visit(child);
        }
      }
    }

    for (final node in nodes) {
      visit(node);
    }

    return List.unmodifiable(references);
  }

  static List<ContentMediaValidationError> validateReferences(
    Iterable<ContentMediaReference> references,
  ) {
    final errors = <ContentMediaValidationError>[];
    for (final reference in references) {
      final sourceError = validateSource(reference.source);
      if (sourceError != null) {
        errors.add(
          ContentMediaValidationError(
            source: reference.source,
            message: sourceError,
          ),
        );
      }
      if (reference.alt.trim().isEmpty) {
        errors.add(
          ContentMediaValidationError(
            source: reference.source,
            message: 'Image alt text is required.',
          ),
        );
      }
    }

    return List.unmodifiable(errors);
  }

  static String? validateSource(String source) {
    final trimmed = source.trim();
    if (trimmed.isEmpty) {
      return 'Image source is required.';
    }

    final uri = Uri.tryParse(trimmed);
    if (uri == null ||
        uri.hasScheme ||
        uri.hasAuthority ||
        uri.query.isNotEmpty ||
        uri.fragment.isNotEmpty) {
      return 'Image source must be a relative media path.';
    }
    if (!uri.path.startsWith('media/')) {
      return 'Image source must start with media/.';
    }
    if (uri.pathSegments.any((segment) => segment == '..')) {
      return 'Image source must not contain .. segments.';
    }
    if (!supportedExtensions.contains(extensionFor(uri.path))) {
      return 'Image extension must be one of '
          '${supportedExtensions.join(', ')}.';
    }

    return null;
  }

  static String extensionFor(String path) {
    final lowerPath = path.toLowerCase();
    final dotIndex = lowerPath.lastIndexOf('.');
    if (dotIndex < 0) {
      return '';
    }

    return lowerPath.substring(dotIndex);
  }
}
