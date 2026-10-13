import 'package:flutter/material.dart';

import '../../../core/content/domain/content_models.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/quote_card.dart';
import '../../../core/widgets/section_title.dart';
import '../../../generated/l10n/app_localizations.dart';
import 'wiki_tree_widgets.dart';

/// Most quotes shown at the bottom of a wiki entry.
const wikiRelatedQuoteLimit = 2;

/// Quotes whose related ids include [entryId], at most [wikiRelatedQuoteLimit],
/// in bundle order.
List<Quote> relatedQuotesFor(List<Quote> quotes, String entryId) {
  return [
    for (final quote in quotes)
      if (quote.related.any((link) => link.id == entryId)) quote,
  ].take(wikiRelatedQuoteLimit).toList(growable: false);
}

/// "In their words" block of the wiki reader.
class WikiRelatedQuotes extends StatelessWidget {
  const WikiRelatedQuotes({required this.quotes, super.key});

  final List<Quote> quotes;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle(title: l10n.connectQuotesTitle),
        const SizedBox(height: AppSpacing.md),
        ...spaced([
          for (final quote in quotes) QuoteCard(quote: quote),
        ], AppSpacing.md),
      ],
    );
  }
}
