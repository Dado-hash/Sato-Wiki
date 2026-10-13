import 'package:flutter/material.dart';

import '../../features/code/presentation/code_dashboard_screen.dart';
import '../../features/code/presentation/release_list_screen.dart';
import '../../features/history/presentation/history_timeline_screen.dart';
import '../../features/learn/presentation/glossary_screens.dart';
import '../../features/learn/presentation/learning_path_screen.dart';
import '../../features/news/presentation/news_feed_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../features/settings/presentation/bookmarks_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/shell/presentation/sato_wiki_shell.dart';
import '../../features/tools/presentation/reference_list_screen.dart';
import '../../features/tools/presentation/reference_table_screen.dart';
import '../../features/tools/presentation/tool_address_screen.dart';
import '../../features/tools/presentation/tool_hash_screen.dart';
import '../../features/tools/presentation/tool_target_screen.dart';
import '../../features/tools/presentation/tool_transaction_screen.dart';
import '../../features/tools/presentation/tool_units_screen.dart';
import '../../features/wiki/presentation/product_screen.dart';
import '../../features/wiki/presentation/wiki_overview_screen.dart';
import '../../features/wiki/presentation/wiki_subcategory_screen.dart';
import '../content/app_content.dart';
import '../content/domain/content_store.dart';
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

    if (_toolRoutes.contains(routeName)) {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => AnimatedBuilder(
          animation: contentController,
          builder: (_, _) =>
              _toolScreenFor(routeName, contentController.content.store),
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

  /// Offline tools under the Code tab. They need the loaded store for their
  /// wiki links, so they are built from the content controller.
  static const _toolRoutes = {
    AppRoutes.toolHash,
    AppRoutes.toolAddress,
    AppRoutes.toolTransaction,
    AppRoutes.toolTarget,
    AppRoutes.toolUnits,
  };

  static Widget _toolScreenFor(String routeName, ContentStore store) {
    return switch (routeName) {
      AppRoutes.toolHash => ToolHashScreen(store: store),
      AppRoutes.toolAddress => ToolAddressScreen(store: store),
      AppRoutes.toolTransaction => ToolTransactionScreen(store: store),
      AppRoutes.toolTarget => ToolTargetScreen(store: store),
      AppRoutes.toolUnits => ToolUnitsScreen(store: store),
      _ => UnknownRouteScreen(routeName: routeName),
    };
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

    if (segments.length == 1 && segments[0] == 'glossary') {
      return GlossaryListScreen(store: appContent.store);
    }

    if (segments.length == 2 && segments[0] == 'glossary') {
      return GlossaryTermScreen(store: appContent.store, slug: segments[1]);
    }

    if (segments.length == 2 && segments[0] == 'paths') {
      return LearningPathScreen(
        store: appContent.store,
        settings: settingsController,
        slug: segments[1],
      );
    }

    if (segments.length == 3 &&
        segments[0] == 'wiki' &&
        segments[1] == 'subcategories') {
      return WikiSubcategoryScreen(
        store: appContent.store,
        subcategoryId: segments[2],
      );
    }

    if (segments.length == 2 && segments[0] == 'products') {
      return ProductScreen(store: appContent.store, slug: segments[1]);
    }

    if (segments.length == 2 &&
        segments[0] == 'code' &&
        segments[1] == 'references') {
      return ReferenceListScreen(store: appContent.store);
    }

    if (segments.length == 3 &&
        segments[0] == 'code' &&
        segments[1] == 'references') {
      return ReferenceTableScreen(store: appContent.store, slug: segments[2]);
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

    if (segments.length == 1 && segments[0] == 'glossary') {
      return DeepLinkTarget(routeName: routeName);
    }

    if (segments.length == 2 && segments[0] == 'glossary') {
      return DeepLinkTarget(routeName: routeName);
    }

    if (segments.length == 2 && segments[0] == 'paths') {
      return DeepLinkTarget(routeName: routeName);
    }

    if (segments.length == 3 &&
        segments[0] == 'wiki' &&
        segments[1] == 'subcategories') {
      return DeepLinkTarget(routeName: routeName);
    }

    if (segments.length == 2 && segments[0] == 'products') {
      return DeepLinkTarget(routeName: routeName);
    }

    if (segments.length == 2 &&
        segments[0] == 'code' &&
        segments[1] == 'references') {
      return DeepLinkTarget(routeName: routeName);
    }

    if (segments.length == 3 &&
        segments[0] == 'code' &&
        segments[1] == 'references') {
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
