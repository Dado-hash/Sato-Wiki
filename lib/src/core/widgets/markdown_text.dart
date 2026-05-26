import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../content/domain/content_media.dart';
import 'content_media_scope.dart';

class MarkdownText extends StatelessWidget {
  const MarkdownText(this.markdown, {this.mediaResolver, super.key});

  final String markdown;
  final ContentMediaResolver? mediaResolver;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return MarkdownBody(
      data: markdown,
      selectable: false,
      styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
        a: textTheme.bodyLarge?.copyWith(
          color: colorScheme.primary,
          decoration: TextDecoration.underline,
          decorationColor: colorScheme.primary,
        ),
        p: textTheme.bodyLarge?.copyWith(height: 1.6),
        h1: textTheme.headlineMedium,
        h2: textTheme.titleLarge,
        h3: textTheme.titleMedium,
        code: textTheme.bodyMedium?.copyWith(fontFamily: 'JetBrains Mono'),
        blockquote: textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        blockquoteDecoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: colorScheme.primary, width: 3),
          ),
        ),
        blockquotePadding: const EdgeInsets.only(left: 16),
        codeblockDecoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        codeblockPadding: const EdgeInsets.all(16),
        blockSpacing: 16,
      ),
      imageBuilder: (uri, title, alt) {
        return _MarkdownImageFigure(
          source: uri.toString(),
          alt: alt,
          title: title,
          resolver:
              mediaResolver ??
              ContentMediaScope.maybeOf(context) ??
              ContentMediaResolver.empty,
        );
      },
    );
  }
}

class _MarkdownImageFigure extends StatelessWidget {
  const _MarkdownImageFigure({
    required this.source,
    required this.resolver,
    this.alt,
    this.title,
  });

  final String source;
  final String? alt;
  final String? title;
  final ContentMediaResolver resolver;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final semanticLabel = (alt?.trim().isNotEmpty ?? false)
        ? alt!.trim()
        : source;
    final caption = title?.trim();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            container: true,
            label: semanticLabel,
            image: true,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _resolvedImage(context),
              ),
            ),
          ),
          if (caption != null && caption.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              caption,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontFamily: 'JetBrains Mono',
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _resolvedImage(BuildContext context) {
    final resolvedUri = resolver.resolve(source);
    if (resolvedUri == null || resolvedUri.scheme != 'file') {
      return _ImagePlaceholder(label: source);
    }

    final file = File.fromUri(resolvedUri);
    final extension = ContentMedia.extensionFor(file.path);
    final image = extension == '.svg'
        ? SvgPicture.file(
            file,
            fit: BoxFit.contain,
            placeholderBuilder: (_) => _ImagePlaceholder(label: source),
          )
        : Image.file(
            file,
            fit: BoxFit.contain,
            semanticLabel: alt,
            errorBuilder: (_, _, _) => _ImagePlaceholder(label: source),
          );

    return SizedBox(width: double.infinity, height: 220, child: image);
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: double.infinity,
      height: 160,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.image_not_supported_outlined,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontFamily: 'JetBrains Mono',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
