import 'package:flutter/material.dart';

import '../content/reading_level.dart';

class ReadingLevelSelector extends StatelessWidget {
  const ReadingLevelSelector({
    required this.selectedLevel,
    required this.onLevelChanged,
    super.key,
  });

  final ReadingLevel selectedLevel;
  final ValueChanged<ReadingLevel> onLevelChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: SegmentedButton<ReadingLevel>(
          selected: {selectedLevel},
          showSelectedIcon: false,
          style: ButtonStyle(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            minimumSize: const WidgetStatePropertyAll(Size(80, 44)),
            visualDensity: VisualDensity.compact,
            side: const WidgetStatePropertyAll(BorderSide.none),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            textStyle: WidgetStatePropertyAll(
              Theme.of(context).textTheme.labelLarge,
            ),
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return colorScheme.primaryContainer;
              }

              return Colors.transparent;
            }),
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return colorScheme.onPrimaryContainer;
              }

              return colorScheme.onSurfaceVariant;
            }),
          ),
          onSelectionChanged: (levels) {
            onLevelChanged(levels.first);
          },
          segments: ReadingLevel.values
              .map(
                (level) => ButtonSegment<ReadingLevel>(
                  value: level,
                  label: Text(level.label),
                ),
              )
              .toList(growable: false),
        ),
      ),
    );
  }
}
