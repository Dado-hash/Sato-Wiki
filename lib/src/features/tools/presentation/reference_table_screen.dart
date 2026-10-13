import 'package:flutter/material.dart';

import '../../../core/content/domain/content_models.dart';
import '../../../core/content/domain/content_store.dart';
import '../../../core/navigation/content_routes.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/content_mappers.dart';
import '../../../core/widgets/detail_scaffold.dart';
import '../../../core/widgets/filter_chip_bar.dart';
import '../../../core/widgets/sources_disclosure.dart';
import '../../../generated/l10n/app_localizations.dart';
import 'tool_widgets.dart';

/// Column whose values filter the rows with chips, when the table has it.
const String _statusKey = 'status';

/// One reference table. Rows are cards on a phone: the first column is the
/// title and the other columns are label and value lines. A text filter
/// matches any cell, and the opcode table also has status chips.
class ReferenceTableScreen extends StatefulWidget {
  const ReferenceTableScreen({
    required this.store,
    required this.slug,
    super.key,
  });

  final ContentStore store;
  final String slug;

  @override
  State<ReferenceTableScreen> createState() => _ReferenceTableScreenState();
}

class _ReferenceTableScreenState extends State<ReferenceTableScreen> {
  final _filter = TextEditingController();
  String? _status;

  @override
  void dispose() {
    _filter.dispose();
    super.dispose();
  }

  ReferenceTable? get _table {
    return widget.store.bundle.references
        .where((table) => table.slug == widget.slug)
        .firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final table = _table;
    if (table == null) {
      return DetailScaffold(
        title: l10n.routeNotFound,
        children: [
          Text(widget.slug, style: Theme.of(context).textTheme.labelMedium),
        ],
      );
    }

    final hasStatus = table.columns.any((column) => column.key == _statusKey);
    final statuses = _statusValues(table);
    final rows = _visibleRows(table);
    final textTheme = Theme.of(context).textTheme;

    return DetailScaffold(
      title: table.title,
      children: [
        Text(table.description, style: textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.toolsRowCount(table.rows.length),
          style: textTheme.labelMedium,
        ),
        const SizedBox(height: AppSpacing.lg),
        ToolTextField(
          controller: _filter,
          hintText: l10n.toolsReferenceFilterHint,
          onChanged: (_) => setState(() {}),
        ),
        if (hasStatus && statuses.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          FilterChipBar<String?>(
            items: [null, ...statuses],
            selectedItem: _status,
            labelFor: (status) => status ?? l10n.all,
            onSelected: (status) => setState(() => _status = status),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        if (rows.isEmpty)
          Text(l10n.toolsReferenceNoMatch, style: textTheme.bodyMedium)
        else
          for (final row in rows) ...[
            _RowCard(store: widget.store, columns: table.columns, row: row),
            const SizedBox(height: AppSpacing.md),
          ],
        if (table.sources.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          SourcesDisclosure(sources: sourceReferences(table.sources)),
        ],
      ],
    );
  }

  /// Rows that match the status chip and the text filter.
  List<ReferenceRow> _visibleRows(ReferenceTable table) {
    final query = _filter.text.trim().toLowerCase();
    final status = _status;

    return [
      for (final row in table.rows)
        if (status == null || row.cells[_statusKey] == status)
          if (query.isEmpty ||
              row.cells.values.any(
                (value) => value.toLowerCase().contains(query),
              ))
            row,
    ];
  }
}

/// Route for a row link. A wiki link is shown only when its entry is loaded.
String? _rowRoute(ContentStore store, String? link) {
  if (link == null) {
    return null;
  }
  if (link.startsWith('wiki.') && recordTitleFor(store, link) == null) {
    return null;
  }

  return routeForContentId(link);
}

/// Distinct values of the status column, in the order they first appear.
List<String> _statusValues(ReferenceTable table) {
  final values = <String>{
    for (final row in table.rows)
      if (row.cells[_statusKey] != null) row.cells[_statusKey]!,
  };

  return values.toList(growable: false);
}

class _RowCard extends StatelessWidget {
  const _RowCard({
    required this.store,
    required this.columns,
    required this.row,
  });

  final ContentStore store;
  final List<ReferenceColumn> columns;
  final ReferenceRow row;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final titleColumn = columns.first;
    final otherColumns = columns.skip(1);
    final route = _rowRoute(store, row.link);

    final content = Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.cells[titleColumn.key] ?? '',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                for (final column in otherColumns)
                  if ((row.cells[column.key] ?? '').isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      column.label,
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      row.cells[column.key]!,
                      style: _valueStyle(context, column.key),
                    ),
                  ],
              ],
            ),
          ),
          if (route != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ],
      ),
    );

    return Material(
      color: colorScheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: route == null
          ? content
          : InkWell(
              onTap: () => Navigator.of(context).pushNamed(route),
              child: content,
            ),
    );
  }

  /// Hex, numbers and names use the monospace face. Prose uses the body face.
  TextStyle? _valueStyle(BuildContext context, String key) {
    final textTheme = Theme.of(context).textTheme;
    if (key == 'hex' || key == 'size' || key == 'value') {
      return toolMonoStyle(context, size: 13);
    }

    return textTheme.bodyMedium;
  }
}
