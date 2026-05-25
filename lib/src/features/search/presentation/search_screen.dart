import 'package:flutter/material.dart';

import '../../../generated/l10n/app_localizations.dart';
import '../../../core/localization/localized_labels.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/search/search_index.dart';
import '../../../core/widgets/content_card.dart';
import '../../../core/widgets/filter_chip_bar.dart';
import '../../../core/widgets/metadata_row.dart';
import '../../../core/widgets/reader_header.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({required this.searchIndex, super.key});

  final SearchIndex searchIndex;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _query = '';
  SearchSection? _section;

  @override
  Widget build(BuildContext context) {
    final results = widget.searchIndex.search(
      _query,
      sections: _section == null ? null : {_section!},
    );
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.searchTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ReaderHeader(title: l10n.searchTitle, subtitle: l10n.searchSubtitle),
          const SizedBox(height: 16),
          SearchBar(
            hintText: l10n.searchHint,
            leading: const Icon(Icons.search),
            onChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: 16),
          FilterChipBar<SearchSection?>(
            items: const [
              null,
              SearchSection.wiki,
              SearchSection.news,
              SearchSection.history,
              SearchSection.code,
            ],
            selectedItem: _section,
            labelFor: (section) =>
                section == null ? l10n.all : section.label(l10n),
            onSelected: (section) => setState(() => _section = section),
          ),
          const SizedBox(height: 16),
          if (_query.isNotEmpty && results.isEmpty)
            ContentCard(child: Text(l10n.noLocalResultFound)),
          for (final result in results) ...[
            ContentCard(
              onTap: () => Navigator.of(context).pushNamed(result.route),
              trailing: const Icon(Icons.chevron_right),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(result.summary),
                  const SizedBox(height: 10),
                  MetadataRow(
                    items: [
                      MetadataItem(label: result.section.label(l10n)),
                      for (final tag in result.tags)
                        MetadataItem(label: '#$tag', isTag: true),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (_query.isEmpty)
            ContentCard(
              onTap: () {
                Navigator.of(
                  context,
                ).pushNamed(AppRoutes.wikiEntry('proof-of-work'));
              },
              child: Text(l10n.trySearchExamples),
            ),
        ],
      ),
    );
  }
}
