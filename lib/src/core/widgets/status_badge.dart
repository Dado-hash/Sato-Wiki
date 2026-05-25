import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum ContentStatus {
  active('ACTIVE', AppColors.success),
  finalStatus('FINAL', AppColors.success),
  draft('DRAFT', AppColors.warning),
  proposed('PROPOSED', AppColors.warning),
  withdrawn('WITHDRAWN', AppColors.error),
  rejected('REJECTED', AppColors.error),
  major('MAJOR', AppColors.warning),
  minor('MINOR', AppColors.success);

  const ContentStatus(this.label, this.color);

  final String label;
  final Color color;
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({required this.status, this.showDot = true, super.key});

  final ContentStatus status;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
              status.label,
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
