import 'package:flutter/material.dart';

/// Uppercase accent label followed by meta parts, separated by middle dots.
class MetaLine extends StatelessWidget {
  const MetaLine({this.label, this.parts = const [], super.key});

  final String? label;
  final List<String> parts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    final items = <Widget>[
      if (label != null)
        Text(
          label!.toUpperCase(),
          style: textTheme.labelSmall?.copyWith(color: colorScheme.primary),
        ),
      for (final part in parts) Text(part, style: textTheme.labelMedium),
    ];

    final children = <Widget>[];
    for (var index = 0; index < items.length; index++) {
      if (index > 0) {
        children.add(
          ExcludeSemantics(child: Text('·', style: textTheme.labelMedium)),
        );
      }
      children.add(items[index]);
    }

    return Wrap(
      spacing: 8,
      runSpacing: 2,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
  }
}
