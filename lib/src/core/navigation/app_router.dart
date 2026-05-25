import 'package:flutter/material.dart';

import '../../features/code/presentation/code_dashboard_screen.dart';
import '../../features/history/presentation/history_timeline_screen.dart';
import '../../features/news/presentation/news_feed_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../features/shell/presentation/sato_wiki_shell.dart';
import '../../features/wiki/presentation/wiki_overview_screen.dart';
import '../content/app_content.dart';
import '../settings/app_settings_controller.dart';
import 'app_routes.dart';
import 'sato_wiki_tab.dart';

abstract final class AppRouter {
  static Route<dynamic> generateRoute(
    RouteSettings settings,
    AppSettingsController settingsController,
    AppContent appContent,
  ) {
    final routeName = settings.name ?? AppRoutes.root;
    final tabRoute = _tabRouteFor(routeName, settingsController, appContent);
    if (tabRoute != null) {
      return tabRoute;
    }

    if (routeName == AppRoutes.search) {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => SearchScreen(searchIndex: appContent.searchIndex),
      );
    }

    final target = DeepLinkTarget.tryParse(routeName);
    if (target != null) {
      settingsController.setLastTab(target.tab);

      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) =>
            _screenForTarget(target, settingsController, appContent),
      );
    }

    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => UnknownRouteScreen(routeName: routeName),
    );
  }

  static MaterialPageRoute<void>? _tabRouteFor(
    String routeName,
    AppSettingsController settingsController,
    AppContent appContent,
  ) {
    final tab = routeName == AppRoutes.root
        ? settingsController.lastTab
        : SatoWikiTab.fromRoutePath(routeName);

    if (tab == null) {
      return null;
    }

    settingsController.setLastTab(tab);

    return MaterialPageRoute<void>(
      settings: RouteSettings(name: tab.routePath),
      builder: (_) => SatoWikiShell(
        settingsController: settingsController,
        appContent: appContent,
      ),
    );
  }

  static Widget _screenForTarget(
    DeepLinkTarget target,
    AppSettingsController settingsController,
    AppContent appContent,
  ) {
    final segments = Uri.parse(target.routeName).pathSegments;

    if (segments.length == 3 &&
        segments[0] == 'wiki' &&
        segments[1] == 'categories') {
      return WikiCategoryScreen(store: appContent.store, category: segments[2]);
    }

    if (segments.length == 3 &&
        segments[0] == 'wiki' &&
        segments[1] == 'entries') {
      return WikiEntryScreen(
        store: appContent.store,
        slug: segments[2],
        selectedLevel: settingsController.readingLevel,
        onLevelChanged: settingsController.setReadingLevel,
      );
    }

    if (segments.length == 3 &&
        segments[0] == 'news' &&
        segments[1] == 'articles') {
      return NewsArticleScreen(store: appContent.store, slug: segments[2]);
    }

    if (segments.length == 3 &&
        segments[0] == 'history' &&
        segments[1] == 'events') {
      return HistoryEventScreen(store: appContent.store, slug: segments[2]);
    }

    if (segments.length == 3 &&
        segments[0] == 'code' &&
        segments[1] == 'bips') {
      return BipDetailScreen(
        store: appContent.store,
        number: int.tryParse(segments[2]) ?? -1,
      );
    }

    if (segments.length == 4 &&
        segments[0] == 'code' &&
        segments[1] == 'changelogs') {
      return ReleaseNoteScreen(
        store: appContent.store,
        project: segments[2],
        version: segments[3],
      );
    }

    return DeepLinkPlaceholderScreen(target: target);
  }
}

final class DeepLinkTarget {
  const DeepLinkTarget({
    required this.tab,
    required this.title,
    required this.metadata,
    required this.routeName,
  });

  final SatoWikiTab tab;
  final String title;
  final String metadata;
  final String routeName;

  static DeepLinkTarget? tryParse(String routeName) {
    final segments = Uri.parse(routeName).pathSegments;

    if (segments.length == 3 &&
        segments[0] == 'wiki' &&
        segments[1] == 'categories') {
      return DeepLinkTarget(
        tab: SatoWikiTab.wiki,
        title: 'Wiki category',
        metadata: segments[2],
        routeName: routeName,
      );
    }

    if (segments.length == 3 &&
        segments[0] == 'wiki' &&
        segments[1] == 'entries') {
      return DeepLinkTarget(
        tab: SatoWikiTab.wiki,
        title: 'Wiki entry',
        metadata: segments[2],
        routeName: routeName,
      );
    }

    if (segments.length == 3 &&
        segments[0] == 'news' &&
        segments[1] == 'articles') {
      return DeepLinkTarget(
        tab: SatoWikiTab.news,
        title: 'News article',
        metadata: segments[2],
        routeName: routeName,
      );
    }

    if (segments.length == 3 &&
        segments[0] == 'history' &&
        segments[1] == 'events') {
      return DeepLinkTarget(
        tab: SatoWikiTab.history,
        title: 'History event',
        metadata: segments[2],
        routeName: routeName,
      );
    }

    if (segments.length == 3 &&
        segments[0] == 'code' &&
        segments[1] == 'bips') {
      return DeepLinkTarget(
        tab: SatoWikiTab.code,
        title: 'BIP detail',
        metadata: 'BIP ${segments[2]}',
        routeName: routeName,
      );
    }

    if (segments.length == 4 &&
        segments[0] == 'code' &&
        segments[1] == 'changelogs') {
      return DeepLinkTarget(
        tab: SatoWikiTab.code,
        title: 'Changelog',
        metadata: '${segments[2]} ${segments[3]}',
        routeName: routeName,
      );
    }

    return null;
  }
}

class DeepLinkPlaceholderScreen extends StatelessWidget {
  const DeepLinkPlaceholderScreen({required this.target, super.key});

  final DeepLinkTarget target;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('SatoWiki')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      target.title,
                      style: textTheme.headlineLarge?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(target.metadata, style: textTheme.titleLarge),
                    const SizedBox(height: 12),
                    Text(target.routeName, style: textTheme.labelLarge),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class UnknownRouteScreen extends StatelessWidget {
  const UnknownRouteScreen({required this.routeName, super.key});

  final String routeName;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('SatoWiki')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Route not found', style: textTheme.headlineLarge),
              const SizedBox(height: 8),
              Text(routeName, style: textTheme.labelLarge),
            ],
          ),
        ),
      ),
    );
  }
}
