import 'package:flutter/material.dart';

import '../../../core/widgets/content_card.dart';
import '../../../core/widgets/section_title.dart';
import 'reading_level_selector.dart';

class WikiOverviewScreen extends StatefulWidget {
  const WikiOverviewScreen({super.key});

  @override
  State<WikiOverviewScreen> createState() => _WikiOverviewScreenState();
}

class _WikiOverviewScreenState extends State<WikiOverviewScreen> {
  ReadingLevel _selectedLevel = ReadingLevel.base;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 24),
      children: [
        Text(
          'The Orange Book',
          style: textTheme.displayLarge?.copyWith(fontSize: 42, height: 1.05),
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
              Text(_descriptionFor(_selectedLevel), style: textTheme.bodyLarge),
              const SizedBox(height: 18),
              ReadingLevelSelector(
                selectedLevel: _selectedLevel,
                onLevelChanged: (level) {
                  setState(() => _selectedLevel = level);
                },
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  _TagChip(label: '#Mining'),
                  _TagChip(label: '#Consensus'),
                  _TagChip(label: '#Cryptography'),
                ],
              ),
            ],
          ),
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

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Chip(
      label: Text(label),
      backgroundColor: colorScheme.surfaceContainerHighest,
      labelStyle: TextStyle(color: colorScheme.primary),
      side: BorderSide(color: colorScheme.outlineVariant),
    );
  }
}
