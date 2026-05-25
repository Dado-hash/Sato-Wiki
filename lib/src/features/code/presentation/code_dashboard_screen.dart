import 'package:flutter/material.dart';

import '../../../core/widgets/content_card.dart';
import '../../../core/widgets/filter_chip_bar.dart';
import '../../../core/widgets/metadata_row.dart';
import '../../../core/widgets/reader_header.dart';
import '../../../core/widgets/section_title.dart';
import '../../../core/widgets/status_badge.dart';

class CodeDashboardScreen extends StatelessWidget {
  const CodeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 24),
      children: const [
        ReaderHeader(
          title: 'Code Dashboard',
          subtitle:
              'Track Bitcoin Improvement Proposals and core implementation changes.',
          metadata: [
            MetadataItem(label: 'BIP tracker', icon: Icons.terminal_outlined),
          ],
        ),
        SizedBox(height: 24),
        _StatusFilters(),
        SizedBox(height: 28),
        SectionTitle(title: 'Code Dashboard'),
        SizedBox(height: 12),
        _CodeAreaCard(
          icon: Icons.analytics_outlined,
          title: 'BIP Tracker',
          subtitle:
              'Statuses, categories, readable summaries and official links.',
        ),
        SizedBox(height: 12),
        _CodeAreaCard(
          icon: Icons.commit_outlined,
          title: 'Changelog',
          subtitle: 'Bitcoin Core, LND, Core Lightning and Eclair releases.',
        ),
        SizedBox(height: 28),
        SectionTitle(title: 'Recent BIPs'),
        SizedBox(height: 12),
        _BipRow(
          number: 'BIP 341',
          title: 'Taproot',
          status: ContentStatus.active,
        ),
        SizedBox(height: 10),
        _BipRow(
          number: 'BIP 324',
          title: 'V2 Transport',
          status: ContentStatus.draft,
        ),
        SizedBox(height: 10),
        _BipRow(
          number: 'BIP 352',
          title: 'Silent Payments',
          status: ContentStatus.draft,
        ),
      ],
    );
  }
}

class _StatusFilters extends StatelessWidget {
  const _StatusFilters();

  @override
  Widget build(BuildContext context) {
    return FilterChipBar<String>(
      items: const ['All', 'Active', 'Draft', 'Proposed', 'Rejected'],
      selectedItem: 'All',
      labelFor: (item) => item,
      onSelected: (_) {},
    );
  }
}

class _CodeAreaCard extends StatelessWidget {
  const _CodeAreaCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ContentCard(
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}

class _BipRow extends StatelessWidget {
  const _BipRow({
    required this.number,
    required this.title,
    required this.status,
  });

  final String number;
  final String title;
  final ContentStatus status;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ContentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                number,
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(status: status),
            ],
          ),
          const SizedBox(height: 8),
          Text(title, style: textTheme.titleMedium),
        ],
      ),
    );
  }
}
