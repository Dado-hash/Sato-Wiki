import 'package:flutter/material.dart';

import '../../generated/l10n/app_localizations.dart';
import '../theme/app_colors.dart';

enum ContentStatus {
  active(AppColors.success),
  finalStatus(AppColors.success),
  complete(AppColors.success),
  deployed(AppColors.success),
  draft(AppColors.warning),
  proposed(AppColors.warning),
  withdrawn(AppColors.error),
  rejected(AppColors.error),
  closed(AppColors.muted),
  major(AppColors.warning),
  minor(AppColors.success);

  const ContentStatus(this.color);

  final Color color;
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({required this.status, this.showDot = true, super.key});

  final ContentStatus status;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: status.color.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showDot) ...[
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: status.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              _statusLabel(status, l10n),
              style: textTheme.labelSmall?.copyWith(
                color: status.color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _statusLabel(ContentStatus status, AppLocalizations l10n) {
  return switch (status) {
    ContentStatus.active => l10n.statusActive.toUpperCase(),
    ContentStatus.finalStatus => l10n.statusFinal.toUpperCase(),
    ContentStatus.complete => l10n.statusComplete.toUpperCase(),
    ContentStatus.deployed => l10n.statusDeployed.toUpperCase(),
    ContentStatus.draft => l10n.statusDraft.toUpperCase(),
    ContentStatus.proposed => l10n.statusProposed.toUpperCase(),
    ContentStatus.withdrawn => l10n.statusWithdrawn.toUpperCase(),
    ContentStatus.rejected => l10n.statusRejected.toUpperCase(),
    ContentStatus.closed => l10n.statusClosed.toUpperCase(),
    ContentStatus.major => l10n.statusMajor.toUpperCase(),
    ContentStatus.minor => l10n.statusMinor.toUpperCase(),
  };
}
