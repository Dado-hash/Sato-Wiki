import 'package:flutter/material.dart';

import '../../../core/content/reading_level.dart';
import '../../../core/widgets/content_card.dart';
import '../../../core/widgets/hero_media.dart';
import '../../../core/widgets/metadata_row.dart';
import '../../../core/widgets/reader_header.dart';
import '../../../core/widgets/reading_level_selector.dart';
import '../../../core/widgets/related_links_grid.dart';
import '../../../core/widgets/section_title.dart';
import '../../../core/widgets/sources_disclosure.dart';

class WikiOverviewScreen extends StatelessWidget {
  const WikiOverviewScreen({
    required this.selectedLevel,
    required this.onLevelChanged,
    super.key,
  });

  final ReadingLevel selectedLevel;
  final ValueChanged<ReadingLevel> onLevelChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 24),
      children: [
        ReaderHeader(
          title: 'The Orange Book',
          subtitle: 'A technical encyclopedia for Bitcoin readers.',
          metadata: const [
            MetadataItem(label: '#Mining', isTag: true),
            MetadataItem(label: '#Consensus', isTag: true),
            MetadataItem(label: '5 min read', icon: Icons.schedule_outlined),
          ],
        ),
        const SizedBox(height: 24),
        const SectionTitle(title: 'Knowledge Base'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: const [
            _CategoryChip(icon: Icons.account_tree_outlined, label: 'Protocol'),
            _CategoryChip(icon: Icons.lock_outline, label: 'Cryptography'),
            _CategoryChip(
              icon: Icons.flash_on_outlined,
              label: 'Lightning Network',
            ),
            _CategoryChip(icon: Icons.savings_outlined, label: 'Economics'),
          ],
        ),
        const SizedBox(height: 28),
        const SectionTitle(title: 'Featured concept'),
        const SizedBox(height: 12),
        const HeroMedia(
          icon: Icons.memory,
          label: 'Proof of Work conceptual visual',
        ),
        const SizedBox(height: 12),
        ContentCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Proof of Work',
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(_descriptionFor(selectedLevel), style: textTheme.bodyLarge),
              const SizedBox(height: 18),
              ReadingLevelSelector(
                selectedLevel: selectedLevel,
                onLevelChanged: onLevelChanged,
              ),
              const SizedBox(height: 18),
              const MetadataRow(
                items: [
                  MetadataItem(label: '#Mining', isTag: true),
                  MetadataItem(label: '#Consensus', isTag: true),
                  MetadataItem(label: '#Cryptography', isTag: true),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const SectionTitle(title: 'Related Concepts'),
        const SizedBox(height: 12),
        RelatedLinksGrid(
          links: const [
            RelatedLink(title: 'SHA-256 Algorithm', icon: Icons.link),
            RelatedLink(title: 'Difficulty Adjustment', icon: Icons.speed),
          ],
        ),
        const SizedBox(height: 28),
        const SourcesDisclosure(
          sources: [
            SourceReference(
              title: 'Bitcoin: A Peer-to-Peer Electronic Cash System',
              author: 'Satoshi Nakamoto (2008)',
            ),
            SourceReference(
              title: 'Hashcash - A Denial of Service Counter-Measure',
              author: 'Adam Back (2002)',
            ),
          ],
        ),
        const SizedBox(height: 28),
        ContentCard(
          child: Row(
            children: [
              Icon(
                Icons.volunteer_activism_outlined,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Content will be versioned in Markdown and reviewed through GitHub pull requests.',
                  style: textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _descriptionFor(ReadingLevel level) {
    return switch (level) {
      ReadingLevel.base =>
        'Proof of Work is the mechanism Bitcoin uses to agree on valid blocks without a central authority.',
      ReadingLevel.medium =>
        'Miners spend computational energy to find a valid block hash, making attacks expensive and verification cheap.',
      ReadingLevel.advanced =>
        'Difficulty adjustment, SHA-256 hashing and accumulated work form the security model behind Bitcoin consensus.',
    };
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: () {},
    );
  }
}
