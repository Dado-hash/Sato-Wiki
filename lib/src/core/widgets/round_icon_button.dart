import 'package:flutter/material.dart';

/// 44 px circle button on the card background with an outline border.
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.selected = false,
    super.key,
  }) : child = null;

  const RoundIconButton.child({
    required this.child,
    required this.tooltip,
    this.onPressed,
    super.key,
  }) : icon = null,
       selected = false;

  final IconData? icon;
  final Widget? child;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final content =
        child ??
        Icon(
          icon,
          size: 20,
          color: selected ? colorScheme.primary : colorScheme.onSurface,
        );

    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        enabled: onPressed != null,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Material(
            color: colorScheme.surfaceContainerLow,
            shape: CircleBorder(
              side: BorderSide(color: colorScheme.outlineVariant),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onPressed,
              child: Center(child: content),
            ),
          ),
        ),
      ),
    );
  }
}
