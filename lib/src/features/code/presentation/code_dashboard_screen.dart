import 'package:flutter/material.dart';

import '../../../core/content/domain/content_models.dart';
import '../../../core/content/domain/content_store.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/widgets/content_card.dart';
import '../../../core/widgets/filter_chip_bar.dart';
import '../../../core/widgets/markdown_text.dart';
import '../../../core/widgets/metadata_row.dart';
import '../../../core/widgets/reader_header.dart';
import '../../../core/widgets/section_title.dart';
import '../../../core/widgets/status_badge.dart';

class CodeDashboardScreen extends StatelessWidget {
  const CodeDashboardScreen({required this.store, super.key});

  final ContentStore store;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 24),
      children: [
        const ReaderHeader(
          title: 'Code Dashboard',
          subtitle:
              'Track Bitcoin Improvement Proposals and core implementation changes.',
          metadata: [
            MetadataItem(label: 'BIP tracker', icon: Icons.terminal_outlined),
          ],
        ),
        const SizedBox(height: 24),
        const _StatusFilters(),
        const SizedBox(height: 28),
        const SectionTitle(title: 'Code Dashboard'),
        const SizedBox(height: 12),
        const _CodeAreaCard(
          icon: Icons.analytics_outlined,
          title: 'BIP Tracker',
          subtitle:
              'Statuses, categories, readable summaries and official links.',
        ),
        const SizedBox(height: 12),
        const _CodeAreaCard(
          icon: Icons.commit_outlined,
          title: 'Changelog',
          subtitle: 'Bitcoin Core, LND, Core Lightning and Eclair releases.',
        ),
        const SizedBox(height: 28),
        const SectionTitle(title: 'Recent BIPs'),
        const SizedBox(height: 12),
        for (final bip in store.bundle.bips) ...[
          _BipRow(
            bip: bip,
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.codeBip(bip.number));
            },
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 18),
        const SectionTitle(title: 'Releases'),
        const SizedBox(height: 12),
        for (final release in store.bundle.changelogs) ...[
          _ReleaseRow(
            release: release,
            onTap: () {
              Navigator.of(context).pushNamed(
                AppRoutes.codeChangelog(release.project, release.version),
              );
            },
          ),
          const SizedBox(height: 10),
        ],
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
  const _BipRow({required this.bip, required this.onTap});

  final Bip bip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ContentCard(
      onTap: onTap,
      trailing: const Icon(Icons.chevron_right),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'BIP ${bip.number}',
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(status: _badgeFor(bip.status)),
            ],
          ),
          const SizedBox(height: 8),
          Text(bip.title, style: textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(bip.summary),
        ],
      ),
    );
  }

  ContentStatus _badgeFor(BipStatus status) {
    return switch (status) {
      BipStatus.active => ContentStatus.active,
      BipStatus.finalStatus => ContentStatus.finalStatus,
      BipStatus.draft => ContentStatus.draft,
      BipStatus.proposed => ContentStatus.proposed,
      BipStatus.withdrawn => ContentStatus.withdrawn,
      BipStatus.rejected => ContentStatus.rejected,
    };
  }
}

class _ReleaseRow extends StatelessWidget {
  const _ReleaseRow({required this.release, required this.onTap});

  final ReleaseNote release;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ContentCard(
      onTap: onTap,
      trailing: const Icon(Icons.chevron_right),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(release.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(release.summary),
        ],
      ),
    );
  }
}

class BipDetailScreen extends StatelessWidget {
  const BipDetailScreen({required this.store, required this.number, super.key});

  final ContentStore store;
  final int number;

  @override
  Widget build(BuildContext context) {
    final bip = store.bundle.bips
        .where((bip) => bip.number == number)
        .firstOrNull;

    if (bip == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Code')),
        body: const Center(child: Text('BIP not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Code')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ReaderHeader(
            title: 'BIP ${bip.number}: ${bip.title}',
            subtitle: bip.summary,
            trailing: StatusBadge(status: _badgeFor(bip.status)),
            metadata: [
              MetadataItem(label: bip.category, icon: Icons.category_outlined),
              MetadataItem(
                label: bip.createdAt.toIso8601String().split('T').first,
                icon: Icons.calendar_today_outlined,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _ImpactCard(title: 'Summary', body: bip.summaryMarkdown),
          const SizedBox(height: 12),
          _ImpactCard(title: 'Impact', body: bip.impactMarkdown),
          const SizedBox(height: 24),
          const SectionTitle(title: 'Status History'),
          const SizedBox(height: 12),
          for (final change in bip.statusHistory)
            ContentCard(
              child: MetadataRow(
                items: [
                  MetadataItem(
                    label: change.date.toIso8601String().split('T').first,
                    icon: Icons.calendar_today_outlined,
                  ),
                  MetadataItem(label: change.note),
                ],
              ),
            ),
        ],
      ),
    );
  }

  ContentStatus _badgeFor(BipStatus status) {
    return switch (status) {
      BipStatus.active => ContentStatus.active,
      BipStatus.finalStatus => ContentStatus.finalStatus,
      BipStatus.draft => ContentStatus.draft,
      BipStatus.proposed => ContentStatus.proposed,
      BipStatus.withdrawn => ContentStatus.withdrawn,
      BipStatus.rejected => ContentStatus.rejected,
    };
  }
}

class ReleaseNoteScreen extends StatelessWidget {
  const ReleaseNoteScreen({
    required this.store,
    required this.project,
    required this.version,
    super.key,
  });

  final ContentStore store;
  final String project;
  final String version;

  @override
  Widget build(BuildContext context) {
    final release = store.bundle.changelogs
        .where(
          (release) => release.project == project && release.version == version,
        )
        .firstOrNull;

    if (release == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Code')),
        body: const Center(child: Text('Release not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Code')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ReaderHeader(
            title: release.title,
            subtitle: release.summary,
            trailing: StatusBadge(
              status: release.importance == ReleaseImportance.major
                  ? ContentStatus.major
                  : ContentStatus.minor,
            ),
          ),
          const SizedBox(height: 24),
          const SectionTitle(title: 'User Impact'),
          const SizedBox(height: 8),
          MarkdownText(release.userImpactMarkdown),
          const SectionTitle(title: 'Technical Changes'),
          const SizedBox(height: 8),
          MarkdownText(release.technicalChangesMarkdown),
        ],
      ),
    );
  }
}

class _ImpactCard extends StatelessWidget {
  const _ImpactCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return ContentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          MarkdownText(body),
        ],
      ),
    );
  }
}
