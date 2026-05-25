import 'package:flutter/material.dart';

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
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (metadata.isNotEmpty) ...[
          MetadataRow(items: metadata),
          const SizedBox(height: 18),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                title,
                style: textTheme.displayLarge?.copyWith(
                  fontSize: 42,
                  height: 1.08,
                ),
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 16), trailing!],
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 12),
          Text(subtitle!, style: textTheme.bodyLarge),
        ],
      ],
    );
  }
}
