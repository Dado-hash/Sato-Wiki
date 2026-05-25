import 'package:flutter/material.dart';

import '../../../core/content/reading_level.dart';

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

    return SegmentedButton<ReadingLevel>(
      selected: {selectedLevel},
      showSelectedIcon: false,
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        side: WidgetStatePropertyAll(
          BorderSide(color: colorScheme.outlineVariant),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primaryContainer;
          }

          return colorScheme.surfaceContainerLow;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.onPrimaryContainer;
          }

          return colorScheme.onSurface;
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
    );
  }
}
