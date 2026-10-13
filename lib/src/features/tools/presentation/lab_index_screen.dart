import 'package:flutter/material.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/detail_scaffold.dart';
import '../../../core/widgets/sato_group_card.dart';
import '../../../core/widgets/section_title.dart';
import '../../../generated/l10n/app_localizations.dart';
import 'lab_steps.dart';

/// Blockchain lab: a short introduction and the list of steps.
class LabIndexScreen extends StatelessWidget {
  const LabIndexScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DetailScaffold(
      title: l10n.labTitle,
      children: [
        Text(l10n.labIntro, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.section),
        SectionTitle(title: l10n.labIndexSteps),
        const SizedBox(height: AppSpacing.md),
        SatoGroupCard(
          children: [
            for (var step = 1; step <= labStepCount; step++)
              _LabStepRow(
                step: step,
                title: labStepTitle(l10n, step),
                description: labStepDescription(l10n, step),
                optionalLabel: step == labStepCount
                    ? l10n.labStepOptional
                    : null,
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRoutes.labStep(step)),
              ),
          ],
        ),
      ],
    );
  }
}

class _LabStepRow extends StatelessWidget {
  const _LabStepRow({
    required this.step,
    required this.title,
    required this.description,
    required this.onTap,
    this.optionalLabel,
  });

  final int step;
  final String title;
  final String description;
  final String? optionalLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 14,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                child: Text(
                  '$step',
                  style: textTheme.labelLarge?.copyWith(
                    fontFamily: AppFonts.mono,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      description,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (optionalLabel != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        optionalLabel!,
                        style: textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
