import 'package:flutter/material.dart';

import '../../generated/l10n/app_localizations.dart';
import '../content/reading_level.dart';
import '../localization/localized_labels.dart';
import 'sato_segmented_control.dart';

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
    final l10n = AppLocalizations.of(context);

    return SatoSegmentedControl<ReadingLevel>(
      items: ReadingLevel.values,
      selected: selectedLevel,
      labelFor: (level) => level.label(l10n),
      onChanged: onLevelChanged,
    );
  }
}
