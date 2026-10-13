import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/content/domain/content_models.dart';
import '../../../core/content/domain/content_store.dart';
import '../../../core/localization/content_labels.dart';
import '../../../core/localization/localized_labels.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/navigation/content_routes.dart';
import '../../../core/navigation/sato_wiki_tab.dart';
import '../../../core/settings/app_settings_controller.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/content_thumbnail.dart';
import '../../../core/widgets/quote_card.dart';
import '../../../core/widgets/meta_line.dart';
import '../../../core/widgets/round_icon_button.dart';
import '../../../core/widgets/sato_group_card.dart';
import '../../../core/widgets/sato_progress_bar.dart';
import '../../../core/widgets/sato_scaffold.dart';
import '../../../core/widgets/section_title.dart';
import '../../../core/widgets/status_pill.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../learn/presentation/learning_path_progress.dart';
import 'quote_of_the_day.dart';

/// The Today tab: headline, reading continuation, featured entry, anniversaries
/// and the latest code and news items.
class TodayScreen extends StatelessWidget {
  const TodayScreen({
    required this.store,
    required this.settings,
    this.now,
    super.key,
  });

  final ContentStore store;
  final AppSettingsController settings;

  /// Clock override for tests. Defaults to the current time.
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final current = now ?? DateTime.now();
    final todayDate = DateTime.utc(current.year, current.month, current.day);

    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final continueItem = _findContinueItem(store, settings, l10n);
        final featured = _featuredEntry(store, todayDate, continueItem?.id);

        final path = store.bundle.paths.firstOrNull;
        final pathProgress = path == null
            ? null
            : LearningPathProgress.of(
                path,
                store,
                progressFor: settings.progressFor,
              );
        final quote = quoteOfTheDay(store.bundle.quotes, todayDate);

        final anniversaries = _upcomingAnniversaries(
          store.bundle.history,
          todayDate,
        );
        final onThisDay = anniversaries.where((item) => item.days == 0).toList()
          ..sort((a, b) => a.event.date.year.compareTo(b.event.date.year));
        final nextOnly = onThisDay.isNotEmpty || anniversaries.isEmpty
            ? const <_Anniversary>[]
            : [anniversaries.reduce((a, b) => a.days <= b.days ? a : b)];
        final anniversaryItems = onThisDay.isNotEmpty ? onThisDay : nextOnly;

        final bips = store.bundle.bips;
        final topBip = bips.isEmpty
            ? null
            : bips.reduce((a, b) => a.number >= b.number ? a : b);
        final changelogs = store.bundle.changelogs;
        final latestRelease = changelogs.isEmpty
            ? null
            : changelogs.reduce(
                (a, b) => a.releasedAt.isAfter(b.releasedAt) ? a : b,
              );
        final news = store.bundle.news;
        final latestArticle = news.isEmpty
            ? null
            : news.reduce(
                (a, b) => a.publishedAt.isAfter(b.publishedAt) ? a : b,
              );

        return ListView(
          padding: EdgeInsets.only(
            bottom: SatoScaffold.bottomClearanceOf(context),
          ),
          children: [
            const _TopBar(),
            _Headline(date: todayDate),
            if (continueItem != null)
              _Section(
                header: SectionTitle(title: l10n.continueReading),
                children: [
                  _ContinueCard(
                    item: continueItem,
                    progress: settings.progressFor(continueItem.id),
                  ),
                ],
              ),
            if (pathProgress != null && pathProgress.total > 0)
              _Section(children: [_PathCard(progress: pathProgress)]),
            if (quote != null) _Section(children: [QuoteCard(quote: quote)]),
            if (featured != null)
              _Section(
                header: SectionTitle(
                  title: l10n.featured,
                  actionLabel: l10n.allEntries,
                  onAction: () => settings.setLastTab(SatoWikiTab.wiki),
                ),
                children: [_FeaturedCard(entry: featured)],
              ),
            if (anniversaryItems.isNotEmpty)
              _Section(
                header: SectionTitle(
                  title: onThisDay.isNotEmpty
                      ? l10n.onThisDayTitle
                      : l10n.nextAnniversary,
                ),
                children: [
                  for (final item in anniversaryItems)
                    _AnniversaryCard(anniversary: item),
                ],
              ),
            if (topBip != null || latestRelease != null)
              _Section(
                header: SectionTitle(
                  title: l10n.fromTheCode,
                  actionLabel: l10n.seeAll,
                  onAction: () => settings.setLastTab(SatoWikiTab.code),
                ),
                children: [
                  SatoGroupCard(
                    children: [
                      if (topBip != null) _BipRow(bip: topBip),
                      if (latestRelease != null)
                        _ReleaseRow(release: latestRelease),
                    ],
                  ),
                ],
              ),
            if (latestArticle != null)
              _Section(
                header: SectionTitle(
                  title: l10n.latestNews,
                  actionLabel: l10n.seeAll,
                  onAction: () => settings.setLastTab(SatoWikiTab.news),
                ),
                children: [
                  SatoGroupCard(children: [_NewsRow(article: latestArticle)]),
                ],
              ),
          ],
        );
      },
    );
  }
}

/// Spacing shared by every block: section gap above, 12 px between children.
/// A block without [header] starts directly with its first child.
class _Section extends StatelessWidget {
  const _Section({required this.children, this.header});

  final Widget? header;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.section,
        AppSpacing.gutter,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ?header,
          for (var index = 0; index < children.length; index++) ...[
            if (index > 0 || header != null)
              const SizedBox(height: AppSpacing.md),
            children[index],
          ],
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        MediaQuery.paddingOf(context).top + AppSpacing.lg,
        AppSpacing.gutter,
        0,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.menu_book_rounded,
              size: 18,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.appTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          RoundIconButton(
            icon: Icons.search_rounded,
            tooltip: l10n.searchTooltip,
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.search),
          ),
          const SizedBox(width: AppSpacing.sm),
          RoundIconButton(
            icon: Icons.tune_rounded,
            tooltip: l10n.settingsTooltip,
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.settings),
          ),
        ],
      ),
    );
  }
}

class _Headline extends StatelessWidget {
  const _Headline({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.section,
        AppSpacing.gutter,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat.MMMMEEEEd(l10n.localeName).format(date).toUpperCase(),
            style: textTheme.labelMedium?.copyWith(letterSpacing: 1.2),
          ),
          const SizedBox(height: 10),
          Semantics(
            header: true,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '${l10n.todayHeadlineLead} '),
                  TextSpan(
                    text: l10n.todayHeadlineAccent,
                    style: TextStyle(color: theme.colorScheme.primary),
                  ),
                ],
              ),
              style: textTheme.displaySmall,
            ),
          ),
        ],
      ),
    );
  }
}

/// Raised card surface with an ink well. Clips its content to the radius.
class _Card extends StatelessWidget {
  const _Card({required this.radius, required this.onTap, required this.child});

  final double radius;
  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: InkWell(onTap: onTap, child: child),
    );
  }
}

class _ContinueItem {
  const _ContinueItem({
    required this.id,
    required this.title,
    required this.coverImage,
    required this.label,
    required this.readTimeMinutes,
  });

  final String id;
  final String title;
  final String? coverImage;
  final String label;
  final int readTimeMinutes;
}

_ContinueItem? _findContinueItem(
  ContentStore store,
  AppSettingsController settings,
  AppLocalizations l10n,
) {
  final id = settings.continueReadingId;
  if (id == null) {
    return null;
  }

  final entry = store.bundle.wiki.where((item) => item.id == id).firstOrNull;
  if (entry != null) {
    return _ContinueItem(
      id: id,
      title: entry.title,
      coverImage: entry.coverImage?.toString(),
      label: settings.readingLevel.label(l10n),
      readTimeMinutes: entry.readTimeMinutes,
    );
  }

  final article = store.bundle.news.where((item) => item.id == id).firstOrNull;
  if (article != null) {
    return _ContinueItem(
      id: id,
      title: article.title,
      coverImage: article.coverImage?.toString(),
      label: contentCategoryLabel(article.category, l10n),
      readTimeMinutes: article.readTimeMinutes,
    );
  }

  return null;
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({required this.item, required this.progress});

  final _ContinueItem item;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    final minutesLeft = (item.readTimeMinutes * (1 - progress)).ceil();
    final percent = (progress * 100).round();

    return _Card(
      radius: AppRadii.card,
      onTap: () => _openContent(context, item.id),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ContentThumbnail(source: item.coverImage, width: 92, height: 68),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: textTheme.titleLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${item.label} · '
                    '${l10n.minutesLeft(minutesLeft < 1 ? 1 : minutesLeft)}',
                    style: textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  SatoProgressBar(
                    value: progress,
                    semanticLabel: l10n.readPercent(percent),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                size: 20,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Start here": the first learning path with its progress and next step.
class _PathCard extends StatelessWidget {
  const _PathCard({required this.progress});

  final LearningPathProgress progress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final path = progress.path;
    final next = progress.nextUnread;
    final percent = (progress.fraction * 100).round();

    return _Card(
      radius: AppRadii.card,
      onTap: () =>
          Navigator.of(context).pushNamed(AppRoutes.learningPath(path.slug)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l10n.learnStartHere} · '
                      '${l10n.shortMin(path.estimatedMinutes)}'
                  .toUpperCase(),
              style: textTheme.labelSmall?.copyWith(color: colorScheme.primary),
            ),
            const SizedBox(height: 6),
            Text(path.title, style: textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(
              l10n.learnStepsRead(progress.readCount, progress.total),
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 10),
            SatoProgressBar(
              value: progress.fraction,
              semanticLabel: l10n.readPercent(percent),
            ),
            const SizedBox(height: 10),
            Text(
              next == null
                  ? l10n.learnAllStepsRead
                  : l10n.learnNextStep(next.title),
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _openContent(BuildContext context, String id) {
  final route = routeForContentId(id);
  if (route != null) {
    Navigator.of(context).pushNamed(route);
  }
}

/// Deterministic pick per day, skipping the entry shown in "Continue reading".
WikiEntry? _featuredEntry(
  ContentStore store,
  DateTime today,
  String? continueId,
) {
  final sorted = [...store.bundle.wiki]..sort((a, b) => a.id.compareTo(b.id));
  if (sorted.isEmpty) {
    return null;
  }

  final candidates = [
    for (final entry in sorted)
      if (entry.id != continueId) entry,
  ];
  final pool = candidates.isEmpty ? sorted : candidates;
  final dayOfYear = today.difference(DateTime.utc(today.year)).inDays + 1;

  return pool[dayOfYear % pool.length];
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.entry});

  final WikiEntry entry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return _Card(
      radius: AppRadii.media,
      onTap: () =>
          Navigator.of(context).pushNamed(AppRoutes.wikiEntry(entry.slug)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ContentThumbnail(
            source: entry.coverImage?.toString(),
            aspectRatio: 16 / 9,
            borderRadius: 0,
            semanticLabel: entry.title,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MetaLine(
                  label: contentCategoryLabel(entry.category, l10n),
                  parts: [
                    l10n.shortMin(entry.readTimeMinutes),
                    entry.difficulty.label(l10n),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(entry.title, style: textTheme.headlineSmall),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  entry.description,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final class _Anniversary {
  const _Anniversary({
    required this.event,
    required this.date,
    required this.days,
  });

  final HistoryEvent event;

  /// Next occurrence of the event, as a UTC date.
  final DateTime date;

  final int days;
}

bool _isLeapYear(int year) {
  return (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;
}

/// Occurrence of an event's month and day in [year]. 29 February falls back
/// to 28 February in non-leap years.
DateTime _occurrenceIn(HistoryEvent event, int year) {
  final isLeapDay = event.date.month == 2 && event.date.day == 29;
  final day = isLeapDay && !_isLeapYear(year) ? 28 : event.date.day;

  return DateTime.utc(year, event.date.month, day);
}

List<_Anniversary> _upcomingAnniversaries(
  List<HistoryEvent> events,
  DateTime today,
) {
  final result = <_Anniversary>[];
  for (final event in events) {
    var next = _occurrenceIn(event, today.year);
    if (next.isBefore(today)) {
      next = _occurrenceIn(event, today.year + 1);
    }
    result.add(
      _Anniversary(
        event: event,
        date: next,
        days: next.difference(today).inDays,
      ),
    );
  }

  return result;
}

class _AnniversaryCard extends StatelessWidget {
  const _AnniversaryCard({required this.anniversary});

  final _Anniversary anniversary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final event = anniversary.event;
    final days = anniversary.days;

    final when = switch (days) {
      0 => l10n.today,
      1 => l10n.tomorrow,
      _ => l10n.inDays(days),
    };

    return _Card(
      radius: AppRadii.card,
      onTap: () =>
          Navigator.of(context).pushNamed(AppRoutes.historyEvent(event.slug)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 64,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(AppRadii.tile),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${anniversary.date.day}',
                    style: textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat.MMM(
                      l10n.localeName,
                    ).format(anniversary.date).toUpperCase(),
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${event.date.year} · $when',
                    style: textTheme.labelMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.title,
                    style: textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

/// One row of the "From the code" group: label, title and a trailing widget.
class _CodeRow extends StatelessWidget {
  const _CodeRow({
    required this.label,
    required this.title,
    required this.trailing,
    required this.onTap,
  });

  final String label;
  final String title;
  final Widget trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              SizedBox(
                width: 64,
                child: Text(
                  label,
                  style: textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  title,
                  style: textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}

class _BipRow extends StatelessWidget {
  const _BipRow({required this.bip});

  final Bip bip;

  @override
  Widget build(BuildContext context) {
    return _CodeRow(
      label: 'BIP ${bip.number}',
      title: bip.title,
      trailing: BipStatusPill(status: bip.status),
      onTap: () =>
          Navigator.of(context).pushNamed(AppRoutes.codeBip(bip.number)),
    );
  }
}

class _ReleaseRow extends StatelessWidget {
  const _ReleaseRow({required this.release});

  final ReleaseNote release;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return _CodeRow(
      label: 'v${release.version}',
      title: release.title,
      trailing: Text(
        DateFormat.yMMMd(l10n.localeName).format(release.releasedAt),
        style: Theme.of(context).textTheme.labelMedium,
      ),
      onTap: () => Navigator.of(
        context,
      ).pushNamed(AppRoutes.codeChangelog(release.project, release.version)),
    );
  }
}

class _NewsRow extends StatelessWidget {
  const _NewsRow({required this.article});

  final NewsArticle article;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return InkWell(
      onTap: () =>
          Navigator.of(context).pushNamed(AppRoutes.newsArticle(article.slug)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: textTheme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${article.author.displayName} · '
                    '${l10n.shortMin(article.readTimeMinutes)}',
                    style: textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
