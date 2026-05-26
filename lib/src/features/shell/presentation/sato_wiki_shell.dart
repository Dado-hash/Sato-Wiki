import 'package:flutter/material.dart';

import '../../../core/content/application/app_content_controller.dart';
import '../../../core/navigation/sato_wiki_tab.dart';
import '../../../core/settings/app_settings_controller.dart';
import '../../../core/widgets/content_media_scope.dart';
import '../../../core/widgets/sato_scaffold.dart';
import '../../code/presentation/code_dashboard_screen.dart';
import '../../history/presentation/history_timeline_screen.dart';
import '../../news/presentation/news_feed_screen.dart';
import '../../wiki/presentation/wiki_overview_screen.dart';

class SatoWikiShell extends StatefulWidget {
  const SatoWikiShell({
    required this.settingsController,
    required this.contentController,
    super.key,
  });

  final AppSettingsController settingsController;
  final AppContentController contentController;

  @override
  State<SatoWikiShell> createState() => _SatoWikiShellState();
}

class _SatoWikiShellState extends State<SatoWikiShell> {
  @override
  void initState() {
    super.initState();
    widget.settingsController.addListener(_handleSettingsChanged);
    widget.contentController.addListener(_handleSettingsChanged);
  }

  @override
  void didUpdateWidget(SatoWikiShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settingsController != widget.settingsController) {
      oldWidget.settingsController.removeListener(_handleSettingsChanged);
      widget.settingsController.addListener(_handleSettingsChanged);
    }
    if (oldWidget.contentController != widget.contentController) {
      oldWidget.contentController.removeListener(_handleSettingsChanged);
      widget.contentController.addListener(_handleSettingsChanged);
    }
  }

  @override
  void dispose() {
    widget.settingsController.removeListener(_handleSettingsChanged);
    widget.contentController.removeListener(_handleSettingsChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedTab = widget.settingsController.lastTab;
    final appContent = widget.contentController.content;
    final screens = [
      WikiOverviewScreen(
        store: appContent.store,
        selectedLevel: widget.settingsController.readingLevel,
        onLevelChanged: (level) {
          widget.settingsController.setReadingLevel(level);
        },
      ),
      NewsFeedScreen(store: appContent.store),
      HistoryTimelineScreen(store: appContent.store),
      CodeDashboardScreen(store: appContent.store),
    ];

    return ContentMediaScope(
      resolver: appContent.mediaResolver,
      child: SatoScaffold(
        selectedTab: selectedTab,
        onTabSelected: (tab) => _handleDestinationSelected(context, tab),
        localePreference: widget.settingsController.localePreference,
        onLocalePreferenceChanged: (preference) {
          widget.settingsController.setLocalePreference(preference);
        },
        body: IndexedStack(index: selectedTab.index, children: screens),
      ),
    );
  }

  void _handleDestinationSelected(BuildContext context, SatoWikiTab tab) {
    widget.settingsController.setLastTab(tab);

    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute != tab.routePath) {
      Navigator.of(context).pushReplacementNamed(tab.routePath);
    }
  }

  void _handleSettingsChanged() {
    if (mounted) {
      setState(() {});
    }
  }
}
