import 'package:flutter/material.dart';

class MarkdownText extends StatelessWidget {
  const MarkdownText(this.markdown, {super.key});

  final String markdown;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final paragraphs = markdown
        .split(RegExp(r'\n\s*\n'))
        .where((paragraph) => paragraph.trim().isNotEmpty)
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final paragraph in paragraphs) ...[
          Text(paragraph.trim(), style: textTheme.bodyLarge),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}
