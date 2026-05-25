import 'package:flutter/material.dart';

import '../../code/presentation/code_dashboard_screen.dart';
import '../../history/presentation/history_timeline_screen.dart';
import '../../news/presentation/news_feed_screen.dart';
import '../../wiki/presentation/wiki_overview_screen.dart';

class SatoWikiShell extends StatefulWidget {
  const SatoWikiShell({super.key});

  @override
  State<SatoWikiShell> createState() => _SatoWikiShellState();
}

class _SatoWikiShellState extends State<SatoWikiShell> {
  int _selectedIndex = 0;

  static const _screens = [
    WikiOverviewScreen(),
    NewsFeedScreen(),
    HistoryTimelineScreen(),
    CodeDashboardScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (index) {
            setState(() => _selectedIndex = index);
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
}
