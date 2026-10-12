import 'package:flutter/material.dart';

import '../../generated/l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import '../theme/sato_colors.dart';

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
  minor(AppColors.success),
  patch(AppColors.muted);

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
    final color = _colorFor(context, status);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showDot) ...[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              _statusLabel(status, l10n),
              style: textTheme.labelSmall?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

Color _colorFor(BuildContext context, ContentStatus status) {
  final colorScheme = Theme.of(context).colorScheme;
  final sato = context.sato;

  return switch (status) {
    ContentStatus.active ||
    ContentStatus.finalStatus ||
    ContentStatus.deployed ||
    ContentStatus.minor => sato.statusDeployed,
    ContentStatus.complete => sato.statusComplete,
    ContentStatus.draft || ContentStatus.proposed => sato.statusDraft,
    ContentStatus.major => colorScheme.primary,
    ContentStatus.withdrawn || ContentStatus.rejected => colorScheme.error,
    ContentStatus.closed || ContentStatus.patch => sato.statusClosed,
  };
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
    ContentStatus.patch => l10n.statusPatch.toUpperCase(),
  };
}
