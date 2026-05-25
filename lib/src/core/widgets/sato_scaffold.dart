import 'package:flutter/material.dart';

import '../navigation/sato_wiki_tab.dart';
import '../navigation/app_routes.dart';

class SatoScaffold extends StatelessWidget {
  const SatoScaffold({
    required this.selectedTab,
    required this.onTabSelected,
    required this.body,
    this.title = 'SatoWiki',
    super.key,
  });

  final SatoWikiTab selectedTab;
  final ValueChanged<SatoWikiTab> onTabSelected;
  final Widget body;
  final String title;

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
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.search);
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: colorScheme.outlineVariant),
        ),
      ),
      body: body,
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
            onTabSelected(SatoWikiTab.fromIndex(index));
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
