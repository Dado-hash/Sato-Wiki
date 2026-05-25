import 'package:flutter/material.dart';

import 'content_card.dart';

class RelatedLinksGrid extends StatelessWidget {
  const RelatedLinksGrid({required this.links, super.key});

  final List<RelatedLink> links;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 620 ? 2 : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: links.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 76,
          ),
          itemBuilder: (context, index) {
            final link = links[index];

            return ContentCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              onTap: link.onTap,
              trailing: const Icon(Icons.chevron_right),
              child: Row(
                children: [
                  Icon(link.icon, size: 22),
                  const SizedBox(width: 12),
                  Expanded(child: Text(link.title)),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class RelatedLink {
  const RelatedLink({required this.title, required this.icon, this.onTap});

  final String title;
  final IconData icon;
  final VoidCallback? onTap;
}
