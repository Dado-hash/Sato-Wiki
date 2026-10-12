import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// Read-only tag label shown under long-form content.
class TagPill extends StatelessWidget {
  const TagPill({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 7,
        ),
        child: Text(label, style: Theme.of(context).textTheme.bodySmall),
      ),
    );
  }
}
