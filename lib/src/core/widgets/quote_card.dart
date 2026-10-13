import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../content/domain/content_models.dart';
import '../theme/app_tokens.dart';
import '../../generated/l10n/app_localizations.dart';
import 'external_url.dart';

/// A quote with its author, date and a link to the source. The English
/// original is shown under the translation when the bundle is not in English.
class QuoteCard extends StatelessWidget {
  const QuoteCard({required this.quote, super.key});

  final Quote quote;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final original = quote.originalText;

    return Material(
      color: colorScheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.learnQuote.toUpperCase(),
              style: textTheme.labelSmall?.copyWith(color: colorScheme.primary),
            ),
            const SizedBox(height: 10),
            Text(
              '“${quote.text}”',
              style: textTheme.titleMedium?.copyWith(height: 1.35),
            ),
            if (original != null) ...[
              const SizedBox(height: 8),
              Text(
                original,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              '${quote.author} · '
              '${DateFormat.yMMMd(l10n.localeName).format(quote.date)}',
              style: textTheme.labelMedium,
            ),
            const SizedBox(height: 2),
            Text(
              quote.sourceTitle,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                style: TextButton.styleFrom(minimumSize: const Size(44, 44)),
                onPressed: () => openExternalUrl(context, quote.sourceUrl),
                child: Text(l10n.learnSource),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
