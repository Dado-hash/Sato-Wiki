import 'package:flutter/material.dart';

import '../navigation/sato_wiki_tab.dart';
import 'sato_tab_bar.dart';

class SatoScaffold extends StatelessWidget {
  const SatoScaffold({
    required this.selectedTab,
    required this.onTabSelected,
    required this.body,
    super.key,
  });

  final SatoWikiTab selectedTab;
  final ValueChanged<SatoWikiTab> onTabSelected;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: body,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: SatoTabBar(
          selectedTab: selectedTab,
          onTabSelected: onTabSelected,
        ),
      ),
    );
  }
}
