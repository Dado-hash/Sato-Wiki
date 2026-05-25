import 'package:flutter/material.dart';

class ContentCard extends StatelessWidget {
  const ContentCard({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.trailing,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(8);
    final colorScheme = Theme.of(context).colorScheme;
    final content = trailing == null
        ? child
        : Row(
            children: [
              Expanded(child: child),
              const SizedBox(width: 12),
              IconTheme.merge(
                data: IconThemeData(color: colorScheme.onSurfaceVariant),
                child: trailing!,
              ),
            ],
          );

    return Card(
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: Padding(padding: padding, child: content),
      ),
    );
  }
}
