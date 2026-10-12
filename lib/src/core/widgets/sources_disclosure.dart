import 'package:flutter/material.dart';

import '../../generated/l10n/app_localizations.dart';
import '../theme/app_tokens.dart';
import 'external_url.dart';

class SourcesDisclosure extends StatelessWidget {
  const SourcesDisclosure({required this.sources, this.title, super.key});

  final String? title;
  final List<SourceReference> sources;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return Material(
      color: colorScheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        childrenPadding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        shape: const Border(),
        collapsedShape: const Border(),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title ?? l10n.sourcesAndReferences,
                style: textTheme.titleSmall,
              ),
            ),
            Text('${sources.length}', style: textTheme.labelMedium),
          ],
        ),
        children: [
          for (final source in sources)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadii.thumb),
                onTap: source.url == null
                    ? null
                    : () => openExternalUrl(context, source.url!),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 44),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.link,
                          size: 18,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              source.title,
                              style: textTheme.bodyMedium?.copyWith(
                                color: source.url == null
                                    ? colorScheme.onSurface
                                    : colorScheme.primary,
                              ),
                            ),
                            if (source.author != null)
                              Text(source.author!, style: textTheme.bodySmall),
                          ],
                        ),
                      ),
                      if (source.url != null) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.open_in_new,
                            size: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class SourceReference {
  const SourceReference({required this.title, this.author, this.url});

  final String title;
  final String? author;
  final Uri? url;
}
