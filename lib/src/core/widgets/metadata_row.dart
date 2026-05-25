import 'package:flutter/material.dart';

class MetadataRow extends StatelessWidget {
  const MetadataRow({required this.items, this.wrap = true, super.key});

  final List<MetadataItem> items;
  final bool wrap;

  @override
  Widget build(BuildContext context) {
    final children = [
      for (var index = 0; index < items.length; index++) ...[
        _MetadataChip(item: items[index]),
        if (index < items.length - 1)
          SizedBox(width: wrap ? 8 : 12, height: wrap ? 8 : 0),
      ],
    ];

    if (wrap) {
      return Wrap(spacing: 0, runSpacing: 8, children: children);
    }

    return Row(children: children);
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
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.icon != null) ...[
              Icon(item.icon, size: 16, color: foreground),
              const SizedBox(width: 6),
            ],
            Text(
              item.label,
              style: textTheme.labelMedium?.copyWith(color: foreground),
            ),
          ],
        ),
      ),
    );
  }
}
