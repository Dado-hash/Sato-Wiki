import 'package:flutter/material.dart';

import '../../../core/localization/localized_labels.dart';
import '../../../core/search/search_index.dart';
import '../../../core/settings/app_settings_controller.dart';
import '../../../core/settings/app_settings_scope.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/filter_chip_bar.dart';
import '../../../core/widgets/round_icon_button.dart';
import '../../../core/widgets/sato_group_card.dart';
import '../../../generated/l10n/app_localizations.dart';

const _suggestedTerms = [
  'Proof of Work',
  'Taproot',
  'Lightning Network',
  'Halving',
  'Pizza Day',
];

const _maxRowsPerGroup = 8;

class SearchScreen extends StatefulWidget {
  const SearchScreen({required this.searchIndex, super.key});

  final SearchIndex searchIndex;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  SearchSection? _section;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChanged() => setState(() {});

  void _clearQuery() {
    _controller.clear();
    _focusNode.requestFocus();
    setState(() {});
  }

  void _runQuery(String text) {
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    setState(() {});
  }

  void _openResult(
    SearchResult result,
    String query,
    AppSettingsController? settings,
  ) {
    settings?.addRecentSearch(query);
    Navigator.of(context).pushNamed(result.route);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = AppSettingsScope.maybeOf(context);
    final query = _controller.text.trim();
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                8,
                AppSpacing.gutter,
                0,
              ),
              child: Row(
                children: [
                  RoundIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    tooltip: l10n.back,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: _buildField(context, l10n, settings)),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.gutter),
              child: FilterChipBar<SearchSection?>(
                items: [null, ...SearchSection.values],
                selectedItem: _section,
                labelFor: (section) =>
                    section == null ? l10n.all : section.label(l10n),
                onSelected: (section) => setState(() => _section = section),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.gutter,
                  8,
                  AppSpacing.gutter,
                  32 + bottomPadding,
                ),
                children: query.isEmpty
                    ? _buildStartContent(context, l10n, settings)
                    : _buildResultContent(context, l10n, query, settings),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    BuildContext context,
    AppLocalizations l10n,
    AppSettingsController? settings,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasText = _controller.text.isNotEmpty;

    return Container(
      height: 48,
      padding: const EdgeInsets.only(left: 16, right: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(
          color: _focusNode.hasFocus
              ? colorScheme.primary
              : colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            size: 20,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: true,
              textInputAction: TextInputAction.search,
              style: textTheme.bodyMedium?.copyWith(fontSize: 16),
              decoration: InputDecoration.collapsed(
                hintText: l10n.searchHint,
                hintStyle: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: (value) => settings?.addRecentSearch(value),
            ),
          ),
          if (hasText)
            _ClearButton(tooltip: l10n.clearSearch, onPressed: _clearQuery),
        ],
      ),
    );
  }

  List<Widget> _buildStartContent(
    BuildContext context,
    AppLocalizations l10n,
    AppSettingsController? settings,
  ) {
    final recent = settings?.recentSearches ?? const <String>[];

    return [
      if (recent.isNotEmpty) ...[
        _GroupLabel(
          text: l10n.recentSearches,
          trailing: TextButton(
            onPressed: () => settings?.clearRecentSearches(),
            child: Text(l10n.clearRecentSearches),
          ),
        ),
        _PillWrap(terms: recent, onTap: _runQuery),
      ],
      _GroupLabel(text: l10n.suggestedSearches),
      _PillWrap(terms: _suggestedTerms, onTap: _runQuery),
    ];
  }

  List<Widget> _buildResultContent(
    BuildContext context,
    AppLocalizations l10n,
    String query,
    AppSettingsController? settings,
  ) {
    final results = widget.searchIndex.search(
      query,
      sections: _section == null ? null : {_section!},
    );
    if (results.isEmpty) {
      return [_EmptyResults(message: l10n.noResultsFor(query))];
    }

    final groups = <Widget>[];
    for (final section in SearchSection.values) {
      final sectionResults = [
        for (final result in results)
          if (result.section == section) result,
      ];
      if (sectionResults.isEmpty) {
        continue;
      }

      final shown = _section == null
          ? sectionResults.take(_maxRowsPerGroup)
          : sectionResults;
      groups
        ..add(_GroupLabel(text: section.label(l10n)))
        ..add(
          SatoGroupCard(
            children: [
              for (final result in shown)
                _ResultRow(
                  result: result,
                  onTap: () => _openResult(result, query, settings),
                ),
            ],
          ),
        );
    }

    return groups;
  }
}

class _ClearButton extends StatelessWidget {
  const _ClearButton({required this.tooltip, required this.onPressed});

  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Material(
          type: MaterialType.transparency,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: Center(
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel({required this.text, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: 1.2,
    );

    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(text.toUpperCase(), style: labelStyle),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _PillWrap extends StatelessWidget {
  const _PillWrap({required this.terms, required this.onTap});

  final List<String> terms;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final term in terms)
          _TermPill(label: term, onTap: () => onTap(term)),
      ],
    );
  }
}

class _TermPill extends StatelessWidget {
  const _TermPill({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(AppRadii.pill);

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: SizedBox(
          height: 44,
          child: Center(
            widthFactor: 1,
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: radius,
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Center(
                widthFactor: 1,
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.result, required this.onTap});

  final SearchResult result;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      result.title,
                      style: textTheme.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (result.summary.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        result.summary,
                        style: textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
