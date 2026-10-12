import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// Pill track with equal segments. The selected segment is filled with
/// the accent container colour.
class SatoSegmentedControl<T> extends StatelessWidget {
  const SatoSegmentedControl({
    required this.items,
    required this.selected,
    required this.labelFor,
    required this.onChanged,
    this.raisedTrack = false,
    super.key,
  });

  final List<T> items;
  final T selected;
  final String Function(T) labelFor;
  final ValueChanged<T> onChanged;
  final bool raisedTrack;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final segments = <Widget>[];
    for (var index = 0; index < items.length; index++) {
      final item = items[index];
      if (index > 0) {
        segments.add(const SizedBox(width: AppSpacing.xs));
      }
      segments.add(
        Expanded(
          child: _Segment(
            label: labelFor(item),
            isSelected: item == selected,
            onTap: () => onChanged(item),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: raisedTrack
            ? colorScheme.surfaceContainerHigh
            : colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: raisedTrack
            ? null
            : Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(children: segments),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final labelStyle = Theme.of(context).textTheme.labelLarge;

    return Semantics(
      button: true,
      selected: isSelected,
      child: SizedBox(
        height: 44,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primaryContainer
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              customBorder: const StadiumBorder(),
              onTap: onTap,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: labelStyle?.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : null,
                      color: isSelected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
