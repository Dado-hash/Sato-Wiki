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
        return ContentImageFigure(
          source: uri.toString(),
          alt: alt,
          title: title,
          mediaResolver:
              mediaResolver ??
              ContentMediaScope.maybeOf(context) ??
              ContentMediaResolver.empty,
        );
      },
    );
  }
}

class ContentImageFigure extends StatelessWidget {
  const ContentImageFigure({
    required this.source,
    this.mediaResolver,
    this.alt,
    this.title,
    this.aspectRatio,
    this.height = 220,
    this.showCaption = true,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
    this.fit = BoxFit.contain,
    super.key,
  });

  final String source;
  final String? alt;
  final String? title;
  final ContentMediaResolver? mediaResolver;
  final double? aspectRatio;
  final double height;
  final bool showCaption;
  final EdgeInsetsGeometry padding;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final resolver =
        mediaResolver ??
        ContentMediaScope.maybeOf(context) ??
        ContentMediaResolver.empty;
    final semanticLabel = (alt?.trim().isNotEmpty ?? false)
        ? alt!.trim()
        : source;
    final caption = title?.trim();
    final resolvedUri = resolver.resolve(source);
    final VoidCallback? openImage =
        resolvedUri != null && resolvedUri.scheme == 'file'
        ? () => _openFullScreen(context, resolvedUri, semanticLabel)
        : null;
    final canOpen = openImage != null;
    final image = _resolvedImage(context, resolvedUri);

    Widget imageBox = Semantics(
      container: true,
      label: semanticLabel,
      image: true,
      button: canOpen,
      onTap: openImage,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: _sizedImage(image),
      ),
    );

    if (canOpen) {
      imageBox = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: openImage,
        child: imageBox,
      );
    }

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          imageBox,
          if (showCaption && caption != null && caption.isNotEmpty) ...[
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

  Widget _sizedImage(Widget child) {
    if (aspectRatio != null) {
      return AspectRatio(aspectRatio: aspectRatio!, child: child);
    }

    return SizedBox(width: double.infinity, height: height, child: child);
  }

  Widget _resolvedImage(BuildContext context, Uri? resolvedUri) {
    if (resolvedUri == null || resolvedUri.scheme != 'file') {
      return _FramedImagePlaceholder(label: source);
    }

    final file = File.fromUri(resolvedUri);
    final extension = ContentMedia.extensionFor(file.path);
    return _ContentImageFile(
      file: file,
      extension: extension,
      fit: fit,
      semanticLabel: alt,
      placeholder: _FramedImagePlaceholder(label: source),
    );
  }

  void _openFullScreen(
    BuildContext context,
    Uri resolvedUri,
    String semanticLabel,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => _ContentImageFullScreen(
          file: File.fromUri(resolvedUri),
          semanticLabel: semanticLabel,
        ),
      ),
    );
  }
}

class _ContentImageFile extends StatelessWidget {
  const _ContentImageFile({
    required this.file,
    required this.extension,
    required this.fit,
    required this.placeholder,
    this.semanticLabel,
  });

  final File file;
  final String extension;
  final BoxFit fit;
  final Widget placeholder;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    if (extension == '.svg') {
      return SvgPicture.file(
        file,
        fit: fit,
        placeholderBuilder: (_) => placeholder,
      );
    }

    return Image.file(
      file,
      fit: fit,
      semanticLabel: semanticLabel,
      errorBuilder: (_, _, _) => placeholder,
    );
  }
}

class _ContentImageFullScreen extends StatelessWidget {
  const _ContentImageFullScreen({
    required this.file,
    required this.semanticLabel,
  });

  final File file;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final extension = ContentMedia.extensionFor(file.path);
    final closeTooltip = MaterialLocalizations.of(context).closeButtonTooltip;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          tooltip: closeTooltip,
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _ContentImageFile(
                    file: file,
                    extension: extension,
                    fit: BoxFit.contain,
                    semanticLabel: semanticLabel,
                    placeholder: _ImagePlaceholder(label: semanticLabel),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FramedImagePlaceholder extends StatelessWidget {
  const _FramedImagePlaceholder({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: _ImagePlaceholder(label: label),
    );
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
