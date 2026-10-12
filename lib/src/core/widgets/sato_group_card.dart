import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// One card holding rows separated by 1 px dividers.
class SatoGroupCard extends StatelessWidget {
  const SatoGroupCard({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final rows = <Widget>[];
    for (var index = 0; index < children.length; index++) {
      if (index > 0) {
        rows.add(
          Divider(height: 1, thickness: 1, color: colorScheme.outlineVariant),
        );
      }
      rows.add(children[index]);
    }

    return Material(
      color: colorScheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: rows,
      ),
    );
  }
}
