import 'package:flutter/material.dart';

import '../../../core/content/domain/content_store.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/detail_scaffold.dart';
import '../../../core/widgets/sato_group_card.dart';
import '../../../generated/l10n/app_localizations.dart';

/// Lists the reference tables of the loaded bundle: title, description and
/// number of rows. Each row opens the table.
class ReferenceListScreen extends StatelessWidget {
  const ReferenceListScreen({required this.store, super.key});

  final ContentStore store;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tables = store.bundle.references;

    return DetailScaffold(
      title: l10n.toolsReferencesTitle,
      children: [
        if (tables.isEmpty)
          Text(
            l10n.toolsReferencesEmpty,
            style: Theme.of(context).textTheme.bodyMedium,
          )
        else
          SatoGroupCard(
            children: [
              for (final table in tables)
                _TableRow(
                  title: table.title,
                  description: table.description,
                  rowCount: table.rows.length,
                  onTap: () => Navigator.of(
                    context,
                  ).pushNamed(AppRoutes.reference(table.slug)),
                ),
            ],
          ),
      ],
    );
  }
}

class _TableRow extends StatelessWidget {
  const _TableRow({
    required this.title,
    required this.description,
    required this.rowCount,
    required this.onTap,
  });

  final String title;
  final String description;
  final int rowCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: 14,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(description, style: textTheme.bodySmall),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.toolsRowCount(rowCount),
                    style: textTheme.labelMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
