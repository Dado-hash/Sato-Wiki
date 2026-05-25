import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/content_card.dart';
import '../../../core/widgets/section_title.dart';

class CodeDashboardScreen extends StatelessWidget {
  const CodeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 24),
      children: const [
        _CodeHeader(),
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
          status: 'ACTIVE',
          color: AppColors.success,
        ),
        SizedBox(height: 10),
        _BipRow(
          number: 'BIP 324',
          title: 'V2 Transport',
          status: 'DRAFT',
          color: AppColors.warning,
        ),
        SizedBox(height: 10),
        _BipRow(
          number: 'BIP 352',
          title: 'Silent Payments',
          status: 'DRAFT',
          color: AppColors.warning,
        ),
      ],
    );
  }
}

class _CodeHeader extends StatelessWidget {
  const _CodeHeader();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Code Dashboard', style: textTheme.headlineLarge),
        const SizedBox(height: 8),
        Text(
          'Track Bitcoin Improvement Proposals and core implementation changes.',
          style: textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _StatusFilters extends StatelessWidget {
  const _StatusFilters();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: const [
          _StatusFilter(label: 'All', selected: true),
          _StatusFilter(label: 'Active'),
          _StatusFilter(label: 'Draft'),
          _StatusFilter(label: 'Proposed'),
        ],
      ),
    );
  }
}

class _StatusFilter extends StatelessWidget {
  const _StatusFilter({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: FilterChip(
        selected: selected,
        label: Text(label),
        onSelected: (_) {},
      ),
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
    required this.color,
  });

  final String number;
  final String title;
  final String status;
  final Color color;

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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: color.withValues(alpha: 0.18),
                ),
                child: Text(
                  status,
                  style: textTheme.labelSmall?.copyWith(color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(title, style: textTheme.titleMedium),
        ],
      ),
    );
  }
}
