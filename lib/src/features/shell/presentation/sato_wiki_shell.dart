import 'package:flutter/material.dart';

import '../../../core/navigation/sato_wiki_tab.dart';
import '../../../core/settings/app_settings_controller.dart';
import '../../code/presentation/code_dashboard_screen.dart';
import '../../history/presentation/history_timeline_screen.dart';
import '../../news/presentation/news_feed_screen.dart';
import '../../wiki/presentation/wiki_overview_screen.dart';

class SatoWikiShell extends StatefulWidget {
  const SatoWikiShell({required this.settingsController, super.key});

  final AppSettingsController settingsController;

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
    final colorScheme = Theme.of(context).colorScheme;
    final selectedTab = widget.settingsController.lastTab;
    final screens = [
      WikiOverviewScreen(
        selectedLevel: widget.settingsController.readingLevel,
        onLevelChanged: (level) {
          widget.settingsController.setReadingLevel(level);
        },
      ),
      const NewsFeedScreen(),
      const HistoryTimelineScreen(),
      const CodeDashboardScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          tooltip: 'Menu',
          onPressed: () {},
        ),
        title: const Text('SatoWiki'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: colorScheme.outlineVariant),
        ),
      ),
      body: IndexedStack(index: selectedTab.index, children: screens),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: NavigationBar(
          selectedIndex: selectedTab.index,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (index) {
            _handleDestinationSelected(context, SatoWikiTab.fromIndex(index));
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book),
              label: 'Wiki',
            ),
            NavigationDestination(
              icon: Icon(Icons.newspaper_outlined),
              selectedIcon: Icon(Icons.newspaper),
              label: 'News',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_edu_outlined),
              selectedIcon: Icon(Icons.history_edu),
              label: 'History',
            ),
            NavigationDestination(
              icon: Icon(Icons.terminal_outlined),
              selectedIcon: Icon(Icons.terminal),
              label: 'Code',
            ),
          ],
        ),
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
