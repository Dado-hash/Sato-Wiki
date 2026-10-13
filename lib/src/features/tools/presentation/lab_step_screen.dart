import 'package:flutter/material.dart';

import '../../../core/content/domain/content_store.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/detail_scaffold.dart';
import '../../../core/widgets/sato_progress_bar.dart';
import '../../../generated/l10n/app_localizations.dart';
import 'lab_steps.dart';
import 'lab_step_chain.dart';
import 'lab_step_header.dart';
import 'lab_step_hash.dart';
import 'lab_step_mine.dart';
import 'lab_step_network.dart';
import 'lab_step_transactions.dart';
import 'tool_widgets.dart';

/// One step of the blockchain lab: its own demo, the box that says how Bitcoin
/// differs, the wiki links, and previous and next buttons.
class LabStepScreen extends StatelessWidget {
  const LabStepScreen({required this.store, required this.step, super.key});

  final ContentStore store;

  /// Step from 1 to [labStepCount].
  final int step;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final counter = l10n.labStepCounter(step, labStepCount);

    return DetailScaffold(
      title: counter,
      children: [
        SatoProgressBar(
          value: step / labStepCount,
          height: 4,
          semanticLabel: counter,
        ),
        const SizedBox(height: AppSpacing.lg),
        if (step == labStepCount)
          Text(
            l10n.labStepOptional,
            style: textTheme.labelSmall?.copyWith(color: colorScheme.primary),
          ),
        Text(labStepTitle(l10n, step), style: textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.sm),
        Text(
          labStepDescription(l10n, step),
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _stepBody(step),
        const SizedBox(height: AppSpacing.section),
        LabDifferenceBox(text: labStepDifference(l10n, step)),
        const SizedBox(height: AppSpacing.section),
        ToolWikiLinks(store: store, entryIds: labStepWikiIds(step)),
        const SizedBox(height: AppSpacing.section),
        LabStepNavigation(step: step),
      ],
    );
  }

  static Widget _stepBody(int step) {
    return switch (step) {
      1 => const LabHashStep(),
      2 => const LabMineStep(),
      3 => const LabChainStep(),
      4 => const LabNetworkStep(),
      5 => const LabTransactionsStep(),
      6 => const LabCoinbaseStep(),
      _ => const LabHeaderStep(),
    };
  }
}

/// The box that ends each step: how the toy differs from the real protocol.
class LabDifferenceBox extends StatelessWidget {
  const LabDifferenceBox({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.labDifference, style: textTheme.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          Text(text, style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}

/// Previous and next buttons. The first step has no previous, the last no next.
class LabStepNavigation extends StatelessWidget {
  const LabStepNavigation({required this.step, super.key});

  final int step;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasPrevious = step > 1;
    final hasNext = step < labStepCount;

    void open(int target) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.labStep(target));
    }

    return Row(
      children: [
        if (hasPrevious)
          Expanded(
            child: OutlinedButton(
              onPressed: () => open(step - 1),
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
              child: Text(l10n.labPreviousStep),
            ),
          ),
        if (hasPrevious && hasNext) const SizedBox(width: AppSpacing.md),
        if (hasNext)
          Expanded(
            child: FilledButton(
              onPressed: () => open(step + 1),
              style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
              child: Text(l10n.labNextStep),
            ),
          ),
      ],
    );
  }
}
