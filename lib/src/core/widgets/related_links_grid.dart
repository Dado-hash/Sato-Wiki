import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

class RelatedLinksGrid extends StatelessWidget {
  const RelatedLinksGrid({required this.links, super.key});

  final List<RelatedLink> links;

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final columns = textScale > 1.3 ? 1 : 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var start = 0; start < links.length; start += columns) ...[
          if (start > 0) const SizedBox(height: AppSpacing.md),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _RelatedLinkTile(link: links[start])),
                if (columns == 2) ...[
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: start + 1 < links.length
                        ? _RelatedLinkTile(link: links[start + 1])
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _RelatedLinkTile extends StatelessWidget {
  const _RelatedLinkTile({required this.link});

  final RelatedLink link;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: colorScheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: link.onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 72),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: 14,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    link.title,
                    style: textTheme.titleMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (link.onTap != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RelatedLink {
  const RelatedLink({required this.title, required this.icon, this.onTap});

  final String title;
  final IconData icon;
  final VoidCallback? onTap;
}
