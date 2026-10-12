import 'package:flutter/material.dart';

import '../../features/code/presentation/code_dashboard_screen.dart';
import '../../features/code/presentation/release_list_screen.dart';
import '../../features/history/presentation/history_timeline_screen.dart';
import '../../features/news/presentation/news_feed_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../features/settings/presentation/bookmarks_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/shell/presentation/sato_wiki_shell.dart';
import '../../features/wiki/presentation/wiki_overview_screen.dart';
import '../content/app_content.dart';
import '../content/application/app_content_controller.dart';
import '../settings/app_settings_controller.dart';
import '../widgets/content_media_scope.dart';
import '../widgets/detail_scaffold.dart';
import '../../generated/l10n/app_localizations.dart';
import 'app_routes.dart';
import 'sato_wiki_tab.dart';

abstract final class AppRouter {
  static Route<dynamic> generateRoute(
    RouteSettings settings,
    AppSettingsController settingsController,
    AppContentController contentController,
  ) {
    final routeName = settings.name ?? AppRoutes.root;
    final tabRoute = _tabRouteFor(
      routeName,
      settingsController,
      contentController,
    );
    if (tabRoute != null) {
      return tabRoute;
    }

    if (routeName == AppRoutes.search) {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => AnimatedBuilder(
          animation: contentController,
          builder: (_, _) =>
              SearchScreen(searchIndex: contentController.content.searchIndex),
        ),
      );
    }

    if (routeName == AppRoutes.settings) {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => SettingsScreen(
          settings: settingsController,
          content: contentController,
        ),
      );
    }

    if (routeName == AppRoutes.bookmarks) {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => AnimatedBuilder(
          animation: contentController,
          builder: (_, _) {
            final appContent = contentController.content;

            return ContentMediaScope(
              resolver: appContent.mediaResolver,
              child: BookmarksScreen(
                store: appContent.store,
                settings: settingsController,
              ),
            );
          },
        ),
      );
    }

    final target = DeepLinkTarget.tryParse(routeName);
    if (target != null) {
      // Content screens do not change the last tab: related links push them
      // on top of the current tab, which must stay visible behind them.
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => AnimatedBuilder(
          animation: contentController,
          builder: (_, _) {
            final appContent = contentController.content;

            return ContentMediaScope(
              resolver: appContent.mediaResolver,
              child: _screenForTarget(target, settingsController, appContent),
            );
          },
        ),
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
    AppContentController contentController,
  ) {
    final tab = routeName == AppRoutes.root
        ? settingsController.lastTab
        : SatoWikiTab.fromRoutePath(routeName);

    if (tab == null) {
      return null;
    }

    // Only a deep link to another tab changes anything here: the initial
    // route and tab taps already carry the last tab, so this is a no-op.
    settingsController.setLastTab(tab);

    return MaterialPageRoute<void>(
      settings: const RouteSettings(name: AppRoutes.root),
      builder: (_) => SatoWikiShell(
        settingsController: settingsController,
        contentController: contentController,
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

    if (segments.length == 2 &&
        segments[0] == 'code' &&
        segments[1] == 'bips') {
      return BipListScreen(store: appContent.store);
    }

    if (segments.length == 2 &&
        segments[0] == 'code' &&
        segments[1] == 'changelogs') {
      return ReleaseListScreen(store: appContent.store);
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

    return UnknownRouteScreen(routeName: target.routeName);
  }
}

final class DeepLinkTarget {
  const DeepLinkTarget({required this.routeName});

  final String routeName;

  static DeepLinkTarget? tryParse(String routeName) {
    final segments = Uri.parse(routeName).pathSegments;

    if (segments.length == 3 &&
        segments[0] == 'wiki' &&
        segments[1] == 'categories') {
      return DeepLinkTarget(routeName: routeName);
    }

    if (segments.length == 3 &&
        segments[0] == 'wiki' &&
        segments[1] == 'entries') {
      return DeepLinkTarget(routeName: routeName);
    }

    if (segments.length == 3 &&
        segments[0] == 'news' &&
        segments[1] == 'articles') {
      return DeepLinkTarget(routeName: routeName);
    }

    if (segments.length == 3 &&
        segments[0] == 'history' &&
        segments[1] == 'events') {
      return DeepLinkTarget(routeName: routeName);
    }

    if (segments.length == 2 &&
        segments[0] == 'code' &&
        segments[1] == 'bips') {
      return DeepLinkTarget(routeName: routeName);
    }

    if (segments.length == 2 &&
        segments[0] == 'code' &&
        segments[1] == 'changelogs') {
      return DeepLinkTarget(routeName: routeName);
    }

    if (segments.length == 3 &&
        segments[0] == 'code' &&
        segments[1] == 'bips') {
      return DeepLinkTarget(routeName: routeName);
    }

    if (segments.length == 4 &&
        segments[0] == 'code' &&
        segments[1] == 'changelogs') {
      return DeepLinkTarget(routeName: routeName);
    }

    return null;
  }
}

class UnknownRouteScreen extends StatelessWidget {
  const UnknownRouteScreen({required this.routeName, super.key});

  final String routeName;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return DetailScaffold(
      title: l10n.routeNotFound,
      children: [Text(routeName, style: textTheme.labelMedium)],
    );
  }
}
