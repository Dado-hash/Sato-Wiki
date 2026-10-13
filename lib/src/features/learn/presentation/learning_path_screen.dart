import 'package:flutter/material.dart';

import '../../../core/content/domain/content_store.dart';
import '../../../core/settings/app_settings_controller.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/detail_scaffold.dart';
import '../../../core/widgets/meta_line.dart';
import '../../../core/widgets/sato_group_card.dart';
import '../../../core/widgets/sato_progress_bar.dart';
import '../../../generated/l10n/app_localizations.dart';
import 'learning_path_progress.dart';

/// Ordered steps of one learning path, with the read state of each step.
class LearningPathScreen extends StatelessWidget {
  const LearningPathScreen({
    required this.store,
    required this.settings,
    required this.slug,
    super.key,
  });

  final ContentStore store;
  final AppSettingsController settings;
  final String slug;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final path = store.bundle.paths
        .where((item) => item.slug == slug)
        .firstOrNull;

    if (path == null) {
      return DetailScaffold(title: l10n.learnPathNotFound, children: const []);
    }

    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final progress = LearningPathProgress.of(
          path,
          store,
          progressFor: settings.progressFor,
        );
        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;
        final percent = (progress.fraction * 100).round();

        return DetailScaffold(
          title: path.title,
          children: [
            MetaLine(parts: [l10n.shortMin(path.estimatedMinutes)]),
            const SizedBox(height: AppSpacing.md),
            Text(
              path.description,
              style: textTheme.bodyLarge?.copyWith(
                height: 26 / 17,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SatoProgressBar(
              value: progress.fraction,
              height: 3,
              semanticLabel: l10n.readPercent(percent),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.learnStepsRead(progress.readCount, progress.total),
              style: textTheme.labelMedium,
            ),
            if (progress.total > 0 && progress.nextUnread == null) ...[
              const SizedBox(height: 4),
              Text(
                l10n.learnAllStepsRead,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.section),
            SatoGroupCard(
              children: [
                for (final step in progress.steps)
                  _StepRow(
                    step: step,
                    onOpened: tracksScrollProgress(step.id)
                        ? null
                        : () => settings.setReadingProgress(step.id, 1),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.step, this.onOpened});

  final ResolvedPathStep step;

  /// Called when the step is opened and its screen records no progress itself.
  final VoidCallback? onOpened;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final route = step.route;

    return InkWell(
      onTap: route == null
          ? null
          : () {
              onOpened?.call();
              Navigator.of(context).pushNamed(route);
            },
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 14,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 28,
                child: Semantics(
                  label: l10n.learnStepNumber(step.number),
                  child: Text(
                    '${step.number}',
                    style: textTheme.labelLarge?.copyWith(
                      fontFamily: AppFonts.mono,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(step.title, style: textTheme.titleMedium),
                    if (step.note.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        step.note,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (step.isRead) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            l10n.learnStepRead,
                            style: textTheme.labelMedium?.copyWith(
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (route != null) ...[
                const SizedBox(width: AppSpacing.md),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
