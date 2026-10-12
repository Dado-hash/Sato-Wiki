import 'package:flutter/material.dart';

import '../content/domain/content_models.dart';
import '../localization/localized_labels.dart';
import '../../generated/l10n/app_localizations.dart';
import '../theme/sato_colors.dart';

/// Dot and label on a tinted pill. Colour is never the only signal: the label is always shown.
class StatusPill extends StatelessWidget {
  const StatusPill({required this.label, required this.color, super.key});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelSmall;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(label, style: labelStyle?.copyWith(color: color)),
          ),
        ],
      ),
    );
  }
}

class BipStatusPill extends StatelessWidget {
  const BipStatusPill({required this.status, super.key});

  final BipStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return StatusPill(
      label: status.label(l10n),
      color: bipStatusColor(context, status),
    );
  }
}

Color bipStatusColor(BuildContext context, BipStatus status) {
  final sato = context.sato;

  return switch (status) {
    BipStatus.deployed => sato.statusDeployed,
    BipStatus.complete => sato.statusComplete,
    BipStatus.draft => sato.statusDraft,
    BipStatus.closed => sato.statusClosed,
  };
}
