import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// Thin pill progress bar. [value] is clamped to 0..1 for the fill.
class SatoProgressBar extends StatelessWidget {
  const SatoProgressBar({
    required this.value,
    this.height = 4,
    this.semanticLabel,
    super.key,
  });

  final double value;
  final double height;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final bar = SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: colorScheme.outlineVariant),
            FractionallySizedBox(
              widthFactor: value.clamp(0.0, 1.0).toDouble(),
              alignment: Alignment.centerLeft,
              child: ColoredBox(color: colorScheme.primaryContainer),
            ),
          ],
        ),
      ),
    );

    if (semanticLabel == null) {
      return bar;
    }

    return Semantics(
      label: semanticLabel,
      value: '${(value * 100).round()}%',
      child: bar,
    );
  }
}
