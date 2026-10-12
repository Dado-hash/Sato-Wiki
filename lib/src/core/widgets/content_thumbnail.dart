import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../content/domain/content_media.dart';
import '../theme/app_tokens.dart';
import 'content_media_scope.dart';

/// Cover image for a content record, resolved through [ContentMediaScope].
/// Shows [fallbackIcon] on a raised tile when there is no usable file.
class ContentThumbnail extends StatelessWidget {
  const ContentThumbnail({
    required this.source,
    this.width,
    this.height,
    this.aspectRatio,
    this.borderRadius = AppRadii.thumb,
    this.fallbackIcon = Icons.article_outlined,
    this.semanticLabel,
    super.key,
  });

  final String? source;
  final double? width;
  final double? height;
  final double? aspectRatio;
  final double borderRadius;
  final IconData fallbackIcon;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final resolver =
        ContentMediaScope.maybeOf(context) ?? ContentMediaResolver.empty;

    final fallback = ColoredBox(
      color: colorScheme.surfaceContainerHigh,
      child: Center(
        child: Icon(
          fallbackIcon,
          size: 24,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );

    Widget image = fallback;
    final currentSource = source;
    if (currentSource != null) {
      final resolvedUri = resolver.resolve(currentSource);
      if (resolvedUri != null && resolvedUri.scheme == 'file') {
        final file = File.fromUri(resolvedUri);
        image = ContentMedia.extensionFor(file.path) == '.svg'
            ? SvgPicture.file(
                file,
                fit: BoxFit.cover,
                placeholderBuilder: (_) => fallback,
              )
            : Image.file(
                file,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => fallback,
              );
      }
    }

    final sized = aspectRatio != null
        ? AspectRatio(aspectRatio: aspectRatio!, child: image)
        : SizedBox(width: width, height: height, child: image);

    final clipped = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: sized,
    );

    if (semanticLabel != null) {
      return Semantics(image: true, label: semanticLabel, child: clipped);
    }

    return ExcludeSemantics(child: clipped);
  }
}
