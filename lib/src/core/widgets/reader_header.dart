import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';
import 'metadata_row.dart';

class ReaderHeader extends StatelessWidget {
  const ReaderHeader({
    required this.title,
    this.subtitle,
    this.metadata = const [],
    this.trailing,
    super.key,
  });

  final String title;
  final String? subtitle;
  final List<MetadataItem> metadata;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (metadata.isNotEmpty) ...[
          MetadataRow(items: metadata),
          const SizedBox(height: AppSpacing.md),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Text(title, style: textTheme.headlineLarge)),
            if (trailing != null) ...[
              const SizedBox(width: AppSpacing.lg),
              trailing!,
            ],
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 10),
          Text(
            subtitle!,
            style: textTheme.bodyLarge?.copyWith(
              fontSize: 17,
              height: 26 / 17,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
