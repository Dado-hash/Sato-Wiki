import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/content/domain/content_models.dart';
import '../../../core/localization/content_labels.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/sato_colors.dart';
import '../../../core/widgets/status_pill.dart';
import '../../../generated/l10n/app_localizations.dart';

/// Subcategory keys in the order they are listed. Unknown keys follow them,
/// alphabetically.
const _subcategoryOrder = [
  'nodes',
  'software-wallets',
  'lightning',
  'servers',
  'node-systems',
  'mining-software',
  'developer-tools',
  'hardware-wallets',
  'seed-backups',
  'mining-hardware',
  'node-hardware',
];

/// Fixed order for known subcategories, alphabetical for the others.
int compareSubcategoryKeys(String a, String b) {
  final indexA = _subcategoryOrder.indexOf(a);
  final indexB = _subcategoryOrder.indexOf(b);
  if (indexA != -1 || indexB != -1) {
    if (indexA == -1) return 1;
    if (indexB == -1) return -1;
    return indexA.compareTo(indexB);
  }

  return a.compareTo(b);
}

IconData iconForSubcategory(String subcategory) {
  return switch (subcategory.toLowerCase()) {
    'nodes' => Icons.hub_outlined,
    'software-wallets' => Icons.account_balance_wallet_outlined,
    'lightning' => Icons.bolt_outlined,
    'servers' => Icons.dns_outlined,
    'node-systems' => Icons.home_outlined,
    'mining-software' => Icons.construction_outlined,
    'developer-tools' => Icons.code_outlined,
    'hardware-wallets' => Icons.usb_outlined,
    'seed-backups' => Icons.edit_note_outlined,
    'mining-hardware' => Icons.memory_outlined,
    'node-hardware' => Icons.storage_outlined,
    _ => Icons.article_outlined,
  };
}

/// Bordered card used by the wiki tree lists and rows.
class WikiCardSurface extends StatelessWidget {
  const WikiCardSurface({required this.onTap, required this.child, super.key});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: InkWell(onTap: onTap, child: child),
    );
  }
}

/// Accent icon on a soft orange tile.
class WikiIconTile extends StatelessWidget {
  const WikiIconTile({required this.icon, this.size = 40, super.key});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.sato.accentTint,
        borderRadius: BorderRadius.circular(AppRadii.thumb),
      ),
      child: Icon(icon, size: 22, color: colorScheme.primary),
    );
  }
}

/// One subcategory in a category: icon, name, a short description and chevron.
class WikiSubcategoryRow extends StatelessWidget {
  const WikiSubcategoryRow({
    required this.subcategory,
    required this.onTap,
    this.description,
    super.key,
  });

  final String subcategory;
  final String? description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return WikiCardSurface(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            WikiIconTile(icon: iconForSubcategory(subcategory)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    contentSubcategoryLabel(subcategory, l10n),
                    style: textTheme.titleMedium,
                  ),
                  if (description != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      description!,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

/// Plain outlined label for facts such as "Open source" or a platform list.
class WikiInfoPill extends StatelessWidget {
  const WikiInfoPill({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final labelStyle = Theme.of(context).textTheme.labelSmall;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: labelStyle?.copyWith(color: colorScheme.onSurfaceVariant),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// Status pill for a product, with the status text next to the dot.
class ProductStatusPill extends StatelessWidget {
  const ProductStatusPill({required this.status, super.key});

  final ProductStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sato = context.sato;

    return switch (status) {
      ProductStatus.active => StatusPill(
        label: l10n.wikiTreeStatusActive,
        color: sato.statusDeployed,
      ),
      ProductStatus.discontinued => StatusPill(
        label: l10n.wikiTreeStatusDiscontinued,
        color: sato.statusClosed,
      ),
    };
  }
}

/// "Checked on [date]" with a check mark, shown only when a review date exists.
class CheckedOnLine extends StatelessWidget {
  const CheckedOnLine({required this.date, super.key});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final formatted = DateFormat.yMMMd(l10n.localeName).format(date);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check_rounded, size: 16, color: context.sato.statusDeployed),
        const SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Text(
            l10n.wikiTreeCheckedOn(formatted),
            style: textTheme.labelMedium,
          ),
        ),
      ],
    );
  }
}

/// Puts [gap] between consecutive widgets.
List<Widget> spaced(List<Widget> widgets, double gap) {
  return [
    for (var i = 0; i < widgets.length; i++) ...[
      if (i > 0) SizedBox(height: gap),
      widgets[i],
    ],
  ];
}
