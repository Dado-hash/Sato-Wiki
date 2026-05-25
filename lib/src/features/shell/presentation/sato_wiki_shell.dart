import 'package:flutter/material.dart';

import '../../../core/content/app_content.dart';
import '../../../core/navigation/sato_wiki_tab.dart';
import '../../../core/settings/app_settings_controller.dart';
import '../../../core/widgets/sato_scaffold.dart';
import '../../code/presentation/code_dashboard_screen.dart';
import '../../history/presentation/history_timeline_screen.dart';
import '../../news/presentation/news_feed_screen.dart';
import '../../wiki/presentation/wiki_overview_screen.dart';

class SatoWikiShell extends StatefulWidget {
  const SatoWikiShell({
    required this.settingsController,
    required this.appContent,
    super.key,
  });

  final AppSettingsController settingsController;
  final AppContent appContent;

  @override
  State<SatoWikiShell> createState() => _SatoWikiShellState();
}

class _SatoWikiShellState extends State<SatoWikiShell> {
  @override
  void initState() {
    super.initState();
    widget.settingsController.addListener(_handleSettingsChanged);
  }

  @override
  void didUpdateWidget(SatoWikiShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settingsController != widget.settingsController) {
      oldWidget.settingsController.removeListener(_handleSettingsChanged);
      widget.settingsController.addListener(_handleSettingsChanged);
    }
  }

  @override
  void dispose() {
    widget.settingsController.removeListener(_handleSettingsChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedTab = widget.settingsController.lastTab;
    final screens = [
      WikiOverviewScreen(
        store: widget.appContent.store,
        selectedLevel: widget.settingsController.readingLevel,
        onLevelChanged: (level) {
          widget.settingsController.setReadingLevel(level);
        },
      ),
      NewsFeedScreen(store: widget.appContent.store),
      HistoryTimelineScreen(store: widget.appContent.store),
      CodeDashboardScreen(store: widget.appContent.store),
    ];

    return SatoScaffold(
      selectedTab: selectedTab,
      onTabSelected: (tab) => _handleDestinationSelected(context, tab),
      body: IndexedStack(index: selectedTab.index, children: screens),
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
