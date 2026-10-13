import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/sato_colors.dart';
import '../../../core/widgets/status_pill.dart';
import '../../../generated/l10n/app_localizations.dart';

/// Valid or not valid, as text on a pill with a colour cue. The label is
/// always shown, so the state never depends on colour alone.
class LabValidityPill extends StatelessWidget {
  const LabValidityPill({required this.valid, super.key});

  final bool valid;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return StatusPill(
      label: valid ? l10n.labValid : l10n.labNotValid,
      color: valid
          ? context.sato.statusDeployed
          : Theme.of(context).colorScheme.error,
    );
  }
}

/// Card for one block of the lab: title, validity label and its fields.
class LabBlockCard extends StatelessWidget {
  const LabBlockCard({
    required this.title,
    required this.valid,
    required this.children,
    super.key,
  });

  final String title;
  final bool valid;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(
          color: valid ? colorScheme.outlineVariant : colorScheme.error,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: textTheme.titleSmall)),
              const SizedBox(width: AppSpacing.sm),
              LabValidityPill(valid: valid),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...children,
        ],
      ),
    );
  }
}
