import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

class MetadataRow extends StatelessWidget {
  const MetadataRow({required this.items, this.wrap = true, super.key});

  final List<MetadataItem> items;
  final bool wrap;

  @override
  Widget build(BuildContext context) {
    final chips = [for (final item in items) _MetadataChip(item: item)];

    if (wrap) {
      return Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: chips,
      );
    }

    return Row(
      children: [
        for (var index = 0; index < chips.length; index++) ...[
          chips[index],
          if (index < chips.length - 1) const SizedBox(width: AppSpacing.sm),
        ],
      ],
    );
  }
}

class MetadataItem {
  const MetadataItem({required this.label, this.icon, this.isTag = false});

  final String label;
  final IconData? icon;
  final bool isTag;
}

class _MetadataChip extends StatelessWidget {
  const _MetadataChip({required this.item});

  final MetadataItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final foreground = item.isTag
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: SizedBox(
        height: 32,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 7,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (item.icon != null) ...[
                Icon(item.icon, size: 16, color: foreground),
                const SizedBox(width: 6),
              ],
              Text(
                item.label,
                style: textTheme.bodySmall?.copyWith(color: foreground),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
