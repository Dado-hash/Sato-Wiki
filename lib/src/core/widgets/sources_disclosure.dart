import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../generated/l10n/app_localizations.dart';

class SourcesDisclosure extends StatelessWidget {
  const SourcesDisclosure({required this.sources, this.title, super.key});

  final String? title;
  final List<SourceReference> sources;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Icon(Icons.menu_book_outlined, color: colorScheme.primary),
        title: Text(
          title ?? l10n.sourcesAndReferences,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        children: [
          Divider(height: 1, color: colorScheme.outlineVariant),
          const SizedBox(height: 12),
          for (final source in sources)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: source.url == null
                    ? null
                    : () => launchUrl(
                        source.url!,
                        mode: LaunchMode.externalApplication,
                      ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.link,
                        size: 18,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            text: source.title,
                            style: textTheme.bodyMedium?.copyWith(
                              color: source.url == null
                                  ? colorScheme.onSurface
                                  : colorScheme.primary,
                              decoration: source.url == null
                                  ? TextDecoration.none
                                  : TextDecoration.underline,
                              decorationColor: colorScheme.outlineVariant,
                            ),
                            children: [
                              if (source.author != null)
                                TextSpan(
                                  text: ' - ${source.author}',
                                  style: textTheme.bodyMedium,
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (source.url != null) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.open_in_new,
                          size: 16,
                          color: colorScheme.onSurfaceVariant,
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
